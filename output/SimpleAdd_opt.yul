object "SimpleAdd_16" {
    code {
        {
            /// @src 0:57:180  "contract SimpleAdd {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("SimpleAdd_16_deployed")
            codecopy(_1, dataoffset("SimpleAdd_16_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"contracts/SimpleAdd.sol"
    object "SimpleAdd_16_deployed" {
        code {
            {
                /// @src 0:57:180  "contract SimpleAdd {..."
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                if iszero(lt(calldatasize(), 4))
                {
                    if eq(0x771602f7, shr(224, calldataload(0)))
                    {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        let value := calldataload(4)
                        let sum := add(value, calldataload(36))
                        if gt(value, sum)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 36)
                        }
                        mstore(_1, sum)
                        return(_1, 32)
                    }
                }
                revert(0, 0)
            }
        }
        data ".metadata" hex"a2646970667358221220fc1347c0e825cf500f98a07f5681f96d77adcda9e263912e3fd09df706220a4e64736f6c634300081c0033"
    }
}