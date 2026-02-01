object "ConstantTest_33" {
    code {
        {
            /// @src 0:58:430  "contract ConstantTest {..."
            let _1 := memoryguard(0xa0)
            if callvalue() { revert(0, 0) }
            let programSize := datasize("ConstantTest_33")
            let argSize := sub(codesize(), programSize)
            let newFreePtr := add(_1, and(add(argSize, 31), not(31)))
            if or(gt(newFreePtr, sub(shl(64, 1), 1)), lt(newFreePtr, _1))
            {
                mstore(/** @src -1:-1:-1 */ 0, /** @src 0:58:430  "contract ConstantTest {..." */ shl(224, 0x4e487b71))
                mstore(4, 0x41)
                revert(/** @src -1:-1:-1 */ 0, /** @src 0:58:430  "contract ConstantTest {..." */ 0x24)
            }
            mstore(64, newFreePtr)
            codecopy(_1, programSize, argSize)
            if slt(sub(add(_1, argSize), _1), 32)
            {
                revert(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 0:210:229  "IMMUTABLE_VAL = val"
            mstore(128, /** @src 0:58:430  "contract ConstantTest {..." */ mload(_1))
            let _2 := mload(64)
            let _3 := datasize("ConstantTest_33_deployed")
            codecopy(_2, dataoffset("ConstantTest_33_deployed"), _3)
            setimmutable(_2, "6", mload(/** @src 0:210:229  "IMMUTABLE_VAL = val" */ 128))
            /// @src 0:58:430  "contract ConstantTest {..."
            return(_2, _3)
        }
    }
    /// @use-src 0:"foundry/src/ConstantTest.sol"
    object "ConstantTest_33_deployed" {
        code {
            {
                /// @src 0:58:430  "contract ConstantTest {..."
                mstore(64, memoryguard(0x80))
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x9dcedf6e { external_fun_getImmutable() }
                    case 0xdfe8bfa1 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPos := mload(64)
                        mstore(memPos, /** @src 0:121:124  "123" */ 0x7b)
                        /// @src 0:58:430  "contract ConstantTest {..."
                        return(memPos, 32)
                    }
                    case 0xf13a38a6 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPos_1 := mload(64)
                        mstore(memPos_1, /** @src 0:121:124  "123" */ 0x7b)
                        /// @src 0:58:430  "contract ConstantTest {..."
                        return(memPos_1, 32)
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
                mstore(memPos, /** @src 0:408:421  "IMMUTABLE_VAL" */ loadimmutable("6"))
                /// @src 0:58:430  "contract ConstantTest {..."
                return(memPos, 32)
            }
        }
        data ".metadata" hex"a2646970667358221220a60da7f3e00defc302488bb27aaecd74741cbacabd5c7936a196ba0ab327cbca64736f6c634300081c0033"
    }
}