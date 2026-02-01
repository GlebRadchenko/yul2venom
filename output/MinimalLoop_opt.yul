object "MinimalLoop_76" {
    code {
        {
            /// @src 0:58:532  "contract MinimalLoop {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("MinimalLoop_76_deployed")
            codecopy(_1, dataoffset("MinimalLoop_76_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/MinimalLoop.sol"
    object "MinimalLoop_76_deployed" {
        code {
            {
                /// @src 0:58:532  "contract MinimalLoop {..."
                mstore(64, memoryguard(0x80))
                if iszero(lt(calldatasize(), 4))
                {
                    if eq(0x9759c210, shr(224, calldataload(0)))
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
                        /// @src 0:340:353  "uint256 i = 0"
                        let var_i := /** @src 0:58:532  "contract MinimalLoop {..." */ 0
                        /// @src 0:335:468  "for (uint256 i = 0; i < input.length; i++) {..."
                        for { }
                        /** @src 0:355:371  "i < input.length" */ lt(var_i, length)
                        /// @src 0:340:353  "uint256 i = 0"
                        {
                            /// @src 0:373:376  "i++"
                            var_i := /** @src 0:58:532  "contract MinimalLoop {..." */ add(/** @src 0:373:376  "i++" */ var_i, /** @src 0:454:455  "1" */ 0x01)
                        }
                        /// @src 0:373:376  "i++"
                        {
                            /// @src 0:58:532  "contract MinimalLoop {..."
                            let value := calldataload(/** @src 0:417:425  "input[i]" */ calldata_array_index_access_struct_Element_calldata_dyn_calldata(arrayPos, length, var_i))
                            /// @src 0:58:532  "contract MinimalLoop {..."
                            let value_1 := calldataload(/** @src 0:437:451  "input[i].value" */ add(/** @src 0:437:445  "input[i]" */ calldata_array_index_access_struct_Element_calldata_dyn_calldata(arrayPos, length, var_i), /** @src 0:58:532  "contract MinimalLoop {..." */ 32))
                            let sum := add(value_1, /** @src 0:454:455  "1" */ 0x01)
                            /// @src 0:58:532  "contract MinimalLoop {..."
                            if gt(value_1, sum)
                            {
                                mstore(0, shl(224, 0x4e487b71))
                                mstore(4, 0x11)
                                revert(0, 36)
                            }
                            /// @src 0:404:457  "Element({id: input[i].id, value: input[i].value + 1})"
                            let expr_mpos := /** @src 0:58:532  "contract MinimalLoop {..." */ allocate_memory()
                            mstore(expr_mpos, value)
                            mstore(/** @src 0:404:457  "Element({id: input[i].id, value: input[i].value + 1})" */ add(expr_mpos, /** @src 0:58:532  "contract MinimalLoop {..." */ 32), sum)
                            /// @src 0:392:457  "output[i] = Element({id: input[i].id, value: input[i].value + 1})"
                            mstore(memory_array_index_access_struct_Element_dyn(memPtr, var_i), expr_mpos)
                            pop(memory_array_index_access_struct_Element_dyn(memPtr, var_i))
                        }
                        /// @src 0:483:492  "output[0]"
                        let addr := /** @src 0:58:532  "contract MinimalLoop {..." */ 0
                        if iszero(mload(memPtr))
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x32)
                            revert(0, 36)
                        }
                        addr := add(memPtr, 32)
                        let _3 := mload(/** @src 0:483:492  "output[0]" */ mload(addr))
                        /// @src 0:511:520  "output[1]"
                        let addr_1 := /** @src 0:58:532  "contract MinimalLoop {..." */ 0
                        if iszero(lt(/** @src 0:454:455  "1" */ 0x01, /** @src 0:58:532  "contract MinimalLoop {..." */ mload(memPtr)))
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x32)
                            revert(0, 36)
                        }
                        addr_1 := add(memPtr, 64)
                        let _4 := mload(/** @src 0:511:520  "output[1]" */ mload(addr_1))
                        /// @src 0:58:532  "contract MinimalLoop {..."
                        let memPos := mload(64)
                        mstore(memPos, _3)
                        mstore(add(memPos, 32), _4)
                        return(memPos, 64)
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
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:58:532  "contract MinimalLoop {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x41)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:58:532  "contract MinimalLoop {..." */ 0x24)
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
        data ".metadata" hex"a26469706673582212204f5e35d54a0bed1e6970242f0cf85524d667ac0d843fd6684a9269b6319f611c64736f6c634300081c0033"
    }
}