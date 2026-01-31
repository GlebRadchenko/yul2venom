# Venom Backend Deep Research

> **Purpose**: Comprehensive file-by-file analysis of the Vyper Venom backend, optimized for AI agent comprehension. This document focuses on the internal architecture, passes, and assembly emission of the Venom IR system.

**Source Directory**: `vyper/vyper/venom/`

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Core Data Structures](#core-data-structures)
3. [Parser and Operand Reversal](#parser-and-operand-reversal)
4. [Memory Model: Yul vs Venom](#memory-model-yul-vs-venom)
5. [Static Single Assignment (SSA) Form](#static-single-assignment-ssa-form)
6. [Phi Nodes](#phi-nodes)
7. [The `assign` Opcode](#the-assign-opcode)
8. [Analysis Framework](#analysis-framework)
9. [Optimization Passes](#optimization-passes)
10. [Assembly Emission](#assembly-emission)
11. [Stack Management](#stack-management)
12. [Memory Allocation](#memory-allocation)
13. [Effects System](#effects-system)
14. [Calling Convention](#calling-convention)
15. [Critical Gotchas for Yul2Venom](#critical-gotchas)
16. [Pass Pipeline Reference](#pass-pipeline-reference)
17. [Extended Optimization Passes](#extended-optimization-passes)
18. [Function Inlining](#function-inlining)
19. [Memory Optimization](#memory-optimization)
20. [Instruction Categories](#instruction-categories)
21. [Native IR Conversion](#native-ir-conversion-ir_node_to_venompy)

---

## Architecture Overview

The Venom backend transforms Venom IR into EVM bytecode. The architecture follows a standard compiler pipeline:

```
┌─────────────────┐
│   IRContext     │  ← Top-level container (multiple functions + data)
├─────────────────┤
│   IRFunction    │  ← Named function with entry block
├─────────────────┤
│  IRBasicBlock   │  ← Labeled block with instruction list
├─────────────────┤
│  IRInstruction  │  ← Operation with operands and outputs
├─────────────────┤
│   IROperand     │  ← Variable, Literal, or Label
└─────────────────┘
```

**Key Files**:
- [`context.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/context.py) - `IRContext` container
- [`function.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/function.py) - `IRFunction` with basic blocks
- [`basicblock.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/basicblock.py) - Core IR types
- [`__init__.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/__init__.py) - Entry point, pass orchestration

---

## Core Data Structures

### IROperand Hierarchy

```python
# From basicblock.py lines 52-140
class IROperand(ABC):      # Abstract base
    value: OperandValue    # str for vars/labels, int for literals

class IRVariable(IROperand):    # %name format
    @property
    def name(self) -> str       # Returns with % prefix

class IRLiteral(IROperand):     # Integer constants
    value: int                  # Raw integer value

class IRLabel(IROperand):       # @label format for jumps
    value: str                  # Label name (without @)
    is_symbol: bool             # True if user-defined symbol
```

### IRInstruction Structure

```python
# From basicblock.py lines 260-340
class IRInstruction:
    opcode: str                     # e.g., "add", "jmp", "phi"
    operands: list[IROperand]       # Input operands
    _outputs: list[IRVariable]      # Output variables (single for most ops)
    parent: IRBasicBlock            # Containing basic block
    ast_source: Optional            # Source location for errors
```

**Critical Properties**:
- `output`: Returns first output (asserts single output exists)
- `get_outputs()`: Returns all outputs (invoke can have multiple)
- `is_bb_terminator`: True for jmp, jnz, djmp, ret, return, revert, stop
- `is_commutative`: True for add, mul, and, or, xor, eq
- `is_pseudo`: True for param, dbname (not real instructions)
- `flippable`: True for lt/gt, slt/sgt pairs (can swap args + opcode)

### IRBasicBlock

```python
# From basicblock.py lines 400-530
class IRBasicBlock:
    label: IRLabel
    parent: IRFunction
    instructions: list[IRInstruction]

    # Key methods:
    is_terminated -> bool         # Has terminator instruction
    is_halting -> bool            # return/revert/stop/invalid
    pseudo_instructions           # param, phi, dbname
    non_phi_instructions          # Everything except phi
    out_bbs -> list[IRBasicBlock] # Successor blocks
```

### IRFunction

```python
# From function.py
class IRFunction:
    name: IRLabel
    ctx: IRContext
    args: list[IRParameter]       # Function parameters
    _basic_block_dict: dict       # label.name -> IRBasicBlock
    last_variable: int            # Counter for SSA variables

    entry -> IRBasicBlock         # First basic block
```

### IRContext

```python
# From context.py
class IRContext:
    functions: dict[IRLabel, IRFunction]
    entry_function: IRFunction
    data_segment: list[DataSection]
    mem_allocator: MemoryAllocator
    last_label: int
    last_variable: int
```

---

## Parser and Operand Reversal

> **⚠️ CRITICAL FOR YUL2VENOM**

### File: [`parser.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/parser.py)

The parser implements **operand reversal** for most instructions.

```python
# parser.py lines 255-264
def instruction(self, children) -> IRInstruction:
    # ...
    if opcode == "invoke":
        # reverse stack arguments but not label arg
        operands = [operands[0]] + list(reversed(operands[1:]))
    elif opcode not in ("jmp", "jnz", "djmp", "phi"):
        operands.reverse()  # ⚠️ REVERSAL HAPPENS HERE
    return IRInstruction(opcode, operands)
```

**Implication**: When generating Venom IR text:
- **Regular ops**: Write operands in **human-readable (EVM) order**, parser will reverse
  - `add a, b` in text → internally stored as `add [b, a]` → emits `PUSH a, PUSH b, ADD`
- **invoke**: Label first, then args in **reverse stack order**
- **Control flow (jmp, jnz, djmp, phi)**: Operands are NOT reversed

### Text Format Examples

```venom
; Human-readable text format:
%result = add %a, %b      ; add(a, b) - parser reverses to internal [b, a]
%cmp = lt %x, %y          ; lt(x, y) - parser reverses to internal [y, x]
jnz %cond, @true, @false  ; NOT reversed
%merged = phi @blk1 %v1 @blk2 %v2  ; NOT reversed
```

---

## Memory Model: Yul vs Venom

> **Critical for Yul2Venom Transpilation**

### Yul/Solidity Memory Model

Yul (and Solidity) uses a **linear heap allocation** model with a **free memory pointer**:

```
┌──────────────────────────────────────────────────────────┐
│ Memory Layout                                             │
├──────────────────────────────────────────────────────────┤
│ 0x00 - 0x3F (64 bytes)  │ Scratch space for hashing      │
│ 0x40 - 0x5F (32 bytes)  │ Free memory pointer location   │
│ 0x60 - 0x7F (32 bytes)  │ Zero slot (empty array init)   │
│ 0x80 onwards            │ Heap (grows upward)            │
└──────────────────────────────────────────────────────────┘
```

**Key Characteristics**:
- **Free memory pointer at `0x40`**: Yul reads/writes this location directly
- **Heap starts at `0x80`**: Initial value of free pointer
- **Bump allocation**: New allocations increment the free pointer
- **No deallocation**: Memory only grows during a call
- **Manual management in Yul**: Developer must update `mload(0x40)` / `mstore(0x40, ...)`

```yul
// Yul allocation pattern
let ptr := mload(0x40)           // Get free pointer
mstore(ptr, value)                // Write data
mstore(0x40, add(ptr, 0x20))     // Bump free pointer
```

### Venom Memory Model

Venom uses an **abstract allocation** model with explicit allocation instructions:

```
┌──────────────────────────────────────────────────────────┐
│ Venom Memory Layout (after concretization)               │
├──────────────────────────────────────────────────────────┤
│ 0x00 - 0x1F (32 bytes)  │ FREE_VAR_SPACE (scratch #1)    │
│ 0x20 - 0x3F (32 bytes)  │ FREE_VAR_SPACE2 (scratch #2)   │
│ 0x40 onwards            │ Alloca regions (non-overlapping)│
└──────────────────────────────────────────────────────────┘
```

**Key Characteristics**:
- **No free memory pointer**: Memory is tracked abstractly through `Allocation` objects
- **Static allocation**: All memory positions computed at compile-time
- **alloca instructions**: Declare memory regions symbolically
- **Memory liveness analysis**: Allocator reuses positions when lifetimes don't overlap
- **Concretization pass**: Converts abstract allocas to concrete offsets

**Allocation Instructions**:

| Instruction | Purpose | Operands |
|-------------|---------|----------|
| `alloca` | Local variable/buffer | `size` |
| `palloca` | Parameter passed via memory | `size, offset, alloca_id` |
| `calloca` | Caller-side buffer for call params | `size, offset, alloca_id, label` |
| `gep` | Get Element Pointer (offset calc) | `base, offset` |

```venom
; Venom allocation pattern
%buf = alloca 64           ; Request 64 bytes
mstore %buf, %value        ; Write to allocated region
%elem = gep %buf, 32       ; Get pointer to buf+32
mload %elem                ; Read from buf+32
```

### Memory Model Translation for Yul2Venom

| Yul Pattern | Venom Equivalent |
|-------------|------------------|
| `mload(0x40)` | Not needed (no free pointer) |
| `mstore(0x40, add(ptr, 0x20))` | Not needed (static allocation) |
| `let ptr := mload(0x40)` | `%ptr = alloca <size>` |
| `mstore(ptr, val)` | `mstore %ptr, %val` |
| `mload(add(ptr, 32))` | `%gep = gep %ptr, 32` then `mload %gep` |
| Scratch at `0x00-0x3F` | Use `alloca` or FREE_VAR_SPACE |

**Translation Strategies**:

1. **Static allocation**: When allocation size is known at transpile-time, use `alloca` directly
2. **Dynamic allocation**: When size is runtime-determined, must either:
   - Conservatively over-allocate
   - Use mload/mstore with computed offsets (less optimizable)
3. **Free pointer pattern**: Eliminate entirely - Yul's `mload(0x40)`/`mstore(0x40, ...)` becomes no-ops

### Memory Aliasing in Venom

The **MemoryLocation** class tracks aliasing:

```python
# From memory_location.py
@dataclass
class MemoryLocation:
    offset: Optional[int] = None    # None = unknown
    size: Optional[int] = None      # None = unknown
    alloca: Optional[Allocation]    # Allocation region (None = global)
    _is_volatile: bool = False      # Accessed externally?
```

**Aliasing Rules**:
- Different allocas **never alias** (guaranteed by allocator)
- Same alloca with known non-overlapping offsets **don't alias**
- Unknown offset or size → **may alias** (conservative)
- `is_volatile` → Always treated as aliasing (external access)

### Memory Passes Pipeline

```
┌─────────────────────┐
│  FixMemLocationsPass │ ← Convert FREE_VAR_SPACE literals to allocas
├─────────────────────┤
│     FloatAllocas     │ ← Move all allocas to entry block
├─────────────────────┤
│      Mem2Var         │ ← Promote eligible allocas to SSA variables
├─────────────────────┤
│    MemMergePass      │ ← Fuse adjacent memory operations
├─────────────────────┤
│  DeadStoreElim       │ ← Remove unused stores (uses MemSSA)
├─────────────────────┤
│ ConcretizeMemLocPass │ ← Assign concrete offsets to allocas
├─────────────────────┤
│    LowerDloadPass    │ ← Convert dload to codecopy
└─────────────────────┘
```

---

## Static Single Assignment (SSA) Form

> **Foundational IR Property**

### SSA Overview

In SSA form, every variable is assigned **exactly once**. This enables powerful optimizations by making data flow explicit.

**Non-SSA (mutable)**:
```
x = 5
x = x + 1    ; x reassigned
use(x)
```

**SSA**:
```
%x.0 = 5
%x.1 = add %x.0, 1
use(%x.1)
```

### Variable Naming Convention

Venom uses `:` suffix for SSA versions:
- Original variable: `%x`
- After first def: `%x:0`
- After second def: `%x:1`
- And so on...

### MakeSSA Pass

**File**: [`passes/make_ssa.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/passes/make_ssa.py)

**Algorithm (Standard SSA Construction)**:

1. **Compute definition points**: Find where each variable is defined
2. **Place phi nodes**: At dominance frontiers where definitions merge
3. **Rename variables**: Apply version numbers to all defs and uses
4. **Remove degenerate phis**: Simplify trivial phis to assigns

```python
# Phi placement at dominance frontier
for dom in self.dom.dominator_frontiers[bb]:
    self._place_phi(var, dom)

# Variable renaming with version stack
new_var = IRVariable(f"{og_var.name}:{version}")
self.var_name_stacks[name].append(version)
```

---

## Phi Nodes

> **Merging Values from Different Control Flow Paths**

### Phi Node Semantics

A phi node "magically" selects between values based on which predecessor block control came from:

```venom
entry:
    %cond = ...
    jnz %cond, @then, @else

then:
    %val_then = 42
    jmp @merge

else:
    %val_else = 99
    jmp @merge

merge:
    %result = phi @then, %val_then, @else, %val_else
    ; %result is 42 if came from @then, 99 if came from @else
```

### Phi Node Format

```
%output = phi @label1, %var1, @label2, %var2, ...
```

**Operands are pairs**: `(predecessor_label, value_from_that_predecessor)`

### Phi Node Rules

1. **Must be at block start**: Phis precede all other instructions in a basic block
2. **One phi per SSA variable per merge point**: At most one phi per variable in each block
3. **All predecessors must be covered**: Each incoming edge needs an operand pair
4. **Values must be defined in predecessor**: The variable must dominate the phi

### Phi Elimination Pass

**File**: [`passes/phi_elimination.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/passes/phi_elimination.py)

**Purpose**: Simplify phis that have a single origin to `assign` instructions.

```python
# If all phi operands trace back to a single instruction
if len(origins) == 1:
    phi.opcode = "assign"
    phi.operands = [origin.output]
```

**Origin Tracing**: The pass follows chains of phis and assigns to find "root" instructions:

```
%a = some_op(...)       ; origin
%b = assign %a
%c = phi @x, %a, @y, %b ; both trace back to %a
; → simplified to: %c = assign %a
```

**Barrier Phis**: When a phi has multiple true origins, it becomes a "barrier" that downstream phis can reference:

```
%c = phi %a, %b  ; barrier (two origins)
%d = assign %c
%f = phi %d, %c  ; both paths → %c, so %f = %c
```

### Degenerate Phi Handling

During SSA construction, degenerate phis are simplified:

1. **No operands remaining** (after removing self-refs): Remove entirely
2. **Single operand**: Convert to `%out = assign %val`
3. **All same operand values**: Convert to `%out = assign %val`
4. **Multiple different**: Keep as phi

### Phi Node in Assembly Emission

Phis don't generate code directly. Instead, `venom_to_assembly.py` handles them by:
1. Finding which phi operand is on the stack (based on predecessor)
2. Using `poke()` to rename that stack slot to the phi output

```python
# From venom_to_assembly.py
if opcode == "phi":
    depth = stack.get_phi_depth(phis)
    stack.poke(depth, phi_output)  # Virtual "rename"
```

---

## The `assign` Opcode

> **Central to SSA and Code Generation**

### Purpose

The `assign` opcode is Venom's mechanism for creating SSA variable copies:

```venom
%y = assign %x       ; %y now holds the value of %x (same value, new SSA name)
%const = assign 42   ; %const holds the literal value 42
```

### Semantic Meaning

- **Variable operand**: Creates an alias in the IR (logically same value, different SSA name)
- **Literal operand**: Materializes a constant into an SSA variable

### Assembly Emission

The `assign` opcode generates **zero EVM instructions** in the common case:

```python
# From venom_to_assembly.py
elif opcode == "assign":
    # No EVM code - just stack renaming
    pass
```

This works because:
1. `SingleUseExpansion` pass ensures single-use variables
2. Assembly generator tracks stack positions symbolically
3. Value is already on stack; just update the name in `StackModel`

### Use Cases

1. **Phi elimination**: Degenerate phis become assigns
2. **Literal extraction**: `add 5, %x` → `%t = assign 5; add %t, %x`
3. **Variable forwarding**: Copying a value to avoid multi-use
4. **SSA construction**: When renaming creates new versions

### Yul to Venom Translation

| Yul Pattern | Venom Pattern |
|-------------|---------------|
| `let x := 5` | `%x = assign 5` |
| `let y := x` | `%y = assign %x` |
| `x := add(x, 1)` | `%x:1 = add %x:0, 1` (direct, no assign needed) |
| `foo(1, 2)` | `%1 = assign 1; %2 = assign 2; foo %1, %2` |

### Assign Elimination Pass

**File**: [`passes/assign_elimination.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/passes/assign_elimination.py)

Propagates variable values through assign chains and removes redundant assigns:

```python
# Before:
%y = assign %x
use(%y)

# After (if %y has single use):
use(%x)
```

---

## Analysis Framework

### Analysis Base Classes

**File**: [`analysis/analysis.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/analysis/analysis.py)

```python
class IRAnalysis:
    analyses_cache: IRAnalysesCache
    function: IRFunction
    
    def analyze(self): ...      # Override to perform analysis
    def invalidate(self): ...   # Called when cache is invalidated

class IRAnalysesCache:
    def request_analysis(self, cls) -> IRAnalysis
    def force_analysis(self, cls) -> IRAnalysis
    def invalidate_analysis(self, cls)
```

### CFGAnalysis

**File**: [`analysis/cfg.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/analysis/cfg.py)

```python
class CFGAnalysis(IRAnalysis):
    cfg_in(bb) -> OrderedSet[IRBasicBlock]   # Predecessors
    cfg_out(bb) -> OrderedSet[IRBasicBlock]  # Successors
    is_reachable(bb) -> bool
    is_normalized() -> bool    # No bb with multiple preds AND multiple succs
    dfs_post_walk -> Iterator  # Post-order DFS
    dfs_pre_walk -> Iterator   # Pre-order DFS
```

**Normalization Requirement**: The code generator requires normalized CFG. A BB cannot have BOTH multiple predecessors AND multiple successors.

### LivenessAnalysis

**File**: [`analysis/liveness.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/analysis/liveness.py)

```python
class LivenessAnalysis(IRAnalysis):
    live_vars_at(inst) -> OrderedSet[IRVariable]  # Live BEFORE inst
    out_vars(bb) -> OrderedSet[IRVariable]        # Live at BB exit
    liveness_in_vars(bb) -> OrderedSet            # Live at first non-phi
    input_vars_from(source, target) -> OrderedSet # Phi-aware liveness
```

**Key Algorithm** (line 50-61):
```python
# Standard liveness: live_in = (live_out - defs) ∪ uses
for instruction in reversed(bb.instructions):
    liveness = liveness.copy()
    liveness.dropmany(outs)   # Remove defined vars
    liveness.update(ins)      # Add used vars
```

### DFGAnalysis

**File**: [`analysis/dfg.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/analysis/dfg.py)

```python
class DFGAnalysis(IRAnalysis):
    get_uses(var) -> OrderedSet[IRInstruction]      # Instructions using var
    get_producing_instruction(var) -> IRInstruction  # Defines var
    are_equivalent(var1, var2) -> bool              # Same through assign chain
```

### DominatorTreeAnalysis

**File**: [`analysis/dominators.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/analysis/dominators.py)

```python
class DominatorTreeAnalysis(IRAnalysis):
    dominators: dict[BB, OrderedSet[BB]]          # All dominators
    immediate_dominators: dict[BB, BB]            # Direct dominator
    dominated: dict[BB, OrderedSet[BB]]           # Children in dom tree
    dominator_frontiers: dict[BB, OrderedSet[BB]] # For SSA phi placement
    
    dominates(dom, sub) -> bool
    dom_post_order -> Iterator[BB]  # For SSA construction
```

---

## Optimization Passes

### Pass Base Class

**File**: [`passes/base_pass.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/passes/base_pass.py)

```python
class IRPass:
    analyses_cache: IRAnalysesCache
    function: IRFunction
    
    def run_pass(self, **kwargs): ...  # Override to implement
```

### MakeSSA Pass

**File**: [`passes/make_ssa.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/passes/make_ssa.py)

**Purpose**: Convert function to Static Single Assignment form.

**Algorithm**:
1. Compute definition points for each variable
2. Add phi nodes at dominance frontiers
3. Rename variables with version numbers (`%x` → `%x:1`, `%x:2`)
4. Remove degenerate phis (single operand → assign)

```python
# Phi placement at dominance frontier
for dom in self.dom.dominator_frontiers[bb]:
    self._place_phi(var, dom)

# Variable renaming
new_var = IRVariable(f"{og_var.name}:{version}")
```

### Mem2Var Pass

**File**: [`passes/mem2var.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/passes/mem2var.py)

**Purpose**: Promote memory operations to stack variables when safe.

```python
# alloca → variable promotion
# If alloca only used by mstore/mload/return, convert to assigns

# mstore %alloca, %val  →  %var = %val
# mload %alloca         →  use %var
```

### PhiEliminationPass

**File**: [`passes/phi_elimination.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/passes/phi_elimination.py)

**Purpose**: Eliminate redundant phi nodes by tracing origin chains.

```python
# If phi has single origin instruction, replace with assign
if len(origins) == 1:
    convert_to_assign(phi, origin.output)
```

### SCCP (Sparse Conditional Constant Propagation)

**File**: [`passes/sccp/sccp.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/passes/sccp/sccp.py)

**Purpose**: Propagate constants and eliminate dead branches.

Uses lattice-based dataflow:
- **TOP**: Unknown value
- **BOTTOM**: Multiple/conflicting values
- **IRLiteral**: Known constant

### DFTPass (Data Flow Tree)

**File**: [`passes/dft.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/passes/dft.py)

**Purpose**: Reorder instructions within basic blocks for optimal stack usage.

**Key Concepts**:
- `dda`: Data Dependency Analysis - instruction depends on operand producers
- `eda`: Effect Dependency Analysis - read/write ordering

```python
# Reorder based on:
# 1. Effect-only dependencies (must preserve order)
# 2. Data dependencies (operand producers before consumers)
# 3. Cost heuristic for stack depth
```

### SingleUseExpansion

**File**: [`passes/single_use_expansion.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/passes/single_use_expansion.py)

**Purpose**: Prepare IR for venom_to_assembly by ensuring:
1. Each variable used at most once (except by assigns)
2. All operands are variables (literals extracted to assigns)

```python
# Before:
%r = add 10, %x

# After:
%t1 = 10
%r = add %t1, %x
```

**REQUIRED** for venom_to_assembly.py (see pass docstring).

### CFGNormalization

**File**: [`passes/cfg_normalization.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/passes/cfg_normalization.py)

**Purpose**: Split basic blocks to ensure CFG normalization.

```
Before:                       After:
┌──────┐                     ┌──────┐
│  A   │─jnz─→ B             │  A   │─jnz─→ A_split_C
│      │─────→ C             │      │─────→ C
└──────┘                     └──────┘
    ↑                            ↑
    │                            │
┌───┴──┐                     ┌───┴──┐    ┌──────────┐
│  D   │─────→ C             │  D   │─→  │A_split_C │─→ C
└──────┘                     └──────┘    └──────────┘
```

Inserts split blocks when BB has multiple predecessors from branching blocks.

### SimplifyCFGPass

**File**: [`passes/simplify_cfg.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/passes/simplify_cfg.py)

**Purpose**: Merge sequential blocks, remove unreachable code.

```python
# Merge A → B (single predecessor/successor)
# Remove unreachable blocks
# Fix phi references after merges
```

---

## Assembly Emission

### File: [`venom_to_assembly.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/venom_to_assembly.py)

### VenomCompiler Class

```python
class VenomCompiler:
    ctx: IRContext
    liveness: LivenessAnalysis
    dfg: DFGAnalysis
    cfg: CFGAnalysis
    spiller: StackSpiller
    
    generate_evm_assembly() -> list[AssemblyInstruction]
```

### Assembly Generation Flow

```python
def generate_evm_assembly(self):
    for fn in self.ctx.functions.values():
        # Request fresh analyses
        ac = IRAnalysesCache(fn)
        self.liveness = ac.request_analysis(LivenessAnalysis)
        self.dfg = ac.request_analysis(DFGAnalysis)
        self.cfg = ac.request_analysis(CFGAnalysis)
        
        # Generate code for each basic block (recursive DFS)
        self._generate_evm_for_basicblock_r(asm, fn.entry, StackModel(), {})
```

### Per-Instruction Emission

**6-Step Process** (lines 528-783):

```python
def _generate_evm_for_instruction(self, inst, stack, next_liveness, spilled):
    # Step 1: Special stack manipulations (phi, invoke, ret)
    # Step 2: Emit input operands (PUSH literals, DUP variables)
    # Step 3: Reorder stack for join points (jmp to multi-pred BB)
    # Step 4: Pop operands, push outputs (update stack model)
    # Step 5: Emit EVM instruction(s)
    # Step 6: Pop dead outputs
```

### One-to-One Instructions

**Lines 36-120**: Direct EVM opcode mapping.

```python
_ONE_TO_ONE_INSTRUCTIONS = frozenset([
    "revert", "coinbase", "calldatasize", ...,
    "add", "sub", "mul", "div", ...,
    "sha3", "return", "log0", "log1", ...,
])
```

### Phi Node Handling

**Lines 560-576**:
```python
if opcode == "phi":
    # Find the phi operand that's on the stack
    depth = stack.get_phi_depth(phis)
    # Rename it to the phi output (virtual replacement)
    stack.poke(depth, phi_output)
```

### Invoke/Ret Handling

**Lines 729-739**:
```python
elif opcode == "invoke":
    # Push return label, push target, JUMP
    return_label = self.mklabel("return_label")
    assembly.extend([
        PUSHLABEL(return_label),
        PUSHLABEL(target),
        "JUMP",
        return_label
    ])

elif opcode == "ret":
    assembly.append("JUMP")  # Jump to return PC on stack
```

---

## Stack Management

### StackModel

**File**: [`stack_model.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/stack_model.py)

```python
class StackModel:
    NOT_IN_STACK = object()  # Sentinel for missing operands
    _stack: list[IROperand]  # Stack state, index 0 = bottom
    
    push(op)              # Append to top
    pop(num=1)            # Remove from top
    get_depth(op) -> int  # Negative offset from top, 0 = top
    peek(depth) -> op     # Get operand at depth
    poke(depth, op)       # Replace operand at depth
    dup(depth)            # Duplicate operand to top
    swap(depth)           # Swap with top
```

**Depth Convention**: 0 = top, -1 = one below top, etc.

### StackSpiller

**File**: [`stack_spiller.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/stack_spiller.py)

**Purpose**: Handle stacks deeper than EVM's DUP16/SWAP16 limit.

```python
class StackSpiller:
    def swap(self, assembly, stack, depth) -> cost:
        if -depth <= 16:
            stack.swap(depth)
            assembly.append(f"SWAP{-depth}")
        else:
            # Spill segment to memory, restore in swapped order
            self._spill_stack_segment(...)
            self._restore_spilled_segment(...)
    
    def dup(self, assembly, stack, depth) -> cost:
        # Similar memory-based approach for deep dups
```

**Memory Allocation**: Uses `fn_eom` (end of memory) from MemoryAllocator for spill slots.

---

## Memory Allocation

### MemoryAllocator

**File**: [`memory_allocator.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/memory_allocator.py)

```python
class MemoryAllocator:
    allocated: dict[Allocation, int]     # alloca → memory offset
    mems_used: dict[IRFunction, OrderedSet[Allocation]]
    fn_eom: dict[IRFunction, int]        # End of memory per function
    
    FN_START = 0  # Memory starts at offset 0
    
    allocate(alloca) -> int              # Assign memory offset
    get_concrete(ptr) -> IRLiteral       # Resolve to concrete offset
    reserve(alloca)                      # Mark as reserved
```

### Allocation Instructions

- **alloca**: Local variable allocation
- **palloca**: Parameter passed via memory (with alloca_id)
- **calloca**: Caller-allocated for call returns

---

## Effects System

### File: [`effects.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/effects.py)

**Purpose**: Track side effects for instruction ordering.

```python
class Effects(Flag):
    STORAGE   = auto()
    TRANSIENT = auto()
    MEMORY    = auto()
    MSIZE     = auto()
    IMMUTABLES = auto()
    RETURNDATA = auto()
    LOG       = auto()
    BALANCE   = auto()
    EXTCODE   = auto()

# Read effects
reads = {
    "sload": STORAGE,
    "mload": MEMORY,
    "call": ALL,  # Calls can read anything
    ...
}

# Write effects
writes = {
    "sstore": STORAGE,
    "mstore": MEMORY,
    "invoke": ALL,  # Invokes conservatively marked as ALL
    ...
}
```

**Usage in DFTPass**: Prevents reordering across effect boundaries.

---

## Calling Convention

### File: [`check_venom.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/check_venom.py)

### Invariants Enforced

```python
# 1. Consistent return arity within function
# All 'ret' instructions must return same number of values

# 2. Invoke output count matches callee return count
# output_count = len(inst.get_outputs())
# expected = callee's ret arity

# 3. Multi-output only for invoke
# Other instructions can only have 0 or 1 output
```

### invoke/ret Stack Protocol

```
BEFORE invoke:      AFTER ret:
┌─────────────┐     ┌─────────────┐
│  arg_n      │     │  ret_val_n  │
│  ...        │     │  ...        │
│  arg_1      │     │  ret_val_1  │
│  return_pc  │     │  (consumed) │
└─────────────┘     └─────────────┘
```

**ret** operands: Return values followed by return PC as LAST operand.

---

## Critical Gotchas for Yul2Venom

### 1. Operand Reversal in Parser

> **Problem**: Parser reverses operands for all non-control-flow instructions.
>
> **Solution**: Generate IR in human-readable order. Parser handles reversal.

```python
# In venom_generator.py, emit:
add %a, %b          # Human-readable: a + b
# Parser reverses to:
# operands = [%b, %a]  # Internal format
# Assembly order: PUSH %a, PUSH %b, ADD → result = a + b ✓
```

### 2. Phi Nodes Must Be At Block Start

```python
# BasicBlock.ensure_well_formed() enforces this
# ALWAYS insert phis before any other instructions
```

### 3. Single-Use Variable Invariant

The `SingleUseExpansion` pass runs near the end of the pipeline and:
- Extracts all literals to assign instructions
- Duplicates multi-used variables with assigns

**For Yul2Venom**: Don't worry about this during generation; the pass handles it.

### 4. CFG Normalization Requirement

venom_to_assembly requires normalized CFG. The `CFGNormalization` pass fixes this, but malformed CFGs can cause issues.

### 5. Native Vyper Uses Single `__main_entry` Function

Native Vyper uses memory-based parameter passing with aggressive inlining. Yul2Venom uses stack-based invoke/ret which is less tested in the backend.

### 6. Stack Reordering at Join Points

When jumping to a BB with multiple predecessors, the stack must be arranged consistently. The `_stack_reorder` function handles this at `jmp` instructions.

### 7. ret Convention: PC is LAST Operand

```python
# venom_to_assembly.py line 552-556
if opcode == "ret":
    # Return values must remain on stack, PC consumed by JUMP
    operands = [inst.operands[-1]]  # Only PC as input operand
```

---

## Pass Pipeline Reference

### O2 Optimization Pipeline

**File**: [`optimization_levels/O2.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/optimization_levels/O2.py)

```python
PASSES_O2 = [
    # Foundation
    FixMemLocationsPass,
    FloatAllocas,
    SimplifyCFGPass,
    
    # SSA conversion
    MakeSSA,
    PhiEliminationPass,
    
    # Optimization loop
    AlgebraicOptimizationPass,
    SCCP,
    SimplifyCFGPass,
    AssignElimination,
    Mem2Var,
    
    # Second SSA pass
    MakeSSA,
    PhiEliminationPass,
    SCCP,
    SimplifyCFGPass,
    AssignElimination,
    
    # Further optimization
    AlgebraicOptimizationPass,
    LoadElimination,
    PhiEliminationPass,
    AssignElimination,
    SCCP,
    AssignElimination,
    RevertToAssert,
    SimplifyCFGPass,
    
    # Memory optimization
    MemMergePass,
    LowerDloadPass,
    RemoveUnusedVariablesPass,
    DeadStoreElimination (MEMORY),
    DeadStoreElimination (STORAGE),
    DeadStoreElimination (TRANSIENT),
    
    # Cleanup
    AssignElimination,
    RemoveUnusedVariablesPass,
    ConcretizeMemLocPass,
    SCCP,
    SimplifyCFGPass,
    MemMergePass,
    RemoveUnusedVariablesPass,
    BranchOptimizationPass,
    AlgebraicOptimizationPass,
    AssertCombinerPass,
    
    # Final preparation
    RemoveUnusedVariablesPass,
    PhiEliminationPass,
    AssignElimination,
    CSE,
    AssignElimination,
    RemoveUnusedVariablesPass,
    
    # ⚠️ CRITICAL: Must run last before emission
    SingleUseExpansion,   # Prepare for venom_to_assembly
    DFTPass,              # Reorder for stack efficiency
    CFGNormalization,     # Final CFG normalization
]
```

### Global Passes (Run Before Per-Function)

```python
# From __init__.py
FixCalloca(ir_analyses, ctx).run_pass()
FunctionInlinerPass(ir_analyses, ctx, flags).run_pass()  # If enabled
```

---

## File Index

| File | Purpose |
|------|---------|
| `basicblock.py` | Core IR types (IROperand, IRInstruction, IRBasicBlock) |
| `context.py` | IRContext - top-level container |
| `function.py` | IRFunction - function with basic blocks |
| `parser.py` | Parse text IR, **operand reversal** |
| `venom_to_assembly.py` | Emit EVM assembly |
| `stack_model.py` | Track stack state during emission |
| `stack_spiller.py` | Handle deep stacks (>16) |
| `memory_allocator.py` | Memory offset allocation |
| `effects.py` | Side effect tracking |
| `check_venom.py` | Invariant validation |
| `passes/__init__.py` | All pass exports |
| `passes/base_pass.py` | IRPass base class |
| `passes/make_ssa.py` | SSA conversion |
| `passes/mem2var.py` | Memory-to-variable promotion |
| `passes/phi_elimination.py` | Redundant phi removal |
| `passes/sccp/sccp.py` | Constant propagation |
| `passes/dft.py` | Instruction reordering |
| `passes/single_use_expansion.py` | Prepare for emission |
| `passes/cfg_normalization.py` | CFG normalization |
| `passes/simplify_cfg.py` | CFG simplification |
| `analysis/cfg.py` | CFG analysis |
| `analysis/liveness.py` | Liveness analysis |
| `analysis/dfg.py` | Data flow graph |
| `analysis/dominators.py` | Dominator tree |

---

## Extended Optimization Passes

### AlgebraicOptimization Pass

**File**: [`passes/algebraic_optimization.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/passes/algebraic_optimization.py)

**Purpose**: Reduce algebraically evaluatable expressions.

**Key Optimizations**:
- **iszero chains**: Collapse `iszero(iszero(x))` to `x` when appropriate
- **Binary operations**: Simplify `add 0, x`, `mul 1, x`, `and -1, x`, etc.
- **Offset adds**: Combine `add(ptr, 32)` and `add(ptr+32, 64)` into single offset
- **Signextend elimination**: Remove `signextend` when range analysis proves it's unnecessary

```python
# Uses VariableRangeAnalysis for range-based optimizations
if self._var_ranges.can_eliminate_signextend(inst):
    inst.opcode = "assign"
```

### Common Subexpression Elimination (CSE)

**File**: [`passes/common_subexpression_elimination.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/passes/common_subexpression_elimination.py)

**Purpose**: Replace redundant computations with previous results.

**Limitations**:
- Does NOT support multi-output instructions
- Uses expression depth heuristic to avoid bloat

```python
# Relies on AvailableExpressionAnalysis
if available_expr := self.avail_exprs.get(inst):
    inst.opcode = "assign"
    inst.operands = [available_expr.output]
```

### Load Elimination Pass

**File**: [`passes/load_elimination.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/passes/load_elimination.py)

**Purpose**: Eliminate redundant memory/storage loads.

**Targets**: `sload`, `mload`, `tload`

```python
# Uses LoadAnalysis to track memory states
class LoadAnalysis:
    _abstract_stores: dict  # Track what each location contains
    
    def get_available_load(self, inst) -> Optional[IRVariable]:
        # Returns already-computed value if available
```

### Dead Store Elimination

**File**: [`passes/dead_store_elimination.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/passes/dead_store_elimination.py)

**Purpose**: Remove stores whose values are never read.

**Uses Memory SSA** to track memory state chains:

```python
# Check if store is ever used
for use in mem_ssa.get_uses(mem_def):
    if use.is_volatile:
        return False  # Cannot eliminate
return True  # Safe to eliminate
```

### Branch Optimization Pass

**File**: [`passes/branch_optimization.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/passes/branch_optimization.py)

**Purpose**: Optimize conditional branches.

**Key Heuristics**:
- Invert `jnz` conditions when it reduces liveness costs
- Eliminate `iszero` in conditions when labels can be swapped

```python
# Cost-based branch inversion
if invert_cost < normal_cost:
    # Swap labels and add iszero
    jnz.operands = [iszero(cond), false_label, true_label]
```

### Assign Elimination Pass

**File**: [`passes/assign_elimination.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/passes/assign_elimination.py)

**Purpose**: Forward variables through assign chains and remove redundant assigns.

```python
# %y = %x; use(%y) → use(%x)
# But only if %y has single use
```

### Remove Unused Variables Pass

**File**: [`passes/remove_unused_variables.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/passes/remove_unused_variables.py)

**Purpose**: Remove instructions whose outputs are never used.

**Special Cases**:
- `msize`: Must preserve instruction order relative to msize
- Multi-output instructions (invoke): Only remove if ALL outputs unused

---

## Function Inlining

### FunctionInlinerPass

**File**: [`passes/function_inliner.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/passes/function_inliner.py)

**Purpose**: Inline function bodies at call sites to reduce call overhead.

**Selection Criteria**:
1. **Always inline** if single call site
2. **Inline if** `code_size_cost <= inline_threshold` (configurable flag)

**Inline Process**:
```python
def _inline_call_site(self, func, call_site):
    # 1. Clone function with prefix (e.g., "inl0_")
    # 2. Replace param instructions with actual arguments
    # 3. Replace ret with jmp to return block
    # 4. Map return values to call site outputs
    # 5. Fix phi references
```

**alloca/palloca/calloca Handling**:
- **calloca** at call site matches **palloca** in callee
- After inlining, callocas demoted to regular allocas
- Memory layout preserved through ID matching

```python
# Match callocas to pallocas by ID
if alloca_id in callocas:
    inst.opcode = "assign"
    inst.operands = [calloca_inst.output]
```

### FloatAllocas Pass

**File**: [`passes/float_allocas.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/passes/float_allocas.py)

**Purpose**: Move all allocas to entry block (required for SCCP).

```python
# All alloca/palloca/calloca instructions
# moved to function entry before terminator
```

---

## Memory Optimization

### MemMergePass

**File**: [`passes/memmerging.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/passes/memmerging.py)

**Purpose**: Fuse multiple memory operations into bulk copies.

**Patterns Merged**:
- `mload + mstore` → `mcopy` (Cancun+)
- `calldataload + mstore` → `calldatacopy`
- `dload + mstore` → `dloadbytes`
- Multiple `mstore 0` → `calldatacopy(calldatasize())`

**Hazard Detection**:
```python
# Read-After-Write: src may be overwritten before copy
# Write-After-Write: dst may be overwritten
# Write-After-Read: new copy may overwrite pending read
```

### LowerDloadPass

**File**: [`passes/lower_dload.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/passes/lower_dload.py)

**Purpose**: Lower `dload`/`dloadbytes` pseudo-instructions to `codecopy`.

```python
# dload %ptr → 
#   alloca 32
#   %addr = add %ptr, @code_end
#   codecopy 32, %addr, alloca
#   mload alloca
```

### FixMemLocationsPass

**File**: [`passes/fix_mem_locations.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/passes/fix_mem_locations.py)

**Purpose**: Replace literal FREE_VAR_SPACE accesses with pinned allocations.

```python
# If writing to FREE_VAR_SPACE (magic offset):
#   Create alloca pinned to that offset
#   Replace literal with alloca + gep
```

---

## Instruction Categories

### From basicblock.py

```python
# Block Terminators
BB_TERMINATORS = frozenset([
    "jmp", "djmp", "jnz",         # Branches
    "ret", "return", "revert",    # Function/message returns
    "stop", "sink"                # Halt execution
])

# Halting Terminators (no successor blocks)
HALTING_TERMINATORS = frozenset([
    "return", "revert", "stop", "invalid"
])

# Volatile Instructions (cannot be eliminated/reordered freely)
VOLATILE_INSTRUCTIONS = frozenset([
    "param", "invoke", "ret",
    "call", "staticcall", "delegatecall", "create", "create2",
    "sstore", "tstore", "mstore", "istore",
    "calldatacopy", "mcopy", "extcodecopy", "returndatacopy", "codecopy",
    "return", "sink", "jmp", "jnz", "djmp",
    "log", "selfdestruct", "invalid", "revert",
    "assert", "assert_unreachable", "stop"
])

# Instructions with no output
NO_OUTPUT_INSTRUCTIONS = frozenset([
    "mstore", "sstore", "istore", "tstore",
    # ... copies, terminators, logs
])

# Commutative (operands can be swapped)
COMMUTATIVE_INSTRUCTIONS = frozenset([
    "add", "mul", "smul", "or", "xor", "and", "eq"
])

# Comparators (can flip with opcode change)
COMPARATOR_INSTRUCTIONS = ("gt", "lt", "sgt", "slt")
```

### CFG-Altering Instructions

```python
CFG_ALTERING_INSTRUCTIONS = frozenset(["jmp", "djmp", "jnz"])
```

---

## Native IR Conversion (ir_node_to_venom.py)

### File: [`ir_node_to_venom.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/ir_node_to_venom.py)

**Purpose**: Convert Vyper's internal IRnode representation to Venom IR.

### Key Patterns

**Inverse Mapped Instructions**:
```python
INVERSE_MAPPED_IR_INSTRUCTIONS = {
    "ne": "eq",    # ne(a,b) → iszero(eq(a,b))
    "le": "gt",    # le(a,b) → iszero(gt(a,b))
    "sle": "sgt",
    "ge": "lt",
    "sge": "slt"
}
```

**Pass-Through Instructions**: Direct EVM opcode equivalents (100+ opcodes).

**Control Flow**:
```python
# if/else → jnz with then/else blocks
# repeat → loop with cond/body/incr/exit blocks
# break/continue → jmp to exit/incr blocks
```

**Self-Call Handling** (internal function calls):
```python
def _handle_self_call(fn, ir, symbols):
    # 1. Convert arguments
    # 2. Create return buffer if multi-return
    # 3. Load stack args from callocas
    # 4. Emit invoke
    # 5. Store return values to buffer
```

**Internal Function Handling**:
```python
def _handle_internal_func(fn, ir, does_return_data, symbols):
    # 1. Create new IRFunction
    # 2. Setup immutables region alloca (if present)
    # 3. Process param instructions for each argument
    # 4. Add return_pc as final param
    # 5. Convert function body
```

---

## Analysis Framework Extended

### Memory SSA (MemSSAAbstract)

**File**: [`analysis/mem_ssa.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/analysis/mem_ssa.py)

**Purpose**: Track memory state through Memory SSA form (based on LLVM MemorySSA).

**Key Classes**:
```python
class MemoryAccess:       # Base
class MemoryDef:          # Store instruction
class MemoryUse:          # Load instruction  
class MemoryPhi:          # Memory merge point
class LiveOnEntry:        # Memory state at function entry
```

**Volatility**: Memory locations can be marked volatile if they may be accessed through side effects (calls).

### Base Pointer Analysis

**File**: [`analysis/base_ptr_analysis.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/analysis/base_ptr_analysis.py)

**Purpose**: Track base allocations for all pointers.

```python
class Ptr:
    base_alloca: Allocation
    offset: int | None  # None = unknown offset

class BasePtrAnalysis:
    # Tracks: alloca → Ptr, gep → offset into Ptr
    # Handles: memory reads/writes, storage, calldata, etc.
```

### Function Call Graph (FCGAnalysis)

**File**: [`analysis/fcg.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/analysis/fcg.py)

**Purpose**: Build call graph from invoke instructions.

```python
class FCGAnalysis:
    call_sites: dict[IRFunction, OrderedSet[IRInstruction]]  # Callers
    callees: dict[IRFunction, OrderedSet[IRFunction]]        # Called functions
    
    get_reachable_functions()    # All reachable from entry
    get_unreachable_functions()  # Dead code
```

### Reachable Analysis

**File**: [`analysis/reachable.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/analysis/reachable.py)

**Purpose**: Compute transitive reachability in CFG.

```python
class ReachableAnalysis:
    reachable: dict[BB, OrderedSet[BB]]  # All BBs reachable from key
```

---

## InstUpdater Utility

**File**: [`passes/machinery/inst_updater.py`](file:///Users/gleb/Developer/onchain-trader/yul2venom/vyper/vyper/venom/passes/machinery/inst_updater.py)

**Purpose**: Safe instruction modification with DFG maintenance.

```python
class InstUpdater:
    def update(inst, new_opcode, new_operands):
        # Updates instruction and DFG in-place
    
    def nop(inst):
        # Convert to nop, remove from DFG
    
    def add_before(inst, opcode, operands) -> IRVariable:
        # Insert new instruction before inst
    
    def move_uses(old_var, new_inst):
        # Redirect all uses of old_var to new_inst.output
```

---

## Quick Reference for Common Operations

### Adding a New Instruction

1. Add to `_ONE_TO_ONE_INSTRUCTIONS` in venom_to_assembly.py if direct EVM op
2. Or add special handling in `_generate_evm_for_instruction`
3. Add read/write effects in `effects.py` if needed

### Debugging Stack Issues

1. Enable `DEBUG_SHOW_COST = True` in venom_to_assembly.py
2. Check `_stack_reorder` for failed operand lookups
3. Verify liveness analysis is correct

### Trace Optimization Pipeline

```python
# Add print statements in __init__.py:_run_passes
for pass_config in passes:
    print(f"Running {pass_cls.__name__}")
    pass_instance.run_pass(**kwargs)
    print(fn)  # Print IR after each pass
```

---

## File Index Extended

| File | Purpose |
|------|---------|
| `ir_node_to_venom.py` | Convert native Vyper IR to Venom |
| `passes/function_inliner.py` | Inline functions at call sites |
| `passes/float_allocas.py` | Move allocas to entry block |
| `passes/memmerging.py` | Fuse memory operations |
| `passes/lower_dload.py` | Lower dload to codecopy |
| `passes/fix_mem_locations.py` | Handle FREE_VAR_SPACE |
| `passes/algebraic_optimization.py` | Algebraic simplifications |
| `passes/common_subexpression_elimination.py` | CSE |
| `passes/load_elimination.py` | Eliminate redundant loads |
| `passes/dead_store_elimination.py` | Eliminate dead stores |
| `passes/branch_optimization.py` | Optimize branches |
| `passes/assign_elimination.py` | Forward through assigns |
| `passes/remove_unused_variables.py` | DCE |
| `analysis/mem_ssa.py` | Memory SSA form |
| `analysis/base_ptr_analysis.py` | Pointer tracking |
| `analysis/fcg.py` | Function call graph |
| `analysis/reachable.py` | CFG reachability |
| `analysis/available_expression.py` | Available expressions for CSE |
| `analysis/variable_range/value_range.py` | Value range analysis |
| `passes/machinery/inst_updater.py` | Safe instruction updates |
