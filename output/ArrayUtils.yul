object "ArrayUtils_370" {
    code {
        {
            /// @src 0:1988:3039  "library ArrayUtils {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("ArrayUtils_370_deployed")
            codecopy(_1, dataoffset("ArrayUtils_370_deployed"), _2)
            setimmutable(_1, "library_deploy_address", address())
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/bench/Libraries.sol"
    object "ArrayUtils_370_deployed" {
        code {
            {
                /// @src 0:1988:3039  "library ArrayUtils {..."
                revert(0, 0)
            }
        }
        data ".metadata" hex"a264697066735822122098e2ced5adb000b3e7cc668b5577c238541bc316b9b7b458e1d1a0409950f00e64736f6c634300081c0033"
    }
}