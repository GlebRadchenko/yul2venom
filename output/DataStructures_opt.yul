object "DataStructures_270" {
    code {
        {
            /// @src 0:155:2411  "contract DataStructures {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("DataStructures_270_deployed")
            codecopy(_1, dataoffset("DataStructures_270_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/bench/DataStructures.sol"
    object "DataStructures_270_deployed" {
        code {
            {
                /// @src 0:155:2411  "contract DataStructures {..."
                mstore(64, memoryguard(0x80))
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x3e715a46 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let offset := calldataload(4)
                        if gt(offset, 0xffffffffffffffff) { revert(0, 0) }
                        if iszero(slt(add(offset, 35), calldatasize())) { revert(0, 0) }
                        let length := calldataload(add(4, offset))
                        if gt(length, 0xffffffffffffffff) { revert(0, 0) }
                        let arrayPos := add(offset, 36)
                        if gt(add(add(offset, shl(6, length)), 36), calldatasize()) { revert(0, 0) }
                        let _1 := array_allocation_size_array_struct_SimpleStruct_dyn(length)
                        let memPtr := mload(64)
                        finalize_allocation(memPtr, _1)
                        mstore(memPtr, length)
                        let _2 := add(array_allocation_size_array_struct_SimpleStruct_dyn(length), not(31))
                        let i := 0
                        for { } lt(i, _2) { i := add(i, 32) }
                        {
                            let memPtr_1 := /** @src -1:-1:-1 */ 0
                            /// @src 0:155:2411  "contract DataStructures {..."
                            let memPtr_2 := mload(64)
                            finalize_allocation_4288(memPtr_2)
                            memPtr_1 := memPtr_2
                            mstore(memPtr_2, /** @src -1:-1:-1 */ 0)
                            /// @src 0:155:2411  "contract DataStructures {..."
                            mstore(add(memPtr_2, 32), /** @src -1:-1:-1 */ 0)
                            /// @src 0:155:2411  "contract DataStructures {..."
                            mstore(add(add(memPtr, i), 32), memPtr_2)
                        }
                        /// @src 0:1748:1761  "uint256 i = 0"
                        let var_i := /** @src 0:155:2411  "contract DataStructures {..." */ 0
                        /// @src 0:1743:1866  "for (uint256 i = 0; i < arr.length; i++) {..."
                        for { }
                        /** @src 0:1763:1777  "i < arr.length" */ lt(var_i, length)
                        /// @src 0:1748:1761  "uint256 i = 0"
                        {
                            /// @src 0:1779:1782  "i++"
                            var_i := /** @src 0:155:2411  "contract DataStructures {..." */ add(/** @src 0:1779:1782  "i++" */ var_i, /** @src 0:155:2411  "contract DataStructures {..." */ 1)
                        }
                        /// @src 0:1779:1782  "i++"
                        {
                            /// @src 0:155:2411  "contract DataStructures {..."
                            let value := calldataload(/** @src 0:1823:1829  "arr[i]" */ calldata_array_index_access_struct_SimpleStruct_calldata_dyn_calldata(arrayPos, length, var_i))
                            /// @src 0:155:2411  "contract DataStructures {..."
                            let product := shl(1, value)
                            if iszero(or(iszero(value), eq(/** @src 0:1835:1836  "2" */ 0x02, /** @src 0:155:2411  "contract DataStructures {..." */ div(product, value))))
                            {
                                mstore(0, shl(224, 0x4e487b71))
                                mstore(4, 0x11)
                                revert(0, 36)
                            }
                            let value_1 := calldataload(/** @src 0:1838:1850  "arr[i].value" */ add(/** @src 0:1838:1844  "arr[i]" */ calldata_array_index_access_struct_SimpleStruct_calldata_dyn_calldata(arrayPos, length, var_i), /** @src 0:155:2411  "contract DataStructures {..." */ 32))
                            let product_1 := shl(1, value_1)
                            if iszero(or(iszero(value_1), eq(/** @src 0:1835:1836  "2" */ 0x02, /** @src 0:155:2411  "contract DataStructures {..." */ div(product_1, value_1))))
                            {
                                mstore(0, shl(224, 0x4e487b71))
                                mstore(4, 0x11)
                                revert(0, 36)
                            }
                            let memPtr_3 := mload(64)
                            finalize_allocation_4288(memPtr_3)
                            mstore(memPtr_3, product)
                            mstore(/** @src 0:1810:1855  "SimpleStruct(arr[i].id * 2, arr[i].value * 2)" */ add(memPtr_3, /** @src 0:155:2411  "contract DataStructures {..." */ 32), product_1)
                            /// @src 0:1798:1855  "result[i] = SimpleStruct(arr[i].id * 2, arr[i].value * 2)"
                            mstore(memory_array_index_access_struct_SimpleStruct_dyn(memPtr, var_i), memPtr_3)
                            pop(memory_array_index_access_struct_SimpleStruct_dyn(memPtr, var_i))
                        }
                        /// @src 0:155:2411  "contract DataStructures {..."
                        let memPos := mload(64)
                        let tail := add(memPos, 32)
                        mstore(memPos, 32)
                        let pos := tail
                        let length_1 := mload(memPtr)
                        mstore(tail, length_1)
                        pos := add(memPos, 64)
                        let srcPtr := add(memPtr, 32)
                        let i_1 := 0
                        for { } lt(i_1, length_1) { i_1 := add(i_1, 1) }
                        {
                            let _3 := mload(srcPtr)
                            mstore(pos, mload(_3))
                            mstore(add(pos, 32), mload(add(_3, 32)))
                            pos := add(pos, 64)
                            srcPtr := add(srcPtr, 32)
                        }
                        return(memPos, sub(pos, memPos))
                    }
                    case 0x4a0db301 {
                        if callvalue() { revert(0, 0) }
                        let _4 := slt(add(calldatasize(), not(3)), 64)
                        if _4 { revert(0, 0) }
                        _4 := 0
                        /// @src 0:1343:1364  "return s.id + s.value"
                        let var := /** @src 0:1350:1364  "s.id + s.value" */ checked_add_uint256(/** @src 0:155:2411  "contract DataStructures {..." */ calldataload(4), calldataload(/** @src 0:1357:1364  "s.value" */ 36))
                        /// @src 0:155:2411  "contract DataStructures {..."
                        let memPos_1 := mload(64)
                        mstore(memPos_1, var)
                        return(memPos_1, /** @src 0:1357:1364  "s.value" */ 32)
                    }
                    case /** @src 0:155:2411  "contract DataStructures {..." */ 0x890fa2fa {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        let offset_1 := calldataload(4)
                        if gt(offset_1, 0xffffffffffffffff) { revert(0, 0) }
                        let value0, value1 := abi_decode_bytes_calldata(add(4, offset_1), calldatasize())
                        let offset_2 := calldataload(36)
                        if gt(offset_2, 0xffffffffffffffff) { revert(0, 0) }
                        let value2, value3 := abi_decode_bytes_calldata(add(4, offset_2), calldatasize())
                        let outPtr := mload(64)
                        let _5 := add(outPtr, 32)
                        calldatacopy(_5, value0, value1)
                        let _6 := add(outPtr, value1)
                        let _7 := add(_6, 32)
                        mstore(_7, 0)
                        calldatacopy(_7, value2, value3)
                        let _8 := add(add(_6, value3), 32)
                        mstore(_8, 0)
                        let _9 := sub(_8, outPtr)
                        mstore(outPtr, add(_9, not(31)))
                        finalize_allocation(outPtr, _9)
                        let memPos_2 := mload(64)
                        mstore(memPos_2, 32)
                        let length_2 := mload(outPtr)
                        mstore(add(memPos_2, 32), length_2)
                        mcopy(add(memPos_2, 64), _5, length_2)
                        mstore(add(add(memPos_2, length_2), 64), 0)
                        return(memPos_2, add(sub(add(memPos_2, and(add(length_2, 31), not(31))), memPos_2), 64))
                    }
                    case 0xb3a72dd6 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let offset_3 := calldataload(4)
                        if gt(offset_3, 0xffffffffffffffff) { revert(0, 0) }
                        let value0_1, value1_1 := abi_decode_bytes_calldata(add(4, offset_3), calldatasize())
                        let memPos_3 := mload(64)
                        mstore(memPos_3, value1_1)
                        return(memPos_3, 32)
                    }
                    case 0xba373f8e {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        let value_2 := calldataload(4)
                        pop(allocate_and_zero_memory_struct_struct_SimpleStruct())
                        let memPtr_4 := mload(64)
                        finalize_allocation_4288(memPtr_4)
                        mstore(memPtr_4, value_2)
                        /// @src 0:1509:1532  "SimpleStruct(id, value)"
                        let _10 := add(memPtr_4, /** @src 0:155:2411  "contract DataStructures {..." */ 32)
                        mstore(_10, calldataload(36))
                        let memPos_4 := mload(64)
                        mstore(memPos_4, value_2)
                        mstore(add(memPos_4, 32), mload(_10))
                        return(memPos_4, 64)
                    }
                    case 0xd878faca {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 160) { revert(0, 0) }
                        if gt(164, calldatasize()) { revert(0, 0) }
                        /// @src 0:487:502  "uint256 sum = 0"
                        let var_sum := /** @src 0:155:2411  "contract DataStructures {..." */ 0
                        /// @src 0:517:530  "uint256 i = 0"
                        let var_i_1 := /** @src 0:155:2411  "contract DataStructures {..." */ 0
                        /// @src 0:512:582  "for (uint256 i = 0; i < 5; i++) {..."
                        for { }
                        /** @src 0:155:2411  "contract DataStructures {..." */ 1
                        /// @src 0:517:530  "uint256 i = 0"
                        {
                            /// @src 0:539:542  "i++"
                            var_i_1 := /** @src 0:155:2411  "contract DataStructures {..." */ add(/** @src 0:539:542  "i++" */ var_i_1, /** @src 0:155:2411  "contract DataStructures {..." */ 1)
                        }
                        /// @src 0:539:542  "i++"
                        {
                            /// @src 0:532:537  "i < 5"
                            let _11 := iszero(lt(var_i_1, /** @src 0:536:537  "5" */ 0x05))
                            /// @src 0:532:537  "i < 5"
                            if _11 { break }
                            /// @src 0:155:2411  "contract DataStructures {..."
                            _11 := 0
                            /// @src 0:558:571  "sum += arr[i]"
                            var_sum := checked_add_uint256(var_sum, /** @src 0:155:2411  "contract DataStructures {..." */ calldataload(add(4, shl(/** @src 0:536:537  "5" */ 0x05, /** @src 0:155:2411  "contract DataStructures {..." */ var_i_1))))
                        }
                        let memPos_5 := mload(64)
                        mstore(memPos_5, var_sum)
                        return(memPos_5, 32)
                    }
                    case 0xf82b8963 {
                        if callvalue() { revert(0, 0) }
                        let _12 := slt(add(calldatasize(), not(3)), 96)
                        if _12 { revert(0, 0) }
                        _12 := 0
                        /// @src 0:2055:2072  "n.id + n.inner.id"
                        let expr := checked_add_uint256(/** @src 0:155:2411  "contract DataStructures {..." */ calldataload(4), calldataload(/** @src 0:2062:2069  "n.inner" */ 36))
                        /// @src 0:2048:2088  "return n.id + n.inner.id + n.inner.value"
                        let var_1 := /** @src 0:2055:2088  "n.id + n.inner.id + n.inner.value" */ checked_add_uint256(expr, /** @src 0:155:2411  "contract DataStructures {..." */ calldataload(/** @src 0:2075:2088  "n.inner.value" */ 68))
                        /// @src 0:155:2411  "contract DataStructures {..."
                        let memPos_6 := mload(64)
                        mstore(memPos_6, var_1)
                        return(memPos_6, /** @src 0:2062:2069  "n.inner" */ 32)
                    }
                    case /** @src 0:155:2411  "contract DataStructures {..." */ 0xfbe73ab3 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let var_size := calldataload(4)
                        /// @src 0:998:1024  "if (size > 100) size = 100"
                        if /** @src 0:1002:1012  "size > 100" */ gt(var_size, /** @src 0:1009:1012  "100" */ 0x64)
                        /// @src 0:998:1024  "if (size > 100) size = 100"
                        {
                            /// @src 0:1014:1024  "size = 100"
                            var_size := /** @src 0:1009:1012  "100" */ 0x64
                        }
                        /// @src 0:155:2411  "contract DataStructures {..."
                        let _13 := array_allocation_size_array_struct_SimpleStruct_dyn(var_size)
                        let memPtr_5 := mload(64)
                        finalize_allocation(memPtr_5, _13)
                        mstore(memPtr_5, var_size)
                        let dataSize := array_allocation_size_array_struct_SimpleStruct_dyn(var_size)
                        let dataStart := add(memPtr_5, 32)
                        calldatacopy(dataStart, calldatasize(), add(dataSize, not(31)))
                        /// @src 0:1091:1104  "uint256 i = 0"
                        let var_i_2 := /** @src 0:155:2411  "contract DataStructures {..." */ 0
                        /// @src 0:1086:1160  "for (uint256 i = 0; i < size; i++) {..."
                        for { }
                        /** @src 0:1106:1114  "i < size" */ lt(var_i_2, var_size)
                        /// @src 0:1091:1104  "uint256 i = 0"
                        {
                            /// @src 0:1116:1119  "i++"
                            var_i_2 := /** @src 0:155:2411  "contract DataStructures {..." */ add(/** @src 0:1116:1119  "i++" */ var_i_2, /** @src 0:155:2411  "contract DataStructures {..." */ 1)
                        }
                        /// @src 0:1116:1119  "i++"
                        {
                            /// @src 0:155:2411  "contract DataStructures {..."
                            let product_2 := shl(1, var_i_2)
                            if iszero(or(iszero(var_i_2), eq(/** @src 0:1148:1149  "2" */ 0x02, /** @src 0:155:2411  "contract DataStructures {..." */ div(product_2, var_i_2))))
                            {
                                mstore(0, shl(224, 0x4e487b71))
                                mstore(4, 0x11)
                                revert(0, 0x24)
                            }
                            mstore(/** @src 0:1135:1149  "arr[i] = i * 2" */ memory_array_index_access_struct_SimpleStruct_dyn(memPtr_5, var_i_2), /** @src 0:155:2411  "contract DataStructures {..." */ product_2)
                        }
                        let memPos_7 := mload(64)
                        let tail_1 := add(memPos_7, 32)
                        mstore(memPos_7, 32)
                        let pos_1 := tail_1
                        let length_3 := mload(memPtr_5)
                        mstore(tail_1, length_3)
                        pos_1 := add(memPos_7, 64)
                        let srcPtr_1 := dataStart
                        let i_2 := 0
                        for { } lt(i_2, length_3) { i_2 := add(i_2, 1) }
                        {
                            mstore(pos_1, mload(srcPtr_1))
                            pos_1 := add(pos_1, 32)
                            srcPtr_1 := add(srcPtr_1, 32)
                        }
                        return(memPos_7, sub(pos_1, memPos_7))
                    }
                    case 0xfc2831d4 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let offset_4 := calldataload(4)
                        if gt(offset_4, 0xffffffffffffffff) { revert(0, 0) }
                        if iszero(slt(add(offset_4, 35), calldatasize())) { revert(0, 0) }
                        let length_4 := calldataload(add(4, offset_4))
                        if gt(length_4, 0xffffffffffffffff) { revert(0, 0) }
                        if gt(add(add(offset_4, shl(5, length_4)), 36), calldatasize()) { revert(0, 0) }
                        /// @src 0:762:777  "uint256 sum = 0"
                        let var_sum_1 := /** @src 0:155:2411  "contract DataStructures {..." */ 0
                        /// @src 0:792:805  "uint256 i = 0"
                        let var_i_3 := /** @src 0:155:2411  "contract DataStructures {..." */ 0
                        /// @src 0:787:866  "for (uint256 i = 0; i < arr.length; i++) {..."
                        for { }
                        /** @src 0:155:2411  "contract DataStructures {..." */ 1
                        /// @src 0:792:805  "uint256 i = 0"
                        {
                            /// @src 0:823:826  "i++"
                            var_i_3 := /** @src 0:155:2411  "contract DataStructures {..." */ add(/** @src 0:823:826  "i++" */ var_i_3, /** @src 0:155:2411  "contract DataStructures {..." */ 1)
                        }
                        /// @src 0:823:826  "i++"
                        {
                            /// @src 0:807:821  "i < arr.length"
                            let _14 := iszero(lt(var_i_3, /** @src 0:811:821  "arr.length" */ length_4))
                            /// @src 0:807:821  "i < arr.length"
                            if _14 { break }
                            /// @src 0:155:2411  "contract DataStructures {..."
                            _14 := 0
                            /// @src 0:842:855  "sum += arr[i]"
                            var_sum_1 := checked_add_uint256(var_sum_1, /** @src 0:155:2411  "contract DataStructures {..." */ calldataload(add(add(offset_4, shl(5, var_i_3)), 36)))
                        }
                        let memPos_8 := mload(64)
                        mstore(memPos_8, var_sum_1)
                        return(memPos_8, 32)
                    }
                }
                revert(0, 0)
            }
            function abi_decode_bytes_calldata(offset, end) -> arrayPos, length
            {
                if iszero(slt(add(offset, 0x1f), end)) { revert(0, 0) }
                length := calldataload(offset)
                if gt(length, 0xffffffffffffffff) { revert(0, 0) }
                arrayPos := add(offset, 0x20)
                if gt(add(add(offset, length), 0x20), end) { revert(0, 0) }
            }
            function finalize_allocation_4288(memPtr)
            {
                let newFreePtr := add(memPtr, 64)
                if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr))
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:155:2411  "contract DataStructures {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x41)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:155:2411  "contract DataStructures {..." */ 0x24)
                }
                mstore(64, newFreePtr)
            }
            function finalize_allocation(memPtr, size)
            {
                let newFreePtr := add(memPtr, and(add(size, 31), not(31)))
                if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr))
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:155:2411  "contract DataStructures {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x41)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:155:2411  "contract DataStructures {..." */ 0x24)
                }
                mstore(64, newFreePtr)
            }
            function array_allocation_size_array_struct_SimpleStruct_dyn(length) -> size
            {
                if gt(length, 0xffffffffffffffff)
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x41)
                    revert(0, 0x24)
                }
                size := add(shl(5, length), 0x20)
            }
            function allocate_and_zero_memory_struct_struct_SimpleStruct() -> memPtr
            {
                let memPtr_1 := mload(64)
                finalize_allocation_4288(memPtr_1)
                memPtr := memPtr_1
                mstore(memPtr_1, /** @src -1:-1:-1 */ 0)
                /// @src 0:155:2411  "contract DataStructures {..."
                mstore(add(memPtr_1, 32), /** @src -1:-1:-1 */ 0)
            }
            /// @src 0:155:2411  "contract DataStructures {..."
            function calldata_array_index_access_struct_SimpleStruct_calldata_dyn_calldata(base_ref, length, index) -> addr
            {
                if iszero(lt(index, length))
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x32)
                    revert(0, 0x24)
                }
                addr := add(base_ref, shl(6, index))
            }
            function memory_array_index_access_struct_SimpleStruct_dyn(baseRef, index) -> addr
            {
                if iszero(lt(index, mload(baseRef)))
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x32)
                    revert(0, 0x24)
                }
                addr := add(add(baseRef, shl(5, index)), 32)
            }
            function checked_add_uint256(x, y) -> sum
            {
                sum := add(x, y)
                if gt(x, sum)
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x11)
                    revert(0, 0x24)
                }
            }
        }
        data ".metadata" hex"a2646970667358221220be2fa7d33529dd39894fd197dbe694c09a153720b5424fced993093194dd1d6764736f6c634300081c0033"
    }
}