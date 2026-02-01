object "TinyCall_10" {
    code {
        {
            /// @src 0:57:161  "contract TinyCall {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("TinyCall_10_deployed")
            codecopy(_1, dataoffset("TinyCall_10_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/TinyCall.sol"
    object "TinyCall_10_deployed" {
        code {
            {
                /// @src 0:57:161  "contract TinyCall {..."
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                if iszero(lt(calldatasize(), 4))
                {
                    if eq(0xb0bea725, shr(224, calldataload(0)))
                    {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        mstore(_1, /** @src 0:148:152  "0x42" */ 0x42)
                        /// @src 0:57:161  "contract TinyCall {..."
                        return(_1, 32)
                    }
                }
                revert(0, 0)
            }
        }
        data ".metadata" hex"a26469706673582212202dc4f0cac89e86979bd765da8ddbe9bec5579fc8ac5f4766fcc60759979a170064736f6c634300081c0033"
    }
}