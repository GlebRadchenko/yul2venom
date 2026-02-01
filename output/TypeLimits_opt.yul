object "TypeLimits_549" {
    code {
        {
            
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            
            let _2 := datasize("TypeLimits_549_deployed")
            codecopy(_1, dataoffset("TypeLimits_549_deployed"), _2)
            return(_1, _2)
        }
    }
    
    object "TypeLimits_549_deployed" {
        code {
            {
                
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                
                {
                    switch shr(224, calldataload(0))
                    case 0x0625faae {
                        
                        
                        mstore(_1,  shl(255, 1))
                        
                        mstore(add(_1, 32),  sub(shl(255,  1), 1))
                        
                        return(_1, 64)
                    }
                    case 0x098d3228 {
                        
                        
                        let memPos := mload(64)
                        mstore(memPos,  sub(shl(255,  1), 1))
                        
                        return(memPos, 32)
                    }
                    case 0x1509e91a {
                        
                        
                        let memPos_1 := mload(64)
                        mstore(memPos_1, 0)
                        mstore(add(memPos_1, 32),  0xffffffff)
                        
                        return(memPos_1, 64)
                    }
                    case 0x250cf21e {
                        
                        
                        let memPos_2 := mload(64)
                        mstore(memPos_2,  not(32767))
                        
                        mstore(add(memPos_2, 32),  32767)
                        
                        return(memPos_2, 64)
                    }
                    case 0x31351785 {
                        
                        
                        let memPos_3 := mload(64)
                        mstore(memPos_3, 0)
                        mstore(add(memPos_3, 32),  not(0))
                        
                        return(memPos_3, 64)
                    }
                    case 0x35f1085f {
                        
                        
                        let value := calldataload(4)
                        
                        let ret := fun_maxForBits(value)
                        let memPos_4 := mload(64)
                        mstore(memPos_4, ret)
                        return(memPos_4, 32)
                    }
                    case 0x47398011 {
                        
                        
                        let memPos_5 := mload(64)
                        mstore(memPos_5, 0)
                        mstore(add(memPos_5, 32),  255)
                        
                        return(memPos_5, 64)
                    }
                    case 0x4f4f220d {
                        
                        
                        let memPos_6 := mload(64)
                        mstore(memPos_6, 0)
                        mstore(add(memPos_6, 32),  0xffffffffffffffff)
                        
                        return(memPos_6, 64)
                    }
                    case 0x52631aea {
                        
                        
                        let memPos_7 := mload(64)
                        mstore(memPos_7,  0xffffffffffffffffffffffffffffffff)
                        
                        return(memPos_7, 32)
                    }
                    case 0x59f1a071 {
                        
                        
                        let memPos_8 := mload(64)
                        mstore(memPos_8, 0)
                        mstore(add(memPos_8, 32),  0xffffffffffffffffffffffffffffffff)
                        
                        return(memPos_8, 64)
                    }
                    case 0x6763b692 {
                        
                        
                        let ret_1 := fun_clampToUint8(calldataload(4))
                        let memPos_9 := mload(64)
                        mstore(memPos_9, and(ret_1, 0xff))
                        return(memPos_9, 32)
                    }
                    case 0x687db44c {
                        
                        
                        let ret_2 := fun_clampToInt128(calldataload(4))
                        let memPos_10 := mload(64)
                        mstore(memPos_10, signextend(15, ret_2))
                        return(memPos_10, 32)
                    }
                    case 0x6b9241fc {
                        
                        
                        let memPos_11 := mload(64)
                        mstore(memPos_11,  shl(224, 0x01ffc9a7))
                        
                        return(memPos_11, 32)
                    }
                    case 0x7b602edf {
                        
                        
                        let memPos_12 := mload(64)
                        mstore(memPos_12,  eq( calldataload(4),  shl(255, 1)))
                        
                        return(memPos_12, 32)
                    }
                    case 0x97b3805f {
                        
                        
                        let memPos_13 := mload(64)
                        mstore(memPos_13, 0)
                        mstore(add(memPos_13, 32),  65535)
                        
                        return(memPos_13, 64)
                    }
                    case 0x9a02ea65 {
                        
                        let param, param_1 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_14 := mload(64)
                        mstore(memPos_14,  gt(param,  not(param_1)))
                        return(memPos_14, 32)
                    }
                    case 0x9a295e73 {
                        
                        
                        let memPos_15 := mload(64)
                        mstore(memPos_15,  not(0))
                        
                        mstore(add(memPos_15, 32),  shl(255, 1))
                        
                        mstore(add(memPos_15, 64),  sub(shl(255,  1), 1))
                        
                        mstore(add(memPos_15, 96),  0xffffffffffffffffffffffffffffffff)
                        
                        return(memPos_15, 128)
                    }
                    case 0x9c250177 {
                        
                        
                        let memPos_16 := mload(64)
                        mstore(memPos_16,  not(0x7fffffff))
                        
                        mstore(add(memPos_16, 32),  0x7fffffff)
                        
                        return(memPos_16, 64)
                    }
                    case 0xbef75fb2 {
                        
                        
                        let value_1 := calldataload(4)
                        
                        let expr :=  iszero(slt(value_1,  not(0x7fffffffffffffff)))
                        
                        if expr
                        {
                            expr :=  iszero(sgt(value_1,  0x7fffffffffffffff))
                        }
                        
                        let memPos_17 := mload(64)
                        mstore(memPos_17, iszero(iszero(expr)))
                        return(memPos_17, 32)
                    }
                    case 0xc5f506ab {
                        
                        
                        let memPos_18 := mload(64)
                        mstore(memPos_18,  shl(255, 1))
                        
                        return(memPos_18, 32)
                    }
                    case 0xc9940342 {
                        
                        let param_2, param_3 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_19 := mload(64)
                        mstore(memPos_19,  gt(param_3, param_2))
                        
                        return(memPos_19, 32)
                    }
                    case 0xe5b5019a {
                        
                        
                        let memPos_20 := mload(64)
                        mstore(memPos_20,  not(0))
                        
                        return(memPos_20, 32)
                    }
                    case 0xe6cb9013 {
                        
                        let param_4, param_5 := abi_decode_uint256t_uint256(calldatasize())
                        if  gt(param_4,  not(param_5))
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
                        
                        
                        let memPos_22 := mload(64)
                        mstore(memPos_22,  not(0x7fffffffffffffff))
                        
                        mstore(add(memPos_22, 32),  0x7fffffffffffffff)
                        
                        return(memPos_22, 64)
                    }
                    case 0xf189e25a {
                        
                        
                        let memPos_23 := mload(64)
                        mstore(memPos_23,  not(127))
                        
                        mstore(add(memPos_23, 32),  127)
                        
                        return(memPos_23, 64)
                    }
                    case 0xf4aee8ab {
                        
                        
                        let memPos_24 := mload(64)
                        mstore(memPos_24,  not(0x7fffffffffffffffffffffffffffffff))
                        
                        mstore(add(memPos_24, 32),  0x7fffffffffffffffffffffffffffffff)
                        
                        return(memPos_24, 64)
                    }
                    case 0xf8c2ccba {
                        
                        
                        let memPos_25 := mload(64)
                        mstore(memPos_25,  eq( calldataload(4),  not(0)))
                        
                        return(memPos_25, 32)
                    }
                    case 0xf9788ec3 {
                        
                        
                        let memPos_26 := mload(64)
                        mstore(memPos_26,  iszero(gt( calldataload(4), 0xffffffffffffffffffffffffffffffff)))
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
                
                var :=  0
                let _1 := and( var_bits,  0xff)
                
                let expr :=  iszero(iszero( _1))
                
                if expr
                {
                    expr :=  iszero(gt( _1,  0x0100))
                }
                
                if iszero(expr)
                {
                    let memPtr := mload(64)
                    mstore(memPtr, shl(229, 4594637))
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 12)
                    mstore(add(memPtr, 68), "Invalid bits")
                    revert(memPtr, 100)
                }
                
                if  eq( _1,  0x0100)
                
                {
                    
                    var :=  not(0)
                    
                    leave
                }
                
                let result := shl(_1,  0x01)
                
                let diff := add(result,  not(0))
                
                if gt(diff, result)
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x11)
                    revert(0, 0x24)
                }
                
                var := diff
            }
            /// @ast-id 335 @src 0:2581:2769  "function clampToUint8(uint256 value) external pure returns (uint8) {..."
            function fun_clampToUint8(var_value) -> var
            {
                
                var :=  0
                
                if  gt(var_value,  0xff)
                
                {
                    
                    var :=  0xff
                    
                    leave
                }
                
                var :=  and( var_value,  0xff)
            }
            /// @ast-id 379 @src 0:2819:3098  "function clampToInt128(int256 value) external pure returns (int128) {..."
            function fun_clampToInt128(var_value) -> var
            {
                
                var :=  0
                
                if  sgt(var_value,  0x7fffffffffffffffffffffffffffffff)
                
                {
                    
                    var :=  0x7fffffffffffffffffffffffffffffff
                    
                    leave
                }
                
                if  slt(var_value,  not(0x7fffffffffffffffffffffffffffffff))
                
                {
                    
                    var :=  not(0x7fffffffffffffffffffffffffffffff)
                    
                    leave
                }
                
                var :=  signextend(15,  var_value)
            }
        }
        data ".metadata" hex"a2646970667358221220bb9104bca1f728ef70fbae1728d7100dd822ee1a4b1a78f0b8f4117920ec0f2164736f6c634300081c0033"
    }
}