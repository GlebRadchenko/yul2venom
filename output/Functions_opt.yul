object "Functions_609" {
    code {
        {
            
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            
            let _2 := datasize("Functions_609_deployed")
            codecopy(_1, dataoffset("Functions_609_deployed"), _2)
            return(_1, _2)
        }
    }
    
    object "Functions_609_deployed" {
        code {
            {
                
                mstore(64, 128)
                
                {
                    switch shr(224, calldataload(0))
                    case 0x15bad0e8 { external_fun_callVirtualB() }
                    case 0x19af7fb4 { external_fun_nestedInternal() }
                    case 0x2872b1ff { external_fun_callTarget() }
                    case 0x2e19789e { external_fun_virtualA() }
                    case 0x364ed2f4 { external_fun_selfAdd() }
                    case 0x43e20c0d {
                        external_fun_lowLevelDelegateCall()
                    }
                    case 0x5c60da1b { external_fun_implementation() }
                    case 0x61047ff4 { external_fun_fibonacci() }
                    case 0x6d619daa { external_fun_storedValue() }
                    case 0x6e744ea4 { external_fun_staticCallPure() }
                    case 0x83450770 { external_fun_returnNothing() }
                    case 0x83714834 { external_fun_factorial() }
                    case 0x87d9b0b5 { external_fun_callSelf() }
                    case 0x904e294d { external_fun_setCallTarget() }
                    case 0x906d76ff { external_fun_returnSingle() }
                    case 0xa2c29712 { external_fun_selfAdd() }
                    case 0xa399cec0 { external_fun_interfaceFunc() }
                    case 0xa4232a4a { external_fun_proxyCall() }
                    case 0xa6cc75bd { external_fun_callVirtualB() }
                    case 0xc4307f6a {
                        external_fun_delegateSetValue()
                    }
                    case 0xc8464891 { external_fun_virtualA() }
                    case 0xc9f3c86e { external_fun_lowLevelCall() }
                    case 0xd4da2ecb {
                        external_fun_lowLevelStaticCall()
                    }
                    case 0xd784d426 {
                        external_fun_setImplementation()
                    }
                    case 0xe377a4c5 { external_fun_callWithValue() }
                    case 0xe61e4008 { external_fun_returnMultiple() }
                }
                if iszero(calldatasize()) { stop() }
                fun()
                stop()
            }
            function abi_encode_uint256(headStart, value0) -> tail
            {
                tail := add(headStart, 32)
                mstore(headStart, value0)
            }
            function external_fun_callVirtualB()
            {
                
                
                
                let var := 222
                let memPos := mload(64)
                mstore(memPos, 222)
                return(memPos, 32)
            }
            function abi_decode_uint256_3456() -> value
            { value := calldataload(4) }
            function abi_decode_uint256_3458() -> value
            { value := calldataload(36) }
            function abi_decode_uint256() -> value
            { value := calldataload(68) }
            function external_fun_nestedInternal()
            {
                
                if slt(add(calldatasize(), not(3)), 32)
                {
                    revert( 0, 0)
                }
                
                let value := calldataload(4)
                let sum := add(value,  0x0a)
                
                
                let product := shl(1, sum)
                
                let sum_1 := add(product, 1)
                
                let memPos := mload(64)
                mstore(memPos, sum_1)
                return(memPos, 32)
            }
            function external_fun_callTarget()
            {
                
                
                let value := and(sload( 1),  sub(shl(160, 1), 1))
                let memPos := mload(64)
                mstore(memPos, value)
                return(memPos, 32)
            }
            function external_fun_virtualA()
            {
                
                
                let var := 111
                let memPos := mload(64)
                mstore(memPos, 111)
                return(memPos, 32)
            }
            function external_fun_selfAdd()
            {
                
                if slt(add(calldatasize(), not(3)), 64)
                {
                    revert( 0, 0)
                }
                
                let value := calldataload(4)
                let value_1 := calldataload(36)
                let sum := add(value, value_1)
                
                let memPos := mload(64)
                mstore(memPos, sum)
                return(memPos, 32)
            }
            function abi_decode_bytes_calldata(dataEnd) -> value0, value1
            {
                if slt(add(dataEnd, not(3)), 32) { revert(0, 0) }
                let offset := calldataload(4)
                
                if iszero(slt(add(offset, 35), dataEnd))
                {
                    revert( 0, 0)
                }
                
                let length := calldataload(add(4, offset))
                
                
                if gt(add(add(offset, length), 36), dataEnd)
                {
                    revert( 0, 0)
                }
                
                value0 := add(offset, 36)
                value1 := length
            }
            function abi_encode_bytes(value, pos) -> end
            {
                let length := mload(value)
                mstore(pos, length)
                mcopy(add(pos, 0x20), add(value, 0x20), length)
                mstore(add(add(pos, length), 0x20),  0)
                
                end := add(add(pos, and(add(length, 31), not(31))), 0x20)
            }
            function abi_encode_bool_bytes(headStart, value0, value1) -> tail
            {
                mstore(headStart, iszero(iszero(value0)))
                mstore(add(headStart, 32), 64)
                tail := abi_encode_bytes(value1, add(headStart, 64))
            }
            function external_fun_lowLevelDelegateCall()
            {
                
                let param, param_1 := abi_decode_bytes_calldata(calldatasize())
                let value := and(sload( 0x01),  sub(shl(160, 1), 1))
                
                let _1 :=  mload(64)
                calldatacopy(_1, param, param_1)
                let _2 := add(_1, param_1)
                mstore(_2,  0)
                
                let expr_component := delegatecall(gas(), value, _1, sub( _2,  _1),  0, 0)
                
                let var_result_mpos :=  extract_returndata()
                
                let memPos := mload(64)
                return(memPos, sub(abi_encode_bool_bytes(memPos, expr_component, var_result_mpos), memPos))
            }
            function external_fun_implementation()
            {
                
                
                let value := and(sload( 2),  sub(shl(160, 1), 1))
                let memPos := mload(64)
                mstore(memPos, value)
                return(memPos, 32)
            }
            function external_fun_fibonacci()
            {
                
                if slt(add(calldatasize(), not(3)), 32)
                {
                    revert( 0, 0)
                }
                
                let value := calldataload(4)
                let var_n := value
                
                if  gt(value,  0x14)
                
                {
                    
                    var_n :=  0x14
                }
                
                let var :=  fun_fib(var_n)
                
                let memPos := mload(64)
                mstore(memPos, var)
                return(memPos, 32)
            }
            function external_fun_storedValue()
            {
                
                
                let _1 := sload(0)
                let memPos := mload(64)
                mstore(memPos, _1)
                return(memPos, 32)
            }
            function abi_decode_address() -> value
            {
                value := calldataload(4)
                
            }
            function external_fun_staticCallPure()
            {
                
                if slt(add(calldatasize(), not(3)), 96)
                {
                    revert( 0, 0)
                }
                
                let value0 := abi_decode_address()
                let value1 := abi_decode_uint256_3458()
                let value2 := abi_decode_uint256()
                
                let expr_mpos :=  mload(64)
                
                let _1 := add(expr_mpos,  32)
                
                mstore(_1, shl(226, 0x2ba8fca3))
                let _2 := sub(abi_encode_uint256_uint256(add(expr_mpos,  36),  value1, value2), expr_mpos)
                mstore(expr_mpos, add(_2,  not(31)))
                
                finalize_allocation(expr_mpos, _2)
                
                let expr_component := staticcall(gas(), value0, _1, mload(expr_mpos),  0, 0)
                
                let expr_component_mpos := extract_returndata()
                
                if iszero(expr_component)
                {
                    let memPtr := mload(64)
                    mstore(memPtr, shl(229, 4594637))
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 17)
                    mstore(add(memPtr, 68), "staticcall failed")
                    revert(memPtr, 100)
                }
                
                let var :=  abi_decode_uint256_fromMemory(add(expr_component_mpos,  32),  add(add(expr_component_mpos,  mload( expr_component_mpos)),  32))
                let memPos := mload(64)
                return(memPos, sub(abi_encode_uint256(memPos, var), memPos))
            }
            function external_fun_returnNothing()
            {
                
                
                return(0, 0)
            }
            function external_fun_factorial()
            {
                
                if slt(add(calldatasize(), not(3)), 32)
                {
                    revert( 0, 0)
                }
                
                let value := calldataload(4)
                let var_n := value
                
                if  gt(value,  0x0c)
                
                {
                    
                    var_n :=  0x0c
                }
                
                let var :=  fun_factorial(var_n)
                
                let memPos := mload(64)
                mstore(memPos, var)
                return(memPos, 32)
            }
            function external_fun_callSelf()
            {
                
                if slt(add(calldatasize(), not(3)), 64)
                {
                    revert( 0, 0)
                }
                
                let value0 := abi_decode_uint256_3456()
                let value1 := abi_decode_uint256_3458()
                
                let _1 :=  mload(64)
                
                mstore(_1,  shl(226, 0x0d93b4bd))
                
                let _2 := staticcall(gas(),  address(),  _1, sub(abi_encode_uint256_uint256(add(_1,  4),  value0, value1), _1), _1,  32)
                
                if iszero(_2)
                {
                    
                    let pos := mload(64)
                    returndatacopy(pos,  0,  returndatasize())
                    revert(pos, returndatasize())
                }
                
                let expr :=  0
                
                if _2
                {
                    let _3 :=  32
                    
                    if gt( 32,  returndatasize()) { _3 := returndatasize() }
                    finalize_allocation(_1, _3)
                    expr := abi_decode_uint256_fromMemory(_1, add(_1, _3))
                }
                
                let memPos := mload(64)
                return(memPos, sub(abi_encode_uint256(memPos, expr), memPos))
            }
            function external_fun_setCallTarget()
            {
                
                if slt(add(calldatasize(), not(3)), 32)
                {
                    revert( 0, 0)
                }
                
                sstore( 0x01,  or(and(sload( 0x01),  shl(160, 0xffffffffffffffffffffffff)), and(abi_decode_address(), sub(shl(160, 1), 1))))
                return( 0, 0)
            }
            
            function external_fun_returnSingle()
            {
                
                
                let memPos := mload(64)
                mstore(memPos,  0x2a)
                
                return(memPos, 32)
            }
            function external_fun_interfaceFunc()
            {
                
                
                let memPos := mload(64)
                mstore(memPos,  0x03e7)
                
                return(memPos, 32)
            }
            function external_fun_proxyCall()
            {
                
                let param, param_1 := abi_decode_bytes_calldata(calldatasize())
                let value := and(sload( 0x02),  sub(shl(160, 1), 1))
                
                let _1 :=  mload(64)
                calldatacopy(_1, param, param_1)
                let _2 := add(_1, param_1)
                mstore(_2,  0)
                
                let expr_component := delegatecall(gas(), value, _1, sub( _2,  _1),  0, 0)
                
                let expr_component_mpos := extract_returndata()
                
                if iszero(expr_component)
                {
                    let memPtr := mload(64)
                    mstore(memPtr, shl(229, 4594637))
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 12)
                    mstore(add(memPtr, 68), "proxy failed")
                    revert(memPtr, 100)
                }
                let memPos := mload(64)
                let tail :=  0
                
                mstore(memPos, 32)
                tail := abi_encode_bytes(expr_component_mpos, add(memPos, 32))
                return(memPos, sub(tail, memPos))
            }
            function external_fun_delegateSetValue()
            {
                
                if slt(add(calldatasize(), not(3)), 64)
                {
                    revert( 0, 0)
                }
                
                let value0 := abi_decode_address()
                let value1 := abi_decode_uint256_3458()
                
                let expr_mpos :=  mload(64)
                
                let _1 := add(expr_mpos,  32)
                
                mstore(_1, shl(231, 0x01503d1f))
                
                mstore( add(expr_mpos,  36), value1)
                
                mstore(expr_mpos,  36)
                
                finalize_allocation(expr_mpos, 68)
                
                let expr_component := delegatecall(gas(), value0, _1, mload(expr_mpos),  0, 0)
                
                let expr_component_mpos := extract_returndata()
                
                if iszero(expr_component)
                {
                    let memPtr := mload(64)
                    mstore(memPtr, shl(229, 4594637))
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 19)
                    mstore(add(memPtr,  68),  "delegatecall failed")
                    revert(memPtr, 100)
                }
                
                let var :=  abi_decode_uint256_fromMemory(add(expr_component_mpos,  32),  add(add(expr_component_mpos,  mload( expr_component_mpos)),  32))
                let memPos := mload(64)
                return(memPos, sub(abi_encode_uint256(memPos, var), memPos))
            }
            function external_fun_lowLevelCall()
            {
                
                let param, param_1 := abi_decode_bytes_calldata(calldatasize())
                let value := and(sload( 0x01),  sub(shl(160, 1), 1))
                
                let _1 :=  mload(64)
                calldatacopy(_1, param, param_1)
                let _2 := add(_1, param_1)
                mstore(_2,  0)
                
                let expr_component := call(gas(), value,  0,  _1, sub( _2,  _1),  0, 0)
                
                let var_result_mpos :=  extract_returndata()
                
                let memPos := mload(64)
                return(memPos, sub(abi_encode_bool_bytes(memPos, expr_component, var_result_mpos), memPos))
            }
            function external_fun_lowLevelStaticCall()
            {
                
                let param, param_1 := abi_decode_bytes_calldata(calldatasize())
                let value := and(sload( 0x01),  sub(shl(160, 1), 1))
                
                let _1 :=  mload(64)
                calldatacopy(_1, param, param_1)
                let _2 := add(_1, param_1)
                mstore(_2,  0)
                
                let expr_component := staticcall(gas(), value, _1, sub( _2,  _1),  0, 0)
                
                let var_result_mpos :=  extract_returndata()
                
                let memPos := mload(64)
                return(memPos, sub(abi_encode_bool_bytes(memPos, expr_component, var_result_mpos), memPos))
            }
            function external_fun_setImplementation()
            {
                
                if slt(add(calldatasize(), not(3)), 32)
                {
                    revert( 0, 0)
                }
                
                sstore( 0x02,  or(and(sload( 0x02),  shl(160, 0xffffffffffffffffffffffff)), and(abi_decode_address(), sub(shl(160, 1), 1))))
                return( 0, 0)
            }
            
            function external_fun_callWithValue()
            {
                if slt(add(calldatasize(), not(3)), 64)
                {
                    revert( 0, 0)
                }
                
                let value0 := abi_decode_address()
                let value := calldataload(36)
                
                let expr_component := call(gas(), value0, value,  0, 0, 0, 0)
                
                pop(extract_returndata())
                
                let memPos := mload(64)
                mstore(memPos, iszero(iszero(expr_component)))
                return(memPos, 32)
            }
            function external_fun_returnMultiple()
            {
                
                
                let memPos := mload(64)
                mstore(memPos,  0x01)
                
                mstore(add(memPos, 32),  0x02)
                
                mstore(add(memPos, 64),  0x03)
                
                return(memPos, 96)
            }
            
            
            function finalize_allocation(memPtr, size)
            {
                let newFreePtr := add(memPtr, and(add(size, 31), not(31)))
                
                mstore(64, newFreePtr)
            }
            function extract_returndata() -> data
            {
                switch returndatasize()
                case 0 { data := 96 }
                default {
                    let _1 := returndatasize()
                    
                    let memPtr := mload(64)
                    finalize_allocation(memPtr, add(and(add(_1, 31), not(31)), 0x20))
                    mstore(memPtr, _1)
                    data := memPtr
                    returndatacopy(add(memPtr, 0x20),  0,  returndatasize())
                }
            }
            function abi_encode_uint256_uint256(headStart, value0, value1) -> tail
            {
                tail := add(headStart, 64)
                mstore(headStart, value0)
                mstore(add(headStart, 32), value1)
            }
            function abi_decode_uint256_fromMemory(headStart, dataEnd) -> value0
            {
                if slt(sub(dataEnd, headStart), 32) { revert(0, 0) }
                value0 := mload(headStart)
            }
            /// @ast-id 608 @src 0:6152:6526  "fallback() external payable {..."
            function fun()
            {
                
                let value := and(sload( 0x02),  sub(shl(160, 1), 1))
                
                if  value
                
                {
                    
                    let _1 :=  mload(64)
                    calldatacopy(_1,  0,  calldatasize())
                    
                    let _2 := add(_1,  calldatasize())
                    
                    mstore(_2,  0)
                    
                    let expr_component := delegatecall(gas(), value, _1, sub( _2,  _1),  0, 0)
                    
                    let expr_598_component_2_mpos := extract_returndata()
                    
                    if iszero(expr_component)
                    {
                        revert( 0, 0)
                    }
                    
                    return(add(expr_598_component_2_mpos, 32), mload(expr_598_component_2_mpos))
                }
            }
            /// @ast-id 348 @src 0:3462:3598  "function _fib(uint256 n) internal pure returns (uint256) {..."
            function fun_fib(var_n) -> var
            {
                
                var :=  0
                
                if  iszero(gt(var_n,  0x01))
                
                {
                    
                    var := var_n
                    leave
                }
                
                let diff := add(var_n, not(0))
                
                
                let expr := fun_fib( diff)
                
                let diff_1 := add(var_n, not(1))
                
                let sum := add(expr,  fun_fib( diff_1))
                
                
                
                var := sum
            }
            /// @ast-id 302 @src 0:3182:3320  "function _factorial(uint256 n) internal pure returns (uint256) {..."
            function fun_factorial(var_n) -> var
            {
                
                var :=  0
                
                if  iszero(gt(var_n,  0x01))
                
                {
                    
                    var :=  0x01
                    
                    leave
                }
                
                let diff := add(var_n, not(0))
                
                
                let _1 := fun_factorial( diff)
                
                let product := mul(var_n, _1)
                
                
                var := product
            }
        }
        data ".metadata" hex"a26469706673582212209ea918bdf3d4aa5aeb6dc787d58ecee58e1b842ec3ceed447d39627a6e1b31cb64736f6c634300081c0033"
    }
}