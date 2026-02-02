object "InitPayableTest_34" {
    code {
        {
            /// @src 0:194:538  "contract InitPayableTest {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            sstore(/** @src 0:293:319  "initialBalance = msg.value" */ 0x00, /** @src 0:310:319  "msg.value" */ callvalue())
            /// @src 0:194:538  "contract InitPayableTest {..."
            let _2 := datasize("InitPayableTest_34_deployed")
            codecopy(_1, dataoffset("InitPayableTest_34_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/init/InitPayableTest.sol"
    object "InitPayableTest_34_deployed" {
        code {
            {
                /// @src 0:194:538  "contract InitPayableTest {..."
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x0db146e6 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        mstore(_1, sload(0))
                        return(_1, 32)
                    }
                    case 0x12065fe0 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let ret := /** @src 0:508:529  "address(this).balance" */ selfbalance()
                        /// @src 0:194:538  "contract InitPayableTest {..."
                        let memPos := mload(64)
                        mstore(memPos, ret)
                        return(memPos, 32)
                    }
                    case 0x18369a2a {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _2 := sload(0)
                        let memPos_1 := mload(64)
                        mstore(memPos_1, _2)
                        return(memPos_1, 32)
                    }
                }
                revert(0, 0)
            }
        }
        data ".metadata" hex"a2646970667358221220e5e09ea54bb386c22f9b9b6906eedd6793f962915faf3db7e7fa0328890163e764736f6c634300081c0033"
    }
}