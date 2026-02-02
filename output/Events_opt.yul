object "Events_146" {
    code {
        {
            /// @src 0:142:1599  "contract Events {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("Events_146_deployed")
            codecopy(_1, dataoffset("Events_146_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/bench/Events.sol"
    object "Events_146_deployed" {
        code {
            {
                /// @src 0:142:1599  "contract Events {..."
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x2536f127 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let offset := calldataload(4)
                        if gt(offset, 0xffffffffffffffff) { revert(0, 0) }
                        let value0, value1 := abi_decode_string_calldata(add(4, offset), calldatasize())
                        mstore(_1, 32)
                        /// @src 0:1025:1045  "StringEvent(message)"
                        log1(_1, sub(/** @src 0:142:1599  "contract Events {..." */ abi_encode_string_calldata(value0, value1, add(_1, 32)), /** @src 0:1025:1045  "StringEvent(message)" */ _1), 0x617cf8a4400dd7963ed519ebe655a16e8da1282bb8fea36a21f634af912f54ab)
                        /// @src 0:142:1599  "contract Events {..."
                        return(0, 0)
                    }
                    case 0x309818a4 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let var_count := calldataload(4)
                        /// @src 0:1473:1501  "if (count > 100) count = 100"
                        if /** @src 0:1477:1488  "count > 100" */ gt(var_count, /** @src 0:1485:1488  "100" */ 0x64)
                        /// @src 0:1473:1501  "if (count > 100) count = 100"
                        {
                            /// @src 0:1490:1501  "count = 100"
                            var_count := /** @src 0:1485:1488  "100" */ 0x64
                        }
                        /// @src 0:1516:1529  "uint256 i = 0"
                        let var_i := /** @src 0:142:1599  "contract Events {..." */ 0
                        /// @src 0:1511:1591  "for (uint256 i = 0; i < count; i++) {..."
                        for { }
                        /** @src 0:1531:1540  "i < count" */ lt(var_i, var_count)
                        /// @src 0:1516:1529  "uint256 i = 0"
                        {
                            /// @src 0:1542:1545  "i++"
                            var_i := /** @src 0:142:1599  "contract Events {..." */ add(/** @src 0:1542:1545  "i++" */ var_i, /** @src 0:142:1599  "contract Events {..." */ 1)
                        }
                        /// @src 0:1542:1545  "i++"
                        {
                            /// @src 0:1566:1580  "SimpleEvent(i)"
                            let _2 := /** @src 0:142:1599  "contract Events {..." */ mload(64)
                            mstore(_2, var_i)
                            /// @src 0:1566:1580  "SimpleEvent(i)"
                            log1(_2, /** @src 0:142:1599  "contract Events {..." */ 32, /** @src 0:1566:1580  "SimpleEvent(i)" */ 0x12d199749b3f4c44df8d9386c63d725b7756ec47204f3aa0bf05ea832f89effb)
                        }
                        /// @src 0:142:1599  "contract Events {..."
                        return(0, 0)
                    }
                    case 0x7ea47d4b {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 96) { revert(0, 0) }
                        let offset_1 := calldataload(68)
                        if gt(offset_1, 0xffffffffffffffff) { revert(0, 0) }
                        let value2, value3 := abi_decode_string_calldata(add(4, offset_1), calldatasize())
                        /// @src 0:1318:1359  "ComplexEvent(msg.sender, id, value, data)"
                        let _3 := /** @src 0:142:1599  "contract Events {..." */ mload(64)
                        mstore(_3, calldataload(36))
                        mstore(add(_3, 32), 64)
                        /// @src 0:1318:1359  "ComplexEvent(msg.sender, id, value, data)"
                        log3(_3, sub(/** @src 0:142:1599  "contract Events {..." */ abi_encode_string_calldata(value2, value3, add(_3, 64)), /** @src 0:1318:1359  "ComplexEvent(msg.sender, id, value, data)" */ _3), 0x5bc8cccb2e4db71ecfb93e6240a44bedb48dc3b393064e139b7bc6d27d257d59, /** @src 0:1331:1341  "msg.sender" */ caller(), /** @src 0:142:1599  "contract Events {..." */ calldataload(4))
                        return(0, 0)
                    }
                    case 0xb12c11e4 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 96) { revert(0, 0) }
                        /// @src 0:873:894  "MultiIndexed(a, b, c)"
                        log4(/** @src 0:142:1599  "contract Events {..." */ 0, 0, /** @src 0:873:894  "MultiIndexed(a, b, c)" */ 0x39eb0fba179eb98affc7a0a67edf5a0d4cc6ee08a1ebd277c8bb980da58adc22, /** @src 0:142:1599  "contract Events {..." */ calldataload(4), calldataload(36), calldataload(68))
                        return(0, 0)
                    }
                    case 0xc76f0635 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let offset_2 := calldataload(4)
                        if gt(offset_2, 0xffffffffffffffff) { revert(0, 0) }
                        let value0_1, value1_1 := abi_decode_string_calldata(add(4, offset_2), calldatasize())
                        /// @src 0:1122:1138  "BytesEvent(data)"
                        let _4 := /** @src 0:142:1599  "contract Events {..." */ mload(64)
                        mstore(_4, 32)
                        /// @src 0:1122:1138  "BytesEvent(data)"
                        log1(_4, sub(/** @src 0:142:1599  "contract Events {..." */ abi_encode_string_calldata(value0_1, value1_1, add(_4, 32)), /** @src 0:1122:1138  "BytesEvent(data)" */ _4), 0x9ee3485561a302141390e6d886e41f4922a82c93c6ab2d9f52c30cbd682994f1)
                        /// @src 0:142:1599  "contract Events {..."
                        return(0, 0)
                    }
                    case 0xd0ee85c8 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        /// @src 0:651:669  "SimpleEvent(value)"
                        let _5 := /** @src 0:142:1599  "contract Events {..." */ mload(64)
                        mstore(_5, calldataload(4))
                        /// @src 0:651:669  "SimpleEvent(value)"
                        log1(_5, /** @src 0:142:1599  "contract Events {..." */ 32, /** @src 0:651:669  "SimpleEvent(value)" */ 0x12d199749b3f4c44df8d9386c63d725b7756ec47204f3aa0bf05ea832f89effb)
                        /// @src 0:142:1599  "contract Events {..."
                        return(0, 0)
                    }
                    case 0xfa31e50b {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        /// @src 0:754:777  "IndexedEvent(id, value)"
                        let _6 := /** @src 0:142:1599  "contract Events {..." */ mload(64)
                        mstore(_6, calldataload(36))
                        /// @src 0:754:777  "IndexedEvent(id, value)"
                        log2(_6, /** @src 0:142:1599  "contract Events {..." */ 32, /** @src 0:754:777  "IndexedEvent(id, value)" */ 0xc254f246ab6ea865f412958066d69e30165cc2edb333036518db581d9176a2d0, /** @src 0:142:1599  "contract Events {..." */ calldataload(4))
                        return(0, 0)
                    }
                }
                revert(0, 0)
            }
            function abi_decode_string_calldata(offset, end) -> arrayPos, length
            {
                if iszero(slt(add(offset, 0x1f), end)) { revert(0, 0) }
                length := calldataload(offset)
                if gt(length, 0xffffffffffffffff) { revert(0, 0) }
                arrayPos := add(offset, 0x20)
                if gt(add(add(offset, length), 0x20), end) { revert(0, 0) }
            }
            function abi_encode_string_calldata(start, length, pos) -> end
            {
                mstore(pos, length)
                calldatacopy(add(pos, 0x20), start, length)
                mstore(add(add(pos, length), 0x20), /** @src -1:-1:-1 */ 0)
                /// @src 0:142:1599  "contract Events {..."
                end := add(add(pos, and(add(length, 31), not(31))), 0x20)
            }
        }
        data ".metadata" hex"a26469706673582212202b5112c1f41c8f28f4304a62ef647cb429a83584c125d368cbfab7c43fdd773464736f6c634300081c0033"
    }
}