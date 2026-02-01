object "SafeMath_124" {
    code {
        {
            /// @src 0:218:1111  "library SafeMath {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("SafeMath_124_deployed")
            codecopy(_1, dataoffset("SafeMath_124_deployed"), _2)
            setimmutable(_1, "library_deploy_address", address())
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/bench/Libraries.sol"
    object "SafeMath_124_deployed" {
        code {
            {
                /// @src 0:218:1111  "library SafeMath {..."
                revert(0, 0)
            }
        }
        data ".metadata" hex"a26469706673582212206fbdf8e783043dcc863002410c2cd3f867f34ed84e0eebcc40c6afa1ef4ab40864736f6c634300081c0033"
    }
}