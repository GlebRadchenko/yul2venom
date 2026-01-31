object "LoopCheckCalldata_59" {
    code {
        {
            /// @src 0:58:471  "contract LoopCheckCalldata {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("LoopCheckCalldata_59_deployed")
            codecopy(_1, dataoffset("LoopCheckCalldata_59_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"contracts/LoopCheckCalldata.sol"
    object "LoopCheckCalldata_59_deployed" {
        code {
            {
                /// @src 0:58:471  "contract LoopCheckCalldata {..."
                mstore(64, memoryguard(0x80))
                if iszero(lt(calldatasize(), 4))
                {
                    if eq(0xe296f284, shr(224, calldataload(0)))
                    {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let offset := calldataload(4)
                        if gt(offset, 0xffffffffffffffff) { revert(0, 0) }
                        if iszero(slt(add(offset, 35), calldatasize())) { revert(0, 0) }
                        let length := calldataload(add(4, offset))
                        if gt(length, 0xffffffffffffffff) { revert(0, 0) }
                        let arrayPos := add(offset, 36)
                        if gt(add(add(offset, shl(6, length)), 36), calldatasize()) { revert(0, 0) }
                        let _1 := array_allocation_size_array_struct_Element_dyn(length)
                        let memPtr := 0
                        memPtr := mload(64)
                        let newFreePtr := add(memPtr, and(add(_1, 31), not(31)))
                        if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr))
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x41)
                            revert(0, 36)
                        }
                        mstore(64, newFreePtr)
                        mstore(memPtr, length)
                        let _2 := add(array_allocation_size_array_struct_Element_dyn(length), not(31))
                        let i := 0
                        for { } lt(i, _2) { i := add(i, 32) }
                        {
                            let memPtr_1 := allocate_memory()
                            mstore(memPtr_1, 0)
                            mstore(add(memPtr_1, 32), 0)
                            mstore(add(add(memPtr, i), 32), memPtr_1)
                        }
                        /// @src 0:335:348  "uint256 i = 0"
                        let var_i := /** @src 0:58:471  "contract LoopCheckCalldata {..." */ 0
                        /// @src 0:330:463  "for (uint256 i = 0; i < input.length; i++) {..."
                        for { }
                        /** @src 0:350:366  "i < input.length" */ lt(var_i, length)
                        /// @src 0:335:348  "uint256 i = 0"
                        {
                            /// @src 0:368:371  "i++"
                            var_i := /** @src 0:58:471  "contract LoopCheckCalldata {..." */ add(/** @src 0:368:371  "i++" */ var_i, /** @src 0:449:450  "1" */ 0x01)
                        }
                        /// @src 0:368:371  "i++"
                        {
                            /// @src 0:58:471  "contract LoopCheckCalldata {..."
                            let value := calldataload(/** @src 0:412:420  "input[i]" */ calldata_array_index_access_struct_Element_calldata_dyn_calldata(arrayPos, length, var_i))
                            /// @src 0:58:471  "contract LoopCheckCalldata {..."
                            let value_1 := calldataload(/** @src 0:432:446  "input[i].value" */ add(/** @src 0:432:440  "input[i]" */ calldata_array_index_access_struct_Element_calldata_dyn_calldata(arrayPos, length, var_i), /** @src 0:58:471  "contract LoopCheckCalldata {..." */ 32))
                            let sum := add(value_1, /** @src 0:449:450  "1" */ 0x01)
                            /// @src 0:58:471  "contract LoopCheckCalldata {..."
                            if gt(value_1, sum)
                            {
                                mstore(0, shl(224, 0x4e487b71))
                                mstore(4, 0x11)
                                revert(0, 36)
                            }
                            /// @src 0:399:452  "Element({id: input[i].id, value: input[i].value + 1})"
                            let expr_mpos := /** @src 0:58:471  "contract LoopCheckCalldata {..." */ allocate_memory()
                            mstore(expr_mpos, value)
                            mstore(/** @src 0:399:452  "Element({id: input[i].id, value: input[i].value + 1})" */ add(expr_mpos, /** @src 0:58:471  "contract LoopCheckCalldata {..." */ 32), sum)
                            /// @src 0:387:452  "output[i] = Element({id: input[i].id, value: input[i].value + 1})"
                            mstore(memory_array_index_access_struct_Element_dyn(memPtr, var_i), expr_mpos)
                            pop(memory_array_index_access_struct_Element_dyn(memPtr, var_i))
                        }
                        /// @src 0:58:471  "contract LoopCheckCalldata {..."
                        let memPos := mload(64)
                        let tail := add(memPos, 32)
                        mstore(memPos, 32)
                        let pos := tail
                        let length_1 := mload(memPtr)
                        mstore(tail, length_1)
                        pos := add(memPos, 64)
                        let srcPtr := add(memPtr, 32)
                        let i_1 := 0
                        for { }
                        lt(i_1, length_1)
                        {
                            i_1 := add(i_1, /** @src 0:449:450  "1" */ 0x01)
                        }
                        /// @src 0:58:471  "contract LoopCheckCalldata {..."
                        {
                            let _3 := mload(srcPtr)
                            mstore(pos, mload(_3))
                            mstore(add(pos, 32), mload(add(_3, 32)))
                            pos := add(pos, 64)
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
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:58:471  "contract LoopCheckCalldata {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x41)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:58:471  "contract LoopCheckCalldata {..." */ 0x24)
                }
                mstore(64, newFreePtr)
            }
            function array_allocation_size_array_struct_Element_dyn(length) -> size
            {
                if gt(length, 0xffffffffffffffff)
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x41)
                    revert(0, 0x24)
                }
                size := add(shl(5, length), 0x20)
            }
            function calldata_array_index_access_struct_Element_calldata_dyn_calldata(base_ref, length, index) -> addr
            {
                if iszero(lt(index, length))
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x32)
                    revert(0, 0x24)
                }
                addr := add(base_ref, shl(6, index))
            }
            function memory_array_index_access_struct_Element_dyn(baseRef, index) -> addr
            {
                if iszero(lt(index, mload(baseRef)))
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x32)
                    revert(0, 0x24)
                }
                addr := add(add(baseRef, shl(5, index)), 32)
            }
        }
        data ".metadata" hex"a264697066735822122088d9176d1f2d9de993e7cb5acfda5c4a567ec1b30646776d324103b82f7e394f64736f6c634300081c0033"
    }
}