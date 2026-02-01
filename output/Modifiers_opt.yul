object "Modifiers_490" {
    code {
        {
            
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            
            sstore( 0x00,  or(and(sload( 0x00),  not(sub(shl(160, 1), 1))),  caller()))
            
            mstore( 0x00,  caller())
            
            mstore(0x20,  0x02)
            
            let dataSlot := keccak256( 0x00,  64)
            sstore(dataSlot, or(and(sload(dataSlot), not(255)),  0x01))
            
            let _2 := datasize("Modifiers_490_deployed")
            codecopy(_1, dataoffset("Modifiers_490_deployed"), _2)
            return(_1, _2)
        }
    }
    
    object "Modifiers_490_deployed" {
        code {
            {
                
                mstore(64, memoryguard(0x80))
                
                {
                    switch shr(224, calldataload(0))
                    case 0x07d226bd {
                        
                        
                        let _1 := sload( 0x01)
                        
                        let _2 := increment_uint256( _1)
                        sstore( 0x01,  _2)
                        let sum := add(_1,  0x01)
                        
                        if gt(_1, sum)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        
                        require_helper_stringliteral( eq(_2, sum))
                        
                        return(0, 0)
                    }
                    case 0x085f4b05 {
                        
                        
                        let _3 := sload(0)
                        
                        if  iszero(eq( caller(),  and(_3, sub(shl(160, 1), 1))))
                        
                        {
                            
                            mstore( 0,  shl(224, 0x30cd7471))
                            revert( 0, 4)
                        }
                        
                        if  and(shr(160, _3), 0xff)
                        
                        {
                            
                            mstore( 0,  shl(227, 0x13d0ff59))
                            revert( 0, 4)
                        }
                        let _4 := sload( 0x01)
                        
                        let memPtr := 0
                        let size := 0
                        let memPtr_1 := mload(64)
                        let newFreePtr := add(memPtr_1, 64)
                        
                        mstore(64, newFreePtr)
                        memPtr := memPtr_1
                        mstore(memPtr_1, 4)
                        mstore(add(memPtr_1, 32), "full")
                        
                        let _5 :=  mload(64)
                        
                        log1(_5, sub(abi_encode_string(_5, memPtr_1), _5), 0x0ab8476427dc967cd4151b39f5b46551fe823303177494fd5e4e052ea40f2dd6)
                        
                        let _6 := increment_uint256( _4)
                        sstore( 0x01,  _6)
                        
                        let _7 :=  mload(64)
                        
                        log2(_7, sub(abi_encode_string(_7, memPtr_1), _7), 0xe0e2450862980d2d725d0eaff08ee369b5c951ad7f60c0214d8a068f7a501c45,  caller())
                        
                        let sum_1 := add(_4,  0x01)
                        
                        if gt(_4, sum_1)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        
                        require_helper_stringliteral( eq(_6, sum_1))
                        
                        return(0, 0)
                    }
                    case 0x0887573d {
                        
                        
                        let value := calldataload(4)
                        if iszero(eq(value, iszero(iszero(value)))) { revert(0, 0) }
                        
                        if value
                        {
                            
                            let _8 := sload( 0x01)
                            
                            let sum_2 := add(_8,  0x32)
                            
                            if gt(_8, sum_2)
                            {
                                mstore(0, shl(224, 0x4e487b71))
                                mstore(4, 0x11)
                                revert(0, 0x24)
                            }
                            sstore( 0x01,  sum_2)
                        }
                        return(0, 0)
                    }
                    case 0x13820d6a {
                        
                        
                        let _9 := sload( 0x01)
                        
                        let sum_3 := add(_9,  0x0a)
                        
                        if gt(_9, sum_3)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        sstore( 0x01,  sum_3)
                        
                        require_helper_stringliteral_13c0( gt(sum_3, _9))
                        
                        return(0, 0)
                    }
                    case 0x13af4035 {
                        
                        
                        let value_1 := calldataload(4)
                        let _10 := and(value_1, sub(shl(160, 1), 1))
                        if iszero(eq(value_1, _10)) { revert(0, 0) }
                        let _11 := sload(0)
                        
                        if  iszero(eq( caller(),  and(_11, sub(shl(160, 1), 1))))
                        
                        {
                            
                            mstore( 0,  shl(224, 0x30cd7471))
                            revert( 0, 4)
                        }
                        sstore(0, or(and(_11, shl(160, 0xffffffffffffffffffffffff)), _10))
                        return(0, 0)
                    }
                    case 0x16c38b3c {
                        
                        
                        let value_2 := calldataload(4)
                        let _12 := iszero(iszero(value_2))
                        if iszero(eq(value_2, _12)) { revert(0, 0) }
                        let _13 := sload(0)
                        
                        if  iszero(eq( caller(),  and(_13, sub(shl(160, 1), 1))))
                        
                        {
                            
                            mstore( 0,  shl(224, 0x30cd7471))
                            revert( 0, 4)
                        }
                        sstore(0, or(and(_13, not(shl(160, 255))), and(shl(160, _12), shl(160, 255))))
                        return(0, 0)
                    }
                    case 0x1785f53c {
                        
                        
                        let value_3 := calldataload(4)
                        let _14 := and(value_3, sub(shl(160, 1), 1))
                        if iszero(eq(value_3, _14)) { revert(0, 0) }
                        
                        if  iszero(eq( caller(),  and(sload(0), sub(shl(160, 1), 1))))
                        
                        {
                            
                            mstore( 0,  shl(224, 0x30cd7471))
                            revert( 0, 4)
                        }
                        mstore(0, _14)
                        mstore(32,  0x02)
                        
                        let dataSlot := keccak256(0, 64)
                        sstore(dataSlot, and(sload(dataSlot), not(255)))
                        return(0, 0)
                    }
                    case 0x1865c57d {
                        
                        
                        let _15 := sload(0)
                        let _16 := sload( 0x01)
                        
                        let memPos := mload(64)
                        mstore(memPos, and(_15, sub(shl(160, 1), 1)))
                        mstore(add(memPos, 32), iszero(iszero(and(shr(160, _15), 0xff))))
                        mstore(add(memPos, 64), _16)
                        return(memPos, 96)
                    }
                    case 0x290b487b {
                        
                        
                        let _17 := sload( 0x01)
                        
                        let sum_4 := add(_17,  0x07)
                        
                        if gt(_17, sum_4)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        
                        require_helper_stringliteral_13c0( gt(sum_4, _17))
                        
                        let sum_5 := add(_17, 1007)
                        if gt(sum_4, sum_5)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        sstore( 0x01,  sum_5)
                        return(0, 0)
                    }
                    case 0x2fd415b2 {
                        
                        
                        mstore(0,  caller())
                        
                        mstore(0x20,  0x02)
                        
                        if  iszero( and(sload(keccak256(0, 64)), 0xff))
                        
                        {
                            
                            mstore( 0,  shl(224, 0x7bfa4b9f))
                            revert( 0, 4)
                        }
                        
                        if  and(shr(160, sload(0)), 0xff)
                        
                        {
                            
                            mstore( 0,  shl(227, 0x13d0ff59))
                            revert( 0, 4)
                        }
                        sstore( 0x01, increment_uint256( sload( 0x01)))
                        
                        let memPos_1 := mload(64)
                        mstore(memPos_1,  0x01)
                        
                        return(memPos_1, 0x20)
                    }
                    case 0x32408f41 {
                        
                        
                        let _18 := sload( 0x01)
                        
                        let sum_6 := add(_18,  0x05)
                        
                        if gt(_18, sum_6)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        let sum_7 := add(_18, 1005)
                        if gt(sum_6, sum_7)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        sstore( 0x01,  sum_7)
                        return(0, 0)
                    }
                    case 0x429b62e5 {
                        
                        
                        let value_4 := calldataload(4)
                        let _19 := and(value_4, sub(shl(160, 1), 1))
                        if iszero(eq(value_4, _19)) { revert(0, 0) }
                        mstore(0, _19)
                        mstore(32,  2)
                        
                        let value_5 := and(sload(keccak256(0, 64)), 0xff)
                        let memPos_2 := mload(64)
                        mstore(memPos_2, iszero(iszero(value_5)))
                        return(memPos_2, 32)
                    }
                    case 0x5a08d4cf {
                        
                        
                        
                        let _20 :=  mload(64)
                        
                        mstore(_20, shl(229, 4594637))
                        
                        mstore( add(_20,  4), 32)
                        mstore(add( _20,  36), 19)
                        mstore(add( _20,  68), "Blocked by modifier")
                        
                        revert(_20, 100)
                    }
                    case  0x5c975abb {
                        
                        
                        let value_6 := and(shr(160, sload(0)), 0xff)
                        let memPos_3 := mload(64)
                        mstore(memPos_3, iszero(iszero(value_6)))
                        return(memPos_3, 32)
                    }
                    case 0x61baffe6 {
                        
                        
                        let _21 := sload(0)
                        
                        if  iszero(eq( caller(),  and(_21, sub(shl(160, 1), 1))))
                        
                        {
                            
                            mstore( 0,  shl(224, 0x30cd7471))
                            revert( 0, 4)
                        }
                        mstore(0,  caller())
                        
                        mstore(0x20,  0x02)
                        
                        if  iszero( and(sload(keccak256(0, 64)), 0xff))
                        
                        {
                            
                            mstore( 0,  shl(224, 0x7bfa4b9f))
                            revert( 0, 4)
                        }
                        
                        if  and(shr(160, _21), 0xff)
                        
                        {
                            
                            mstore( 0,  shl(227, 0x13d0ff59))
                            revert( 0, 4)
                        }
                        let _22 := sload( 0x01)
                        
                        let sum_8 := add(_22,  0x64)
                        
                        if gt(_22, sum_8)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        sstore( 0x01,  sum_8)
                        return(0, 0)
                    }
                    case 0x61bc221a {
                        
                        
                        let _23 := sload( 1)
                        
                        let memPos_4 := mload(64)
                        mstore(memPos_4, _23)
                        return(memPos_4, 32)
                    }
                    case 0x686b0327 {
                        
                        
                        let expr :=  lt( callvalue(),  0x016345785d8a0000)
                        
                        if iszero(expr)
                        {
                            expr :=  gt( callvalue(),  0x0de0b6b3a7640000)
                        }
                        
                        if expr
                        {
                            
                            mstore( 0,  shl(226, 0x181c9d0b))
                            
                            mstore(4,  callvalue())
                            
                            revert( 0, 36)
                        }
                        sstore( 0x01, checked_add_uint256( sload( 0x01),  callvalue()))
                        
                        return(0, 0)
                    }
                    case 0x70480275 {
                        
                        
                        let value_7 := calldataload(4)
                        let _24 := and(value_7, sub(shl(160, 1), 1))
                        if iszero(eq(value_7, _24)) { revert(0, 0) }
                        
                        if  iszero(eq( caller(),  and(sload(0), sub(shl(160, 1), 1))))
                        
                        {
                            
                            mstore( 0,  shl(224, 0x30cd7471))
                            revert( 0, 4)
                        }
                        mstore(0, _24)
                        mstore(32,  0x02)
                        
                        let dataSlot_1 := keccak256(0, 64)
                        sstore(dataSlot_1, or(and(sload(dataSlot_1), not(255)),  0x01))
                        
                        return(0, 0)
                    }
                    case 0x8ada066e {
                        
                        
                        mstore(0,  caller())
                        
                        mstore(0x20,  0x02)
                        
                        if  iszero( and(sload(keccak256(0, 64)), 0xff))
                        
                        {
                            
                            mstore( 0,  shl(224, 0x7bfa4b9f))
                            revert( 0, 4)
                        }
                        let _25 := sload( 0x01)
                        
                        let memPos_5 := mload(64)
                        mstore(memPos_5, _25)
                        return(memPos_5, 0x20)
                    }
                    case 0x8c81e1b0 {
                        
                        
                        let _26 := sload(0)
                        
                        if  iszero(eq( caller(),  and(_26, sub(shl(160, 1), 1))))
                        
                        {
                            
                            mstore( 0,  shl(224, 0x30cd7471))
                            revert( 0, 4)
                        }
                        
                        if  and(shr(160, _26), 0xff)
                        
                        {
                            
                            mstore( 0,  shl(227, 0x13d0ff59))
                            revert( 0, 4)
                        }
                        let _27 := sload( 0x01)
                        
                        let sum_9 := add(_27,  0x0a)
                        
                        if gt(_27, sum_9)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        sstore( 0x01,  sum_9)
                        let memPos_6 := mload(64)
                        mstore(memPos_6, sum_9)
                        return(memPos_6, 32)
                    }
                    case 0x8da5cb5b {
                        
                        
                        let value_8 := and(sload(0), sub(shl(160, 1), 1))
                        let memPos_7 := mload(64)
                        mstore(memPos_7, value_8)
                        return(memPos_7, 32)
                    }
                    case 0x9b6a7110 {
                        
                        
                        let memPtr_2 := 0
                        let size_1 := 0
                        let memPtr_3 := mload(64)
                        let newFreePtr_1 := add(memPtr_3, 64)
                        
                        mstore(64, newFreePtr_1)
                        memPtr_2 := memPtr_3
                        mstore(memPtr_3, 9)
                        mstore(add(memPtr_3, 32), "increment")
                        
                        let _28 :=  mload(64)
                        
                        log1(_28, sub(abi_encode_string(_28, memPtr_3), _28), 0x0ab8476427dc967cd4151b39f5b46551fe823303177494fd5e4e052ea40f2dd6)
                        
                        sstore( 0x01, increment_uint256( sload( 0x01)))
                        
                        let _29 :=  mload(64)
                        
                        log2(_29, sub(abi_encode_string(_29, memPtr_3), _29), 0xe0e2450862980d2d725d0eaff08ee369b5c951ad7f60c0214d8a068f7a501c45,  caller())
                        
                        return(0, 0)
                    }
                    case 0xaea3f28c {
                        
                        
                        let ret :=  checked_add_uint256( calldataload(4), calldataload(36))
                        let memPos_8 := mload(64)
                        mstore(memPos_8, ret)
                        return(memPos_8, 32)
                    }
                    case 0xe9d0f58a {
                        
                        
                        let _30 := sload( 0x01)
                        
                        let sum_10 := add(_30,  0x64)
                        
                        if gt(_30, sum_10)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        let sum_11 := add(_30, 101)
                        if gt(sum_10, sum_11)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        let sum_12 := add(_30, 301)
                        if gt(sum_11, sum_12)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        sstore( 0x01,  sum_12)
                        return(0, 0)
                    }
                    case 0xed87cf46 {
                        
                        if  lt( callvalue(),  0x2386f26fc10000)
                        
                        {
                            let memPtr_4 := mload(64)
                            mstore(memPtr_4,  shl(229, 4594637))
                            
                            mstore(add(memPtr_4, 4), 32)
                            mstore(add(memPtr_4, 36), 13)
                            mstore(add(memPtr_4, 68), "Below minimum")
                            revert(memPtr_4, 100)
                        }
                        sstore( 0x01, checked_add_uint256( sload( 0x01),  callvalue()))
                        
                        return(0, 0)
                    }
                }
                revert(0, 0)
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
            function require_helper_stringliteral(condition)
            {
                if iszero(condition)
                {
                    let memPtr := mload(64)
                    mstore(memPtr,  shl(229, 4594637))
                    
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 19)
                    mstore(add(memPtr, 68), "Reentrancy detected")
                    revert(memPtr, 100)
                }
            }
            function increment_uint256(value) -> ret
            {
                if eq(value, not(0))
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x11)
                    revert(0, 0x24)
                }
                ret := add(value, 1)
            }
            function abi_encode_string(headStart, value0) -> tail
            {
                mstore(headStart, 32)
                let length := mload(value0)
                mstore(add(headStart, 32), length)
                mcopy(add(headStart, 64), add(value0, 32), length)
                mstore(add(add(headStart, length), 64), 0)
                tail := add(add(headStart, and(add(length, 31), not(31))), 64)
            }
            function require_helper_stringliteral_13c0(condition)
            {
                if iszero(condition)
                {
                    let memPtr := mload(64)
                    mstore(memPtr,  shl(229, 4594637))
                    
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 21)
                    mstore(add(memPtr, 68), "Counter must increase")
                    revert(memPtr, 100)
                }
            }
        }
        data ".metadata" hex"a264697066735822122008433f2fa239ae7f2deb2b71185a4b9f3affc44dc6b28f0701e3455998e63c9564736f6c634300081c0033"
    }
}