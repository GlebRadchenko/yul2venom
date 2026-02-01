object "SoladyToken_216" {
    code {
        {
            
            mstore(64, memoryguard(0x80))
            
            let programSize := datasize("SoladyToken_216")
            let argSize := sub(codesize(), programSize)
            let memoryDataOffset := allocate_memory(argSize)
            codecopy(memoryDataOffset, programSize, argSize)
            let _1 := add(memoryDataOffset, argSize)
            if slt(sub(_1, memoryDataOffset), 96)
            {
                revert( 0, 0)
            }
            
            let offset := mload(memoryDataOffset)
            if gt(offset, sub(shl(64, 1), 1))
            {
                revert( 0, 0)
            }
            
            let value0 := abi_decode_string_fromMemory(add(memoryDataOffset, offset), _1)
            let offset_1 := mload(add(memoryDataOffset, 32))
            if gt(offset_1, sub(shl(64, 1), 1))
            {
                revert( 0, 0)
            }
            
            let value1 := abi_decode_string_fromMemory(add(memoryDataOffset, offset_1), _1)
            let value := mload(add(memoryDataOffset, 64))
            let _2 := and(value, 0xff)
            if iszero(eq(value, _2))
            {
                revert( 0, 0)
            }
            
            let newLen := mload(value0)
            if gt(newLen, sub(shl(64, 1), 1))
            {
                mstore( 0,  shl(224, 0x4e487b71))
                mstore(4, 0x41)
                revert( 0,  0x24)
            }
            let _3 := sload( 0)
            
            let length := shr(1, _3)
            let outOfPlaceEncoding := and(_3, 1)
            if iszero(outOfPlaceEncoding) { length := and(length, 0x7f) }
            if eq(outOfPlaceEncoding, lt(length, 32))
            {
                mstore( 0,  shl(224, 0x4e487b71))
                mstore(4, 0x22)
                revert( 0,  0x24)
            }
            if gt(length, 31)
            {
                mstore( 0, 0)
                
                let data := keccak256( 0,  32)
                let deleteStart := add(data, shr(5, add(newLen, 31)))
                if lt(newLen, 32) { deleteStart := data }
                let _4 := add(data, shr(5, add(length, 31)))
                let start := deleteStart
                for { } lt(start, _4) { start := add(start, 1) }
                {
                    sstore(start,  0)
                }
            }
            
            let srcOffset := 32
            switch gt(newLen, 31)
            case 1 {
                let loopEnd := and(newLen, not(31))
                mstore( 0, 0)
                
                let dstPtr := keccak256( 0,  srcOffset)
                let i :=  0
                
                for { } lt(i, loopEnd) { i := add(i, 32) }
                {
                    sstore(dstPtr, mload(add(value0, srcOffset)))
                    dstPtr := add(dstPtr, 1)
                    srcOffset := add(srcOffset, 32)
                }
                if lt(loopEnd, newLen)
                {
                    let lastValue := mload(add(value0, srcOffset))
                    sstore(dstPtr, and(lastValue, not(shr(and(shl(3, newLen), 248), not(0)))))
                }
                sstore( 0,  add(shl(1, newLen), 1))
            }
            default {
                let value_1 :=  0
                
                if newLen
                {
                    value_1 := mload(add(value0, srcOffset))
                }
                sstore( 0,  or(and(value_1, not(shr(shl(3, newLen), not(0)))), shl(1, newLen)))
            }
            let newLen_1 := mload(value1)
            if gt(newLen_1, sub(shl(64, 1), 1))
            {
                mstore( 0,  shl(224, 0x4e487b71))
                mstore(4, 0x41)
                revert( 0,  0x24)
            }
            let _5 := sload(1)
            let length_1 := shr(1, _5)
            let outOfPlaceEncoding_1 := and(_5, 1)
            if iszero(outOfPlaceEncoding_1)
            {
                length_1 := and(length_1, 0x7f)
            }
            if eq(outOfPlaceEncoding_1, lt(length_1, 32))
            {
                mstore( 0,  shl(224, 0x4e487b71))
                mstore(4, 0x22)
                revert( 0,  0x24)
            }
            if gt(length_1, 31)
            {
                mstore( 0,  1)
                let data_1 := keccak256( 0,  32)
                let deleteStart_1 := add(data_1, shr(5, add(newLen_1, 31)))
                if lt(newLen_1, 32) { deleteStart_1 := data_1 }
                let _6 := add(data_1, shr(5, add(length_1, 31)))
                let start_1 := deleteStart_1
                for { } lt(start_1, _6) { start_1 := add(start_1, 1) }
                {
                    sstore(start_1,  0)
                }
            }
            
            let srcOffset_1 := 32
            switch gt(newLen_1, 31)
            case 1 {
                let loopEnd_1 := and(newLen_1, not(31))
                mstore( 0,  1)
                let dstPtr_1 := keccak256( 0,  srcOffset_1)
                let i_1 :=  0
                
                for { } lt(i_1, loopEnd_1) { i_1 := add(i_1, 32) }
                {
                    sstore(dstPtr_1, mload(add(value1, srcOffset_1)))
                    dstPtr_1 := add(dstPtr_1, 1)
                    srcOffset_1 := add(srcOffset_1, 32)
                }
                if lt(loopEnd_1, newLen_1)
                {
                    let lastValue_1 := mload(add(value1, srcOffset_1))
                    sstore(dstPtr_1, and(lastValue_1, not(shr(and(shl(3, newLen_1), 248), not(0)))))
                }
                sstore(1, add(shl(1, newLen_1), 1))
            }
            default {
                let value_2 :=  0
                
                if newLen_1
                {
                    value_2 := mload(add(value1, srcOffset_1))
                }
                sstore(1, or(and(value_2, not(shr(shl(3, newLen_1), not(0)))), shl(1, newLen_1)))
            }
            let _7 := sload( 0x02)
            
            sstore( 0x02,  or(or(and(_7, not(sub(shl(168, 1), 1))), _2), and(shl(8,  caller()),  sub(shl(168, 1), 256))))
            let _8 := mload(64)
            let _9 := datasize("SoladyToken_216_deployed")
            codecopy(_8, dataoffset("SoladyToken_216_deployed"), _9)
            return(_8, _9)
        }
        function allocate_memory(size) -> memPtr
        {
            memPtr := mload(64)
            let newFreePtr := add(memPtr, and(add(size, 31), not(31)))
            if or(gt(newFreePtr, sub(shl(64, 1), 1)), lt(newFreePtr, memPtr))
            {
                mstore( 0,  shl(224, 0x4e487b71))
                mstore(4, 0x41)
                revert( 0,  0x24)
            }
            mstore(64, newFreePtr)
        }
        function abi_decode_string_fromMemory(offset, end) -> array
        {
            if iszero(slt(add(offset, 0x1f), end)) { revert(0, 0) }
            let length := mload(offset)
            if gt(length, sub(shl(64, 1), 1))
            {
                mstore( 0,  shl(224, 0x4e487b71))
                mstore(4, 0x41)
                revert( 0,  0x24)
            }
            let array_1 := allocate_memory(add(and(add(length, 0x1f), not(31)), 0x20))
            mstore(array_1, length)
            if gt(add(add(offset, length), 0x20), end)
            {
                revert( 0, 0)
            }
            
            mcopy(add(array_1, 0x20), add(offset, 0x20), length)
            mstore(add(add(array_1, length), 0x20),  0)
            
            array := array_1
        }
    }
    
    object "SoladyToken_216_deployed" {
        code {
            {
                
                mstore(64, memoryguard(0x80))
                
                {
                    switch shr(224, calldataload(0))
                    case 0x06fdde03 {
                        
                        
                        let converted := copy_array_from_storage_to_memory_string()
                        let memPos := mload(64)
                        return(memPos, sub(abi_encode_string(memPos, converted), memPos))
                    }
                    case 0x095ea7b3 {
                        
                        
                        let value0 := abi_decode_address_4839()
                        let value := calldataload(36)
                        
                        if iszero(or(xor(and(value0, sub(shl(160, 1), 1)), 0x22d473030f116ddee9f6b43ac78ba3), iszero(not(value))))
                        {
                            mstore( 0,  0x3f68539a)
                            revert(0x1c,  4)
                        }
                        
                        mstore( 32,  value0)
                        mstore(0x0c, 2136907552)
                        mstore( 0,  caller())
                        sstore(keccak256(0x0c, 0x34), value)
                        mstore( 0,  value)
                        log3( 0, 32,  63486140976153616755203102783360879283472101686154884697241723088393386309925, caller(), shr(96, mload(0x2c)))
                        
                        let memPos_1 := mload(64)
                        mstore(memPos_1, 1)
                        return(memPos_1, 32)
                    }
                    case 0x18160ddd {
                        
                        
                        let ret :=  sload(96006856662521017420)
                        
                        let memPos_2 := mload(64)
                        mstore(memPos_2, ret)
                        return(memPos_2, 32)
                    }
                    case 0x23b872dd {
                        
                        let param, param_1, param_2 := abi_decode_addresst_addresst_uint256(calldatasize())
                        
                        let usr$from := shl(96, param)
                        if iszero(eq(caller(), 0x22d473030f116ddee9f6b43ac78ba3))
                        {
                            mstore(0x20, caller())
                            mstore(0x0c, or(usr$from, 2136907552))
                            let usr$allowanceSlot := keccak256(0x0c, 0x34)
                            let usr$allowance := sload(usr$allowanceSlot)
                            if not(usr$allowance)
                            {
                                if gt(param_2, usr$allowance)
                                {
                                    mstore( 0,  0x13be252b)
                                    revert(0x1c,  4)
                                }
                                
                                sstore(usr$allowanceSlot, sub(usr$allowance, param_2))
                            }
                        }
                        mstore(0x0c, or(usr$from, 2275545506))
                        let usr$fromBalanceSlot := keccak256(0x0c, 0x20)
                        let usr$fromBalance := sload(usr$fromBalanceSlot)
                        if gt(param_2, usr$fromBalance)
                        {
                            mstore( 0,  0xf4d678b8)
                            revert(0x1c,  4)
                        }
                        
                        sstore(usr$fromBalanceSlot, sub(usr$fromBalance, param_2))
                        mstore( 0,  param_1)
                        let usr$toBalanceSlot := keccak256(0x0c, 0x20)
                        sstore(usr$toBalanceSlot, add(sload(usr$toBalanceSlot), param_2))
                        mstore(0x20, param_2)
                        log3(0x20, 0x20, 100389287136786176327247604509743168900146139575972864366142685224231313322991, and(param,  sub(shl(160, 1), 1)),  shr(96, mload(0x0c)))
                        
                        let memPos_3 := mload(64)
                        mstore(memPos_3,  0x01)
                        
                        return(memPos_3,  0x20)
                    }
                    case  0x313ce567 {
                        
                        
                        let value_1 := and(sload( 0x02),  0xff)
                        let memPos_4 := mload(64)
                        mstore(memPos_4, value_1)
                        return(memPos_4, 32)
                    }
                    case 0x3644e515 {
                        
                        
                        let _1 := copy_array_from_storage_to_memory_string()
                        
                        let var_nameHash :=  keccak256( add( _1,  0x20), mload( _1))
                        
                        let usr$m := mload( 64)
                        
                        mstore(usr$m, 63076024560530113402979550242307453568063438748328787417531900361828837441551)
                        mstore(add(usr$m,  0x20),  var_nameHash)
                        mstore(add(usr$m,  64),  0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6)
                        
                        mstore(add(usr$m, 0x60), chainid())
                        mstore(add(usr$m, 0x80), address())
                        let var_result := keccak256(usr$m, 0xa0)
                        
                        let memPos_5 := mload(64)
                        mstore(memPos_5, var_result)
                        return(memPos_5, 0x20)
                    }
                    case 0x40c10f19 {
                        
                        
                        let value0_1 := abi_decode_address_4839()
                        
                        require_helper_stringliteral_17d9( eq( caller(),  and(shr(8, sload( 0x02)),  sub(shl(160, 1), 1))))
                        
                        fun_mint(value0_1,  calldataload(36))
                        return(0, 0)
                    }
                    case 0x423f6cef {
                        
                        
                        let value0_2 := abi_decode_address_4839()
                        
                        fun_transfer( caller(),  value0_2,  calldataload(36))
                        let memPos_6 := mload(64)
                        mstore(memPos_6, 1)
                        return(memPos_6, 32)
                    }
                    case 0x42842e0e {
                        
                        let param_3, param_4, param_5 := abi_decode_addresst_addresst_uint256(calldatasize())
                        
                        fun_spendAllowance(param_3,  caller(),  param_5)
                        
                        fun_transfer(param_3, param_4, param_5)
                        
                        let memPos_7 := mload(64)
                        mstore(memPos_7,  0x01)
                        
                        return(memPos_7, 32)
                    }
                    case 0x42966c68 {
                        
                        
                        
                        fun_burn( caller(),  calldataload(4))
                        return(0, 0)
                    }
                    case 0x70a08231 {
                        
                        
                        let value0_3 := abi_decode_address_4839()
                        
                        mstore(0x0c, 2275545506)
                        mstore( 0,  value0_3)
                        let var_result_1 := sload(keccak256(0x0c,  32))
                        let memPos_8 := mload(64)
                        mstore(memPos_8, var_result_1)
                        return(memPos_8, 32)
                    }
                    case 0x79cc6790 {
                        
                        
                        let value0_4 := abi_decode_address_4839()
                        let value_2 := calldataload(36)
                        
                        fun_spendAllowance(value0_4,  caller(),  value_2)
                        
                        fun_burn(value0_4, value_2)
                        
                        return(0, 0)
                    }
                    case 0x7c88e3d9 {
                        
                        
                        let offset := calldataload(4)
                        
                        let value0_5, value1 := abi_decode_array_address_dyn_calldata(add(4, offset), calldatasize())
                        let offset_1 := calldataload(36)
                        
                        let value2, value3 := abi_decode_array_address_dyn_calldata(add(4, offset_1), calldatasize())
                        
                        require_helper_stringliteral_17d9( eq( caller(),  and(shr(8, sload( 0x02)),  sub(shl(160, 1), 1))))
                        
                        if iszero( eq(value1, value3))
                        
                        {
                            let memPtr := mload(64)
                            mstore(memPtr, shl(229, 4594637))
                            mstore(add(memPtr, 4), 32)
                            mstore(add(memPtr, 36), 15)
                            mstore(add(memPtr, 68), "Length mismatch")
                            revert(memPtr, 100)
                        }
                        
                        let var_i :=  0
                        
                        for { }
                         lt(var_i, value1)
                        
                        {
                            
                            var_i :=  add( var_i,  1)
                        }
                        
                        {
                            
                            let value_3 := calldataload( calldata_array_index_access_address_dyn_calldata(value0_5, value1, var_i))
                            
                            
                            
                            fun_mint(value_3,  calldataload( calldata_array_index_access_address_dyn_calldata(value2, value3, var_i)))
                        }
                        
                        return(0, 0)
                    }
                    case 0x7ecebe00 {
                        
                        
                        let value0_6 := abi_decode_address_4839()
                        
                        mstore(0x0c, 943158536)
                        mstore( 0,  value0_6)
                        let var_result_2 := sload(keccak256(0x0c,  32))
                        let memPos_9 := mload(64)
                        mstore(memPos_9, var_result_2)
                        return(memPos_9, 32)
                    }
                    case 0x8da5cb5b {
                        
                        
                        let value_4 := and(shr(8, sload( 2)),  sub(shl(160, 1), 1))
                        
                        let memPos_10 := mload(64)
                        mstore(memPos_10, value_4)
                        return(memPos_10, 32)
                    }
                    case 0x95d89b41 {
                        
                        
                        let memPtr_1 := mload(64)
                        let ret_1 := 0
                        let slotValue := sload( 0x01)
                        
                        let length := shr( 0x01,  slotValue)
                        let outOfPlaceEncoding := and(slotValue,  0x01)
                        
                        if iszero(outOfPlaceEncoding) { length := and(length, 0x7f) }
                        if eq(outOfPlaceEncoding, lt(length, 32))
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x22)
                            revert(0, 0x24)
                        }
                        mstore(memPtr_1, length)
                        switch outOfPlaceEncoding
                        case 0 {
                            mstore(add(memPtr_1, 32), and(slotValue, not(255)))
                            ret_1 := add(add(memPtr_1, shl(5, iszero(iszero(length)))), 32)
                        }
                        case 1 {
                            mstore(0,  0x01)
                            
                            let dataPos := keccak256(0, 32)
                            let i := 0
                            for { } lt(i, length) { i := add(i, 32) }
                            {
                                mstore(add(add(memPtr_1, i), 32), sload(dataPos))
                                dataPos := add(dataPos,  0x01)
                            }
                            
                            ret_1 := add(add(memPtr_1, i), 32)
                        }
                        let newFreePtr := add(memPtr_1, and(add(sub(ret_1, memPtr_1), 31), not(31)))
                        
                        mstore(64, newFreePtr)
                        let memPos_11 := mload(64)
                        return(memPos_11, sub(abi_encode_string(memPos_11, memPtr_1), memPos_11))
                    }
                    case 0xa9059cbb {
                        
                        
                        let value0_7 := abi_decode_address_4839()
                        let value_5 := calldataload(36)
                        
                        mstore(0x0c, 2275545506)
                        mstore( 0,  caller())
                        let usr$fromBalanceSlot_1 := keccak256(0x0c,  32)
                        
                        let usr$fromBalance_1 := sload(usr$fromBalanceSlot_1)
                        if gt(value_5, usr$fromBalance_1)
                        {
                            mstore( 0,  0xf4d678b8)
                            revert(0x1c,  4)
                        }
                        
                        sstore(usr$fromBalanceSlot_1, sub(usr$fromBalance_1, value_5))
                        mstore( 0,  value0_7)
                        let usr$toBalanceSlot_1 := keccak256(0x0c,  32)
                        
                        sstore(usr$toBalanceSlot_1, add(sload(usr$toBalanceSlot_1), value_5))
                        mstore( 32,  value_5)
                        log3( 32, 32,  100389287136786176327247604509743168900146139575972864366142685224231313322991, caller(), shr(96, mload(0x0c)))
                        
                        let memPos_12 := mload(64)
                        mstore(memPos_12, 1)
                        return(memPos_12, 32)
                    }
                    case 0xd505accf {
                        
                        
                        let value0_8 := abi_decode_address_4839()
                        let value1_1 := abi_decode_address()
                        let value_6 := calldataload(68)
                        let value_7 := calldataload(100)
                        let value_8 := calldataload(132)
                        
                        
                        let _2 := and(value1_1,  sub(shl(160, 1), 1))
                        
                        if iszero(or(xor(_2, 0x22d473030f116ddee9f6b43ac78ba3), iszero(not(value_6))))
                        {
                            mstore( 0,  0x3f68539a)
                            revert(0x1c,  4)
                        }
                        let _3 := copy_array_from_storage_to_memory_string()
                        
                        let var_nameHash_1 :=  keccak256( add( _3,  32), mload( _3))
                        
                        if gt(timestamp(), value_7)
                        {
                            mstore( 0,  0x1a15a3cc)
                            revert(0x1c,  4)
                        }
                        
                        let usr$m_1 := mload( 64)
                        
                        let var_owner := and(value0_8,  sub(shl(160, 1), 1))
                        
                        mstore(0x0e, 61810837821697)
                        mstore( 0,  var_owner)
                        let usr$nonceSlot := keccak256(0x0c,  32)
                        
                        let usr$nonceValue := sload(usr$nonceSlot)
                        mstore(usr$m_1, 63076024560530113402979550242307453568063438748328787417531900361828837441551)
                        let _4 := add(usr$m_1,  32)
                        
                        mstore(_4, var_nameHash_1)
                        let _5 := add(usr$m_1,  64)
                        
                        mstore(_5,  0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6)
                        
                        let _6 := add(usr$m_1,  96)
                        
                        mstore(_6, chainid())
                        let _7 := add(usr$m_1,  128)
                        
                        mstore(_7, address())
                        mstore(0x2e, keccak256(usr$m_1,  160))
                        
                        mstore(usr$m_1, 49955707469362902507454157297736832118868343942642399513960811609542965143241)
                        mstore(_4, var_owner)
                        mstore(_5, _2)
                        mstore(_6, value_6)
                        mstore(_7, usr$nonceValue)
                        mstore(add(usr$m_1,  160),  value_7)
                        mstore(0x4e, keccak256(usr$m_1,  192))
                        
                        mstore( 0,  keccak256(0x2c, 0x42))
                        mstore( 32,  and( 0xff,  value_8))
                        mstore( 64, calldataload(164))
                        
                        mstore( 96, calldataload(196))
                        
                        let usr$t := staticcall(gas(),  1, 0, 128, 32, 32)
                        
                        if iszero(eq(mload(returndatasize()), var_owner))
                        {
                            mstore( 0,  0xddafbaef)
                            revert(0x1c,  4)
                        }
                        
                        sstore(usr$nonceSlot, add(usr$nonceValue, usr$t))
                        mstore( 64,  or(shl(165, 0x03faf4f9), _2))
                        sstore(keccak256(0x2c, 0x34), value_6)
                        log3(_6,  32,  63486140976153616755203102783360879283472101686154884697241723088393386309925, var_owner, _2)
                        
                        return(0, 0)
                    }
                    case 0xdd62ed3e {
                        
                        
                        let value0_9 := abi_decode_address_4839()
                        let ret_2 := fun_allowance(value0_9, abi_decode_address())
                        let memPos_13 := mload(64)
                        mstore(memPos_13, ret_2)
                        return(memPos_13, 32)
                    }
                }
                revert(0, 0)
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
            function abi_decode_address_4839() -> value
            {
                value := calldataload(4)
                
            }
            function abi_decode_address() -> value
            {
                value := calldataload(36)
                
            }
            function abi_decode_addresst_addresst_uint256(dataEnd) -> value0, value1, value2
            {
                if slt(add(dataEnd, not(3)), 96) { revert(0, 0) }
                let value := calldataload(4)
                
                value0 := value
                let value_1 := calldataload(36)
                
                value1 := value_1
                value2 := calldataload(68)
            }
            function abi_decode_array_address_dyn_calldata(offset, end) -> arrayPos, length
            {
                if iszero(slt(add(offset, 0x1f), end)) { revert(0, 0) }
                length := calldataload(offset)
                
                arrayPos := add(offset, 0x20)
                if gt(add(add(offset, shl(5, length)), 0x20), end) { revert(0, 0) }
            }
            function copy_array_from_storage_to_memory_string() -> memPtr
            {
                memPtr := mload(64)
                let ret := 0
                let slotValue := sload(0)
                let length := shr(1, slotValue)
                let outOfPlaceEncoding := and(slotValue, 1)
                if iszero(outOfPlaceEncoding) { length := and(length, 0x7f) }
                if eq(outOfPlaceEncoding, lt(length, 32))
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x22)
                    revert(0, 0x24)
                }
                mstore(memPtr, length)
                switch outOfPlaceEncoding
                case 0 {
                    mstore(add(memPtr, 32), and(slotValue, not(255)))
                    ret := add(add(memPtr, shl(5, iszero(iszero(length)))), 32)
                }
                case 1 {
                    mstore(0, 0)
                    let dataPos := keccak256(0, 32)
                    let i := 0
                    for { } lt(i, length) { i := add(i, 32) }
                    {
                        mstore(add(add(memPtr, i), 32), sload(dataPos))
                        dataPos := add(dataPos, 1)
                    }
                    ret := add(add(memPtr, i), 32)
                }
                let newFreePtr := add(memPtr, and(add(sub(ret, memPtr), 31), not(31)))
                
                mstore(64, newFreePtr)
            }
            function require_helper_stringliteral_17d9(condition)
            {
                if iszero(condition)
                {
                    let memPtr := mload(64)
                    mstore(memPtr, shl(229, 4594637))
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 10)
                    mstore(add(memPtr, 68), "Only owner")
                    revert(memPtr, 100)
                }
            }
            function calldata_array_index_access_address_dyn_calldata(base_ref, length, index) -> addr
            {
                if iszero(lt(index, length))
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x32)
                    revert(0, 0x24)
                }
                addr := add(base_ref, shl(5, index))
            }
            /// @ast-id 370 @src 0:7570:8065  "function allowance(address owner, address spender)..."
            function fun_allowance(var_owner, var_spender) -> var_result
            {
                
                var_result :=  0
                
                if  eq( and( var_spender,  sub(shl(160, 1), 1)),  0x22d473030f116ddee9f6b43ac78ba3)
                
                {
                    
                    var_result :=  not(0)
                    
                    leave
                }
                
                mstore(0x20, var_spender)
                mstore(0x0c, 2136907552)
                mstore( 0,  var_owner)
                var_result := sload(keccak256(0x0c, 0x34))
            }
            /// @ast-id 602 @src 0:22620:23792  "function _mint(address to, uint256 amount) internal virtual {..."
            function fun_mint(var_to, var_amount)
            {
                
                let usr$totalSupplyBefore := sload(96006856662521017420)
                let usr$totalSupplyAfter := add(usr$totalSupplyBefore, var_amount)
                if lt(usr$totalSupplyAfter, usr$totalSupplyBefore)
                {
                    mstore(0x00, 0xe5cfe957)
                    revert(0x1c, 0x04)
                }
                sstore(96006856662521017420, usr$totalSupplyAfter)
                mstore(0x0c, 2275545506)
                mstore(0x00, var_to)
                let usr$toBalanceSlot := keccak256(0x0c, 0x20)
                sstore(usr$toBalanceSlot, add(sload(usr$toBalanceSlot), var_amount))
                mstore(0x20, var_amount)
                log3(0x20, 0x20, 100389287136786176327247604509743168900146139575972864366142685224231313322991, 0x00, shr(96, mload(0x0c)))
            }
            /// @ast-id 654 @src 0:25665:27061  "function _transfer(address from, address to, uint256 amount) internal virtual {..."
            function fun_transfer(var_from, var_to, var_amount)
            {
                
                mstore(0x0c, or(shl(96, var_from), 2275545506))
                let usr$fromBalanceSlot := keccak256(0x0c, 0x20)
                let usr$fromBalance := sload(usr$fromBalanceSlot)
                if gt(var_amount, usr$fromBalance)
                {
                    mstore(0x00, 0xf4d678b8)
                    revert(0x1c, 0x04)
                }
                sstore(usr$fromBalanceSlot, sub(usr$fromBalance, var_amount))
                mstore(0x00, var_to)
                let usr$toBalanceSlot := keccak256(0x0c, 0x20)
                sstore(usr$toBalanceSlot, add(sload(usr$toBalanceSlot), var_amount))
                mstore(0x20, var_amount)
                log3(0x20, 0x20, 100389287136786176327247604509743168900146139575972864366142685224231313322991, and(var_from,  sub(shl(160, 1), 1)),  shr(96, mload(0x0c)))
            }
            /// @ast-id 675 @src 0:27435:28522  "function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {..."
            function fun_spendAllowance(var_owner, var_spender, var_amount)
            {
                
                if  eq( and( var_spender,  sub(shl(160, 1), 1)),  0x22d473030f116ddee9f6b43ac78ba3)
                
                {
                    
                    leave
                }
                
                mstore(0x20, var_spender)
                mstore(0x0c, 2136907552)
                mstore(0x00, var_owner)
                let usr$allowanceSlot := keccak256(0x0c, 0x34)
                let usr$allowance := sload(usr$allowanceSlot)
                if not(usr$allowance)
                {
                    if gt(var_amount, usr$allowance)
                    {
                        mstore(0x00, 0x13be252b)
                        revert(0x1c, 0x04)
                    }
                    sstore(usr$allowanceSlot, sub(usr$allowance, var_amount))
                }
            }
            /// @ast-id 630 @src 0:24198:25317  "function _burn(address from, uint256 amount) internal virtual {..."
            function fun_burn(var_from, var_amount)
            {
                
                mstore(0x0c, 2275545506)
                mstore(0x00, var_from)
                let usr$fromBalanceSlot := keccak256(0x0c, 0x20)
                let usr$fromBalance := sload(usr$fromBalanceSlot)
                if gt(var_amount, usr$fromBalance)
                {
                    mstore(0x00, 0xf4d678b8)
                    revert(0x1c, 0x04)
                }
                sstore(usr$fromBalanceSlot, sub(usr$fromBalance, var_amount))
                sstore(96006856662521017420, sub(sload(96006856662521017420), var_amount))
                mstore(0x00, var_amount)
                log3(0x00, 0x20, 100389287136786176327247604509743168900146139575972864366142685224231313322991, and(var_from,  sub(shl(160, 1), 1)),  0x00)
            }
        }
        data ".metadata" hex"a2646970667358221220b4615b8496a98f8efd46ad82c68042ddd6370c48ba5b201c28dada81c7840f4a64736f6c634300081c0033"
    }
}