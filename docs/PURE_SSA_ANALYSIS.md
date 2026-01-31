# Pure SSA Analysis: Eliminating Memory from Yul2Venom

## Current State: Memory-Backed Variables

Our transpiler uses `mstore`/`mload` for:
1. **Loop variables** - stored in scratch memory (0x300+)
2. **Switch state** - stored in memory during case dispatch
3. **Cross-block values** - any variable live across BBs

```venom
; OUR CURRENT OUTPUT (memory-backed)
%offset = 0x300
mstore %offset, %i
...
%i = mload %offset
```

## Vyper Venom: Pure Virtual Registers

Vyper Venom uses **NO memory for computation variables**:

```venom
; VYPER OUTPUT (pure SSA)
5_condition:
    %i:1 = phi @init, %i_init, @body, %i:2
    jnz %cond, @body, @exit

6_body:
    %i:2 = add 1, %i:1
    jmp @5_condition
```

**Key difference**: Variables are SSA versioned (`%i:1`, `%i:2`) and merged with `phi`.

## How Venom Backend Maps SSA to Stack

`VenomCompiler` → `StackModel`:
1. Each `%var` assignment → PUSH result (stack grows)
2. Each `%var` use → DUP from current stack position
3. `phi` nodes → select correct predecessor version
4. `_stack_reorder` → arrange stack for instruction input order
5. Stack spilling → deep items (>16) spilled to memory only when needed

## Can We Achieve Pure SSA?

**YES, but requires significant refactoring:**

### Required Changes

| Component | Current | Pure SSA |
|-----------|---------|----------|
| Loop vars | mstore/mload | phi nodes + SSA versions |
| Switch state | switch_var_mem | phi nodes at case joins |
| Cross-BB | memory | liveness analysis + phi |
| Generator | emit mstore | emit variable assignments |

### Implementation Steps

1. **SSA Version Variables**
   ```python
   # Instead of: self.emit_line(f"mstore 0x300, %{var}")
   # Emit: %var:2 = add 1, %var:1
   self.var_version[var] += 1
   new_var = f"%{var}:{self.var_version[var]}"
   self.emit_line(f"{new_var} = add 1, {old_var}")
   ```

2. **Emit Phi Nodes at Join Points**
   ```python
   def emit_loop_header(self, loop_var, preds):
       versions = [(pred, self.get_var_version(loop_var, pred)) for pred in preds]
       phi_str = ", ".join(f"@{p}, {v}" for p, v in versions)
       self.emit_line(f"%{loop_var}:merged = phi {phi_str}")
   ```

3. **Track Liveness**
   - Variables live at block exit need phi at join

### Memory Still Needed For

- ABI return encoding (`mstore` before `return`)
- Storage sha3 computation (scratch for key hashing)
- Dynamic arrays (actual data storage)
- Call data parameters

## Feasibility Assessment

| Factor | Assessment |
|--------|------------|
| Complexity | HIGH - full SSA construction |
| Backend compat | HIGH - Venom expects phi nodes |
| Performance gain | MODERATE - fewer memory ops |
| Risk | MEDIUM - may break edge cases |

## Recommendation

**Hybrid approach:**
1. Keep memory for complex cases (arrays, storage)
2. Add phi nodes for simple loop counters/accumulators
3. Let `Mem2Var` pass optimize remaining cases

The `Mem2Var` pass already converts many memory ops to registers - our memory approach is "tricking" it correctly. For maximum efficiency, we'd emit pure SSA, but the current approach works.
