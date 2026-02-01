object "Edge_516" {
    code {
        {
            /// @src 0:181:5705  "contract Edge {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("Edge_516_deployed")
            codecopy(_1, dataoffset("Edge_516_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/bench/Edge.sol"
    object "Edge_516_deployed" {
        code {
            {
                /// @src 0:181:5705  "contract Edge {..."
                mstore(64, 128)
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x00819439 { external_fun_getBlockInfo() }
                    case 0x0a8ef17a {
                        external_fun_tryCallWithReason()
                    }
                    case 0x0e95a841 { external_fun_mayPanic() }
                    case 0x21cae483 { external_fun_getChainInfo() }
                    case 0x2c49bf51 { external_fun_gasHeavyLoop() }
                    case 0x2e49d78b { external_fun_setStatus() }
                    case 0x3f88ca72 { external_fun_tryCall() }
                    case 0x45bcc413 { external_fun_uintToStatus() }
                    case 0x4926c4c6 { external_fun_revertEmpty() }
                    case 0x4e69d560 { external_fun_getStatus() }
                    case 0x502178de { external_fun_requireValue() }
                    case 0x54ccfcf6 {
                        external_fun_revertZeroValue()
                    }
                    case 0x585da3e6 { external_fun_statusToUint() }
                    case 0x5e878508 { external_fun_getTxInfo() }
                    case 0x67ebb3ef { external_fun_requireTrue() }
                    case 0x6de0e656 {
                        external_fun_assertCondition()
                    }
                    case 0x81ea4408 { external_fun_getCodeHash() }
                    case 0x8f46a686 {
                        external_fun_revertUnauthorized()
                    }
                    case 0x90042baf { external_fun_createContract() }
                    case 0x9a9b5d41 { external_fun_revertMessage() }
                    case 0x9ddd1ea1 {
                        external_fun_tryCallWithPanic()
                    }
                    case 0xadaae636 { external_fun_getMsgInfo() }
                    case 0xb51c4f96 { external_fun_getCodeSize() }
                    case 0xd4e6a2b0 { external_fun_revertCustom() }
                    case 0xd78d008b { external_fun_mayFail() }
                    case 0xe9413d38 { external_fun_getBlockhash() }
                    case 0xeca7ed0a { external_fun_checkGas() }
                    case 0xef8a9235 { external_fun_getStatus() }
                    case 0xf8b2cb4f { external_fun_getBalance() }
                    case 0xfdf45d9e {
                        external_fun_create2Contract()
                    }
                }
                if iszero(calldatasize()) { stop() }
                stop()
            }
            function external_fun_getBlockInfo()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                let memPos := mload(64)
                mstore(memPos, /** @src 0:3943:3955  "block.number" */ number())
                /// @src 0:181:5705  "contract Edge {..."
                mstore(add(memPos, 32), /** @src 0:3957:3972  "block.timestamp" */ timestamp())
                /// @src 0:181:5705  "contract Edge {..."
                mstore(add(memPos, 64), /** @src 0:3974:3988  "block.coinbase" */ coinbase())
                /// @src 0:181:5705  "contract Edge {..."
                return(memPos, 96)
            }
            function abi_decode_uint256(dataEnd) -> value0
            {
                if slt(add(dataEnd, not(3)), 32) { revert(0, 0) }
                value0 := calldataload(4)
            }
            function external_fun_tryCallWithReason()
            {
                if callvalue() { revert(0, 0) }
                let ret, ret_1 := fun_tryCallWithReason(abi_decode_uint256(calldatasize()))
                let memPos := mload(64)
                mstore(memPos, iszero(iszero(ret)))
                mstore(add(memPos, 32), 64)
                let length := mload(ret_1)
                mstore(add(memPos, 64), length)
                mcopy(add(memPos, 96), add(ret_1, 32), length)
                mstore(add(add(memPos, length), 96), /** @src -1:-1:-1 */ 0)
                /// @src 0:181:5705  "contract Edge {..."
                return(memPos, add(sub(add(memPos, and(add(length, 31), not(31))), memPos), 96))
            }
            function abi_encode_uint256(headStart, value0) -> tail
            {
                tail := add(headStart, 32)
                mstore(headStart, value0)
            }
            function external_fun_mayPanic()
            {
                if callvalue() { revert(0, 0) }
                let _1 := abi_decode_uint256(calldatasize())
                if iszero(_1)
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:181:5705  "contract Edge {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x12)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:181:5705  "contract Edge {..." */ 0x24)
                }
                let memPos := mload(64)
                mstore(memPos, div(/** @src 0:3403:3406  "100" */ 0x64, /** @src 0:181:5705  "contract Edge {..." */ _1))
                return(memPos, 32)
            }
            function external_fun_getChainInfo()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                let memPos := mload(64)
                mstore(memPos, /** @src 0:4252:4265  "block.chainid" */ chainid())
                /// @src 0:181:5705  "contract Edge {..."
                mstore(add(memPos, 32), /** @src 0:4285:4298  "block.basefee" */ basefee())
                /// @src 0:181:5705  "contract Edge {..."
                return(memPos, 64)
            }
            function external_fun_gasHeavyLoop()
            {
                if callvalue() { revert(0, 0) }
                let var_n := abi_decode_uint256(calldatasize())
                /// @src 0:3633:3655  "if (n > 1000) n = 1000"
                if /** @src 0:3637:3645  "n > 1000" */ gt(var_n, /** @src 0:3641:3645  "1000" */ 0x03e8)
                /// @src 0:3633:3655  "if (n > 1000) n = 1000"
                {
                    /// @src 0:3647:3655  "n = 1000"
                    var_n := /** @src 0:3641:3645  "1000" */ 0x03e8
                }
                /// @src 0:3665:3680  "uint256 sum = 0"
                let var_sum := /** @src -1:-1:-1 */ 0
                /// @src 0:3695:3708  "uint256 i = 0"
                let var_i := /** @src -1:-1:-1 */ 0
                /// @src 0:3690:3779  "for (uint256 i = 0; i < n; i++) {..."
                for { }
                /** @src 0:3710:3715  "i < n" */ lt(var_i, var_n)
                /// @src 0:3695:3708  "uint256 i = 0"
                {
                    /// @src 0:3717:3720  "i++"
                    var_i := /** @src 0:181:5705  "contract Edge {..." */ add(/** @src 0:3717:3720  "i++" */ var_i, /** @src 0:181:5705  "contract Edge {..." */ 1)
                }
                /// @src 0:3717:3720  "i++"
                {
                    /// @src 0:3743:3748  "i * i"
                    let product := /** @src -1:-1:-1 */ 0
                    /// @src 0:181:5705  "contract Edge {..."
                    product := mul(var_i, var_i)
                    if iszero(or(iszero(var_i), eq(var_i, div(product, var_i)))) { panic_error_0x11() }
                    let sum := add(var_sum, product)
                    if gt(var_sum, sum) { panic_error_0x11() }
                    /// @src 0:3736:3748  "sum += i * i"
                    var_sum := sum
                }
                /// @src 0:181:5705  "contract Edge {..."
                let memPos := mload(64)
                mstore(memPos, var_sum)
                return(memPos, 32)
            }
            function external_fun_setStatus()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 32)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:181:5705  "contract Edge {..."
                let value := calldataload(4)
                let _1 := iszero(lt(value, 5))
                if _1
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:181:5705  "contract Edge {..."
                _1 := /** @src -1:-1:-1 */ 0
                /// @src 0:181:5705  "contract Edge {..."
                let value_1 := and(sload(/** @src -1:-1:-1 */ 0), /** @src 0:181:5705  "contract Edge {..." */ not(255))
                sstore(/** @src -1:-1:-1 */ 0, /** @src 0:181:5705  "contract Edge {..." */ or(value_1, and(value, 255)))
                return(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 0:181:5705  "contract Edge {..."
            function abi_encode_bool_uint256(headStart, value0, value1) -> tail
            {
                tail := add(headStart, 64)
                mstore(headStart, iszero(iszero(value0)))
                mstore(add(headStart, 32), value1)
            }
            function external_fun_tryCall()
            {
                if callvalue() { revert(0, 0) }
                let ret, ret_1 := fun_tryCall(abi_decode_uint256(calldatasize()))
                let memPos := mload(64)
                return(memPos, sub(abi_encode_bool_uint256(memPos, ret, ret_1), memPos))
            }
            function abi_encode_enum_Status(headStart, value0) -> tail
            {
                tail := add(headStart, 32)
                if iszero(lt(value0, 5))
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:181:5705  "contract Edge {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x21)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:181:5705  "contract Edge {..." */ 0x24)
                }
                mstore(headStart, value0)
            }
            function external_fun_uintToStatus()
            {
                if callvalue() { revert(0, 0) }
                let _1 := abi_decode_uint256(calldatasize())
                if /** @src 0:1117:1149  "val <= uint256(type(Status).max)" */ gt(_1, /** @src 0:181:5705  "contract Edge {..." */ 4)
                {
                    let memPtr := mload(64)
                    mstore(memPtr, shl(229, 4594637))
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 14)
                    mstore(add(memPtr, 68), "invalid status")
                    revert(memPtr, 100)
                }
                if iszero(lt(_1, 5))
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:181:5705  "contract Edge {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x21)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:181:5705  "contract Edge {..." */ 0x24)
                }
                let memPos := mload(64)
                return(memPos, sub(abi_encode_enum_Status(memPos, _1), memPos))
            }
            function external_fun_revertEmpty()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                revert(0, 0)
            }
            function external_fun_getStatus()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                let value := and(sload(0), 0xff)
                let memPos := mload(64)
                return(memPos, sub(abi_encode_enum_Status(memPos, value), memPos))
            }
            function external_fun_requireValue()
            {
                if callvalue() { revert(0, 0) }
                let _1 := abi_decode_uint256(calldatasize())
                if /** @src 0:1977:1982  "x > 0" */ iszero(_1)
                /// @src 0:181:5705  "contract Edge {..."
                {
                    let memPtr := mload(64)
                    mstore(memPtr, shl(229, 4594637))
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 16)
                    mstore(add(memPtr, 68), "must be positive")
                    revert(memPtr, 100)
                }
                let memPos := mload(64)
                mstore(memPos, _1)
                return(memPos, 32)
            }
            function external_fun_revertZeroValue()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                /// @src 0:1587:1598  "ZeroValue()"
                mstore(/** @src 0:181:5705  "contract Edge {..." */ 0, /** @src 0:1587:1598  "ZeroValue()" */ shl(224, 0x7c946ed7))
                revert(/** @src 0:181:5705  "contract Edge {..." */ 0, 4)
            }
            function external_fun_statusToUint()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                let value := and(sload(0), 0xff)
                if iszero(lt(value, 5))
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x21)
                    revert(0, 0x24)
                }
                let memPos := mload(64)
                mstore(memPos, value)
                return(memPos, 32)
            }
            function external_fun_getTxInfo()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                let memPos := mload(64)
                mstore(memPos, /** @src 0:4612:4621  "tx.origin" */ origin())
                /// @src 0:181:5705  "contract Edge {..."
                mstore(add(memPos, 32), /** @src 0:4623:4634  "tx.gasprice" */ gasprice())
                /// @src 0:181:5705  "contract Edge {..."
                return(memPos, 64)
            }
            function abi_decode_bool(dataEnd) -> value0
            {
                if slt(add(dataEnd, not(3)), 32) { revert(0, 0) }
                let value := calldataload(4)
                if iszero(eq(value, iszero(iszero(value))))
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:181:5705  "contract Edge {..."
                value0 := value
            }
            function external_fun_requireTrue()
            {
                if callvalue() { revert(0, 0) }
                if iszero(abi_decode_bool(calldatasize()))
                {
                    let memPtr := mload(64)
                    mstore(memPtr, shl(229, 4594637))
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 16)
                    mstore(add(memPtr, 68), "condition failed")
                    revert(memPtr, 100)
                }
                let memPos := mload(64)
                mstore(memPos, /** @src 0:1877:1881  "true" */ 0x01)
                /// @src 0:181:5705  "contract Edge {..."
                return(memPos, 32)
            }
            function external_fun_assertCondition()
            {
                if callvalue() { revert(0, 0) }
                if iszero(abi_decode_bool(calldatasize()))
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:181:5705  "contract Edge {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x01)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:181:5705  "contract Edge {..." */ 0x24)
                }
                let memPos := mload(64)
                mstore(memPos, /** @src 0:2184:2188  "true" */ 0x01)
                /// @src 0:181:5705  "contract Edge {..."
                return(memPos, 32)
            }
            function abi_decode_address(dataEnd) -> value0
            {
                if slt(add(dataEnd, not(3)), 32) { revert(0, 0) }
                let value := calldataload(4)
                if iszero(eq(value, and(value, sub(shl(160, 1), 1))))
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:181:5705  "contract Edge {..."
                value0 := value
            }
            function external_fun_getCodeHash()
            {
                if callvalue() { revert(0, 0) }
                /// @src 0:5038:5096  "assembly {..."
                let var_hash := extcodehash(/** @src 0:181:5705  "contract Edge {..." */ abi_decode_address(calldatasize()))
                let memPos := mload(64)
                mstore(memPos, var_hash)
                return(memPos, 32)
            }
            function external_fun_revertUnauthorized()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                /// @src 0:1672:1696  "Unauthorized(msg.sender)"
                mstore(/** @src 0:181:5705  "contract Edge {..." */ 0, /** @src 0:1672:1696  "Unauthorized(msg.sender)" */ shl(225, 0x472511eb))
                /// @src 0:181:5705  "contract Edge {..."
                mstore(4, /** @src 0:1685:1695  "msg.sender" */ caller())
                /// @src 0:1672:1696  "Unauthorized(msg.sender)"
                revert(/** @src 0:181:5705  "contract Edge {..." */ 0, 36)
            }
            function panic_error_0x41()
            {
                mstore(0, shl(224, 0x4e487b71))
                mstore(4, 0x41)
                revert(0, 0x24)
            }
            function finalize_allocation(memPtr, size)
            {
                let newFreePtr := add(memPtr, and(add(size, 31), not(31)))
                if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr)) { panic_error_0x41() }
                mstore(64, newFreePtr)
            }
            function array_allocation_size_bytes(length) -> size
            {
                if gt(length, 0xffffffffffffffff) { panic_error_0x41() }
                size := add(and(add(length, 31), not(31)), 0x20)
            }
            function abi_decode_bytes(offset, end) -> array
            {
                if iszero(slt(add(offset, 0x1f), end)) { revert(0, 0) }
                let length := calldataload(offset)
                let _1 := array_allocation_size_bytes(length)
                let memPtr := mload(64)
                finalize_allocation(memPtr, _1)
                mstore(memPtr, length)
                if gt(add(add(offset, length), 0x20), end)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:181:5705  "contract Edge {..."
                calldatacopy(add(memPtr, 0x20), add(offset, 0x20), length)
                mstore(add(add(memPtr, length), 0x20), /** @src -1:-1:-1 */ 0)
                /// @src 0:181:5705  "contract Edge {..."
                array := memPtr
            }
            function abi_encode_address(headStart, value0) -> tail
            {
                tail := add(headStart, 32)
                mstore(headStart, and(value0, sub(shl(160, 1), 1)))
            }
            function external_fun_createContract()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 32)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:181:5705  "contract Edge {..."
                let offset := calldataload(4)
                if gt(offset, 0xffffffffffffffff)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:181:5705  "contract Edge {..."
                let value0 := abi_decode_bytes(add(4, offset), calldatasize())
                /// @src 0:5267:5355  "assembly {..."
                let var_addr := create(/** @src -1:-1:-1 */ 0, /** @src 0:5267:5355  "assembly {..." */ add(value0, /** @src 0:181:5705  "contract Edge {..." */ 32), /** @src 0:5267:5355  "assembly {..." */ mload(value0))
                /// @src 0:181:5705  "contract Edge {..."
                if /** @src 0:5372:5390  "addr != address(0)" */ iszero(/** @src 0:181:5705  "contract Edge {..." */ and(/** @src 0:5372:5390  "addr != address(0)" */ var_addr, /** @src 0:181:5705  "contract Edge {..." */ sub(shl(160, 1), 1)))
                {
                    let memPtr := mload(64)
                    mstore(memPtr, shl(229, 4594637))
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 13)
                    mstore(add(memPtr, 68), "create failed")
                    revert(memPtr, 100)
                }
                let memPos := mload(64)
                return(memPos, sub(abi_encode_address(memPos, var_addr), memPos))
            }
            function external_fun_revertMessage()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 32)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:181:5705  "contract Edge {..."
                let offset := calldataload(4)
                if gt(offset, 0xffffffffffffffff)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:181:5705  "contract Edge {..."
                if iszero(slt(add(offset, 35), calldatasize()))
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:181:5705  "contract Edge {..."
                let length := calldataload(add(4, offset))
                if gt(length, 0xffffffffffffffff)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:181:5705  "contract Edge {..."
                if gt(add(add(offset, length), 36), calldatasize())
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:1391:1403  "revert(msg_)"
                let _1 := /** @src 0:181:5705  "contract Edge {..." */ mload(64)
                /// @src 0:1391:1403  "revert(msg_)"
                mstore(_1, /** @src 0:181:5705  "contract Edge {..." */ shl(229, 4594637))
                mstore(/** @src 0:1391:1403  "revert(msg_)" */ add(_1, /** @src 0:181:5705  "contract Edge {..." */ 4), 32)
                mstore(add(/** @src 0:1391:1403  "revert(msg_)" */ _1, /** @src 0:181:5705  "contract Edge {..." */ 36), length)
                calldatacopy(add(/** @src 0:1391:1403  "revert(msg_)" */ _1, /** @src 0:181:5705  "contract Edge {..." */ 68), add(offset, 36), length)
                mstore(add(add(/** @src 0:1391:1403  "revert(msg_)" */ _1, /** @src 0:181:5705  "contract Edge {..." */ length), 68), /** @src -1:-1:-1 */ 0)
                /// @src 0:1391:1403  "revert(msg_)"
                revert(_1, add(sub(/** @src 0:181:5705  "contract Edge {..." */ add(/** @src 0:1391:1403  "revert(msg_)" */ _1, /** @src 0:181:5705  "contract Edge {..." */ and(add(length, 0x1f), not(31))), /** @src 0:1391:1403  "revert(msg_)" */ _1), /** @src 0:181:5705  "contract Edge {..." */ 68))
            }
            function external_fun_tryCallWithPanic()
            {
                if callvalue() { revert(0, 0) }
                let ret, ret_1 := fun_tryCallWithPanic(abi_decode_uint256(calldatasize()))
                let memPos := mload(64)
                return(memPos, sub(abi_encode_bool_uint256(memPos, ret, ret_1), memPos))
            }
            function external_fun_getMsgInfo()
            {
                if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                let memPos := mload(64)
                mstore(memPos, /** @src 0:4444:4454  "msg.sender" */ caller())
                /// @src 0:181:5705  "contract Edge {..."
                mstore(add(memPos, 32), /** @src 0:4456:4465  "msg.value" */ callvalue())
                /// @src 0:181:5705  "contract Edge {..."
                mstore(add(memPos, 64), /** @src 0:4467:4474  "msg.sig" */ and(calldataload(/** @src 0:181:5705  "contract Edge {..." */ 0), /** @src 0:4467:4474  "msg.sig" */ shl(224, 0xffffffff)))
                /// @src 0:181:5705  "contract Edge {..."
                return(memPos, 96)
            }
            function external_fun_getCodeSize()
            {
                if callvalue() { revert(0, 0) }
                /// @src 0:4886:4944  "assembly {..."
                let var_size := extcodesize(/** @src 0:181:5705  "contract Edge {..." */ abi_decode_address(calldatasize()))
                let memPos := mload(64)
                mstore(memPos, var_size)
                return(memPos, 32)
            }
            function external_fun_revertCustom()
            {
                if callvalue() { revert(0, 0) }
                let _1 := abi_decode_uint256(calldatasize())
                /// @src 0:1483:1516  "CustomError(code, \"custom error\")"
                let _2 := /** @src 0:181:5705  "contract Edge {..." */ mload(64)
                /// @src 0:1483:1516  "CustomError(code, \"custom error\")"
                mstore(_2, shl(224, 0x97ea5a2f))
                /// @src 0:181:5705  "contract Edge {..."
                mstore(/** @src 0:1483:1516  "CustomError(code, \"custom error\")" */ add(_2, /** @src 0:181:5705  "contract Edge {..." */ 4), _1)
                mstore(add(/** @src 0:1483:1516  "CustomError(code, \"custom error\")" */ _2, /** @src 0:181:5705  "contract Edge {..." */ 36), 64)
                mstore(add(/** @src 0:1483:1516  "CustomError(code, \"custom error\")" */ _2, /** @src 0:181:5705  "contract Edge {..." */ 68), 12)
                mstore(add(/** @src 0:1483:1516  "CustomError(code, \"custom error\")" */ _2, /** @src 0:181:5705  "contract Edge {..." */ 100), "custom error")
                /// @src 0:1483:1516  "CustomError(code, \"custom error\")"
                revert(_2, 132)
            }
            /// @src 0:181:5705  "contract Edge {..."
            function external_fun_mayFail()
            {
                if callvalue() { revert(0, 0) }
                let _1 := abi_decode_uint256(calldatasize())
                if iszero(/** @src 0:3211:3218  "x < 100" */ lt(_1, /** @src 0:3215:3218  "100" */ 0x64))
                /// @src 0:181:5705  "contract Edge {..."
                {
                    let memPtr := mload(64)
                    mstore(memPtr, shl(229, 4594637))
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 9)
                    mstore(add(memPtr, 68), "too large")
                    revert(memPtr, /** @src 0:3215:3218  "100" */ 0x64)
                }
                /// @src 0:181:5705  "contract Edge {..."
                let product := shl(1, _1)
                if iszero(or(iszero(_1), eq(/** @src 0:3253:3254  "2" */ 0x02, /** @src 0:181:5705  "contract Edge {..." */ div(product, _1)))) { panic_error_0x11() }
                let memPos := mload(64)
                let tail := /** @src -1:-1:-1 */ 0
                /// @src 0:181:5705  "contract Edge {..."
                tail := add(memPos, 32)
                mstore(memPos, product)
                return(memPos, sub(tail, memPos))
            }
            function external_fun_getBlockhash()
            {
                if callvalue() { revert(0, 0) }
                /// @src 0:4084:4110  "return blockhash(blockNum)"
                let var := /** @src 0:4091:4110  "blockhash(blockNum)" */ blockhash(/** @src 0:181:5705  "contract Edge {..." */ abi_decode_uint256(calldatasize()))
                let memPos := mload(64)
                mstore(memPos, var)
                return(memPos, 32)
            }
            function external_fun_checkGas()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                let ret := /** @src 0:3536:3545  "gasleft()" */ gas()
                /// @src 0:181:5705  "contract Edge {..."
                let memPos := mload(64)
                mstore(memPos, ret)
                return(memPos, 32)
            }
            function external_fun_getBalance()
            {
                if callvalue() { revert(0, 0) }
                /// @src 0:4772:4791  "return addr.balance"
                let var := /** @src 0:4779:4791  "addr.balance" */ balance(/** @src 0:181:5705  "contract Edge {..." */ abi_decode_address(calldatasize()))
                let memPos := mload(64)
                mstore(memPos, var)
                return(memPos, 32)
            }
            function external_fun_create2Contract()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), not(3)), 64)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:181:5705  "contract Edge {..."
                let offset := calldataload(4)
                if gt(offset, 0xffffffffffffffff)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:181:5705  "contract Edge {..."
                let value0 := abi_decode_bytes(add(4, offset), calldatasize())
                /// @src 0:5547:5642  "assembly {..."
                let var_addr := create2(/** @src -1:-1:-1 */ 0, /** @src 0:5547:5642  "assembly {..." */ add(value0, /** @src 0:181:5705  "contract Edge {..." */ 32), /** @src 0:5547:5642  "assembly {..." */ mload(value0), /** @src 0:181:5705  "contract Edge {..." */ calldataload(36))
                if /** @src 0:5659:5677  "addr != address(0)" */ iszero(/** @src 0:181:5705  "contract Edge {..." */ and(/** @src 0:5659:5677  "addr != address(0)" */ var_addr, /** @src 0:181:5705  "contract Edge {..." */ sub(shl(160, 1), 1)))
                {
                    let memPtr := mload(64)
                    mstore(memPtr, shl(229, 4594637))
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 14)
                    mstore(add(memPtr, 68), "create2 failed")
                    revert(memPtr, 100)
                }
                let memPos := mload(64)
                return(memPos, sub(abi_encode_address(memPos, var_addr), memPos))
            }
            function abi_decode_uint256_fromMemory(headStart, dataEnd) -> value0
            {
                if slt(sub(dataEnd, headStart), 32) { revert(0, 0) }
                value0 := mload(headStart)
            }
            function allocate_memory_array_string() -> memPtr
            {
                let size := /** @src -1:-1:-1 */ 0
                /// @src 0:181:5705  "contract Edge {..."
                if gt(/** @src -1:-1:-1 */ 0, /** @src 0:181:5705  "contract Edge {..." */ 0xffffffffffffffff) { panic_error_0x41() }
                size := add(and(add(/** @src -1:-1:-1 */ 0, /** @src 0:181:5705  "contract Edge {..." */ 31), not(31)), 0x20)
                let memPtr_1 := mload(64)
                finalize_allocation(memPtr_1, size)
                memPtr := memPtr_1
                mstore(memPtr_1, 0)
            }
            function return_data_selector() -> sig
            {
                if gt(returndatasize(), 3)
                {
                    returndatacopy(0, 0, 4)
                    sig := shr(224, mload(0))
                }
            }
            function try_decode_error_message() -> ret
            {
                if lt(returndatasize(), 0x44) { leave }
                let data := mload(64)
                returndatacopy(data, 4, add(returndatasize(), not(3)))
                let offset := mload(data)
                if or(gt(offset, 0xffffffffffffffff), gt(add(offset, 0x24), returndatasize())) { leave }
                let msg := add(data, offset)
                let length := mload(msg)
                if gt(length, 0xffffffffffffffff) { leave }
                if gt(add(add(msg, length), 0x20), add(add(data, returndatasize()), not(3))) { leave }
                finalize_allocation(data, add(add(offset, length), 0x20))
                ret := msg
            }
            function copy_literal_to_memory_24695ee963d29f0f52edfdea1e830d2fcfc9052d5ba70b194bddd0afbbc89765() -> memPtr
            {
                let size := /** @src -1:-1:-1 */ 0
                /// @src 0:181:5705  "contract Edge {..."
                let _1 := /** @src -1:-1:-1 */ 0
                /// @src 0:181:5705  "contract Edge {..."
                _1 := /** @src -1:-1:-1 */ 0
                /// @src 0:181:5705  "contract Edge {..."
                size := 64
                let memPtr_1 := mload(64)
                finalize_allocation(memPtr_1, 64)
                mstore(memPtr_1, 7)
                memPtr := memPtr_1
                mstore(add(memPtr_1, 32), "unknown")
            }
            /// @ast-id 247 @src 0:2496:2827  "function tryCallWithReason(..."
            function fun_tryCallWithReason(var_x) -> var, var_mpos
            {
                /// @src 0:2571:2575  "bool"
                var := /** @src 0:181:5705  "contract Edge {..." */ 0
                /// @src 0:2577:2590  "string memory"
                var_mpos := /** @src 0:181:5705  "contract Edge {..." */ 96
                /// @src 0:2606:2621  "this.mayFail(x)"
                let _1 := /** @src 0:181:5705  "contract Edge {..." */ mload(64)
                /// @src 0:2606:2621  "this.mayFail(x)"
                mstore(_1, /** @src 0:181:5705  "contract Edge {..." */ shl(224, 0xd78d008b))
                /// @src 0:2606:2621  "this.mayFail(x)"
                let trySuccessCondition := staticcall(gas(), /** @src 0:2606:2610  "this" */ address(), /** @src 0:2606:2621  "this.mayFail(x)" */ _1, sub(abi_encode_uint256(add(_1, 4), var_x), _1), _1, 32)
                let expr := /** @src 0:181:5705  "contract Edge {..." */ 0
                /// @src 0:2606:2621  "this.mayFail(x)"
                if trySuccessCondition
                {
                    let _2 := 32
                    if gt(32, returndatasize()) { _2 := returndatasize() }
                    finalize_allocation(_1, _2)
                    expr := abi_decode_uint256_fromMemory(_1, add(_1, _2))
                }
                /// @src 0:2602:2821  "try this.mayFail(x) returns (uint256) {..."
                switch iszero(trySuccessCondition)
                case 0 {
                    /// @src 0:2654:2671  "return (true, \"\")"
                    var := /** @src 0:2662:2666  "true" */ 0x01
                    /// @src 0:2654:2671  "return (true, \"\")"
                    var_mpos := /** @src 0:181:5705  "contract Edge {..." */ allocate_memory_array_string()
                    /// @src 0:2654:2671  "return (true, \"\")"
                    leave
                }
                default /// @src 0:2602:2821  "try this.mayFail(x) returns (uint256) {..."
                {
                    if eq(147028384, return_data_selector())
                    {
                        /// @src 0:2683:2764  "catch Error(string memory reason) {..."
                        let _3 := try_decode_error_message()
                        if _3
                        {
                            /// @src 0:2731:2753  "return (false, reason)"
                            var := /** @src 0:181:5705  "contract Edge {..." */ 0
                            /// @src 0:2731:2753  "return (false, reason)"
                            var_mpos := _3
                            leave
                        }
                    }
                    /// @src 0:2785:2810  "return (false, \"unknown\")"
                    var := /** @src 0:181:5705  "contract Edge {..." */ 0
                    /// @src 0:2785:2810  "return (false, \"unknown\")"
                    var_mpos := /** @src 0:181:5705  "contract Edge {..." */ copy_literal_to_memory_24695ee963d29f0f52edfdea1e830d2fcfc9052d5ba70b194bddd0afbbc89765()
                    /// @src 0:2785:2810  "return (false, \"unknown\")"
                    leave
                }
            }
            /// @src 0:181:5705  "contract Edge {..."
            function panic_error_0x11()
            {
                mstore(0, shl(224, 0x4e487b71))
                mstore(4, 0x11)
                revert(0, 0x24)
            }
            /// @ast-id 208 @src 0:2249:2490  "function tryCall(..."
            function fun_tryCall(var_x) -> var_success, var_result
            {
                /// @src 0:2358:2373  "this.mayFail(x)"
                let _1 := /** @src 0:181:5705  "contract Edge {..." */ mload(64)
                /// @src 0:2358:2373  "this.mayFail(x)"
                mstore(_1, /** @src 0:181:5705  "contract Edge {..." */ shl(224, 0xd78d008b))
                mstore(/** @src 0:2358:2373  "this.mayFail(x)" */ add(_1, 4), /** @src 0:181:5705  "contract Edge {..." */ var_x)
                /// @src 0:2358:2373  "this.mayFail(x)"
                let trySuccessCondition := staticcall(gas(), /** @src 0:2358:2362  "this" */ address(), /** @src 0:2358:2373  "this.mayFail(x)" */ _1, 36, _1, /** @src 0:181:5705  "contract Edge {..." */ 32)
                /// @src 0:2358:2373  "this.mayFail(x)"
                let expr := /** @src -1:-1:-1 */ 0
                /// @src 0:2358:2373  "this.mayFail(x)"
                if trySuccessCondition
                {
                    let _2 := /** @src 0:181:5705  "contract Edge {..." */ 32
                    /// @src 0:2358:2373  "this.mayFail(x)"
                    if gt(/** @src 0:181:5705  "contract Edge {..." */ 32, /** @src 0:2358:2373  "this.mayFail(x)" */ returndatasize()) { _2 := returndatasize() }
                    finalize_allocation(_1, _2)
                    expr := abi_decode_uint256_fromMemory(_1, add(_1, _2))
                }
                /// @src 0:2354:2484  "try this.mayFail(x) returns (uint256 r) {..."
                switch iszero(trySuccessCondition)
                case 0 {
                    /// @src 0:2408:2424  "return (true, r)"
                    var_success := /** @src 0:2416:2420  "true" */ 0x01
                    /// @src 0:2408:2424  "return (true, r)"
                    var_result := expr
                    leave
                }
                default /// @src 0:2354:2484  "try this.mayFail(x) returns (uint256 r) {..."
                {
                    /// @src 0:2456:2473  "return (false, 0)"
                    var_success := /** @src -1:-1:-1 */ 0
                    /// @src 0:2456:2473  "return (false, 0)"
                    var_result := /** @src -1:-1:-1 */ 0
                    /// @src 0:2456:2473  "return (false, 0)"
                    leave
                }
            }
            /// @src 0:181:5705  "contract Edge {..."
            function try_decode_panic_data() -> success, data
            {
                if gt(returndatasize(), 0x23)
                {
                    returndatacopy(0, 4, 0x20)
                    success := 1
                    data := mload(0)
                }
            }
            /// @ast-id 286 @src 0:2833:3127  "function tryCallWithPanic(uint256 x) external view returns (bool, uint256) {..."
            function fun_tryCallWithPanic(var_x) -> var, var_1
            {
                /// @src 0:2893:2897  "bool"
                var := /** @src 0:181:5705  "contract Edge {..." */ 0
                /// @src 0:2899:2906  "uint256"
                var_1 := /** @src 0:181:5705  "contract Edge {..." */ 0
                /// @src 0:2922:2938  "this.mayPanic(x)"
                let _1 := /** @src 0:181:5705  "contract Edge {..." */ mload(64)
                /// @src 0:2922:2938  "this.mayPanic(x)"
                mstore(_1, /** @src 0:181:5705  "contract Edge {..." */ shl(224, 0x0e95a841))
                /// @src 0:2922:2938  "this.mayPanic(x)"
                let trySuccessCondition := staticcall(gas(), /** @src 0:2922:2926  "this" */ address(), /** @src 0:2922:2938  "this.mayPanic(x)" */ _1, sub(abi_encode_uint256(add(_1, 4), var_x), _1), _1, 32)
                let expr := /** @src 0:181:5705  "contract Edge {..." */ 0
                /// @src 0:2922:2938  "this.mayPanic(x)"
                if trySuccessCondition
                {
                    let _2 := 32
                    if gt(32, returndatasize()) { _2 := returndatasize() }
                    finalize_allocation(_1, _2)
                    expr := abi_decode_uint256_fromMemory(_1, add(_1, _2))
                }
                /// @src 0:2918:3121  "try this.mayPanic(x) returns (uint256) {..."
                switch iszero(trySuccessCondition)
                case 0 {
                    /// @src 0:2971:2987  "return (true, 0)"
                    var := /** @src 0:2979:2983  "true" */ 0x01
                    /// @src 0:2971:2987  "return (true, 0)"
                    var_1 := /** @src 0:181:5705  "contract Edge {..." */ 0
                    /// @src 0:2971:2987  "return (true, 0)"
                    leave
                }
                default /// @src 0:2918:3121  "try this.mayPanic(x) returns (uint256) {..."
                {
                    if eq(1313373041, return_data_selector())
                    {
                        /// @src 0:2999:3070  "catch Panic(uint256 code) {..."
                        let _3, _4 := try_decode_panic_data()
                        if _3
                        {
                            /// @src 0:3039:3059  "return (false, code)"
                            var := /** @src 0:181:5705  "contract Edge {..." */ 0
                            /// @src 0:3039:3059  "return (false, code)"
                            var_1 := _4
                            leave
                        }
                    }
                    /// @src 0:3091:3110  "return (false, 999)"
                    var := /** @src 0:181:5705  "contract Edge {..." */ 0
                    /// @src 0:3091:3110  "return (false, 999)"
                    var_1 := /** @src 0:3106:3109  "999" */ 0x03e7
                    /// @src 0:3091:3110  "return (false, 999)"
                    leave
                }
            }
        }
        data ".metadata" hex"a2646970667358221220331e96b4f7cf62ec126673fb660c55814874336261216d27f3bb99519d6e18b564736f6c634300081c0033"
    }
}