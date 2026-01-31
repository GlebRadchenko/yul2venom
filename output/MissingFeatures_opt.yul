object "MissingFeatures_139" {
    code {
        {
            /// @src 0:58:1258  "contract MissingFeatures {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("MissingFeatures_139_deployed")
            codecopy(_1, dataoffset("MissingFeatures_139_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"contracts/MissingFeatures.sol"
    object "MissingFeatures_139_deployed" {
        code {
            {
                /// @src 0:58:1258  "contract MissingFeatures {..."
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x0e5356ec {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        /// @src 0:271:280  "Log1(100)"
                        log2(/** @src 0:58:1258  "contract MissingFeatures {..." */ 0, 0, /** @src 0:271:280  "Log1(100)" */ 0x46692c0e59ca9cd1ad8f984a9d11715ec83424398b7eed4e05c8ce84662415a8, /** @src 0:276:279  "100" */ 0x64)
                        /// @src 0:295:309  "Log2(200, 300)"
                        log3(/** @src 0:58:1258  "contract MissingFeatures {..." */ 0, 0, /** @src 0:295:309  "Log2(200, 300)" */ 0x513dad7582fd8b11c8f4d05e6e7ac8caaa5eb690e9173dd2bed96b5ae0e0d024, /** @src 0:300:303  "200" */ 0xc8, /** @src 0:305:308  "300" */ 0x012c)
                        /// @src 0:58:1258  "contract MissingFeatures {..."
                        mstore(_1, 32)
                        mstore(add(_1, 32), 5)
                        mstore(add(_1, 64), "Hello")
                        /// @src 0:324:340  "LogData(\"Hello\")"
                        log1(_1, 96, 0x4609e0ccf047a9139d8e498ab3b5fe10aae422e66592ab6db3d4e8c87cf516ff)
                        /// @src 0:58:1258  "contract MissingFeatures {..."
                        return(0, 0)
                    }
                    case 0x3045db41 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let memPos := mload(64)
                        mstore(memPos, calldataload(4))
                        return(memPos, 32)
                    }
                    case 0x36c28556 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        if iszero(/** @src 0:1231:1237  "x < 10" */ lt(/** @src 0:58:1258  "contract MissingFeatures {..." */ calldataload(4), /** @src 0:1235:1237  "10" */ 0x0a))
                        /// @src 0:58:1258  "contract MissingFeatures {..."
                        {
                            let memPtr := mload(64)
                            mstore(memPtr, shl(229, 4594637))
                            mstore(add(memPtr, 4), 32)
                            mstore(add(memPtr, 36), 7)
                            mstore(add(memPtr, 68), "Too big")
                            revert(memPtr, 100)
                        }
                        return(0, 0)
                    }
                    case 0x38f14e0f {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        /// @src 0:583:622  "abi.encodePacked(uint256(1), uint16(2))"
                        let expr_mpos := /** @src 0:58:1258  "contract MissingFeatures {..." */ mload(64)
                        mstore(/** @src 0:583:622  "abi.encodePacked(uint256(1), uint16(2))" */ add(expr_mpos, 0x20), /** @src 0:608:609  "1" */ 0x01)
                        /// @src 0:58:1258  "contract MissingFeatures {..."
                        mstore(add(/** @src 0:583:622  "abi.encodePacked(uint256(1), uint16(2))" */ expr_mpos, /** @src 0:58:1258  "contract MissingFeatures {..." */ 64), shl(241, 1))
                        /// @src 0:583:622  "abi.encodePacked(uint256(1), uint16(2))"
                        mstore(expr_mpos, 34)
                        finalize_allocation(expr_mpos, 66)
                        /// @src 0:58:1258  "contract MissingFeatures {..."
                        let memPos_1 := mload(64)
                        return(memPos_1, sub(abi_encode_bytes(memPos_1, expr_mpos), memPos_1))
                    }
                    case 0x595c380e {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        /// @src 0:453:487  "abi.encode(uint256(1), uint256(2))"
                        let expr_mpos_1 := /** @src 0:58:1258  "contract MissingFeatures {..." */ mload(64)
                        mstore(/** @src 0:453:487  "abi.encode(uint256(1), uint256(2))" */ add(expr_mpos_1, 0x20), /** @src 0:472:473  "1" */ 0x01)
                        /// @src 0:58:1258  "contract MissingFeatures {..."
                        mstore(add(/** @src 0:453:487  "abi.encode(uint256(1), uint256(2))" */ expr_mpos_1, /** @src 0:58:1258  "contract MissingFeatures {..." */ 64), /** @src 0:484:485  "2" */ 0x02)
                        /// @src 0:453:487  "abi.encode(uint256(1), uint256(2))"
                        mstore(expr_mpos_1, /** @src 0:58:1258  "contract MissingFeatures {..." */ 64)
                        /// @src 0:453:487  "abi.encode(uint256(1), uint256(2))"
                        finalize_allocation(expr_mpos_1, 96)
                        /// @src 0:58:1258  "contract MissingFeatures {..."
                        let memPos_2 := mload(64)
                        return(memPos_2, sub(abi_encode_bytes(memPos_2, expr_mpos_1), memPos_2))
                    }
                    case 0xbee62ecb {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value := calldataload(4)
                        let _2 := iszero(iszero(value))
                        if iszero(eq(value, _2)) { revert(0, 0) }
                        if _2
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x01)
                            revert(0, 0x24)
                        }
                        return(0, 0)
                    }
                    case 0xdb59397b {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let ret := fun_tryCatchTest(calldataload(4))
                        let memPos_3 := mload(64)
                        mstore(memPos_3, iszero(iszero(ret)))
                        return(memPos_3, 32)
                    }
                    case 0xfb667036 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value_1 := calldataload(4)
                        let _3 := iszero(iszero(value_1))
                        if iszero(eq(value_1, _3)) { revert(0, 0) }
                        if _3
                        {
                            let memPtr_1 := mload(64)
                            mstore(memPtr_1, shl(229, 4594637))
                            mstore(add(memPtr_1, 4), 32)
                            mstore(add(memPtr_1, 36), 8)
                            mstore(add(memPtr_1, 68), "Required")
                            revert(memPtr_1, 100)
                        }
                        return(0, 0)
                    }
                }
                revert(0, 0)
            }
            function abi_encode_bytes(headStart, value0) -> tail
            {
                mstore(headStart, 32)
                let length := mload(value0)
                mstore(add(headStart, 32), length)
                mcopy(add(headStart, 64), add(value0, 32), length)
                mstore(add(add(headStart, length), 64), 0)
                tail := add(add(headStart, and(add(length, 31), not(31))), 64)
            }
            function finalize_allocation(memPtr, size)
            {
                let newFreePtr := add(memPtr, and(add(size, 31), not(31)))
                if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr))
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:58:1258  "contract MissingFeatures {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x41)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:58:1258  "contract MissingFeatures {..." */ 0x24)
                }
                mstore(64, newFreePtr)
            }
            /// @ast-id 125 @src 0:981:1162  "function tryCatchTest(uint256 x) public view returns (bool) {..."
            function fun_tryCatchTest(var_x) -> var
            {
                /// @src 0:1035:1039  "bool"
                let var_1 := /** @src 0:58:1258  "contract MissingFeatures {..." */ 0
                /// @src 0:1035:1039  "bool"
                var := /** @src 0:58:1258  "contract MissingFeatures {..." */ 0
                /// @src 0:1055:1075  "this.externalFail(x)"
                if iszero(extcodesize(/** @src 0:1055:1059  "this" */ address()))
                /// @src 0:1055:1075  "this.externalFail(x)"
                {
                    /// @src 0:58:1258  "contract MissingFeatures {..."
                    revert(0, 0)
                }
                /// @src 0:1055:1075  "this.externalFail(x)"
                let _1 := /** @src 0:58:1258  "contract MissingFeatures {..." */ mload(64)
                /// @src 0:1055:1075  "this.externalFail(x)"
                mstore(_1, /** @src 0:58:1258  "contract MissingFeatures {..." */ shl(225, 0x1b6142ab))
                mstore(/** @src 0:1055:1075  "this.externalFail(x)" */ add(_1, 4), /** @src 0:58:1258  "contract MissingFeatures {..." */ var_x)
                /// @src 0:1055:1075  "this.externalFail(x)"
                let trySuccessCondition := staticcall(gas(), /** @src 0:1055:1059  "this" */ address(), /** @src 0:1055:1075  "this.externalFail(x)" */ _1, 36, _1, /** @src 0:58:1258  "contract MissingFeatures {..." */ 0)
                /// @src 0:1055:1075  "this.externalFail(x)"
                if trySuccessCondition
                {
                    finalize_allocation(_1, /** @src 0:58:1258  "contract MissingFeatures {..." */ 0)
                    var_1 := 0
                }
                /// @src 0:1051:1156  "try this.externalFail(x) {..."
                switch iszero(trySuccessCondition)
                case 0 {
                    /// @src 0:1090:1101  "return true"
                    var := /** @src 0:1097:1101  "true" */ 0x01
                    /// @src 0:1090:1101  "return true"
                    leave
                }
                default /// @src 0:1051:1156  "try this.externalFail(x) {..."
                {
                    /// @src 0:1133:1145  "return false"
                    var := /** @src 0:58:1258  "contract MissingFeatures {..." */ var_1
                    /// @src 0:1133:1145  "return false"
                    leave
                }
            }
        }
        data ".metadata" hex"a2646970667358221220dbba6a011dc278b76dca3f2a842b074803979dac2d5f96c07d39daf355c6f3ba64736f6c634300081c0033"
    }
}