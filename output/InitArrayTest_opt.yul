object "InitArrayTest_64" {
    code {
        {
            /// @src 0:212:748  "contract InitArrayTest {..."
            mstore(64, memoryguard(0x80))
            if callvalue() { revert(0, 0) }
            let programSize := datasize("InitArrayTest_64")
            let argSize := sub(codesize(), programSize)
            let memoryDataOffset := allocate_memory(argSize)
            codecopy(memoryDataOffset, programSize, argSize)
            let _1 := add(memoryDataOffset, argSize)
            if slt(sub(_1, memoryDataOffset), 32)
            {
                revert(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 0:212:748  "contract InitArrayTest {..."
            let offset := mload(memoryDataOffset)
            if gt(offset, sub(shl(64, 1), 1))
            {
                revert(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 0:212:748  "contract InitArrayTest {..."
            let _2 := add(memoryDataOffset, offset)
            if iszero(slt(add(_2, 0x1f), _1))
            {
                revert(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 0:212:748  "contract InitArrayTest {..."
            let length := mload(_2)
            if gt(length, sub(shl(64, 1), 1))
            {
                mstore(/** @src -1:-1:-1 */ 0, /** @src 0:212:748  "contract InitArrayTest {..." */ shl(224, 0x4e487b71))
                mstore(4, 0x41)
                revert(/** @src -1:-1:-1 */ 0, /** @src 0:212:748  "contract InitArrayTest {..." */ 0x24)
            }
            let _3 := shl(5, length)
            let dst := allocate_memory(add(_3, 32))
            let array := dst
            mstore(dst, length)
            dst := add(dst, 32)
            let srcEnd := add(add(_2, _3), 32)
            if gt(srcEnd, _1)
            {
                revert(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 0:212:748  "contract InitArrayTest {..."
            let src := add(_2, 32)
            for { } lt(src, srcEnd) { src := add(src, 32) }
            {
                mstore(dst, mload(src))
                dst := add(dst, 32)
            }
            /// @src 0:331:344  "uint256 i = 0"
            let var_i := /** @src -1:-1:-1 */ 0
            /// @src 0:326:433  "for (uint256 i = 0; i < _initialValues.length; i++) {..."
            for { }
            /** @src 0:212:748  "contract InitArrayTest {..." */ 1
            /// @src 0:331:344  "uint256 i = 0"
            {
                /// @src 0:373:376  "i++"
                var_i := /** @src 0:212:748  "contract InitArrayTest {..." */ add(/** @src 0:373:376  "i++" */ var_i, /** @src 0:212:748  "contract InitArrayTest {..." */ 1)
            }
            /// @src 0:373:376  "i++"
            {
                /// @src 0:346:371  "i < _initialValues.length"
                let _4 := iszero(lt(var_i, /** @src 0:212:748  "contract InitArrayTest {..." */ mload(/** @src 0:350:371  "_initialValues.length" */ array)))
                /// @src 0:346:371  "i < _initialValues.length"
                if _4 { break }
                /// @src 0:212:748  "contract InitArrayTest {..."
                _4 := /** @src -1:-1:-1 */ 0
                /// @src 0:212:748  "contract InitArrayTest {..."
                let _5 := mload(add(add(array, shl(5, var_i)), 32))
                let oldLen := sload(/** @src -1:-1:-1 */ 0)
                /// @src 0:212:748  "contract InitArrayTest {..."
                if iszero(lt(oldLen, 18446744073709551616))
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:212:748  "contract InitArrayTest {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x41)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:212:748  "contract InitArrayTest {..." */ 0x24)
                }
                let _6 := add(oldLen, 1)
                sstore(/** @src -1:-1:-1 */ 0, /** @src 0:212:748  "contract InitArrayTest {..." */ _6)
                if iszero(lt(oldLen, _6))
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:212:748  "contract InitArrayTest {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x32)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:212:748  "contract InitArrayTest {..." */ 0x24)
                }
                mstore(/** @src -1:-1:-1 */ 0, 0)
                /// @src 0:212:748  "contract InitArrayTest {..."
                sstore(add(keccak256(/** @src -1:-1:-1 */ 0, /** @src 0:212:748  "contract InitArrayTest {..." */ 32), oldLen), _5)
            }
            let _7 := mload(64)
            let _8 := datasize("InitArrayTest_64_deployed")
            codecopy(_7, dataoffset("InitArrayTest_64_deployed"), _8)
            return(_7, _8)
        }
        function allocate_memory(size) -> memPtr
        {
            memPtr := mload(64)
            let newFreePtr := add(memPtr, and(add(size, 31), not(31)))
            if or(gt(newFreePtr, sub(shl(64, 1), 1)), lt(newFreePtr, memPtr))
            {
                mstore(/** @src -1:-1:-1 */ 0, /** @src 0:212:748  "contract InitArrayTest {..." */ shl(224, 0x4e487b71))
                mstore(4, 0x41)
                revert(/** @src -1:-1:-1 */ 0, /** @src 0:212:748  "contract InitArrayTest {..." */ 0x24)
            }
            mstore(64, newFreePtr)
        }
    }
    /// @use-src 0:"foundry/src/init/InitArrayTest.sol"
    object "InitArrayTest_64_deployed" {
        code {
            {
                /// @src 0:212:748  "contract InitArrayTest {..."
                mstore(64, memoryguard(0x80))
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x5e383d21 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value := calldataload(4)
                        /// @src 0:241:264  "uint256[] public values"
                        if iszero(lt(value, /** @src 0:212:748  "contract InitArrayTest {..." */ sload(0)))
                        /// @src 0:241:264  "uint256[] public values"
                        {
                            revert(/** @src 0:212:748  "contract InitArrayTest {..." */ 0, 0)
                        }
                        /// @src 0:241:264  "uint256[] public values"
                        let slot, offset := storage_array_index_access_uint256_dyn(value)
                        /// @src 0:212:748  "contract InitArrayTest {..."
                        let value_1 := shr(shl(3, offset), sload(/** @src 0:241:264  "uint256[] public values" */ slot))
                        /// @src 0:212:748  "contract InitArrayTest {..."
                        let memPos := mload(64)
                        mstore(memPos, value_1)
                        return(memPos, 32)
                    }
                    case 0x981f5499 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let pos := mload(64)
                        let memPtr := pos
                        let length := sload(0)
                        mstore(pos, length)
                        pos := add(pos, 0x20)
                        let updated_pos := pos
                        mstore(0, 0)
                        let srcPtr := 18569430475105882587588266137607568536673111973893317399460219858819262702947
                        let i := 0
                        for { } lt(i, length) { i := add(i, 1) }
                        {
                            mstore(pos, sload(srcPtr))
                            pos := add(pos, 0x20)
                            srcPtr := add(srcPtr, 1)
                        }
                        let newFreePtr := add(memPtr, and(add(sub(pos, memPtr), 31), not(31)))
                        if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr))
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x41)
                            revert(0, 0x24)
                        }
                        mstore(64, newFreePtr)
                        let tail := add(newFreePtr, 0x20)
                        mstore(newFreePtr, 0x20)
                        let pos_1 := tail
                        let length_1 := mload(memPtr)
                        mstore(tail, length_1)
                        pos_1 := add(newFreePtr, 64)
                        let srcPtr_1 := updated_pos
                        let i_1 := 0
                        for { } lt(i_1, length_1) { i_1 := add(i_1, 1) }
                        {
                            mstore(pos_1, mload(srcPtr_1))
                            pos_1 := add(pos_1, 0x20)
                            srcPtr_1 := add(srcPtr_1, 0x20)
                        }
                        return(newFreePtr, sub(pos_1, newFreePtr))
                    }
                    case 0xbc6b888b {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        /// @src 0:625:638  "values[index]"
                        let _1, _2 := storage_array_index_access_uint256_dyn(/** @src 0:212:748  "contract InitArrayTest {..." */ calldataload(4))
                        let value_2 := shr(shl(3, _2), sload(/** @src 0:625:638  "values[index]" */ _1))
                        /// @src 0:212:748  "contract InitArrayTest {..."
                        let memPos_1 := mload(64)
                        mstore(memPos_1, value_2)
                        return(memPos_1, 32)
                    }
                    case 0xbe1c766b {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let length_2 := sload(0)
                        let memPos_2 := mload(64)
                        mstore(memPos_2, length_2)
                        return(memPos_2, 32)
                    }
                }
                revert(0, 0)
            }
            function storage_array_index_access_uint256_dyn(index) -> slot, offset
            {
                if iszero(lt(index, sload(0)))
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x32)
                    revert(0, 0x24)
                }
                mstore(0, 0)
                slot := add(keccak256(0, 0x20), index)
                offset := 0
            }
        }
        data ".metadata" hex"a26469706673582212202697e60d85976e8bd8fcc13fa4e8f185aa27c191d25b63febcf1e6c674ce663164736f6c634300081c0033"
    }
}