# Venom IR Research: Native Vyper Patterns

> **Generated**: 2026-01-28  
> **Vyper Version**: 0.4.3+commit.bff19ea2  
> **Source Files**: `tests/vyper_comprehensive.vy`, `tests/vyper_loop_test.vy`

This document captures research findings from analyzing native Vyper-generated Venom IR to understand patterns for improving the Yul2Venom transpiler.

---

## How to Generate Native Venom IR

Use the globally-installed Vyper (via pipx), **NOT** the local fork:

```bash
# Using vyper_ir_helper.py
cd yul2venom
python3.11 vyper_ir_helper.py tests/contract.vy --venom -o output

# Direct command (runtime code)
pipx run vyper tests/contract.vy -f bb_runtime --experimental-codegen

# Direct command (deploy code)
pipx run vyper tests/contract.vy -f bb --experimental-codegen
```

**Output Files**:
- `output/<name>_venom_runtime.vnm` - Runtime bytecode IR
- `output/<name>_venom_deploy.vnm` - Deploy/init code IR

---

## Key IR Instruction Patterns

### 1. Function Entry (`__main_entry`)

Native Vyper uses a **single function** `__main_entry` that contains all external function dispatch:

```
function __main_entry {
  __main_entry:  ; OUT=[selector_bucket_0, selector_bucket_1, fallback]
      %1 = calldataload 0
      %2 = shr 224, %1
      ; ... selector bucket lookup via djmp
}
```

**Key Difference from Yul2Venom**: We use separate `function external_fun_X` but Vyper inlines everything into `__main_entry`.

### 2. Selector Dispatch (`djmp` - Dynamic Jump)

Vyper uses a **hash bucket** approach with `djmp`:

```
%4 = mod %2, 20              ; Hash selector into 20 buckets
%5 = shl 1, %4               ; Multiply by 2 (label size)
%6 = add @selector_buckets, %5
codecopy 30, %6, 2           ; Load bucket address
%7 = mload 0
djmp %7, @selector_bucket_0, @selector_bucket_1, ..., @fallback
```

**Data Section** stores bucket labels:
```
data readonly {
  dbsection selector_buckets:
    db @selector_bucket_0
    db @selector_bucket_1
    db @fallback
}
```

**Difference**: Yul2Venom uses linear `eq`/`jnz` chain for selector matching.

### 3. Loop Pattern with Phi Nodes

Loops follow a strict CFG pattern with phi nodes at the loop condition:

```
5_condition:  ; OUT=[6_body, 8_exit]
    %alloca_4_14_0:1 = phi @2_then, %alloca_4_14_0, @6_body, %alloca_4_14_0:2
    %21:1:1 = phi @2_then, %21, @6_body, %21:2
    %25 = xor %16, %21:1:1
    jnz %25, @6_body, @8_exit

6_body:  ; OUT=[5_condition]
    ; ... loop body
    %alloca_4_14_0:2 = %32           ; Update accumulator
    %21:2 = add 1, %21:1:1           ; Increment counter
    jmp @5_condition
```

**Phi Node Format**: `%var:version = phi @label1, %val1, @label2, %val2`
- SSA version suffix: `:1`, `:2`, `:1:1`
- First pair: entry block + initial value
- Second pair: back-edge + loop-modified value

### 3. Loop Pattern with Phi Nodes

Loops follow a strict CFG pattern with phi nodes at the loop condition:

```
5_condition:  ; OUT=[6_body, 8_exit]
    %alloca_4_14_0:1 = phi @2_then, %alloca_4_14_0, @6_body, %alloca_4_14_0:2
    %21:1:1 = phi @2_then, %21, @6_body, %21:2
    %25 = xor %16, %21:1:1
    jnz %25, @6_body, @8_exit

6_body:  ; OUT=[5_condition]
    ; ... loop body
    %alloca_4_14_0:2 = %32           ; Update accumulator
    %21:2 = add 1, %21:1:1           ; Increment counter
    jmp @5_condition
```

**Phi Node Format**: `%var:version = phi @label1, %val1, @label2, %val2`
- First pair: entry block + initial value
- Second pair: back-edge + loop-modified value

**Why Use Phis?**
- Eliminates memory overhead (`mload`/`mstore`)
- Enables backend optimizations (DCE, Constant Folding)
- "Venom-native" representation of variable state changes
- Essential for gas efficiency in loops

### 4. SSA Variable Naming

Vyper's SSA versioning uses colons:
- `%21` - Base variable
- `%21:1` - First redefinition
- `%21:1:1` - Further versioning in nested scopes
- `%alloca_4_14_0` - Allocas for local variables (prefix with source info)

### 5. Immutable Storage (`istore`/`iload`)

Deploy code uses `istore` to write immutables:

```
%5 = mload 0              ; Load constructor arg from calldata
istore 0, %5              ; Store to immutable slot 0 (MULTIPLIER)
%6 = caller
istore 32, %6             ; Store to immutable slot 32 (OWNER)
```

Runtime code uses `offset @code_end` to read immutables:

```
%439 = offset @code_end, 0     ; MULTIPLIER is at offset 0
codecopy 0, %439, 32
%343 = mload 0
```

**Key Insight**: Immutables are stored AFTER the runtime code and accessed via `codecopy`.

### 6. Storage Operations

Direct sload/sstore with slot numbers:

```
%41 = sload 0                    ; Load slot 0 (counter)
%43 = add 1, %41
sstore 0, %43                    ; Store back

; Mapping access using sha3_64
%238 = sha3_64 2, %226           ; keccak256(slot, key) for users mapping
sstore %238, %242                ; Store balance
```

**sha3_64**: Special instruction for 64-byte keccak (slot + key for mappings).

### 7. Assert Instruction

Used for require-like checks:

```
%13 = iszero %12
assert %13                       ; Reverts if false
```

No explicit revert - `assert` handles it.

### 8. Internal Function Inlining

Internal functions are INLINED with comments:

```
%inl0_7 = shl 1, %175           ; from "internal 4 _double(uint256)_runtime"
%inl0_9 = shr 1, %inl0_7        ; from "internal 4 _double(uint256)_runtime"
```

**No `invoke`** - internal functions are fully inlined during IR generation.

### 9. Event Logging

```
mstore 64, %210                  ; Store indexed param
mstore 96, %205                  ; Store data
%644 = 0x23..81                  ; Topic (keccak of event signature)
log 64, 64, %644, 1              ; log(offset, size, topic0, topic_count)
stop
```

**Log Format**: `log offset, size, topic0, topic_count`

### 10. Return Pattern

```
mstore 64, %result
return 64, 32
```

Always `mstore` result, then `return offset, size`.

### 11. Branching (if/else chains)

```
76_then:  ; OUT=[89_if_exit]
    %alloca_25_309_19:8 = 1
    jmp @89_if_exit

77_else:  ; OUT=[79_else, 78_then]
    %314 = calldataload 4
    %315 = lt 19, %314
    jnz %315, @79_else, @78_then
```

Multiple phi nodes at merge points:

```
89_if_exit:  ; OUT=[]
    %alloca_25_309_19:1 = phi @76_then, %alloca_25_309_19:8, @88_if_exit, %alloca_25_309_19:2
```

---

## Comparison: Native Vyper vs Yul2Venom

| Feature | Native Vyper | Yul2Venom |
|---------|-------------|-------------|
| Function organization | Single `__main_entry` | Separate `function external_fun_X` |
| Selector dispatch | `djmp` with buckets | Linear `eq`/`jnz` chain |
| Internal calls | Inlined | `invoke @func` |
| Loop handling | Phi nodes in condition block | Memory-backed (0x300+) |
| If-statement SSA | Phi nodes at merge | Memory-backed (0x400+) |
| Immutables | `istore`/`offset @code_end` | Not fully supported |
| Assertions | `assert` | `jnz` + `revert` |

---

## Recommendations for Yul2Venom

### High Priority

1. **Use `assert` instruction** instead of manual `jnz`/`revert` patterns
2. **Emit inlined internal functions** rather than `invoke` - matches native pattern
3. **Implement `sha3_64`** for mapping access (more efficient than raw `sha3`)

### Medium Priority

4. Consider `djmp` for selector dispatch (better performance for many functions)
5. Explore true phi nodes vs memory-backing for SSA (Vyper's `mem2var` pass handles this)

### Low Priority (Native Compatibility)

6. Merge all externals into single `__main_entry` function
6. Merge all externals into single `__main_entry` function
7. Add `data readonly` sections for constants

### 12. Struct Array Handling (Native)

Native Vyper handles `DynArray[Struct]` by copying contiguous memory blocks, not pointers:

```venom
%32 = shl 6, %index      ; size 64 (2 words)
%33 = add %base, %32     ; offset
mcopy %dest, %33, 64     ; Copy full struct size
```

This contradicts Yul2Venom's "Array of Pointers" model derived from Yul.
However, since Yul2Venom follows Yul, the "Array of Pointers" approach should work if consistent. Note that Solidity uses pointers for memory arrays of structs, while Vyper (native) uses contiguous layout.

### 13. Aggressive Inlining

Native Vyper inlines **all** external functions into `__main_entry`. There are no `invoke` instructions for `processStructs` or `mapElements`.


---

## Example: Sum Loop in Native Venom IR

```vyper
@external
def sum_to_n(n: uint256) -> uint256:
    total: uint256 = 0
    for i in range(n, bound=50):
        total += i
    return total
```

**Generated IR**:

```
2_then:  ; Entry
    %alloca_4_14_0 = 0           ; total = 0
    %21 = 0                       ; i = 0
    jmp @5_condition

5_condition:  ; Loop test
    %alloca_4_14_0:1 = phi @2_then, %alloca_4_14_0, @6_body, %alloca_4_14_0:2
    %21:1:1 = phi @2_then, %21, @6_body, %21:2
    %25 = xor %16, %21:1:1        ; i != n
    jnz %25, @6_body, @8_exit

6_body:  ; Loop body
    %32 = add %alloca_4_14_0:1, %21:1:1   ; total += i
    assert ...                             ; Overflow check
    %alloca_4_14_0:2 = %32
    %21:2 = add 1, %21:1:1                 ; i++
    jmp @5_condition

8_exit:  ; Return
    mstore 64, %alloca_4_14_0:1
    return 64, 32
```

---

## Files Generated

| File | Content |
|------|---------|
| `output/vyper_loop_test_venom_runtime.vnm` | Loop patterns (247 lines) |
| `output/vyper_loop_test_venom_deploy.vnm` | Minimal (no constructor) |
| `output/vyper_comprehensive_venom_runtime.vnm` | Full patterns (994 lines) |
| `output/vyper_comprehensive_venom_deploy.vnm` | Constructor with immutables |

---

## Session 1 Findings: Alloca/Mem2Var Interaction

### Experiment

Attempted to replace fixed-address `mstore 0x400, %val` with `alloca`-based pattern:

```venom
%slot = alloca 32
mstore %slot, %val
jnz %cond, @then, @else
; ...
%result = mload %slot
```

### Result: Mem2Var Conversion Fails

When alloca is in the **same block** as a branching `jnz`, Mem2Var produces incorrect phi:

```
; After Mem2Var + MakeSSA:
16_end_if:
    %alloca_8_0:2 = %8      ; ← %8 is the POINTER, not the value!
```

The false-branch edge passes the alloca pointer through the stack instead of the stored value.

### Root Cause

Mem2Var's `_process_alloca_var` expects:
1. Alloca output used ONLY by mstore/mload
2. All uses are dominated by the alloca

When alloca + mstore + jnz are in the same block, the CFG edges don't carry the stored value - they carry the alloca pointer.

### Native Vyper Avoids This

Native Vyper frontend emits **direct register assignments**, not alloca for SSA locals:

```venom
entry:
    %alloca_X = 0          ; Direct assignment, not alloca instruction
    jnz %cond, @then, @else

then:
    %alloca_X:2 = ...      ; Another assignment to same name
    jmp @join

join:
    %alloca_X:1 = phi @entry, %alloca_X, @then, %alloca_X:2
```

The naming convention `%alloca_X` is just a variable name - NOT an `alloca` instruction.

### Implication for Yul2Venom

To achieve native-like IR, we need either:
1. **Emit direct register assignments** (like Vyper frontend)
2. **Move alloca to function entry** with explicit initialization

Both require restructuring how we handle SSA across control flow.

---

## Session 2 Findings: Deep Dive into Native Calling Convention (2026-01-28)

### Source: `ir_node_to_venom.py`

#### Function Entry (`_handle_internal_func`, line 316-406)

```python
# Arguments captured in FORWARD order
for arg in func_t.arguments:
    if not _pass_via_stack(func_t)[arg.name]:
        continue
    param = bb.append_instruction("param")
    # ... register param ...

# Return PC is captured LAST (TOP of runtime stack at entry)
return_pc = bb.append_instruction("param")
symbols["return_pc"] = return_pc
```

**Key Insight**: Runtime stack at function entry is `[...args, return_pc]` with `return_pc` on TOP.
`param` instructions pop from TOP, so the ORDER of param emissions matters:
- If we emit params in FORWARD order, first param gets deepest value
- Last param (`return_pc`) gets the TOP (return address)

#### Function Call (`_handle_self_call`, line 227-287)

```python
# Target label is FIRST in stack_args
stack_args: list[IROperand] = [IRLabel(str(target_label))]

# Then args are appended
for alloca in callsite_args:
    stack_arg = bb.append_instruction("mload", ptr)
    stack_args.append(stack_arg)

# Uses proper API (NOT append_instruction!)
if returns_count > 0:
    outs = bb.append_invoke_instruction(stack_args, returns=returns_count)
else:
    bb.append_invoke_instruction(stack_args, returns=0)
```

**Key Insight**: Native Vyper uses `append_invoke_instruction()` method, which:
1. Creates properly structured `IRInstruction("invoke", ...)`
2. Handles output variables correctly
3. Ensures operands[0] is always the target IRLabel

### Comparison: Native Vyper vs Yul2Venom

| Aspect | Native Vyper | Yul2Venom |
|--------|-------------|-------------|
| Function structure | Single `__main_entry` with all externals inlined | Separate `function external_fun_X` |
| Internal calls | Fully inlined (no invoke) | Uses `invoke @func` |
| Selector dispatch | `djmp` with hash buckets | Linear `eq`/`jnz` chain |
| param order | Forward order, return_pc LAST | Forward order, return_pc LAST ✓ |
| invoke API | `append_invoke_instruction()` | `append_instruction("invoke", ...)` |
| Loop SSA | Phi nodes only | Phi nodes ✓ |
| Memory layout | Internal (no memoryguard) | memoryguard → 0x1000 |

### Critical Difference: invoke API

**Native Vyper** (`basicblock.py` line 582-603):
```python
def append_invoke_instruction(self, args, returns=0):
    outputs = [self.parent.get_next_variable() for _ in range(returns)]
    inst = IRInstruction("invoke", inst_args, outputs)
    ...
```

**Yul2Venom** (`venom_generator.py`):
```python
# Uses direct append_instruction - may differ in output handling!
self.current_bb.append_instruction("invoke", IRLabel(s_func), *args)
# OR
invoke_inst = IRInstruction("invoke", operands, outputs=ret_vars)
self.current_bb.instructions.append(invoke_inst)
```

The transpiler's direct instruction construction is functionally similar, but bypasses some validation/setup in `append_invoke_instruction`.

### Single Function Model

Native Vyper compiles ALL external functions into a SINGLE `__main_entry`:

```venom
function __main_entry {
  __main_entry:
      ; selector dispatch via djmp
      djmp %selector_hash, @bucket_0, @bucket_1, @fallback

  bucket_0:
      ; selector matching + external function body INLINED
      assert %selector == 0xABC...
      ; ... function logic directly here, no invoke ...

  bucket_1:
      ; another external function INLINED
      ...
}
```

**Yul2Venom** creates separate functions:
```venom
function global {
  global:
      ; selector dispatch via jnz chain
      jnz %match_0, @call_0, @try_1
  call_0:
      invoke @external_fun_test_sub  ; CALLS separate function
      ...
}

function external_fun_test_sub {
  ...
}
```

This structural difference is acceptable but creates additional `invoke`/`ret` pairs that the backend must handle.

### Validation Checks Now Enabled

`yul2venom.py` now runs before optimization:
```python
from vyper.venom.check_venom import check_calling_convention, check_venom_ctx

check_venom_ctx(ctx)         # All vars defined, BBs terminated
check_calling_convention(ctx) # ret/invoke arity matches
```

Both pass, confirming IR is structurally valid. The bug is in assembly generation.

---

## CRITICAL FINDING: Native Vyper Uses NO invoke/ret

When examining native Vyper IR (`vyper_loop_test_venom_runtime.vnm`):

```venom
function __main_entry {
  __main_entry:
      ; selector dispatch via djmp
      djmp %7, @selector_bucket_0, @selector_bucket_1, @fallback

  selector_bucket_0:
      ; external function body INLINED directly here
      assert %8                  ; No invoke!
      %alloca_2_27_0 = 0
      jmp @5_condition

  5_condition:
      %alloca_2_27_0:1 = phi @selector_bucket_0, %alloca_2_27_0, @6_body, %alloca_2_27_0:2
      ; ... loop body ...

  8_exit:
      mstore %151, %150
      return %153, %152          ; Direct return, no ret instruction!
}
```

**Native Vyper has:**
- **0 `invoke` instructions** - all internal functions are inlined
- **0 `ret` instructions** - flows end with `return`, `revert`, or `stop`
- **1 single function** (`__main_entry`) containing all code

**Our transpiler has:**
- **100+ `invoke` instructions** - for every ABI helper and external function
- **100+ `ret` instructions** - each function returns via stack
- **100+ separate functions** - one per Yul function

### Implication

The Venom backend's `invoke`/`ret` handling is less battle-tested since native Vyper doesn't use it for normal compilation. The transpiler is stress-testing a rarely-used code path.

### Sample Transpiler `ret` Pattern
```venom
function abi_decode_address {
  abi_decode_address:
      %1 = param        ; offset
      %2 = param        ; dataEnd
      %3 = param        ; return PC
      %4 = calldataload %1
      invoke @validator_revert_address, %4
      ret %4, %3        ; Return value + PC for JUMP
}
```

### Why This Matters

The `OutOfGas` error (infinite loop) suggests the `ret` instruction's PC operand (`%3`) is incorrect or the stack is misaligned when `JUMP` executes. Since native Vyper never generates this pattern, there may be bugs in the backend that have never been exercised.

### Potential Fixes

1. **Inline all ABI helpers** (like native Vyper does) - eliminates invoke/ret
2. **Debug `venom_to_assembly.py` invoke/ret handling** - fix stack tracking
3. **Verify param order matches invoke order** - ensure PC is correctly positioned

---

## Session 3: Deep Dive into S-Expression IR (`vyper_comprehensive.ir`)

### Key Discovery: Internal Functions ARE Defined (But Gets Inlined)

Looking at `vyper_comprehensive.ir` (lines 899-955), internal functions ARE separately defined in S-expression IR:

```lisp
[seq,
  [label,
    internal 4 _double(uint256)_runtime,
    [var_list, return_buffer, return_pc],   ; ← PARAMETERS
    [seq,
      [mstore, return_buffer, ...]          ; Store result in buffer
      [exit_to, internal 4 _double(uint256)_cleanup, return_pc]]], ; Return via label jump
  [label,
    internal 4 _double(uint256)_cleanup,
    [var_list, return_pc],
    [exit_to, return_pc]]]                  ; Jump to caller
```

**Key Observations:**
1. `return_buffer` - Memory location to write return values (NOT stack-based)
2. `return_pc` - Return address label (NOT an actual PC value)
3. `exit_to` - Vyper's "goto with cleanup" pattern
4. Result is written to memory via `mstore`, not passed on stack

### How Internal Calls Work (S-Expression)

```lisp
[mstore, 64, arg_value]           ; Store argument
[goto,
  internal 4 _double(uint256)_runtime,      ; Target label
  160 <return_buf>,                          ; Where to store result
  [symbol, internal 4 _double(uint256)_call1]], ; Return label
[label, internal 4 _double(uint256)_call1, var_list, pass],
160 <return_buf>]]                           ; Read result from memory
```

**Critical Pattern**: Native Vyper uses memory-based parameter passing:
1. Arguments are stored in memory at known offsets before `goto`
2. Return values are written to `return_buffer` in memory
3. Control returns via label jump, NOT stack manipulation
4. The return_pc is a **label symbol**, not an address on stack

### Inlining Detection

Looking at `vyper_comprehensive_venom_runtime.vnm`, internal functions ARE INLINED:

```venom
; From 46_then (call_internal function)
%inl0_7 = shl %601, %600       ; from "internal 4 _double(uint256)_runtime"
...
%inl1_11 = add %606, %605      ; from "internal 5 _add_with_mul..."
```

The `inl0_`, `inl1_` prefixes indicate inlined internal function code!

### Memory-Based Calling Convention (NOT Stack-Based)

Native Vyper's calling convention:
| Component | Mechanism |
|-----------|-----------|
| Arguments | `mstore` at fixed offsets (e.g., 64, 96) |
| Return PC | Label symbol, passed to `goto` |
| Return value | `mstore` to `return_buffer` |
| Control flow | `goto` + `exit_to` (label-based jumps) |

Our transpiler's calling convention:
| Component | Mechanism |
|-----------|-----------|
| Arguments | `invoke` operands (stack push) |
| Return PC | `param` (popped from EVM stack) |
| Return value | `ret` operands (pushed to stack) |
| Control flow | `invoke`/`ret` (EVM JUMP) |

**THIS IS THE FUNDAMENTAL DIFFERENCE!**

### `repeat` vs `for` Loop Translation

S-Expression IR uses `repeat`:
```lisp
[repeat,
  range_ix0,        ; Counter variable
  0,                ; Start value
  end,              ; End expression
  50,               ; Max iterations (bound)
  [seq, body...]]   ; Loop body
```

Venom IR translates to:
```venom
5_condition:
    %alloca:1 = phi @entry, %init, @body, %alloca:2
    %counter:1 = phi @entry, %start, @body, %counter:2
    %cond = xor %end, %counter:1
    jnz %cond, @body, @exit

body:
    ; ... body operations ...
    %counter:2 = add 1, %counter:1
    jmp @5_condition
```

### Selector Dispatch: `djmp` vs `jnz` Chain

Native Vyper uses hash buckets + `djmp`:
```venom
%4 = mod %selector, 20          ; mod by bucket count
%5 = shl 1, %4                  ; multiply by 2 (pointer size)
%6 = add @selector_buckets, %5  ; index into table
codecopy 30, %6, 2              ; read 2-byte pointer
%7 = mload 0                    ; load target address
djmp %7, @bucket_0, @bucket_1, ... @fallback
```

In the bucket, linear search within that bucket:
```venom
selector_bucket_2:
    %sel = xor 0x85fed016, %selector
    jnz %sel, @next_in_bucket, @handler
```

Our transpiler uses pure linear `jnz` chain:
```venom
    %6 = eq %5, 0x591d3ab
    jnz %6, @case_0, @switch_next_1
switch_next_1:
    %7 = eq %5, 0x1495fcf3
    jnz %7, @case_1, @switch_next_2
; ... repeated for every selector
```

**Performance difference**: O(1) average vs O(n) worst case

### Key Opcode Patterns

| Vyper S-Expr | Venom IR | Notes |
|--------------|----------|-------|
| `[add, x, y]` | `%r = add %x, %y` | Direct mapping |
| `[mstore, offset, val]` | `mstore %offset, %val` | Memory write |
| `[sload, slot]` | `%r = sload %slot` | Storage read |
| `[sha3_64, a, b]` | `%r = sha3_64 %a, %b` | Keccak256 of 2 words |
| `[dload, offset]` | `%r = dload %offset` | Immutable read (deploy code) |
| `[calldataload, off]` | `%r = calldataload %off` | Read calldata |
| `[exit_to, lbl, args]` | `jmp @label` + phi at target | Goto with values |
| `[assert, cond]` | `assert %cond` | Revert if false |
| `[repeat, ...]` | Phi nodes + jnz/jmp loop | Bounded loop |

### Return Patterns

Native Vyper external functions:
```venom
; Exit: store result and return from EVM
mstore %offset, %value
return %offset, %size
```

No `ret` instruction for external functions! They use EVM `return`.

### `offset @code_end` Pattern for Immutables

```venom
%439 = offset @code_end, 0      ; Address of immutable at offset 0
codecopy 0, %439, 32            ; Copy 32 bytes to memory
%val = mload 0                  ; Read immutable value
```

Immutables are stored after the runtime code (`@code_end`) and loaded via `codecopy`.

### Summary: Why Native Vyper Doesn't Use invoke/ret

1. **External functions** terminate with EVM `return`, `revert`, or `stop`
2. **Internal functions** are fully inlined during IR → Venom translation
3. **Memory-based parameter passing** eliminates need for stack-based invoke/ret
4. **Labels** are used for control flow, not EVM addresses on stack

Our transpiler creates a fundamentally different pattern:
- Separate IR functions with `invoke`/`ret`
- Stack-based parameter passing
- PC captured via `param`, returned via `ret`

This is why we're stress-testing backend code paths that native Vyper never exercises.

---

## Session 4: Actionable Native Patterns for Transpiler

### Confirmed Stats from `vyper_mega_test_venom_runtime.vnm`

| Metric | Native Vyper | Yul2Venom (Current) |
|--------|--------------|----------------------|
| Functions | **1** (`__main_entry`) | 100+ |
| `invoke` instructions | **0** | 100+ |
| `ret` instructions | **0** | 100+ |
| `phi` nodes | **33+** | ? |
| `djmp` (hash dispatch) | **1** | 0 |
| Internal call inlining | ✅ All (`%inlX_` prefix) | ❌ None |

---

### Pattern 1: Hash-Based Selector Dispatch (`djmp`)

Native Vyper uses **O(1) average case** selector dispatch:

```venom
__main_entry:
    %selector = shr 224, (calldataload 0)
    %bucket_idx = mod %selector, 41          ; mod by bucket count
    %ptr = shl 1, %bucket_idx                ; *2 for 2-byte pointers
    %table_addr = add @selector_buckets, %ptr
    codecopy 30, %table_addr, 2              ; read 2-byte jump target
    %target = mload 0
    djmp %target, @bucket_0, @bucket_1, ... @fallback
```

**Implementation for Yul2Venom:**
1. Group selectors into buckets by `mod(selector, N)`
2. Create a jump table with 2-byte offsets
3. Use `djmp` with all bucket labels as targets
4. Within each bucket, use linear `jnz` chain (small N per bucket)

---

### Pattern 2: SSA Variables with Versioning

Native Vyper uses SSA-style variable versioning with colon notation:

```venom
%alloca_52_33_1 = 0          ; Initial definition (version 1)
; ... at loop header:
%alloca_52_33_1:1 = phi @entry, %alloca_52_33_1, @incr, %alloca_52_33_1:2
; ... inside loop:
%alloca_52_33_1:2 = add ...  ; Updated definition (version 2)
```

**Naming Convention:**
- `%varname` - first definition
- `%varname:1` - second definition (phi merge)
- `%varname:2` - third definition (loop body update)

**Implementation for Yul2Venom:**
- Use Vyper's `IRVariable.version` property
- Maintain version counter per variable when translating loops

---

### Pattern 3: Phi Nodes for Control Flow Merge

Phi nodes select values based on predecessor block:

```venom
"external_cleanup":
    ; Merge return offset from two branches
    %ret_ofst:2 = phi @then_branch, %ret_ofst:4, @else_branch, %ret_ofst:3
    return %ret_ofst:2, 32
```

**Pattern for if/else:**
```venom
then_branch:
    mstore 64, 1
    %ret_ofst:4 = 64
    jmp @cleanup

else_branch:
    mstore 96, 0  
    %ret_ofst:3 = 96
    jmp @cleanup

cleanup:
    %ret_ofst:2 = phi @then_branch, %ret_ofst:4, @else_branch, %ret_ofst:3
    return %ret_ofst:2, 32
```

**Implementation for Yul2Venom:**
- Convert Yul `switch` blocks to phi-based merges
- Track which variable is assigned per branch
- Insert phi at merge point

---

### Pattern 4: Loop Structure with Phi

Bounded loops use this exact pattern:

```venom
; Before loop
%counter = 0
%accum = 0
jmp @condition

condition:  ; Loop header with phi nodes
    %counter:1 = phi @entry, %counter, @incr, %counter:2
    %accum:1 = phi @entry, %accum, @incr, %accum:2
    %done = xor %limit, %counter:1    ; xor-based != check
    jnz %done, @body, @exit

body:
    ; ... loop operations using %accum:1 ...
    %accum:2 = add %accum:1, %value
    jmp @incr

incr:
    %counter:2 = add 1, %counter:1
    jmp @condition

exit:
    ; Use %accum:1 (the phi-merged value)
```

**Key Points:**
- Use `xor` then `jnz` for inequality (not `eq` + negation)
- Phi node at loop header, not at merge points
- Increment separate from body for clarity

---

### Pattern 5: Allocas for Mutable Variables

Variables that change value get `alloca` prefix and versioning:

```venom
%alloca_52_33_1 = 0              ; Storage for mutable var
%alloca_52_33_1:1 = phi ...      ; Merge at control flow joins
%alloca_52_33_1:2 = add ...      ; Update within body
```

**Naming:** `%alloca_<line>_<name>_<unique>`

---

### Pattern 6: Internal Function Inlining

**ALL internal functions are inlined** in native Vyper:

```venom
; Call to _internal_calc(a, 10)
%1262 = %a                            ; arg1
%1263 = 10                            ; arg2
%inl2_11 = mul %1263, %1262           ; from "_internal_calc"
%1268 = 1
%inl2_18 = add %1268, %inl2_11        ; from "_internal_calc"  
%result = %inl2_18                    ; return value
```

**Inlining Pattern:**
- Prefix all inlined variables with `%inlN_` where N is call site index
- No invoke/ret - just embed the function body directly
- Comment source with `; from "function_name"`

**Implementation for Yul2Venom:**
1. Track all internal function definitions
2. At call sites, inline the function body
3. Rename all variables with `%inl{call_index}_` prefix
4. Map formal parameters to actual arguments

---

### Pattern 7: Return Value via Memory (Not Stack)

External functions return via memory:

```venom
mstore 64, %result      ; Store result at offset 64
return 64, 32           ; Return 32 bytes from offset 64
```

Internal "returns" write to known memory locations (no stack-based ret):

```venom
; In S-expression IR:
[mstore, return_buffer, %result]
[exit_to, cleanup_label, return_pc]

; In Venom IR - just becomes inline code
%result = ...computation...
; No ret instruction - value is used directly at call site
```

---

### Pattern 8: Offset for Immutables

Immutables (deploy-time constants) use codecopy:

```venom
%addr = offset @code_end, 0      ; Offset 0 after runtime code
codecopy 0, %addr, 32            ; Copy 32 bytes to memory
%immutable_val = mload 0         ; Read from memory
```

---

### Actionable Implementation Plan

1. **Selector Dispatch**: Implement `djmp` with hash buckets
   - File: `venom_generator.py` - `_handle_yul_switch()`
   
2. **Phi Nodes**: Generate proper phi at merge points
   - For if/else: phi at exit block
   - For loops: phi at loop header
   
3. **Internal Function Inlining**: Eliminate invoke/ret entirely
   - Option A: Inline at IR generation time (modify `_handle_yul_function_call()`)
   - Option B: Run inlining pass after IR generation
   
4. **SSA Versioning**: Use colon notation for variable versions
   - Track variable definitions, add `:N` suffix for redefinitions

5. **Loop Translation**: Match exact native pattern
   - Entry → jmp to condition
   - Condition: phi nodes + xor + jnz
   - Body → jmp to incr
   - Incr: counter + 1 → jmp to condition

---

### Priority for Fixing OutOfGas

**Highest Impact**: Inline internal functions
- Eliminates all `invoke`/`ret` instructions
- Bypasses the under-tested backend code path entirely
- Matches exactly what native Vyper does

---

## Session 5: Deep AHA Moments from Native IR Analysis (2026-01-31)

### Source Files Analyzed

| File | Lines | Size | Key Features |
|------|-------|------|--------------|
| `vyper_loop_test_venom_runtime.vnm` | 247 | 5.3KB | Multiple loops, djmp dispatch |
| `vyper_nested_loop_venom_runtime.vnm` | 299 | 6.2KB | **Nested loops**, phi version chaining |
| `loop_test_struct_venom_runtime.vnm` | 176 | 3.5KB | Struct arrays, mcopy |
| `vyper_mega_test_venom_runtime.vnm` | 50KB+ | - | Full feature coverage |

### 🎯 AHA Moment #1: Constants Are Always Separate Variables

Native Vyper **NEVER** uses inline constants. Every constant is assigned to a variable first:

```venom
; NATIVE VYPER - constants as variables
%115 = 224                    ; constant 224
%2 = shr %115, %1             ; use variable, not literal
%116 = 3                      ; constant 3
%4 = mod %117, %116           ; use variable

; WRONG (what Yul2Venom might do)
%2 = shr 224, %1              ; direct literal - not native pattern!
```

**Why?**: This enables better register allocation and optimization passes. Constants become SSA variables that can be analyzed.

### 🎯 AHA Moment #2: Operand Order is REVERSED from Text

Looking at native IR closely:

```venom
%2 = shr %115, %1    ; TEXT ORDER: shift_amount, value
; Parser reverses → Internal: [%1, %115]
; Execution: shr(value=%1, amount=%115) ✓
```

The **text order** is `(shift_amount, value)` but the **execution order** is `shr(value, shift_amount)`. This confirms the parser reversal pattern.

### 🎯 AHA Moment #3: SSA Versioning Pattern for Nested Loops

In nested loop IR (`vyper_nested_loop_venom_runtime.vnm`), phi versions chain correctly:

```venom
; Outer loop condition (lines 211-217)
18_condition:
    %alloca_7_103_1:1 = phi @14_if_exit, %alloca_7_103_1, @20_incr, %alloca_7_103_1:2
    %111:1:1 = phi @14_if_exit, %111, @20_incr, %111:2
    ; counter is %111:1:1

; Inner loop condition (lines 244-250)
23_condition:
    %alloca_7_103_1:2 = phi @19_body, %alloca_7_103_1:1, @24_body, %alloca_7_103_1:3
    %132:1:1 = phi @19_body, %132, @24_body, %132:2
```

**Key Observation**: The outer loop's phi output (`:1`) feeds into the inner loop's phi input. Version chains:
- Outer loop: `:1` → body modifies → `:2` → back to condition
- Inner loop: receives `:1`, produces `:2` (merged back) and `:3` (in body)

### 🎯 AHA Moment #4: mstore Always Uses Variable Addresses

Native Vyper pre-computes all memory offsets as variables:

```venom
%151 = 0xce0                  ; compute address as variable
mstore %151, %150             ; use variable, not literal 0xce0

%152 = 32                     ; size
%153 = 0xce0                  ; offset
return %153, %152             ; both are variables!
```

**Never**: `mstore 0xce0, %val` - this is NOT native Vyper style!

### 🎯 AHA Moment #5: Loop Increment is SEPARATE from Body

Native Vyper separates loop increment into its own block for nested loops:

```venom
5_body:          ; loop body
    ; ... body operations ...
    jmp @4_condition   ; NO increment here for single loops!

; But for nested loops, there's an explicit incr block:
20_incr:         ; OUT=[18_condition]
    %262 = %111:1:1
    %263 = 1
    %111:2 = add %263, %262
    jmp @18_condition
```

**Pattern for nested loops**:
- Outer body → inner loop → jmp to outer incr
- Outer incr → increment counter → jmp to outer condition

### 🎯 AHA Moment #6: mcopy for Struct Copies

Struct copying uses `mcopy` instruction (Cancun opcode):

```venom
%187 = 64                     ; size = 64 bytes (2 words = 1 struct)
%188 = 0x32a0                 ; destination
mcopy %188, %46, %187         ; mcopy dest, src, size
```

**Struct size**: shl 6 = multiply by 64 = 2 * 32-byte words = typical struct size.

### 🎯 AHA Moment #7: xor-based Inequality Check

Native Vyper uses `xor` for inequality (not `eq` + `iszero`):

```venom
%33 = xor %181, %180          ; if %181 != %180, result is non-zero
jnz %33, @5_body, @7_exit     ; jump to body if non-zero (not equal)
```

**Optimization**: `xor a, b` is 3 gas. `eq a, b` + `iszero` is 6 gas. Native Vyper saves gas!

### 🎯 AHA Moment #8: Overflow Checks with assert

Overflow checking pattern:

```venom
%192 = %54                    ; original value
%193 = 1
%56 = add %193, %192          ; add 1
%195 = %56                    ; result
%58 = lt %195, %194           ; if result < original, overflow!
%59 = iszero %58
assert %59                    ; revert if overflow
```

**Pattern**: After `add a, b`, check `lt(result, a)`. If true, overflow occurred.

### 🎯 AHA Moment #9: Immutable Storage Access Pattern

Reading immutables (constant addresses):

```venom
%176 = 0x1960                 ; storage location for counter
%175 = 0
mstore %176, %175             ; initialize counter to 0
; ... later ...
%198 = 0x1960
%61 = mload %198              ; read counter
```

**Fixed addresses** like `0x1960`, `0x32a0`, `0x3320` are used for temporary storage. These are pre-allocated by the compiler.

### 🎯 AHA Moment #10: Single Function = Selector Dispatch + All Bodies

The entire contract is ONE function with this structure:

```venom
function __main_entry {
  __main_entry:
      ; selector extraction + dispatch
      djmp/jnz to function bodies

  selector_bucket_0:
      ; function body 0 INLINED HERE

  selector_bucket_1:
      ; jnz for function 1 vs function 2
      ; function body 1 INLINED HERE (or goto body block)

  internal_function_body_blocks:
      ; all internal function code INLINED
      
  fallback:
      revert 0, 0
}
```

### Summary: Native Pattern Checklist

| Pattern | Native Vyper | Check |
|---------|-------------|-------|
| Constants as variables | ✅ Always | |
| Operand reversal awareness | ✅ Parser reverses | |
| SSA version chaining | ✅ `:1`, `:2`, `:1:1` | |
| Variable addresses for mstore | ✅ Never literal addresses | |
| Separate incr block for nested | ✅ `N_incr:` block | |
| mcopy for struct copy | ✅ `mcopy dest, src, size` | |
| xor for inequality | ✅ More efficient than eq | |
| assert for overflow | ✅ `lt(result, original)` | |
| Fixed memory addresses | ✅ Pre-allocated slots | |
| Single function model | ✅ `__main_entry` only | |

### Implications for Yul2Venom

1. **Pre-compute all constants as variables** before using in operations
2. **Use xor for loop conditions** instead of eq + iszero
3. **Version phi variables correctly** for nested loop support
4. **Use mcopy** for struct array operations (if Cancun target)
5. **Inline all internal functions** to match native pattern

---

## Appendix: File Quick Reference

| File | Purpose | Key Patterns |
|------|---------|--------------|
| `vyper_loop_test_*` | Basic loops | phi, xor, assert overflow |
| `vyper_nested_loop_*` | Nested loops | phi version chaining, incr blocks |
| `loop_test_struct_*` | Struct arrays | mcopy, shl 6 sizing |
| `vyper_comprehensive_*` | All features | djmp dispatch, inlined internals |
| `vyper_mega_test_*` | Full coverage | 50KB+, production patterns |







