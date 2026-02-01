object "NoSelector_7" {
    code {
        {
            /// @src 0:57:226  "contract NoSelector {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("NoSelector_7_deployed")
            codecopy(_1, dataoffset("NoSelector_7_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/NoSelector.sol"
    object "NoSelector_7_deployed" {
        code {
            {
                /// @src 0:146:218  "assembly {..."
                mstore(0, 15)
                return(0, 32)
            }
        }
        data ".metadata" hex"a26469706673582212202d967db85a381337fb95a366bb4f8a4712729b2650b856f0f26b09b2180688d564736f6c634300081c0033"
    }
}