object "VoidCall_13" {
    code {
        {
            /// @src 0:123:313  "contract VoidCall {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("VoidCall_13_deployed")
            codecopy(_1, dataoffset("VoidCall_13_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/VoidCall.sol"
    object "VoidCall_13_deployed" {
        code {
            {
                /// @src 0:123:313  "contract VoidCall {..."
                if iszero(lt(calldatasize(), 4))
                {
                    if eq(0x7fec8d38, shr(224, calldataload(0)))
                    {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        return(0, 0)
                    }
                }
                revert(0, 0)
            }
        }
        data ".metadata" hex"a264697066735822122029cd3a0f3c05a4b71583933fcc41cef6872b653bbf30b7ac66ddbd95f7d94d4964736f6c634300081c0033"
    }
}