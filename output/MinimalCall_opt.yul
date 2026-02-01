object "MinimalCall_10" {
    code {
        {
            /// @src 0:58:159  "contract MinimalCall {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("MinimalCall_10_deployed")
            codecopy(_1, dataoffset("MinimalCall_10_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/MinimalCall.sol"
    object "MinimalCall_10_deployed" {
        code {
            {
                /// @src 0:58:159  "contract MinimalCall {..."
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                if iszero(lt(calldatasize(), 4))
                {
                    if eq(0x6d4ce63c, shr(224, calldataload(0)))
                    {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        mstore(_1, /** @src 0:149:150  "1" */ 0x01)
                        /// @src 0:58:159  "contract MinimalCall {..."
                        return(_1, 32)
                    }
                }
                revert(0, 0)
            }
        }
        data ".metadata" hex"a26469706673582212204f9ddf0220a0928562e532f7130686c0e737869f7390a73b90942dd92209eff164736f6c634300081c0033"
    }
}