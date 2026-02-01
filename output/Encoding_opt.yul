object "Encoding_160" {
    code {
        {
            
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            
            let _2 := datasize("Encoding_160_deployed")
            codecopy(_1, dataoffset("Encoding_160_deployed"), _2)
            return(_1, _2)
        }
    }
    
    object "Encoding_160_deployed" {
        code {
            {
                
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                
                {
                    switch shr(224, calldataload(0))
                    case 0x0c74e88e {
                        
                        
                        let offset := calldataload(4)
                        
                        let value0, value1 := abi_decode_bytes_calldata(add(4, offset), calldatasize())
                        
                        let value0_1 :=  0
                        
                        let value1_1 :=  0
                        if slt(sub( add(value0, value1),  value0), 64) { revert(0, 0) }
                        value0_1 := calldataload(value0)
                        value1_1 := calldataload(add(value0, 32))
                        mstore(_1, value0_1)
                        mstore(add(_1, 32), value1_1)
                        return(_1, 64)
                    }
                    case 0x11850929 {
                        
                        let param, param_1 := abi_decode_uint256t_uint256(calldatasize())
                        
                        let expr_mpos :=  mload(64)
                        
                        let _2 := add(expr_mpos, 0x20)
                        
                        mstore(_2, param)
                        mstore(add( expr_mpos,  64), param_1)
                        
                        mstore(expr_mpos,  64)
                        
                        finalize_allocation(expr_mpos, 96)
                        
                        let var :=  keccak256( _2, mload( expr_mpos))
                        
                        let memPos := mload(64)
                        mstore(memPos, var)
                        return(memPos,  0x20)
                    }
                    case  0x1e768902 {
                        
                        let param_2, param_3 := abi_decode_uint256t_uint256(calldatasize())
                        
                        let expr_mpos_1 :=  mload(64)
                        mstore( add(expr_mpos_1, 0x20),  param_2)
                        mstore(add( expr_mpos_1,  64), param_3)
                        
                        mstore(expr_mpos_1,  64)
                        
                        finalize_allocation(expr_mpos_1, 96)
                        
                        let memPos_1 := mload(64)
                        return(memPos_1, sub(abi_encode_bytes(memPos_1, expr_mpos_1), memPos_1))
                    }
                    case 0x36dcae6d {
                        
                        
                        let value := calldataload(4)
                        if iszero(eq(value, and(value, shl(224, 0xffffffff)))) { revert(0, 0) }
                        
                        let expr_mpos_2 :=  mload(64)
                        
                        mstore(add(expr_mpos_2,  32),  value)
                        
                        mstore( add(expr_mpos_2,  36), calldataload(36))
                        
                        mstore(expr_mpos_2,  36)
                        
                        finalize_allocation(expr_mpos_2, 68)
                        
                        let memPos_2 := mload(64)
                        return(memPos_2, sub(abi_encode_bytes(memPos_2, expr_mpos_2), memPos_2))
                    }
                    case 0x4f66de1e {
                        
                        let param_4, param_5 := abi_decode_uint256t_uint256(calldatasize())
                        
                        let expr_mpos_3 :=  mload(64)
                        
                        let _3 := add(expr_mpos_3, 0x20)
                        
                        mstore(_3, param_4)
                        mstore(add( expr_mpos_3,  64), param_5)
                        
                        mstore(expr_mpos_3,  64)
                        
                        finalize_allocation(expr_mpos_3, 96)
                        
                        let var_1 :=  keccak256( _3, mload( expr_mpos_3))
                        
                        let memPos_3 := mload(64)
                        mstore(memPos_3, var_1)
                        return(memPos_3,  0x20)
                    }
                    case  0x54a65923 {
                        
                        let param_6, param_7 := abi_decode_uint256t_uint256(calldatasize())
                        
                        let expr_mpos_4 :=  mload(64)
                        mstore( add(expr_mpos_4, 0x20),  param_6)
                        mstore(add( expr_mpos_4,  64), param_7)
                        
                        mstore(expr_mpos_4,  64)
                        
                        finalize_allocation(expr_mpos_4, 96)
                        
                        let memPos_4 := mload(64)
                        return(memPos_4, sub(abi_encode_bytes(memPos_4, expr_mpos_4), memPos_4))
                    }
                    case 0xbbd05589 {
                        
                        
                        let value_1 := calldataload(4)
                        
                        let value_2 := calldataload(36)
                        
                        
                        let expr_mpos_5 :=  mload(64)
                        mstore( add(expr_mpos_5,  32), and(shl(248, value_1), shl(248, 255)))
                        mstore(add( expr_mpos_5,  33), and(shl(240, value_2), shl(240, 65535)))
                        mstore(add( expr_mpos_5,  35), calldataload(68))
                        
                        mstore(expr_mpos_5,  35)
                        
                        finalize_allocation(expr_mpos_5, 67)
                        
                        let memPos_5 := mload(64)
                        return(memPos_5, sub(abi_encode_bytes(memPos_5, expr_mpos_5), memPos_5))
                    }
                    case 0xeb90f459 {
                        
                        
                        let offset_1 := calldataload(4)
                        
                        let value0_2, value1_2 := abi_decode_bytes_calldata(add(4, offset_1), calldatasize())
                        
                        let memPtr := mload(64)
                        finalize_allocation(memPtr, add(and(add(value1_2, 31), not(31)), 32))
                        mstore(memPtr, value1_2)
                        let dst := add(memPtr, 32)
                        if gt(add(value0_2, value1_2), calldatasize()) { revert(0, 0) }
                        calldatacopy(dst, value0_2, value1_2)
                        mstore(add(add(memPtr, value1_2), 32), 0)
                        
                        let var_2 :=  keccak256( dst, mload( memPtr))
                        
                        let memPos_6 := mload(64)
                        mstore(memPos_6, var_2)
                        return(memPos_6, 32)
                    }
                    case 0xf0f00925 {
                        
                        
                        let value_3 := calldataload(36)
                        let _4 := and(value_3, sub(shl(160, 1), 1))
                        if iszero(eq(value_3, _4)) { revert(0, 0) }
                        let offset_2 := calldataload(100)
                        
                        let value3, value4 := abi_decode_bytes_calldata(add(4, offset_2), calldatasize())
                        
                        let expr_mpos_6 :=  mload(64)
                        mstore( add(expr_mpos_6,  32), calldataload(4))
                        mstore(add( expr_mpos_6,  64), _4)
                        mstore(add( expr_mpos_6,  96), calldataload(68))
                        mstore(add( expr_mpos_6,  128), 128)
                        mstore(add( expr_mpos_6,  160), value4)
                        calldatacopy(add( expr_mpos_6,  192), value3, value4)
                        mstore(add(add( expr_mpos_6,  value4), 192), 0)
                        
                        let _5 := add(sub( add( expr_mpos_6,  and(add(value4, 31), not(31))),  expr_mpos_6),  192)
                        
                        mstore(expr_mpos_6, add(_5,  not(31)))
                        
                        finalize_allocation(expr_mpos_6, _5)
                        
                        let memPos_7 := mload(64)
                        return(memPos_7, sub(abi_encode_bytes(memPos_7, expr_mpos_6), memPos_7))
                    }
                }
                revert(0, 0)
            }
            function abi_decode_bytes_calldata(offset, end) -> arrayPos, length
            {
                if iszero(slt(add(offset, 0x1f), end)) { revert(0, 0) }
                length := calldataload(offset)
                
                arrayPos := add(offset, 0x20)
                if gt(add(add(offset, length), 0x20), end) { revert(0, 0) }
            }
            function abi_decode_uint256t_uint256(dataEnd) -> value0, value1
            {
                if slt(add(dataEnd, not(3)), 64) { revert(0, 0) }
                value0 := calldataload(4)
                value1 := calldataload(36)
            }
            function abi_encode_bytes(headStart, value0) -> tail
            {
                mstore(headStart, 32)
                let length := mload(value0)
                mstore(add(headStart, 32), length)
                mcopy(add(headStart, 64), add(value0, 32), length)
                mstore(add(add(headStart, length), 64), 0)
                tail := add(add(headStart, and(add(length, 31), not(31))), 64)
            }
            function finalize_allocation(memPtr, size)
            {
                let newFreePtr := add(memPtr, and(add(size, 31), not(31)))
                
                mstore(64, newFreePtr)
            }
        }
        data ".metadata" hex"a26469706673582212202da795b0b6941083e5f16ff6678aaf0f973eb166d854c426f4372d1ece5607ce64736f6c634300081c0033"
    }
}