object "ExternalLibraryTest_320" {
    code {
        {
            
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            
            let _2 := datasize("ExternalLibraryTest_320_deployed")
            codecopy(_1, dataoffset("ExternalLibraryTest_320_deployed"), _2)
            return(_1, _2)
        }
    }
    
    object "ExternalLibraryTest_320_deployed" {
        code {
            {
                
                mstore(64, memoryguard(0x80))
                
                {
                    switch shr(224, calldataload(0))
                    case 0x6245a978 {
                        
                        let param, param_1 := abi_decode_array_uint256_dyn_calldata(calldatasize())
                        
                        let var_arrMem_mpos :=  abi_decode_available_length_array_uint256_dyn( param, param_1,  calldatasize())
                        
                        let _1 :=  mload(64)
                        
                        mstore(_1,  shl(225, 0x1dfb6f4b))
                        
                        let _2 := delegatecall(gas(),  linkersymbol("foundry/src/bench/ExternalLibrary.sol:ArrayLib"),  _1, sub(abi_encode_array_uint256_dyn(add(_1,  4),  var_arrMem_mpos), _1), _1, 32)
                        if iszero(_2)
                        {
                            
                            let pos := mload(64)
                            returndatacopy(pos, 0, returndatasize())
                            revert(pos, returndatasize())
                        }
                        
                        let expr :=  0
                        
                        if _2
                        {
                            let _3 := 32
                            if gt(32, returndatasize()) { _3 := returndatasize() }
                            finalize_allocation(_1, _3)
                            let value0 :=  0
                            if slt(sub( add(_1, _3), _1),  32) { revert(0, 0) }
                            value0 := mload( _1)
                            expr := value0
                        }
                        
                        let memPos := mload(64)
                        mstore(memPos, expr)
                        return(memPos,  32)
                    }
                    case  0x66c8f273 {
                        
                        
                        
                        let expr_address :=  linkersymbol("foundry/src/bench/ExternalLibrary.sol:MathLib")
                        
                        let _4 :=  mload(64)
                        
                        mstore(_4,  shl(224, 0x771602f7))
                        mstore( add(_4,  4), calldataload(4))
                        mstore(add( _4,  36), calldataload(36))
                        
                        let _5 := delegatecall(gas(), expr_address, _4,  68,  _4,  32)
                        
                        if iszero(_5)
                        {
                            
                            let pos_1 := mload(64)
                            returndatacopy(pos_1, 0, returndatasize())
                            revert(pos_1, returndatasize())
                        }
                        
                        let expr_1 :=  0
                        
                        if _5
                        {
                            let _6 :=  32
                            
                            if gt( 32,  returndatasize()) { _6 := returndatasize() }
                            finalize_allocation(_4, _6)
                            let value0_1 :=  0
                            if slt(sub( add(_4, _6), _4),  32) { revert(0, 0) }
                            value0_1 := mload( _4)
                            expr_1 := value0_1
                        }
                        
                        let _7 :=  mload(64)
                        
                        mstore(_7,  shl(226, 0x32292b27))
                        mstore( add(_7,  4), expr_1)
                        mstore(add( _7,  36), calldataload(68))
                        
                        let _8 := delegatecall(gas(), expr_address, _7,  68,  _7,  32)
                        
                        if iszero(_8)
                        {
                            
                            let pos_2 := mload(64)
                            returndatacopy(pos_2, 0, returndatasize())
                            revert(pos_2, returndatasize())
                        }
                        
                        let expr_2 :=  0
                        
                        if _8
                        {
                            let _9 :=  32
                            
                            if gt( 32,  returndatasize()) { _9 := returndatasize() }
                            finalize_allocation(_7, _9)
                            let value0_2 :=  0
                            if slt(sub( add(_7, _9), _7),  32) { revert(0, 0) }
                            value0_2 := mload( _7)
                            expr_2 := value0_2
                        }
                        
                        let memPos_1 := mload(64)
                        mstore(memPos_1, expr_2)
                        return(memPos_1, 32)
                    }
                    case 0x7c3ffef2 {
                        
                        let param_2, param_3 := abi_decode_uint256t_uint256(calldatasize())
                        
                        let _10 :=  mload(64)
                        
                        mstore(_10,  shl(224, 0x771602f7))
                        mstore( add(_10,  4), param_2)
                        mstore(add( _10,  36), param_3)
                        
                        let _11 := delegatecall(gas(),  linkersymbol("foundry/src/bench/ExternalLibrary.sol:MathLib"),  _10, 68, _10,  32)
                        
                        if iszero(_11)
                        {
                            
                            let pos_3 := mload(64)
                            returndatacopy(pos_3, 0, returndatasize())
                            revert(pos_3, returndatasize())
                        }
                        
                        let expr_3 :=  0
                        
                        if _11
                        {
                            let _12 :=  32
                            
                            if gt( 32,  returndatasize()) { _12 := returndatasize() }
                            finalize_allocation(_10, _12)
                            let value0_3 :=  0
                            if slt(sub( add(_10, _12), _10),  32) { revert(0, 0) }
                            value0_3 := mload( _10)
                            expr_3 := value0_3
                        }
                        
                        sstore(0, expr_3)
                        let memPos_2 := mload(64)
                        mstore(memPos_2, expr_3)
                        return(memPos_2, 32)
                    }
                    case 0xabcc11d8 {
                        
                        
                        let _13 := sload(0)
                        let memPos_3 := mload(64)
                        mstore(memPos_3, _13)
                        return(memPos_3, 32)
                    }
                    case 0xbd2c7195 {
                        
                        let param_4, param_5 := abi_decode_uint256t_uint256(calldatasize())
                        
                        let _14 :=  mload(64)
                        
                        mstore(_14,  shl(226, 0x32292b27))
                        mstore( add(_14,  4), param_4)
                        mstore(add( _14,  36), param_5)
                        
                        let _15 := delegatecall(gas(),  linkersymbol("foundry/src/bench/ExternalLibrary.sol:MathLib"),  _14, 68, _14,  32)
                        
                        if iszero(_15)
                        {
                            
                            let pos_4 := mload(64)
                            returndatacopy(pos_4, 0, returndatasize())
                            revert(pos_4, returndatasize())
                        }
                        
                        let expr_4 :=  0
                        
                        if _15
                        {
                            let _16 :=  32
                            
                            if gt( 32,  returndatasize()) { _16 := returndatasize() }
                            finalize_allocation(_14, _16)
                            let value0_4 :=  0
                            if slt(sub( add(_14, _16), _14),  32) { revert(0, 0) }
                            value0_4 := mload( _14)
                            expr_4 := value0_4
                        }
                        
                        let memPos_4 := mload(64)
                        mstore(memPos_4, expr_4)
                        return(memPos_4, 32)
                    }
                    case 0xbe1beee0 {
                        
                        let param_6, param_7 := abi_decode_array_uint256_dyn_calldata(calldatasize())
                        
                        let var_arrMem_mpos_1 :=  abi_decode_available_length_array_uint256_dyn( param_6, param_7,  calldatasize())
                        
                        let _17 :=  mload(64)
                        
                        mstore(_17,  shl(225, 13266375))
                        
                        let _18 := delegatecall(gas(),  linkersymbol("foundry/src/bench/ExternalLibrary.sol:ArrayLib"),  _17, sub(abi_encode_array_uint256_dyn(add(_17,  4),  var_arrMem_mpos_1), _17), _17, 32)
                        if iszero(_18)
                        {
                            
                            let pos_5 := mload(64)
                            returndatacopy(pos_5, 0, returndatasize())
                            revert(pos_5, returndatasize())
                        }
                        
                        let expr_5 :=  0
                        
                        if _18
                        {
                            let _19 := 32
                            if gt(32, returndatasize()) { _19 := returndatasize() }
                            finalize_allocation(_17, _19)
                            let value0_5 :=  0
                            if slt(sub( add(_17, _19), _17),  32) { revert(0, 0) }
                            value0_5 := mload( _17)
                            expr_5 := value0_5
                        }
                        
                        let memPos_5 := mload(64)
                        mstore(memPos_5, expr_5)
                        return(memPos_5,  32)
                    }
                    case  0xbe2e7302 {
                        
                        let param_8, param_9 := abi_decode_uint256t_uint256(calldatasize())
                        let sum := add(param_8, param_9)
                        if gt(param_8, sum)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        let memPos_6 := mload(64)
                        mstore(memPos_6, sum)
                        return(memPos_6, 32)
                    }
                    case 0xc1ade926 {
                        
                        let param_10, param_11 := abi_decode_uint256t_uint256(calldatasize())
                        
                        let _20 :=  mload(64)
                        
                        mstore(_20,  shl(224, 0x2e4c697f))
                        mstore( add(_20,  4), param_10)
                        mstore(add( _20,  36), param_11)
                        
                        let _21 := delegatecall(gas(),  linkersymbol("foundry/src/bench/ExternalLibrary.sol:MathLib"),  _20, 68, _20,  32)
                        
                        if iszero(_21)
                        {
                            
                            let pos_6 := mload(64)
                            returndatacopy(pos_6, 0, returndatasize())
                            revert(pos_6, returndatasize())
                        }
                        
                        let expr_6 :=  0
                        
                        if _21
                        {
                            let _22 :=  32
                            
                            if gt( 32,  returndatasize()) { _22 := returndatasize() }
                            finalize_allocation(_20, _22)
                            let value0_6 :=  0
                            if slt(sub( add(_20, _22), _20),  32) { revert(0, 0) }
                            value0_6 := mload( _20)
                            expr_6 := value0_6
                        }
                        
                        let memPos_7 := mload(64)
                        mstore(memPos_7, expr_6)
                        return(memPos_7, 32)
                    }
                }
                revert(0, 0)
            }
            function abi_decode_array_uint256_dyn_calldata(dataEnd) -> value0, value1
            {
                if slt(add(dataEnd, not(3)), 32) { revert(0, 0) }
                let offset := calldataload(4)
                
                if iszero(slt(add(offset, 35), dataEnd))
                {
                    revert( 0, 0)
                }
                
                let length := calldataload(add(4, offset))
                
                
                if gt(add(add(offset, shl(5, length)), 36), dataEnd)
                {
                    revert( 0, 0)
                }
                
                value0 := add(offset, 36)
                value1 := length
            }
            function abi_decode_uint256t_uint256(dataEnd) -> value0, value1
            {
                if slt(add(dataEnd, not(3)), 64) { revert(0, 0) }
                value0 := calldataload(4)
                value1 := calldataload(36)
            }
            function finalize_allocation(memPtr, size)
            {
                let newFreePtr := add(memPtr, and(add(size, 31), not(31)))
                
                mstore(64, newFreePtr)
            }
            function abi_decode_available_length_array_uint256_dyn(offset, length, end) -> array
            {
                
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
                    revert( 0, 0)
                }
                
                let src := offset
                for { } lt(src, srcEnd) { src := add(src, 0x20) }
                {
                    mstore(dst, calldataload(src))
                    dst := add(dst, 0x20)
                }
            }
            function abi_encode_array_uint256_dyn(headStart, value0) -> tail
            {
                let tail_1 := add(headStart, 32)
                mstore(headStart, 32)
                let pos := tail_1
                let length := mload(value0)
                mstore(tail_1, length)
                pos := add(headStart, 64)
                let srcPtr := add(value0, 32)
                let i := 0
                for { } lt(i, length) { i := add(i, 1) }
                {
                    mstore(pos, mload(srcPtr))
                    pos := add(pos, 32)
                    srcPtr := add(srcPtr, 32)
                }
                tail := pos
            }
        }
        data ".metadata" hex"a264697066735822122041449beefdc086550ece5d572524811f51571d240b4944add1e35b748d76b04964736f6c634300081c0033"
    }
}