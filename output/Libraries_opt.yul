object "Libraries_741" {
    code {
        {
            /// @src 0:3080:6881  "contract Libraries {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("Libraries_741_deployed")
            codecopy(_1, dataoffset("Libraries_741_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/bench/Libraries.sol"
    object "Libraries_741_deployed" {
        code {
            {
                /// @src 0:3080:6881  "contract Libraries {..."
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x02dd56d0 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let ret := 0
                        let slotValue := sload(/** @src 0:3276:3302  "string public storedString" */ 1)
                        /// @src 0:3080:6881  "contract Libraries {..."
                        let length := 0
                        length := shr(/** @src 0:3276:3302  "string public storedString" */ 1, /** @src 0:3080:6881  "contract Libraries {..." */ slotValue)
                        let outOfPlaceEncoding := and(slotValue, /** @src 0:3276:3302  "string public storedString" */ 1)
                        /// @src 0:3080:6881  "contract Libraries {..."
                        if iszero(outOfPlaceEncoding) { length := and(length, 0x7f) }
                        if eq(outOfPlaceEncoding, lt(length, 32))
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x22)
                            revert(0, 0x24)
                        }
                        mstore(_1, length)
                        switch outOfPlaceEncoding
                        case 0 {
                            mstore(add(_1, 32), and(slotValue, not(255)))
                            ret := add(add(_1, shl(5, iszero(iszero(length)))), 32)
                        }
                        case 1 {
                            mstore(0, /** @src 0:3276:3302  "string public storedString" */ 1)
                            /// @src 0:3080:6881  "contract Libraries {..."
                            let dataPos := 80084422859880547211683076133703299733277748156566366325829078699459944778998
                            let i := 0
                            for { } lt(i, length) { i := add(i, 32) }
                            {
                                mstore(add(add(_1, i), 32), sload(dataPos))
                                dataPos := add(dataPos, /** @src 0:3276:3302  "string public storedString" */ 1)
                            }
                            /// @src 0:3080:6881  "contract Libraries {..."
                            ret := add(add(_1, i), 32)
                        }
                        finalize_allocation(_1, sub(ret, _1))
                        let memPos := mload(64)
                        mstore(memPos, 32)
                        return(memPos, sub(abi_encode_string(_1, add(memPos, 32)), memPos))
                    }
                    case 0x03df179c {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        /// @src 0:5736:5759  "storedValue.add(amount)"
                        let _2 := fun_add(/** @src 0:3080:6881  "contract Libraries {..." */ sload(0), calldataload(4))
                        sstore(0, _2)
                        let memPos_1 := mload(64)
                        mstore(memPos_1, _2)
                        return(memPos_1, 32)
                    }
                    case 0x04037b50 {
                        if callvalue() { revert(0, 0) }
                        let param, param_1 := abi_decode_uint256t_uint256(calldatasize())
                        /// @src 0:1046:1051  "b > 0"
                        let _3 := iszero(param_1)
                        /// @src 0:3080:6881  "contract Libraries {..."
                        if _3
                        {
                            let memPtr := mload(64)
                            mstore(memPtr, shl(229, 4594637))
                            mstore(add(memPtr, 4), 32)
                            mstore(add(memPtr, 36), 24)
                            mstore(add(memPtr, 68), "SafeMath: modulo by zero")
                            revert(memPtr, 100)
                        }
                        _3 := 0
                        let memPos_2 := mload(64)
                        mstore(memPos_2, mod(param, param_1))
                        return(memPos_2, 32)
                    }
                    case 0x0d336a21 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _4 := sload(0)
                        let memPos_3 := mload(64)
                        mstore(memPos_3, _4)
                        return(memPos_3, 32)
                    }
                    case 0x27b2b35d {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value := calldataload(4)
                        if iszero(eq(value, and(value, sub(shl(160, 1), 1)))) { revert(0, 0) }
                        /// @src 0:1809:1824  "return size > 0"
                        let var := /** @src 0:1816:1824  "size > 0" */ iszero(iszero(/** @src 0:1739:1800  "assembly {..." */ extcodesize(value)))
                        /// @src 0:3080:6881  "contract Libraries {..."
                        let memPos_4 := mload(64)
                        mstore(memPos_4, var)
                        return(memPos_4, 32)
                    }
                    case 0x3295425d {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        sstore(0, calldataload(4))
                        return(0, 0)
                    }
                    case 0x3721b1d8 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        /// @src 0:5888:5911  "storedValue.sub(amount)"
                        let _5 := fun_sub(/** @src 0:3080:6881  "contract Libraries {..." */ sload(0), calldataload(4))
                        sstore(0, _5)
                        let memPos_5 := mload(64)
                        mstore(memPos_5, _5)
                        return(memPos_5, 32)
                    }
                    case 0x3b3a7e31 {
                        if callvalue() { revert(0, 0) }
                        let param_2, param_3 := abi_decode_uint256t_uint256(calldatasize())
                        if /** @src 0:890:895  "b > 0" */ iszero(param_3)
                        /// @src 0:3080:6881  "contract Libraries {..."
                        {
                            let memPtr_1 := mload(64)
                            mstore(memPtr_1, shl(229, 4594637))
                            mstore(add(memPtr_1, 4), 32)
                            mstore(add(memPtr_1, 36), 26)
                            mstore(add(memPtr_1, 68), "SafeMath: division by zero")
                            revert(memPtr_1, 100)
                        }
                        /// @src 0:936:948  "return a / b"
                        let var_1 := /** @src 0:943:948  "a / b" */ checked_div_uint256(param_2, param_3)
                        /// @src 0:3080:6881  "contract Libraries {..."
                        let memPos_6 := mload(64)
                        mstore(memPos_6, var_1)
                        return(memPos_6, 32)
                    }
                    case 0x437da23e {
                        external_fun_directLibraryCall()
                    }
                    case 0x529486dd {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let offset := calldataload(4)
                        if gt(offset, 0xffffffffffffffff) { revert(0, 0) }
                        let value0, value1 := abi_decode_string_calldata(add(4, offset), calldatasize())
                        /// @src 0:1362:1389  "return bytes(s).length == 0"
                        let var_2 := /** @src 0:1369:1389  "bytes(s).length == 0" */ iszero(/** @src 0:3080:6881  "contract Libraries {..." */ mload(abi_decode_available_length_string(value0, value1, calldatasize())))
                        let memPos_7 := mload(64)
                        mstore(memPos_7, var_2)
                        return(memPos_7, 32)
                    }
                    case 0x6245a978 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let offset_1 := calldataload(4)
                        if gt(offset_1, 0xffffffffffffffff) { revert(0, 0) }
                        let value0_1, value1_1 := abi_decode_array_uint256_dyn_calldata(add(4, offset_1), calldatasize())
                        let ret_1 := /** @src 0:5270:5279  "arr.max()" */ fun_max(/** @src 0:3080:6881  "contract Libraries {..." */ abi_decode_available_length_array_uint256_dyn(value0_1, value1_1, calldatasize()))
                        let memPos_8 := mload(64)
                        mstore(memPos_8, ret_1)
                        return(memPos_8, 32)
                    }
                    case 0x6d619daa {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _6 := sload(0)
                        let memPos_9 := mload(64)
                        mstore(memPos_9, _6)
                        return(memPos_9, 32)
                    }
                    case 0x7c3ffef2 {
                        external_fun_directLibraryCall()
                    }
                    case 0x960f4743 {
                        if callvalue() { revert(0, 0) }
                        let param_4, param_5, param_6 := abi_decode_array_uint256_dyn_calldatat_uint256(calldatasize())
                        /// @src 0:6323:6359  "total = values.sum().mul(multiplier)"
                        let var_total := /** @src 0:6331:6359  "values.sum().mul(multiplier)" */ fun_mul(/** @src 0:6331:6343  "values.sum()" */ fun_sum(/** @src 0:3080:6881  "contract Libraries {..." */ abi_decode_available_length_array_uint256_dyn(/** @src 0:6331:6341  "values.sum" */ param_4, param_5, /** @src 0:3080:6881  "contract Libraries {..." */ calldatasize())), /** @src 0:6331:6359  "values.sum().mul(multiplier)" */ param_6)
                        /// @src 0:6369:6390  "maxVal = values.max()"
                        let var_maxVal := /** @src 0:6378:6390  "values.max()" */ fun_max(/** @src 0:3080:6881  "contract Libraries {..." */ abi_decode_available_length_array_uint256_dyn(/** @src 0:6378:6388  "values.max" */ param_4, param_5, /** @src 0:3080:6881  "contract Libraries {..." */ calldatasize()))
                        /// @src 0:6400:6421  "minVal = values.min()"
                        let var_minVal := /** @src 0:6409:6421  "values.min()" */ fun_min(/** @src 0:3080:6881  "contract Libraries {..." */ abi_decode_available_length_array_uint256_dyn(/** @src 0:6409:6419  "values.min" */ param_4, param_5, /** @src 0:3080:6881  "contract Libraries {..." */ calldatasize()))
                        let memPos_10 := mload(64)
                        mstore(memPos_10, var_total)
                        mstore(add(memPos_10, 32), var_maxVal)
                        mstore(add(memPos_10, 64), var_minVal)
                        return(memPos_10, 96)
                    }
                    case 0x966d3b3d {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 96) { revert(0, 0) }
                        let ret_2 := /** @src 0:4057:4072  "a.add(b.mul(c))" */ fun_add(/** @src 0:3080:6881  "contract Libraries {..." */ calldataload(4), /** @src 0:4063:4071  "b.mul(c)" */ fun_mul(/** @src 0:3080:6881  "contract Libraries {..." */ calldataload(36), calldataload(68)))
                        let memPos_11 := mload(64)
                        mstore(memPos_11, ret_2)
                        return(memPos_11, 32)
                    }
                    case 0xbac32a65 {
                        if callvalue() { revert(0, 0) }
                        let param_7, param_8, param_9 := abi_decode_array_uint256_dyn_calldatat_uint256(calldatasize())
                        let ret_3 := /** @src 0:5557:5576  "arr.contains(value)" */ fun_contains(/** @src 0:3080:6881  "contract Libraries {..." */ abi_decode_available_length_array_uint256_dyn(param_7, param_8, calldatasize()), param_9)
                        let memPos_12 := mload(64)
                        mstore(memPos_12, iszero(iszero(ret_3)))
                        return(memPos_12, 32)
                    }
                    case 0xbd2c7195 {
                        if callvalue() { revert(0, 0) }
                        let param_10, param_11 := abi_decode_uint256t_uint256(calldatasize())
                        let ret_4 := /** @src 0:3660:3668  "a.mul(b)" */ fun_mul(/** @src 0:3080:6881  "contract Libraries {..." */ param_10, param_11)
                        let memPos_13 := mload(64)
                        mstore(memPos_13, ret_4)
                        return(memPos_13, 32)
                    }
                    case 0xbe1beee0 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let offset_2 := calldataload(4)
                        if gt(offset_2, 0xffffffffffffffff) { revert(0, 0) }
                        let value0_2, value1_2 := abi_decode_array_uint256_dyn_calldata(add(4, offset_2), calldatasize())
                        let ret_5 := /** @src 0:5139:5148  "arr.sum()" */ fun_sum(/** @src 0:3080:6881  "contract Libraries {..." */ abi_decode_available_length_array_uint256_dyn(value0_2, value1_2, calldatasize()))
                        let memPos_14 := mload(64)
                        mstore(memPos_14, ret_5)
                        return(memPos_14, 32)
                    }
                    case 0xcea29937 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        /// @src 0:6039:6062  "storedValue.mul(factor)"
                        let _7 := fun_mul(/** @src 0:3080:6881  "contract Libraries {..." */ sload(0), calldataload(4))
                        sstore(0, _7)
                        let memPos_15 := mload(64)
                        mstore(memPos_15, _7)
                        return(memPos_15, 32)
                    }
                    case 0xd84da15f {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let offset_3 := calldataload(4)
                        if gt(offset_3, 0xffffffffffffffff) { revert(0, 0) }
                        let value0_3, value1_3 := abi_decode_string_calldata(add(4, offset_3), calldatasize())
                        /// @src 0:1254:1276  "return bytes(s).length"
                        let var_3 := /** @src 0:3080:6881  "contract Libraries {..." */ mload(abi_decode_available_length_string(value0_3, value1_3, calldatasize()))
                        let memPos_16 := mload(64)
                        mstore(memPos_16, var_3)
                        return(memPos_16, 32)
                    }
                    case 0xd9aa2494 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        let offset_4 := calldataload(4)
                        if gt(offset_4, 0xffffffffffffffff) { revert(0, 0) }
                        let value0_4, value1_4 := abi_decode_string_calldata(add(4, offset_4), calldatasize())
                        let offset_5 := calldataload(36)
                        if gt(offset_5, 0xffffffffffffffff) { revert(0, 0) }
                        let value2, value3 := abi_decode_string_calldata(add(4, offset_5), calldatasize())
                        /// @src 0:4659:4667  "a.equals"
                        let expr_self_mpos := /** @src 0:3080:6881  "contract Libraries {..." */ abi_decode_available_length_string(/** @src 0:4659:4667  "a.equals" */ value0_4, value1_4, /** @src 0:3080:6881  "contract Libraries {..." */ calldatasize())
                        let _8 := abi_decode_available_length_string(/** @src 0:4659:4670  "a.equals(b)" */ value2, value3, /** @src 0:3080:6881  "contract Libraries {..." */ calldatasize())
                        /// @src 0:1520:1539  "keccak256(bytes(a))"
                        let expr := keccak256(/** @src 0:3080:6881  "contract Libraries {..." */ add(/** @src 0:1520:1539  "keccak256(bytes(a))" */ expr_self_mpos, /** @src 0:3080:6881  "contract Libraries {..." */ 32), mload(/** @src 0:1520:1539  "keccak256(bytes(a))" */ expr_self_mpos))
                        /// @src 0:1513:1562  "return keccak256(bytes(a)) == keccak256(bytes(b))"
                        let var_4 := /** @src 0:1520:1562  "keccak256(bytes(a)) == keccak256(bytes(b))" */ eq(expr, /** @src 0:1543:1562  "keccak256(bytes(b))" */ keccak256(/** @src 0:3080:6881  "contract Libraries {..." */ add(/** @src 0:1543:1562  "keccak256(bytes(b))" */ _8, /** @src 0:3080:6881  "contract Libraries {..." */ 32), mload(/** @src 0:1543:1562  "keccak256(bytes(b))" */ _8)))
                        /// @src 0:3080:6881  "contract Libraries {..."
                        let memPos_17 := mload(64)
                        mstore(memPos_17, var_4)
                        return(memPos_17, 32)
                    }
                    case 0xdb0721d0 {
                        if callvalue() { revert(0, 0) }
                        let param_12, param_13 := abi_decode_uint256t_uint256(calldatasize())
                        let ret_6 := /** @src 0:3551:3559  "a.sub(b)" */ fun_sub(/** @src 0:3080:6881  "contract Libraries {..." */ param_12, param_13)
                        let memPos_18 := mload(64)
                        mstore(memPos_18, ret_6)
                        return(memPos_18, 32)
                    }
                    case 0xdd43d292 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value_1 := calldataload(4)
                        if iszero(eq(value_1, and(value_1, sub(shl(160, 1), 1)))) { revert(0, 0) }
                        /// @src 0:1919:1938  "abi.encodePacked(a)"
                        let expr_mpos := /** @src 0:3080:6881  "contract Libraries {..." */ mload(64)
                        mstore(/** @src 0:1919:1938  "abi.encodePacked(a)" */ add(expr_mpos, /** @src 0:3080:6881  "contract Libraries {..." */ 32), and(shl(96, value_1), not(0xffffffffffffffffffffffff)))
                        /// @src 0:1919:1938  "abi.encodePacked(a)"
                        mstore(expr_mpos, 20)
                        finalize_allocation(expr_mpos, 52)
                        /// @src 0:3080:6881  "contract Libraries {..."
                        let memPos_19 := mload(64)
                        mstore(memPos_19, 32)
                        return(memPos_19, sub(abi_encode_string(expr_mpos, add(memPos_19, 32)), memPos_19))
                    }
                    case 0xeec5de75 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value_2 := calldataload(4)
                        /// @src 0:4198:4207  "x.add(10)"
                        let var_5 := /** @src 0:3080:6881  "contract Libraries {..." */ 0
                        /// @src 0:330:335  "a + b"
                        let sum := /** @src 0:3080:6881  "contract Libraries {..." */ 0
                        sum := add(value_2, /** @src 0:4204:4206  "10" */ 0x0a)
                        /// @src 0:3080:6881  "contract Libraries {..."
                        if gt(value_2, sum)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        if /** @src 0:353:359  "c >= a" */ lt(sum, value_2)
                        /// @src 0:3080:6881  "contract Libraries {..."
                        {
                            let memPtr_2 := mload(64)
                            mstore(memPtr_2, shl(229, 4594637))
                            mstore(add(memPtr_2, 4), 32)
                            mstore(add(memPtr_2, 36), 27)
                            mstore(add(memPtr_2, 68), "SafeMath: addition overflow")
                            revert(memPtr_2, 100)
                        }
                        /// @src 0:401:409  "return c"
                        var_5 := sum
                        /// @src 0:4198:4214  "x.add(10).mul(2)"
                        let expr_1 := fun_mul_5958(sum)
                        /// @src 0:4198:4221  "x.add(10).mul(2).sub(5)"
                        let var_6 := /** @src 0:3080:6881  "contract Libraries {..." */ 0
                        if /** @src 0:507:513  "b <= a" */ gt(/** @src 0:4219:4220  "5" */ 0x05, /** @src 0:507:513  "b <= a" */ expr_1)
                        /// @src 0:3080:6881  "contract Libraries {..."
                        {
                            let memPtr_3 := mload(64)
                            mstore(memPtr_3, shl(229, 4594637))
                            mstore(add(memPtr_3, 4), 32)
                            mstore(add(memPtr_3, 36), 31)
                            mstore(add(memPtr_3, 68), "SafeMath: subtraction underflow")
                            revert(memPtr_3, 100)
                        }
                        let diff := add(expr_1, not(4))
                        if gt(diff, expr_1)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        /// @src 0:559:571  "return a - b"
                        var_6 := diff
                        /// @src 0:3080:6881  "contract Libraries {..."
                        let memPos_20 := mload(64)
                        mstore(memPos_20, diff)
                        return(memPos_20, 32)
                    }
                    case 0xf8b81edb {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let offset_6 := calldataload(4)
                        if gt(offset_6, 0xffffffffffffffff) { revert(0, 0) }
                        let value0_5, value1_5 := abi_decode_array_uint256_dyn_calldata(add(4, offset_6), calldatasize())
                        let ret_7 := /** @src 0:5401:5410  "arr.min()" */ fun_min(/** @src 0:3080:6881  "contract Libraries {..." */ abi_decode_available_length_array_uint256_dyn(value0_5, value1_5, calldatasize()))
                        let memPos_21 := mload(64)
                        mstore(memPos_21, ret_7)
                        return(memPos_21, 32)
                    }
                }
                revert(0, 0)
            }
            function finalize_allocation(memPtr, size)
            {
                let newFreePtr := add(memPtr, and(add(size, 31), not(31)))
                if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr))
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:3080:6881  "contract Libraries {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x41)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:3080:6881  "contract Libraries {..." */ 0x24)
                }
                mstore(64, newFreePtr)
            }
            function abi_encode_string(value, pos) -> end
            {
                let length := mload(value)
                mstore(pos, length)
                mcopy(add(pos, 0x20), add(value, 0x20), length)
                mstore(add(add(pos, length), 0x20), /** @src -1:-1:-1 */ 0)
                /// @src 0:3080:6881  "contract Libraries {..."
                end := add(add(pos, and(add(length, 31), not(31))), 0x20)
            }
            function abi_decode_uint256t_uint256(dataEnd) -> value0, value1
            {
                if slt(add(dataEnd, not(3)), 64) { revert(0, 0) }
                value0 := calldataload(4)
                value1 := calldataload(36)
            }
            function external_fun_directLibraryCall()
            {
                if callvalue() { revert(0, 0) }
                let param, param_1 := abi_decode_uint256t_uint256(calldatasize())
                let ret := /** @src 0:6621:6639  "SafeMath.add(a, b)" */ fun_add(/** @src 0:3080:6881  "contract Libraries {..." */ param, param_1)
                let memPos := mload(64)
                mstore(memPos, ret)
                return(memPos, 32)
            }
            function abi_decode_string_calldata(offset, end) -> arrayPos, length
            {
                if iszero(slt(add(offset, 0x1f), end)) { revert(0, 0) }
                length := calldataload(offset)
                if gt(length, 0xffffffffffffffff) { revert(0, 0) }
                arrayPos := add(offset, 0x20)
                if gt(add(add(offset, length), 0x20), end) { revert(0, 0) }
            }
            function abi_decode_array_uint256_dyn_calldata(offset, end) -> arrayPos, length
            {
                if iszero(slt(add(offset, 0x1f), end)) { revert(0, 0) }
                length := calldataload(offset)
                if gt(length, 0xffffffffffffffff) { revert(0, 0) }
                arrayPos := add(offset, 0x20)
                if gt(add(add(offset, shl(5, length)), 0x20), end) { revert(0, 0) }
            }
            function abi_decode_array_uint256_dyn_calldatat_uint256(dataEnd) -> value0, value1, value2
            {
                if slt(add(dataEnd, not(3)), 64) { revert(0, 0) }
                let offset := calldataload(4)
                if gt(offset, 0xffffffffffffffff) { revert(0, 0) }
                let value0_1, value1_1 := abi_decode_array_uint256_dyn_calldata(add(4, offset), dataEnd)
                value0 := value0_1
                value1 := value1_1
                value2 := calldataload(36)
            }
            function abi_decode_available_length_string(src, length, end) -> array
            {
                if gt(length, 0xffffffffffffffff)
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:3080:6881  "contract Libraries {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x41)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:3080:6881  "contract Libraries {..." */ 0x24)
                }
                let memPtr := mload(64)
                finalize_allocation(memPtr, add(and(add(length, 31), not(31)), 0x20))
                array := memPtr
                mstore(memPtr, length)
                if gt(add(src, length), end)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:3080:6881  "contract Libraries {..."
                calldatacopy(add(memPtr, 0x20), src, length)
                mstore(add(add(memPtr, length), 0x20), /** @src -1:-1:-1 */ 0)
            }
            /// @src 0:3080:6881  "contract Libraries {..."
            function abi_decode_available_length_array_uint256_dyn(offset, length, end) -> array
            {
                if gt(length, 0xffffffffffffffff)
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:3080:6881  "contract Libraries {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x41)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:3080:6881  "contract Libraries {..." */ 0x24)
                }
                let _1 := shl(5, length)
                let memPtr := mload(64)
                finalize_allocation(memPtr, add(_1, 0x20))
                array := memPtr
                let dst := memPtr
                mstore(memPtr, length)
                dst := add(memPtr, 0x20)
                let srcEnd := add(offset, _1)
                if gt(srcEnd, end)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:3080:6881  "contract Libraries {..."
                let src := offset
                for { } lt(src, srcEnd) { src := add(src, 0x20) }
                {
                    mstore(dst, calldataload(src))
                    dst := add(dst, 0x20)
                }
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
            /// @ast-id 27 @src 0:241:416  "function add(uint256 a, uint256 b) internal pure returns (uint256) {..."
            function fun_add(var_a, var_b) -> var
            {
                /// @src 0:330:335  "a + b"
                let expr := checked_add_uint256(var_a, var_b)
                /// @src 0:3080:6881  "contract Libraries {..."
                if /** @src 0:353:359  "c >= a" */ lt(expr, var_a)
                /// @src 0:3080:6881  "contract Libraries {..."
                {
                    let memPtr := mload(64)
                    mstore(memPtr, shl(229, 4594637))
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 27)
                    mstore(add(memPtr, 68), "SafeMath: addition overflow")
                    revert(memPtr, 100)
                }
                /// @src 0:401:409  "return c"
                var := expr
            }
            /// @ast-id 48 @src 0:422:578  "function sub(uint256 a, uint256 b) internal pure returns (uint256) {..."
            function fun_sub(var_a, var_b) -> var
            {
                /// @src 0:3080:6881  "contract Libraries {..."
                if /** @src 0:507:513  "b <= a" */ gt(var_b, var_a)
                /// @src 0:3080:6881  "contract Libraries {..."
                {
                    let memPtr := mload(64)
                    mstore(memPtr, shl(229, 4594637))
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 31)
                    mstore(add(memPtr, 68), "SafeMath: subtraction underflow")
                    revert(memPtr, 100)
                }
                let diff := sub(var_a, var_b)
                if gt(diff, var_a)
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:3080:6881  "contract Libraries {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x11)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:3080:6881  "contract Libraries {..." */ 0x24)
                }
                /// @src 0:559:571  "return a - b"
                var := diff
            }
            /// @src 0:3080:6881  "contract Libraries {..."
            function checked_div_uint256(x, y) -> r
            {
                if iszero(y)
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x12)
                    revert(0, 0x24)
                }
                r := div(x, y)
            }
            function require_helper_stringliteral_bf73(condition)
            {
                if iszero(condition)
                {
                    let memPtr := mload(64)
                    mstore(memPtr, shl(229, 4594637))
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 11)
                    mstore(add(memPtr, 68), "Empty array")
                    revert(memPtr, 100)
                }
            }
            function memory_array_index_access_uint256_dyn_5974(baseRef) -> addr
            {
                if iszero(mload(baseRef))
                {
                    mstore(/** @src 0:2294:2295  "0" */ 0x00, /** @src 0:3080:6881  "contract Libraries {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x32)
                    revert(/** @src 0:2294:2295  "0" */ 0x00, /** @src 0:3080:6881  "contract Libraries {..." */ 0x24)
                }
                addr := add(baseRef, 32)
            }
            function memory_array_index_access_uint256_dyn(baseRef, index) -> addr
            {
                if iszero(lt(index, mload(baseRef)))
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x32)
                    revert(0, 0x24)
                }
                addr := add(add(baseRef, shl(5, index)), 32)
            }
            /// @ast-id 286 @src 0:2189:2486  "function max(uint256[] memory arr) internal pure returns (uint256 maxVal) {..."
            function fun_max(var_arr_240_mpos) -> var_maxVal
            {
                /// @src 0:2273:2311  "require(arr.length > 0, \"Empty array\")"
                require_helper_stringliteral_bf73(/** @src 0:2281:2295  "arr.length > 0" */ iszero(iszero(/** @src 0:3080:6881  "contract Libraries {..." */ mload(/** @src 0:2281:2291  "arr.length" */ var_arr_240_mpos))))
                /// @src 0:2321:2336  "maxVal = arr[0]"
                var_maxVal := /** @src 0:3080:6881  "contract Libraries {..." */ mload(/** @src 0:2330:2336  "arr[0]" */ memory_array_index_access_uint256_dyn_5974(var_arr_240_mpos))
                /// @src 0:2351:2364  "uint256 i = 1"
                let var_i := /** @src 0:2363:2364  "1" */ 0x01
                /// @src 0:2346:2480  "for (uint256 i = 1; i < arr.length; i++) {..."
                for { }
                /** @src 0:2363:2364  "1" */ 0x01
                /// @src 0:2351:2364  "uint256 i = 1"
                {
                    /// @src 0:2382:2385  "i++"
                    var_i := /** @src 0:3080:6881  "contract Libraries {..." */ add(/** @src 0:2382:2385  "i++" */ var_i, /** @src 0:2363:2364  "1" */ 0x01)
                }
                /// @src 0:2382:2385  "i++"
                {
                    /// @src 0:2366:2380  "i < arr.length"
                    if iszero(lt(var_i, /** @src 0:3080:6881  "contract Libraries {..." */ mload(/** @src 0:2370:2380  "arr.length" */ var_arr_240_mpos)))
                    /// @src 0:2366:2380  "i < arr.length"
                    { break }
                    /// @src 0:2401:2470  "if (arr[i] > maxVal) {..."
                    if /** @src 0:2405:2420  "arr[i] > maxVal" */ gt(/** @src 0:3080:6881  "contract Libraries {..." */ mload(/** @src 0:2405:2411  "arr[i]" */ memory_array_index_access_uint256_dyn(var_arr_240_mpos, var_i)), /** @src 0:2405:2420  "arr[i] > maxVal" */ var_maxVal)
                    /// @src 0:2401:2470  "if (arr[i] > maxVal) {..."
                    {
                        /// @src 0:2440:2455  "maxVal = arr[i]"
                        var_maxVal := /** @src 0:3080:6881  "contract Libraries {..." */ mload(/** @src 0:2449:2455  "arr[i]" */ memory_array_index_access_uint256_dyn(var_arr_240_mpos, var_i))
                    }
                }
            }
            /// @ast-id 237 @src 0:2013:2183  "function sum(uint256[] memory arr) internal pure returns (uint256 total) {..."
            function fun_sum(var_arr_212_mpos) -> var_total
            {
                /// @src 0:2071:2084  "uint256 total"
                var_total := /** @src 0:3080:6881  "contract Libraries {..." */ 0
                /// @src 0:2101:2114  "uint256 i = 0"
                let var_i := /** @src 0:3080:6881  "contract Libraries {..." */ 0
                /// @src 0:2096:2177  "for (uint256 i = 0; i < arr.length; i++) {..."
                for { }
                /** @src 0:3080:6881  "contract Libraries {..." */ 1
                /// @src 0:2101:2114  "uint256 i = 0"
                {
                    /// @src 0:2132:2135  "i++"
                    var_i := /** @src 0:3080:6881  "contract Libraries {..." */ add(/** @src 0:2132:2135  "i++" */ var_i, /** @src 0:3080:6881  "contract Libraries {..." */ 1)
                }
                /// @src 0:2132:2135  "i++"
                {
                    /// @src 0:2116:2130  "i < arr.length"
                    if iszero(lt(var_i, /** @src 0:3080:6881  "contract Libraries {..." */ mload(/** @src 0:2120:2130  "arr.length" */ var_arr_212_mpos)))
                    /// @src 0:2116:2130  "i < arr.length"
                    { break }
                    /// @src 0:2151:2166  "total += arr[i]"
                    var_total := checked_add_uint256(var_total, /** @src 0:3080:6881  "contract Libraries {..." */ mload(/** @src 0:2160:2166  "arr[i]" */ memory_array_index_access_uint256_dyn(var_arr_212_mpos, var_i)))
                }
            }
            /// @ast-id 81 @src 0:584:799  "function mul(uint256 a, uint256 b) internal pure returns (uint256) {..."
            function fun_mul_5958(var_a) -> var
            {
                /// @src 0:642:649  "uint256"
                var := /** @src 0:3080:6881  "contract Libraries {..." */ 0
                /// @src 0:661:681  "if (a == 0) return 0"
                if /** @src 0:665:671  "a == 0" */ iszero(var_a)
                /// @src 0:661:681  "if (a == 0) return 0"
                {
                    /// @src 0:673:681  "return 0"
                    var := /** @src 0:3080:6881  "contract Libraries {..." */ 0
                    /// @src 0:673:681  "return 0"
                    leave
                }
                /// @src 0:3080:6881  "contract Libraries {..."
                let product := shl(1, var_a)
                if iszero(eq(/** @src 0:4212:4213  "2" */ 0x02, /** @src 0:3080:6881  "contract Libraries {..." */ div(product, var_a)))
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x11)
                    revert(0, 0x24)
                }
                if iszero(/** @src 0:726:736  "c / a == b" */ eq(/** @src 0:726:731  "c / a" */ checked_div_uint256(product, var_a), /** @src 0:4212:4213  "2" */ 0x02))
                /// @src 0:3080:6881  "contract Libraries {..."
                {
                    let memPtr := mload(64)
                    mstore(memPtr, shl(229, 4594637))
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 33)
                    mstore(add(memPtr, 68), "SafeMath: multiplication overflo")
                    mstore(add(memPtr, 100), "w")
                    revert(memPtr, 132)
                }
                /// @src 0:784:792  "return c"
                var := product
            }
            /// @ast-id 81 @src 0:584:799  "function mul(uint256 a, uint256 b) internal pure returns (uint256) {..."
            function fun_mul(var_a, var_b) -> var
            {
                /// @src 0:642:649  "uint256"
                var := /** @src 0:3080:6881  "contract Libraries {..." */ 0
                /// @src 0:661:681  "if (a == 0) return 0"
                if /** @src 0:665:671  "a == 0" */ iszero(var_a)
                /// @src 0:661:681  "if (a == 0) return 0"
                {
                    /// @src 0:673:681  "return 0"
                    var := /** @src 0:3080:6881  "contract Libraries {..." */ 0
                    /// @src 0:673:681  "return 0"
                    leave
                }
                /// @src 0:3080:6881  "contract Libraries {..."
                let product := mul(var_a, var_b)
                if iszero(eq(var_b, div(product, var_a)))
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x11)
                    revert(0, 0x24)
                }
                if iszero(/** @src 0:726:736  "c / a == b" */ eq(/** @src 0:726:731  "c / a" */ checked_div_uint256(product, var_a), /** @src 0:726:736  "c / a == b" */ var_b))
                /// @src 0:3080:6881  "contract Libraries {..."
                {
                    let memPtr := mload(64)
                    mstore(memPtr, shl(229, 4594637))
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 33)
                    mstore(add(memPtr, 68), "SafeMath: multiplication overflo")
                    mstore(add(memPtr, 100), "w")
                    revert(memPtr, 132)
                }
                /// @src 0:784:792  "return c"
                var := product
            }
            /// @ast-id 335 @src 0:2492:2789  "function min(uint256[] memory arr) internal pure returns (uint256 minVal) {..."
            function fun_min(var_arr_289_mpos) -> var_minVal
            {
                /// @src 0:2576:2614  "require(arr.length > 0, \"Empty array\")"
                require_helper_stringliteral_bf73(/** @src 0:2584:2598  "arr.length > 0" */ iszero(iszero(/** @src 0:3080:6881  "contract Libraries {..." */ mload(/** @src 0:2584:2594  "arr.length" */ var_arr_289_mpos))))
                /// @src 0:2624:2639  "minVal = arr[0]"
                var_minVal := /** @src 0:3080:6881  "contract Libraries {..." */ mload(/** @src 0:2633:2639  "arr[0]" */ memory_array_index_access_uint256_dyn_5974(var_arr_289_mpos))
                /// @src 0:2654:2667  "uint256 i = 1"
                let var_i := /** @src 0:2666:2667  "1" */ 0x01
                /// @src 0:2649:2783  "for (uint256 i = 1; i < arr.length; i++) {..."
                for { }
                /** @src 0:2666:2667  "1" */ 0x01
                /// @src 0:2654:2667  "uint256 i = 1"
                {
                    /// @src 0:2685:2688  "i++"
                    var_i := /** @src 0:3080:6881  "contract Libraries {..." */ add(/** @src 0:2685:2688  "i++" */ var_i, /** @src 0:2666:2667  "1" */ 0x01)
                }
                /// @src 0:2685:2688  "i++"
                {
                    /// @src 0:2669:2683  "i < arr.length"
                    if iszero(lt(var_i, /** @src 0:3080:6881  "contract Libraries {..." */ mload(/** @src 0:2673:2683  "arr.length" */ var_arr_289_mpos)))
                    /// @src 0:2669:2683  "i < arr.length"
                    { break }
                    /// @src 0:2704:2773  "if (arr[i] < minVal) {..."
                    if /** @src 0:2708:2723  "arr[i] < minVal" */ lt(/** @src 0:3080:6881  "contract Libraries {..." */ mload(/** @src 0:2708:2714  "arr[i]" */ memory_array_index_access_uint256_dyn(var_arr_289_mpos, var_i)), /** @src 0:2708:2723  "arr[i] < minVal" */ var_minVal)
                    /// @src 0:2704:2773  "if (arr[i] < minVal) {..."
                    {
                        /// @src 0:2743:2758  "minVal = arr[i]"
                        var_minVal := /** @src 0:3080:6881  "contract Libraries {..." */ mload(/** @src 0:2752:2758  "arr[i]" */ memory_array_index_access_uint256_dyn(var_arr_289_mpos, var_i))
                    }
                }
            }
            /// @ast-id 369 @src 0:2795:3037  "function contains(..."
            function fun_contains(var_arr_mpos, var_value) -> var
            {
                /// @src 0:2895:2899  "bool"
                var := /** @src 0:3080:6881  "contract Libraries {..." */ 0
                /// @src 0:2916:2929  "uint256 i = 0"
                let var_i := /** @src 0:3080:6881  "contract Libraries {..." */ 0
                /// @src 0:2911:3009  "for (uint256 i = 0; i < arr.length; i++) {..."
                for { }
                /** @src 0:3080:6881  "contract Libraries {..." */ 1
                /// @src 0:2916:2929  "uint256 i = 0"
                {
                    /// @src 0:2947:2950  "i++"
                    var_i := /** @src 0:3080:6881  "contract Libraries {..." */ add(/** @src 0:2947:2950  "i++" */ var_i, /** @src 0:3080:6881  "contract Libraries {..." */ 1)
                }
                /// @src 0:2947:2950  "i++"
                {
                    /// @src 0:2931:2945  "i < arr.length"
                    if iszero(lt(var_i, /** @src 0:3080:6881  "contract Libraries {..." */ mload(/** @src 0:2935:2945  "arr.length" */ var_arr_mpos)))
                    /// @src 0:2931:2945  "i < arr.length"
                    { break }
                    /// @src 0:2966:2998  "if (arr[i] == value) return true"
                    if /** @src 0:2970:2985  "arr[i] == value" */ eq(/** @src 0:3080:6881  "contract Libraries {..." */ mload(/** @src 0:2970:2976  "arr[i]" */ memory_array_index_access_uint256_dyn(var_arr_mpos, var_i)), /** @src 0:2970:2985  "arr[i] == value" */ var_value)
                    /// @src 0:2966:2998  "if (arr[i] == value) return true"
                    {
                        /// @src 0:2987:2998  "return true"
                        var := /** @src 0:3080:6881  "contract Libraries {..." */ 1
                        /// @src 0:2987:2998  "return true"
                        leave
                    }
                }
                /// @src 0:3018:3030  "return false"
                var := /** @src 0:3080:6881  "contract Libraries {..." */ 0
            }
        }
        data ".metadata" hex"a26469706673582212201ee1747c0eddbec7c58a197a6c826ad09a30345347c61848c79ef64ff7d988fc64736f6c634300081c0033"
    }
}