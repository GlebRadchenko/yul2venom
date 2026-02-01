object "Encoding_160" {
    code {
        {
            /// @src 0:141:1829  "contract Encoding {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("Encoding_160_deployed")
            codecopy(_1, dataoffset("Encoding_160_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/bench/Encoding.sol"
    object "Encoding_160_deployed" {
        code {
            {
                /// @src 0:141:1829  "contract Encoding {..."
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x0c74e88e {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let offset := calldataload(4)
                        if gt(offset, 0xffffffffffffffff) { revert(0, 0) }
                        let value0, value1 := abi_decode_bytes_calldata(add(4, offset), calldatasize())
                        /// @src 0:1784:1820  "abi.decode(data, (uint256, uint256))"
                        let value0_1 := /** @src 0:141:1829  "contract Encoding {..." */ 0
                        /// @src 0:1784:1820  "abi.decode(data, (uint256, uint256))"
                        let value1_1 := /** @src 0:141:1829  "contract Encoding {..." */ 0
                        if slt(sub(/** @src 0:1784:1820  "abi.decode(data, (uint256, uint256))" */ add(value0, value1), /** @src 0:141:1829  "contract Encoding {..." */ value0), 64) { revert(0, 0) }
                        value0_1 := calldataload(value0)
                        value1_1 := calldataload(add(value0, 32))
                        mstore(_1, value0_1)
                        mstore(add(_1, 32), value1_1)
                        return(_1, 64)
                    }
                    case 0x11850929 {
                        if callvalue() { revert(0, 0) }
                        let param, param_1 := abi_decode_uint256t_uint256(calldatasize())
                        /// @src 0:1576:1598  "abi.encodePacked(a, b)"
                        let expr_mpos := /** @src 0:141:1829  "contract Encoding {..." */ mload(64)
                        /// @src 0:1576:1598  "abi.encodePacked(a, b)"
                        let _2 := add(expr_mpos, 0x20)
                        /// @src 0:141:1829  "contract Encoding {..."
                        mstore(_2, param)
                        mstore(add(/** @src 0:1576:1598  "abi.encodePacked(a, b)" */ expr_mpos, /** @src 0:141:1829  "contract Encoding {..." */ 64), param_1)
                        /// @src 0:1576:1598  "abi.encodePacked(a, b)"
                        mstore(expr_mpos, /** @src 0:141:1829  "contract Encoding {..." */ 64)
                        /// @src 0:1576:1598  "abi.encodePacked(a, b)"
                        finalize_allocation(expr_mpos, 96)
                        /// @src 0:1559:1599  "return keccak256(abi.encodePacked(a, b))"
                        let var := /** @src 0:1566:1599  "keccak256(abi.encodePacked(a, b))" */ keccak256(/** @src 0:141:1829  "contract Encoding {..." */ _2, mload(/** @src 0:1566:1599  "keccak256(abi.encodePacked(a, b))" */ expr_mpos))
                        /// @src 0:141:1829  "contract Encoding {..."
                        let memPos := mload(64)
                        mstore(memPos, var)
                        return(memPos, /** @src 0:1576:1598  "abi.encodePacked(a, b)" */ 0x20)
                    }
                    case /** @src 0:141:1829  "contract Encoding {..." */ 0x1e768902 {
                        if callvalue() { revert(0, 0) }
                        let param_2, param_3 := abi_decode_uint256t_uint256(calldatasize())
                        /// @src 0:474:496  "abi.encodePacked(a, b)"
                        let expr_mpos_1 := /** @src 0:141:1829  "contract Encoding {..." */ mload(64)
                        mstore(/** @src 0:474:496  "abi.encodePacked(a, b)" */ add(expr_mpos_1, 0x20), /** @src 0:141:1829  "contract Encoding {..." */ param_2)
                        mstore(add(/** @src 0:474:496  "abi.encodePacked(a, b)" */ expr_mpos_1, /** @src 0:141:1829  "contract Encoding {..." */ 64), param_3)
                        /// @src 0:474:496  "abi.encodePacked(a, b)"
                        mstore(expr_mpos_1, /** @src 0:141:1829  "contract Encoding {..." */ 64)
                        /// @src 0:474:496  "abi.encodePacked(a, b)"
                        finalize_allocation(expr_mpos_1, 96)
                        /// @src 0:141:1829  "contract Encoding {..."
                        let memPos_1 := mload(64)
                        return(memPos_1, sub(abi_encode_bytes(memPos_1, expr_mpos_1), memPos_1))
                    }
                    case 0x36dcae6d {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        let value := calldataload(4)
                        if iszero(eq(value, and(value, shl(224, 0xffffffff)))) { revert(0, 0) }
                        /// @src 0:644:679  "abi.encodeWithSelector(selector, a)"
                        let expr_mpos_2 := /** @src 0:141:1829  "contract Encoding {..." */ mload(64)
                        /// @src 0:644:679  "abi.encodeWithSelector(selector, a)"
                        mstore(add(expr_mpos_2, /** @src 0:141:1829  "contract Encoding {..." */ 32), /** @src 0:644:679  "abi.encodeWithSelector(selector, a)" */ value)
                        /// @src 0:141:1829  "contract Encoding {..."
                        mstore(/** @src 0:644:679  "abi.encodeWithSelector(selector, a)" */ add(expr_mpos_2, /** @src 0:141:1829  "contract Encoding {..." */ 36), calldataload(36))
                        /// @src 0:644:679  "abi.encodeWithSelector(selector, a)"
                        mstore(expr_mpos_2, /** @src 0:141:1829  "contract Encoding {..." */ 36)
                        /// @src 0:644:679  "abi.encodeWithSelector(selector, a)"
                        finalize_allocation(expr_mpos_2, 68)
                        /// @src 0:141:1829  "contract Encoding {..."
                        let memPos_2 := mload(64)
                        return(memPos_2, sub(abi_encode_bytes(memPos_2, expr_mpos_2), memPos_2))
                    }
                    case 0x4f66de1e {
                        if callvalue() { revert(0, 0) }
                        let param_4, param_5 := abi_decode_uint256t_uint256(calldatasize())
                        /// @src 0:1418:1434  "abi.encode(a, b)"
                        let expr_mpos_3 := /** @src 0:141:1829  "contract Encoding {..." */ mload(64)
                        /// @src 0:1418:1434  "abi.encode(a, b)"
                        let _3 := add(expr_mpos_3, 0x20)
                        /// @src 0:141:1829  "contract Encoding {..."
                        mstore(_3, param_4)
                        mstore(add(/** @src 0:1418:1434  "abi.encode(a, b)" */ expr_mpos_3, /** @src 0:141:1829  "contract Encoding {..." */ 64), param_5)
                        /// @src 0:1418:1434  "abi.encode(a, b)"
                        mstore(expr_mpos_3, /** @src 0:141:1829  "contract Encoding {..." */ 64)
                        /// @src 0:1418:1434  "abi.encode(a, b)"
                        finalize_allocation(expr_mpos_3, 96)
                        /// @src 0:1401:1435  "return keccak256(abi.encode(a, b))"
                        let var_1 := /** @src 0:1408:1435  "keccak256(abi.encode(a, b))" */ keccak256(/** @src 0:141:1829  "contract Encoding {..." */ _3, mload(/** @src 0:1408:1435  "keccak256(abi.encode(a, b))" */ expr_mpos_3))
                        /// @src 0:141:1829  "contract Encoding {..."
                        let memPos_3 := mload(64)
                        mstore(memPos_3, var_1)
                        return(memPos_3, /** @src 0:1418:1434  "abi.encode(a, b)" */ 0x20)
                    }
                    case /** @src 0:141:1829  "contract Encoding {..." */ 0x54a65923 {
                        if callvalue() { revert(0, 0) }
                        let param_6, param_7 := abi_decode_uint256t_uint256(calldatasize())
                        /// @src 0:322:338  "abi.encode(a, b)"
                        let expr_mpos_4 := /** @src 0:141:1829  "contract Encoding {..." */ mload(64)
                        mstore(/** @src 0:322:338  "abi.encode(a, b)" */ add(expr_mpos_4, 0x20), /** @src 0:141:1829  "contract Encoding {..." */ param_6)
                        mstore(add(/** @src 0:322:338  "abi.encode(a, b)" */ expr_mpos_4, /** @src 0:141:1829  "contract Encoding {..." */ 64), param_7)
                        /// @src 0:322:338  "abi.encode(a, b)"
                        mstore(expr_mpos_4, /** @src 0:141:1829  "contract Encoding {..." */ 64)
                        /// @src 0:322:338  "abi.encode(a, b)"
                        finalize_allocation(expr_mpos_4, 96)
                        /// @src 0:141:1829  "contract Encoding {..."
                        let memPos_4 := mload(64)
                        return(memPos_4, sub(abi_encode_bytes(memPos_4, expr_mpos_4), memPos_4))
                    }
                    case 0xbbd05589 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 96) { revert(0, 0) }
                        let value_1 := calldataload(4)
                        if iszero(eq(value_1, and(value_1, 0xff))) { revert(0, 0) }
                        let value_2 := calldataload(36)
                        if iszero(eq(value_2, and(value_2, 0xffff))) { revert(0, 0) }
                        /// @src 0:1080:1105  "abi.encodePacked(a, b, c)"
                        let expr_mpos_5 := /** @src 0:141:1829  "contract Encoding {..." */ mload(64)
                        mstore(/** @src 0:1080:1105  "abi.encodePacked(a, b, c)" */ add(expr_mpos_5, /** @src 0:141:1829  "contract Encoding {..." */ 32), and(shl(248, value_1), shl(248, 255)))
                        mstore(add(/** @src 0:1080:1105  "abi.encodePacked(a, b, c)" */ expr_mpos_5, /** @src 0:141:1829  "contract Encoding {..." */ 33), and(shl(240, value_2), shl(240, 65535)))
                        mstore(add(/** @src 0:1080:1105  "abi.encodePacked(a, b, c)" */ expr_mpos_5, /** @src 0:141:1829  "contract Encoding {..." */ 35), calldataload(68))
                        /// @src 0:1080:1105  "abi.encodePacked(a, b, c)"
                        mstore(expr_mpos_5, /** @src 0:141:1829  "contract Encoding {..." */ 35)
                        /// @src 0:1080:1105  "abi.encodePacked(a, b, c)"
                        finalize_allocation(expr_mpos_5, 67)
                        /// @src 0:141:1829  "contract Encoding {..."
                        let memPos_5 := mload(64)
                        return(memPos_5, sub(abi_encode_bytes(memPos_5, expr_mpos_5), memPos_5))
                    }
                    case 0xeb90f459 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let offset_1 := calldataload(4)
                        if gt(offset_1, 0xffffffffffffffff) { revert(0, 0) }
                        let value0_2, value1_2 := abi_decode_bytes_calldata(add(4, offset_1), calldatasize())
                        if gt(value1_2, 0xffffffffffffffff)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x41)
                            revert(0, 0x24)
                        }
                        let memPtr := mload(64)
                        finalize_allocation(memPtr, add(and(add(value1_2, 31), not(31)), 32))
                        mstore(memPtr, value1_2)
                        let dst := add(memPtr, 32)
                        if gt(add(value0_2, value1_2), calldatasize()) { revert(0, 0) }
                        calldatacopy(dst, value0_2, value1_2)
                        mstore(add(add(memPtr, value1_2), 32), 0)
                        /// @src 0:1255:1277  "return keccak256(data)"
                        let var_2 := /** @src 0:1262:1277  "keccak256(data)" */ keccak256(/** @src 0:141:1829  "contract Encoding {..." */ dst, mload(/** @src 0:1262:1277  "keccak256(data)" */ memPtr))
                        /// @src 0:141:1829  "contract Encoding {..."
                        let memPos_6 := mload(64)
                        mstore(memPos_6, var_2)
                        return(memPos_6, 32)
                    }
                    case 0xf0f00925 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 128) { revert(0, 0) }
                        let value_3 := calldataload(36)
                        let _4 := and(value_3, sub(shl(160, 1), 1))
                        if iszero(eq(value_3, _4)) { revert(0, 0) }
                        let offset_2 := calldataload(100)
                        if gt(offset_2, 0xffffffffffffffff) { revert(0, 0) }
                        let value3, value4 := abi_decode_bytes_calldata(add(4, offset_2), calldatasize())
                        /// @src 0:904:926  "abi.encode(a, b, c, d)"
                        let expr_mpos_6 := /** @src 0:141:1829  "contract Encoding {..." */ mload(64)
                        mstore(/** @src 0:904:926  "abi.encode(a, b, c, d)" */ add(expr_mpos_6, /** @src 0:141:1829  "contract Encoding {..." */ 32), calldataload(4))
                        mstore(add(/** @src 0:904:926  "abi.encode(a, b, c, d)" */ expr_mpos_6, /** @src 0:141:1829  "contract Encoding {..." */ 64), _4)
                        mstore(add(/** @src 0:904:926  "abi.encode(a, b, c, d)" */ expr_mpos_6, /** @src 0:141:1829  "contract Encoding {..." */ 96), calldataload(68))
                        mstore(add(/** @src 0:904:926  "abi.encode(a, b, c, d)" */ expr_mpos_6, /** @src 0:141:1829  "contract Encoding {..." */ 128), 128)
                        mstore(add(/** @src 0:904:926  "abi.encode(a, b, c, d)" */ expr_mpos_6, /** @src 0:141:1829  "contract Encoding {..." */ 160), value4)
                        calldatacopy(add(/** @src 0:904:926  "abi.encode(a, b, c, d)" */ expr_mpos_6, /** @src 0:141:1829  "contract Encoding {..." */ 192), value3, value4)
                        mstore(add(add(/** @src 0:904:926  "abi.encode(a, b, c, d)" */ expr_mpos_6, /** @src 0:141:1829  "contract Encoding {..." */ value4), 192), 0)
                        /// @src 0:904:926  "abi.encode(a, b, c, d)"
                        let _5 := add(sub(/** @src 0:141:1829  "contract Encoding {..." */ add(/** @src 0:904:926  "abi.encode(a, b, c, d)" */ expr_mpos_6, /** @src 0:141:1829  "contract Encoding {..." */ and(add(value4, 31), not(31))), /** @src 0:904:926  "abi.encode(a, b, c, d)" */ expr_mpos_6), /** @src 0:141:1829  "contract Encoding {..." */ 192)
                        /// @src 0:904:926  "abi.encode(a, b, c, d)"
                        mstore(expr_mpos_6, add(_5, /** @src 0:141:1829  "contract Encoding {..." */ not(31)))
                        /// @src 0:904:926  "abi.encode(a, b, c, d)"
                        finalize_allocation(expr_mpos_6, _5)
                        /// @src 0:141:1829  "contract Encoding {..."
                        let memPos_7 := mload(64)
                        return(memPos_7, sub(abi_encode_bytes(memPos_7, expr_mpos_6), memPos_7))
                    }
                }
                revert(0, 0)
            }
            function abi_decode_bytes_calldata(offset, end) -> arrayPos, length
            {
                if iszero(slt(add(offset, 0x1f), end)) { revert(0, 0) }
                length := calldataload(offset)
                if gt(length, 0xffffffffffffffff) { revert(0, 0) }
                arrayPos := add(offset, 0x20)
                if gt(add(add(offset, length), 0x20), end) { revert(0, 0) }
            }
            function abi_decode_uint256t_uint256(dataEnd) -> value0, value1
            {
                if slt(add(dataEnd, not(3)), 64) { revert(0, 0) }
                value0 := calldataload(4)
                value1 := calldataload(36)
            }
            function abi_encode_bytes(headStart, value0) -> tail
            {
                mstore(headStart, 32)
                let length := mload(value0)
                mstore(add(headStart, 32), length)
                mcopy(add(headStart, 64), add(value0, 32), length)
                mstore(add(add(headStart, length), 64), 0)
                tail := add(add(headStart, and(add(length, 31), not(31))), 64)
            }
            function finalize_allocation(memPtr, size)
            {
                let newFreePtr := add(memPtr, and(add(size, 31), not(31)))
                if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr))
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:141:1829  "contract Encoding {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x41)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:141:1829  "contract Encoding {..." */ 0x24)
                }
                mstore(64, newFreePtr)
            }
        }
        data ".metadata" hex"a26469706673582212202da795b0b6941083e5f16ff6678aaf0f973eb166d854c426f4372d1ece5607ce64736f6c634300081c0033"
    }
}