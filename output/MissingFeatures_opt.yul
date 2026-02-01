object "MissingFeatures_141" {
    code {
        {
            /// @src 0:58:1460  "contract MissingFeatures {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("MissingFeatures_141_deployed")
            codecopy(_1, dataoffset("MissingFeatures_141_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/MissingFeatures.sol"
    object "MissingFeatures_141_deployed" {
        code {
            {
                /// @src 0:58:1460  "contract MissingFeatures {..."
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x0e5356ec {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        /// @src 0:271:280  "Log1(100)"
                        log2(/** @src 0:58:1460  "contract MissingFeatures {..." */ 0, 0, /** @src 0:271:280  "Log1(100)" */ 0x46692c0e59ca9cd1ad8f984a9d11715ec83424398b7eed4e05c8ce84662415a8, /** @src 0:276:279  "100" */ 0x64)
                        /// @src 0:295:309  "Log2(200, 300)"
                        log3(/** @src 0:58:1460  "contract MissingFeatures {..." */ 0, 0, /** @src 0:295:309  "Log2(200, 300)" */ 0x513dad7582fd8b11c8f4d05e6e7ac8caaa5eb690e9173dd2bed96b5ae0e0d024, /** @src 0:300:303  "200" */ 0xc8, /** @src 0:305:308  "300" */ 0x012c)
                        /// @src 0:58:1460  "contract MissingFeatures {..."
                        mstore(_1, 32)
                        mstore(add(_1, 32), 5)
                        mstore(add(_1, 64), "Hello")
                        /// @src 0:324:340  "LogData(\"Hello\")"
                        log1(_1, 96, 0x4609e0ccf047a9139d8e498ab3b5fe10aae422e66592ab6db3d4e8c87cf516ff)
                        /// @src 0:58:1460  "contract MissingFeatures {..."
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
                        if iszero(/** @src 0:1433:1439  "x < 10" */ lt(/** @src 0:58:1460  "contract MissingFeatures {..." */ calldataload(4), /** @src 0:1437:1439  "10" */ 0x0a))
                        /// @src 0:58:1460  "contract MissingFeatures {..."
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
                        let expr_mpos := /** @src 0:58:1460  "contract MissingFeatures {..." */ mload(64)
                        mstore(/** @src 0:583:622  "abi.encodePacked(uint256(1), uint16(2))" */ add(expr_mpos, 0x20), /** @src 0:608:609  "1" */ 0x01)
                        /// @src 0:58:1460  "contract MissingFeatures {..."
                        mstore(add(/** @src 0:583:622  "abi.encodePacked(uint256(1), uint16(2))" */ expr_mpos, /** @src 0:58:1460  "contract MissingFeatures {..." */ 64), shl(241, 1))
                        /// @src 0:583:622  "abi.encodePacked(uint256(1), uint16(2))"
                        mstore(expr_mpos, 34)
                        finalize_allocation(expr_mpos, 66)
                        /// @src 0:58:1460  "contract MissingFeatures {..."
                        let memPos_1 := mload(64)
                        return(memPos_1, sub(abi_encode_bytes(memPos_1, expr_mpos), memPos_1))
                    }
                    case 0x595c380e {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        /// @src 0:453:487  "abi.encode(uint256(1), uint256(2))"
                        let expr_mpos_1 := /** @src 0:58:1460  "contract MissingFeatures {..." */ mload(64)
                        mstore(/** @src 0:453:487  "abi.encode(uint256(1), uint256(2))" */ add(expr_mpos_1, 0x20), /** @src 0:472:473  "1" */ 0x01)
                        /// @src 0:58:1460  "contract MissingFeatures {..."
                        mstore(add(/** @src 0:453:487  "abi.encode(uint256(1), uint256(2))" */ expr_mpos_1, /** @src 0:58:1460  "contract MissingFeatures {..." */ 64), /** @src 0:484:485  "2" */ 0x02)
                        /// @src 0:453:487  "abi.encode(uint256(1), uint256(2))"
                        mstore(expr_mpos_1, /** @src 0:58:1460  "contract MissingFeatures {..." */ 64)
                        /// @src 0:453:487  "abi.encode(uint256(1), uint256(2))"
                        finalize_allocation(expr_mpos_1, 96)
                        /// @src 0:58:1460  "contract MissingFeatures {..."
                        let memPos_2 := mload(64)
                        return(memPos_2, sub(abi_encode_bytes(memPos_2, expr_mpos_1), memPos_2))
                    }
                    case 0xbee62ecb {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value := calldataload(4)
                        let _2 := iszero(iszero(value))
                        if iszero(eq(value, _2)) { revert(0, 0) }
                        let memPos_3 := mload(64)
                        mstore(memPos_3, _2)
                        return(memPos_3, 32)
                    }
                    case 0xdb59397b {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let ret := fun_tryCatchTest(calldataload(4))
                        let memPos_4 := mload(64)
                        mstore(memPos_4, iszero(iszero(ret)))
                        return(memPos_4, 32)
                    }
                    case 0xfb667036 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value_1 := calldataload(4)
                        if iszero(eq(value_1, iszero(iszero(value_1)))) { revert(0, 0) }
                        let ret_1 := fun_testRequire(value_1)
                        let memPos_5 := mload(64)
                        mstore(memPos_5, iszero(iszero(ret_1)))
                        return(memPos_5, 32)
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
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:58:1460  "contract MissingFeatures {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x41)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:58:1460  "contract MissingFeatures {..." */ 0x24)
                }
                mstore(64, newFreePtr)
            }
            /// @ast-id 127 @src 0:1183:1364  "function tryCatchTest(uint256 x) public view returns (bool) {..."
            function fun_tryCatchTest(var_x) -> var
            {
                /// @src 0:1237:1241  "bool"
                let var_1 := /** @src 0:58:1460  "contract MissingFeatures {..." */ 0
                /// @src 0:1237:1241  "bool"
                var := /** @src 0:58:1460  "contract MissingFeatures {..." */ 0
                /// @src 0:1257:1277  "this.externalFail(x)"
                if iszero(extcodesize(/** @src 0:1257:1261  "this" */ address()))
                /// @src 0:1257:1277  "this.externalFail(x)"
                {
                    /// @src 0:58:1460  "contract MissingFeatures {..."
                    revert(0, 0)
                }
                /// @src 0:1257:1277  "this.externalFail(x)"
                let _1 := /** @src 0:58:1460  "contract MissingFeatures {..." */ mload(64)
                /// @src 0:1257:1277  "this.externalFail(x)"
                mstore(_1, /** @src 0:58:1460  "contract MissingFeatures {..." */ shl(225, 0x1b6142ab))
                mstore(/** @src 0:1257:1277  "this.externalFail(x)" */ add(_1, 4), /** @src 0:58:1460  "contract MissingFeatures {..." */ var_x)
                /// @src 0:1257:1277  "this.externalFail(x)"
                let trySuccessCondition := staticcall(gas(), /** @src 0:1257:1261  "this" */ address(), /** @src 0:1257:1277  "this.externalFail(x)" */ _1, 36, _1, /** @src 0:58:1460  "contract MissingFeatures {..." */ 0)
                /// @src 0:1257:1277  "this.externalFail(x)"
                if trySuccessCondition
                {
                    finalize_allocation(_1, /** @src 0:58:1460  "contract MissingFeatures {..." */ 0)
                    var_1 := 0
                }
                /// @src 0:1253:1358  "try this.externalFail(x) {..."
                switch iszero(trySuccessCondition)
                case 0 {
                    /// @src 0:1292:1303  "return true"
                    var := /** @src 0:1299:1303  "true" */ 0x01
                    /// @src 0:1292:1303  "return true"
                    leave
                }
                default /// @src 0:1253:1358  "try this.externalFail(x) {..."
                {
                    /// @src 0:1335:1347  "return false"
                    var := /** @src 0:58:1460  "contract MissingFeatures {..." */ var_1
                    /// @src 0:1335:1347  "return false"
                    leave
                }
            }
            /// @ast-id 83 @src 0:711:843  "function testRequire(bool shouldPass) public pure returns (bool) {..."
            function fun_testRequire(var_shouldPass) -> var
            {
                /// @src 0:770:774  "bool"
                var := /** @src 0:58:1460  "contract MissingFeatures {..." */ 0
                /// @src 0:786:815  "if (!shouldPass) return false"
                if /** @src 0:790:801  "!shouldPass" */ iszero(var_shouldPass)
                /// @src 0:786:815  "if (!shouldPass) return false"
                {
                    /// @src 0:803:815  "return false"
                    var := /** @src 0:58:1460  "contract MissingFeatures {..." */ 0
                    /// @src 0:803:815  "return false"
                    leave
                }
                /// @src 0:825:836  "return true"
                var := /** @src 0:832:836  "true" */ 0x01
            }
        }
        data ".metadata" hex"a26469706673582212207154604b945d97dd9b0cdb4824b1de079cd7b1a0ff0d3e6db9e282bc71cd1f1b64736f6c634300081c0033"
    }
}