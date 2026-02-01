object "SoladyToken_216" {
    code {
        {
            /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
            mstore(64, memoryguard(0x80))
            if callvalue() { revert(0, 0) }
            let programSize := datasize("SoladyToken_216")
            let argSize := sub(codesize(), programSize)
            let memoryDataOffset := allocate_memory(argSize)
            codecopy(memoryDataOffset, programSize, argSize)
            let _1 := add(memoryDataOffset, argSize)
            if slt(sub(_1, memoryDataOffset), 96)
            {
                revert(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
            let offset := mload(memoryDataOffset)
            if gt(offset, sub(shl(64, 1), 1))
            {
                revert(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
            let value0 := abi_decode_string_fromMemory(add(memoryDataOffset, offset), _1)
            let offset_1 := mload(add(memoryDataOffset, 32))
            if gt(offset_1, sub(shl(64, 1), 1))
            {
                revert(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
            let value1 := abi_decode_string_fromMemory(add(memoryDataOffset, offset_1), _1)
            let value := mload(add(memoryDataOffset, 64))
            let _2 := and(value, 0xff)
            if iszero(eq(value, _2))
            {
                revert(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
            let newLen := mload(value0)
            if gt(newLen, sub(shl(64, 1), 1))
            {
                mstore(/** @src -1:-1:-1 */ 0, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ shl(224, 0x4e487b71))
                mstore(4, 0x41)
                revert(/** @src -1:-1:-1 */ 0, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 0x24)
            }
            let _3 := sload(/** @src -1:-1:-1 */ 0)
            /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
            let length := /** @src -1:-1:-1 */ 0
            /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
            length := shr(1, _3)
            let outOfPlaceEncoding := and(_3, 1)
            if iszero(outOfPlaceEncoding) { length := and(length, 0x7f) }
            if eq(outOfPlaceEncoding, lt(length, 32))
            {
                mstore(/** @src -1:-1:-1 */ 0, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ shl(224, 0x4e487b71))
                mstore(4, 0x22)
                revert(/** @src -1:-1:-1 */ 0, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 0x24)
            }
            if gt(length, 31)
            {
                mstore(/** @src -1:-1:-1 */ 0, 0)
                /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                let data := keccak256(/** @src -1:-1:-1 */ 0, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 32)
                let deleteStart := add(data, shr(5, add(newLen, 31)))
                if lt(newLen, 32) { deleteStart := data }
                let _4 := add(data, shr(5, add(length, 31)))
                let start := deleteStart
                for { } lt(start, _4) { start := add(start, 1) }
                {
                    sstore(start, /** @src -1:-1:-1 */ 0)
                }
            }
            /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
            let srcOffset := /** @src -1:-1:-1 */ 0
            /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
            srcOffset := 32
            switch gt(newLen, 31)
            case 1 {
                let loopEnd := and(newLen, not(31))
                mstore(/** @src -1:-1:-1 */ 0, 0)
                /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                let dstPtr := keccak256(/** @src -1:-1:-1 */ 0, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ srcOffset)
                let i := /** @src -1:-1:-1 */ 0
                /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                for { } lt(i, loopEnd) { i := add(i, 32) }
                {
                    sstore(dstPtr, mload(add(value0, srcOffset)))
                    dstPtr := add(dstPtr, 1)
                    srcOffset := add(srcOffset, 32)
                }
                if lt(loopEnd, newLen)
                {
                    let lastValue := mload(add(value0, srcOffset))
                    sstore(dstPtr, and(lastValue, not(shr(and(shl(3, newLen), 248), not(0)))))
                }
                sstore(/** @src -1:-1:-1 */ 0, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ add(shl(1, newLen), 1))
            }
            default {
                let value_1 := /** @src -1:-1:-1 */ 0
                /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                if newLen
                {
                    value_1 := mload(add(value0, srcOffset))
                }
                sstore(/** @src -1:-1:-1 */ 0, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ or(and(value_1, not(shr(shl(3, newLen), not(0)))), shl(1, newLen)))
            }
            let newLen_1 := mload(value1)
            if gt(newLen_1, sub(shl(64, 1), 1))
            {
                mstore(/** @src -1:-1:-1 */ 0, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ shl(224, 0x4e487b71))
                mstore(4, 0x41)
                revert(/** @src -1:-1:-1 */ 0, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 0x24)
            }
            let _5 := sload(1)
            let length_1 := /** @src -1:-1:-1 */ 0
            /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
            length_1 := shr(1, _5)
            let outOfPlaceEncoding_1 := and(_5, 1)
            if iszero(outOfPlaceEncoding_1)
            {
                length_1 := and(length_1, 0x7f)
            }
            if eq(outOfPlaceEncoding_1, lt(length_1, 32))
            {
                mstore(/** @src -1:-1:-1 */ 0, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ shl(224, 0x4e487b71))
                mstore(4, 0x22)
                revert(/** @src -1:-1:-1 */ 0, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 0x24)
            }
            if gt(length_1, 31)
            {
                mstore(/** @src -1:-1:-1 */ 0, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 1)
                let data_1 := keccak256(/** @src -1:-1:-1 */ 0, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 32)
                let deleteStart_1 := add(data_1, shr(5, add(newLen_1, 31)))
                if lt(newLen_1, 32) { deleteStart_1 := data_1 }
                let _6 := add(data_1, shr(5, add(length_1, 31)))
                let start_1 := deleteStart_1
                for { } lt(start_1, _6) { start_1 := add(start_1, 1) }
                {
                    sstore(start_1, /** @src -1:-1:-1 */ 0)
                }
            }
            /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
            let srcOffset_1 := /** @src -1:-1:-1 */ 0
            /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
            srcOffset_1 := 32
            switch gt(newLen_1, 31)
            case 1 {
                let loopEnd_1 := and(newLen_1, not(31))
                mstore(/** @src -1:-1:-1 */ 0, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 1)
                let dstPtr_1 := keccak256(/** @src -1:-1:-1 */ 0, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ srcOffset_1)
                let i_1 := /** @src -1:-1:-1 */ 0
                /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                for { } lt(i_1, loopEnd_1) { i_1 := add(i_1, 32) }
                {
                    sstore(dstPtr_1, mload(add(value1, srcOffset_1)))
                    dstPtr_1 := add(dstPtr_1, 1)
                    srcOffset_1 := add(srcOffset_1, 32)
                }
                if lt(loopEnd_1, newLen_1)
                {
                    let lastValue_1 := mload(add(value1, srcOffset_1))
                    sstore(dstPtr_1, and(lastValue_1, not(shr(and(shl(3, newLen_1), 248), not(0)))))
                }
                sstore(1, add(shl(1, newLen_1), 1))
            }
            default {
                let value_2 := /** @src -1:-1:-1 */ 0
                /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                if newLen_1
                {
                    value_2 := mload(add(value1, srcOffset_1))
                }
                sstore(1, or(and(value_2, not(shr(shl(3, newLen_1), not(0)))), shl(1, newLen_1)))
            }
            let _7 := sload(/** @src 1:504:525  "_decimals = decimals_" */ 0x02)
            /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
            sstore(/** @src 1:504:525  "_decimals = decimals_" */ 0x02, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ or(or(and(_7, not(sub(shl(168, 1), 1))), _2), and(shl(8, /** @src 1:543:553  "msg.sender" */ caller()), /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ sub(shl(168, 1), 256))))
            let _8 := mload(64)
            let _9 := datasize("SoladyToken_216_deployed")
            codecopy(_8, dataoffset("SoladyToken_216_deployed"), _9)
            return(_8, _9)
        }
        function allocate_memory(size) -> memPtr
        {
            memPtr := mload(64)
            let newFreePtr := add(memPtr, and(add(size, 31), not(31)))
            if or(gt(newFreePtr, sub(shl(64, 1), 1)), lt(newFreePtr, memPtr))
            {
                mstore(/** @src -1:-1:-1 */ 0, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ shl(224, 0x4e487b71))
                mstore(4, 0x41)
                revert(/** @src -1:-1:-1 */ 0, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 0x24)
            }
            mstore(64, newFreePtr)
        }
        function abi_decode_string_fromMemory(offset, end) -> array
        {
            if iszero(slt(add(offset, 0x1f), end)) { revert(0, 0) }
            let length := mload(offset)
            if gt(length, sub(shl(64, 1), 1))
            {
                mstore(/** @src -1:-1:-1 */ 0, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ shl(224, 0x4e487b71))
                mstore(4, 0x41)
                revert(/** @src -1:-1:-1 */ 0, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 0x24)
            }
            let array_1 := allocate_memory(add(and(add(length, 0x1f), not(31)), 0x20))
            mstore(array_1, length)
            if gt(add(add(offset, length), 0x20), end)
            {
                revert(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
            mcopy(add(array_1, 0x20), add(offset, 0x20), length)
            mstore(add(add(array_1, length), 0x20), /** @src -1:-1:-1 */ 0)
            /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
            array := array_1
        }
    }
    /// @use-src 0:"foundry/lib/solady/src/tokens/ERC20.sol", 1:"foundry/src/bench/SoladyToken.sol"
    object "SoladyToken_216_deployed" {
        code {
            {
                /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                mstore(64, memoryguard(0x80))
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x06fdde03 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let converted := copy_array_from_storage_to_memory_string()
                        let memPos := mload(64)
                        return(memPos, sub(abi_encode_string(memPos, converted), memPos))
                    }
                    case 0x095ea7b3 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        let value0 := abi_decode_address_4839()
                        let value := calldataload(36)
                        /// @src 0:8384:8723  "assembly {..."
                        if iszero(or(xor(and(value0, sub(shl(160, 1), 1)), 0x22d473030f116ddee9f6b43ac78ba3), iszero(not(value))))
                        {
                            mstore(/** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 0, /** @src 0:8384:8723  "assembly {..." */ 0x3f68539a)
                            revert(0x1c, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 4)
                        }
                        /// @src 0:8785:9198  "assembly {..."
                        mstore(/** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 32, /** @src 0:8785:9198  "assembly {..." */ value0)
                        mstore(0x0c, 2136907552)
                        mstore(/** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 0, /** @src 0:8785:9198  "assembly {..." */ caller())
                        sstore(keccak256(0x0c, 0x34), value)
                        mstore(/** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 0, /** @src 0:8785:9198  "assembly {..." */ value)
                        log3(/** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 0, 32, /** @src 0:8785:9198  "assembly {..." */ 63486140976153616755203102783360879283472101686154884697241723088393386309925, caller(), shr(96, mload(0x2c)))
                        /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                        let memPos_1 := mload(64)
                        mstore(memPos_1, 1)
                        return(memPos_1, 32)
                    }
                    case 0x18160ddd {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let ret := /** @src 0:7049:7117  "assembly {..." */ sload(96006856662521017420)
                        /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                        let memPos_2 := mload(64)
                        mstore(memPos_2, ret)
                        return(memPos_2, 32)
                    }
                    case 0x23b872dd {
                        if callvalue() { revert(0, 0) }
                        let param, param_1, param_2 := abi_decode_addresst_addresst_uint256(calldatasize())
                        /// @src 0:11506:13707  "assembly {..."
                        let usr$from := shl(96, param)
                        if iszero(eq(caller(), 0x22d473030f116ddee9f6b43ac78ba3))
                        {
                            mstore(0x20, caller())
                            mstore(0x0c, or(usr$from, 2136907552))
                            let usr$allowanceSlot := keccak256(0x0c, 0x34)
                            let usr$allowance := sload(usr$allowanceSlot)
                            if not(usr$allowance)
                            {
                                if gt(param_2, usr$allowance)
                                {
                                    mstore(/** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 0, /** @src 0:11506:13707  "assembly {..." */ 0x13be252b)
                                    revert(0x1c, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 4)
                                }
                                /// @src 0:11506:13707  "assembly {..."
                                sstore(usr$allowanceSlot, sub(usr$allowance, param_2))
                            }
                        }
                        mstore(0x0c, or(usr$from, 2275545506))
                        let usr$fromBalanceSlot := keccak256(0x0c, 0x20)
                        let usr$fromBalance := sload(usr$fromBalanceSlot)
                        if gt(param_2, usr$fromBalance)
                        {
                            mstore(/** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 0, /** @src 0:11506:13707  "assembly {..." */ 0xf4d678b8)
                            revert(0x1c, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 4)
                        }
                        /// @src 0:11506:13707  "assembly {..."
                        sstore(usr$fromBalanceSlot, sub(usr$fromBalance, param_2))
                        mstore(/** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 0, /** @src 0:11506:13707  "assembly {..." */ param_1)
                        let usr$toBalanceSlot := keccak256(0x0c, 0x20)
                        sstore(usr$toBalanceSlot, add(sload(usr$toBalanceSlot), param_2))
                        mstore(0x20, param_2)
                        log3(0x20, 0x20, 100389287136786176327247604509743168900146139575972864366142685224231313322991, and(param, /** @src 0:8384:8723  "assembly {..." */ sub(shl(160, 1), 1)), /** @src 0:11506:13707  "assembly {..." */ shr(96, mload(0x0c)))
                        /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                        let memPos_3 := mload(64)
                        mstore(memPos_3, /** @src 0:31102:31106  "true" */ 0x01)
                        /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                        return(memPos_3, /** @src 0:11506:13707  "assembly {..." */ 0x20)
                    }
                    case /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 0x313ce567 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let value_1 := and(sload(/** @src 1:836:845  "_decimals" */ 0x02), /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 0xff)
                        let memPos_4 := mload(64)
                        mstore(memPos_4, value_1)
                        return(memPos_4, 32)
                    }
                    case 0x3644e515 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _1 := copy_array_from_storage_to_memory_string()
                        /// @src 0:21732:21767  "nameHash = keccak256(bytes(name()))"
                        let var_nameHash := /** @src 0:21743:21767  "keccak256(bytes(name()))" */ keccak256(/** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ add(/** @src 0:21743:21767  "keccak256(bytes(name()))" */ _1, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 0x20), mload(/** @src 0:21743:21767  "keccak256(bytes(name()))" */ _1))
                        /// @src 0:21866:22210  "assembly {..."
                        let usr$m := mload(/** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 64)
                        /// @src 0:21866:22210  "assembly {..."
                        mstore(usr$m, 63076024560530113402979550242307453568063438748328787417531900361828837441551)
                        mstore(add(usr$m, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 0x20), /** @src 0:21866:22210  "assembly {..." */ var_nameHash)
                        mstore(add(usr$m, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 64), /** @src 0:5177:5243  "0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6" */ 0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6)
                        /// @src 0:21866:22210  "assembly {..."
                        mstore(add(usr$m, 0x60), chainid())
                        mstore(add(usr$m, 0x80), address())
                        let var_result := keccak256(usr$m, 0xa0)
                        /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                        let memPos_5 := mload(64)
                        mstore(memPos_5, var_result)
                        return(memPos_5, 0x20)
                    }
                    case 0x40c10f19 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        let value0_1 := abi_decode_address_4839()
                        /// @src 1:957:999  "require(msg.sender == owner, \"Only owner\")"
                        require_helper_stringliteral_17d9(/** @src 1:965:984  "msg.sender == owner" */ eq(/** @src 1:965:975  "msg.sender" */ caller(), /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ and(shr(8, sload(/** @src 1:979:984  "owner" */ 0x02)), /** @src 0:8384:8723  "assembly {..." */ sub(shl(160, 1), 1))))
                        /// @src 1:1019:1025  "amount"
                        fun_mint(value0_1, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ calldataload(36))
                        return(0, 0)
                    }
                    case 0x423f6cef {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        let value0_2 := abi_decode_address_4839()
                        /// @src 1:1949:1955  "amount"
                        fun_transfer(/** @src 1:1933:1943  "msg.sender" */ caller(), /** @src 1:1949:1955  "amount" */ value0_2, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ calldataload(36))
                        let memPos_6 := mload(64)
                        mstore(memPos_6, 1)
                        return(memPos_6, 32)
                    }
                    case 0x42842e0e {
                        if callvalue() { revert(0, 0) }
                        let param_3, param_4, param_5 := abi_decode_addresst_addresst_uint256(calldatasize())
                        /// @src 1:2156:2162  "amount"
                        fun_spendAllowance(param_3, /** @src 1:2144:2154  "msg.sender" */ caller(), /** @src 1:2156:2162  "amount" */ param_5)
                        /// @src 1:2193:2199  "amount"
                        fun_transfer(param_3, param_4, param_5)
                        /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                        let memPos_7 := mload(64)
                        mstore(memPos_7, /** @src 1:2217:2221  "true" */ 0x01)
                        /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                        return(memPos_7, 32)
                    }
                    case 0x42966c68 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        /// @src 1:1505:1511  "amount"
                        fun_burn(/** @src 1:1493:1503  "msg.sender" */ caller(), /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ calldataload(4))
                        return(0, 0)
                    }
                    case 0x70a08231 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value0_3 := abi_decode_address_4839()
                        /// @src 0:7321:7469  "assembly {..."
                        mstore(0x0c, 2275545506)
                        mstore(/** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 0, /** @src 0:7321:7469  "assembly {..." */ value0_3)
                        let var_result_1 := sload(keccak256(0x0c, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 32))
                        let memPos_8 := mload(64)
                        mstore(memPos_8, var_result_1)
                        return(memPos_8, 32)
                    }
                    case 0x79cc6790 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        let value0_4 := abi_decode_address_4839()
                        let value_2 := calldataload(36)
                        /// @src 1:1626:1632  "amount"
                        fun_spendAllowance(value0_4, /** @src 1:1614:1624  "msg.sender" */ caller(), /** @src 1:1626:1632  "amount" */ value_2)
                        /// @src 1:1655:1661  "amount"
                        fun_burn(value0_4, value_2)
                        /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                        return(0, 0)
                    }
                    case 0x7c88e3d9 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        let offset := calldataload(4)
                        if gt(offset, 0xffffffffffffffff) { revert(0, 0) }
                        let value0_5, value1 := abi_decode_array_address_dyn_calldata(add(4, offset), calldatasize())
                        let offset_1 := calldataload(36)
                        if gt(offset_1, 0xffffffffffffffff) { revert(0, 0) }
                        let value2, value3 := abi_decode_array_address_dyn_calldata(add(4, offset_1), calldatasize())
                        /// @src 1:1158:1200  "require(msg.sender == owner, \"Only owner\")"
                        require_helper_stringliteral_17d9(/** @src 1:1166:1185  "msg.sender == owner" */ eq(/** @src 1:1166:1176  "msg.sender" */ caller(), /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ and(shr(8, sload(/** @src 1:1180:1185  "owner" */ 0x02)), /** @src 0:8384:8723  "assembly {..." */ sub(shl(160, 1), 1))))
                        /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                        if iszero(/** @src 1:1218:1253  "recipients.length == amounts.length" */ eq(value1, value3))
                        /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                        {
                            let memPtr := mload(64)
                            mstore(memPtr, shl(229, 4594637))
                            mstore(add(memPtr, 4), 32)
                            mstore(add(memPtr, 36), 15)
                            mstore(add(memPtr, 68), "Length mismatch")
                            revert(memPtr, 100)
                        }
                        /// @src 1:1288:1301  "uint256 i = 0"
                        let var_i := /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 0
                        /// @src 1:1283:1388  "for (uint256 i = 0; i < recipients.length; i++) {..."
                        for { }
                        /** @src 1:1303:1324  "i < recipients.length" */ lt(var_i, value1)
                        /// @src 1:1288:1301  "uint256 i = 0"
                        {
                            /// @src 1:1326:1329  "i++"
                            var_i := /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ add(/** @src 1:1326:1329  "i++" */ var_i, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 1)
                        }
                        /// @src 1:1326:1329  "i++"
                        {
                            /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                            let value_3 := calldataload(/** @src 1:1351:1364  "recipients[i]" */ calldata_array_index_access_address_dyn_calldata(value0_5, value1, var_i))
                            /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                            if iszero(eq(value_3, and(value_3, /** @src 0:8384:8723  "assembly {..." */ sub(shl(160, 1), 1))))
                            /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                            { revert(0, 0) }
                            /// @src 1:1366:1376  "amounts[i]"
                            fun_mint(value_3, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ calldataload(/** @src 1:1366:1376  "amounts[i]" */ calldata_array_index_access_address_dyn_calldata(value2, value3, var_i)))
                        }
                        /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                        return(0, 0)
                    }
                    case 0x7ecebe00 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value0_6 := abi_decode_address_4839()
                        /// @src 0:17287:17492  "assembly {..."
                        mstore(0x0c, 943158536)
                        mstore(/** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 0, /** @src 0:17287:17492  "assembly {..." */ value0_6)
                        let var_result_2 := sload(keccak256(0x0c, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 32))
                        let memPos_9 := mload(64)
                        mstore(memPos_9, var_result_2)
                        return(memPos_9, 32)
                    }
                    case 0x8da5cb5b {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let value_4 := and(shr(8, sload(/** @src 1:344:364  "address public owner" */ 2)), /** @src 0:8384:8723  "assembly {..." */ sub(shl(160, 1), 1))
                        /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                        let memPos_10 := mload(64)
                        mstore(memPos_10, value_4)
                        return(memPos_10, 32)
                    }
                    case 0x95d89b41 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPtr_1 := 0
                        memPtr_1 := mload(64)
                        let ret_1 := 0
                        let slotValue := sload(/** @src 1:742:749  "_symbol" */ 0x01)
                        /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                        let length := 0
                        length := shr(/** @src 1:742:749  "_symbol" */ 0x01, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ slotValue)
                        let outOfPlaceEncoding := and(slotValue, /** @src 1:742:749  "_symbol" */ 0x01)
                        /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                        if iszero(outOfPlaceEncoding) { length := and(length, 0x7f) }
                        if eq(outOfPlaceEncoding, lt(length, 32))
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x22)
                            revert(0, 0x24)
                        }
                        mstore(memPtr_1, length)
                        switch outOfPlaceEncoding
                        case 0 {
                            mstore(add(memPtr_1, 32), and(slotValue, not(255)))
                            ret_1 := add(add(memPtr_1, shl(5, iszero(iszero(length)))), 32)
                        }
                        case 1 {
                            mstore(0, /** @src 1:742:749  "_symbol" */ 0x01)
                            /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                            let dataPos := keccak256(0, 32)
                            let i := 0
                            for { } lt(i, length) { i := add(i, 32) }
                            {
                                mstore(add(add(memPtr_1, i), 32), sload(dataPos))
                                dataPos := add(dataPos, /** @src 1:742:749  "_symbol" */ 0x01)
                            }
                            /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                            ret_1 := add(add(memPtr_1, i), 32)
                        }
                        let newFreePtr := add(memPtr_1, and(add(sub(ret_1, memPtr_1), 31), not(31)))
                        if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr_1))
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x41)
                            revert(0, 0x24)
                        }
                        mstore(64, newFreePtr)
                        let memPos_11 := mload(64)
                        return(memPos_11, sub(abi_encode_string(memPos_11, memPtr_1), memPos_11))
                    }
                    case 0xa9059cbb {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        let value0_7 := abi_decode_address_4839()
                        let value_5 := calldataload(36)
                        /// @src 0:9595:10738  "assembly {..."
                        mstore(0x0c, 2275545506)
                        mstore(/** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 0, /** @src 0:9595:10738  "assembly {..." */ caller())
                        let usr$fromBalanceSlot_1 := keccak256(0x0c, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 32)
                        /// @src 0:9595:10738  "assembly {..."
                        let usr$fromBalance_1 := sload(usr$fromBalanceSlot_1)
                        if gt(value_5, usr$fromBalance_1)
                        {
                            mstore(/** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 0, /** @src 0:9595:10738  "assembly {..." */ 0xf4d678b8)
                            revert(0x1c, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 4)
                        }
                        /// @src 0:9595:10738  "assembly {..."
                        sstore(usr$fromBalanceSlot_1, sub(usr$fromBalance_1, value_5))
                        mstore(/** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 0, /** @src 0:9595:10738  "assembly {..." */ value0_7)
                        let usr$toBalanceSlot_1 := keccak256(0x0c, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 32)
                        /// @src 0:9595:10738  "assembly {..."
                        sstore(usr$toBalanceSlot_1, add(sload(usr$toBalanceSlot_1), value_5))
                        mstore(/** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 32, /** @src 0:9595:10738  "assembly {..." */ value_5)
                        log3(/** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 32, 32, /** @src 0:9595:10738  "assembly {..." */ 100389287136786176327247604509743168900146139575972864366142685224231313322991, caller(), shr(96, mload(0x0c)))
                        /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                        let memPos_12 := mload(64)
                        mstore(memPos_12, 1)
                        return(memPos_12, 32)
                    }
                    case 0xd505accf {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 224) { revert(0, 0) }
                        let value0_8 := abi_decode_address_4839()
                        let value1_1 := abi_decode_address()
                        let value_6 := calldataload(68)
                        let value_7 := calldataload(100)
                        let value_8 := calldataload(132)
                        if iszero(eq(value_8, and(value_8, 0xff))) { revert(0, 0) }
                        /// @src 0:17979:18316  "assembly {..."
                        let _2 := and(value1_1, /** @src 0:8384:8723  "assembly {..." */ sub(shl(160, 1), 1))
                        /// @src 0:17979:18316  "assembly {..."
                        if iszero(or(xor(_2, 0x22d473030f116ddee9f6b43ac78ba3), iszero(not(value_6))))
                        {
                            mstore(/** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 0, /** @src 0:17979:18316  "assembly {..." */ 0x3f68539a)
                            revert(0x1c, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 4)
                        }
                        let _3 := copy_array_from_storage_to_memory_string()
                        /// @src 0:18505:18540  "nameHash = keccak256(bytes(name()))"
                        let var_nameHash_1 := /** @src 0:18516:18540  "keccak256(bytes(name()))" */ keccak256(/** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ add(/** @src 0:18516:18540  "keccak256(bytes(name()))" */ _3, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 32), mload(/** @src 0:18516:18540  "keccak256(bytes(name()))" */ _3))
                        /// @src 0:18639:21392  "assembly {..."
                        if gt(timestamp(), value_7)
                        {
                            mstore(/** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 0, /** @src 0:18639:21392  "assembly {..." */ 0x1a15a3cc)
                            revert(0x1c, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 4)
                        }
                        /// @src 0:18639:21392  "assembly {..."
                        let usr$m_1 := mload(/** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 64)
                        /// @src 0:18639:21392  "assembly {..."
                        let var_owner := and(value0_8, /** @src 0:8384:8723  "assembly {..." */ sub(shl(160, 1), 1))
                        /// @src 0:18639:21392  "assembly {..."
                        mstore(0x0e, 61810837821697)
                        mstore(/** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 0, /** @src 0:18639:21392  "assembly {..." */ var_owner)
                        let usr$nonceSlot := keccak256(0x0c, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 32)
                        /// @src 0:18639:21392  "assembly {..."
                        let usr$nonceValue := sload(usr$nonceSlot)
                        mstore(usr$m_1, 63076024560530113402979550242307453568063438748328787417531900361828837441551)
                        let _4 := add(usr$m_1, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 32)
                        /// @src 0:18639:21392  "assembly {..."
                        mstore(_4, var_nameHash_1)
                        let _5 := add(usr$m_1, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 64)
                        /// @src 0:18639:21392  "assembly {..."
                        mstore(_5, /** @src 0:5177:5243  "0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6" */ 0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6)
                        /// @src 0:18639:21392  "assembly {..."
                        let _6 := add(usr$m_1, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 96)
                        /// @src 0:18639:21392  "assembly {..."
                        mstore(_6, chainid())
                        let _7 := add(usr$m_1, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 128)
                        /// @src 0:18639:21392  "assembly {..."
                        mstore(_7, address())
                        mstore(0x2e, keccak256(usr$m_1, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 160))
                        /// @src 0:18639:21392  "assembly {..."
                        mstore(usr$m_1, 49955707469362902507454157297736832118868343942642399513960811609542965143241)
                        mstore(_4, var_owner)
                        mstore(_5, _2)
                        mstore(_6, value_6)
                        mstore(_7, usr$nonceValue)
                        mstore(add(usr$m_1, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 160), /** @src 0:18639:21392  "assembly {..." */ value_7)
                        mstore(0x4e, keccak256(usr$m_1, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 192))
                        /// @src 0:18639:21392  "assembly {..."
                        mstore(/** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 0, /** @src 0:18639:21392  "assembly {..." */ keccak256(0x2c, 0x42))
                        mstore(/** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 32, /** @src 0:18639:21392  "assembly {..." */ and(/** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 0xff, /** @src 0:18639:21392  "assembly {..." */ value_8))
                        mstore(/** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 64, calldataload(164))
                        /// @src 0:18639:21392  "assembly {..."
                        mstore(/** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 96, calldataload(196))
                        /// @src 0:18639:21392  "assembly {..."
                        let usr$t := staticcall(gas(), /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 1, 0, 128, 32, 32)
                        /// @src 0:18639:21392  "assembly {..."
                        if iszero(eq(mload(returndatasize()), var_owner))
                        {
                            mstore(/** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 0, /** @src 0:18639:21392  "assembly {..." */ 0xddafbaef)
                            revert(0x1c, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 4)
                        }
                        /// @src 0:18639:21392  "assembly {..."
                        sstore(usr$nonceSlot, add(usr$nonceValue, usr$t))
                        mstore(/** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 64, /** @src 0:18639:21392  "assembly {..." */ or(shl(165, 0x03faf4f9), _2))
                        sstore(keccak256(0x2c, 0x34), value_6)
                        log3(_6, /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 32, /** @src 0:18639:21392  "assembly {..." */ 63486140976153616755203102783360879283472101686154884697241723088393386309925, var_owner, _2)
                        /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                        return(0, 0)
                    }
                    case 0xdd62ed3e {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        let value0_9 := abi_decode_address_4839()
                        let ret_2 := fun_allowance(value0_9, abi_decode_address())
                        let memPos_13 := mload(64)
                        mstore(memPos_13, ret_2)
                        return(memPos_13, 32)
                    }
                }
                revert(0, 0)
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
            function abi_decode_address_4839() -> value
            {
                value := calldataload(4)
                if iszero(eq(value, and(value, /** @src 0:8384:8723  "assembly {..." */ sub(shl(160, 1), 1))))
                /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                { revert(0, 0) }
            }
            function abi_decode_address() -> value
            {
                value := calldataload(36)
                if iszero(eq(value, and(value, /** @src 0:8384:8723  "assembly {..." */ sub(shl(160, 1), 1))))
                /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                { revert(0, 0) }
            }
            function abi_decode_addresst_addresst_uint256(dataEnd) -> value0, value1, value2
            {
                if slt(add(dataEnd, not(3)), 96) { revert(0, 0) }
                let value := /** @src -1:-1:-1 */ 0
                /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                value := calldataload(4)
                if iszero(eq(value, and(value, /** @src 0:8384:8723  "assembly {..." */ sub(shl(160, 1), 1))))
                /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                { revert(0, 0) }
                value0 := value
                let value_1 := /** @src -1:-1:-1 */ 0
                /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                value_1 := calldataload(36)
                if iszero(eq(value_1, and(value_1, /** @src 0:8384:8723  "assembly {..." */ sub(shl(160, 1), 1))))
                /// @src 1:225:2230  "contract SoladyToken is ERC20 {..."
                { revert(0, 0) }
                value1 := value_1
                value2 := calldataload(68)
            }
            function abi_decode_array_address_dyn_calldata(offset, end) -> arrayPos, length
            {
                if iszero(slt(add(offset, 0x1f), end)) { revert(0, 0) }
                length := calldataload(offset)
                if gt(length, 0xffffffffffffffff) { revert(0, 0) }
                arrayPos := add(offset, 0x20)
                if gt(add(add(offset, shl(5, length)), 0x20), end) { revert(0, 0) }
            }
            function copy_array_from_storage_to_memory_string() -> memPtr
            {
                memPtr := mload(64)
                let ret := 0
                let slotValue := sload(0)
                let length := 0
                length := shr(1, slotValue)
                let outOfPlaceEncoding := and(slotValue, 1)
                if iszero(outOfPlaceEncoding) { length := and(length, 0x7f) }
                if eq(outOfPlaceEncoding, lt(length, 32))
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x22)
                    revert(0, 0x24)
                }
                mstore(memPtr, length)
                switch outOfPlaceEncoding
                case 0 {
                    mstore(add(memPtr, 32), and(slotValue, not(255)))
                    ret := add(add(memPtr, shl(5, iszero(iszero(length)))), 32)
                }
                case 1 {
                    mstore(0, 0)
                    let dataPos := keccak256(0, 32)
                    let i := 0
                    for { } lt(i, length) { i := add(i, 32) }
                    {
                        mstore(add(add(memPtr, i), 32), sload(dataPos))
                        dataPos := add(dataPos, 1)
                    }
                    ret := add(add(memPtr, i), 32)
                }
                let newFreePtr := add(memPtr, and(add(sub(ret, memPtr), 31), not(31)))
                if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr))
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x41)
                    revert(0, 0x24)
                }
                mstore(64, newFreePtr)
            }
            function require_helper_stringliteral_17d9(condition)
            {
                if iszero(condition)
                {
                    let memPtr := mload(64)
                    mstore(memPtr, shl(229, 4594637))
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 10)
                    mstore(add(memPtr, 68), "Only owner")
                    revert(memPtr, 100)
                }
            }
            function calldata_array_index_access_address_dyn_calldata(base_ref, length, index) -> addr
            {
                if iszero(lt(index, length))
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x32)
                    revert(0, 0x24)
                }
                addr := add(base_ref, shl(5, index))
            }
            /// @ast-id 370 @src 0:7570:8065  "function allowance(address owner, address spender)..."
            function fun_allowance(var_owner, var_spender) -> var_result
            {
                /// @src 0:7682:7696  "uint256 result"
                var_result := /** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 0
                /// @src 0:7763:7812  "if (spender == _PERMIT2) return type(uint256).max"
                if /** @src 0:7767:7786  "spender == _PERMIT2" */ eq(/** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ and(/** @src 0:7767:7786  "spender == _PERMIT2" */ var_spender, /** @src 0:8384:8723  "assembly {..." */ sub(shl(160, 1), 1)), /** @src 0:5890:5932  "0x000000000022D473030F116dDEE9F6B43aC78BA3" */ 0x22d473030f116ddee9f6b43ac78ba3)
                /// @src 0:7763:7812  "if (spender == _PERMIT2) return type(uint256).max"
                {
                    /// @src 0:7788:7812  "return type(uint256).max"
                    var_result := /** @src 0:7795:7812  "type(uint256).max" */ not(0)
                    /// @src 0:7788:7812  "return type(uint256).max"
                    leave
                }
                /// @src 0:7875:8059  "assembly {..."
                mstore(0x20, var_spender)
                mstore(0x0c, 2136907552)
                mstore(/** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ 0, /** @src 0:7875:8059  "assembly {..." */ var_owner)
                var_result := sload(keccak256(0x0c, 0x34))
            }
            /// @ast-id 602 @src 0:22620:23792  "function _mint(address to, uint256 amount) internal virtual {..."
            function fun_mint(var_to, var_amount)
            {
                /// @src 0:22787:23733  "assembly {..."
                let usr$totalSupplyBefore := sload(96006856662521017420)
                let usr$totalSupplyAfter := add(usr$totalSupplyBefore, var_amount)
                if lt(usr$totalSupplyAfter, usr$totalSupplyBefore)
                {
                    mstore(0x00, 0xe5cfe957)
                    revert(0x1c, 0x04)
                }
                sstore(96006856662521017420, usr$totalSupplyAfter)
                mstore(0x0c, 2275545506)
                mstore(0x00, var_to)
                let usr$toBalanceSlot := keccak256(0x0c, 0x20)
                sstore(usr$toBalanceSlot, add(sload(usr$toBalanceSlot), var_amount))
                mstore(0x20, var_amount)
                log3(0x20, 0x20, 100389287136786176327247604509743168900146139575972864366142685224231313322991, 0x00, shr(96, mload(0x0c)))
            }
            /// @ast-id 654 @src 0:25665:27061  "function _transfer(address from, address to, uint256 amount) internal virtual {..."
            function fun_transfer(var_from, var_to, var_amount)
            {
                /// @src 0:25844:27008  "assembly {..."
                mstore(0x0c, or(shl(96, var_from), 2275545506))
                let usr$fromBalanceSlot := keccak256(0x0c, 0x20)
                let usr$fromBalance := sload(usr$fromBalanceSlot)
                if gt(var_amount, usr$fromBalance)
                {
                    mstore(0x00, 0xf4d678b8)
                    revert(0x1c, 0x04)
                }
                sstore(usr$fromBalanceSlot, sub(usr$fromBalance, var_amount))
                mstore(0x00, var_to)
                let usr$toBalanceSlot := keccak256(0x0c, 0x20)
                sstore(usr$toBalanceSlot, add(sload(usr$toBalanceSlot), var_amount))
                mstore(0x20, var_amount)
                log3(0x20, 0x20, 100389287136786176327247604509743168900146139575972864366142685224231313322991, and(var_from, /** @src 0:8384:8723  "assembly {..." */ sub(shl(160, 1), 1)), /** @src 0:25844:27008  "assembly {..." */ shr(96, mload(0x0c)))
            }
            /// @ast-id 675 @src 0:27435:28522  "function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {..."
            function fun_spendAllowance(var_owner, var_spender, var_amount)
            {
                /// @src 0:27586:27618  "if (spender == _PERMIT2) return;"
                if /** @src 0:27590:27609  "spender == _PERMIT2" */ eq(/** @src 1:225:2230  "contract SoladyToken is ERC20 {..." */ and(/** @src 0:27590:27609  "spender == _PERMIT2" */ var_spender, /** @src 0:8384:8723  "assembly {..." */ sub(shl(160, 1), 1)), /** @src 0:5890:5932  "0x000000000022D473030F116dDEE9F6B43aC78BA3" */ 0x22d473030f116ddee9f6b43ac78ba3)
                /// @src 0:27586:27618  "if (spender == _PERMIT2) return;"
                {
                    /// @src 0:27611:27618  "return;"
                    leave
                }
                /// @src 0:27721:28516  "assembly {..."
                mstore(0x20, var_spender)
                mstore(0x0c, 2136907552)
                mstore(0x00, var_owner)
                let usr$allowanceSlot := keccak256(0x0c, 0x34)
                let usr$allowance := sload(usr$allowanceSlot)
                if not(usr$allowance)
                {
                    if gt(var_amount, usr$allowance)
                    {
                        mstore(0x00, 0x13be252b)
                        revert(0x1c, 0x04)
                    }
                    sstore(usr$allowanceSlot, sub(usr$allowance, var_amount))
                }
            }
            /// @ast-id 630 @src 0:24198:25317  "function _burn(address from, uint256 amount) internal virtual {..."
            function fun_burn(var_from, var_amount)
            {
                /// @src 0:24369:25256  "assembly {..."
                mstore(0x0c, 2275545506)
                mstore(0x00, var_from)
                let usr$fromBalanceSlot := keccak256(0x0c, 0x20)
                let usr$fromBalance := sload(usr$fromBalanceSlot)
                if gt(var_amount, usr$fromBalance)
                {
                    mstore(0x00, 0xf4d678b8)
                    revert(0x1c, 0x04)
                }
                sstore(usr$fromBalanceSlot, sub(usr$fromBalance, var_amount))
                sstore(96006856662521017420, sub(sload(96006856662521017420), var_amount))
                mstore(0x00, var_amount)
                log3(0x00, 0x20, 100389287136786176327247604509743168900146139575972864366142685224231313322991, and(var_from, /** @src 0:8384:8723  "assembly {..." */ sub(shl(160, 1), 1)), /** @src 0:24369:25256  "assembly {..." */ 0x00)
            }
        }
        data ".metadata" hex"a2646970667358221220b4615b8496a98f8efd46ad82c68042ddd6370c48ba5b201c28dada81c7840f4a64736f6c634300081c0033"
    }
}