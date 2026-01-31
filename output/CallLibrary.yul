object "CallLibrary_91" {
    code {
        {
            /// @src 0:891:1187  "contract CallLibrary {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("CallLibrary_91_deployed")
            codecopy(_1, dataoffset("CallLibrary_91_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/bench/Functions.sol"
    object "CallLibrary_91_deployed" {
        code {
            {
                /// @src 0:891:1187  "contract CallLibrary {..."
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x6d619daa {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        mstore(_1, sload(0))
                        return(_1, 32)
                    }
                    case 0xa81e8f80 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value := calldataload(4)
                        let product := shl(1, value)
                        if iszero(or(iszero(value), eq(/** @src 0:1043:1044  "2" */ 0x02, /** @src 0:891:1187  "contract CallLibrary {..." */ div(product, value))))
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        sstore(0, product)
                        let memPos := mload(64)
                        mstore(memPos, product)
                        return(memPos, 32)
                    }
                    case 0xaea3f28c {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        let value_1 := calldataload(4)
                        let sum := add(value_1, calldataload(36))
                        if gt(value_1, sum)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 36)
                        }
                        let memPos_1 := mload(64)
                        mstore(memPos_1, sum)
                        return(memPos_1, 32)
                    }
                }
                revert(0, 0)
            }
        }
        data ".metadata" hex"a264697066735822122067ef2a9f2bafeb8f93cc9b38f27ce899634d95f0d0d0c28c8c61f42e8be5d2fd64736f6c634300081c0033"
    }
}