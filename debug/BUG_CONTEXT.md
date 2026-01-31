# Yul2Venom Transpiler Bug: 32 != 20 Serialization Error

## Bug Summary
A Solidity→Yul→Venom IR transpiler produces incorrect bytecode for struct array serialization. The second element returns wrong data.

## Test Case
Input: `processStructs([{id:10, value:100}, {id:20, value:200}])`  
Expected output: `[{id:10, value:101}, {id:20, value:201}]`  
Actual output: `[{id:10, value:101}, {id:32, value:2}]`

## Return Data Analysis
```
Word 0: 32   ← ABI offset
Word 1: 2    ← Array length
Word 2: 10   ← output[0].id ✓
Word 3: 101  ← output[0].value ✓
Word 4: 32   ← output[1].id ✗ (should be 20, but equals Word 0!)
Word 5: 2    ← output[1].value ✗ (should be 201, but equals Word 1!)
```

Words 4-5 are identical to Words 0-1, meaning the serialization loop reads from the output buffer header instead of struct[1] data.

## Files Included
1. `source.yul` - Yul source from Solidity compilation
2. `venom_ir.vnm` - Transpiled Venom IR
3. `assembly.asm` - Generated EVM assembly
4. `runtime_bytecode.hex` - Final bytecode

## Architecture Overview
The code has two main loops:
1. **Population loop (block 33)** - Reads calldata, allocates structs at FMP, stores pointers in array
2. **Serialization loop (block 54)** - Reads pointer array, loads struct data, writes to output buffer

## Key IR Blocks

### Block 50_end_if (Stores struct pointer into array)
```
%295 = %80                    ; struct addr (from mload(64) = FMP)
%91 = shl %292, %291          ; i * 32
%92 = add %293, %91           ; array_base + i*32
%93 = add %294, %92           ; array_base + i*32 + 32 = pointer slot
mstore %296, %295             ; Store struct addr to pointer slot
```

### Block 55_blk_loop_body (Serialization loop - reads and writes data)
```
%113 = mload %322             ; Load struct addr from pointer array
%114 = mload %323             ; Load id from struct
mstore %324, %114             ; Write id to output
%117 = mload %116             ; Load value from struct+32
mstore %115, %117             ; Write value to output+32
%119 = add %332, %331         ; srcPtr += 32 (next pointer slot)
%118 = add %330, %329         ; pos += 64 (next output position)
```

## Memory Layout (Expected)
```
0x1000: Array base (contains length=2)
0x1020: Pointer to struct[0] → should contain 0x1060
0x1040: Pointer to struct[1] → should contain 0x10A0 (BUG: contains wrong value!)
0x1060: Struct[0] data {id, value}
0x10A0: Struct[1] data {id, value}  
0x10E0: Output buffer start (32=offset, 2=length, ...)
```

## Hypothesis
The mstore in block 50_end_if writes the wrong value to the pointer array slot for element[1]. Either:
1. Stack manipulation puts wrong value on stack for mstore
2. The `%80` (struct addr) value is not correctly preserved/updated between loop iterations
3. Phi node handling at loop boundaries has incorrect value flow

## Backend Assign Handling Context
The backend has special handling for `assign` instructions. When source is live after:
```python
if source in next_liveness:
    self.spiller.dup(assembly, stack, depth)
    stack.poke(0, dest)
```

Issue found: `next_liveness` uses liveness at NEXT instruction. After `assign %276 = %81`, variable `%81` is "dead" (renamed to `%276`), so DUPs may not happen when needed.

## Request
Please analyze:
1. Trace stack state through blocks 44_end_if → 47_end_if → 50_end_if for both loop iterations
2. Verify if `mstore %296, %295` in block 50 writes correct struct address for both iterations
3. Check if the serialization loop (block 55) reads from correct pointer slots
4. Identify the exact point where wrong value flows to wrong location
