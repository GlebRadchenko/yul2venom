object "StateManagement_444" {
    code {
        {
            
            mstore(64, memoryguard(0xe0))
            
            
            mstore(128,  timestamp())
            
            mstore(160,  caller())
            
            let expr :=  0x00
            
            switch  iszero(iszero( number()))
            case  0 {
                expr :=  0x00
            }
            default 
            {
                
                let diff := add( number(),  not(0))
                if gt(diff,  number())
                
                {
                    mstore( 0x00,  shl(224, 0x4e487b71))
                    mstore(4, 0x11)
                    revert( 0x00,  0x24)
                }
                
                expr := diff
            }
            
            mstore(192,  blockhash(expr))
            
            let _1 := mload(64)
            let _2 := datasize("StateManagement_444_deployed")
            codecopy(_1, dataoffset("StateManagement_444_deployed"), _2)
            setimmutable(_1, "15", mload( 128))
            
            setimmutable(_1, "17", mload( 160))
            
            setimmutable(_1, "19", mload( 192))
            
            return(_1, _2)
        }
    }
    
    object "StateManagement_444_deployed" {
        code {
            {
                
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                
                {
                    switch shr(224, calldataload(0))
                    case 0x0198214f {
                        
                        let param, param_1 := abi_decode_uint256t_uint256(calldatasize())
                        
                        tstore(param, param_1)
                        
                        return(0, 0)
                    }
                    case 0x04fe64ce {
                        
                        let param_2, param_3 := abi_decode_uint256t_uint256(calldatasize())
                        
                        let usr$a := tload(param_2)
                        tstore(param_2, tload(param_3))
                        tstore(param_3, usr$a)
                        
                        return(0, 0)
                    }
                    case 0x0849cc99 {
                        
                        
                        mstore(_1, sload( 0x09))
                        
                        return(_1, 32)
                    }
                    case 0x0c36ee80 {
                        
                        
                        let value := calldataload(4)
                        let _2 := iszero(iszero(value))
                        if iszero(eq(value, _2)) { revert(0, 0) }
                        let value_1 := and(sload( 0x02),  not(255))
                        sstore( 0x02,  or(value_1, and(_2, 255)))
                        return(0, 0)
                    }
                    case 0x0cef0fe7 {
                        
                        
                        sstore(0, calldataload(4))
                        return(0, 0)
                    }
                    case 0x142edc7a {
                        
                        
                        
                        let _3, _4 := storage_array_index_access_uint256_dyn( calldataload(4))
                        let value_2 := shr(shl(3, _4), sload( _3))
                        
                        let memPos := mload(64)
                        mstore(memPos, value_2)
                        return(memPos, 32)
                    }
                    case 0x16cdf825 {
                        
                        
                        let oldLen := sload( 0x09)
                        
                        if iszero(lt(oldLen, 18446744073709551616))
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x41)
                            revert(0, 0x24)
                        }
                        sstore( 0x09,  add(oldLen, 1))
                        let slot, offset := storage_array_index_access_uint256_dyn(oldLen)
                        let _5 := sload(slot)
                        let shiftBits := shl(3, offset)
                        sstore(slot, or(and(_5, not(shl(shiftBits, not(0)))), shl(shiftBits, calldataload(4))))
                        return(0, 0)
                    }
                    case 0x202df7cd {
                        
                        
                        let value_3 := and(shr(128, sload( 5)),  0xffffffffffffffff)
                        let memPos_1 := mload(64)
                        mstore(memPos_1, value_3)
                        return(memPos_1, 32)
                    }
                    case 0x26fcfbcc {
                        
                        let param_4, param_5 := abi_decode_uint256t_uint256(calldatasize())
                        mstore(0, param_4)
                        mstore(0x20,  8)
                        
                        let dataSlot := keccak256(0, 64)
                        mstore(0, param_5)
                        mstore(0x20, dataSlot)
                        let _6 := sload(keccak256(0, 64))
                        let memPos_2 := mload(64)
                        mstore(memPos_2, _6)
                        return(memPos_2, 0x20)
                    }
                    case 0x27e235e3 {
                        
                        
                        mstore(0, and(abi_decode_address(), sub(shl(160, 1), 1)))
                        mstore(32,  7)
                        
                        let _7 := sload(keccak256(0, 64))
                        let memPos_3 := mload(64)
                        mstore(memPos_3, _7)
                        return(memPos_3, 32)
                    }
                    case 0x2c6ddcb6 {
                        
                        
                        let _8 := shr(128, sload(4))
                        let memPos_4 := mload(64)
                        mstore(memPos_4, _8)
                        return(memPos_4, 32)
                    }
                    case 0x384bc466 {
                        
                        
                        mstore(0, and(abi_decode_address(), sub(shl(160, 1), 1)))
                        mstore(32,  0x07)
                        
                        let dataSlot_1 := keccak256(0, 64)
                        let _9 := sload( dataSlot_1)
                        
                        let sum := add(_9, calldataload(36))
                        if gt(_9, sum)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 36)
                        }
                        sstore(dataSlot_1, sum)
                        return(0, 0)
                    }
                    case 0x3e213e28 {
                        
                        
                        let var_size := calldataload(4)
                        
                        if  gt(var_size,  0x03e8)
                        
                        {
                            
                            var_size :=  0x03e8
                        }
                        
                        let length := mload( allocate_and_zero_memory_array_array_uint256_dyn(var_size))
                        
                        let memPos_5 := mload(64)
                        mstore(memPos_5, length)
                        return(memPos_5, 32)
                    }
                    case 0x5e115ec2 {
                        
                        
                        let value_4 := and(sload( 0x02),  0xff)
                        let memPos_6 := mload(64)
                        mstore(memPos_6, iszero(iszero(value_4)))
                        return(memPos_6, 32)
                    }
                    case 0x60f63fc9 {
                        
                        
                        let _10 := sload(4)
                        let memPos_7 := mload(64)
                        mstore(memPos_7, and(_10, 0xffffffffffffffffffffffffffffffff))
                        mstore(add(memPos_7, 32), shr(128, _10))
                        return(memPos_7, 64)
                    }
                    case 0x61c0afb2 {
                        
                        
                        let memPos_8 := mload(64)
                        mstore(memPos_8,  loadimmutable("19"))
                        
                        return(memPos_8, 32)
                    }
                    case 0x62ec9192 {
                        
                        
                        let value_5 := calldataload(4)
                        
                        tstore(value_5, add(tload(value_5),  1))
                        return(0, 0)
                    }
                    case 0x6e4d2a34 {
                        
                        
                        let _11 := sload(0)
                        let memPos_9 := mload(64)
                        mstore(memPos_9, _11)
                        return(memPos_9, 32)
                    }
                    case 0x74530819 {
                        
                        
                        let memPtr := mload(64)
                        let newFreePtr := add(memPtr, 64)
                        
                        mstore(64, newFreePtr)
                        mstore(memPtr, 5)
                        let _12 := add(memPtr, 32)
                        mstore(_12, "hello")
                        let memPos_10 := mload(64)
                        mstore(memPos_10, 32)
                        let length_1 := mload(memPtr)
                        mstore(add(memPos_10, 32), length_1)
                        mcopy(add(memPos_10, 64), _12, length_1)
                        mstore(add(add(memPos_10, length_1), 64), 0)
                        return(memPos_10, add(sub(add(memPos_10, and(add(length_1, 31), not(31))), memPos_10), 64))
                    }
                    case 0x8aa0391a {
                        
                        
                        mstore(0, calldataload(4))
                        mstore(32,  0x08)
                        
                        let dataSlot_2 := keccak256(0, 64)
                        mstore(0, calldataload(36))
                        mstore(32, dataSlot_2)
                        sstore(keccak256(0, 64), calldataload(68))
                        return(0, 0)
                    }
                    case 0x8f63640e {
                        
                        
                        let value_6 := and(shr(8, sload( 2)),  sub(shl(160, 1), 1))
                        let memPos_11 := mload(64)
                        mstore(memPos_11, value_6)
                        return(memPos_11, 32)
                    }
                    case 0x90d92e76 {
                        
                        
                        let memPos_12 := mload(64)
                        mstore(memPos_12,  loadimmutable("15"))
                        
                        return(memPos_12, 32)
                    }
                    case 0x9a0363bb {
                        
                        
                        let _13 := sload( 3)
                        
                        let memPos_13 := mload(64)
                        mstore(memPos_13, _13)
                        return(memPos_13, 32)
                    }
                    case 0x9a295e73 {
                        
                        
                        let memPos_14 := mload(64)
                        mstore(memPos_14,  0x3039)
                        
                        mstore(add(memPos_14, 32),  0xfe6e943664ea20c614f5e9ef10a77775da30c9e509ae648d83f4197fe516f21e)
                        
                        mstore(add(memPos_14, 64),  loadimmutable("15"))
                        
                        mstore(add(memPos_14, 96), and( loadimmutable("17"),  sub(shl(160, 1), 1)))
                        return(memPos_14, 128)
                    }
                    case 0x9a5009ac {
                        
                        
                        let value_7 := calldataload(4)
                        
                        let _14 := iszero(lt(value_7,  0x0a))
                        
                        if _14
                        {
                            revert( 0, 0)
                        }
                        _14 := 0
                        let _15 := sload(add(0x0a, value_7))
                        let memPos_15 := mload(64)
                        mstore(memPos_15, _15)
                        return(memPos_15, 32)
                    }
                    case 0x9a9bdca7 {
                        
                        
                        let value_8 := calldataload(4)
                        
                        if iszero(lt(value_8,  sload( 9)))
                        {
                            revert( 0, 0)
                        }
                        
                        let slot_1, offset_1 := storage_array_index_access_uint256_dyn(value_8)
                        
                        let value_9 := shr(shl(3, offset_1), sload( slot_1))
                        
                        let memPos_16 := mload(64)
                        mstore(memPos_16, value_9)
                        return(memPos_16, 32)
                    }
                    case 0x9ba71853 {
                        
                        
                        let var_size_1 := calldataload(4)
                        
                        if  gt(var_size_1,  0x64)
                        
                        {
                            
                            var_size_1 :=  0x64
                        }
                        
                        let expr_mpos := allocate_and_zero_memory_array_array_uint256_dyn(var_size_1)
                        
                        let var_i :=  0
                        
                        for { }
                         lt(var_i, var_size_1)
                        
                        {
                            
                            var_i :=  add( var_i,  1)
                        }
                        
                        {
                            
                            mstore( memory_array_index_access_uint256_dyn(expr_mpos, var_i),  var_i)
                        }
                        
                        let expr_mpos_1 := allocate_and_zero_memory_array_array_uint256_dyn(var_size_1)
                        
                        let var_i_1 :=  0
                        
                        for { }
                         lt(var_i_1, var_size_1)
                        
                        {
                            
                            var_i_1 :=  add( var_i_1,  1)
                        }
                        
                        {
                            
                            mstore( memory_array_index_access_uint256_dyn(expr_mpos_1, var_i_1),  mload( memory_array_index_access_uint256_dyn(expr_mpos, var_i_1)))
                        }
                        
                        let expr :=  0
                        
                        switch  iszero(iszero(var_size_1))
                        case  0 {
                            expr :=  0
                        }
                        default 
                        {
                            
                            let diff := add(var_size_1, not(0))
                            if gt(diff, var_size_1)
                            {
                                mstore(0, shl(224, 0x4e487b71))
                                mstore(4, 0x11)
                                revert(0, 0x24)
                            }
                            
                            expr := diff
                        }
                        
                        let _16 := mload( memory_array_index_access_uint256_dyn(expr_mpos_1, expr))
                        
                        let memPos_17 := mload(64)
                        mstore(memPos_17, _16)
                        return(memPos_17, 32)
                    }
                    case 0x9c6f010c {
                        
                        
                        
                        let var_value := tload( calldataload(4))
                        let memPos_18 := mload(64)
                        mstore(memPos_18, var_value)
                        return(memPos_18, 32)
                    }
                    case 0xae713d2a {
                        
                        
                        let oldLen_1 := sload( 0x09)
                        
                        if iszero(oldLen_1)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x31)
                            revert(0, 0x24)
                        }
                        let newLen := add(oldLen_1, not(0))
                        let slot_2, offset_2 := storage_array_index_access_uint256_dyn(newLen)
                        let _17 := sload(slot_2)
                        sstore(slot_2, and(_17, not(shl(shl(3, offset_2), not(0)))))
                        sstore( 0x09,  newLen)
                        return(0, 0)
                    }
                    case 0xb2df5978 {
                        
                        
                        let _18 := sload(0)
                        let memPos_19 := mload(64)
                        mstore(memPos_19, _18)
                        return(memPos_19, 32)
                    }
                    case 0xbae4ab0d {
                        
                        
                        let _19 := shr(192, sload( 5))
                        
                        let memPos_20 := mload(64)
                        mstore(memPos_20, _19)
                        return(memPos_20, 32)
                    }
                    case 0xbba50db2 {
                        
                        
                        mstore(0, calldataload(4))
                        mstore(32,  0x06)
                        
                        let _20 := sload(keccak256(0, 64))
                        let memPos_21 := mload(64)
                        mstore(memPos_21, _20)
                        return(memPos_21, 32)
                    }
                    case 0xc1b8411a {
                        
                        
                        let memPos_22 := mload(64)
                        mstore(memPos_22, and( loadimmutable("17"),  sub(shl(160, 1), 1)))
                        return(memPos_22, 32)
                    }
                    case 0xc3278189 {
                        
                        
                        let value_10 := and(sload( 5),  0xffffffffffffffff)
                        let memPos_23 := mload(64)
                        mstore(memPos_23, value_10)
                        return(memPos_23, 32)
                    }
                    case 0xcefe1833 {
                        
                        
                        let value_11 := and(sload( 2),  0xff)
                        let memPos_24 := mload(64)
                        mstore(memPos_24, iszero(iszero(value_11)))
                        return(memPos_24, 32)
                    }
                    case 0xcfe5cee4 {
                        
                        
                        let value_12 := calldataload(4)
                        let _21 := and(value_12, 0xffffffffffffffffffffffffffffffff)
                        if iszero(eq(value_12, _21)) { revert(0, 0) }
                        let value_13 := calldataload(36)
                        
                        sstore(4, or(_21, and(shl(128, value_13), not(0xffffffffffffffffffffffffffffffff))))
                        return(0, 0)
                    }
                    case 0xdaae8ba2 {
                        
                        
                        mstore(0, calldataload(4))
                        mstore(32,  6)
                        
                        let _22 := sload(keccak256(0, 64))
                        let memPos_25 := mload(64)
                        mstore(memPos_25, _22)
                        return(memPos_25, 32)
                    }
                    case 0xe465acab {
                        
                        
                        let memPos_26 := mload(64)
                        mstore(memPos_26,  0x3039)
                        
                        return(memPos_26, 32)
                    }
                    case 0xe93ccaa3 {
                        
                        
                        let value_14 := and(sload(4), 0xffffffffffffffffffffffffffffffff)
                        let memPos_27 := mload(64)
                        mstore(memPos_27, value_14)
                        return(memPos_27, 32)
                    }
                    case 0xeb790438 {
                        
                        let param_6, param_7 := abi_decode_uint256t_uint256(calldatasize())
                        mstore(0, param_6)
                        mstore(0x20,  0x08)
                        
                        let dataSlot_3 := keccak256(0, 64)
                        mstore(0, param_7)
                        mstore(0x20, dataSlot_3)
                        let _23 := sload(keccak256(0, 64))
                        let memPos_28 := mload(64)
                        mstore(memPos_28, _23)
                        return(memPos_28, 0x20)
                    }
                    case 0xf36745d8 {
                        
                        
                        let value_15 := and(shr(64, sload( 5)),  0xffffffffffffffff)
                        let memPos_29 := mload(64)
                        mstore(memPos_29, value_15)
                        return(memPos_29, 32)
                    }
                    case 0xf6b9be5b {
                        
                        let param_8, param_9 := abi_decode_uint256t_uint256(calldatasize())
                        mstore(0, param_8)
                        mstore(0x20,  0x06)
                        
                        sstore(keccak256(0, 64), param_9)
                        return(0, 0)
                    }
                    case 0xfa196518 {
                        
                        
                        let memPos_30 := mload(64)
                        mstore(memPos_30,  0xfe6e943664ea20c614f5e9ef10a77775da30c9e509ae648d83f4197fe516f21e)
                        
                        return(memPos_30, 32)
                    }
                    case 0xfac8b339 {
                        
                        
                        let _24 := sload( 1)
                        
                        let memPos_31 := mload(64)
                        mstore(memPos_31, _24)
                        return(memPos_31, 32)
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
            function abi_decode_address() -> value
            {
                value := calldataload(4)
                
            }
            function storage_array_index_access_uint256_dyn(index) -> slot, offset
            {
                if iszero(lt(index, sload( 0x09)))
                
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x32)
                    revert(0, 0x24)
                }
                mstore( 0,  0x09)
                
                slot := add(keccak256( 0,  0x20), index)
                offset :=  0
            }
            
            function array_allocation_size_array_uint256_dyn(length) -> size
            {
                
                size := add(shl(5, length), 0x20)
            }
            function allocate_and_zero_memory_array_array_uint256_dyn(length) -> memPtr
            {
                let _1 := array_allocation_size_array_uint256_dyn(length)
                let memPtr_1 := mload(64)
                let newFreePtr := add(memPtr_1, and(add(_1, 31), not(31)))
                
                mstore(64, newFreePtr)
                mstore(memPtr_1, length)
                memPtr := memPtr_1
                calldatacopy(add(memPtr_1, 32), calldatasize(), add(array_allocation_size_array_uint256_dyn(length), not(31)))
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
        }
        data ".metadata" hex"a264697066735822122059ab35e6a80e3d4f2df96d057ee163c8618751e77371e99784c50e75f89fcc1e64736f6c634300081c0033"
    }
}