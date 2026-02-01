object "AddressUtils_209" {
    code {
        {
            /// @src 0:1614:1947  "library AddressUtils {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("AddressUtils_209_deployed")
            codecopy(_1, dataoffset("AddressUtils_209_deployed"), _2)
            setimmutable(_1, "library_deploy_address", address())
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/bench/Libraries.sol"
    object "AddressUtils_209_deployed" {
        code {
            {
                /// @src 0:1614:1947  "library AddressUtils {..."
                revert(0, 0)
            }
        }
        data ".metadata" hex"a2646970667358221220a69980c16c085a0238441f724207ae3547cb906635420a767c01dc9e73a9438064736f6c634300081c0033"
    }
}