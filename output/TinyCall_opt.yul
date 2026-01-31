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
    /// @use-src 0:"contracts/TinyCall.sol"
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
        data ".metadata" hex"a26469706673582212205ad428c7b7f9fd9600c417a65b9b1a164f59d994d6136fbd54af754bdc6c5b6464736f6c634300081c0033"
    }
}