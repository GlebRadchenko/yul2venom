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
    /// @use-src 0:"contracts/NoSelector.sol"
    object "NoSelector_7_deployed" {
        code {
            {
                /// @src 0:146:218  "assembly {..."
                mstore(0, 15)
                return(0, 32)
            }
        }
        data ".metadata" hex"a2646970667358221220a4bc5d2d51b3822897692555445f18d228bcf776cc0edd2417c63e7cd5eb029a64736f6c634300081c0033"
    }
}