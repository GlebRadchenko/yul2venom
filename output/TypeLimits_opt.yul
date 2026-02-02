object "TypeLimits_549" {
    code {
        {
            /// @src 0:165:4884  "contract TypeLimits {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("TypeLimits_549_deployed")
            codecopy(_1, dataoffset("TypeLimits_549_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/bench/TypeLimits.sol"
    object "TypeLimits_549_deployed" {
        code {
            {
                /// @src 0:165:4884  "contract TypeLimits {..."
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x0625faae {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        mstore(_1, /** @src 0:1873:1889  "type(int256).min" */ shl(255, 1))
                        /// @src 0:165:4884  "contract TypeLimits {..."
                        mstore(add(_1, 32), /** @src 0:1891:1907  "type(int256).max" */ sub(shl(255, /** @src 0:1873:1889  "type(int256).min" */ 1), 1))
                        /// @src 0:165:4884  "contract TypeLimits {..."
                        return(_1, 64)
                    }
                    case 0x098d3228 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPos := mload(64)
                        mstore(memPos, /** @src 0:1891:1907  "type(int256).max" */ sub(shl(255, /** @src 0:1873:1889  "type(int256).min" */ 1), 1))
                        /// @src 0:165:4884  "contract TypeLimits {..."
                        return(memPos, 32)
                    }
                    case 0x1509e91a {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPos_1 := mload(64)
                        mstore(memPos_1, 0)
                        mstore(add(memPos_1, 32), /** @src 0:621:637  "type(uint32).max" */ 0xffffffff)
                        /// @src 0:165:4884  "contract TypeLimits {..."
                        return(memPos_1, 64)
                    }
                    case 0x250cf21e {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPos_2 := mload(64)
                        mstore(memPos_2, /** @src 0:1337:1352  "type(int16).min" */ not(32767))
                        /// @src 0:165:4884  "contract TypeLimits {..."
                        mstore(add(memPos_2, 32), /** @src 0:1354:1369  "type(int16).max" */ 32767)
                        /// @src 0:165:4884  "contract TypeLimits {..."
                        return(memPos_2, 64)
                    }
                    case 0x31351785 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPos_3 := mload(64)
                        mstore(memPos_3, 0)
                        mstore(add(memPos_3, 32), /** @src 0:1041:1058  "type(uint256).max" */ not(0))
                        /// @src 0:165:4884  "contract TypeLimits {..."
                        return(memPos_3, 64)
                    }
                    case 0x35f1085f {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value := calldataload(4)
                        if iszero(eq(value, and(value, 0xff))) { revert(0, 0) }
                        let ret := fun_maxForBits(value)
                        let memPos_4 := mload(64)
                        mstore(memPos_4, ret)
                        return(memPos_4, 32)
                    }
                    case 0x47398011 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPos_5 := mload(64)
                        mstore(memPos_5, 0)
                        mstore(add(memPos_5, 32), /** @src 0:348:363  "type(uint8).max" */ 255)
                        /// @src 0:165:4884  "contract TypeLimits {..."
                        return(memPos_5, 64)
                    }
                    case 0x4f4f220d {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPos_6 := mload(64)
                        mstore(memPos_6, 0)
                        mstore(add(memPos_6, 32), /** @src 0:758:774  "type(uint64).max" */ 0xffffffffffffffff)
                        /// @src 0:165:4884  "contract TypeLimits {..."
                        return(memPos_6, 64)
                    }
                    case 0x52631aea {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPos_7 := mload(64)
                        mstore(memPos_7, /** @src 0:3967:3984  "type(uint128).max" */ 0xffffffffffffffffffffffffffffffff)
                        /// @src 0:165:4884  "contract TypeLimits {..."
                        return(memPos_7, 32)
                    }
                    case 0x59f1a071 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPos_8 := mload(64)
                        mstore(memPos_8, 0)
                        mstore(add(memPos_8, 32), /** @src 0:899:916  "type(uint128).max" */ 0xffffffffffffffffffffffffffffffff)
                        /// @src 0:165:4884  "contract TypeLimits {..."
                        return(memPos_8, 64)
                    }
                    case 0x6763b692 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let ret_1 := fun_clampToUint8(calldataload(4))
                        let memPos_9 := mload(64)
                        mstore(memPos_9, and(ret_1, 0xff))
                        return(memPos_9, 32)
                    }
                    case 0x687db44c {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let ret_2 := fun_clampToInt128(calldataload(4))
                        let memPos_10 := mload(64)
                        mstore(memPos_10, signextend(15, ret_2))
                        return(memPos_10, 32)
                    }
                    case 0x6b9241fc {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPos_11 := mload(64)
                        mstore(memPos_11, /** @src 0:3665:3690  "type(IERC165).interfaceId" */ shl(224, 0x01ffc9a7))
                        /// @src 0:165:4884  "contract TypeLimits {..."
                        return(memPos_11, 32)
                    }
                    case 0x7b602edf {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let memPos_12 := mload(64)
                        mstore(memPos_12, /** @src 0:4518:4543  "value == type(int256).min" */ eq(/** @src 0:165:4884  "contract TypeLimits {..." */ calldataload(4), /** @src 0:1873:1889  "type(int256).min" */ shl(255, 1)))
                        /// @src 0:165:4884  "contract TypeLimits {..."
                        return(memPos_12, 32)
                    }
                    case 0x97b3805f {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPos_13 := mload(64)
                        mstore(memPos_13, 0)
                        mstore(add(memPos_13, 32), /** @src 0:484:500  "type(uint16).max" */ 65535)
                        /// @src 0:165:4884  "contract TypeLimits {..."
                        return(memPos_13, 64)
                    }
                    case 0x9a02ea65 {
                        if callvalue() { revert(0, 0) }
                        let param, param_1 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_14 := mload(64)
                        mstore(memPos_14, /** @src 0:2117:2142  "a > type(uint256).max - b" */ gt(param, /** @src 0:165:4884  "contract TypeLimits {..." */ not(param_1)))
                        return(memPos_14, 32)
                    }
                    case 0x9a295e73 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPos_15 := mload(64)
                        mstore(memPos_15, /** @src 0:1041:1058  "type(uint256).max" */ not(0))
                        /// @src 0:165:4884  "contract TypeLimits {..."
                        mstore(add(memPos_15, 32), /** @src 0:1873:1889  "type(int256).min" */ shl(255, 1))
                        /// @src 0:165:4884  "contract TypeLimits {..."
                        mstore(add(memPos_15, 64), /** @src 0:1891:1907  "type(int256).max" */ sub(shl(255, /** @src 0:1873:1889  "type(int256).min" */ 1), 1))
                        /// @src 0:165:4884  "contract TypeLimits {..."
                        mstore(add(memPos_15, 96), /** @src 0:3967:3984  "type(uint128).max" */ 0xffffffffffffffffffffffffffffffff)
                        /// @src 0:165:4884  "contract TypeLimits {..."
                        return(memPos_15, 128)
                    }
                    case 0x9c250177 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPos_16 := mload(64)
                        mstore(memPos_16, /** @src 0:1469:1484  "type(int32).min" */ not(0x7fffffff))
                        /// @src 0:165:4884  "contract TypeLimits {..."
                        mstore(add(memPos_16, 32), /** @src 0:1486:1501  "type(int32).max" */ 0x7fffffff)
                        /// @src 0:165:4884  "contract TypeLimits {..."
                        return(memPos_16, 64)
                    }
                    case 0xbef75fb2 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value_1 := calldataload(4)
                        /// @src 0:3414:3466  "value >= type(int64).min && value <= type(int64).max"
                        let expr := /** @src 0:3414:3438  "value >= type(int64).min" */ iszero(slt(value_1, /** @src 0:3423:3438  "type(int64).min" */ not(0x7fffffffffffffff)))
                        /// @src 0:3414:3466  "value >= type(int64).min && value <= type(int64).max"
                        if expr
                        {
                            expr := /** @src 0:3442:3466  "value <= type(int64).max" */ iszero(sgt(value_1, /** @src 0:3451:3466  "type(int64).max" */ 0x7fffffffffffffff))
                        }
                        /// @src 0:165:4884  "contract TypeLimits {..."
                        let memPos_17 := mload(64)
                        mstore(memPos_17, iszero(iszero(expr)))
                        return(memPos_17, 32)
                    }
                    case 0xc5f506ab {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPos_18 := mload(64)
                        mstore(memPos_18, /** @src 0:1873:1889  "type(int256).min" */ shl(255, 1))
                        /// @src 0:165:4884  "contract TypeLimits {..."
                        return(memPos_18, 32)
                    }
                    case 0xc9940342 {
                        if callvalue() { revert(0, 0) }
                        let param_2, param_3 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_19 := mload(64)
                        mstore(memPos_19, /** @src 0:2303:2308  "b > a" */ gt(param_3, param_2))
                        /// @src 0:165:4884  "contract TypeLimits {..."
                        return(memPos_19, 32)
                    }
                    case 0xe5b5019a {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPos_20 := mload(64)
                        mstore(memPos_20, /** @src 0:1041:1058  "type(uint256).max" */ not(0))
                        /// @src 0:165:4884  "contract TypeLimits {..."
                        return(memPos_20, 32)
                    }
                    case 0xe6cb9013 {
                        if callvalue() { revert(0, 0) }
                        let param_4, param_5 := abi_decode_uint256t_uint256(calldatasize())
                        if /** @src 0:2464:2490  "a <= type(uint256).max - b" */ gt(param_4, /** @src 0:165:4884  "contract TypeLimits {..." */ not(param_5))
                        {
                            let memPtr := mload(64)
                            mstore(memPtr, shl(229, 4594637))
                            mstore(add(memPtr, 4), 32)
                            mstore(add(memPtr, 36), 8)
                            mstore(add(memPtr, 68), "overflow")
                            revert(memPtr, 100)
                        }
                        let sum := add(param_4, param_5)
                        if gt(param_4, sum)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        let memPos_21 := mload(64)
                        mstore(memPos_21, sum)
                        return(memPos_21, 32)
                    }
                    case 0xeb967ec2 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPos_22 := mload(64)
                        mstore(memPos_22, /** @src 0:3423:3438  "type(int64).min" */ not(0x7fffffffffffffff))
                        /// @src 0:165:4884  "contract TypeLimits {..."
                        mstore(add(memPos_22, 32), /** @src 0:1618:1633  "type(int64).max" */ 0x7fffffffffffffff)
                        /// @src 0:165:4884  "contract TypeLimits {..."
                        return(memPos_22, 64)
                    }
                    case 0xf189e25a {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPos_23 := mload(64)
                        mstore(memPos_23, /** @src 0:1207:1221  "type(int8).min" */ not(127))
                        /// @src 0:165:4884  "contract TypeLimits {..."
                        mstore(add(memPos_23, 32), /** @src 0:1223:1237  "type(int8).max" */ 127)
                        /// @src 0:165:4884  "contract TypeLimits {..."
                        return(memPos_23, 64)
                    }
                    case 0xf4aee8ab {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPos_24 := mload(64)
                        mstore(memPos_24, /** @src 0:1736:1752  "type(int128).min" */ not(0x7fffffffffffffffffffffffffffffff))
                        /// @src 0:165:4884  "contract TypeLimits {..."
                        mstore(add(memPos_24, 32), /** @src 0:1754:1770  "type(int128).max" */ 0x7fffffffffffffffffffffffffffffff)
                        /// @src 0:165:4884  "contract TypeLimits {..."
                        return(memPos_24, 64)
                    }
                    case 0xf8c2ccba {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let memPos_25 := mload(64)
                        mstore(memPos_25, /** @src 0:4398:4424  "value == type(uint256).max" */ eq(/** @src 0:165:4884  "contract TypeLimits {..." */ calldataload(4), /** @src 0:1041:1058  "type(uint256).max" */ not(0)))
                        /// @src 0:165:4884  "contract TypeLimits {..."
                        return(memPos_25, 32)
                    }
                    case 0xf9788ec3 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let memPos_26 := mload(64)
                        mstore(memPos_26, /** @src 0:3235:3261  "value <= type(uint128).max" */ iszero(gt(/** @src 0:165:4884  "contract TypeLimits {..." */ calldataload(4), 0xffffffffffffffffffffffffffffffff)))
                        return(memPos_26, 32)
                    }
                }
                revert(0, 0)
            }
            function abi_decode_uint256t_uint256(dataEnd) -> value0, value1
            {
                if slt(add(dataEnd, not(3)), 64) { revert(0, 0) }
                value0 := calldataload(4)
                value1 := calldataload(36)
            }
            /// @ast-id 548 @src 0:4670:4882  "function maxForBits(uint8 bits) external pure returns (uint256) {..."
            function fun_maxForBits(var_bits) -> var
            {
                /// @src 0:4725:4732  "uint256"
                var := /** @src 0:165:4884  "contract TypeLimits {..." */ 0
                let _1 := and(/** @src 0:4752:4760  "bits > 0" */ var_bits, /** @src 0:165:4884  "contract TypeLimits {..." */ 0xff)
                /// @src 0:4752:4775  "bits > 0 && bits <= 256"
                let expr := /** @src 0:4752:4760  "bits > 0" */ iszero(iszero(/** @src 0:165:4884  "contract TypeLimits {..." */ _1))
                /// @src 0:4752:4775  "bits > 0 && bits <= 256"
                if expr
                {
                    expr := /** @src 0:4764:4775  "bits <= 256" */ iszero(gt(/** @src 0:165:4884  "contract TypeLimits {..." */ _1, /** @src 0:4772:4775  "256" */ 0x0100))
                }
                /// @src 0:165:4884  "contract TypeLimits {..."
                if iszero(expr)
                {
                    let memPtr := mload(64)
                    mstore(memPtr, shl(229, 4594637))
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 12)
                    mstore(add(memPtr, 68), "Invalid bits")
                    revert(memPtr, 100)
                }
                /// @src 0:4802:4843  "if (bits == 256) return type(uint256).max"
                if /** @src 0:4806:4817  "bits == 256" */ eq(/** @src 0:165:4884  "contract TypeLimits {..." */ _1, /** @src 0:4814:4817  "256" */ 0x0100)
                /// @src 0:4802:4843  "if (bits == 256) return type(uint256).max"
                {
                    /// @src 0:4819:4843  "return type(uint256).max"
                    var := /** @src 0:1041:1058  "type(uint256).max" */ not(0)
                    /// @src 0:4819:4843  "return type(uint256).max"
                    leave
                }
                /// @src 0:165:4884  "contract TypeLimits {..."
                let result := shl(_1, /** @src 0:4861:4862  "1" */ 0x01)
                /// @src 0:165:4884  "contract TypeLimits {..."
                let diff := add(result, /** @src 0:1041:1058  "type(uint256).max" */ not(0))
                /// @src 0:165:4884  "contract TypeLimits {..."
                if gt(diff, result)
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x11)
                    revert(0, 0x24)
                }
                /// @src 0:4853:4875  "return (1 << bits) - 1"
                var := diff
            }
            /// @ast-id 335 @src 0:2581:2769  "function clampToUint8(uint256 value) external pure returns (uint8) {..."
            function fun_clampToUint8(var_value) -> var
            {
                /// @src 0:2641:2646  "uint8"
                var := /** @src 0:165:4884  "contract TypeLimits {..." */ 0
                /// @src 0:2658:2734  "if (value > type(uint8).max) {..."
                if /** @src 0:2662:2685  "value > type(uint8).max" */ gt(var_value, /** @src 0:165:4884  "contract TypeLimits {..." */ 0xff)
                /// @src 0:2658:2734  "if (value > type(uint8).max) {..."
                {
                    /// @src 0:2701:2723  "return type(uint8).max"
                    var := /** @src 0:165:4884  "contract TypeLimits {..." */ 0xff
                    /// @src 0:2701:2723  "return type(uint8).max"
                    leave
                }
                /// @src 0:2743:2762  "return uint8(value)"
                var := /** @src 0:165:4884  "contract TypeLimits {..." */ and(/** @src 0:2750:2762  "uint8(value)" */ var_value, /** @src 0:165:4884  "contract TypeLimits {..." */ 0xff)
            }
            /// @ast-id 379 @src 0:2819:3098  "function clampToInt128(int256 value) external pure returns (int128) {..."
            function fun_clampToInt128(var_value) -> var
            {
                /// @src 0:2879:2885  "int128"
                var := /** @src 0:165:4884  "contract TypeLimits {..." */ 0
                /// @src 0:2897:2975  "if (value > type(int128).max) {..."
                if /** @src 0:2901:2925  "value > type(int128).max" */ sgt(var_value, /** @src 0:2909:2925  "type(int128).max" */ 0x7fffffffffffffffffffffffffffffff)
                /// @src 0:2897:2975  "if (value > type(int128).max) {..."
                {
                    /// @src 0:2941:2964  "return type(int128).max"
                    var := /** @src 0:2909:2925  "type(int128).max" */ 0x7fffffffffffffffffffffffffffffff
                    /// @src 0:2941:2964  "return type(int128).max"
                    leave
                }
                /// @src 0:2984:3062  "if (value < type(int128).min) {..."
                if /** @src 0:2988:3012  "value < type(int128).min" */ slt(var_value, /** @src 0:1736:1752  "type(int128).min" */ not(0x7fffffffffffffffffffffffffffffff))
                /// @src 0:2984:3062  "if (value < type(int128).min) {..."
                {
                    /// @src 0:3028:3051  "return type(int128).min"
                    var := /** @src 0:1736:1752  "type(int128).min" */ not(0x7fffffffffffffffffffffffffffffff)
                    /// @src 0:3028:3051  "return type(int128).min"
                    leave
                }
                /// @src 0:3071:3091  "return int128(value)"
                var := /** @src 0:165:4884  "contract TypeLimits {..." */ signextend(15, /** @src 0:3078:3091  "int128(value)" */ var_value)
            }
        }
        data ".metadata" hex"a2646970667358221220bb9104bca1f728ef70fbae1728d7100dd822ee1a4b1a78f0b8f4117920ec0f2164736f6c634300081c0033"
    }
}