object "InitCodeTest_31" {
    code {
        {
            /// @src 0:228:497  "contract InitCodeTest {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            sstore(/** @src 0:307:317  "value = 42" */ 0x00, /** @src 0:315:317  "42" */ 0x2a)
            /// @src 0:228:497  "contract InitCodeTest {..."
            let _2 := datasize("InitCodeTest_31_deployed")
            codecopy(_1, dataoffset("InitCodeTest_31_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/init/InitCodeTest.sol"
    object "InitCodeTest_31_deployed" {
        code {
            {
                /// @src 0:228:497  "contract InitCodeTest {..."
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x20965255 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        mstore(_1, sload(0))
                        return(_1, 32)
                    }
                    case 0x3fa4f245 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _2 := sload(0)
                        let memPos := mload(64)
                        mstore(memPos, _2)
                        return(memPos, 32)
                    }
                    case 0x55241077 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        sstore(0, calldataload(4))
                        return(0, 0)
                    }
                }
                revert(0, 0)
            }
        }
        data ".metadata" hex"a2646970667358221220e47519cf0a8b496fe7f29c953235047b90f00459786383650c3a7ccdb870138a64736f6c634300081c0033"
    }
}