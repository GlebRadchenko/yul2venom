/// @use-src 0:"src/init/InitNewChildTest.sol"
object "InitNewChildTest_204" {
    code {
        {
            /// @src 0:921:2403  "contract InitNewChildTest {..."
            mstore(64, memoryguard(0xc0))
            if callvalue() { revert(0, 0) }
            let programSize := datasize("InitNewChildTest_204")
            let argSize := sub(codesize(), programSize)
            let memoryDataOffset := allocate_memory(argSize)
            codecopy(memoryDataOffset, programSize, argSize)
            let _1 := add(memoryDataOffset, argSize)
            if slt(sub(_1, memoryDataOffset), 64)
            {
                revert(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 0:921:2403  "contract InitNewChildTest {..."
            let value := mload(memoryDataOffset)
            let offset := mload(add(memoryDataOffset, 32))
            if gt(offset, sub(shl(64, 1), 1))
            {
                revert(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 0:921:2403  "contract InitNewChildTest {..."
            let _2 := add(memoryDataOffset, offset)
            if iszero(slt(add(_2, 0x1f), _1))
            {
                revert(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 0:921:2403  "contract InitNewChildTest {..."
            let length := mload(_2)
            if gt(length, sub(shl(64, 1), 1))
            {
                mstore(/** @src -1:-1:-1 */ 0, /** @src 0:921:2403  "contract InitNewChildTest {..." */ shl(224, 0x4e487b71))
                mstore(4, 0x41)
                revert(/** @src -1:-1:-1 */ 0, /** @src 0:921:2403  "contract InitNewChildTest {..." */ 0x24)
            }
            let array := allocate_memory(add(and(add(length, 0x1f), not(31)), 32))
            mstore(array, length)
            let dst := add(array, 32)
            if gt(add(add(_2, length), 32), _1)
            {
                revert(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 0:921:2403  "contract InitNewChildTest {..."
            mcopy(dst, add(_2, 32), length)
            mstore(add(add(array, length), 32), /** @src -1:-1:-1 */ 0)
            /// @src 0:921:2403  "contract InitNewChildTest {..."
            sstore(1, value)
            sstore(/** @src 0:1306:1327  "deployer = msg.sender" */ 0x02, /** @src 0:921:2403  "contract InitNewChildTest {..." */ or(and(sload(/** @src 0:1306:1327  "deployer = msg.sender" */ 0x02), /** @src 0:921:2403  "contract InitNewChildTest {..." */ not(sub(shl(160, 1), 1))), /** @src 0:1317:1327  "msg.sender" */ caller()))
            /// @src 0:1400:1441  "new ChildContractA(address(this), _value)"
            let _3 := /** @src 0:921:2403  "contract InitNewChildTest {..." */ mload(64)
            /// @src 0:1400:1441  "new ChildContractA(address(this), _value)"
            let _4 := datasize("ChildContractA_35")
            let _5 := add(_3, _4)
            if or(gt(_5, /** @src 0:921:2403  "contract InitNewChildTest {..." */ sub(shl(64, 1), 1)), /** @src 0:1400:1441  "new ChildContractA(address(this), _value)" */ lt(_5, _3))
            {
                /// @src 0:921:2403  "contract InitNewChildTest {..."
                mstore(/** @src -1:-1:-1 */ 0, /** @src 0:921:2403  "contract InitNewChildTest {..." */ shl(224, 0x4e487b71))
                mstore(4, 0x41)
                revert(/** @src -1:-1:-1 */ 0, /** @src 0:921:2403  "contract InitNewChildTest {..." */ 0x24)
            }
            /// @src 0:1400:1441  "new ChildContractA(address(this), _value)"
            let _6 := dataoffset("ChildContractA_35")
            datacopy(_3, _6, _4)
            let expr_address := create(/** @src -1:-1:-1 */ 0, /** @src 0:1400:1441  "new ChildContractA(address(this), _value)" */ _3, sub(abi_encode_address_uint256(_5, /** @src 0:1427:1431  "this" */ address(), /** @src 0:1400:1441  "new ChildContractA(address(this), _value)" */ value), _3))
            if iszero(expr_address)
            {
                /// @src 0:921:2403  "contract InitNewChildTest {..."
                let pos := mload(64)
                returndatacopy(pos, /** @src -1:-1:-1 */ 0, /** @src 0:921:2403  "contract InitNewChildTest {..." */ returndatasize())
                revert(pos, returndatasize())
            }
            /// @src 0:1383:1442  "childA = address(new ChildContractA(address(this), _value))"
            mstore(128, /** @src 0:921:2403  "contract InitNewChildTest {..." */ and(/** @src 0:1392:1442  "address(new ChildContractA(address(this), _value))" */ expr_address, /** @src 0:921:2403  "contract InitNewChildTest {..." */ sub(shl(160, 1), 1)))
            /// @src 0:1469:1506  "new ChildContractB(msg.sender, _name)"
            let _7 := /** @src 0:921:2403  "contract InitNewChildTest {..." */ mload(64)
            /// @src 0:1469:1506  "new ChildContractB(msg.sender, _name)"
            let _8 := datasize("ChildContractB_64")
            let _9 := add(_7, _8)
            if or(gt(_9, /** @src 0:921:2403  "contract InitNewChildTest {..." */ sub(shl(64, 1), 1)), /** @src 0:1469:1506  "new ChildContractB(msg.sender, _name)" */ lt(_9, _7))
            {
                /// @src 0:921:2403  "contract InitNewChildTest {..."
                mstore(/** @src -1:-1:-1 */ 0, /** @src 0:921:2403  "contract InitNewChildTest {..." */ shl(224, 0x4e487b71))
                mstore(4, 0x41)
                revert(/** @src -1:-1:-1 */ 0, /** @src 0:921:2403  "contract InitNewChildTest {..." */ 0x24)
            }
            /// @src 0:1469:1506  "new ChildContractB(msg.sender, _name)"
            datacopy(_7, dataoffset("ChildContractB_64"), _8)
            /// @src 0:921:2403  "contract InitNewChildTest {..."
            mstore(_9, /** @src 0:1317:1327  "msg.sender" */ caller())
            /// @src 0:921:2403  "contract InitNewChildTest {..."
            mstore(add(_9, 32), 64)
            let length_1 := mload(array)
            mstore(add(_9, 64), length_1)
            mcopy(add(_9, 96), dst, length_1)
            mstore(add(add(_9, length_1), 96), /** @src -1:-1:-1 */ 0)
            /// @src 0:1469:1506  "new ChildContractB(msg.sender, _name)"
            let expr_address_1 := create(/** @src -1:-1:-1 */ 0, /** @src 0:1469:1506  "new ChildContractB(msg.sender, _name)" */ _7, add(sub(/** @src 0:921:2403  "contract InitNewChildTest {..." */ add(_9, and(add(length_1, 0x1f), not(31))), /** @src 0:1469:1506  "new ChildContractB(msg.sender, _name)" */ _7), /** @src 0:921:2403  "contract InitNewChildTest {..." */ 96))
            /// @src 0:1469:1506  "new ChildContractB(msg.sender, _name)"
            if iszero(expr_address_1)
            {
                /// @src 0:921:2403  "contract InitNewChildTest {..."
                let pos_1 := mload(64)
                returndatacopy(pos_1, /** @src -1:-1:-1 */ 0, /** @src 0:921:2403  "contract InitNewChildTest {..." */ returndatasize())
                revert(pos_1, returndatasize())
            }
            /// @src 0:1452:1507  "childB = address(new ChildContractB(msg.sender, _name))"
            mstore(160, /** @src 0:921:2403  "contract InitNewChildTest {..." */ and(/** @src 0:1461:1507  "address(new ChildContractB(msg.sender, _name))" */ expr_address_1, /** @src 0:921:2403  "contract InitNewChildTest {..." */ sub(shl(160, 1), 1)))
            let product := shl(1, value)
            if iszero(or(iszero(value), eq(/** @src 0:1306:1327  "deployer = msg.sender" */ 0x02, /** @src 0:921:2403  "contract InitNewChildTest {..." */ div(product, value))))
            {
                mstore(/** @src -1:-1:-1 */ 0, /** @src 0:921:2403  "contract InitNewChildTest {..." */ shl(224, 0x4e487b71))
                mstore(4, 0x11)
                revert(/** @src -1:-1:-1 */ 0, /** @src 0:921:2403  "contract InitNewChildTest {..." */ 0x24)
            }
            /// @src 0:1588:1633  "new ChildContractA(address(this), _value * 2)"
            let _10 := /** @src 0:921:2403  "contract InitNewChildTest {..." */ mload(64)
            /// @src 0:1588:1633  "new ChildContractA(address(this), _value * 2)"
            let _11 := add(_10, _4)
            if or(gt(_11, /** @src 0:921:2403  "contract InitNewChildTest {..." */ sub(shl(64, 1), 1)), /** @src 0:1588:1633  "new ChildContractA(address(this), _value * 2)" */ lt(_11, _10))
            {
                /// @src 0:921:2403  "contract InitNewChildTest {..."
                mstore(/** @src -1:-1:-1 */ 0, /** @src 0:921:2403  "contract InitNewChildTest {..." */ shl(224, 0x4e487b71))
                mstore(4, 0x41)
                revert(/** @src -1:-1:-1 */ 0, /** @src 0:921:2403  "contract InitNewChildTest {..." */ 0x24)
            }
            /// @src 0:1588:1633  "new ChildContractA(address(this), _value * 2)"
            datacopy(_10, _6, _4)
            let expr_address_2 := create(/** @src -1:-1:-1 */ 0, /** @src 0:1588:1633  "new ChildContractA(address(this), _value * 2)" */ _10, sub(abi_encode_address_uint256(_11, /** @src 0:1427:1431  "this" */ address(), /** @src 0:1588:1633  "new ChildContractA(address(this), _value * 2)" */ product), _10))
            if iszero(expr_address_2)
            {
                /// @src 0:921:2403  "contract InitNewChildTest {..."
                let pos_2 := mload(64)
                returndatacopy(pos_2, /** @src -1:-1:-1 */ 0, /** @src 0:921:2403  "contract InitNewChildTest {..." */ returndatasize())
                revert(pos_2, returndatasize())
            }
            sstore(/** @src -1:-1:-1 */ 0, /** @src 0:921:2403  "contract InitNewChildTest {..." */ or(and(sload(/** @src -1:-1:-1 */ 0), /** @src 0:921:2403  "contract InitNewChildTest {..." */ not(sub(shl(160, 1), 1))), and(/** @src 0:1580:1634  "address(new ChildContractA(address(this), _value * 2))" */ expr_address_2, /** @src 0:921:2403  "contract InitNewChildTest {..." */ sub(shl(160, 1), 1))))
            let _12 := mload(64)
            let _13 := datasize("InitNewChildTest_204_deployed")
            codecopy(_12, dataoffset("InitNewChildTest_204_deployed"), _13)
            setimmutable(_12, "67", mload(/** @src 0:1383:1442  "childA = address(new ChildContractA(address(this), _value))" */ 128))
            /// @src 0:921:2403  "contract InitNewChildTest {..."
            setimmutable(_12, "69", mload(/** @src 0:1452:1507  "childB = address(new ChildContractB(msg.sender, _name))" */ 160))
            /// @src 0:921:2403  "contract InitNewChildTest {..."
            return(_12, _13)
        }
        function allocate_memory(size) -> memPtr
        {
            memPtr := mload(64)
            let newFreePtr := add(memPtr, and(add(size, 31), not(31)))
            if or(gt(newFreePtr, sub(shl(64, 1), 1)), lt(newFreePtr, memPtr))
            {
                mstore(/** @src -1:-1:-1 */ 0, /** @src 0:921:2403  "contract InitNewChildTest {..." */ shl(224, 0x4e487b71))
                mstore(4, 0x41)
                revert(/** @src -1:-1:-1 */ 0, /** @src 0:921:2403  "contract InitNewChildTest {..." */ 0x24)
            }
            mstore(64, newFreePtr)
        }
        function abi_encode_address_uint256(headStart, value0, value1) -> tail
        {
            tail := add(headStart, 64)
            mstore(headStart, and(value0, sub(shl(160, 1), 1)))
            mstore(add(headStart, 32), value1)
        }
    }
    /// @use-src 0:"src/init/InitNewChildTest.sol"
    object "InitNewChildTest_204_deployed" {
        code {
            {
                /// @src 0:921:2403  "contract InitNewChildTest {..."
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x20965255 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                        mstore(_1, sload(/** @src 0:1716:1721  "value" */ 0x01))
                        /// @src 0:921:2403  "contract InitNewChildTest {..."
                        return(_1, 32)
                    }
                    case 0x24b8adfe { external_fun_getChildA() }
                    case 0x3fa4f245 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                        let _2 := sload(/** @src 0:1167:1187  "uint256 public value" */ 1)
                        /// @src 0:921:2403  "contract InitNewChildTest {..."
                        let memPos := mload(64)
                        mstore(memPos, _2)
                        return(memPos, 32)
                    }
                    case 0x41c793ef { external_fun_getChildB() }
                    case 0x53282946 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                        let value := and(sload(0), 0xffffffffffffffffffffffffffffffffffffffff)
                        let memPos_1 := mload(64)
                        mstore(memPos_1, value)
                        return(memPos_1, 32)
                    }
                    case 0x5875993e { external_fun_getChildB() }
                    case 0x72630531 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                        let value_1 := and(sload(/** @src 0:2073:2081  "deployer" */ 0x02), /** @src 0:921:2403  "contract InitNewChildTest {..." */ 0xffffffffffffffffffffffffffffffffffffffff)
                        let memPos_2 := mload(64)
                        mstore(memPos_2, value_1)
                        return(memPos_2, 32)
                    }
                    case 0x87d2aa5f {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                        /// @src 0:2238:2270  "ChildContractA(childA).getInfo()"
                        let _3 := /** @src 0:921:2403  "contract InitNewChildTest {..." */ mload(64)
                        /// @src 0:2238:2270  "ChildContractA(childA).getInfo()"
                        mstore(_3, /** @src 0:921:2403  "contract InitNewChildTest {..." */ 0x5a9b0b8900000000000000000000000000000000000000000000000000000000)
                        /// @src 0:2238:2270  "ChildContractA(childA).getInfo()"
                        let _4 := staticcall(gas(), /** @src 0:921:2403  "contract InitNewChildTest {..." */ and(/** @src 0:2253:2259  "childA" */ loadimmutable("67"), /** @src 0:921:2403  "contract InitNewChildTest {..." */ 0xffffffffffffffffffffffffffffffffffffffff), /** @src 0:2238:2270  "ChildContractA(childA).getInfo()" */ _3, /** @src 0:921:2403  "contract InitNewChildTest {..." */ 4, /** @src 0:2238:2270  "ChildContractA(childA).getInfo()" */ _3, /** @src 0:921:2403  "contract InitNewChildTest {..." */ 64)
                        /// @src 0:2238:2270  "ChildContractA(childA).getInfo()"
                        if iszero(_4)
                        {
                            /// @src 0:921:2403  "contract InitNewChildTest {..."
                            let pos := mload(64)
                            returndatacopy(pos, 0, returndatasize())
                            revert(pos, returndatasize())
                        }
                        /// @src 0:2238:2270  "ChildContractA(childA).getInfo()"
                        let expr_component := /** @src 0:921:2403  "contract InitNewChildTest {..." */ 0
                        let expr_component_1 := 0
                        /// @src 0:2238:2270  "ChildContractA(childA).getInfo()"
                        if _4
                        {
                            let _5 := /** @src 0:921:2403  "contract InitNewChildTest {..." */ 64
                            /// @src 0:2238:2270  "ChildContractA(childA).getInfo()"
                            if gt(/** @src 0:921:2403  "contract InitNewChildTest {..." */ 64, /** @src 0:2238:2270  "ChildContractA(childA).getInfo()" */ returndatasize()) { _5 := returndatasize() }
                            finalize_allocation(_3, _5)
                            /// @src 0:921:2403  "contract InitNewChildTest {..."
                            if slt(sub(/** @src 0:2238:2270  "ChildContractA(childA).getInfo()" */ add(_3, _5), /** @src 0:921:2403  "contract InitNewChildTest {..." */ _3), 64) { revert(0, 0) }
                            let value_2 := mload(_3)
                            if iszero(eq(value_2, and(value_2, 0xffffffffffffffffffffffffffffffffffffffff))) { revert(0, 0) }
                            let value_3 := mload(add(_3, 32))
                            /// @src 0:2238:2270  "ChildContractA(childA).getInfo()"
                            expr_component := value_2
                            expr_component_1 := value_3
                        }
                        /// @src 0:921:2403  "contract InitNewChildTest {..."
                        let memPos_3 := mload(64)
                        mstore(memPos_3, and(expr_component, 0xffffffffffffffffffffffffffffffffffffffff))
                        mstore(add(memPos_3, 32), expr_component_1)
                        return(memPos_3, 64)
                    }
                    case 0xa69b8951 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                        /// @src 0:2362:2394  "ChildContractB(childB).getName()"
                        let _6 := /** @src 0:921:2403  "contract InitNewChildTest {..." */ mload(64)
                        /// @src 0:2362:2394  "ChildContractB(childB).getName()"
                        mstore(_6, /** @src 0:921:2403  "contract InitNewChildTest {..." */ 0x17d7de7c00000000000000000000000000000000000000000000000000000000)
                        /// @src 0:2362:2394  "ChildContractB(childB).getName()"
                        let _7 := staticcall(gas(), /** @src 0:921:2403  "contract InitNewChildTest {..." */ and(/** @src 0:2377:2383  "childB" */ loadimmutable("69"), /** @src 0:921:2403  "contract InitNewChildTest {..." */ 0xffffffffffffffffffffffffffffffffffffffff), /** @src 0:2362:2394  "ChildContractB(childB).getName()" */ _6, /** @src 0:921:2403  "contract InitNewChildTest {..." */ 4, /** @src 0:2362:2394  "ChildContractB(childB).getName()" */ _6, /** @src 0:921:2403  "contract InitNewChildTest {..." */ 0)
                        /// @src 0:2362:2394  "ChildContractB(childB).getName()"
                        if iszero(_7)
                        {
                            /// @src 0:921:2403  "contract InitNewChildTest {..."
                            let pos_1 := mload(64)
                            returndatacopy(pos_1, 0, returndatasize())
                            revert(pos_1, returndatasize())
                        }
                        /// @src 0:2362:2394  "ChildContractB(childB).getName()"
                        let expr_mpos := /** @src 0:921:2403  "contract InitNewChildTest {..." */ 0
                        /// @src 0:2362:2394  "ChildContractB(childB).getName()"
                        if _7
                        {
                            let _8 := returndatasize()
                            returndatacopy(_6, /** @src 0:921:2403  "contract InitNewChildTest {..." */ 0, /** @src 0:2362:2394  "ChildContractB(childB).getName()" */ _8)
                            finalize_allocation(_6, _8)
                            let _9 := add(_6, _8)
                            /// @src 0:921:2403  "contract InitNewChildTest {..."
                            if slt(sub(_9, _6), 32) { revert(0, 0) }
                            let offset := mload(_6)
                            if gt(offset, 0xffffffffffffffff) { revert(0, 0) }
                            let _10 := add(_6, offset)
                            if iszero(slt(add(_10, 0x1f), _9)) { revert(0, 0) }
                            let length := mload(_10)
                            if gt(length, 0xffffffffffffffff)
                            {
                                mstore(0, 35408467139433450592217433187231851964531694900788300625387963629091585785856)
                                mstore(4, 0x41)
                                revert(0, 0x24)
                            }
                            let memPtr := mload(64)
                            finalize_allocation(memPtr, add(and(add(length, 0x1f), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0), 32))
                            mstore(memPtr, length)
                            if gt(add(add(_10, length), 32), _9) { revert(0, 0) }
                            mcopy(add(memPtr, 32), add(_10, 32), length)
                            mstore(add(add(memPtr, length), 32), 0)
                            /// @src 0:2362:2394  "ChildContractB(childB).getName()"
                            expr_mpos := memPtr
                        }
                        /// @src 0:921:2403  "contract InitNewChildTest {..."
                        let memPos_4 := mload(64)
                        mstore(memPos_4, 32)
                        let length_1 := mload(expr_mpos)
                        mstore(add(memPos_4, 32), length_1)
                        mcopy(add(memPos_4, 64), add(expr_mpos, 32), length_1)
                        mstore(add(add(memPos_4, length_1), 64), 0)
                        return(memPos_4, add(sub(add(memPos_4, and(add(length_1, 31), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0)), memPos_4), 64))
                    }
                    case 0xc1de7661 { external_fun_getChildA() }
                    case 0xd5f39488 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                        let value_4 := and(sload(/** @src 0:1193:1216  "address public deployer" */ 2), /** @src 0:921:2403  "contract InitNewChildTest {..." */ 0xffffffffffffffffffffffffffffffffffffffff)
                        let memPos_5 := mload(64)
                        mstore(memPos_5, value_4)
                        return(memPos_5, 32)
                    }
                    case 0xdb8ac47a {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                        let value_5 := and(sload(0), 0xffffffffffffffffffffffffffffffffffffffff)
                        let memPos_6 := mload(64)
                        mstore(memPos_6, value_5)
                        return(memPos_6, 32)
                    }
                }
                revert(0, 0)
            }
            function external_fun_getChildA()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                let memPos := mload(64)
                mstore(memPos, and(/** @src 0:1804:1810  "childA" */ loadimmutable("67"), /** @src 0:921:2403  "contract InitNewChildTest {..." */ 0xffffffffffffffffffffffffffffffffffffffff))
                return(memPos, 32)
            }
            function external_fun_getChildB()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                let memPos := mload(64)
                mstore(memPos, and(/** @src 0:1893:1899  "childB" */ loadimmutable("69"), /** @src 0:921:2403  "contract InitNewChildTest {..." */ 0xffffffffffffffffffffffffffffffffffffffff))
                return(memPos, 32)
            }
            function finalize_allocation(memPtr, size)
            {
                let newFreePtr := add(memPtr, and(add(size, 31), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0))
                if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr))
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:921:2403  "contract InitNewChildTest {..." */ 35408467139433450592217433187231851964531694900788300625387963629091585785856)
                    mstore(4, 0x41)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:921:2403  "contract InitNewChildTest {..." */ 0x24)
                }
                mstore(64, newFreePtr)
            }
        }
        data ".metadata" hex"a164736f6c634300081e000a"
    }
    /// @use-src 0:"src/init/InitNewChildTest.sol"
    object "ChildContractA_35" {
        code {
            {
                /// @src 0:248:541  "contract ChildContractA {..."
                let _1 := memoryguard(0x80)
                if callvalue() { revert(0, 0) }
                let programSize := datasize("ChildContractA_35")
                let argSize := sub(codesize(), programSize)
                let newFreePtr := add(_1, and(add(argSize, 31), not(31)))
                if or(gt(newFreePtr, sub(shl(64, 1), 1)), lt(newFreePtr, _1))
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:248:541  "contract ChildContractA {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x41)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:248:541  "contract ChildContractA {..." */ 0x24)
                }
                mstore(64, newFreePtr)
                codecopy(_1, programSize, argSize)
                if slt(sub(add(_1, argSize), _1), 64)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:248:541  "contract ChildContractA {..."
                let value := mload(_1)
                let _2 := and(value, sub(shl(160, 1), 1))
                if iszero(eq(value, _2))
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:248:541  "contract ChildContractA {..."
                let value_1 := mload(add(_1, 32))
                sstore(/** @src -1:-1:-1 */ 0, /** @src 0:248:541  "contract ChildContractA {..." */ or(and(sload(/** @src -1:-1:-1 */ 0), /** @src 0:248:541  "contract ChildContractA {..." */ not(sub(shl(160, 1), 1))), _2))
                sstore(1, value_1)
                let _3 := mload(64)
                let _4 := datasize("ChildContractA_35_deployed")
                codecopy(_3, dataoffset("ChildContractA_35_deployed"), _4)
                return(_3, _4)
            }
        }
        /// @use-src 0:"src/init/InitNewChildTest.sol"
        object "ChildContractA_35_deployed" {
            code {
                {
                    /// @src 0:248:541  "contract ChildContractA {..."
                    let _1 := memoryguard(0x80)
                    mstore(64, _1)
                    if iszero(lt(calldatasize(), 4))
                    {
                        switch shr(224, calldataload(0))
                        case 0x3fa4f245 {
                            if callvalue() { revert(0, 0) }
                            if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                            mstore(_1, sload(/** @src 0:305:325  "uint256 public value" */ 1))
                            /// @src 0:248:541  "contract ChildContractA {..."
                            return(_1, 32)
                        }
                        case 0x5a9b0b89 {
                            if callvalue() { revert(0, 0) }
                            if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                            let value := and(sload(0), 0xffffffffffffffffffffffffffffffffffffffff)
                            let _2 := sload(/** @src 0:526:531  "value" */ 0x01)
                            /// @src 0:248:541  "contract ChildContractA {..."
                            let memPos := mload(64)
                            mstore(memPos, value)
                            mstore(add(memPos, 32), _2)
                            return(memPos, 64)
                        }
                        case 0x60f96a8f {
                            if callvalue() { revert(0, 0) }
                            if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                            let value_1 := and(sload(0), 0xffffffffffffffffffffffffffffffffffffffff)
                            let memPos_1 := mload(64)
                            mstore(memPos_1, value_1)
                            return(memPos_1, 32)
                        }
                    }
                    revert(0, 0)
                }
            }
            data ".metadata" hex"a164736f6c634300081e000a"
        }
    }
    /// @use-src 0:"src/init/InitNewChildTest.sol"
    object "ChildContractB_64" {
        code {
            {
                /// @src 0:543:819  "contract ChildContractB {..."
                mstore(64, memoryguard(0x80))
                if callvalue() { revert(0, 0) }
                let programSize := datasize("ChildContractB_64")
                let argSize := sub(codesize(), programSize)
                let memoryDataOffset := allocate_memory(argSize)
                codecopy(memoryDataOffset, programSize, argSize)
                let _1 := add(memoryDataOffset, argSize)
                if slt(sub(_1, memoryDataOffset), 64)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:543:819  "contract ChildContractB {..."
                let value := mload(memoryDataOffset)
                let _2 := and(value, sub(shl(160, 1), 1))
                if iszero(eq(value, _2))
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:543:819  "contract ChildContractB {..."
                let offset := mload(add(memoryDataOffset, 32))
                if gt(offset, sub(shl(64, 1), 1))
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:543:819  "contract ChildContractB {..."
                let _3 := add(memoryDataOffset, offset)
                if iszero(slt(add(_3, 0x1f), _1))
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:543:819  "contract ChildContractB {..."
                let length := mload(_3)
                if gt(length, sub(shl(64, 1), 1))
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:543:819  "contract ChildContractB {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x41)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:543:819  "contract ChildContractB {..." */ 0x24)
                }
                let array := allocate_memory(add(and(add(length, 0x1f), not(31)), 32))
                mstore(array, length)
                if gt(add(add(_3, length), 32), _1)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:543:819  "contract ChildContractB {..."
                mcopy(add(array, 32), add(_3, 32), length)
                mstore(add(add(array, length), 32), /** @src -1:-1:-1 */ 0)
                /// @src 0:543:819  "contract ChildContractB {..."
                sstore(/** @src -1:-1:-1 */ 0, /** @src 0:543:819  "contract ChildContractB {..." */ or(and(sload(/** @src -1:-1:-1 */ 0), /** @src 0:543:819  "contract ChildContractB {..." */ not(sub(shl(160, 1), 1))), _2))
                let newLen := mload(array)
                if gt(newLen, sub(shl(64, 1), 1))
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:543:819  "contract ChildContractB {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x41)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:543:819  "contract ChildContractB {..." */ 0x24)
                }
                let _4 := sload(/** @src 0:707:719  "name = _name" */ 0x01)
                /// @src 0:543:819  "contract ChildContractB {..."
                let length_1 := /** @src -1:-1:-1 */ 0
                /// @src 0:543:819  "contract ChildContractB {..."
                length_1 := shr(/** @src 0:707:719  "name = _name" */ 0x01, /** @src 0:543:819  "contract ChildContractB {..." */ _4)
                let outOfPlaceEncoding := and(_4, /** @src 0:707:719  "name = _name" */ 0x01)
                /// @src 0:543:819  "contract ChildContractB {..."
                if iszero(outOfPlaceEncoding)
                {
                    length_1 := and(length_1, 0x7f)
                }
                if eq(outOfPlaceEncoding, lt(length_1, 32))
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:543:819  "contract ChildContractB {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x22)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:543:819  "contract ChildContractB {..." */ 0x24)
                }
                if gt(length_1, 0x1f)
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:707:719  "name = _name" */ 0x01)
                    /// @src 0:543:819  "contract ChildContractB {..."
                    let data := keccak256(/** @src -1:-1:-1 */ 0, /** @src 0:543:819  "contract ChildContractB {..." */ 32)
                    let deleteStart := add(data, shr(5, add(newLen, 0x1f)))
                    if lt(newLen, 32) { deleteStart := data }
                    let _5 := add(data, shr(5, add(length_1, 0x1f)))
                    let start := deleteStart
                    for { }
                    lt(start, _5)
                    {
                        start := add(start, /** @src 0:707:719  "name = _name" */ 0x01)
                    }
                    /// @src 0:543:819  "contract ChildContractB {..."
                    {
                        sstore(start, /** @src -1:-1:-1 */ 0)
                    }
                }
                /// @src 0:543:819  "contract ChildContractB {..."
                let srcOffset := /** @src -1:-1:-1 */ 0
                /// @src 0:543:819  "contract ChildContractB {..."
                srcOffset := 32
                switch gt(newLen, 0x1f)
                case 1 {
                    let loopEnd := and(newLen, not(31))
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:707:719  "name = _name" */ 0x01)
                    /// @src 0:543:819  "contract ChildContractB {..."
                    let dstPtr := keccak256(/** @src -1:-1:-1 */ 0, /** @src 0:543:819  "contract ChildContractB {..." */ srcOffset)
                    let i := /** @src -1:-1:-1 */ 0
                    /// @src 0:543:819  "contract ChildContractB {..."
                    for { } lt(i, loopEnd) { i := add(i, 32) }
                    {
                        sstore(dstPtr, mload(add(array, srcOffset)))
                        dstPtr := add(dstPtr, /** @src 0:707:719  "name = _name" */ 0x01)
                        /// @src 0:543:819  "contract ChildContractB {..."
                        srcOffset := add(srcOffset, 32)
                    }
                    if lt(loopEnd, newLen)
                    {
                        let lastValue := mload(add(array, srcOffset))
                        sstore(dstPtr, and(lastValue, not(shr(and(shl(3, newLen), 248), not(0)))))
                    }
                    sstore(/** @src 0:707:719  "name = _name" */ 0x01, /** @src 0:543:819  "contract ChildContractB {..." */ add(shl(/** @src 0:707:719  "name = _name" */ 0x01, /** @src 0:543:819  "contract ChildContractB {..." */ newLen), /** @src 0:707:719  "name = _name" */ 0x01))
                }
                default /// @src 0:543:819  "contract ChildContractB {..."
                {
                    let value_1 := /** @src -1:-1:-1 */ 0
                    /// @src 0:543:819  "contract ChildContractB {..."
                    if newLen
                    {
                        value_1 := mload(add(array, srcOffset))
                    }
                    sstore(/** @src 0:707:719  "name = _name" */ 0x01, /** @src 0:543:819  "contract ChildContractB {..." */ or(and(value_1, not(shr(shl(3, newLen), not(0)))), shl(/** @src 0:707:719  "name = _name" */ 0x01, /** @src 0:543:819  "contract ChildContractB {..." */ newLen)))
                }
                let _6 := mload(64)
                let _7 := datasize("ChildContractB_64_deployed")
                codecopy(_6, dataoffset("ChildContractB_64_deployed"), _7)
                return(_6, _7)
            }
            function allocate_memory(size) -> memPtr
            {
                memPtr := mload(64)
                let newFreePtr := add(memPtr, and(add(size, 31), not(31)))
                if or(gt(newFreePtr, sub(shl(64, 1), 1)), lt(newFreePtr, memPtr))
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:543:819  "contract ChildContractB {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x41)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:543:819  "contract ChildContractB {..." */ 0x24)
                }
                mstore(64, newFreePtr)
            }
        }
        /// @use-src 0:"src/init/InitNewChildTest.sol"
        object "ChildContractB_64_deployed" {
            code {
                {
                    /// @src 0:543:819  "contract ChildContractB {..."
                    mstore(64, memoryguard(0x80))
                    if iszero(lt(calldatasize(), 4))
                    {
                        switch shr(224, calldataload(0))
                        case 0x06fdde03 {
                            if callvalue() { revert(0, 0) }
                            if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                            let value := copy_array_from_storage_to_memory_string()
                            let memPos := mload(64)
                            return(memPos, sub(abi_encode_string(memPos, value), memPos))
                        }
                        case 0x17d7de7c {
                            if callvalue() { revert(0, 0) }
                            if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                            let converted := copy_array_from_storage_to_memory_string()
                            let memPos_1 := mload(64)
                            return(memPos_1, sub(abi_encode_string(memPos_1, converted), memPos_1))
                        }
                        case 0x8da5cb5b {
                            if callvalue() { revert(0, 0) }
                            if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                            let value_1 := and(sload(0), 0xffffffffffffffffffffffffffffffffffffffff)
                            let memPos_2 := mload(64)
                            mstore(memPos_2, value_1)
                            return(memPos_2, 32)
                        }
                    }
                    revert(0, 0)
                }
                function copy_array_from_storage_to_memory_string() -> memPtr
                {
                    memPtr := mload(64)
                    let ret := /** @src -1:-1:-1 */ 0
                    /// @src 0:543:819  "contract ChildContractB {..."
                    let slotValue := sload(/** @src 0:599:617  "string public name" */ 1)
                    /// @src 0:543:819  "contract ChildContractB {..."
                    let length := /** @src -1:-1:-1 */ 0
                    /// @src 0:543:819  "contract ChildContractB {..."
                    length := shr(/** @src 0:599:617  "string public name" */ 1, /** @src 0:543:819  "contract ChildContractB {..." */ slotValue)
                    let outOfPlaceEncoding := and(slotValue, /** @src 0:599:617  "string public name" */ 1)
                    /// @src 0:543:819  "contract ChildContractB {..."
                    if iszero(outOfPlaceEncoding) { length := and(length, 0x7f) }
                    if eq(outOfPlaceEncoding, lt(length, 32))
                    {
                        mstore(/** @src -1:-1:-1 */ 0, /** @src 0:543:819  "contract ChildContractB {..." */ 35408467139433450592217433187231851964531694900788300625387963629091585785856)
                        mstore(4, 0x22)
                        revert(/** @src -1:-1:-1 */ 0, /** @src 0:543:819  "contract ChildContractB {..." */ 0x24)
                    }
                    mstore(memPtr, length)
                    switch outOfPlaceEncoding
                    case 0 {
                        mstore(add(memPtr, 32), and(slotValue, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00))
                        ret := add(add(memPtr, shl(5, iszero(iszero(length)))), 32)
                    }
                    case 1 {
                        mstore(/** @src -1:-1:-1 */ 0, /** @src 0:599:617  "string public name" */ 1)
                        /// @src 0:543:819  "contract ChildContractB {..."
                        let dataPos := keccak256(/** @src -1:-1:-1 */ 0, /** @src 0:543:819  "contract ChildContractB {..." */ 32)
                        let i := /** @src -1:-1:-1 */ 0
                        /// @src 0:543:819  "contract ChildContractB {..."
                        for { } lt(i, length) { i := add(i, 32) }
                        {
                            mstore(add(add(memPtr, i), 32), sload(dataPos))
                            dataPos := add(dataPos, /** @src 0:599:617  "string public name" */ 1)
                        }
                        /// @src 0:543:819  "contract ChildContractB {..."
                        ret := add(add(memPtr, i), 32)
                    }
                    let newFreePtr := add(memPtr, and(add(sub(ret, memPtr), 31), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0))
                    if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr))
                    {
                        mstore(/** @src -1:-1:-1 */ 0, /** @src 0:543:819  "contract ChildContractB {..." */ 35408467139433450592217433187231851964531694900788300625387963629091585785856)
                        mstore(4, 0x41)
                        revert(/** @src -1:-1:-1 */ 0, /** @src 0:543:819  "contract ChildContractB {..." */ 0x24)
                    }
                    mstore(64, newFreePtr)
                }
                function abi_encode_string(headStart, value0) -> tail
                {
                    mstore(headStart, 32)
                    let length := mload(value0)
                    mstore(add(headStart, 32), length)
                    mcopy(add(headStart, 64), add(value0, 32), length)
                    mstore(add(add(headStart, length), 64), 0)
                    tail := add(add(headStart, and(add(length, 31), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0)), 64)
                }
            }
            data ".metadata" hex"a164736f6c634300081e000a"
        }
    }
}

