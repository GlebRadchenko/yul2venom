object "Arithmetic_420" {
    code {
        {
            
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            
            let _2 := datasize("Arithmetic_420_deployed")
            codecopy(_1, dataoffset("Arithmetic_420_deployed"), _2)
            return(_1, _2)
        }
    }
    
    object "Arithmetic_420_deployed" {
        code {
            {
                
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                
                {
                    switch shr(224, calldataload(0))
                    case 0x118fc88c {
                        
                        let param, param_1 := abi_decode_uint256t_uint256(calldatasize())
                        mstore(_1,  lt(param, param_1))
                        
                        return(_1, 32)
                    }
                    case 0x21e5749b {
                        
                        let param_2, param_3 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos := mload(64)
                        mstore(memPos,  gt(param_2, param_3))
                        
                        return(memPos, 32)
                    }
                    case 0x27401a41 {
                        
                        let param_4, param_5 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_1 := mload(64)
                        mstore(memPos_1,  xor( param_4, param_5))
                        return(memPos_1, 32)
                    }
                    case 0x2912581c {
                        
                        let param_6, param_7 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_2 := mload(64)
                        mstore(memPos_2,  sgt(param_6, param_7))
                        
                        return(memPos_2, 32)
                    }
                    case 0x32148d73 {
                        
                        let param_8, param_9 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_3 := mload(64)
                        mstore(memPos_3,  eq(param_8, param_9))
                        
                        return(memPos_3, 32)
                    }
                    case 0x3f3f7899 {
                        
                        let param_10, param_11 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_4 := mload(64)
                        mstore(memPos_4, add(param_10, param_11))
                        return(memPos_4, 32)
                    }
                    case 0x3f8d6558 {
                        
                        let param_12, param_13 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_5 := mload(64)
                        mstore(memPos_5,  or( param_12, param_13))
                        return(memPos_5, 32)
                    }
                    case 0x42a08c38 {
                        
                        let param_14, param_15 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_6 := mload(64)
                        mstore(memPos_6,  slt(param_14, param_15))
                        
                        return(memPos_6, 32)
                    }
                    case 0x48eaa435 {
                        
                        let param_16, param_17 := abi_decode_uint256t_uint256(calldatasize())
                        let power := checked_exp_unsigned(param_16, param_17)
                        let memPos_7 := mload(64)
                        mstore(memPos_7, power)
                        return(memPos_7, 32)
                    }
                    case 0x4b68c306 {
                        
                        
                        let memPos_8 := mload(64)
                        mstore(memPos_8, signextend(0, and(calldataload(4), 0xff)))
                        return(memPos_8, 32)
                    }
                    case 0x502df5e0 {
                        
                        let param_18, param_19 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_9 := mload(64)
                        mstore(memPos_9, mul(param_18, param_19))
                        return(memPos_9, 32)
                    }
                    case 0x62a144d9 { external_fun_safeMod() }
                    case 0x75f4479a {
                        
                        let param_20, param_21 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_10 := mload(64)
                        mstore(memPos_10, shr(param_20, param_21))
                        return(memPos_10, 32)
                    }
                    case 0x8491293f {
                        
                        let param_22, param_23 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_11 := mload(64)
                        mstore(memPos_11,  and( param_22, param_23))
                        return(memPos_11, 32)
                    }
                    case 0x97964011 {
                        
                        let param_24, param_25 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_12 := mload(64)
                        mstore(memPos_12, exp(param_24, param_25))
                        return(memPos_12, 32)
                    }
                    case 0x9da760ef {
                        
                        let param_26, param_27 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_13 := mload(64)
                        mstore(memPos_13, shl(param_26, param_27))
                        return(memPos_13, 32)
                    }
                    case 0x9eb4547b {
                        
                        let param_28, param_29 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_14 := mload(64)
                        mstore(memPos_14, sub(param_28, param_29))
                        return(memPos_14, 32)
                    }
                    case 0xa293d1e8 {
                        
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
                        
                        
                        let memPos_16 := mload(64)
                        mstore(memPos_16, sar(calldataload(36), calldataload(4)))
                        return(memPos_16, 32)
                    }
                    case 0xaa0acef2 { external_fun_unsafeDiv() }
                    case 0xb4773329 {
                        
                        let param_32, param_33 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_17 := mload(64)
                        mstore(memPos_17,  iszero(lt(param_32, param_33)))
                        
                        return(memPos_17, 32)
                    }
                    case 0xb5931f7c { external_fun_unsafeDiv() }
                    case 0xc519bf25 {
                        
                        
                        let memPos_18 := mload(64)
                        mstore(memPos_18, signextend(1, and(calldataload(4), 0xffff)))
                        return(memPos_18, 32)
                    }
                    case 0xcca58718 { external_fun_safeMod() }
                    case 0xd05c78da {
                        
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
                        
                        
                        let memPos_20 := mload(64)
                        mstore(memPos_20,  not( calldataload(4)))
                        return(memPos_20, 32)
                    }
                    case 0xe6cb9013 {
                        
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
                        
                        let param_38, param_39 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_22 := mload(64)
                        mstore(memPos_22,  iszero(gt(param_38, param_39)))
                        
                        return(memPos_22, 32)
                    }
                    case 0xfbe3c6a0 {
                        
                        
                        let memPos_23 := mload(64)
                        mstore(memPos_23,  iszero( calldataload(4)))
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
                
                let param, param_1 := abi_decode_uint256t_uint256(calldatasize())
                
                let r :=  0
                
                if iszero(param_1)
                {
                    mstore( 0,  shl(224, 0x4e487b71))
                    mstore(4, 0x12)
                    revert( 0,  0x24)
                }
                r := mod(param, param_1)
                let memPos := mload(64)
                mstore(memPos, r)
                return(memPos, 32)
            }
            function external_fun_unsafeDiv()
            {
                
                let param, param_1 := abi_decode_uint256t_uint256(calldatasize())
                
                let r :=  0
                
                if iszero(param_1)
                {
                    mstore( 0,  shl(224, 0x4e487b71))
                    mstore(4, 0x12)
                    revert( 0,  0x24)
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
                    leave
                }
                if or(and(lt(base, 11), lt(exponent, 78)), and(lt(base, 307), lt(exponent, 32)))
                {
                    power := exp(base, exponent)
                    let _2 := 0
                    leave
                }
                let exponent_1 := exponent
                let power_1 :=  0
                
                let base_1 :=  0
                
                power_1 := 1
                base_1 := base
                for { } gt(exponent_1, 1) { }
                {
                    if gt(base_1, div(not(0), base_1))
                    {
                        mstore( 0,  shl(224, 0x4e487b71))
                        mstore(4, 0x11)
                        revert( 0,  0x24)
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
                    mstore( 0,  shl(224, 0x4e487b71))
                    mstore(4, 0x11)
                    revert( 0,  0x24)
                }
                power := mul(power_1, base_1)
            }
        }
        data ".metadata" hex"a2646970667358221220088ec0ef72619e5e96d78041ec6b148a585951c527f475c85017b8f777533d4264736f6c634300081c0033"
    }
}