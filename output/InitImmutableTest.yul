object "InitImmutableTest_63" {
    code {
        {
            /// @src 0:200:932  "contract InitImmutableTest {..."
            let _1 := memoryguard(0xc0)
            if callvalue() { revert(0, 0) }
            let programSize := datasize("InitImmutableTest_63")
            let argSize := sub(codesize(), programSize)
            let newFreePtr := add(_1, and(add(argSize, 31), not(31)))
            if or(gt(newFreePtr, sub(shl(64, 1), 1)), lt(newFreePtr, _1))
            {
                mstore(/** @src -1:-1:-1 */ 0, /** @src 0:200:932  "contract InitImmutableTest {..." */ shl(224, 0x4e487b71))
                mstore(4, 0x41)
                revert(/** @src -1:-1:-1 */ 0, /** @src 0:200:932  "contract InitImmutableTest {..." */ 0x24)
            }
            mstore(64, newFreePtr)
            codecopy(_1, programSize, argSize)
            if slt(sub(add(_1, argSize), _1), 64)
            {
                revert(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 0:200:932  "contract InitImmutableTest {..."
            let value := mload(_1)
            let value_1 := mload(add(_1, 32))
            if iszero(eq(value_1, and(value_1, sub(shl(160, 1), 1))))
            {
                revert(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 0:430:461  "IMMUTABLE_VALUE = _immutableVal"
            mstore(128, value)
            /// @src 0:471:504  "IMMUTABLE_OWNER = _immutableOwner"
            mstore(160, value_1)
            /// @src 0:200:932  "contract InitImmutableTest {..."
            sstore(/** @src -1:-1:-1 */ 0, /** @src 0:529:532  "100" */ 0x64)
            /// @src 0:200:932  "contract InitImmutableTest {..."
            let _2 := mload(64)
            let _3 := datasize("InitImmutableTest_63_deployed")
            codecopy(_2, dataoffset("InitImmutableTest_63_deployed"), _3)
            setimmutable(_2, "4", mload(/** @src 0:430:461  "IMMUTABLE_VALUE = _immutableVal" */ 128))
            /// @src 0:200:932  "contract InitImmutableTest {..."
            setimmutable(_2, "6", mload(/** @src 0:471:504  "IMMUTABLE_OWNER = _immutableOwner" */ 160))
            /// @src 0:200:932  "contract InitImmutableTest {..."
            return(_2, _3)
        }
    }
    /// @use-src 0:"foundry/src/init/InitImmutableTest.sol"
    object "InitImmutableTest_63_deployed" {
        code {
            {
                /// @src 0:200:932  "contract InitImmutableTest {..."
                mstore(64, memoryguard(0x80))
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x0e8ac330 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        sstore(0, calldataload(4))
                        return(0, 0)
                    }
                    case 0x304e1cb2 {
                        external_fun_getImmutableValue()
                    }
                    case 0x8ab3d5ba {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _1 := sload(0)
                        let memPos := mload(64)
                        mstore(memPos, _1)
                        return(memPos, 32)
                    }
                    case 0x8d164303 {
                        external_fun_getImmutableValue()
                    }
                    case 0xa5f89150 {
                        external_fun_getImmutableOwner()
                    }
                    case 0xacdaa2b1 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _2 := sload(0)
                        let memPos_1 := mload(64)
                        mstore(memPos_1, _2)
                        return(memPos_1, 32)
                    }
                    case 0xf3d1372f {
                        external_fun_getImmutableOwner()
                    }
                }
                revert(0, 0)
            }
            function external_fun_getImmutableValue()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                let memPos := mload(64)
                mstore(memPos, /** @src 0:623:638  "IMMUTABLE_VALUE" */ loadimmutable("4"))
                /// @src 0:200:932  "contract InitImmutableTest {..."
                return(memPos, 32)
            }
            function external_fun_getImmutableOwner()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                let memPos := mload(64)
                mstore(memPos, and(/** @src 0:729:744  "IMMUTABLE_OWNER" */ loadimmutable("6"), /** @src 0:200:932  "contract InitImmutableTest {..." */ sub(shl(160, 1), 1)))
                return(memPos, 32)
            }
        }
        data ".metadata" hex"a264697066735822122046f3c9fb0d625c8e65e0712a35ec99aa0b092ec5843937a8adcd6503b5a9e55d64736f6c634300081c0033"
    }
}