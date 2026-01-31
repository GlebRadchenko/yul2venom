object "Middle_86" {
    code {
        {
            /// @src 0:488:793  "contract Middle is Base {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("Middle_86_deployed")
            codecopy(_1, dataoffset("Middle_86_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"contracts/MegaTest.sol"
    object "Middle_86_deployed" {
        code {
            {
                /// @src 0:488:793  "contract Middle is Base {..."
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x38e80f68 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value := calldataload(4)
                        let product := shl(1, value)
                        if iszero(or(iszero(value), eq(/** @src 0:635:636  "2" */ 0x02, /** @src 0:488:793  "contract Middle is Base {..." */ div(product, value))))
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        sstore(0, product)
                        mstore(_1, product)
                        /// @src 0:365:378  "BaseLog(_val)"
                        log1(_1, /** @src 0:488:793  "contract Middle is Base {..." */ 32, /** @src 0:365:378  "BaseLog(_val)" */ 0x5bd6f351647a993b2105c3591351fe8c025806d42e284ff5056d411bf57a530b)
                        /// @src 0:488:793  "contract Middle is Base {..."
                        sstore(1, value)
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
                        let product_1 := shl(1, sum)
                        if iszero(or(iszero(sum), eq(/** @src 0:783:784  "2" */ 0x02, /** @src 0:488:793  "contract Middle is Base {..." */ div(product_1, sum))))
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        let memPos_1 := mload(64)
                        mstore(memPos_1, product_1)
                        return(memPos_1, 32)
                    }
                    case 0xc4250732 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _3 := sload(/** @src 0:518:542  "uint256 public middleVal" */ 1)
                        /// @src 0:488:793  "contract Middle is Base {..."
                        let memPos_2 := mload(64)
                        mstore(memPos_2, _3)
                        return(memPos_2, 32)
                    }
                }
                revert(0, 0)
            }
        }
        data ".metadata" hex"a2646970667358221220bf79fcf250cd731db40de2c426a71fc8e27b3f281c8177dee35a42e1f8e9562864736f6c634300081c0033"
    }
}