object "Modifiers_490" {
    code {
        {
            /// @src 0:160:6215  "contract Modifiers {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            sstore(/** @src 0:650:668  "owner = msg.sender" */ 0x00, /** @src 0:160:6215  "contract Modifiers {..." */ or(and(sload(/** @src 0:650:668  "owner = msg.sender" */ 0x00), /** @src 0:160:6215  "contract Modifiers {..." */ not(sub(shl(160, 1), 1))), /** @src 0:658:668  "msg.sender" */ caller()))
            /// @src 0:160:6215  "contract Modifiers {..."
            mstore(/** @src 0:650:668  "owner = msg.sender" */ 0x00, /** @src 0:658:668  "msg.sender" */ caller())
            /// @src 0:160:6215  "contract Modifiers {..."
            mstore(0x20, /** @src 0:678:684  "admins" */ 0x02)
            /// @src 0:160:6215  "contract Modifiers {..."
            let dataSlot := keccak256(/** @src 0:650:668  "owner = msg.sender" */ 0x00, /** @src 0:160:6215  "contract Modifiers {..." */ 64)
            sstore(dataSlot, or(and(sload(dataSlot), not(255)), /** @src 0:699:703  "true" */ 0x01))
            /// @src 0:160:6215  "contract Modifiers {..."
            let _2 := datasize("Modifiers_490_deployed")
            codecopy(_1, dataoffset("Modifiers_490_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/bench/Modifiers.sol"
    object "Modifiers_490_deployed" {
        code {
            {
                /// @src 0:160:6215  "contract Modifiers {..."
                mstore(64, memoryguard(0x80))
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x07d226bd {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _1 := sload(/** @src 0:1700:1707  "counter" */ 0x01)
                        /// @src 0:4301:4310  "counter++"
                        let _2 := increment_uint256(/** @src 0:160:6215  "contract Modifiers {..." */ _1)
                        sstore(/** @src 0:1700:1707  "counter" */ 0x01, /** @src 0:160:6215  "contract Modifiers {..." */ _2)
                        let sum := add(_1, /** @src 0:1700:1707  "counter" */ 0x01)
                        /// @src 0:160:6215  "contract Modifiers {..."
                        if gt(_1, sum)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        /// @src 0:1728:1781  "require(counter == before + 1, \"Reentrancy detected\")"
                        require_helper_stringliteral(/** @src 0:1736:1757  "counter == before + 1" */ eq(_2, sum))
                        /// @src 0:160:6215  "contract Modifiers {..."
                        return(0, 0)
                    }
                    case 0x085f4b05 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _3 := sload(0)
                        /// @src 0:832:874  "if (msg.sender != owner) revert NotOwner()"
                        if /** @src 0:836:855  "msg.sender != owner" */ iszero(eq(/** @src 0:836:846  "msg.sender" */ caller(), /** @src 0:160:6215  "contract Modifiers {..." */ and(_3, sub(shl(160, 1), 1))))
                        /// @src 0:832:874  "if (msg.sender != owner) revert NotOwner()"
                        {
                            /// @src 0:864:874  "NotOwner()"
                            mstore(/** @src 0:160:6215  "contract Modifiers {..." */ 0, /** @src 0:864:874  "NotOwner()" */ shl(224, 0x30cd7471))
                            revert(/** @src 0:160:6215  "contract Modifiers {..." */ 0, 4)
                        }
                        /// @src 0:1096:1123  "if (paused) revert Paused()"
                        if /** @src 0:160:6215  "contract Modifiers {..." */ and(shr(160, _3), 0xff)
                        /// @src 0:1096:1123  "if (paused) revert Paused()"
                        {
                            /// @src 0:1115:1123  "Paused()"
                            mstore(/** @src 0:160:6215  "contract Modifiers {..." */ 0, /** @src 0:1115:1123  "Paused()" */ shl(227, 0x13d0ff59))
                            revert(/** @src 0:160:6215  "contract Modifiers {..." */ 0, 4)
                        }
                        let _4 := sload(/** @src 0:1700:1707  "counter" */ 0x01)
                        /// @src 0:160:6215  "contract Modifiers {..."
                        let memPtr := 0
                        let size := 0
                        size := 0
                        let memPtr_1 := mload(64)
                        let newFreePtr := add(memPtr_1, 64)
                        if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr_1))
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x41)
                            revert(0, 0x24)
                        }
                        mstore(64, newFreePtr)
                        memPtr := memPtr_1
                        mstore(memPtr_1, 4)
                        mstore(add(memPtr_1, 32), "full")
                        /// @src 0:1880:1902  "GuardTriggered(action)"
                        let _5 := /** @src 0:160:6215  "contract Modifiers {..." */ mload(64)
                        /// @src 0:1880:1902  "GuardTriggered(action)"
                        log1(_5, sub(abi_encode_string(_5, memPtr_1), _5), 0x0ab8476427dc967cd4151b39f5b46551fe823303177494fd5e4e052ea40f2dd6)
                        /// @src 0:4301:4310  "counter++"
                        let _6 := increment_uint256(/** @src 0:160:6215  "contract Modifiers {..." */ _4)
                        sstore(/** @src 0:1700:1707  "counter" */ 0x01, /** @src 0:160:6215  "contract Modifiers {..." */ _6)
                        /// @src 0:1928:1963  "ActionPerformed(msg.sender, action)"
                        let _7 := /** @src 0:160:6215  "contract Modifiers {..." */ mload(64)
                        /// @src 0:1928:1963  "ActionPerformed(msg.sender, action)"
                        log2(_7, sub(abi_encode_string(_7, memPtr_1), _7), 0xe0e2450862980d2d725d0eaff08ee369b5c951ad7f60c0214d8a068f7a501c45, /** @src 0:836:846  "msg.sender" */ caller())
                        /// @src 0:160:6215  "contract Modifiers {..."
                        let sum_1 := add(_4, /** @src 0:1700:1707  "counter" */ 0x01)
                        /// @src 0:160:6215  "contract Modifiers {..."
                        if gt(_4, sum_1)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        /// @src 0:1728:1781  "require(counter == before + 1, \"Reentrancy detected\")"
                        require_helper_stringliteral(/** @src 0:1736:1757  "counter == before + 1" */ eq(_6, sum_1))
                        /// @src 0:160:6215  "contract Modifiers {..."
                        return(0, 0)
                    }
                    case 0x0887573d {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value := calldataload(4)
                        if iszero(eq(value, iszero(iszero(value)))) { revert(0, 0) }
                        /// @src 0:2697:2738  "if (shouldRun) {..."
                        if value
                        {
                            /// @src 0:160:6215  "contract Modifiers {..."
                            let _8 := sload(/** @src 0:5798:5811  "counter += 50" */ 0x01)
                            /// @src 0:160:6215  "contract Modifiers {..."
                            let sum_2 := add(_8, /** @src 0:5809:5811  "50" */ 0x32)
                            /// @src 0:160:6215  "contract Modifiers {..."
                            if gt(_8, sum_2)
                            {
                                mstore(0, shl(224, 0x4e487b71))
                                mstore(4, 0x11)
                                revert(0, 0x24)
                            }
                            sstore(/** @src 0:5798:5811  "counter += 50" */ 0x01, /** @src 0:160:6215  "contract Modifiers {..." */ sum_2)
                        }
                        return(0, 0)
                    }
                    case 0x13820d6a {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _9 := sload(/** @src 0:2310:2317  "counter" */ 0x01)
                        /// @src 0:160:6215  "contract Modifiers {..."
                        let sum_3 := add(_9, /** @src 0:5444:5446  "10" */ 0x0a)
                        /// @src 0:160:6215  "contract Modifiers {..."
                        if gt(_9, sum_3)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        sstore(/** @src 0:2310:2317  "counter" */ 0x01, /** @src 0:160:6215  "contract Modifiers {..." */ sum_3)
                        /// @src 0:2338:2390  "require(counter > preValue, \"Counter must increase\")"
                        require_helper_stringliteral_13c0(/** @src 0:2346:2364  "counter > preValue" */ gt(sum_3, _9))
                        /// @src 0:160:6215  "contract Modifiers {..."
                        return(0, 0)
                    }
                    case 0x13af4035 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value_1 := calldataload(4)
                        let _10 := and(value_1, sub(shl(160, 1), 1))
                        if iszero(eq(value_1, _10)) { revert(0, 0) }
                        let _11 := sload(0)
                        /// @src 0:832:874  "if (msg.sender != owner) revert NotOwner()"
                        if /** @src 0:836:855  "msg.sender != owner" */ iszero(eq(/** @src 0:836:846  "msg.sender" */ caller(), /** @src 0:160:6215  "contract Modifiers {..." */ and(_11, sub(shl(160, 1), 1))))
                        /// @src 0:832:874  "if (msg.sender != owner) revert NotOwner()"
                        {
                            /// @src 0:864:874  "NotOwner()"
                            mstore(/** @src 0:160:6215  "contract Modifiers {..." */ 0, /** @src 0:864:874  "NotOwner()" */ shl(224, 0x30cd7471))
                            revert(/** @src 0:160:6215  "contract Modifiers {..." */ 0, 4)
                        }
                        sstore(0, or(and(_11, shl(160, 0xffffffffffffffffffffffff)), _10))
                        return(0, 0)
                    }
                    case 0x16c38b3c {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value_2 := calldataload(4)
                        let _12 := iszero(iszero(value_2))
                        if iszero(eq(value_2, _12)) { revert(0, 0) }
                        let _13 := sload(0)
                        /// @src 0:832:874  "if (msg.sender != owner) revert NotOwner()"
                        if /** @src 0:836:855  "msg.sender != owner" */ iszero(eq(/** @src 0:836:846  "msg.sender" */ caller(), /** @src 0:160:6215  "contract Modifiers {..." */ and(_13, sub(shl(160, 1), 1))))
                        /// @src 0:832:874  "if (msg.sender != owner) revert NotOwner()"
                        {
                            /// @src 0:864:874  "NotOwner()"
                            mstore(/** @src 0:160:6215  "contract Modifiers {..." */ 0, /** @src 0:864:874  "NotOwner()" */ shl(224, 0x30cd7471))
                            revert(/** @src 0:160:6215  "contract Modifiers {..." */ 0, 4)
                        }
                        sstore(0, or(and(_13, not(shl(160, 255))), and(shl(160, _12), shl(160, 255))))
                        return(0, 0)
                    }
                    case 0x1785f53c {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value_3 := calldataload(4)
                        let _14 := and(value_3, sub(shl(160, 1), 1))
                        if iszero(eq(value_3, _14)) { revert(0, 0) }
                        /// @src 0:832:874  "if (msg.sender != owner) revert NotOwner()"
                        if /** @src 0:836:855  "msg.sender != owner" */ iszero(eq(/** @src 0:836:846  "msg.sender" */ caller(), /** @src 0:160:6215  "contract Modifiers {..." */ and(sload(0), sub(shl(160, 1), 1))))
                        /// @src 0:832:874  "if (msg.sender != owner) revert NotOwner()"
                        {
                            /// @src 0:864:874  "NotOwner()"
                            mstore(/** @src 0:160:6215  "contract Modifiers {..." */ 0, /** @src 0:864:874  "NotOwner()" */ shl(224, 0x30cd7471))
                            revert(/** @src 0:160:6215  "contract Modifiers {..." */ 0, 4)
                        }
                        mstore(0, _14)
                        mstore(32, /** @src 0:3404:3410  "admins" */ 0x02)
                        /// @src 0:160:6215  "contract Modifiers {..."
                        let dataSlot := keccak256(0, 64)
                        sstore(dataSlot, and(sload(dataSlot), not(255)))
                        return(0, 0)
                    }
                    case 0x1865c57d {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _15 := sload(0)
                        let _16 := sload(/** @src 0:5035:5042  "counter" */ 0x01)
                        /// @src 0:160:6215  "contract Modifiers {..."
                        let memPos := mload(64)
                        mstore(memPos, and(_15, sub(shl(160, 1), 1)))
                        mstore(add(memPos, 32), iszero(iszero(and(shr(160, _15), 0xff))))
                        mstore(add(memPos, 64), _16)
                        return(memPos, 96)
                    }
                    case 0x290b487b {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _17 := sload(/** @src 0:2310:2317  "counter" */ 0x01)
                        /// @src 0:160:6215  "contract Modifiers {..."
                        let sum_4 := add(_17, /** @src 0:6146:6147  "7" */ 0x07)
                        /// @src 0:160:6215  "contract Modifiers {..."
                        if gt(_17, sum_4)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        /// @src 0:2338:2390  "require(counter > preValue, \"Counter must increase\")"
                        require_helper_stringliteral_13c0(/** @src 0:2346:2364  "counter > preValue" */ gt(sum_4, _17))
                        /// @src 0:160:6215  "contract Modifiers {..."
                        let sum_5 := add(_17, 1007)
                        if gt(sum_4, sum_5)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        sstore(/** @src 0:2310:2317  "counter" */ 0x01, /** @src 0:160:6215  "contract Modifiers {..." */ sum_5)
                        return(0, 0)
                    }
                    case 0x2fd415b2 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        mstore(0, /** @src 0:976:986  "msg.sender" */ caller())
                        /// @src 0:160:6215  "contract Modifiers {..."
                        mstore(0x20, /** @src 0:969:975  "admins" */ 0x02)
                        /// @src 0:964:1006  "if (!admins[msg.sender]) revert NotAdmin()"
                        if /** @src 0:968:987  "!admins[msg.sender]" */ iszero(/** @src 0:160:6215  "contract Modifiers {..." */ and(sload(keccak256(0, 64)), 0xff))
                        /// @src 0:964:1006  "if (!admins[msg.sender]) revert NotAdmin()"
                        {
                            /// @src 0:996:1006  "NotAdmin()"
                            mstore(/** @src 0:160:6215  "contract Modifiers {..." */ 0, /** @src 0:996:1006  "NotAdmin()" */ shl(224, 0x7bfa4b9f))
                            revert(/** @src 0:160:6215  "contract Modifiers {..." */ 0, 4)
                        }
                        /// @src 0:1096:1123  "if (paused) revert Paused()"
                        if /** @src 0:160:6215  "contract Modifiers {..." */ and(shr(160, sload(0)), 0xff)
                        /// @src 0:1096:1123  "if (paused) revert Paused()"
                        {
                            /// @src 0:1115:1123  "Paused()"
                            mstore(/** @src 0:160:6215  "contract Modifiers {..." */ 0, /** @src 0:1115:1123  "Paused()" */ shl(227, 0x13d0ff59))
                            revert(/** @src 0:160:6215  "contract Modifiers {..." */ 0, 4)
                        }
                        sstore(/** @src 0:3583:3592  "counter++" */ 0x01, increment_uint256(/** @src 0:160:6215  "contract Modifiers {..." */ sload(/** @src 0:3583:3592  "counter++" */ 0x01)))
                        /// @src 0:160:6215  "contract Modifiers {..."
                        let memPos_1 := mload(64)
                        mstore(memPos_1, /** @src 0:3583:3592  "counter++" */ 0x01)
                        /// @src 0:160:6215  "contract Modifiers {..."
                        return(memPos_1, 0x20)
                    }
                    case 0x32408f41 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _18 := sload(/** @src 0:5272:5284  "counter += 5" */ 0x01)
                        /// @src 0:160:6215  "contract Modifiers {..."
                        let sum_6 := add(_18, /** @src 0:5283:5284  "5" */ 0x05)
                        /// @src 0:160:6215  "contract Modifiers {..."
                        if gt(_18, sum_6)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        let sum_7 := add(_18, 1005)
                        if gt(sum_6, sum_7)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        sstore(/** @src 0:5272:5284  "counter += 5" */ 0x01, /** @src 0:160:6215  "contract Modifiers {..." */ sum_7)
                        return(0, 0)
                    }
                    case 0x429b62e5 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value_4 := calldataload(4)
                        let _19 := and(value_4, sub(shl(160, 1), 1))
                        if iszero(eq(value_4, _19)) { revert(0, 0) }
                        mstore(0, _19)
                        mstore(32, /** @src 0:298:336  "mapping(address => bool) public admins" */ 2)
                        /// @src 0:160:6215  "contract Modifiers {..."
                        let value_5 := and(sload(keccak256(0, 64)), 0xff)
                        let memPos_2 := mload(64)
                        mstore(memPos_2, iszero(iszero(value_5)))
                        return(memPos_2, 32)
                    }
                    case 0x5a08d4cf {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        /// @src 0:2513:2542  "revert(\"Blocked by modifier\")"
                        let _20 := /** @src 0:160:6215  "contract Modifiers {..." */ mload(64)
                        /// @src 0:2513:2542  "revert(\"Blocked by modifier\")"
                        mstore(_20, shl(229, 4594637))
                        /// @src 0:160:6215  "contract Modifiers {..."
                        mstore(/** @src 0:2513:2542  "revert(\"Blocked by modifier\")" */ add(_20, /** @src 0:160:6215  "contract Modifiers {..." */ 4), 32)
                        mstore(add(/** @src 0:2513:2542  "revert(\"Blocked by modifier\")" */ _20, /** @src 0:160:6215  "contract Modifiers {..." */ 36), 19)
                        mstore(add(/** @src 0:2513:2542  "revert(\"Blocked by modifier\")" */ _20, /** @src 0:160:6215  "contract Modifiers {..." */ 68), "Blocked by modifier")
                        /// @src 0:2513:2542  "revert(\"Blocked by modifier\")"
                        revert(_20, 100)
                    }
                    case /** @src 0:160:6215  "contract Modifiers {..." */ 0x5c975abb {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let value_6 := and(shr(160, sload(0)), 0xff)
                        let memPos_3 := mload(64)
                        mstore(memPos_3, iszero(iszero(value_6)))
                        return(memPos_3, 32)
                    }
                    case 0x61baffe6 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _21 := sload(0)
                        /// @src 0:832:874  "if (msg.sender != owner) revert NotOwner()"
                        if /** @src 0:836:855  "msg.sender != owner" */ iszero(eq(/** @src 0:836:846  "msg.sender" */ caller(), /** @src 0:160:6215  "contract Modifiers {..." */ and(_21, sub(shl(160, 1), 1))))
                        /// @src 0:832:874  "if (msg.sender != owner) revert NotOwner()"
                        {
                            /// @src 0:864:874  "NotOwner()"
                            mstore(/** @src 0:160:6215  "contract Modifiers {..." */ 0, /** @src 0:864:874  "NotOwner()" */ shl(224, 0x30cd7471))
                            revert(/** @src 0:160:6215  "contract Modifiers {..." */ 0, 4)
                        }
                        mstore(0, /** @src 0:836:846  "msg.sender" */ caller())
                        /// @src 0:160:6215  "contract Modifiers {..."
                        mstore(0x20, /** @src 0:969:975  "admins" */ 0x02)
                        /// @src 0:964:1006  "if (!admins[msg.sender]) revert NotAdmin()"
                        if /** @src 0:968:987  "!admins[msg.sender]" */ iszero(/** @src 0:160:6215  "contract Modifiers {..." */ and(sload(keccak256(0, 64)), 0xff))
                        /// @src 0:964:1006  "if (!admins[msg.sender]) revert NotAdmin()"
                        {
                            /// @src 0:996:1006  "NotAdmin()"
                            mstore(/** @src 0:160:6215  "contract Modifiers {..." */ 0, /** @src 0:996:1006  "NotAdmin()" */ shl(224, 0x7bfa4b9f))
                            revert(/** @src 0:160:6215  "contract Modifiers {..." */ 0, 4)
                        }
                        /// @src 0:1096:1123  "if (paused) revert Paused()"
                        if /** @src 0:160:6215  "contract Modifiers {..." */ and(shr(160, _21), 0xff)
                        /// @src 0:1096:1123  "if (paused) revert Paused()"
                        {
                            /// @src 0:1115:1123  "Paused()"
                            mstore(/** @src 0:160:6215  "contract Modifiers {..." */ 0, /** @src 0:1115:1123  "Paused()" */ shl(227, 0x13d0ff59))
                            revert(/** @src 0:160:6215  "contract Modifiers {..." */ 0, 4)
                        }
                        let _22 := sload(/** @src 0:3841:3855  "counter += 100" */ 0x01)
                        /// @src 0:160:6215  "contract Modifiers {..."
                        let sum_8 := add(_22, /** @src 0:3852:3855  "100" */ 0x64)
                        /// @src 0:160:6215  "contract Modifiers {..."
                        if gt(_22, sum_8)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        sstore(/** @src 0:3841:3855  "counter += 100" */ 0x01, /** @src 0:160:6215  "contract Modifiers {..." */ sum_8)
                        return(0, 0)
                    }
                    case 0x61bc221a {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _23 := sload(/** @src 0:270:292  "uint256 public counter" */ 1)
                        /// @src 0:160:6215  "contract Modifiers {..."
                        let memPos_4 := mload(64)
                        mstore(memPos_4, _23)
                        return(memPos_4, 32)
                    }
                    case 0x686b0327 {
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        /// @src 0:1299:1333  "msg.value < min || msg.value > max"
                        let expr := /** @src 0:1299:1314  "msg.value < min" */ lt(/** @src 0:1299:1308  "msg.value" */ callvalue(), /** @src 0:4012:4021  "0.1 ether" */ 0x016345785d8a0000)
                        /// @src 0:1299:1333  "msg.value < min || msg.value > max"
                        if iszero(expr)
                        {
                            expr := /** @src 0:1318:1333  "msg.value > max" */ gt(/** @src 0:1299:1308  "msg.value" */ callvalue(), /** @src 0:4023:4030  "1 ether" */ 0x0de0b6b3a7640000)
                        }
                        /// @src 0:1295:1365  "if (msg.value < min || msg.value > max) revert InvalidValue(msg.value)"
                        if expr
                        {
                            /// @src 0:1342:1365  "InvalidValue(msg.value)"
                            mstore(/** @src 0:160:6215  "contract Modifiers {..." */ 0, /** @src 0:1342:1365  "InvalidValue(msg.value)" */ shl(226, 0x181c9d0b))
                            /// @src 0:160:6215  "contract Modifiers {..."
                            mstore(4, /** @src 0:1299:1308  "msg.value" */ callvalue())
                            /// @src 0:1342:1365  "InvalidValue(msg.value)"
                            revert(/** @src 0:160:6215  "contract Modifiers {..." */ 0, 36)
                        }
                        sstore(/** @src 0:4046:4066  "counter += msg.value" */ 0x01, checked_add_uint256(/** @src 0:160:6215  "contract Modifiers {..." */ sload(/** @src 0:4046:4066  "counter += msg.value" */ 0x01), /** @src 0:1299:1308  "msg.value" */ callvalue()))
                        /// @src 0:160:6215  "contract Modifiers {..."
                        return(0, 0)
                    }
                    case 0x70480275 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value_7 := calldataload(4)
                        let _24 := and(value_7, sub(shl(160, 1), 1))
                        if iszero(eq(value_7, _24)) { revert(0, 0) }
                        /// @src 0:832:874  "if (msg.sender != owner) revert NotOwner()"
                        if /** @src 0:836:855  "msg.sender != owner" */ iszero(eq(/** @src 0:836:846  "msg.sender" */ caller(), /** @src 0:160:6215  "contract Modifiers {..." */ and(sload(0), sub(shl(160, 1), 1))))
                        /// @src 0:832:874  "if (msg.sender != owner) revert NotOwner()"
                        {
                            /// @src 0:864:874  "NotOwner()"
                            mstore(/** @src 0:160:6215  "contract Modifiers {..." */ 0, /** @src 0:864:874  "NotOwner()" */ shl(224, 0x30cd7471))
                            revert(/** @src 0:160:6215  "contract Modifiers {..." */ 0, 4)
                        }
                        mstore(0, _24)
                        mstore(32, /** @src 0:3306:3312  "admins" */ 0x02)
                        /// @src 0:160:6215  "contract Modifiers {..."
                        let dataSlot_1 := keccak256(0, 64)
                        sstore(dataSlot_1, or(and(sload(dataSlot_1), not(255)), /** @src 0:3322:3326  "true" */ 0x01))
                        /// @src 0:160:6215  "contract Modifiers {..."
                        return(0, 0)
                    }
                    case 0x8ada066e {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        mstore(0, /** @src 0:976:986  "msg.sender" */ caller())
                        /// @src 0:160:6215  "contract Modifiers {..."
                        mstore(0x20, /** @src 0:969:975  "admins" */ 0x02)
                        /// @src 0:964:1006  "if (!admins[msg.sender]) revert NotAdmin()"
                        if /** @src 0:968:987  "!admins[msg.sender]" */ iszero(/** @src 0:160:6215  "contract Modifiers {..." */ and(sload(keccak256(0, 64)), 0xff))
                        /// @src 0:964:1006  "if (!admins[msg.sender]) revert NotAdmin()"
                        {
                            /// @src 0:996:1006  "NotAdmin()"
                            mstore(/** @src 0:160:6215  "contract Modifiers {..." */ 0, /** @src 0:996:1006  "NotAdmin()" */ shl(224, 0x7bfa4b9f))
                            revert(/** @src 0:160:6215  "contract Modifiers {..." */ 0, 4)
                        }
                        let _25 := sload(/** @src 0:4715:4722  "counter" */ 0x01)
                        /// @src 0:160:6215  "contract Modifiers {..."
                        let memPos_5 := mload(64)
                        mstore(memPos_5, _25)
                        return(memPos_5, 0x20)
                    }
                    case 0x8c81e1b0 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _26 := sload(0)
                        /// @src 0:832:874  "if (msg.sender != owner) revert NotOwner()"
                        if /** @src 0:836:855  "msg.sender != owner" */ iszero(eq(/** @src 0:836:846  "msg.sender" */ caller(), /** @src 0:160:6215  "contract Modifiers {..." */ and(_26, sub(shl(160, 1), 1))))
                        /// @src 0:832:874  "if (msg.sender != owner) revert NotOwner()"
                        {
                            /// @src 0:864:874  "NotOwner()"
                            mstore(/** @src 0:160:6215  "contract Modifiers {..." */ 0, /** @src 0:864:874  "NotOwner()" */ shl(224, 0x30cd7471))
                            revert(/** @src 0:160:6215  "contract Modifiers {..." */ 0, 4)
                        }
                        /// @src 0:1096:1123  "if (paused) revert Paused()"
                        if /** @src 0:160:6215  "contract Modifiers {..." */ and(shr(160, _26), 0xff)
                        /// @src 0:1096:1123  "if (paused) revert Paused()"
                        {
                            /// @src 0:1115:1123  "Paused()"
                            mstore(/** @src 0:160:6215  "contract Modifiers {..." */ 0, /** @src 0:1115:1123  "Paused()" */ shl(227, 0x13d0ff59))
                            revert(/** @src 0:160:6215  "contract Modifiers {..." */ 0, 4)
                        }
                        let _27 := sload(/** @src 0:3710:3723  "counter += 10" */ 0x01)
                        /// @src 0:160:6215  "contract Modifiers {..."
                        let sum_9 := add(_27, /** @src 0:3721:3723  "10" */ 0x0a)
                        /// @src 0:160:6215  "contract Modifiers {..."
                        if gt(_27, sum_9)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        sstore(/** @src 0:3710:3723  "counter += 10" */ 0x01, /** @src 0:160:6215  "contract Modifiers {..." */ sum_9)
                        let memPos_6 := mload(64)
                        mstore(memPos_6, sum_9)
                        return(memPos_6, 32)
                    }
                    case 0x8da5cb5b {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let value_8 := and(sload(0), sub(shl(160, 1), 1))
                        let memPos_7 := mload(64)
                        mstore(memPos_7, value_8)
                        return(memPos_7, 32)
                    }
                    case 0x9b6a7110 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPtr_2 := 0
                        let size_1 := 0
                        size_1 := 0
                        let memPtr_3 := mload(64)
                        let newFreePtr_1 := add(memPtr_3, 64)
                        if or(gt(newFreePtr_1, 0xffffffffffffffff), lt(newFreePtr_1, memPtr_3))
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x41)
                            revert(0, 0x24)
                        }
                        mstore(64, newFreePtr_1)
                        memPtr_2 := memPtr_3
                        mstore(memPtr_3, 9)
                        mstore(add(memPtr_3, 32), "increment")
                        /// @src 0:1880:1902  "GuardTriggered(action)"
                        let _28 := /** @src 0:160:6215  "contract Modifiers {..." */ mload(64)
                        /// @src 0:1880:1902  "GuardTriggered(action)"
                        log1(_28, sub(abi_encode_string(_28, memPtr_3), _28), 0x0ab8476427dc967cd4151b39f5b46551fe823303177494fd5e4e052ea40f2dd6)
                        /// @src 0:160:6215  "contract Modifiers {..."
                        sstore(/** @src 0:4301:4310  "counter++" */ 0x01, increment_uint256(/** @src 0:160:6215  "contract Modifiers {..." */ sload(/** @src 0:4301:4310  "counter++" */ 0x01)))
                        /// @src 0:1928:1963  "ActionPerformed(msg.sender, action)"
                        let _29 := /** @src 0:160:6215  "contract Modifiers {..." */ mload(64)
                        /// @src 0:1928:1963  "ActionPerformed(msg.sender, action)"
                        log2(_29, sub(abi_encode_string(_29, memPtr_3), _29), 0xe0e2450862980d2d725d0eaff08ee369b5c951ad7f60c0214d8a068f7a501c45, /** @src 0:1944:1954  "msg.sender" */ caller())
                        /// @src 0:160:6215  "contract Modifiers {..."
                        return(0, 0)
                    }
                    case 0xaea3f28c {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        let ret := /** @src 0:4868:4873  "a + b" */ checked_add_uint256(/** @src 0:160:6215  "contract Modifiers {..." */ calldataload(4), calldataload(36))
                        let memPos_8 := mload(64)
                        mstore(memPos_8, ret)
                        return(memPos_8, 32)
                    }
                    case 0xe9d0f58a {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _30 := sload(/** @src 0:2925:2945  "counter += addBefore" */ 0x01)
                        /// @src 0:160:6215  "contract Modifiers {..."
                        let sum_10 := add(_30, /** @src 0:5937:5940  "100" */ 0x64)
                        /// @src 0:160:6215  "contract Modifiers {..."
                        if gt(_30, sum_10)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        let sum_11 := add(_30, 101)
                        if gt(sum_10, sum_11)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        let sum_12 := add(_30, 301)
                        if gt(sum_11, sum_12)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        sstore(/** @src 0:2925:2945  "counter += addBefore" */ 0x01, /** @src 0:160:6215  "contract Modifiers {..." */ sum_12)
                        return(0, 0)
                    }
                    case 0xed87cf46 {
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        if /** @src 0:1474:1490  "msg.value >= min" */ lt(/** @src 0:1474:1483  "msg.value" */ callvalue(), /** @src 0:4127:4137  "0.01 ether" */ 0x2386f26fc10000)
                        /// @src 0:160:6215  "contract Modifiers {..."
                        {
                            let memPtr_4 := mload(64)
                            mstore(memPtr_4, /** @src 0:2513:2542  "revert(\"Blocked by modifier\")" */ shl(229, 4594637))
                            /// @src 0:160:6215  "contract Modifiers {..."
                            mstore(add(memPtr_4, 4), 32)
                            mstore(add(memPtr_4, 36), 13)
                            mstore(add(memPtr_4, 68), "Below minimum")
                            revert(memPtr_4, 100)
                        }
                        sstore(/** @src 0:4046:4066  "counter += msg.value" */ 0x01, checked_add_uint256(/** @src 0:160:6215  "contract Modifiers {..." */ sload(/** @src 0:4046:4066  "counter += msg.value" */ 0x01), /** @src 0:1474:1483  "msg.value" */ callvalue()))
                        /// @src 0:160:6215  "contract Modifiers {..."
                        return(0, 0)
                    }
                }
                revert(0, 0)
            }
            function checked_add_uint256(x, y) -> sum
            {
                sum := add(x, y)
                if gt(x, sum)
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x11)
                    revert(0, 0x24)
                }
            }
            function require_helper_stringliteral(condition)
            {
                if iszero(condition)
                {
                    let memPtr := mload(64)
                    mstore(memPtr, /** @src 0:2513:2542  "revert(\"Blocked by modifier\")" */ shl(229, 4594637))
                    /// @src 0:160:6215  "contract Modifiers {..."
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 19)
                    mstore(add(memPtr, 68), "Reentrancy detected")
                    revert(memPtr, 100)
                }
            }
            function increment_uint256(value) -> ret
            {
                if eq(value, not(0))
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x11)
                    revert(0, 0x24)
                }
                ret := add(value, 1)
            }
            function abi_encode_string(headStart, value0) -> tail
            {
                mstore(headStart, 32)
                let length := mload(value0)
                mstore(add(headStart, 32), length)
                mcopy(add(headStart, 64), add(value0, 32), length)
                mstore(add(add(headStart, length), 64), 0)
                tail := add(add(headStart, and(add(length, 31), not(31))), 64)
            }
            function require_helper_stringliteral_13c0(condition)
            {
                if iszero(condition)
                {
                    let memPtr := mload(64)
                    mstore(memPtr, /** @src 0:2513:2542  "revert(\"Blocked by modifier\")" */ shl(229, 4594637))
                    /// @src 0:160:6215  "contract Modifiers {..."
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 21)
                    mstore(add(memPtr, 68), "Counter must increase")
                    revert(memPtr, 100)
                }
            }
        }
        data ".metadata" hex"a264697066735822122008433f2fa239ae7f2deb2b71185a4b9f3affc44dc6b28f0701e3455998e63c9564736f6c634300081c0033"
    }
}