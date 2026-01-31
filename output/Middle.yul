object "Middle_57" {
    code {
        {
            /// @src 0:560:844  "contract Middle is BaseA, BaseB {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("Middle_57_deployed")
            codecopy(_1, dataoffset("Middle_57_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/bench/Functions.sol"
    object "Middle_57_deployed" {
        code {
            {
                /// @src 0:560:844  "contract Middle is BaseA, BaseB {..."
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x2e19789e {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        mstore(_1, 110)
                        return(_1, 32)
                    }
                    case 0xa6cc75bd {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPos := mload(64)
                        mstore(memPos, 220)
                        return(memPos, 32)
                    }
                }
                revert(0, 0)
            }
        }
        data ".metadata" hex"a26469706673582212206fe08f6b9714dfc4ae6d0c401b3e9983eb8b5d01f67895a15940e9d276d74d5164736f6c634300081c0033"
    }
}