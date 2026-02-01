object "ArrayLib_170" {
    code {
        {
            /// @src 0:988:1621  "library ArrayLib {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("ArrayLib_170_deployed")
            codecopy(_1, dataoffset("ArrayLib_170_deployed"), _2)
            setimmutable(_1, "library_deploy_address", address())
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/bench/ExternalLibrary.sol"
    object "ArrayLib_170_deployed" {
        code {
            {
                /// @src 0:988:1621  "library ArrayLib {..."
                mstore(64, memoryguard(0x80))
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x0194db8e {
                        let _1 := abi_decode_array_uint256_dyn(calldatasize())
                        /// @src 0:1123:1140  "uint256 total = 0"
                        let var_total := /** @src 0:988:1621  "library ArrayLib {..." */ 0
                        /// @src 0:1155:1168  "uint256 i = 0"
                        let var_i := /** @src 0:988:1621  "library ArrayLib {..." */ 0
                        /// @src 0:1150:1231  "for (uint256 i = 0; i < arr.length; i++) {..."
                        for { }
                        /** @src 0:988:1621  "library ArrayLib {..." */ 1
                        /// @src 0:1155:1168  "uint256 i = 0"
                        {
                            /// @src 0:1186:1189  "i++"
                            var_i := /** @src 0:988:1621  "library ArrayLib {..." */ add(/** @src 0:1186:1189  "i++" */ var_i, /** @src 0:988:1621  "library ArrayLib {..." */ 1)
                        }
                        /// @src 0:1186:1189  "i++"
                        {
                            /// @src 0:1170:1184  "i < arr.length"
                            if iszero(lt(var_i, /** @src 0:988:1621  "library ArrayLib {..." */ mload(/** @src 0:1174:1184  "arr.length" */ _1)))
                            /// @src 0:1170:1184  "i < arr.length"
                            { break }
                            /// @src 0:988:1621  "library ArrayLib {..."
                            let sum := add(var_total, mload(/** @src 0:1214:1220  "arr[i]" */ memory_array_index_access_uint256_dyn(_1, var_i)))
                            /// @src 0:988:1621  "library ArrayLib {..."
                            if gt(var_total, sum)
                            {
                                mstore(0, shl(224, 0x4e487b71))
                                mstore(4, 0x11)
                                revert(0, 0x24)
                            }
                            /// @src 0:1205:1220  "total += arr[i]"
                            var_total := sum
                        }
                        /// @src 0:988:1621  "library ArrayLib {..."
                        let memPos := mload(64)
                        mstore(memPos, var_total)
                        return(memPos, 32)
                    }
                    case 0x3bf6de96 {
                        let _2 := abi_decode_array_uint256_dyn(calldatasize())
                        if /** @src 0:1383:1397  "arr.length > 0" */ iszero(/** @src 0:988:1621  "library ArrayLib {..." */ mload(/** @src 0:1383:1393  "arr.length" */ _2))
                        /// @src 0:988:1621  "library ArrayLib {..."
                        {
                            let memPtr := mload(64)
                            mstore(memPtr, shl(229, 4594637))
                            mstore(add(memPtr, 4), 32)
                            mstore(add(memPtr, 36), 11)
                            mstore(add(memPtr, 68), "Empty array")
                            revert(memPtr, 100)
                        }
                        /// @src 0:1440:1446  "arr[0]"
                        let addr := /** @src 0:988:1621  "library ArrayLib {..." */ 0
                        if iszero(mload(_2))
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x32)
                            revert(0, 0x24)
                        }
                        addr := add(_2, 32)
                        /// @src 0:1423:1446  "uint256 maxVal = arr[0]"
                        let var_maxVal := /** @src 0:988:1621  "library ArrayLib {..." */ mload(addr)
                        /// @src 0:1461:1474  "uint256 i = 1"
                        let var_i_1 := /** @src 0:1473:1474  "1" */ 0x01
                        /// @src 0:1456:1590  "for (uint256 i = 1; i < arr.length; i++) {..."
                        for { }
                        /** @src 0:1473:1474  "1" */ 0x01
                        /// @src 0:1461:1474  "uint256 i = 1"
                        {
                            /// @src 0:1492:1495  "i++"
                            var_i_1 := /** @src 0:988:1621  "library ArrayLib {..." */ add(/** @src 0:1492:1495  "i++" */ var_i_1, /** @src 0:1473:1474  "1" */ 0x01)
                        }
                        /// @src 0:1492:1495  "i++"
                        {
                            /// @src 0:1476:1490  "i < arr.length"
                            if iszero(lt(var_i_1, /** @src 0:988:1621  "library ArrayLib {..." */ mload(/** @src 0:1480:1490  "arr.length" */ _2)))
                            /// @src 0:1476:1490  "i < arr.length"
                            { break }
                            /// @src 0:1511:1580  "if (arr[i] > maxVal) {..."
                            if /** @src 0:1515:1530  "arr[i] > maxVal" */ gt(/** @src 0:988:1621  "library ArrayLib {..." */ mload(/** @src 0:1515:1521  "arr[i]" */ memory_array_index_access_uint256_dyn(_2, var_i_1)), /** @src 0:1515:1530  "arr[i] > maxVal" */ var_maxVal)
                            /// @src 0:1511:1580  "if (arr[i] > maxVal) {..."
                            {
                                /// @src 0:1550:1565  "maxVal = arr[i]"
                                var_maxVal := /** @src 0:988:1621  "library ArrayLib {..." */ mload(/** @src 0:1559:1565  "arr[i]" */ memory_array_index_access_uint256_dyn(_2, var_i_1))
                            }
                        }
                        /// @src 0:988:1621  "library ArrayLib {..."
                        let memPos_1 := mload(64)
                        mstore(memPos_1, var_maxVal)
                        return(memPos_1, 32)
                    }
                }
                revert(0, 0)
            }
            function abi_decode_array_uint256_dyn(dataEnd) -> value0
            {
                if slt(add(dataEnd, not(3)), 32) { revert(0, 0) }
                let offset := calldataload(4)
                if gt(offset, 0xffffffffffffffff) { revert(0, 0) }
                if iszero(slt(add(offset, 35), dataEnd))
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:988:1621  "library ArrayLib {..."
                let length := calldataload(add(4, offset))
                if gt(length, 0xffffffffffffffff)
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:988:1621  "library ArrayLib {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x41)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:988:1621  "library ArrayLib {..." */ 36)
                }
                let _1 := shl(5, length)
                let memPtr := mload(64)
                let newFreePtr := add(memPtr, and(add(_1, 63), not(31)))
                if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr))
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:988:1621  "library ArrayLib {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x41)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:988:1621  "library ArrayLib {..." */ 36)
                }
                mstore(64, newFreePtr)
                let dst := memPtr
                mstore(memPtr, length)
                dst := add(memPtr, 32)
                let srcEnd := add(add(offset, _1), 36)
                if gt(srcEnd, dataEnd)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:988:1621  "library ArrayLib {..."
                let src := add(offset, 36)
                for { } lt(src, srcEnd) { src := add(src, 32) }
                {
                    mstore(dst, calldataload(src))
                    dst := add(dst, 32)
                }
                value0 := memPtr
            }
            function memory_array_index_access_uint256_dyn(baseRef, index) -> addr
            {
                if iszero(lt(index, mload(baseRef)))
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x32)
                    revert(0, 0x24)
                }
                addr := add(add(baseRef, shl(5, index)), 32)
            }
        }
        data ".metadata" hex"a26469706673582212206dc7229eccbef82900c38b86647ad8842bb4e184b640427c8f66fc8d35b9bca164736f6c634300081c0033"
    }
}