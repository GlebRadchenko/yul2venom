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
    /// @use-src 0:"contracts/VoidCall.sol"
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
        data ".metadata" hex"a26469706673582212208685f8f09847b87059f8ad2c6aef7ef9ac3d47ac4922af6769f897104d8ea5fb64736f6c634300081c0033"
    }
}