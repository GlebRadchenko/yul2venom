object "DataStructures_270" {
    code {
        {
            
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            
            let _2 := datasize("DataStructures_270_deployed")
            codecopy(_1, dataoffset("DataStructures_270_deployed"), _2)
            return(_1, _2)
        }
    }
    
    object "DataStructures_270_deployed" {
        code {
            {
                
                mstore(64, memoryguard(0x80))
                
                {
                    switch shr(224, calldataload(0))
                    case 0x3e715a46 {
                        
                        
                        let offset := calldataload(4)
                        
                        if iszero(slt(add(offset, 35), calldatasize())) { revert(0, 0) }
                        let length := calldataload(add(4, offset))
                        
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
                            let memPtr_1 :=  0
                            
                            let memPtr_2 := mload(64)
                            finalize_allocation_4288(memPtr_2)
                            memPtr_1 := memPtr_2
                            mstore(memPtr_2,  0)
                            
                            mstore(add(memPtr_2, 32),  0)
                            
                            mstore(add(add(memPtr, i), 32), memPtr_2)
                        }
                        
                        let var_i :=  0
                        
                        for { }
                         lt(var_i, length)
                        
                        {
                            
                            var_i :=  add( var_i,  1)
                        }
                        
                        {
                            
                            let value := calldataload( calldata_array_index_access_struct_SimpleStruct_calldata_dyn_calldata(arrayPos, length, var_i))
                            
                            let product := shl(1, value)
                            if iszero(or(iszero(value), eq( 0x02,  div(product, value))))
                            {
                                mstore(0, shl(224, 0x4e487b71))
                                mstore(4, 0x11)
                                revert(0, 36)
                            }
                            let value_1 := calldataload( add( calldata_array_index_access_struct_SimpleStruct_calldata_dyn_calldata(arrayPos, length, var_i),  32))
                            let product_1 := shl(1, value_1)
                            if iszero(or(iszero(value_1), eq( 0x02,  div(product_1, value_1))))
                            {
                                mstore(0, shl(224, 0x4e487b71))
                                mstore(4, 0x11)
                                revert(0, 36)
                            }
                            let memPtr_3 := mload(64)
                            finalize_allocation_4288(memPtr_3)
                            mstore(memPtr_3, product)
                            mstore( add(memPtr_3,  32), product_1)
                            
                            mstore(memory_array_index_access_struct_SimpleStruct_dyn(memPtr, var_i), memPtr_3)
                            pop(memory_array_index_access_struct_SimpleStruct_dyn(memPtr, var_i))
                        }
                        
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
                        
                        let _4 := slt(add(calldatasize(), not(3)), 64)
                        if _4 { revert(0, 0) }
                        _4 := 0
                        
                        let var :=  checked_add_uint256( calldataload(4), calldataload( 36))
                        
                        let memPos_1 := mload(64)
                        mstore(memPos_1, var)
                        return(memPos_1,  32)
                    }
                    case  0x890fa2fa {
                        
                        
                        let offset_1 := calldataload(4)
                        
                        let value0, value1 := abi_decode_bytes_calldata(add(4, offset_1), calldatasize())
                        let offset_2 := calldataload(36)
                        
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
                        
                        
                        let offset_3 := calldataload(4)
                        
                        let value0_1, value1_1 := abi_decode_bytes_calldata(add(4, offset_3), calldatasize())
                        let memPos_3 := mload(64)
                        mstore(memPos_3, value1_1)
                        return(memPos_3, 32)
                    }
                    case 0xba373f8e {
                        
                        
                        let value_2 := calldataload(4)
                        pop(allocate_and_zero_memory_struct_struct_SimpleStruct())
                        let memPtr_4 := mload(64)
                        finalize_allocation_4288(memPtr_4)
                        mstore(memPtr_4, value_2)
                        
                        let _10 := add(memPtr_4,  32)
                        mstore(_10, calldataload(36))
                        let memPos_4 := mload(64)
                        mstore(memPos_4, value_2)
                        mstore(add(memPos_4, 32), mload(_10))
                        return(memPos_4, 64)
                    }
                    case 0xd878faca {
                        
                        
                        if gt(164, calldatasize()) { revert(0, 0) }
                        
                        let var_sum :=  0
                        
                        let var_i_1 :=  0
                        
                        for { }
                         1
                        
                        {
                            
                            var_i_1 :=  add( var_i_1,  1)
                        }
                        
                        {
                            
                            let _11 := iszero(lt(var_i_1,  0x05))
                            
                            if _11 { break }
                            
                            _11 := 0
                            
                            var_sum := checked_add_uint256(var_sum,  calldataload(add(4, shl( 0x05,  var_i_1))))
                        }
                        let memPos_5 := mload(64)
                        mstore(memPos_5, var_sum)
                        return(memPos_5, 32)
                    }
                    case 0xf82b8963 {
                        
                        let _12 := slt(add(calldatasize(), not(3)), 96)
                        if _12 { revert(0, 0) }
                        _12 := 0
                        
                        let expr := checked_add_uint256( calldataload(4), calldataload( 36))
                        
                        let var_1 :=  checked_add_uint256(expr,  calldataload( 68))
                        
                        let memPos_6 := mload(64)
                        mstore(memPos_6, var_1)
                        return(memPos_6,  32)
                    }
                    case  0xfbe73ab3 {
                        
                        
                        let var_size := calldataload(4)
                        
                        if  gt(var_size,  0x64)
                        
                        {
                            
                            var_size :=  0x64
                        }
                        
                        let _13 := array_allocation_size_array_struct_SimpleStruct_dyn(var_size)
                        let memPtr_5 := mload(64)
                        finalize_allocation(memPtr_5, _13)
                        mstore(memPtr_5, var_size)
                        let dataSize := array_allocation_size_array_struct_SimpleStruct_dyn(var_size)
                        let dataStart := add(memPtr_5, 32)
                        calldatacopy(dataStart, calldatasize(), add(dataSize, not(31)))
                        
                        let var_i_2 :=  0
                        
                        for { }
                         lt(var_i_2, var_size)
                        
                        {
                            
                            var_i_2 :=  add( var_i_2,  1)
                        }
                        
                        {
                            
                            let product_2 := shl(1, var_i_2)
                            if iszero(or(iszero(var_i_2), eq( 0x02,  div(product_2, var_i_2))))
                            {
                                mstore(0, shl(224, 0x4e487b71))
                                mstore(4, 0x11)
                                revert(0, 0x24)
                            }
                            mstore( memory_array_index_access_struct_SimpleStruct_dyn(memPtr_5, var_i_2),  product_2)
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
                        
                        
                        let offset_4 := calldataload(4)
                        
                        if iszero(slt(add(offset_4, 35), calldatasize())) { revert(0, 0) }
                        let length_4 := calldataload(add(4, offset_4))
                        
                        if gt(add(add(offset_4, shl(5, length_4)), 36), calldatasize()) { revert(0, 0) }
                        
                        let var_sum_1 :=  0
                        
                        let var_i_3 :=  0
                        
                        for { }
                         1
                        
                        {
                            
                            var_i_3 :=  add( var_i_3,  1)
                        }
                        
                        {
                            
                            let _14 := iszero(lt(var_i_3,  length_4))
                            
                            if _14 { break }
                            
                            _14 := 0
                            
                            var_sum_1 := checked_add_uint256(var_sum_1,  calldataload(add(add(offset_4, shl(5, var_i_3)), 36)))
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
                
                arrayPos := add(offset, 0x20)
                if gt(add(add(offset, length), 0x20), end) { revert(0, 0) }
            }
            function finalize_allocation_4288(memPtr)
            {
                let newFreePtr := add(memPtr, 64)
                
                mstore(64, newFreePtr)
            }
            function finalize_allocation(memPtr, size)
            {
                let newFreePtr := add(memPtr, and(add(size, 31), not(31)))
                
                mstore(64, newFreePtr)
            }
            function array_allocation_size_array_struct_SimpleStruct_dyn(length) -> size
            {
                
                size := add(shl(5, length), 0x20)
            }
            function allocate_and_zero_memory_struct_struct_SimpleStruct() -> memPtr
            {
                let memPtr_1 := mload(64)
                finalize_allocation_4288(memPtr_1)
                memPtr := memPtr_1
                mstore(memPtr_1,  0)
                
                mstore(add(memPtr_1, 32),  0)
            }
            
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