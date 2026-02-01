object "StringUtils_179" {
    code {
        {
            /// @src 0:1153:1571  "library StringUtils {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("StringUtils_179_deployed")
            codecopy(_1, dataoffset("StringUtils_179_deployed"), _2)
            setimmutable(_1, "library_deploy_address", address())
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/bench/Libraries.sol"
    object "StringUtils_179_deployed" {
        code {
            {
                /// @src 0:1153:1571  "library StringUtils {..."
                revert(0, 0)
            }
        }
        data ".metadata" hex"a26469706673582212207d9930edb769ce2036ad573bc8e01546a4cbb4277b21d49292ddf91e54155de764736f6c634300081c0033"
    }
}