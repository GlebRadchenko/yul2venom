object "Functions_609" {
    code {
        {
            /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("Functions_609_deployed")
            codecopy(_1, dataoffset("Functions_609_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/bench/Functions.sol"
    object "Functions_609_deployed" {
        code {
            {
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                mstore(64, 128)
                if iszero(lt(calldatasize(), 4))
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
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                /// @src 0:2248:2258  "virtualB()"
                let var := /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ 0
                /// @src 0:2032:2059  "return super.virtualB() + 2"
                var := /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ 222
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
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 32)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                let value := /** @src -1:-1:-1 */ 0
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                value := calldataload(4)
                let sum := add(value, /** @src 0:2966:2968  "10" */ 0x0a)
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                if gt(value, sum) { panic_error_0x11() }
                let product := shl(1, sum)
                if iszero(or(iszero(sum), eq(/** @src 0:2871:2872  "2" */ 0x02, /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ div(product, sum)))) { panic_error_0x11() }
                let sum_1 := add(product, 1)
                if gt(product, sum_1) { panic_error_0x11() }
                let memPos := mload(64)
                mstore(memPos, sum_1)
                return(memPos, 32)
            }
            function external_fun_callTarget()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                let value := and(sload(/** @src 0:1263:1288  "address public callTarget" */ 1), /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ sub(shl(160, 1), 1))
                let memPos := mload(64)
                mstore(memPos, value)
                return(memPos, 32)
            }
            function external_fun_virtualA()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                let var := 0
                /// @src 0:1916:1943  "return super.virtualA() + 1"
                var := /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ 111
                let memPos := mload(64)
                mstore(memPos, 111)
                return(memPos, 32)
            }
            function external_fun_selfAdd()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 64)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                let value := /** @src -1:-1:-1 */ 0
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                value := calldataload(4)
                let value_1 := /** @src -1:-1:-1 */ 0
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                value_1 := calldataload(36)
                let sum := add(value, value_1)
                if gt(value, sum) { panic_error_0x11() }
                let memPos := mload(64)
                mstore(memPos, sum)
                return(memPos, 32)
            }
            function abi_decode_bytes_calldata(dataEnd) -> value0, value1
            {
                if slt(add(dataEnd, not(3)), 32) { revert(0, 0) }
                let offset := calldataload(4)
                if gt(offset, 0xffffffffffffffff) { revert(0, 0) }
                if iszero(slt(add(offset, 35), dataEnd))
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                let length := calldataload(add(4, offset))
                if gt(length, 0xffffffffffffffff)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                if gt(add(add(offset, length), 36), dataEnd)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                value0 := add(offset, 36)
                value1 := length
            }
            function abi_encode_bytes(value, pos) -> end
            {
                let length := mload(value)
                mstore(pos, length)
                mcopy(add(pos, 0x20), add(value, 0x20), length)
                mstore(add(add(pos, length), 0x20), /** @src -1:-1:-1 */ 0)
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
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
                if callvalue() { revert(0, 0) }
                let param, param_1 := abi_decode_bytes_calldata(calldatasize())
                let value := and(sload(/** @src 0:4526:4536  "callTarget" */ 0x01), /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ sub(shl(160, 1), 1))
                /// @src 0:4526:4555  "callTarget.delegatecall(data)"
                let _1 := /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ mload(64)
                calldatacopy(_1, param, param_1)
                let _2 := add(_1, param_1)
                mstore(_2, /** @src -1:-1:-1 */ 0)
                /// @src 0:4526:4555  "callTarget.delegatecall(data)"
                let expr_component := delegatecall(gas(), value, _1, sub(/** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ _2, /** @src 0:4526:4555  "callTarget.delegatecall(data)" */ _1), /** @src -1:-1:-1 */ 0, 0)
                /// @src 0:4506:4555  "(success, result) = callTarget.delegatecall(data)"
                let var_result_mpos := /** @src 0:4526:4555  "callTarget.delegatecall(data)" */ extract_returndata()
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                let memPos := mload(64)
                return(memPos, sub(abi_encode_bool_bytes(memPos, expr_component, var_result_mpos), memPos))
            }
            function external_fun_implementation()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                let value := and(sload(/** @src 0:5710:5739  "address public implementation" */ 2), /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ sub(shl(160, 1), 1))
                let memPos := mload(64)
                mstore(memPos, value)
                return(memPos, 32)
            }
            function external_fun_fibonacci()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 32)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                let value := /** @src -1:-1:-1 */ 0
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                value := calldataload(4)
                let var_n := value
                /// @src 0:3398:3416  "if (n > 20) n = 20"
                if /** @src 0:3402:3408  "n > 20" */ gt(value, /** @src 0:3406:3408  "20" */ 0x14)
                /// @src 0:3398:3416  "if (n > 20) n = 20"
                {
                    /// @src 0:3410:3416  "n = 20"
                    var_n := /** @src 0:3406:3408  "20" */ 0x14
                }
                /// @src 0:3435:3449  "return _fib(n)"
                let var := /** @src 0:3442:3449  "_fib(n)" */ fun_fib(var_n)
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                let memPos := mload(64)
                mstore(memPos, var)
                return(memPos, 32)
            }
            function external_fun_storedValue()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                let _1 := sload(0)
                let memPos := mload(64)
                mstore(memPos, _1)
                return(memPos, 32)
            }
            function abi_decode_address() -> value
            {
                value := calldataload(4)
                if iszero(eq(value, and(value, sub(shl(160, 1), 1)))) { revert(0, 0) }
            }
            function external_fun_staticCallPure()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 96)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                let value0 := abi_decode_address()
                let value1 := abi_decode_uint256_3458()
                let value2 := abi_decode_uint256()
                /// @src 0:5075:5132  "abi.encodeWithSignature(\"pureAdd(uint256,uint256)\", a, b)"
                let expr_mpos := /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ mload(64)
                /// @src 0:5075:5132  "abi.encodeWithSignature(\"pureAdd(uint256,uint256)\", a, b)"
                let _1 := add(expr_mpos, /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ 32)
                /// @src 0:5075:5132  "abi.encodeWithSignature(\"pureAdd(uint256,uint256)\", a, b)"
                mstore(_1, shl(226, 0x2ba8fca3))
                let _2 := sub(abi_encode_uint256_uint256(add(expr_mpos, /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ 36), /** @src 0:5075:5132  "abi.encodeWithSignature(\"pureAdd(uint256,uint256)\", a, b)" */ value1, value2), expr_mpos)
                mstore(expr_mpos, add(_2, /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ not(31)))
                /// @src 0:5075:5132  "abi.encodeWithSignature(\"pureAdd(uint256,uint256)\", a, b)"
                finalize_allocation(expr_mpos, _2)
                /// @src 0:5044:5142  "target.staticcall(..."
                let expr_component := staticcall(gas(), value0, _1, mload(expr_mpos), /** @src -1:-1:-1 */ 0, 0)
                /// @src 0:5044:5142  "target.staticcall(..."
                let expr_component_mpos := extract_returndata()
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                if iszero(expr_component)
                {
                    let memPtr := mload(64)
                    mstore(memPtr, shl(229, 4594637))
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 17)
                    mstore(add(memPtr, 68), "staticcall failed")
                    revert(memPtr, 100)
                }
                /// @src 0:5199:5235  "return abi.decode(result, (uint256))"
                let var := /** @src 0:5206:5235  "abi.decode(result, (uint256))" */ abi_decode_uint256_fromMemory(add(expr_component_mpos, /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ 32), /** @src 0:5206:5235  "abi.decode(result, (uint256))" */ add(add(expr_component_mpos, /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ mload(/** @src 0:5206:5235  "abi.decode(result, (uint256))" */ expr_component_mpos)), /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ 32))
                let memPos := mload(64)
                return(memPos, sub(abi_encode_uint256(memPos, var), memPos))
            }
            function external_fun_returnNothing()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                return(0, 0)
            }
            function external_fun_factorial()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 32)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                let value := /** @src -1:-1:-1 */ 0
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                value := calldataload(4)
                let var_n := value
                /// @src 0:3092:3110  "if (n > 12) n = 12"
                if /** @src 0:3096:3102  "n > 12" */ gt(value, /** @src 0:3100:3102  "12" */ 0x0c)
                /// @src 0:3092:3110  "if (n > 12) n = 12"
                {
                    /// @src 0:3104:3110  "n = 12"
                    var_n := /** @src 0:3100:3102  "12" */ 0x0c
                }
                /// @src 0:3149:3169  "return _factorial(n)"
                let var := /** @src 0:3156:3169  "_factorial(n)" */ fun_factorial(var_n)
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                let memPos := mload(64)
                mstore(memPos, var)
                return(memPos, 32)
            }
            function external_fun_callSelf()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 64)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                let value0 := abi_decode_uint256_3456()
                let value1 := abi_decode_uint256_3458()
                /// @src 0:3847:3865  "this.selfAdd(a, b)"
                let _1 := /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ mload(64)
                /// @src 0:3847:3865  "this.selfAdd(a, b)"
                mstore(_1, /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ shl(226, 0x0d93b4bd))
                /// @src 0:3847:3865  "this.selfAdd(a, b)"
                let _2 := staticcall(gas(), /** @src 0:3847:3851  "this" */ address(), /** @src 0:3847:3865  "this.selfAdd(a, b)" */ _1, sub(abi_encode_uint256_uint256(add(_1, /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ 4), /** @src 0:3847:3865  "this.selfAdd(a, b)" */ value0, value1), _1), _1, /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ 32)
                /// @src 0:3847:3865  "this.selfAdd(a, b)"
                if iszero(_2)
                {
                    /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                    let pos := mload(64)
                    returndatacopy(pos, /** @src -1:-1:-1 */ 0, /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ returndatasize())
                    revert(pos, returndatasize())
                }
                /// @src 0:3847:3865  "this.selfAdd(a, b)"
                let expr := /** @src -1:-1:-1 */ 0
                /// @src 0:3847:3865  "this.selfAdd(a, b)"
                if _2
                {
                    let _3 := /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ 32
                    /// @src 0:3847:3865  "this.selfAdd(a, b)"
                    if gt(/** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ 32, /** @src 0:3847:3865  "this.selfAdd(a, b)" */ returndatasize()) { _3 := returndatasize() }
                    finalize_allocation(_1, _3)
                    expr := abi_decode_uint256_fromMemory(_1, add(_1, _3))
                }
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                let memPos := mload(64)
                return(memPos, sub(abi_encode_uint256(memPos, expr), memPos))
            }
            function external_fun_setCallTarget()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 32)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                sstore(/** @src 0:3981:4000  "callTarget = target" */ 0x01, /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ or(and(sload(/** @src 0:3981:4000  "callTarget = target" */ 0x01), /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ shl(160, 0xffffffffffffffffffffffff)), and(abi_decode_address(), sub(shl(160, 1), 1))))
                return(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
            function external_fun_returnSingle()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                let memPos := mload(64)
                mstore(memPos, /** @src 0:1412:1414  "42" */ 0x2a)
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                return(memPos, 32)
            }
            function external_fun_interfaceFunc()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                let memPos := mload(64)
                mstore(memPos, /** @src 0:1782:1785  "999" */ 0x03e7)
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                return(memPos, 32)
            }
            function external_fun_proxyCall()
            {
                if callvalue() { revert(0, 0) }
                let param, param_1 := abi_decode_bytes_calldata(calldatasize())
                let value := and(sload(/** @src 0:5960:5974  "implementation" */ 0x02), /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ sub(shl(160, 1), 1))
                /// @src 0:5960:5993  "implementation.delegatecall(data)"
                let _1 := /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ mload(64)
                calldatacopy(_1, param, param_1)
                let _2 := add(_1, param_1)
                mstore(_2, /** @src -1:-1:-1 */ 0)
                /// @src 0:5960:5993  "implementation.delegatecall(data)"
                let expr_component := delegatecall(gas(), value, _1, sub(/** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ _2, /** @src 0:5960:5993  "implementation.delegatecall(data)" */ _1), /** @src -1:-1:-1 */ 0, 0)
                /// @src 0:5960:5993  "implementation.delegatecall(data)"
                let expr_component_mpos := extract_returndata()
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
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
                let tail := /** @src -1:-1:-1 */ 0
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                mstore(memPos, 32)
                tail := abi_encode_bytes(expr_component_mpos, add(memPos, 32))
                return(memPos, sub(tail, memPos))
            }
            function external_fun_delegateSetValue()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 64)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                let value0 := abi_decode_address()
                let value1 := abi_decode_uint256_3458()
                /// @src 0:5496:5549  "abi.encodeWithSignature(\"setAndDouble(uint256)\", val)"
                let expr_mpos := /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ mload(64)
                /// @src 0:5496:5549  "abi.encodeWithSignature(\"setAndDouble(uint256)\", val)"
                let _1 := add(expr_mpos, /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ 32)
                /// @src 0:5496:5549  "abi.encodeWithSignature(\"setAndDouble(uint256)\", val)"
                mstore(_1, shl(231, 0x01503d1f))
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                mstore(/** @src 0:5496:5549  "abi.encodeWithSignature(\"setAndDouble(uint256)\", val)" */ add(expr_mpos, /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ 36), value1)
                /// @src 0:5496:5549  "abi.encodeWithSignature(\"setAndDouble(uint256)\", val)"
                mstore(expr_mpos, /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ 36)
                /// @src 0:5496:5549  "abi.encodeWithSignature(\"setAndDouble(uint256)\", val)"
                finalize_allocation(expr_mpos, 68)
                /// @src 0:5461:5559  "library_.delegatecall(..."
                let expr_component := delegatecall(gas(), value0, _1, mload(expr_mpos), /** @src -1:-1:-1 */ 0, 0)
                /// @src 0:5461:5559  "library_.delegatecall(..."
                let expr_component_mpos := extract_returndata()
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                if iszero(expr_component)
                {
                    let memPtr := mload(64)
                    mstore(memPtr, shl(229, 4594637))
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 19)
                    mstore(add(memPtr, /** @src 0:5496:5549  "abi.encodeWithSignature(\"setAndDouble(uint256)\", val)" */ 68), /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ "delegatecall failed")
                    revert(memPtr, 100)
                }
                /// @src 0:5618:5654  "return abi.decode(result, (uint256))"
                let var := /** @src 0:5625:5654  "abi.decode(result, (uint256))" */ abi_decode_uint256_fromMemory(add(expr_component_mpos, /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ 32), /** @src 0:5625:5654  "abi.decode(result, (uint256))" */ add(add(expr_component_mpos, /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ mload(/** @src 0:5625:5654  "abi.decode(result, (uint256))" */ expr_component_mpos)), /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ 32))
                let memPos := mload(64)
                return(memPos, sub(abi_encode_uint256(memPos, var), memPos))
            }
            function external_fun_lowLevelCall()
            {
                if callvalue() { revert(0, 0) }
                let param, param_1 := abi_decode_bytes_calldata(calldatasize())
                let value := and(sload(/** @src 0:4153:4163  "callTarget" */ 0x01), /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ sub(shl(160, 1), 1))
                /// @src 0:4153:4174  "callTarget.call(data)"
                let _1 := /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ mload(64)
                calldatacopy(_1, param, param_1)
                let _2 := add(_1, param_1)
                mstore(_2, /** @src -1:-1:-1 */ 0)
                /// @src 0:4153:4174  "callTarget.call(data)"
                let expr_component := call(gas(), value, /** @src -1:-1:-1 */ 0, /** @src 0:4153:4174  "callTarget.call(data)" */ _1, sub(/** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ _2, /** @src 0:4153:4174  "callTarget.call(data)" */ _1), /** @src -1:-1:-1 */ 0, 0)
                /// @src 0:4133:4174  "(success, result) = callTarget.call(data)"
                let var_result_mpos := /** @src 0:4153:4174  "callTarget.call(data)" */ extract_returndata()
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                let memPos := mload(64)
                return(memPos, sub(abi_encode_bool_bytes(memPos, expr_component, var_result_mpos), memPos))
            }
            function external_fun_lowLevelStaticCall()
            {
                if callvalue() { revert(0, 0) }
                let param, param_1 := abi_decode_bytes_calldata(calldatasize())
                let value := and(sload(/** @src 0:4338:4348  "callTarget" */ 0x01), /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ sub(shl(160, 1), 1))
                /// @src 0:4338:4365  "callTarget.staticcall(data)"
                let _1 := /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ mload(64)
                calldatacopy(_1, param, param_1)
                let _2 := add(_1, param_1)
                mstore(_2, /** @src -1:-1:-1 */ 0)
                /// @src 0:4338:4365  "callTarget.staticcall(data)"
                let expr_component := staticcall(gas(), value, _1, sub(/** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ _2, /** @src 0:4338:4365  "callTarget.staticcall(data)" */ _1), /** @src -1:-1:-1 */ 0, 0)
                /// @src 0:4318:4365  "(success, result) = callTarget.staticcall(data)"
                let var_result_mpos := /** @src 0:4338:4365  "callTarget.staticcall(data)" */ extract_returndata()
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                let memPos := mload(64)
                return(memPos, sub(abi_encode_bool_bytes(memPos, expr_component, var_result_mpos), memPos))
            }
            function external_fun_setImplementation()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 32)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                sstore(/** @src 0:5806:5827  "implementation = impl" */ 0x02, /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ or(and(sload(/** @src 0:5806:5827  "implementation = impl" */ 0x02), /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ shl(160, 0xffffffffffffffffffffffff)), and(abi_decode_address(), sub(shl(160, 1), 1))))
                return(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
            function external_fun_callWithValue()
            {
                if slt(add(calldatasize(), not(3)), 64)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                let value0 := abi_decode_address()
                let value := /** @src -1:-1:-1 */ 0
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                value := calldataload(36)
                /// @src 0:4751:4781  "target.call{value: amount}(\"\")"
                let expr_component := call(gas(), value0, value, /** @src -1:-1:-1 */ 0, 0, 0, 0)
                /// @src 0:4751:4781  "target.call{value: amount}(\"\")"
                pop(extract_returndata())
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                let memPos := mload(64)
                mstore(memPos, iszero(iszero(expr_component)))
                return(memPos, 32)
            }
            function external_fun_returnMultiple()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                let memPos := mload(64)
                mstore(memPos, /** @src 0:1549:1550  "1" */ 0x01)
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                mstore(add(memPos, 32), /** @src 0:1552:1553  "2" */ 0x02)
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                mstore(add(memPos, 64), /** @src 0:1555:1556  "3" */ 0x03)
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                return(memPos, 96)
            }
            function panic_error_0x11()
            {
                mstore(0, shl(224, 0x4e487b71))
                mstore(4, 0x11)
                revert(0, 0x24)
            }
            function panic_error_0x41()
            {
                mstore(0, shl(224, 0x4e487b71))
                mstore(4, 0x41)
                revert(0, 0x24)
            }
            function finalize_allocation(memPtr, size)
            {
                let newFreePtr := add(memPtr, and(add(size, 31), not(31)))
                if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr)) { panic_error_0x41() }
                mstore(64, newFreePtr)
            }
            function extract_returndata() -> data
            {
                switch returndatasize()
                case 0 { data := 96 }
                default {
                    let _1 := returndatasize()
                    if gt(_1, 0xffffffffffffffff) { panic_error_0x41() }
                    let memPtr := mload(64)
                    finalize_allocation(memPtr, add(and(add(_1, 31), not(31)), 0x20))
                    mstore(memPtr, _1)
                    data := memPtr
                    returndatacopy(add(memPtr, 0x20), /** @src -1:-1:-1 */ 0, /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ returndatasize())
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
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                let value := and(sload(/** @src 0:6238:6252  "implementation" */ 0x02), /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ sub(shl(160, 1), 1))
                /// @src 0:6234:6520  "if (implementation != address(0)) {..."
                if /** @src 0:6238:6266  "implementation != address(0)" */ iszero(iszero(/** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ value))
                /// @src 0:6234:6520  "if (implementation != address(0)) {..."
                {
                    /// @src 0:6320:6387  "implementation.delegatecall(..."
                    let _1 := /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ mload(64)
                    calldatacopy(_1, /** @src -1:-1:-1 */ 0, /** @src 0:6365:6373  "msg.data" */ calldatasize())
                    /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                    let _2 := add(_1, /** @src 0:6365:6373  "msg.data" */ calldatasize())
                    /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                    mstore(_2, /** @src -1:-1:-1 */ 0)
                    /// @src 0:6320:6387  "implementation.delegatecall(..."
                    let expr_component := delegatecall(gas(), value, _1, sub(/** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ _2, /** @src 0:6320:6387  "implementation.delegatecall(..." */ _1), /** @src -1:-1:-1 */ 0, 0)
                    /// @src 0:6320:6387  "implementation.delegatecall(..."
                    let expr_598_component_2_mpos := extract_returndata()
                    /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                    if iszero(expr_component)
                    {
                        revert(/** @src -1:-1:-1 */ 0, 0)
                    }
                    /// @src 0:6431:6510  "assembly {..."
                    return(add(expr_598_component_2_mpos, 32), mload(expr_598_component_2_mpos))
                }
            }
            /// @ast-id 348 @src 0:3462:3598  "function _fib(uint256 n) internal pure returns (uint256) {..."
            function fun_fib(var_n) -> var
            {
                /// @src 0:3510:3517  "uint256"
                var := /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ 0
                /// @src 0:3529:3549  "if (n <= 1) return n"
                if /** @src 0:3533:3539  "n <= 1" */ iszero(gt(var_n, /** @src 0:3538:3539  "1" */ 0x01))
                /// @src 0:3529:3549  "if (n <= 1) return n"
                {
                    /// @src 0:3541:3549  "return n"
                    var := var_n
                    leave
                }
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                let diff := add(var_n, not(0))
                if gt(diff, var_n) { panic_error_0x11() }
                /// @src 0:3566:3577  "_fib(n - 1)"
                let expr := fun_fib(/** @src 0:3571:3576  "n - 1" */ diff)
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                let diff_1 := add(var_n, not(1))
                if gt(diff_1, var_n) { panic_error_0x11() }
                let sum := add(expr, /** @src 0:3580:3591  "_fib(n - 2)" */ fun_fib(/** @src 0:3585:3590  "n - 2" */ diff_1))
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                if gt(expr, sum) { panic_error_0x11() }
                /// @src 0:3559:3591  "return _fib(n - 1) + _fib(n - 2)"
                var := sum
            }
            /// @ast-id 302 @src 0:3182:3320  "function _factorial(uint256 n) internal pure returns (uint256) {..."
            function fun_factorial(var_n) -> var
            {
                /// @src 0:3236:3243  "uint256"
                var := /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ 0
                /// @src 0:3255:3275  "if (n <= 1) return 1"
                if /** @src 0:3259:3265  "n <= 1" */ iszero(gt(var_n, /** @src 0:3264:3265  "1" */ 0x01))
                /// @src 0:3255:3275  "if (n <= 1) return 1"
                {
                    /// @src 0:3267:3275  "return 1"
                    var := /** @src 0:3264:3265  "1" */ 0x01
                    /// @src 0:3267:3275  "return 1"
                    leave
                }
                /// @src 0:1189:6528  "contract Functions is Middle, IBase {..."
                let diff := add(var_n, not(0))
                if gt(diff, var_n) { panic_error_0x11() }
                /// @src 0:3296:3313  "_factorial(n - 1)"
                let _1 := fun_factorial(/** @src 0:3307:3312  "n - 1" */ diff)
                /// @src 0:3292:3313  "n * _factorial(n - 1)"
                let product := /** @src 0:1189:6528  "contract Functions is Middle, IBase {..." */ 0
                product := mul(var_n, _1)
                if iszero(or(iszero(var_n), eq(_1, div(product, var_n)))) { panic_error_0x11() }
                /// @src 0:3285:3313  "return n * _factorial(n - 1)"
                var := product
            }
        }
        data ".metadata" hex"a26469706673582212209ea918bdf3d4aa5aeb6dc787d58ecee58e1b842ec3ceed447d39627a6e1b31cb64736f6c634300081c0033"
    }
}