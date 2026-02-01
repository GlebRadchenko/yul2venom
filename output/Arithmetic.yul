object "Arithmetic_420" {
    code {
        {
            /// @src 0:181:3996  "contract Arithmetic {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("Arithmetic_420_deployed")
            codecopy(_1, dataoffset("Arithmetic_420_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/bench/Arithmetic.sol"
    object "Arithmetic_420_deployed" {
        code {
            {
                /// @src 0:181:3996  "contract Arithmetic {..."
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x118fc88c {
                        if callvalue() { revert(0, 0) }
                        let param, param_1 := abi_decode_uint256t_uint256(calldatasize())
                        mstore(_1, /** @src 0:2230:2235  "a < b" */ lt(param, param_1))
                        /// @src 0:181:3996  "contract Arithmetic {..."
                        return(_1, 32)
                    }
                    case 0x21e5749b {
                        if callvalue() { revert(0, 0) }
                        let param_2, param_3 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos := mload(64)
                        mstore(memPos, /** @src 0:2328:2333  "a > b" */ gt(param_2, param_3))
                        /// @src 0:181:3996  "contract Arithmetic {..."
                        return(memPos, 32)
                    }
                    case 0x27401a41 {
                        if callvalue() { revert(0, 0) }
                        let param_4, param_5 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_1 := mload(64)
                        mstore(memPos_1, /** @src 0:3258:3263  "a ^ b" */ xor(/** @src 0:181:3996  "contract Arithmetic {..." */ param_4, param_5))
                        return(memPos_1, 32)
                    }
                    case 0x2912581c {
                        if callvalue() { revert(0, 0) }
                        let param_6, param_7 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_2 := mload(64)
                        mstore(memPos_2, /** @src 0:2821:2826  "a > b" */ sgt(param_6, param_7))
                        /// @src 0:181:3996  "contract Arithmetic {..."
                        return(memPos_2, 32)
                    }
                    case 0x32148d73 {
                        if callvalue() { revert(0, 0) }
                        let param_8, param_9 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_3 := mload(64)
                        mstore(memPos_3, /** @src 0:2426:2432  "a == b" */ eq(param_8, param_9))
                        /// @src 0:181:3996  "contract Arithmetic {..."
                        return(memPos_3, 32)
                    }
                    case 0x3f3f7899 {
                        if callvalue() { revert(0, 0) }
                        let param_10, param_11 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_4 := mload(64)
                        mstore(memPos_4, add(param_10, param_11))
                        return(memPos_4, 32)
                    }
                    case 0x3f8d6558 {
                        if callvalue() { revert(0, 0) }
                        let param_12, param_13 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_5 := mload(64)
                        mstore(memPos_5, /** @src 0:3155:3160  "a | b" */ or(/** @src 0:181:3996  "contract Arithmetic {..." */ param_12, param_13))
                        return(memPos_5, 32)
                    }
                    case 0x42a08c38 {
                        if callvalue() { revert(0, 0) }
                        let param_14, param_15 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_6 := mload(64)
                        mstore(memPos_6, /** @src 0:2724:2729  "a < b" */ slt(param_14, param_15))
                        /// @src 0:181:3996  "contract Arithmetic {..."
                        return(memPos_6, 32)
                    }
                    case 0x48eaa435 {
                        if callvalue() { revert(0, 0) }
                        let param_16, param_17 := abi_decode_uint256t_uint256(calldatasize())
                        let power := checked_exp_unsigned(param_16, param_17)
                        let memPos_7 := mload(64)
                        mstore(memPos_7, power)
                        return(memPos_7, 32)
                    }
                    case 0x4b68c306 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let memPos_8 := mload(64)
                        mstore(memPos_8, signextend(0, and(calldataload(4), 0xff)))
                        return(memPos_8, 32)
                    }
                    case 0x502df5e0 {
                        if callvalue() { revert(0, 0) }
                        let param_18, param_19 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_9 := mload(64)
                        mstore(memPos_9, mul(param_18, param_19))
                        return(memPos_9, 32)
                    }
                    case 0x62a144d9 { external_fun_safeMod() }
                    case 0x75f4479a {
                        if callvalue() { revert(0, 0) }
                        let param_20, param_21 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_10 := mload(64)
                        mstore(memPos_10, shr(param_20, param_21))
                        return(memPos_10, 32)
                    }
                    case 0x8491293f {
                        if callvalue() { revert(0, 0) }
                        let param_22, param_23 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_11 := mload(64)
                        mstore(memPos_11, /** @src 0:3053:3058  "a & b" */ and(/** @src 0:181:3996  "contract Arithmetic {..." */ param_22, param_23))
                        return(memPos_11, 32)
                    }
                    case 0x97964011 {
                        if callvalue() { revert(0, 0) }
                        let param_24, param_25 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_12 := mload(64)
                        mstore(memPos_12, exp(param_24, param_25))
                        return(memPos_12, 32)
                    }
                    case 0x9da760ef {
                        if callvalue() { revert(0, 0) }
                        let param_26, param_27 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_13 := mload(64)
                        mstore(memPos_13, shl(param_26, param_27))
                        return(memPos_13, 32)
                    }
                    case 0x9eb4547b {
                        if callvalue() { revert(0, 0) }
                        let param_28, param_29 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_14 := mload(64)
                        mstore(memPos_14, sub(param_28, param_29))
                        return(memPos_14, 32)
                    }
                    case 0xa293d1e8 {
                        if callvalue() { revert(0, 0) }
                        let param_30, param_31 := abi_decode_uint256t_uint256(calldatasize())
                        let diff := sub(param_30, param_31)
                        if gt(diff, param_30)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        let memPos_15 := mload(64)
                        mstore(memPos_15, diff)
                        return(memPos_15, 32)
                    }
                    case 0xa3c4aeeb {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        let memPos_16 := mload(64)
                        mstore(memPos_16, sar(calldataload(36), calldataload(4)))
                        return(memPos_16, 32)
                    }
                    case 0xaa0acef2 { external_fun_unsafeDiv() }
                    case 0xb4773329 {
                        if callvalue() { revert(0, 0) }
                        let param_32, param_33 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_17 := mload(64)
                        mstore(memPos_17, /** @src 0:2626:2632  "a >= b" */ iszero(lt(param_32, param_33)))
                        /// @src 0:181:3996  "contract Arithmetic {..."
                        return(memPos_17, 32)
                    }
                    case 0xb5931f7c { external_fun_unsafeDiv() }
                    case 0xc519bf25 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let memPos_18 := mload(64)
                        mstore(memPos_18, signextend(1, and(calldataload(4), 0xffff)))
                        return(memPos_18, 32)
                    }
                    case 0xcca58718 { external_fun_safeMod() }
                    case 0xd05c78da {
                        if callvalue() { revert(0, 0) }
                        let param_34, param_35 := abi_decode_uint256t_uint256(calldatasize())
                        let product := mul(param_34, param_35)
                        if iszero(or(iszero(param_34), eq(param_35, div(product, param_34))))
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        let memPos_19 := mload(64)
                        mstore(memPos_19, product)
                        return(memPos_19, 32)
                    }
                    case 0xd6eddb18 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let memPos_20 := mload(64)
                        mstore(memPos_20, /** @src 0:3350:3352  "~a" */ not(/** @src 0:181:3996  "contract Arithmetic {..." */ calldataload(4)))
                        return(memPos_20, 32)
                    }
                    case 0xe6cb9013 {
                        if callvalue() { revert(0, 0) }
                        let param_36, param_37 := abi_decode_uint256t_uint256(calldatasize())
                        let sum := add(param_36, param_37)
                        if gt(param_36, sum)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        let memPos_21 := mload(64)
                        mstore(memPos_21, sum)
                        return(memPos_21, 32)
                    }
                    case 0xea6515c4 {
                        if callvalue() { revert(0, 0) }
                        let param_38, param_39 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_22 := mload(64)
                        mstore(memPos_22, /** @src 0:2526:2532  "a <= b" */ iszero(gt(param_38, param_39)))
                        /// @src 0:181:3996  "contract Arithmetic {..."
                        return(memPos_22, 32)
                    }
                    case 0xfbe3c6a0 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let memPos_23 := mload(64)
                        mstore(memPos_23, /** @src 0:2912:2918  "a == 0" */ iszero(/** @src 0:181:3996  "contract Arithmetic {..." */ calldataload(4)))
                        return(memPos_23, 32)
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
            function external_fun_safeMod()
            {
                if callvalue() { revert(0, 0) }
                let param, param_1 := abi_decode_uint256t_uint256(calldatasize())
                /// @src 0:822:827  "a % b"
                let r := /** @src -1:-1:-1 */ 0
                /// @src 0:181:3996  "contract Arithmetic {..."
                if iszero(param_1)
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:181:3996  "contract Arithmetic {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x12)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:181:3996  "contract Arithmetic {..." */ 0x24)
                }
                r := mod(param, param_1)
                let memPos := mload(64)
                mstore(memPos, r)
                return(memPos, 32)
            }
            function external_fun_unsafeDiv()
            {
                if callvalue() { revert(0, 0) }
                let param, param_1 := abi_decode_uint256t_uint256(calldatasize())
                /// @src 0:1504:1509  "a / b"
                let r := /** @src -1:-1:-1 */ 0
                /// @src 0:181:3996  "contract Arithmetic {..."
                if iszero(param_1)
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:181:3996  "contract Arithmetic {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x12)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:181:3996  "contract Arithmetic {..." */ 0x24)
                }
                r := div(param, param_1)
                let memPos := mload(64)
                mstore(memPos, r)
                return(memPos, 32)
            }
            function checked_exp_unsigned(base, exponent) -> power
            {
                if iszero(exponent)
                {
                    power := 1
                    leave
                }
                if iszero(base)
                {
                    power := 0
                    leave
                }
                switch base
                case 1 {
                    power := 1
                    leave
                }
                case 2 {
                    if gt(exponent, 255)
                    {
                        mstore(0, shl(224, 0x4e487b71))
                        mstore(4, 0x11)
                        revert(0, 0x24)
                    }
                    power := shl(exponent, 1)
                    let _1 := 0
                    _1 := 0
                    leave
                }
                if or(and(lt(base, 11), lt(exponent, 78)), and(lt(base, 307), lt(exponent, 32)))
                {
                    power := exp(base, exponent)
                    let _2 := 0
                    _2 := 0
                    leave
                }
                let exponent_1 := exponent
                let power_1 := /** @src -1:-1:-1 */ 0
                /// @src 0:181:3996  "contract Arithmetic {..."
                let base_1 := /** @src -1:-1:-1 */ 0
                /// @src 0:181:3996  "contract Arithmetic {..."
                power_1 := 1
                base_1 := base
                for { } gt(exponent_1, 1) { }
                {
                    if gt(base_1, div(not(0), base_1))
                    {
                        mstore(/** @src -1:-1:-1 */ 0, /** @src 0:181:3996  "contract Arithmetic {..." */ shl(224, 0x4e487b71))
                        mstore(4, 0x11)
                        revert(/** @src -1:-1:-1 */ 0, /** @src 0:181:3996  "contract Arithmetic {..." */ 0x24)
                    }
                    if and(exponent_1, 1)
                    {
                        power_1 := mul(power_1, base_1)
                    }
                    base_1 := mul(base_1, base_1)
                    exponent_1 := shr(1, exponent_1)
                }
                if gt(power_1, div(not(0), base_1))
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:181:3996  "contract Arithmetic {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x11)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:181:3996  "contract Arithmetic {..." */ 0x24)
                }
                power := mul(power_1, base_1)
            }
        }
        data ".metadata" hex"a2646970667358221220088ec0ef72619e5e96d78041ec6b148a585951c527f475c85017b8f777533d4264736f6c634300081c0033"
    }
}