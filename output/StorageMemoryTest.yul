object "StorageMemoryTest_86" {
    code {
        {
            /// @src 0:57:751  "contract StorageMemoryTest {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("StorageMemoryTest_86_deployed")
            codecopy(_1, dataoffset("StorageMemoryTest_86_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"contracts/StorageMemoryTest.sol"
    object "StorageMemoryTest_86_deployed" {
        code {
            {
                /// @src 0:57:751  "contract StorageMemoryTest {..."
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x27e235e3 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        mstore(0, and(abi_decode_address(), sub(shl(160, 1), 1)))
                        mstore(32, /** @src 0:114:157  "mapping(address => uint256) public balances" */ 1)
                        /// @src 0:57:751  "contract StorageMemoryTest {..."
                        mstore(_1, sload(keccak256(0, 64)))
                        return(_1, 32)
                    }
                    case 0x3c6bb436 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _2 := sload(0)
                        let memPos := mload(64)
                        mstore(memPos, _2)
                        return(memPos, 32)
                    }
                    case 0x3d4197f0 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        sstore(0, calldataload(4))
                        return(0, 0)
                    }
                    case 0x9f4a8995 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let offset := calldataload(4)
                        if gt(offset, 0xffffffffffffffff) { revert(0, 0) }
                        if iszero(slt(add(offset, 35), calldatasize())) { revert(0, 0) }
                        let length := calldataload(add(4, offset))
                        if gt(length, 0xffffffffffffffff)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x41)
                            revert(0, 36)
                        }
                        let _3 := shl(5, length)
                        let memPtr := mload(64)
                        let newFreePtr := add(memPtr, and(add(_3, 63), not(31)))
                        if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr))
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x41)
                            revert(0, 36)
                        }
                        mstore(64, newFreePtr)
                        let dst := memPtr
                        mstore(memPtr, length)
                        dst := add(memPtr, 32)
                        let srcEnd := add(add(offset, _3), 36)
                        if gt(srcEnd, calldatasize()) { revert(0, 0) }
                        let src := add(offset, 36)
                        for { } lt(src, srcEnd) { src := add(src, 32) }
                        {
                            mstore(dst, calldataload(src))
                            dst := add(dst, 32)
                        }
                        /// @src 0:620:635  "uint256 sum = 0"
                        let var_sum := /** @src 0:57:751  "contract StorageMemoryTest {..." */ 0
                        /// @src 0:649:662  "uint256 i = 0"
                        let var_i := /** @src 0:57:751  "contract StorageMemoryTest {..." */ 0
                        /// @src 0:645:723  "for(uint256 i = 0; i < arr.length; i++) {..."
                        for { }
                        /** @src 0:57:751  "contract StorageMemoryTest {..." */ 1
                        /// @src 0:649:662  "uint256 i = 0"
                        {
                            /// @src 0:680:683  "i++"
                            var_i := /** @src 0:57:751  "contract StorageMemoryTest {..." */ add(/** @src 0:680:683  "i++" */ var_i, /** @src 0:57:751  "contract StorageMemoryTest {..." */ 1)
                        }
                        /// @src 0:680:683  "i++"
                        {
                            /// @src 0:664:678  "i < arr.length"
                            let _4 := iszero(lt(var_i, /** @src 0:57:751  "contract StorageMemoryTest {..." */ mload(/** @src 0:668:678  "arr.length" */ memPtr)))
                            /// @src 0:664:678  "i < arr.length"
                            if _4 { break }
                            /// @src 0:57:751  "contract StorageMemoryTest {..."
                            _4 := 0
                            let sum := add(var_sum, mload(add(add(memPtr, shl(5, var_i)), 32)))
                            if gt(var_sum, sum)
                            {
                                mstore(0, shl(224, 0x4e487b71))
                                mstore(4, 0x11)
                                revert(0, 36)
                            }
                            /// @src 0:699:712  "sum += arr[i]"
                            var_sum := sum
                        }
                        /// @src 0:57:751  "contract StorageMemoryTest {..."
                        let memPos_1 := mload(64)
                        mstore(memPos_1, var_sum)
                        return(memPos_1, 32)
                    }
                    case 0xe1cb0e52 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _5 := sload(0)
                        let memPos_2 := mload(64)
                        mstore(memPos_2, _5)
                        return(memPos_2, 32)
                    }
                    case 0xe30443bc {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        mstore(0, and(abi_decode_address(), sub(shl(160, 1), 1)))
                        mstore(32, 1)
                        sstore(keccak256(0, 64), calldataload(36))
                        return(0, 0)
                    }
                    case 0xf8b2cb4f {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        mstore(0, and(abi_decode_address(), sub(shl(160, 1), 1)))
                        mstore(32, /** @src 0:507:515  "balances" */ 0x01)
                        /// @src 0:57:751  "contract StorageMemoryTest {..."
                        let _6 := sload(keccak256(0, 64))
                        let memPos_3 := mload(64)
                        mstore(memPos_3, _6)
                        return(memPos_3, 32)
                    }
                }
                revert(0, 0)
            }
            function abi_decode_address() -> value
            {
                value := calldataload(4)
                if iszero(eq(value, and(value, sub(shl(160, 1), 1)))) { revert(0, 0) }
            }
        }
        data ".metadata" hex"a2646970667358221220bef212af28d62073b74b4b7d0d150571f400c949060b3c72dd242ad9ad946af764736f6c634300081c0033"
    }
}