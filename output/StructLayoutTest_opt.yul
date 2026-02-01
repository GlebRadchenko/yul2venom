object "StructLayoutTest_38" {
    code {
        {
            /// @src 0:57:338  "contract StructLayoutTest {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("StructLayoutTest_38_deployed")
            codecopy(_1, dataoffset("StructLayoutTest_38_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/StructLayoutTest.sol"
    object "StructLayoutTest_38_deployed" {
        code {
            {
                /// @src 0:57:338  "contract StructLayoutTest {..."
                mstore(64, memoryguard(0x80))
                if iszero(lt(calldatasize(), 4))
                {
                    if eq(0x7d4a17e3, shr(224, calldataload(0)))
                    {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let size := /** @src -1:-1:-1 */ 0
                        /// @src 0:57:338  "contract StructLayoutTest {..."
                        let _1 := /** @src -1:-1:-1 */ 0
                        /// @src 0:57:338  "contract StructLayoutTest {..."
                        _1 := /** @src -1:-1:-1 */ 0
                        /// @src 0:57:338  "contract StructLayoutTest {..."
                        size := 64
                        let memPtr := 0
                        memPtr := mload(size)
                        let newFreePtr := add(memPtr, and(add(size, 31), not(31)))
                        if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr))
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x41)
                            revert(0, 0x24)
                        }
                        mstore(size, newFreePtr)
                        mstore(memPtr, /** @src 0:273:274  "1" */ 0x01)
                        /// @src 0:57:338  "contract StructLayoutTest {..."
                        let _2 := add(size, not(31))
                        let i := 0
                        for { } lt(i, _2) { i := add(i, 32) }
                        {
                            let memPtr_1 := allocate_memory()
                            mstore(memPtr_1, 0)
                            mstore(add(memPtr_1, 32), 0)
                            mstore(add(add(memPtr, i), 32), memPtr_1)
                        }
                        /// @src 0:294:309  "Element(10, 20)"
                        let expr_mpos := /** @src 0:57:338  "contract StructLayoutTest {..." */ allocate_memory()
                        mstore(expr_mpos, /** @src 0:302:304  "10" */ 0x0a)
                        /// @src 0:57:338  "contract StructLayoutTest {..."
                        mstore(/** @src 0:294:309  "Element(10, 20)" */ add(expr_mpos, /** @src 0:57:338  "contract StructLayoutTest {..." */ 32), /** @src 0:306:308  "20" */ 0x14)
                        /// @src 0:285:309  "arr[0] = Element(10, 20)"
                        mstore(memory_array_index_access_struct_Element_dyn(memPtr), expr_mpos)
                        pop(memory_array_index_access_struct_Element_dyn(memPtr))
                        /// @src 0:57:338  "contract StructLayoutTest {..."
                        let memPos := mload(size)
                        let tail := add(memPos, 32)
                        mstore(memPos, 32)
                        let pos := tail
                        let length := mload(memPtr)
                        mstore(tail, length)
                        pos := add(memPos, size)
                        let srcPtr := add(memPtr, 32)
                        let i_1 := 0
                        for { }
                        lt(i_1, length)
                        {
                            i_1 := add(i_1, /** @src 0:273:274  "1" */ 0x01)
                        }
                        /// @src 0:57:338  "contract StructLayoutTest {..."
                        {
                            let _3 := mload(srcPtr)
                            mstore(pos, mload(_3))
                            mstore(add(pos, 32), mload(add(_3, 32)))
                            pos := add(pos, size)
                            srcPtr := add(srcPtr, 32)
                        }
                        return(memPos, sub(pos, memPos))
                    }
                }
                revert(0, 0)
            }
            function allocate_memory() -> memPtr
            {
                memPtr := mload(64)
                let newFreePtr := add(memPtr, 64)
                if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr))
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:57:338  "contract StructLayoutTest {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x41)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:57:338  "contract StructLayoutTest {..." */ 0x24)
                }
                mstore(64, newFreePtr)
            }
            function memory_array_index_access_struct_Element_dyn(baseRef) -> addr
            {
                if iszero(mload(baseRef))
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x32)
                    revert(0, 0x24)
                }
                addr := add(baseRef, 32)
            }
        }
        data ".metadata" hex"a2646970667358221220230cdbe3731812351a16a3cbd88c682ad827dd648cbaee684705913a25ac751964736f6c634300081c0033"
    }
}