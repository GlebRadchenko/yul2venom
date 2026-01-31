object "ComplexFeaturesTest_144" {
    code {
        {
            /// @src 0:177:1652  "contract ComplexFeaturesTest is Base {..."
            let _1 := memoryguard(0xa0)
            if callvalue() { revert(0, 0) }
            let programSize := datasize("ComplexFeaturesTest_144")
            let argSize := sub(codesize(), programSize)
            let newFreePtr := add(_1, and(add(argSize, 31), not(31)))
            if or(gt(newFreePtr, sub(shl(64, 1), 1)), lt(newFreePtr, _1))
            {
                mstore(/** @src -1:-1:-1 */ 0, /** @src 0:177:1652  "contract ComplexFeaturesTest is Base {..." */ shl(224, 0x4e487b71))
                mstore(4, 0x41)
                revert(/** @src -1:-1:-1 */ 0, /** @src 0:177:1652  "contract ComplexFeaturesTest is Base {..." */ 0x24)
            }
            mstore(64, newFreePtr)
            codecopy(_1, programSize, argSize)
            if slt(sub(add(_1, argSize), _1), 32)
            {
                revert(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 0:501:521  "IMMUTABLE_VAL = _val"
            mstore(128, /** @src 0:177:1652  "contract ComplexFeaturesTest is Base {..." */ mload(_1))
            sstore(/** @src -1:-1:-1 */ 0, /** @src 0:177:1652  "contract ComplexFeaturesTest is Base {..." */ and(sload(/** @src -1:-1:-1 */ 0), /** @src 0:177:1652  "contract ComplexFeaturesTest is Base {..." */ not(255)))
            let _2 := mload(64)
            let _3 := datasize("ComplexFeaturesTest_144_deployed")
            codecopy(_2, dataoffset("ComplexFeaturesTest_144_deployed"), _3)
            setimmutable(_2, "14", mload(/** @src 0:501:521  "IMMUTABLE_VAL = _val" */ 128))
            /// @src 0:177:1652  "contract ComplexFeaturesTest is Base {..."
            return(_2, _3)
        }
    }
    /// @use-src 0:"contracts/ComplexFeaturesTest.sol"
    object "ComplexFeaturesTest_144_deployed" {
        code {
            {
                /// @src 0:177:1652  "contract ComplexFeaturesTest is Base {..."
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x0c3f6acf {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let value := and(sload(0), 0xff)
                        if iszero(lt(value, 3))
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x21)
                            revert(0, 0x24)
                        }
                        mstore(_1, value)
                        return(_1, 32)
                    }
                    case 0x2c6c3105 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let ret := fun_complexFlow(calldataload(4))
                        let memPos := mload(64)
                        mstore(memPos, ret)
                        return(memPos, 32)
                    }
                    case 0x31fdf166 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPos_1 := mload(64)
                        mstore(memPos_1, /** @src 0:925:928  "200" */ 0xc8)
                        /// @src 0:177:1652  "contract ComplexFeaturesTest is Base {..."
                        return(memPos_1, 32)
                    }
                    case 0x61bc221a {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _2 := sload(/** @src 0:436:458  "uint256 public counter" */ 1)
                        /// @src 0:177:1652  "contract ComplexFeaturesTest is Base {..."
                        let memPos_2 := mload(64)
                        mstore(memPos_2, _2)
                        return(memPos_2, 32)
                    }
                    case 0x9dcedf6e { external_fun_getImmutable() }
                    case 0xc50477a9 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value_1 := calldataload(4)
                        let sum := add(value_1, /** @src 0:1640:1642  "10" */ 0x0a)
                        /// @src 0:177:1652  "contract ComplexFeaturesTest is Base {..."
                        if gt(value_1, sum)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        let memPos_3 := mload(64)
                        mstore(memPos_3, sum)
                        return(memPos_3, 32)
                    }
                    case 0xf13a38a6 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPos_4 := mload(64)
                        mstore(memPos_4, /** @src 0:326:329  "123" */ 0x7b)
                        /// @src 0:177:1652  "contract ComplexFeaturesTest is Base {..."
                        return(memPos_4, 32)
                    }
                    case 0xfc989c77 { external_fun_getImmutable() }
                }
                revert(0, 0)
            }
            function external_fun_getImmutable()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                let memPos := mload(64)
                mstore(memPos, /** @src 0:680:693  "IMMUTABLE_VAL" */ loadimmutable("14"))
                /// @src 0:177:1652  "contract ComplexFeaturesTest is Base {..."
                return(memPos, 32)
            }
            /// @ast-id 116 @src 0:969:1397  "function complexFlow(uint256 x) public returns (uint256) {..."
            function fun_complexFlow(var_x) -> var
            {
                /// @src 0:1017:1024  "uint256"
                var := /** @src 0:177:1652  "contract ComplexFeaturesTest is Base {..." */ 0
                /// @src 0:1036:1391  "if (x < 10) {..."
                switch /** @src 0:1040:1046  "x < 10" */ lt(var_x, /** @src 0:1044:1046  "10" */ 0x0a)
                case /** @src 0:1036:1391  "if (x < 10) {..." */ 0 {
                    /// @src 0:1113:1391  "if (x < 20) {..."
                    switch /** @src 0:1117:1123  "x < 20" */ lt(var_x, /** @src 0:1121:1123  "20" */ 0x14)
                    case /** @src 0:1113:1391  "if (x < 20) {..." */ 0 {
                        /// @src 0:177:1652  "contract ComplexFeaturesTest is Base {..."
                        let value := and(sload(0), 0xff)
                        if iszero(lt(value, 3))
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x21)
                            revert(0, 0x24)
                        }
                        /// @src 0:1204:1359  "if (currentState == State.IDLE) {..."
                        switch /** @src 0:1208:1234  "currentState == State.IDLE" */ iszero(value)
                        case /** @src 0:1204:1359  "if (currentState == State.IDLE) {..." */ 0 {
                            /// @src 0:177:1652  "contract ComplexFeaturesTest is Base {..."
                            let slot := 0
                            slot := 0
                            sstore(0, or(and(sload(0), not(255)), /** @src 0:1333:1344  "State.ERROR" */ 2))
                        }
                        default /// @src 0:1204:1359  "if (currentState == State.IDLE) {..."
                        {
                            /// @src 0:177:1652  "contract ComplexFeaturesTest is Base {..."
                            let slot_1 := 0
                            slot_1 := 0
                            sstore(0, or(and(sload(0), not(255)), /** @src 0:1269:1279  "State.BUSY" */ 1))
                        }
                        /// @src 0:1372:1380  "return 3"
                        var := /** @src 0:177:1652  "contract ComplexFeaturesTest is Base {..." */ 3
                        /// @src 0:1372:1380  "return 3"
                        leave
                    }
                    default /// @src 0:1113:1391  "if (x < 20) {..."
                    {
                        /// @src 0:177:1652  "contract ComplexFeaturesTest is Base {..."
                        let _1 := sload(/** @src 0:1139:1151  "counter += 2" */ 0x01)
                        /// @src 0:177:1652  "contract ComplexFeaturesTest is Base {..."
                        let sum := add(_1, /** @src 0:1150:1151  "2" */ 0x02)
                        /// @src 0:177:1652  "contract ComplexFeaturesTest is Base {..."
                        if gt(_1, sum)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        sstore(/** @src 0:1139:1151  "counter += 2" */ 0x01, /** @src 0:177:1652  "contract ComplexFeaturesTest is Base {..." */ sum)
                        /// @src 0:1165:1173  "return 2"
                        var := /** @src 0:1150:1151  "2" */ 0x02
                        /// @src 0:1165:1173  "return 2"
                        leave
                    }
                }
                default /// @src 0:1036:1391  "if (x < 10) {..."
                {
                    /// @src 0:177:1652  "contract ComplexFeaturesTest is Base {..."
                    let _2 := sload(/** @src 0:1073:1074  "1" */ 0x01)
                    /// @src 0:177:1652  "contract ComplexFeaturesTest is Base {..."
                    let sum_1 := add(_2, /** @src 0:1073:1074  "1" */ 0x01)
                    /// @src 0:177:1652  "contract ComplexFeaturesTest is Base {..."
                    if gt(_2, sum_1)
                    {
                        mstore(0, shl(224, 0x4e487b71))
                        mstore(4, 0x11)
                        revert(0, 0x24)
                    }
                    sstore(/** @src 0:1073:1074  "1" */ 0x01, /** @src 0:177:1652  "contract ComplexFeaturesTest is Base {..." */ sum_1)
                    /// @src 0:1088:1096  "return 1"
                    var := /** @src 0:1073:1074  "1" */ 0x01
                    /// @src 0:1088:1096  "return 1"
                    leave
                }
            }
        }
        data ".metadata" hex"a26469706673582212201f155c0752f1ffb9e5c7b0036ef9717195564dbecc06a6cc369e269e8333bdb564736f6c634300081c0033"
    }
}