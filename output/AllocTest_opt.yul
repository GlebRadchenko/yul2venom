object "AllocTest_10" {
    code {
        {
            /// @src 0:57:204  "contract AllocTest {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("AllocTest_10_deployed")
            codecopy(_1, dataoffset("AllocTest_10_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"contracts/AllocTest.sol"
    object "AllocTest_10_deployed" {
        code {
            {
                /// @src 0:57:204  "contract AllocTest {..."
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                if iszero(lt(calldatasize(), 4))
                {
                    if eq(0x6d4ce63c, shr(224, calldataload(0)))
                    {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        mstore(_1, /** @src 0:144:147  "128" */ 0x80)
                        /// @src 0:57:204  "contract AllocTest {..."
                        return(_1, 32)
                    }
                }
                revert(0, 0)
            }
        }
        data ".metadata" hex"a2646970667358221220864ae98bc3e435e63220cb2b715ed5f464f0d229f0552c42258f9430c72a147064736f6c634300081c0033"
    }
}