object "Libraries_741" {
    code {
        {
            
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            
            let _2 := datasize("Libraries_741_deployed")
            codecopy(_1, dataoffset("Libraries_741_deployed"), _2)
            return(_1, _2)
        }
    }
    
    object "Libraries_741_deployed" {
        code {
            {
                
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                
                {
                    switch shr(224, calldataload(0))
                    case 0x02dd56d0 {
                        
                        
                        let ret := 0
                        let slotValue := sload( 1)
                        
                        let length := shr( 1,  slotValue)
                        let outOfPlaceEncoding := and(slotValue,  1)
                        
                        if iszero(outOfPlaceEncoding) { length := and(length, 0x7f) }
                        if eq(outOfPlaceEncoding, lt(length, 32))
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x22)
                            revert(0, 0x24)
                        }
                        mstore(_1, length)
                        switch outOfPlaceEncoding
                        case 0 {
                            mstore(add(_1, 32), and(slotValue, not(255)))
                            ret := add(add(_1, shl(5, iszero(iszero(length)))), 32)
                        }
                        case 1 {
                            mstore(0,  1)
                            
                            let dataPos := 80084422859880547211683076133703299733277748156566366325829078699459944778998
                            let i := 0
                            for { } lt(i, length) { i := add(i, 32) }
                            {
                                mstore(add(add(_1, i), 32), sload(dataPos))
                                dataPos := add(dataPos,  1)
                            }
                            
                            ret := add(add(_1, i), 32)
                        }
                        finalize_allocation(_1, sub(ret, _1))
                        let memPos := mload(64)
                        mstore(memPos, 32)
                        return(memPos, sub(abi_encode_string(_1, add(memPos, 32)), memPos))
                    }
                    case 0x03df179c {
                        
                        
                        
                        let _2 := fun_add( sload(0), calldataload(4))
                        sstore(0, _2)
                        let memPos_1 := mload(64)
                        mstore(memPos_1, _2)
                        return(memPos_1, 32)
                    }
                    case 0x04037b50 {
                        
                        let param, param_1 := abi_decode_uint256t_uint256(calldatasize())
                        
                        let _3 := iszero(param_1)
                        
                        if _3
                        {
                            let memPtr := mload(64)
                            mstore(memPtr, shl(229, 4594637))
                            mstore(add(memPtr, 4), 32)
                            mstore(add(memPtr, 36), 24)
                            mstore(add(memPtr, 68), "SafeMath: modulo by zero")
                            revert(memPtr, 100)
                        }
                        _3 := 0
                        let memPos_2 := mload(64)
                        mstore(memPos_2, mod(param, param_1))
                        return(memPos_2, 32)
                    }
                    case 0x0d336a21 {
                        
                        
                        let _4 := sload(0)
                        let memPos_3 := mload(64)
                        mstore(memPos_3, _4)
                        return(memPos_3, 32)
                    }
                    case 0x27b2b35d {
                        
                        
                        let value := calldataload(4)
                        
                        
                        let var :=  iszero(iszero( extcodesize(value)))
                        
                        let memPos_4 := mload(64)
                        mstore(memPos_4, var)
                        return(memPos_4, 32)
                    }
                    case 0x3295425d {
                        
                        
                        sstore(0, calldataload(4))
                        return(0, 0)
                    }
                    case 0x3721b1d8 {
                        
                        
                        
                        let _5 := fun_sub( sload(0), calldataload(4))
                        sstore(0, _5)
                        let memPos_5 := mload(64)
                        mstore(memPos_5, _5)
                        return(memPos_5, 32)
                    }
                    case 0x3b3a7e31 {
                        
                        let param_2, param_3 := abi_decode_uint256t_uint256(calldatasize())
                        if  iszero(param_3)
                        
                        {
                            let memPtr_1 := mload(64)
                            mstore(memPtr_1, shl(229, 4594637))
                            mstore(add(memPtr_1, 4), 32)
                            mstore(add(memPtr_1, 36), 26)
                            mstore(add(memPtr_1, 68), "SafeMath: division by zero")
                            revert(memPtr_1, 100)
                        }
                        
                        let var_1 :=  checked_div_uint256(param_2, param_3)
                        
                        let memPos_6 := mload(64)
                        mstore(memPos_6, var_1)
                        return(memPos_6, 32)
                    }
                    case 0x437da23e {
                        external_fun_directLibraryCall()
                    }
                    case 0x529486dd {
                        
                        
                        let offset := calldataload(4)
                        
                        let value0, value1 := abi_decode_string_calldata(add(4, offset), calldatasize())
                        
                        let var_2 :=  iszero( mload(abi_decode_available_length_string(value0, value1, calldatasize())))
                        let memPos_7 := mload(64)
                        mstore(memPos_7, var_2)
                        return(memPos_7, 32)
                    }
                    case 0x6245a978 {
                        
                        
                        let offset_1 := calldataload(4)
                        
                        let value0_1, value1_1 := abi_decode_array_uint256_dyn_calldata(add(4, offset_1), calldatasize())
                        let ret_1 :=  fun_max( abi_decode_available_length_array_uint256_dyn(value0_1, value1_1, calldatasize()))
                        let memPos_8 := mload(64)
                        mstore(memPos_8, ret_1)
                        return(memPos_8, 32)
                    }
                    case 0x6d619daa {
                        
                        
                        let _6 := sload(0)
                        let memPos_9 := mload(64)
                        mstore(memPos_9, _6)
                        return(memPos_9, 32)
                    }
                    case 0x7c3ffef2 {
                        external_fun_directLibraryCall()
                    }
                    case 0x960f4743 {
                        
                        let param_4, param_5, param_6 := abi_decode_array_uint256_dyn_calldatat_uint256(calldatasize())
                        
                        let var_total :=  fun_mul( fun_sum( abi_decode_available_length_array_uint256_dyn( param_4, param_5,  calldatasize())),  param_6)
                        
                        let var_maxVal :=  fun_max( abi_decode_available_length_array_uint256_dyn( param_4, param_5,  calldatasize()))
                        
                        let var_minVal :=  fun_min( abi_decode_available_length_array_uint256_dyn( param_4, param_5,  calldatasize()))
                        let memPos_10 := mload(64)
                        mstore(memPos_10, var_total)
                        mstore(add(memPos_10, 32), var_maxVal)
                        mstore(add(memPos_10, 64), var_minVal)
                        return(memPos_10, 96)
                    }
                    case 0x966d3b3d {
                        
                        
                        let ret_2 :=  fun_add( calldataload(4),  fun_mul( calldataload(36), calldataload(68)))
                        let memPos_11 := mload(64)
                        mstore(memPos_11, ret_2)
                        return(memPos_11, 32)
                    }
                    case 0xbac32a65 {
                        
                        let param_7, param_8, param_9 := abi_decode_array_uint256_dyn_calldatat_uint256(calldatasize())
                        let ret_3 :=  fun_contains( abi_decode_available_length_array_uint256_dyn(param_7, param_8, calldatasize()), param_9)
                        let memPos_12 := mload(64)
                        mstore(memPos_12, iszero(iszero(ret_3)))
                        return(memPos_12, 32)
                    }
                    case 0xbd2c7195 {
                        
                        let param_10, param_11 := abi_decode_uint256t_uint256(calldatasize())
                        let ret_4 :=  fun_mul( param_10, param_11)
                        let memPos_13 := mload(64)
                        mstore(memPos_13, ret_4)
                        return(memPos_13, 32)
                    }
                    case 0xbe1beee0 {
                        
                        
                        let offset_2 := calldataload(4)
                        
                        let value0_2, value1_2 := abi_decode_array_uint256_dyn_calldata(add(4, offset_2), calldatasize())
                        let ret_5 :=  fun_sum( abi_decode_available_length_array_uint256_dyn(value0_2, value1_2, calldatasize()))
                        let memPos_14 := mload(64)
                        mstore(memPos_14, ret_5)
                        return(memPos_14, 32)
                    }
                    case 0xcea29937 {
                        
                        
                        
                        let _7 := fun_mul( sload(0), calldataload(4))
                        sstore(0, _7)
                        let memPos_15 := mload(64)
                        mstore(memPos_15, _7)
                        return(memPos_15, 32)
                    }
                    case 0xd84da15f {
                        
                        
                        let offset_3 := calldataload(4)
                        
                        let value0_3, value1_3 := abi_decode_string_calldata(add(4, offset_3), calldatasize())
                        
                        let var_3 :=  mload(abi_decode_available_length_string(value0_3, value1_3, calldatasize()))
                        let memPos_16 := mload(64)
                        mstore(memPos_16, var_3)
                        return(memPos_16, 32)
                    }
                    case 0xd9aa2494 {
                        
                        
                        let offset_4 := calldataload(4)
                        
                        let value0_4, value1_4 := abi_decode_string_calldata(add(4, offset_4), calldatasize())
                        let offset_5 := calldataload(36)
                        
                        let value2, value3 := abi_decode_string_calldata(add(4, offset_5), calldatasize())
                        
                        let expr_self_mpos :=  abi_decode_available_length_string( value0_4, value1_4,  calldatasize())
                        let _8 := abi_decode_available_length_string( value2, value3,  calldatasize())
                        
                        let expr := keccak256( add( expr_self_mpos,  32), mload( expr_self_mpos))
                        
                        let var_4 :=  eq(expr,  keccak256( add( _8,  32), mload( _8)))
                        
                        let memPos_17 := mload(64)
                        mstore(memPos_17, var_4)
                        return(memPos_17, 32)
                    }
                    case 0xdb0721d0 {
                        
                        let param_12, param_13 := abi_decode_uint256t_uint256(calldatasize())
                        let ret_6 :=  fun_sub( param_12, param_13)
                        let memPos_18 := mload(64)
                        mstore(memPos_18, ret_6)
                        return(memPos_18, 32)
                    }
                    case 0xdd43d292 {
                        
                        
                        let value_1 := calldataload(4)
                        
                        
                        let expr_mpos :=  mload(64)
                        mstore( add(expr_mpos,  32), and(shl(96, value_1), not(0xffffffffffffffffffffffff)))
                        
                        mstore(expr_mpos, 20)
                        finalize_allocation(expr_mpos, 52)
                        
                        let memPos_19 := mload(64)
                        mstore(memPos_19, 32)
                        return(memPos_19, sub(abi_encode_string(expr_mpos, add(memPos_19, 32)), memPos_19))
                    }
                    case 0xeec5de75 {
                        
                        
                        let value_2 := calldataload(4)
                        
                        let var_5 :=  0
                        
                        let sum := add(value_2,  0x0a)
                        
                        if gt(value_2, sum)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        if  lt(sum, value_2)
                        
                        {
                            let memPtr_2 := mload(64)
                            mstore(memPtr_2, shl(229, 4594637))
                            mstore(add(memPtr_2, 4), 32)
                            mstore(add(memPtr_2, 36), 27)
                            mstore(add(memPtr_2, 68), "SafeMath: addition overflow")
                            revert(memPtr_2, 100)
                        }
                        
                        var_5 := sum
                        
                        let expr_1 := fun_mul_5958(sum)
                        
                        let var_6 :=  0
                        if  gt( 0x05,  expr_1)
                        
                        {
                            let memPtr_3 := mload(64)
                            mstore(memPtr_3, shl(229, 4594637))
                            mstore(add(memPtr_3, 4), 32)
                            mstore(add(memPtr_3, 36), 31)
                            mstore(add(memPtr_3, 68), "SafeMath: subtraction underflow")
                            revert(memPtr_3, 100)
                        }
                        let diff := add(expr_1, not(4))
                        if gt(diff, expr_1)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        
                        var_6 := diff
                        
                        let memPos_20 := mload(64)
                        mstore(memPos_20, diff)
                        return(memPos_20, 32)
                    }
                    case 0xf8b81edb {
                        
                        
                        let offset_6 := calldataload(4)
                        
                        let value0_5, value1_5 := abi_decode_array_uint256_dyn_calldata(add(4, offset_6), calldatasize())
                        let ret_7 :=  fun_min( abi_decode_available_length_array_uint256_dyn(value0_5, value1_5, calldatasize()))
                        let memPos_21 := mload(64)
                        mstore(memPos_21, ret_7)
                        return(memPos_21, 32)
                    }
                }
                revert(0, 0)
            }
            function finalize_allocation(memPtr, size)
            {
                let newFreePtr := add(memPtr, and(add(size, 31), not(31)))
                
                mstore(64, newFreePtr)
            }
            function abi_encode_string(value, pos) -> end
            {
                let length := mload(value)
                mstore(pos, length)
                mcopy(add(pos, 0x20), add(value, 0x20), length)
                mstore(add(add(pos, length), 0x20),  0)
                
                end := add(add(pos, and(add(length, 31), not(31))), 0x20)
            }
            function abi_decode_uint256t_uint256(dataEnd) -> value0, value1
            {
                if slt(add(dataEnd, not(3)), 64) { revert(0, 0) }
                value0 := calldataload(4)
                value1 := calldataload(36)
            }
            function external_fun_directLibraryCall()
            {
                
                let param, param_1 := abi_decode_uint256t_uint256(calldatasize())
                let ret :=  fun_add( param, param_1)
                let memPos := mload(64)
                mstore(memPos, ret)
                return(memPos, 32)
            }
            function abi_decode_string_calldata(offset, end) -> arrayPos, length
            {
                if iszero(slt(add(offset, 0x1f), end)) { revert(0, 0) }
                length := calldataload(offset)
                
                arrayPos := add(offset, 0x20)
                if gt(add(add(offset, length), 0x20), end) { revert(0, 0) }
            }
            function abi_decode_array_uint256_dyn_calldata(offset, end) -> arrayPos, length
            {
                if iszero(slt(add(offset, 0x1f), end)) { revert(0, 0) }
                length := calldataload(offset)
                
                arrayPos := add(offset, 0x20)
                if gt(add(add(offset, shl(5, length)), 0x20), end) { revert(0, 0) }
            }
            function abi_decode_array_uint256_dyn_calldatat_uint256(dataEnd) -> value0, value1, value2
            {
                if slt(add(dataEnd, not(3)), 64) { revert(0, 0) }
                let offset := calldataload(4)
                
                let value0_1, value1_1 := abi_decode_array_uint256_dyn_calldata(add(4, offset), dataEnd)
                value0 := value0_1
                value1 := value1_1
                value2 := calldataload(36)
            }
            function abi_decode_available_length_string(src, length, end) -> array
            {
                
                let memPtr := mload(64)
                finalize_allocation(memPtr, add(and(add(length, 31), not(31)), 0x20))
                array := memPtr
                mstore(memPtr, length)
                if gt(add(src, length), end)
                {
                    revert( 0, 0)
                }
                
                calldatacopy(add(memPtr, 0x20), src, length)
                mstore(add(add(memPtr, length), 0x20),  0)
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
            /// @ast-id 27 @src 0:241:416  "function add(uint256 a, uint256 b) internal pure returns (uint256) {..."
            function fun_add(var_a, var_b) -> var
            {
                
                let expr := checked_add_uint256(var_a, var_b)
                
                if  lt(expr, var_a)
                
                {
                    let memPtr := mload(64)
                    mstore(memPtr, shl(229, 4594637))
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 27)
                    mstore(add(memPtr, 68), "SafeMath: addition overflow")
                    revert(memPtr, 100)
                }
                
                var := expr
            }
            /// @ast-id 48 @src 0:422:578  "function sub(uint256 a, uint256 b) internal pure returns (uint256) {..."
            function fun_sub(var_a, var_b) -> var
            {
                
                if  gt(var_b, var_a)
                
                {
                    let memPtr := mload(64)
                    mstore(memPtr, shl(229, 4594637))
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 31)
                    mstore(add(memPtr, 68), "SafeMath: subtraction underflow")
                    revert(memPtr, 100)
                }
                let diff := sub(var_a, var_b)
                if gt(diff, var_a)
                {
                    mstore( 0,  shl(224, 0x4e487b71))
                    mstore(4, 0x11)
                    revert( 0,  0x24)
                }
                
                var := diff
            }
            
            function checked_div_uint256(x, y) -> r
            {
                if iszero(y)
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x12)
                    revert(0, 0x24)
                }
                r := div(x, y)
            }
            function require_helper_stringliteral_bf73(condition)
            {
                if iszero(condition)
                {
                    let memPtr := mload(64)
                    mstore(memPtr, shl(229, 4594637))
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 11)
                    mstore(add(memPtr, 68), "Empty array")
                    revert(memPtr, 100)
                }
            }
            function memory_array_index_access_uint256_dyn_5974(baseRef) -> addr
            {
                if iszero(mload(baseRef))
                {
                    mstore( 0x00,  shl(224, 0x4e487b71))
                    mstore(4, 0x32)
                    revert( 0x00,  0x24)
                }
                addr := add(baseRef, 32)
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
            /// @ast-id 286 @src 0:2189:2486  "function max(uint256[] memory arr) internal pure returns (uint256 maxVal) {..."
            function fun_max(var_arr_240_mpos) -> var_maxVal
            {
                
                require_helper_stringliteral_bf73( iszero(iszero( mload( var_arr_240_mpos))))
                
                var_maxVal :=  mload( memory_array_index_access_uint256_dyn_5974(var_arr_240_mpos))
                
                let var_i :=  0x01
                
                for { }
                 0x01
                
                {
                    
                    var_i :=  add( var_i,  0x01)
                }
                
                {
                    
                    if iszero(lt(var_i,  mload( var_arr_240_mpos)))
                    
                    { break }
                    
                    if  gt( mload( memory_array_index_access_uint256_dyn(var_arr_240_mpos, var_i)),  var_maxVal)
                    
                    {
                        
                        var_maxVal :=  mload( memory_array_index_access_uint256_dyn(var_arr_240_mpos, var_i))
                    }
                }
            }
            /// @ast-id 237 @src 0:2013:2183  "function sum(uint256[] memory arr) internal pure returns (uint256 total) {..."
            function fun_sum(var_arr_212_mpos) -> var_total
            {
                
                var_total :=  0
                
                let var_i :=  0
                
                for { }
                 1
                
                {
                    
                    var_i :=  add( var_i,  1)
                }
                
                {
                    
                    if iszero(lt(var_i,  mload( var_arr_212_mpos)))
                    
                    { break }
                    
                    var_total := checked_add_uint256(var_total,  mload( memory_array_index_access_uint256_dyn(var_arr_212_mpos, var_i)))
                }
            }
            /// @ast-id 81 @src 0:584:799  "function mul(uint256 a, uint256 b) internal pure returns (uint256) {..."
            function fun_mul_5958(var_a) -> var
            {
                
                var :=  0
                
                if  iszero(var_a)
                
                {
                    
                    var :=  0
                    
                    leave
                }
                
                let product := shl(1, var_a)
                if iszero(eq( 0x02,  div(product, var_a)))
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x11)
                    revert(0, 0x24)
                }
                if iszero( eq( checked_div_uint256(product, var_a),  0x02))
                
                {
                    let memPtr := mload(64)
                    mstore(memPtr, shl(229, 4594637))
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 33)
                    mstore(add(memPtr, 68), "SafeMath: multiplication overflo")
                    mstore(add(memPtr, 100), "w")
                    revert(memPtr, 132)
                }
                
                var := product
            }
            /// @ast-id 81 @src 0:584:799  "function mul(uint256 a, uint256 b) internal pure returns (uint256) {..."
            function fun_mul(var_a, var_b) -> var
            {
                
                var :=  0
                
                if  iszero(var_a)
                
                {
                    
                    var :=  0
                    
                    leave
                }
                
                let product := mul(var_a, var_b)
                if iszero(eq(var_b, div(product, var_a)))
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x11)
                    revert(0, 0x24)
                }
                if iszero( eq( checked_div_uint256(product, var_a),  var_b))
                
                {
                    let memPtr := mload(64)
                    mstore(memPtr, shl(229, 4594637))
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 33)
                    mstore(add(memPtr, 68), "SafeMath: multiplication overflo")
                    mstore(add(memPtr, 100), "w")
                    revert(memPtr, 132)
                }
                
                var := product
            }
            /// @ast-id 335 @src 0:2492:2789  "function min(uint256[] memory arr) internal pure returns (uint256 minVal) {..."
            function fun_min(var_arr_289_mpos) -> var_minVal
            {
                
                require_helper_stringliteral_bf73( iszero(iszero( mload( var_arr_289_mpos))))
                
                var_minVal :=  mload( memory_array_index_access_uint256_dyn_5974(var_arr_289_mpos))
                
                let var_i :=  0x01
                
                for { }
                 0x01
                
                {
                    
                    var_i :=  add( var_i,  0x01)
                }
                
                {
                    
                    if iszero(lt(var_i,  mload( var_arr_289_mpos)))
                    
                    { break }
                    
                    if  lt( mload( memory_array_index_access_uint256_dyn(var_arr_289_mpos, var_i)),  var_minVal)
                    
                    {
                        
                        var_minVal :=  mload( memory_array_index_access_uint256_dyn(var_arr_289_mpos, var_i))
                    }
                }
            }
            /// @ast-id 369 @src 0:2795:3037  "function contains(..."
            function fun_contains(var_arr_mpos, var_value) -> var
            {
                
                var :=  0
                
                let var_i :=  0
                
                for { }
                 1
                
                {
                    
                    var_i :=  add( var_i,  1)
                }
                
                {
                    
                    if iszero(lt(var_i,  mload( var_arr_mpos)))
                    
                    { break }
                    
                    if  eq( mload( memory_array_index_access_uint256_dyn(var_arr_mpos, var_i)),  var_value)
                    
                    {
                        
                        var :=  1
                        
                        leave
                    }
                }
                
                var :=  0
            }
        }
        data ".metadata" hex"a26469706673582212201ee1747c0eddbec7c58a197a6c826ad09a30345347c61848c79ef64ff7d988fc64736f6c634300081c0033"
    }
}