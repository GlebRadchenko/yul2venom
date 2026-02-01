object "MegaTest_469" {
    code {
        {
            /// @src 0:795:5708  "contract MegaTest is Middle {..."
            let _1 := memoryguard(0x80)
            if callvalue() { revert(0, 0) }
            let programSize := datasize("MegaTest_469")
            let argSize := sub(codesize(), programSize)
            let newFreePtr := add(_1, and(add(argSize, 31), not(31)))
            if or(gt(newFreePtr, sub(shl(64, 1), 1)), lt(newFreePtr, _1))
            {
                mstore(/** @src -1:-1:-1 */ 0, /** @src 0:795:5708  "contract MegaTest is Middle {..." */ shl(224, 0x4e487b71))
                mstore(4, 0x41)
                revert(/** @src -1:-1:-1 */ 0, /** @src 0:795:5708  "contract MegaTest is Middle {..." */ 0x24)
            }
            mstore(64, newFreePtr)
            codecopy(_1, programSize, argSize)
            if slt(sub(add(_1, argSize), _1), 32)
            {
                revert(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 0:795:5708  "contract MegaTest is Middle {..."
            let value := mload(_1)
            let _2 := and(value, sub(shl(160, 1), 1))
            if iszero(eq(value, _2))
            {
                revert(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 0:795:5708  "contract MegaTest is Middle {..."
            sstore(/** @src 0:1552:1562  "lib = _lib" */ 0x07, /** @src 0:795:5708  "contract MegaTest is Middle {..." */ or(and(sload(/** @src 0:1552:1562  "lib = _lib" */ 0x07), /** @src 0:795:5708  "contract MegaTest is Middle {..." */ not(sub(shl(160, 1), 1))), _2))
            sstore(/** @src 0:1572:1590  "state = State.IDLE" */ 0x02, /** @src 0:795:5708  "contract MegaTest is Middle {..." */ and(sload(/** @src 0:1572:1590  "state = State.IDLE" */ 0x02), /** @src 0:795:5708  "contract MegaTest is Middle {..." */ not(255)))
            sstore(/** @src 0:1600:1606  "config" */ 0x03, /** @src 0:1616:1618  "10" */ 0x0a)
            /// @src 0:795:5708  "contract MegaTest is Middle {..."
            sstore(4, /** @src 0:1644:1647  "100" */ 0x64)
            /// @src 0:795:5708  "contract MegaTest is Middle {..."
            sstore(/** @src 0:1657:1669  "config.admin" */ 5, /** @src 0:795:5708  "contract MegaTest is Middle {..." */ or(and(sload(/** @src 0:1657:1669  "config.admin" */ 5), /** @src 0:795:5708  "contract MegaTest is Middle {..." */ not(sub(shl(160, 1), 1))), /** @src 0:1672:1682  "msg.sender" */ caller()))
            /// @src 0:795:5708  "contract MegaTest is Middle {..."
            let _3 := mload(64)
            let _4 := datasize("MegaTest_469_deployed")
            codecopy(_3, dataoffset("MegaTest_469_deployed"), _4)
            return(_3, _4)
        }
    }
    /// @use-src 0:"foundry/src/MegaTest.sol"
    object "MegaTest_469_deployed" {
        code {
            {
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                mstore(64, 128)
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x0591d3ab { external_fun_updateState() }
                    case 0x1495fcf3 {
                        external_fun_getRecursionDepth()
                    }
                    case 0x27e235e3 { external_fun_balances() }
                    case 0x2def54e0 { external_fun_callA() }
                    case 0x38e80f68 { external_fun_setBase() }
                    case 0x76f8c287 { external_fun_baseVal() }
                    case 0x79502c55 { external_fun_config() }
                    case 0x8294326b { external_fun_getTransient() }
                    case 0x92801230 { external_fun_lib() }
                    case 0x97f60695 { external_fun_checkConfig() }
                    case 0xb9cdba71 { external_fun_logic() }
                    case 0xc19d93fb { external_fun_state() }
                    case 0xc4250732 { external_fun_middleVal() }
                    case 0xc511a619 {
                        external_fun_transientCounter()
                    }
                    case 0xcaa78917 { external_fun_setTransient() }
                    case 0xe296f284 { external_fun_processStructs() }
                    case 0xe733e781 { external_fun_runCalc() }
                }
                if iszero(calldatasize()) { stop() }
                fun()
            }
            function external_fun_updateState()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 32)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                let value := calldataload(4)
                let _1 := iszero(lt(value, 4))
                if _1
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                _1 := /** @src -1:-1:-1 */ 0
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                if /** @src 0:2090:2116  "_newState != State.STOPPED" */ eq(value, /** @src 0:2103:2116  "State.STOPPED" */ 3)
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                {
                    let memPtr := mload(64)
                    mstore(memPtr, shl(229, 4594637))
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 11)
                    mstore(add(memPtr, 68), "Cannot stop")
                    revert(memPtr, 100)
                }
                if iszero(lt(/** @src 0:2142:2159  "state = _newState" */ value, /** @src 0:795:5708  "contract MegaTest is Middle {..." */ 4))
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:795:5708  "contract MegaTest is Middle {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x21)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:795:5708  "contract MegaTest is Middle {..." */ 0x24)
                }
                let value_1 := and(sload(/** @src 0:2142:2159  "state = _newState" */ 0x02), /** @src 0:795:5708  "contract MegaTest is Middle {..." */ not(255))
                sstore(/** @src 0:2142:2159  "state = _newState" */ 0x02, /** @src 0:795:5708  "contract MegaTest is Middle {..." */ or(value_1, and(/** @src 0:2142:2159  "state = _newState" */ value, /** @src 0:795:5708  "contract MegaTest is Middle {..." */ 255)))
                return(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 0:795:5708  "contract MegaTest is Middle {..."
            function external_fun_getRecursionDepth()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                let ret := /** @src 0:5637:5700  "assembly {..." */ tload(512)
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                let memPos := mload(64)
                mstore(memPos, ret)
                return(memPos, 32)
            }
            function external_fun_balances()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 32)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                let value := calldataload(4)
                let _1 := and(value, sub(shl(160, 1), 1))
                if iszero(eq(value, _1))
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                mstore(/** @src -1:-1:-1 */ 0, /** @src 0:795:5708  "contract MegaTest is Middle {..." */ _1)
                mstore(32, /** @src 0:879:922  "mapping(address => uint256) public balances" */ 6)
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                let _2 := sload(keccak256(/** @src -1:-1:-1 */ 0, /** @src 0:795:5708  "contract MegaTest is Middle {..." */ 0x40))
                let memPos := mload(0x40)
                mstore(memPos, _2)
                return(memPos, 32)
            }
            function external_fun_callA()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 32)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                let value := /** @src -1:-1:-1 */ 0
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                value := calldataload(4)
                let ret := fun_callA(value)
                let memPos := mload(64)
                mstore(memPos, ret)
                return(memPos, 32)
            }
            function external_fun_setBase()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 32)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                let value := /** @src -1:-1:-1 */ 0
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                value := calldataload(4)
                let product := shl(1, value)
                if iszero(or(iszero(value), eq(/** @src 0:635:636  "2" */ 0x02, /** @src 0:795:5708  "contract MegaTest is Middle {..." */ div(product, value)))) { panic_error_0x11() }
                sstore(/** @src -1:-1:-1 */ 0, /** @src 0:795:5708  "contract MegaTest is Middle {..." */ product)
                /// @src 0:365:378  "BaseLog(_val)"
                let _1 := /** @src 0:795:5708  "contract MegaTest is Middle {..." */ mload(64)
                mstore(_1, product)
                /// @src 0:365:378  "BaseLog(_val)"
                log1(_1, /** @src 0:795:5708  "contract MegaTest is Middle {..." */ 32, /** @src 0:365:378  "BaseLog(_val)" */ 0x5bd6f351647a993b2105c3591351fe8c025806d42e284ff5056d411bf57a530b)
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                sstore(1, value)
                return(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 0:795:5708  "contract MegaTest is Middle {..."
            function external_fun_baseVal()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                let _1 := sload(0)
                let memPos := mload(64)
                mstore(memPos, _1)
                return(memPos, 32)
            }
            function external_fun_config()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                let _1 := sload(/** @src 0:853:873  "Config public config" */ 3)
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                let _2 := sload(4)
                let value := and(sload(/** @src 0:853:873  "Config public config" */ 5), /** @src 0:795:5708  "contract MegaTest is Middle {..." */ sub(shl(160, 1), 1))
                let memPos := mload(64)
                mstore(memPos, _1)
                mstore(add(memPos, 32), _2)
                mstore(add(memPos, 64), value)
                return(memPos, 96)
            }
            function external_fun_getTransient()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 32)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                let value := /** @src -1:-1:-1 */ 0
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                value := calldataload(4)
                /// @src 0:3534:3588  "assembly {..."
                let var_result := tload(value)
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                let memPos := mload(64)
                mstore(memPos, var_result)
                return(memPos, 32)
            }
            function external_fun_lib()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                let value := and(sload(/** @src 0:928:946  "address public lib" */ 7), /** @src 0:795:5708  "contract MegaTest is Middle {..." */ sub(shl(160, 1), 1))
                let memPos := mload(64)
                mstore(memPos, value)
                return(memPos, 32)
            }
            function external_fun_checkConfig()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 32)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                let value := /** @src -1:-1:-1 */ 0
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                value := calldataload(4)
                /// @src 0:2887:2927  "x >= config.minVal && x <= config.maxVal"
                let expr := /** @src 0:2887:2905  "x >= config.minVal" */ iszero(lt(value, /** @src 0:795:5708  "contract MegaTest is Middle {..." */ sload(/** @src 0:2892:2898  "config" */ 0x03)))
                /// @src 0:2887:2927  "x >= config.minVal && x <= config.maxVal"
                if expr
                {
                    expr := /** @src 0:2909:2927  "x <= config.maxVal" */ iszero(gt(value, /** @src 0:795:5708  "contract MegaTest is Middle {..." */ sload(4)))
                }
                let memPos := mload(64)
                mstore(memPos, iszero(iszero(expr)))
                return(memPos, 32)
            }
            function external_fun_logic()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 32)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                let value := /** @src -1:-1:-1 */ 0
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                value := calldataload(4)
                let sum := add(value, /** @src 0:476:477  "1" */ 0x01)
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                if gt(value, sum) { panic_error_0x11() }
                let product := shl(/** @src 0:476:477  "1" */ 0x01, /** @src 0:795:5708  "contract MegaTest is Middle {..." */ sum)
                if iszero(or(iszero(sum), eq(/** @src 0:783:784  "2" */ 0x02, /** @src 0:795:5708  "contract MegaTest is Middle {..." */ div(product, sum)))) { panic_error_0x11() }
                let memPos := mload(64)
                mstore(memPos, product)
                return(memPos, 32)
            }
            function external_fun_state()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                let value := and(sload(/** @src 0:829:847  "State public state" */ 2), /** @src 0:795:5708  "contract MegaTest is Middle {..." */ 0xff)
                let memPos := mload(64)
                if iszero(lt(value, 4))
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x21)
                    revert(0, 0x24)
                }
                mstore(memPos, value)
                return(memPos, 32)
            }
            function external_fun_middleVal()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                let _1 := sload(/** @src 0:518:542  "uint256 public middleVal" */ 1)
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                let memPos := mload(64)
                mstore(memPos, _1)
                return(memPos, 32)
            }
            function external_fun_transientCounter()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                /// @src 0:3688:3787  "assembly {..."
                let var_current := tload(0x100)
                let _1 := add(var_current, 1)
                tstore(0x100, _1)
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                if gt(var_current, _1) { panic_error_0x11() }
                let memPos := mload(64)
                mstore(memPos, _1)
                return(memPos, 32)
            }
            function external_fun_setTransient()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 64)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                let value := /** @src -1:-1:-1 */ 0
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                value := calldataload(4)
                let value_1 := /** @src -1:-1:-1 */ 0
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                value_1 := calldataload(36)
                /// @src 0:3387:3439  "assembly {..."
                tstore(value, value_1)
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                return(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 0:795:5708  "contract MegaTest is Middle {..."
            function abi_encode_array_struct_Element_dyn(headStart, value0) -> tail
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
                    let _1 := mload(srcPtr)
                    mstore(pos, mload(_1))
                    mstore(add(pos, 32), mload(add(_1, 32)))
                    pos := add(pos, 64)
                    srcPtr := add(srcPtr, 32)
                }
                tail := pos
            }
            function external_fun_processStructs()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 32)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                let offset := calldataload(4)
                if gt(offset, 0xffffffffffffffff)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                if iszero(slt(add(offset, 35), calldatasize()))
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                let length := calldataload(add(4, offset))
                if gt(length, 0xffffffffffffffff)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                if gt(add(add(offset, shl(6, length)), 36), calldatasize())
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                let ret := /** @src 0:1173:1192  "_mapElements(input)" */ fun_mapElements(/** @src 0:795:5708  "contract MegaTest is Middle {..." */ add(offset, 36), length)
                let memPos := mload(64)
                return(memPos, sub(abi_encode_array_struct_Element_dyn(memPos, ret), memPos))
            }
            function external_fun_runCalc()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 32)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                let value := /** @src -1:-1:-1 */ 0
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                value := calldataload(4)
                /// @src 0:3081:3086  "x * y"
                let product := /** @src -1:-1:-1 */ 0
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                product := mul(value, /** @src 0:3194:3196  "10" */ 0x0a)
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                if iszero(or(iszero(value), eq(/** @src 0:3194:3196  "10" */ 0x0a, /** @src 0:795:5708  "contract MegaTest is Middle {..." */ div(product, value)))) { panic_error_0x11() }
                let sum := add(product, /** @src 0:3089:3090  "1" */ 0x01)
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                if gt(product, sum) { panic_error_0x11() }
                let memPos := mload(64)
                mstore(memPos, sum)
                return(memPos, 32)
            }
            function panic_error_0x11()
            {
                mstore(0, shl(224, 0x4e487b71))
                mstore(4, 0x11)
                revert(0, 0x24)
            }
            /// @ast-id 395 @src 0:4129:4742  "function callA(uint256 value) public returns (uint256) {..."
            function fun_callA(var_value) -> var
            {
                /// @src 0:4217:4330  "assembly {..."
                let var_depth := tload(512)
                tstore(512, add(var_depth, 1))
                /// @src 0:4344:4361  "Debug(100, value)"
                let _1 := /** @src 0:795:5708  "contract MegaTest is Middle {..." */ mload(64)
                mstore(_1, /** @src 0:4350:4353  "100" */ 0x64)
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                mstore(add(_1, 32), var_value)
                /// @src 0:4344:4361  "Debug(100, value)"
                log1(_1, /** @src 0:795:5708  "contract MegaTest is Middle {..." */ 64, /** @src 0:4344:4361  "Debug(100, value)" */ 0xad7c87b11456fab3d69245f95442061bce96cb3c345293507ec8bae59023990f)
                /// @src 0:4376:4393  "Debug(101, depth)"
                let _2 := /** @src 0:795:5708  "contract MegaTest is Middle {..." */ mload(64)
                mstore(_2, /** @src 0:4382:4385  "101" */ 0x65)
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                mstore(add(_2, 32), var_depth)
                /// @src 0:4376:4393  "Debug(101, depth)"
                log1(_2, /** @src 0:795:5708  "contract MegaTest is Middle {..." */ 64, /** @src 0:4344:4361  "Debug(100, value)" */ 0xad7c87b11456fab3d69245f95442061bce96cb3c345293507ec8bae59023990f)
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                let sum := add(var_value, /** @src 0:4217:4330  "assembly {..." */ 1)
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                if gt(var_value, sum) { panic_error_0x11() }
                /// @src 0:4477:4495  "Debug(102, result)"
                let _3 := /** @src 0:795:5708  "contract MegaTest is Middle {..." */ mload(64)
                mstore(_3, /** @src 0:4483:4486  "102" */ 0x66)
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                mstore(add(_3, 32), sum)
                /// @src 0:4477:4495  "Debug(102, result)"
                log1(_3, /** @src 0:795:5708  "contract MegaTest is Middle {..." */ 64, /** @src 0:4344:4361  "Debug(100, value)" */ 0xad7c87b11456fab3d69245f95442061bce96cb3c345293507ec8bae59023990f)
                /// @src 0:4541:4554  "callB(result)"
                let expr := fun_callB(sum)
                /// @src 0:4603:4712  "assembly {..."
                tstore(/** @src 0:4217:4330  "assembly {..." */ 512, /** @src 0:4603:4712  "assembly {..." */ add(tload(/** @src 0:4217:4330  "assembly {..." */ 512), /** @src 0:4603:4712  "assembly {..." */ not(0)))
                /// @src 0:4722:4735  "return result"
                var := expr
            }
            /// @src 0:795:5708  "contract MegaTest is Middle {..."
            function checked_mul_uint256(x) -> product
            {
                product := shl(1, x)
                if iszero(or(iszero(x), eq(/** @src 0:1490:1491  "2" */ 0x02, /** @src 0:795:5708  "contract MegaTest is Middle {..." */ div(product, x)))) { panic_error_0x11() }
            }
            /// @ast-id 262 @src 0:2301:2805  "fallback() external payable {..."
            function fun()
            {
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                let value := and(sload(/** @src 0:2354:2357  "lib" */ 0x07), /** @src 0:795:5708  "contract MegaTest is Middle {..." */ sub(shl(160, 1), 1))
                if /** @src 0:2375:2393  "_lib != address(0)" */ iszero(/** @src 0:795:5708  "contract MegaTest is Middle {..." */ value)
                {
                    let memPtr := mload(64)
                    mstore(memPtr, shl(229, 4594637))
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 11)
                    mstore(add(memPtr, 68), "Lib not set")
                    revert(memPtr, 100)
                }
                /// @src 0:2419:2799  "assembly {..."
                calldatacopy(/** @src -1:-1:-1 */ 0, 0, /** @src 0:2419:2799  "assembly {..." */ calldatasize())
                let usr$result := delegatecall(gas(), value, /** @src -1:-1:-1 */ 0, /** @src 0:2419:2799  "assembly {..." */ calldatasize(), /** @src -1:-1:-1 */ 0, 0)
                /// @src 0:2419:2799  "assembly {..."
                returndatacopy(/** @src -1:-1:-1 */ 0, 0, /** @src 0:2419:2799  "assembly {..." */ returndatasize())
                switch usr$result
                case 0 {
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:2419:2799  "assembly {..." */ returndatasize())
                }
                default {
                    return(/** @src -1:-1:-1 */ 0, /** @src 0:2419:2799  "assembly {..." */ returndatasize())
                }
            }
            /// @ast-id 427 @src 0:4748:5038  "function callB(uint256 value) internal returns (uint256) {..."
            function fun_callB(var_value) -> var
            {
                /// @src 0:4820:4837  "Debug(200, value)"
                let _1 := /** @src 0:795:5708  "contract MegaTest is Middle {..." */ mload(64)
                mstore(_1, /** @src 0:4826:4829  "200" */ 0xc8)
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                mstore(add(_1, 32), var_value)
                /// @src 0:4820:4837  "Debug(200, value)"
                log1(_1, /** @src 0:795:5708  "contract MegaTest is Middle {..." */ 64, /** @src 0:4820:4837  "Debug(200, value)" */ 0xad7c87b11456fab3d69245f95442061bce96cb3c345293507ec8bae59023990f)
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                let product := shl(1, var_value)
                if iszero(or(iszero(var_value), eq(/** @src 0:4914:4915  "2" */ 0x02, /** @src 0:795:5708  "contract MegaTest is Middle {..." */ div(product, var_value)))) { panic_error_0x11() }
                /// @src 0:4930:4948  "Debug(201, result)"
                let _2 := /** @src 0:795:5708  "contract MegaTest is Middle {..." */ mload(64)
                mstore(_2, /** @src 0:4936:4939  "201" */ 0xc9)
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                mstore(add(_2, 32), product)
                /// @src 0:4930:4948  "Debug(201, result)"
                log1(_2, /** @src 0:795:5708  "contract MegaTest is Middle {..." */ 64, /** @src 0:4820:4837  "Debug(200, value)" */ 0xad7c87b11456fab3d69245f95442061bce96cb3c345293507ec8bae59023990f)
                /// @src 0:5018:5031  "return result"
                var := /** @src 0:4994:5007  "callC(result)" */ fun_callC(product)
            }
            /// @src 0:795:5708  "contract MegaTest is Middle {..."
            function panic_error_0x41()
            {
                mstore(0, shl(224, 0x4e487b71))
                mstore(4, 0x41)
                revert(0, 0x24)
            }
            function allocate_memory_3395() -> memPtr
            {
                memPtr := mload(64)
                let newFreePtr := add(memPtr, 64)
                if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr)) { panic_error_0x41() }
                mstore(64, newFreePtr)
            }
            function allocate_memory(size) -> memPtr
            {
                memPtr := mload(64)
                let newFreePtr := add(memPtr, and(add(size, 31), not(31)))
                if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr)) { panic_error_0x41() }
                mstore(64, newFreePtr)
            }
            function array_allocation_size_array_struct_Element_dyn(length) -> size
            {
                if gt(length, 0xffffffffffffffff) { panic_error_0x41() }
                size := add(shl(5, length), 0x20)
            }
            function panic_error_0x32()
            {
                mstore(0, shl(224, 0x4e487b71))
                mstore(4, 0x32)
                revert(0, 0x24)
            }
            function calldata_array_index_access_struct_Element_calldata_dyn_calldata(base_ref, length, index) -> addr
            {
                if iszero(lt(index, length)) { panic_error_0x32() }
                addr := add(base_ref, shl(6, index))
            }
            function memory_array_index_access_struct_Element_dyn(baseRef, index) -> addr
            {
                if iszero(lt(index, mload(baseRef))) { panic_error_0x32() }
                addr := add(add(baseRef, shl(5, index)), 32)
            }
            /// @ast-id 173 @src 0:1205:1510  "function _mapElements(..."
            function fun_mapElements(var_input_offset, var_input_length) -> var_output_mpos
            {
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                let memPtr := allocate_memory(array_allocation_size_array_struct_Element_dyn(var_input_length))
                mstore(memPtr, var_input_length)
                let _1 := add(array_allocation_size_array_struct_Element_dyn(var_input_length), not(31))
                let i := /** @src -1:-1:-1 */ 0
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                for { } lt(i, _1) { i := add(i, 32) }
                {
                    let memPtr_1 := allocate_memory_3395()
                    mstore(memPtr_1, /** @src -1:-1:-1 */ 0)
                    /// @src 0:795:5708  "contract MegaTest is Middle {..."
                    mstore(add(memPtr_1, 32), /** @src -1:-1:-1 */ 0)
                    /// @src 0:795:5708  "contract MegaTest is Middle {..."
                    mstore(add(add(memPtr, i), 32), memPtr_1)
                }
                /// @src 0:1325:1361  "output = new Element[](input.length)"
                var_output_mpos := memPtr
                /// @src 0:1376:1389  "uint256 i = 0"
                let var_i := /** @src -1:-1:-1 */ 0
                /// @src 0:1371:1504  "for (uint256 i = 0; i < input.length; i++) {..."
                for { }
                /** @src 0:1391:1407  "i < input.length" */ lt(var_i, var_input_length)
                /// @src 0:1376:1389  "uint256 i = 0"
                {
                    /// @src 0:1409:1412  "i++"
                    var_i := /** @src 0:795:5708  "contract MegaTest is Middle {..." */ add(/** @src 0:1409:1412  "i++" */ var_i, /** @src 0:795:5708  "contract MegaTest is Middle {..." */ 1)
                }
                /// @src 0:1409:1412  "i++"
                {
                    /// @src 0:1453:1461  "input[i]"
                    let _2 := calldata_array_index_access_struct_Element_calldata_dyn_calldata(var_input_offset, var_input_length, var_i)
                    /// @src 0:1453:1464  "input[i].id"
                    let returnValue := /** @src -1:-1:-1 */ 0
                    /// @src 0:795:5708  "contract MegaTest is Middle {..."
                    returnValue := calldataload(_2)
                    /// @src 0:1473:1487  "input[i].value"
                    let _3 := add(/** @src 0:1473:1481  "input[i]" */ calldata_array_index_access_struct_Element_calldata_dyn_calldata(var_input_offset, var_input_length, var_i), /** @src 0:795:5708  "contract MegaTest is Middle {..." */ 32)
                    /// @src 0:1473:1487  "input[i].value"
                    let returnValue_1 := /** @src -1:-1:-1 */ 0
                    /// @src 0:795:5708  "contract MegaTest is Middle {..."
                    returnValue_1 := calldataload(_3)
                    /// @src 0:1473:1491  "input[i].value * 2"
                    let expr := checked_mul_uint256(/** @src 0:1473:1487  "input[i].value" */ returnValue_1)
                    /// @src 0:1440:1493  "Element({id: input[i].id, value: input[i].value * 2})"
                    let expr_mpos := /** @src 0:795:5708  "contract MegaTest is Middle {..." */ allocate_memory_3395()
                    mstore(expr_mpos, returnValue)
                    mstore(/** @src 0:1440:1493  "Element({id: input[i].id, value: input[i].value * 2})" */ add(expr_mpos, /** @src 0:795:5708  "contract MegaTest is Middle {..." */ 32), expr)
                    /// @src 0:1428:1493  "output[i] = Element({id: input[i].id, value: input[i].value * 2})"
                    mstore(memory_array_index_access_struct_Element_dyn(memPtr, var_i), expr_mpos)
                    pop(memory_array_index_access_struct_Element_dyn(memPtr, var_i))
                }
            }
            /// @ast-id 461 @src 0:5044:5556  "function callC(uint256 value) internal returns (uint256) {..."
            function fun_callC(var_value) -> var
            {
                /// @src 0:5092:5099  "uint256"
                var := /** @src 0:795:5708  "contract MegaTest is Middle {..." */ 0
                /// @src 0:5134:5197  "assembly {..."
                let var_depth := tload(512)
                /// @src 0:5211:5228  "Debug(300, value)"
                let _1 := /** @src 0:795:5708  "contract MegaTest is Middle {..." */ mload(64)
                mstore(_1, /** @src 0:5217:5220  "300" */ 0x012c)
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                mstore(add(_1, 32), var_value)
                /// @src 0:5211:5228  "Debug(300, value)"
                log1(_1, /** @src 0:795:5708  "contract MegaTest is Middle {..." */ 64, /** @src 0:5211:5228  "Debug(300, value)" */ 0xad7c87b11456fab3d69245f95442061bce96cb3c345293507ec8bae59023990f)
                /// @src 0:5243:5260  "Debug(301, depth)"
                let _2 := /** @src 0:795:5708  "contract MegaTest is Middle {..." */ mload(64)
                mstore(_2, /** @src 0:5249:5252  "301" */ 0x012d)
                /// @src 0:795:5708  "contract MegaTest is Middle {..."
                mstore(add(_2, 32), var_depth)
                /// @src 0:5243:5260  "Debug(301, depth)"
                log1(_2, /** @src 0:795:5708  "contract MegaTest is Middle {..." */ 64, /** @src 0:5211:5228  "Debug(300, value)" */ 0xad7c87b11456fab3d69245f95442061bce96cb3c345293507ec8bae59023990f)
                /// @src 0:5348:5550  "if (depth < MAX_RECURSION) {..."
                switch /** @src 0:5352:5373  "depth < MAX_RECURSION" */ lt(var_depth, /** @src 0:4077:4078  "3" */ 0x03)
                case /** @src 0:5348:5550  "if (depth < MAX_RECURSION) {..." */ 0 {
                    /// @src 0:5527:5539  "return value"
                    var := var_value
                    leave
                }
                default /// @src 0:5348:5550  "if (depth < MAX_RECURSION) {..."
                {
                    /// @src 0:5426:5445  "return callA(value)"
                    var := /** @src 0:5433:5445  "callA(value)" */ fun_callA(var_value)
                    /// @src 0:5426:5445  "return callA(value)"
                    leave
                }
            }
        }
        data ".metadata" hex"a2646970667358221220153d8825a6e74683d0df18383a6dd61253b87953d3e1e171cf908c0f88c328ab64736f6c634300081c0033"
    }
}