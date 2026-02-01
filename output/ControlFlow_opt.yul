object "ControlFlow_331" {
    code {
        {
            
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            
            let _2 := datasize("ControlFlow_331_deployed")
            codecopy(_1, dataoffset("ControlFlow_331_deployed"), _2)
            return(_1, _2)
        }
    }
    
    object "ControlFlow_331_deployed" {
        code {
            {
                
                mstore(64, memoryguard(0x80))
                
                {
                    switch shr(224, calldataload(0))
                    case 0x236744b0 {
                        
                        let param, param_1 := abi_decode_uint256t_uint256(calldatasize())
                        let var_skipEvery := param_1
                        let var_n := param
                        
                        if  gt(param,  0x03e8)
                        
                        {
                            
                            var_n :=  0x03e8
                        }
                        
                        if  iszero(param_1)
                        
                        {
                            
                            var_skipEvery :=  0x01
                        }
                        
                        let var_count :=  0
                        
                        let var_i :=  0
                        
                        for { }
                         lt(var_i, var_n)
                        
                        {
                            
                            var_i :=  add( var_i,  1)
                        }
                        
                        {
                            
                            if iszero(var_skipEvery)
                            {
                                mstore(0, shl(224, 0x4e487b71))
                                mstore(4, 0x12)
                                revert(0, 0x24)
                            }
                            
                            if  iszero( mod(var_i, var_skipEvery))
                            
                            {
                                
                                continue
                            }
                            
                            var_count := increment_uint256(var_count)
                        }
                        
                        let memPos := mload(64)
                        mstore(memPos, var_count)
                        return(memPos, 32)
                    }
                    case 0x5a5e80e7 {
                        
                        
                        let var_n_1 := calldataload(4)
                        
                        if  gt(var_n_1,  0x2710)
                        
                        {
                            
                            var_n_1 :=  0x2710
                        }
                        
                        let var_i_1 :=  0
                        
                        for { }
                         lt(var_i_1, var_n_1)
                        
                        { }
                        {
                            
                            var_i_1 := increment_uint256(var_i_1)
                        }
                        
                        let memPos_1 := mload(64)
                        mstore(memPos_1, var_i_1)
                        return(memPos_1, 32)
                    }
                    case 0x6954c6ec {
                        
                        let param_2, param_3 := abi_decode_uint256t_uint256(calldatasize())
                        let var_inner := param_3
                        let var_outer := param_2
                        
                        if  gt(param_2,  0x64)
                        
                        {
                            
                            var_outer :=  0x64
                        }
                        
                        if  gt(param_3,  0x64)
                        
                        {
                            
                            var_inner :=  0x64
                        }
                        
                        let var_count_1 :=  0
                        
                        let var_i_2 :=  0
                        
                        for { }
                         lt(var_i_2, var_outer)
                        
                        {
                            
                            var_i_2 :=  add( var_i_2,  1)
                        }
                        
                        {
                            
                            let var_j :=  0
                            
                            for { }
                             lt(var_j, var_inner)
                            
                            {
                                
                                var_j :=  add( var_j,  1)
                            }
                            
                            {
                                
                                var_count_1 := increment_uint256(var_count_1)
                            }
                        }
                        
                        let memPos_2 := mload(64)
                        mstore(memPos_2, var_count_1)
                        return(memPos_2, 32)
                    }
                    case 0x8a2592b1 {
                        
                        
                        let var_n_2 := calldataload(4)
                        
                        if  gt(var_n_2,  0x2710)
                        
                        {
                            
                            var_n_2 :=  0x2710
                        }
                        
                        let var_sum :=  0
                        
                        let var_i_3 :=  0
                        
                        for { }
                         lt(var_i_3, var_n_2)
                        
                        {
                            
                            var_i_3 :=  add( var_i_3,  1)
                        }
                        
                        {
                            
                            let sum := add(var_sum, var_i_3)
                            if gt(var_sum, sum)
                            {
                                mstore(0, shl(224, 0x4e487b71))
                                mstore(4, 0x11)
                                revert(0, 0x24)
                            }
                            
                            var_sum := sum
                        }
                        
                        let memPos_3 := mload(64)
                        mstore(memPos_3, var_sum)
                        return(memPos_3, 32)
                    }
                    case 0x950b9954 {
                        
                        
                        let ret := fun_ifElse(calldataload(4))
                        let memPos_4 := mload(64)
                        mstore(memPos_4, ret)
                        return(memPos_4, 32)
                    }
                    case 0x9d25173f {
                        
                        
                        let var_n_3 := calldataload(4)
                        
                        if  gt(var_n_3,  0x2710)
                        
                        {
                            
                            var_n_3 :=  0x2710
                        }
                        
                        let var_count_2 :=  0
                        
                        let var_i_4 :=  0
                        
                        for { }
                         lt(var_i_4, var_n_3)
                        
                        {
                            
                            var_i_4 :=  add( var_i_4,  1)
                        }
                        
                        {
                            
                            var_count_2 := increment_uint256(var_count_2)
                        }
                        
                        let memPos_5 := mload(64)
                        mstore(memPos_5, var_count_2)
                        return(memPos_5, 32)
                    }
                    case 0xaa093375 {
                        
                        let param_4, param_5 := abi_decode_uint256t_uint256(calldatasize())
                        
                        let expr :=  0
                        
                        switch  gt(param_4, param_5)
                        case  0 { expr := param_5 }
                        default { expr := param_4 }
                        
                        let memPos_6 := mload(64)
                        mstore(memPos_6, expr)
                        return(memPos_6, 32)
                    }
                    case 0xb055da2f {
                        
                        
                        let ret_1 := fun_earlyReturn(calldataload(4))
                        let memPos_7 := mload(64)
                        mstore(memPos_7, ret_1)
                        return(memPos_7, 32)
                    }
                    case 0xf602a6af {
                        
                        let param_6, param_7 := abi_decode_uint256t_uint256(calldatasize())
                        let var_n_4 := param_6
                        
                        if  gt(param_6,  0x03e8)
                        
                        {
                            
                            var_n_4 :=  0x03e8
                        }
                        
                        let var_count_3 :=  0
                        
                        let var_i_5 :=  0
                        
                        for { }
                         lt(var_i_5, var_n_4)
                        
                        {
                            
                            var_i_5 :=  add( var_i_5,  1)
                        }
                        
                        {
                            
                            if  eq(var_i_5, param_7)
                            
                            {
                                
                                break
                            }
                            
                            var_count_3 := increment_uint256(var_count_3)
                        }
                        
                        let memPos_8 := mload(64)
                        mstore(memPos_8, var_count_3)
                        return(memPos_8, 32)
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
            /// @ast-id 208 @src 0:1488:1699  "function ifElse(uint256 x) external pure returns (uint256) {..."
            function fun_ifElse(var_x) -> var
            {
                
                var :=  0
                
                switch  lt(var_x,  0x0a)
                case  0 {
                    
                    switch  lt(var_x,  0x64)
                    case  0 {
                        
                        var :=  0x03
                        
                        leave
                    }
                    default 
                    {
                        
                        var :=  0x02
                        
                        leave
                    }
                }
                default 
                {
                    
                    var :=  0x01
                    
                    leave
                }
            }
            /// @ast-id 232 @src 0:1747:1900  "function earlyReturn(uint256 x) external pure returns (uint256) {..."
            function fun_earlyReturn(var_x) -> var
            {
                
                var :=  0
                
                if  iszero(var_x)
                
                {
                    
                    var :=  0
                    
                    leave
                }
                
                if  eq(var_x,  0x01)
                
                {
                    
                    var :=  0x01
                    
                    leave
                }
                
                let product := shl( 0x01,  var_x)
                if iszero(eq( 0x02,  div(product, var_x)))
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x11)
                    revert(0, 0x24)
                }
                
                var := product
            }
        }
        data ".metadata" hex"a2646970667358221220e33a295210b5023e82df2ee00536800bb5ff40b9c77014b933dbffbd6244f56864736f6c634300081c0033"
    }
}