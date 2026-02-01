object "Base_46" {
    code {
        {
            /// @src 0:198:486  "contract Base {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("Base_46_deployed")
            codecopy(_1, dataoffset("Base_46_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/MegaTest.sol"
    object "Base_46_deployed" {
        code {
            {
                /// @src 0:198:486  "contract Base {..."
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x38e80f68 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value := calldataload(4)
                        sstore(0, value)
                        mstore(_1, value)
                        /// @src 0:365:378  "BaseLog(_val)"
                        log1(_1, /** @src 0:198:486  "contract Base {..." */ 32, /** @src 0:365:378  "BaseLog(_val)" */ 0x5bd6f351647a993b2105c3591351fe8c025806d42e284ff5056d411bf57a530b)
                        /// @src 0:198:486  "contract Base {..."
                        return(0, 0)
                    }
                    case 0x76f8c287 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _2 := sload(0)
                        let memPos := mload(64)
                        mstore(memPos, _2)
                        return(memPos, 32)
                    }
                    case 0xb9cdba71 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value_1 := calldataload(4)
                        let sum := add(value_1, 1)
                        if gt(value_1, sum)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        let memPos_1 := mload(64)
                        mstore(memPos_1, sum)
                        return(memPos_1, 32)
                    }
                }
                revert(0, 0)
            }
        }
        data ".metadata" hex"a2646970667358221220027608f01db7d8282b284005805c8049e06d65cc052185f7771dfd8bd555867464736f6c634300081c0033"
    }
}