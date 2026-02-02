object "AdvancedFeatures_532" {
    code {
        {
            /// @src 0:629:5407  "contract AdvancedFeatures {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("AdvancedFeatures_532_deployed")
            codecopy(_1, dataoffset("AdvancedFeatures_532_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/bench/AdvancedFeatures.sol"
    object "AdvancedFeatures_532_deployed" {
        code {
            {
                /// @src 0:629:5407  "contract AdvancedFeatures {..."
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x01173a74 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value0 := abi_decode_address()
                        let _2 := sload(0)
                        let sum := add(_2, /** @src 0:976:977  "1" */ 0x01)
                        /// @src 0:629:5407  "contract AdvancedFeatures {..."
                        if gt(_2, sum)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        sstore(0, sum)
                        mstore(0, sum)
                        mstore(32, /** @src 0:976:977  "1" */ 0x01)
                        /// @src 0:629:5407  "contract AdvancedFeatures {..."
                        let dataSlot := keccak256(0, 64)
                        sstore(dataSlot, or(and(sload(dataSlot), shl(160, 0xffffffffffffffffffffffff)), and(value0, sub(shl(160, 1), 1))))
                        mstore(_1, sum)
                        return(_1, 32)
                    }
                    case 0x11234027 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        let value := 0
                        value := calldataload(36)
                        let _3 := and(value, 0xff)
                        if iszero(eq(value, _3)) { revert(0, 0) }
                        let _4 := iszero(/** @src 0:4563:4573  "index < 32" */ lt(/** @src 0:629:5407  "contract AdvancedFeatures {..." */ _3, 32))
                        if _4
                        {
                            let memPtr := mload(64)
                            mstore(memPtr, shl(229, 4594637))
                            mstore(add(memPtr, 4), 32)
                            mstore(add(memPtr, 36), 19)
                            mstore(add(memPtr, 68), "Index out of bounds")
                            revert(memPtr, 100)
                        }
                        /// @src 0:4614:4625  "data[index]"
                        _4 := /** @src 0:629:5407  "contract AdvancedFeatures {..." */ 0
                        let memPos := mload(64)
                        mstore(memPos, and(shl(248, /** @src 0:4614:4625  "data[index]" */ byte(_3, /** @src 0:629:5407  "contract AdvancedFeatures {..." */ calldataload(4))), shl(248, 255)))
                        return(memPos, 32)
                    }
                    case 0x12600aa3 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        let offset := calldataload(4)
                        if gt(offset, 0xffffffffffffffff) { revert(0, 0) }
                        let value0_1, value1 := abi_decode_string_calldata(add(4, offset), calldatasize())
                        let offset_1 := calldataload(36)
                        if gt(offset_1, 0xffffffffffffffff) { revert(0, 0) }
                        let value2, value3 := abi_decode_string_calldata(add(4, offset_1), calldatasize())
                        let outPtr := mload(64)
                        calldatacopy(add(outPtr, 32), value0_1, value1)
                        let _5 := add(outPtr, value1)
                        let _6 := add(_5, 32)
                        mstore(_6, 0)
                        calldatacopy(_6, value2, value3)
                        let _7 := add(add(_5, value3), 32)
                        mstore(_7, 0)
                        let _8 := sub(_7, outPtr)
                        mstore(outPtr, add(_8, not(31)))
                        finalize_allocation(outPtr, _8)
                        let memPos_1 := mload(64)
                        mstore(memPos_1, 32)
                        return(memPos_1, sub(abi_encode_string(outPtr, add(memPos_1, 32)), memPos_1))
                    }
                    case 0x22644a65 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value_1 := calldataload(4)
                        if iszero(eq(value_1, and(value_1, shl(240, 65535)))) { revert(0, 0) }
                        let _9 := sload(/** @src 0:2918:2936  "storedBytes2 = val" */ 0x03)
                        /// @src 0:629:5407  "contract AdvancedFeatures {..."
                        sstore(/** @src 0:2918:2936  "storedBytes2 = val" */ 0x03, /** @src 0:629:5407  "contract AdvancedFeatures {..." */ or(and(_9, not(16776960)), and(and(shr(232, value_1), 16776960), 16776960)))
                        return(0, 0)
                    }
                    case 0x353ab14a {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value_2 := calldataload(4)
                        if iszero(eq(value_2, and(value_2, not(0xffffffffffffffffffffffffffffffff)))) { revert(0, 0) }
                        let _10 := sload(/** @src 0:3163:3182  "storedBytes16 = val" */ 0x03)
                        /// @src 0:629:5407  "contract AdvancedFeatures {..."
                        sstore(/** @src 0:3163:3182  "storedBytes16 = val" */ 0x03, /** @src 0:629:5407  "contract AdvancedFeatures {..." */ or(and(_10, not(shl(120, 0xffffffffffffffffffffffffffffffff))), and(and(shr(8, value_2), shl(120, 0xffffffffffffffffffffffffffffffff)), shl(120, 0xffffffffffffffffffffffffffffffff))))
                        return(0, 0)
                    }
                    case 0x40de3a99 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        let value0_2 := abi_decode_bytes4()
                        let ret := /** @src 0:4316:4321  "a | b" */ or(/** @src 0:629:5407  "contract AdvancedFeatures {..." */ value0_2, abi_decode_t_bytes4())
                        let memPos_2 := mload(64)
                        mstore(memPos_2, and(ret, shl(224, 0xffffffff)))
                        return(memPos_2, 32)
                    }
                    case 0x5b07c279 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let value_3 := and(shl(232, sload(/** @src 0:2588:2614  "bytes2 public storedBytes2" */ 3)), /** @src 0:629:5407  "contract AdvancedFeatures {..." */ shl(240, 65535))
                        let memPos_3 := mload(64)
                        mstore(memPos_3, value_3)
                        return(memPos_3, 32)
                    }
                    case 0x5b2cb185 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        let value0_3 := abi_decode_address()
                        /// @src 0:2430:2490  "abi.encodeWithSelector(IERC20.transfer.selector, to, amount)"
                        let expr_mpos := /** @src 0:629:5407  "contract AdvancedFeatures {..." */ mload(64)
                        /// @src 0:2430:2490  "abi.encodeWithSelector(IERC20.transfer.selector, to, amount)"
                        mstore(add(expr_mpos, /** @src 0:629:5407  "contract AdvancedFeatures {..." */ 32), /** @src 0:2453:2477  "IERC20.transfer.selector" */ shl(224, 0xa9059cbb))
                        /// @src 0:2430:2490  "abi.encodeWithSelector(IERC20.transfer.selector, to, amount)"
                        let _11 := sub(abi_encode_address_uint256(add(expr_mpos, /** @src 0:629:5407  "contract AdvancedFeatures {..." */ 36), /** @src 0:2430:2490  "abi.encodeWithSelector(IERC20.transfer.selector, to, amount)" */ value0_3, /** @src 0:629:5407  "contract AdvancedFeatures {..." */ calldataload(36)), /** @src 0:2430:2490  "abi.encodeWithSelector(IERC20.transfer.selector, to, amount)" */ expr_mpos)
                        mstore(expr_mpos, add(_11, /** @src 0:629:5407  "contract AdvancedFeatures {..." */ not(31)))
                        /// @src 0:2430:2490  "abi.encodeWithSelector(IERC20.transfer.selector, to, amount)"
                        finalize_allocation(expr_mpos, _11)
                        /// @src 0:629:5407  "contract AdvancedFeatures {..."
                        let memPos_4 := mload(64)
                        mstore(memPos_4, 32)
                        return(memPos_4, sub(abi_encode_string(expr_mpos, add(memPos_4, 32)), memPos_4))
                    }
                    case 0x5c4fb26a {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value0_4 := abi_decode_bytes4()
                        let _12 := sload(/** @src 0:2999:3017  "storedBytes4 = val" */ 0x03)
                        /// @src 0:629:5407  "contract AdvancedFeatures {..."
                        sstore(/** @src 0:2999:3017  "storedBytes4 = val" */ 0x03, /** @src 0:629:5407  "contract AdvancedFeatures {..." */ or(and(_12, not(0xffffffff000000)), and(and(shr(200, value0_4), 0xffffffff000000), 0xffffffff000000)))
                        return(0, 0)
                    }
                    case 0x5dfd1e7f {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let value_4 := shl(96, sload(4))
                        let memPos_5 := mload(64)
                        mstore(memPos_5, and(value_4, not(0xffffffffffffffffffffffff)))
                        return(memPos_5, 32)
                    }
                    case 0x69faf070 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        let value0_5 := abi_decode_bytes1()
                        let value_5 := 0
                        value_5 := calldataload(36)
                        let _13 := and(value_5, shl(248, 255))
                        if iszero(eq(value_5, _13)) { revert(0, 0) }
                        let outPtr_1 := mload(64)
                        mstore(add(outPtr_1, 32), and(value0_5, shl(248, 255)))
                        mstore(add(outPtr_1, 33), _13)
                        mstore(outPtr_1, 2)
                        finalize_allocation(outPtr_1, 34)
                        let memPos_6 := mload(64)
                        mstore(memPos_6, 32)
                        return(memPos_6, sub(abi_encode_string(outPtr_1, add(memPos_6, 32)), memPos_6))
                    }
                    case 0x6d2a02e4 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value_6 := 0
                        value_6 := calldataload(4)
                        if iszero(eq(value_6, and(value_6, shl(192, 0xffffffffffffffff)))) { revert(0, 0) }
                        let _14 := sload(/** @src 0:3080:3098  "storedBytes8 = val" */ 0x03)
                        /// @src 0:629:5407  "contract AdvancedFeatures {..."
                        sstore(/** @src 0:3080:3098  "storedBytes8 = val" */ 0x03, /** @src 0:629:5407  "contract AdvancedFeatures {..." */ or(and(_14, not(0xffffffffffffffff00000000000000)), and(and(shr(136, value_6), 0xffffffffffffffff00000000000000), 0xffffffffffffffff00000000000000)))
                        return(0, 0)
                    }
                    case 0x74966327 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let value_7 := and(shl(200, sload(/** @src 0:2620:2646  "bytes4 public storedBytes4" */ 3)), /** @src 0:629:5407  "contract AdvancedFeatures {..." */ shl(224, 0xffffffff))
                        let memPos_7 := mload(64)
                        mstore(memPos_7, value_7)
                        return(memPos_7, 32)
                    }
                    case 0x8b41ae77 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value0_6 := abi_decode_address()
                        /// @src 0:2204:2247  "abi.encodeCall(IERC20.balanceOf, (account))"
                        let expr_mpos_1 := /** @src 0:629:5407  "contract AdvancedFeatures {..." */ mload(64)
                        /// @src 0:2204:2247  "abi.encodeCall(IERC20.balanceOf, (account))"
                        mstore(add(expr_mpos_1, /** @src 0:629:5407  "contract AdvancedFeatures {..." */ 32), /** @src 0:2204:2247  "abi.encodeCall(IERC20.balanceOf, (account))" */ shl(224, 0x70a08231))
                        /// @src 0:629:5407  "contract AdvancedFeatures {..."
                        mstore(/** @src 0:2204:2247  "abi.encodeCall(IERC20.balanceOf, (account))" */ add(expr_mpos_1, 36), /** @src 0:629:5407  "contract AdvancedFeatures {..." */ and(value0_6, sub(shl(160, 1), 1)))
                        /// @src 0:2204:2247  "abi.encodeCall(IERC20.balanceOf, (account))"
                        mstore(expr_mpos_1, 36)
                        finalize_allocation(expr_mpos_1, 68)
                        /// @src 0:629:5407  "contract AdvancedFeatures {..."
                        let memPos_8 := mload(64)
                        mstore(memPos_8, 32)
                        return(memPos_8, sub(abi_encode_string(expr_mpos_1, add(memPos_8, 32)), memPos_8))
                    }
                    case 0x900112ec {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        mstore(0, and(abi_decode_address(), sub(shl(160, 1), 1)))
                        mstore(32, /** @src 0:800:845  "mapping(address => Amount) public userAmounts" */ 2)
                        /// @src 0:629:5407  "contract AdvancedFeatures {..."
                        let value_8 := and(sload(keccak256(0, 64)), 0xffffffffffffffffffffffffffffffff)
                        let memPos_9 := mload(64)
                        mstore(memPos_9, value_8)
                        return(memPos_9, 32)
                    }
                    case 0x93ef981b {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let value_9 := and(shl(136, sload(/** @src 0:2652:2678  "bytes8 public storedBytes8" */ 3)), /** @src 0:629:5407  "contract AdvancedFeatures {..." */ shl(192, 0xffffffffffffffff))
                        let memPos_10 := mload(64)
                        mstore(memPos_10, value_9)
                        return(memPos_10, 32)
                    }
                    case 0x95c955ac {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value_10 := calldataload(4)
                        if iszero(eq(value_10, and(value_10, not(0xffffffffffffffffffffffff)))) { revert(0, 0) }
                        sstore(4, or(and(sload(4), shl(160, 0xffffffffffffffffffffffff)), shr(96, value_10)))
                        return(0, 0)
                    }
                    case 0x9a0363bb {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _15 := sload(/** @src 0:2752:2780  "bytes32 public storedBytes32" */ 5)
                        /// @src 0:629:5407  "contract AdvancedFeatures {..."
                        let memPos_11 := mload(64)
                        mstore(memPos_11, _15)
                        return(memPos_11, 32)
                    }
                    case 0xa49dc474 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        let value0_7 := abi_decode_bytes4()
                        let ret_1 := /** @src 0:4212:4217  "a & b" */ and(/** @src 0:629:5407  "contract AdvancedFeatures {..." */ value0_7, abi_decode_t_bytes4())
                        let memPos_12 := mload(64)
                        mstore(memPos_12, and(ret_1, shl(224, 0xffffffff)))
                        return(memPos_12, 32)
                    }
                    case 0xa5cd761f {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        mstore(0, calldataload(4))
                        mstore(32, 1)
                        let value_11 := and(sload(keccak256(0, 64)), sub(shl(160, 1), 1))
                        let memPos_13 := mload(64)
                        mstore(memPos_13, value_11)
                        return(memPos_13, 32)
                    }
                    case 0xa907cd9c {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        let value0_8 := abi_decode_address()
                        /// @src 0:1842:1887  "abi.encodeCall(IERC20.transfer, (to, amount))"
                        let expr_mpos_2 := /** @src 0:629:5407  "contract AdvancedFeatures {..." */ mload(64)
                        /// @src 0:1842:1887  "abi.encodeCall(IERC20.transfer, (to, amount))"
                        mstore(add(expr_mpos_2, /** @src 0:629:5407  "contract AdvancedFeatures {..." */ 32), /** @src 0:2453:2477  "IERC20.transfer.selector" */ shl(224, 0xa9059cbb))
                        /// @src 0:1842:1887  "abi.encodeCall(IERC20.transfer, (to, amount))"
                        let _16 := sub(abi_encode_address_uint256(add(expr_mpos_2, /** @src 0:629:5407  "contract AdvancedFeatures {..." */ 36), /** @src 0:1842:1887  "abi.encodeCall(IERC20.transfer, (to, amount))" */ value0_8, /** @src 0:629:5407  "contract AdvancedFeatures {..." */ calldataload(36)), /** @src 0:1842:1887  "abi.encodeCall(IERC20.transfer, (to, amount))" */ expr_mpos_2)
                        mstore(expr_mpos_2, add(_16, /** @src 0:629:5407  "contract AdvancedFeatures {..." */ not(31)))
                        /// @src 0:1842:1887  "abi.encodeCall(IERC20.transfer, (to, amount))"
                        finalize_allocation(expr_mpos_2, _16)
                        /// @src 0:629:5407  "contract AdvancedFeatures {..."
                        let memPos_14 := mload(64)
                        mstore(memPos_14, 32)
                        return(memPos_14, sub(abi_encode_string(expr_mpos_2, add(memPos_14, 32)), memPos_14))
                    }
                    case 0xbb3ad3aa {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let _17 := and(shl(96, abi_decode_address()), not(0xffffffffffffffffffffffff))
                        let memPos_15 := mload(64)
                        mstore(memPos_15, _17)
                        return(memPos_15, 32)
                    }
                    case 0xbce46c6a {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let memPos_16 := mload(64)
                        mstore(memPos_16, and(calldataload(4), shl(192, 0xffffffffffffffff)))
                        return(memPos_16, 32)
                    }
                    case 0xc2b12a73 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        sstore(/** @src 0:3331:3350  "storedBytes32 = val" */ 0x05, /** @src 0:629:5407  "contract AdvancedFeatures {..." */ calldataload(4))
                        return(0, 0)
                    }
                    case 0xc81898d6 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        let value_12 := 0
                        value_12 := calldataload(4)
                        let _18 := and(value_12, 0xffffffffffffffffffffffffffffffff)
                        if iszero(eq(value_12, _18)) { revert(0, 0) }
                        let sum_1 := add(_18, and(abi_decode_userDefinedValueType_Amount(), 0xffffffffffffffffffffffffffffffff))
                        if gt(sum_1, 0xffffffffffffffffffffffffffffffff)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 36)
                        }
                        let memPos_17 := mload(64)
                        mstore(memPos_17, and(sum_1, 0xffffffffffffffffffffffffffffffff))
                        return(memPos_17, 32)
                    }
                    case 0xc87e0337 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 96) { revert(0, 0) }
                        let offset_2 := calldataload(4)
                        if gt(offset_2, 0xffffffffffffffff) { revert(0, 0) }
                        let value0_9, value1_1 := abi_decode_string_calldata(add(4, offset_2), calldatasize())
                        let offset_3 := calldataload(36)
                        if gt(offset_3, 0xffffffffffffffff) { revert(0, 0) }
                        let value2_1, value3_1 := abi_decode_string_calldata(add(4, offset_3), calldatasize())
                        let offset_4 := calldataload(68)
                        if gt(offset_4, 0xffffffffffffffff) { revert(0, 0) }
                        let value4, value5 := abi_decode_string_calldata(add(4, offset_4), calldatasize())
                        let outPtr_2 := mload(64)
                        calldatacopy(add(outPtr_2, 32), value0_9, value1_1)
                        let _19 := add(outPtr_2, value1_1)
                        let _20 := add(_19, 32)
                        mstore(_20, 0)
                        calldatacopy(_20, value2_1, value3_1)
                        let _21 := add(add(_19, value3_1), 32)
                        mstore(_21, 0)
                        calldatacopy(_21, value4, value5)
                        let _22 := add(_21, value5)
                        mstore(_22, 0)
                        let _23 := sub(_22, outPtr_2)
                        mstore(outPtr_2, add(_23, not(31)))
                        finalize_allocation(outPtr_2, _23)
                        let memPos_18 := mload(64)
                        mstore(memPos_18, 32)
                        return(memPos_18, sub(abi_encode_string(outPtr_2, add(memPos_18, 32)), memPos_18))
                    }
                    case 0xc99a760c {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let value_13 := and(shl(8, sload(/** @src 0:2684:2712  "bytes16 public storedBytes16" */ 3)), /** @src 0:629:5407  "contract AdvancedFeatures {..." */ not(0xffffffffffffffffffffffffffffffff))
                        let memPos_19 := mload(64)
                        mstore(memPos_19, value_13)
                        return(memPos_19, 32)
                    }
                    case 0xd19356f5 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let value_14 := shl(248, sload(/** @src 0:2556:2582  "bytes1 public storedBytes1" */ 3))
                        /// @src 0:629:5407  "contract AdvancedFeatures {..."
                        let memPos_20 := mload(64)
                        mstore(memPos_20, and(value_14, shl(248, 255)))
                        return(memPos_20, 32)
                    }
                    case 0xd4887484 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        let value0_10 := abi_decode_address()
                        let value1_2 := abi_decode_userDefinedValueType_Amount()
                        mstore(0, and(value0_10, sub(shl(160, 1), 1)))
                        mstore(32, /** @src 0:1242:1253  "userAmounts" */ 0x02)
                        /// @src 0:629:5407  "contract AdvancedFeatures {..."
                        let dataSlot_1 := keccak256(0, 64)
                        sstore(dataSlot_1, or(and(sload(dataSlot_1), not(0xffffffffffffffffffffffffffffffff)), and(value1_2, 0xffffffffffffffffffffffffffffffff)))
                        return(0, 0)
                    }
                    case 0xdc958e82 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPos_21 := mload(64)
                        mstore(memPos_21, /** @src 0:2453:2477  "IERC20.transfer.selector" */ shl(224, 0xa9059cbb))
                        /// @src 0:629:5407  "contract AdvancedFeatures {..."
                        return(memPos_21, 32)
                    }
                    case 0xe3f4d424 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value_15 := calldataload(4)
                        if iszero(eq(value_15, and(value_15, not(0xffffffffffffffffffffffff)))) { revert(0, 0) }
                        let memPos_22 := mload(64)
                        mstore(memPos_22, shr(96, /** @src 0:3583:3593  "address(b)" */ value_15))
                        /// @src 0:629:5407  "contract AdvancedFeatures {..."
                        return(memPos_22, 32)
                    }
                    case 0xed0915f4 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        let value0_11 := abi_decode_address()
                        /// @src 0:2032:2081  "abi.encodeCall(IERC20.approve, (spender, amount))"
                        let expr_mpos_3 := /** @src 0:629:5407  "contract AdvancedFeatures {..." */ mload(64)
                        /// @src 0:2032:2081  "abi.encodeCall(IERC20.approve, (spender, amount))"
                        mstore(add(expr_mpos_3, /** @src 0:629:5407  "contract AdvancedFeatures {..." */ 32), /** @src 0:2032:2081  "abi.encodeCall(IERC20.approve, (spender, amount))" */ shl(224, 0x095ea7b3))
                        let _24 := sub(abi_encode_address_uint256(add(expr_mpos_3, /** @src 0:629:5407  "contract AdvancedFeatures {..." */ 36), /** @src 0:2032:2081  "abi.encodeCall(IERC20.approve, (spender, amount))" */ value0_11, /** @src 0:629:5407  "contract AdvancedFeatures {..." */ calldataload(36)), /** @src 0:2032:2081  "abi.encodeCall(IERC20.approve, (spender, amount))" */ expr_mpos_3)
                        mstore(expr_mpos_3, add(_24, /** @src 0:629:5407  "contract AdvancedFeatures {..." */ not(31)))
                        /// @src 0:2032:2081  "abi.encodeCall(IERC20.approve, (spender, amount))"
                        finalize_allocation(expr_mpos_3, _24)
                        /// @src 0:629:5407  "contract AdvancedFeatures {..."
                        let memPos_23 := mload(64)
                        mstore(memPos_23, 32)
                        return(memPos_23, sub(abi_encode_string(expr_mpos_3, add(memPos_23, 32)), memPos_23))
                    }
                    case 0xed8d0d11 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value_16 := 0
                        value_16 := calldataload(4)
                        let _25 := and(value_16, 0xff)
                        if iszero(eq(value_16, _25)) { revert(0, 0) }
                        let memPos_24 := mload(64)
                        mstore(memPos_24, _25)
                        return(memPos_24, 32)
                    }
                    case 0xef9d92ad {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        let value0_12 := abi_decode_bytes4()
                        let ret_2 := /** @src 0:4107:4112  "a ^ b" */ xor(/** @src 0:629:5407  "contract AdvancedFeatures {..." */ value0_12, abi_decode_t_bytes4())
                        let memPos_25 := mload(64)
                        mstore(memPos_25, and(ret_2, shl(224, 0xffffffff)))
                        return(memPos_25, 32)
                    }
                    case 0xf5a79767 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        mstore(0, and(abi_decode_address(), sub(shl(160, 1), 1)))
                        mstore(32, /** @src 0:1359:1370  "userAmounts" */ 0x02)
                        /// @src 0:629:5407  "contract AdvancedFeatures {..."
                        let value_17 := and(sload(keccak256(0, 64)), 0xffffffffffffffffffffffffffffffff)
                        let memPos_26 := mload(64)
                        mstore(memPos_26, value_17)
                        return(memPos_26, 32)
                    }
                    case 0xf7bbbf70 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let memPos_27 := mload(64)
                        mstore(memPos_27, and(calldataload(4), shl(224, 0xffffffff)))
                        return(memPos_27, 32)
                    }
                    case 0xf84ddf0b {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _26 := sload(0)
                        let memPos_28 := mload(64)
                        mstore(memPos_28, _26)
                        return(memPos_28, 32)
                    }
                    case 0xf8a14f46 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        mstore(0, calldataload(4))
                        mstore(32, 1)
                        let value_18 := and(sload(keccak256(0, 64)), sub(shl(160, 1), 1))
                        let memPos_29 := mload(64)
                        mstore(memPos_29, value_18)
                        return(memPos_29, 32)
                    }
                    case 0xf98c2076 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 96) { revert(0, 0) }
                        let value0_13 := abi_decode_bytes4()
                        let value1_3 := abi_decode_t_bytes4()
                        let value_19 := 0
                        value_19 := calldataload(68)
                        let _27 := and(value_19, shl(192, 0xffffffffffffffff))
                        if iszero(eq(value_19, _27)) { revert(0, 0) }
                        let outPtr_3 := mload(64)
                        mstore(add(outPtr_3, 32), and(value0_13, shl(224, 0xffffffff)))
                        mstore(add(outPtr_3, 36), and(value1_3, shl(224, 0xffffffff)))
                        mstore(add(outPtr_3, 40), _27)
                        mstore(outPtr_3, 16)
                        finalize_allocation(outPtr_3, 48)
                        let memPos_30 := mload(64)
                        mstore(memPos_30, 32)
                        return(memPos_30, sub(abi_encode_string(outPtr_3, add(memPos_30, 32)), memPos_30))
                    }
                    case 0xfba1a1c3 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        sstore(/** @src 0:2837:2855  "storedBytes1 = val" */ 0x03, /** @src 0:629:5407  "contract AdvancedFeatures {..." */ or(and(sload(/** @src 0:2837:2855  "storedBytes1 = val" */ 0x03), /** @src 0:629:5407  "contract AdvancedFeatures {..." */ not(255)), shr(248, abi_decode_bytes1())))
                        return(0, 0)
                    }
                    case 0xfbba838f {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        /// @src 0:4404:4413  "return ~a"
                        let var := /** @src 0:629:5407  "contract AdvancedFeatures {..." */ and(/** @src 0:4411:4413  "~a" */ not(/** @src 0:629:5407  "contract AdvancedFeatures {..." */ abi_decode_bytes4()), shl(224, 0xffffffff))
                        let memPos_31 := mload(64)
                        mstore(memPos_31, var)
                        return(memPos_31, 32)
                    }
                }
                revert(0, 0)
            }
            function abi_decode_address() -> value
            {
                value := calldataload(4)
                if iszero(eq(value, and(value, sub(shl(160, 1), 1)))) { revert(0, 0) }
            }
            function abi_decode_string_calldata(offset, end) -> arrayPos, length
            {
                if iszero(slt(add(offset, 0x1f), end)) { revert(0, 0) }
                length := calldataload(offset)
                if gt(length, 0xffffffffffffffff) { revert(0, 0) }
                arrayPos := add(offset, 0x20)
                if gt(add(add(offset, length), 0x20), end) { revert(0, 0) }
            }
            function abi_encode_string(value, pos) -> end
            {
                let length := mload(value)
                mstore(pos, length)
                mcopy(add(pos, 0x20), add(value, 0x20), length)
                mstore(add(add(pos, length), 0x20), /** @src -1:-1:-1 */ 0)
                /// @src 0:629:5407  "contract AdvancedFeatures {..."
                end := add(add(pos, and(add(length, 31), not(31))), 0x20)
            }
            function abi_decode_bytes4() -> value
            {
                value := calldataload(4)
                if iszero(eq(value, and(value, shl(224, 0xffffffff)))) { revert(0, 0) }
            }
            function abi_decode_t_bytes4() -> value
            {
                value := calldataload(36)
                if iszero(eq(value, and(value, shl(224, 0xffffffff)))) { revert(0, 0) }
            }
            function abi_decode_bytes1() -> value
            {
                value := calldataload(4)
                if iszero(eq(value, and(value, shl(248, 255)))) { revert(0, 0) }
            }
            function abi_decode_userDefinedValueType_Amount() -> value
            {
                value := calldataload(36)
                if iszero(eq(value, and(value, 0xffffffffffffffffffffffffffffffff))) { revert(0, 0) }
            }
            function finalize_allocation(memPtr, size)
            {
                let newFreePtr := add(memPtr, and(add(size, 31), not(31)))
                if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr))
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:629:5407  "contract AdvancedFeatures {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x41)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:629:5407  "contract AdvancedFeatures {..." */ 0x24)
                }
                mstore(64, newFreePtr)
            }
            function abi_encode_address_uint256(headStart, value0, value1) -> tail
            {
                tail := add(headStart, 64)
                mstore(headStart, and(value0, sub(shl(160, 1), 1)))
                mstore(add(headStart, 32), value1)
            }
        }
        data ".metadata" hex"a2646970667358221220dcee32f44d342f97970b7f3132731f99179daf5a2268700137a005d0fc5b0a2f64736f6c634300081c0033"
    }
}