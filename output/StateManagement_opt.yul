object "StateManagement_444" {
    code {
        {
            /// @src 0:176:4956  "contract StateManagement {..."
            mstore(64, memoryguard(0xe0))
            if callvalue() { revert(0, 0) }
            /// @src 0:1412:1441  "DEPLOY_TIME = block.timestamp"
            mstore(128, /** @src 0:1426:1441  "block.timestamp" */ timestamp())
            /// @src 0:1451:1472  "DEPLOYER = msg.sender"
            mstore(160, /** @src 0:1462:1472  "msg.sender" */ caller())
            /// @src 0:1506:1545  "block.number > 0 ? block.number - 1 : 0"
            let expr := /** @src 0:1521:1522  "0" */ 0x00
            /// @src 0:1506:1545  "block.number > 0 ? block.number - 1 : 0"
            switch /** @src 0:1506:1522  "block.number > 0" */ iszero(iszero(/** @src 0:1506:1518  "block.number" */ number()))
            case /** @src 0:1506:1545  "block.number > 0 ? block.number - 1 : 0" */ 0 {
                expr := /** @src 0:1521:1522  "0" */ 0x00
            }
            default /// @src 0:1506:1545  "block.number > 0 ? block.number - 1 : 0"
            {
                /// @src 0:176:4956  "contract StateManagement {..."
                let diff := add(/** @src 0:1506:1518  "block.number" */ number(), /** @src 0:176:4956  "contract StateManagement {..." */ not(0))
                if gt(diff, /** @src 0:1506:1518  "block.number" */ number())
                /// @src 0:176:4956  "contract StateManagement {..."
                {
                    mstore(/** @src 0:1521:1522  "0" */ 0x00, /** @src 0:176:4956  "contract StateManagement {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x11)
                    revert(/** @src 0:1521:1522  "0" */ 0x00, /** @src 0:176:4956  "contract StateManagement {..." */ 0x24)
                }
                /// @src 0:1506:1545  "block.number > 0 ? block.number - 1 : 0"
                expr := diff
            }
            /// @src 0:1482:1546  "DEPLOY_HASH = blockhash(block.number > 0 ? block.number - 1 : 0)"
            mstore(192, /** @src 0:1496:1546  "blockhash(block.number > 0 ? block.number - 1 : 0)" */ blockhash(expr))
            /// @src 0:176:4956  "contract StateManagement {..."
            let _1 := mload(64)
            let _2 := datasize("StateManagement_444_deployed")
            codecopy(_1, dataoffset("StateManagement_444_deployed"), _2)
            setimmutable(_1, "15", mload(/** @src 0:1412:1441  "DEPLOY_TIME = block.timestamp" */ 128))
            /// @src 0:176:4956  "contract StateManagement {..."
            setimmutable(_1, "17", mload(/** @src 0:1451:1472  "DEPLOYER = msg.sender" */ 160))
            /// @src 0:176:4956  "contract StateManagement {..."
            setimmutable(_1, "19", mload(/** @src 0:1482:1546  "DEPLOY_HASH = blockhash(block.number > 0 ? block.number - 1 : 0)" */ 192))
            /// @src 0:176:4956  "contract StateManagement {..."
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/bench/StateManagement.sol"
    object "StateManagement_444_deployed" {
        code {
            {
                /// @src 0:176:4956  "contract StateManagement {..."
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x0198214f {
                        if callvalue() { revert(0, 0) }
                        let param, param_1 := abi_decode_uint256t_uint256(calldatasize())
                        /// @src 0:4085:4137  "assembly {..."
                        tstore(param, param_1)
                        /// @src 0:176:4956  "contract StateManagement {..."
                        return(0, 0)
                    }
                    case 0x04fe64ce {
                        if callvalue() { revert(0, 0) }
                        let param_2, param_3 := abi_decode_uint256t_uint256(calldatasize())
                        /// @src 0:4558:4704  "assembly {..."
                        let usr$a := tload(param_2)
                        tstore(param_2, tload(param_3))
                        tstore(param_3, usr$a)
                        /// @src 0:176:4956  "contract StateManagement {..."
                        return(0, 0)
                    }
                    case 0x0849cc99 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        mstore(_1, sload(/** @src 0:3143:3155  "dynamicArray" */ 0x09))
                        /// @src 0:176:4956  "contract StateManagement {..."
                        return(_1, 32)
                    }
                    case 0x0c36ee80 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value := calldataload(4)
                        let _2 := iszero(iszero(value))
                        if iszero(eq(value, _2)) { revert(0, 0) }
                        let value_1 := and(sload(/** @src 0:1941:1957  "storedBool = val" */ 0x02), /** @src 0:176:4956  "contract StateManagement {..." */ not(255))
                        sstore(/** @src 0:1941:1957  "storedBool = val" */ 0x02, /** @src 0:176:4956  "contract StateManagement {..." */ or(value_1, and(_2, 255)))
                        return(0, 0)
                    }
                    case 0x0cef0fe7 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        sstore(0, calldataload(4))
                        return(0, 0)
                    }
                    case 0x142edc7a {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        /// @src 0:3262:3279  "dynamicArray[idx]"
                        let _3, _4 := storage_array_index_access_uint256_dyn(/** @src 0:176:4956  "contract StateManagement {..." */ calldataload(4))
                        let value_2 := shr(shl(3, _4), sload(/** @src 0:3262:3279  "dynamicArray[idx]" */ _3))
                        /// @src 0:176:4956  "contract StateManagement {..."
                        let memPos := mload(64)
                        mstore(memPos, value_2)
                        return(memPos, 32)
                    }
                    case 0x16cdf825 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let oldLen := sload(/** @src 0:2963:2975  "dynamicArray" */ 0x09)
                        /// @src 0:176:4956  "contract StateManagement {..."
                        if iszero(lt(oldLen, 18446744073709551616))
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x41)
                            revert(0, 0x24)
                        }
                        sstore(/** @src 0:2963:2975  "dynamicArray" */ 0x09, /** @src 0:176:4956  "contract StateManagement {..." */ add(oldLen, 1))
                        let slot, offset := storage_array_index_access_uint256_dyn(oldLen)
                        let _5 := sload(slot)
                        let shiftBits := shl(3, offset)
                        sstore(slot, or(and(_5, not(shl(shiftBits, not(0)))), shl(shiftBits, calldataload(4))))
                        return(0, 0)
                    }
                    case 0x202df7cd {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let value_3 := and(shr(128, sload(/** @src 0:973:994  "uint64 public packedE" */ 5)), /** @src 0:176:4956  "contract StateManagement {..." */ 0xffffffffffffffff)
                        let memPos_1 := mload(64)
                        mstore(memPos_1, value_3)
                        return(memPos_1, 32)
                    }
                    case 0x26fcfbcc {
                        if callvalue() { revert(0, 0) }
                        let param_4, param_5 := abi_decode_uint256t_uint256(calldatasize())
                        mstore(0, param_4)
                        mstore(0x20, /** @src 0:1201:1265  "mapping(uint256 => mapping(uint256 => uint256)) public nestedMap" */ 8)
                        /// @src 0:176:4956  "contract StateManagement {..."
                        let dataSlot := keccak256(0, 64)
                        mstore(0, param_5)
                        mstore(0x20, dataSlot)
                        let _6 := sload(keccak256(0, 64))
                        let memPos_2 := mload(64)
                        mstore(memPos_2, _6)
                        return(memPos_2, 0x20)
                    }
                    case 0x27e235e3 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        mstore(0, and(abi_decode_address(), sub(shl(160, 1), 1)))
                        mstore(32, /** @src 0:1152:1195  "mapping(address => uint256) public balances" */ 7)
                        /// @src 0:176:4956  "contract StateManagement {..."
                        let _7 := sload(keccak256(0, 64))
                        let memPos_3 := mload(64)
                        mstore(memPos_3, _7)
                        return(memPos_3, 32)
                    }
                    case 0x2c6ddcb6 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _8 := shr(128, sload(4))
                        let memPos_4 := mload(64)
                        mstore(memPos_4, _8)
                        return(memPos_4, 32)
                    }
                    case 0x384bc466 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        mstore(0, and(abi_decode_address(), sub(shl(160, 1), 1)))
                        mstore(32, /** @src 0:2571:2579  "balances" */ 0x07)
                        /// @src 0:176:4956  "contract StateManagement {..."
                        let dataSlot_1 := keccak256(0, 64)
                        let _9 := sload(/** @src 0:2571:2595  "balances[addr] += amount" */ dataSlot_1)
                        /// @src 0:176:4956  "contract StateManagement {..."
                        let sum := add(_9, calldataload(36))
                        if gt(_9, sum)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 36)
                        }
                        sstore(dataSlot_1, sum)
                        return(0, 0)
                    }
                    case 0x3e213e28 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let var_size := calldataload(4)
                        /// @src 0:3416:3444  "if (size > 1000) size = 1000"
                        if /** @src 0:3420:3431  "size > 1000" */ gt(var_size, /** @src 0:3427:3431  "1000" */ 0x03e8)
                        /// @src 0:3416:3444  "if (size > 1000) size = 1000"
                        {
                            /// @src 0:3433:3444  "size = 1000"
                            var_size := /** @src 0:3427:3431  "1000" */ 0x03e8
                        }
                        /// @src 0:176:4956  "contract StateManagement {..."
                        let length := mload(/** @src 0:3477:3496  "new uint256[](size)" */ allocate_and_zero_memory_array_array_uint256_dyn(var_size))
                        /// @src 0:176:4956  "contract StateManagement {..."
                        let memPos_5 := mload(64)
                        mstore(memPos_5, length)
                        return(memPos_5, 32)
                    }
                    case 0x5e115ec2 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let value_4 := and(sload(/** @src 0:1866:1876  "storedBool" */ 0x02), /** @src 0:176:4956  "contract StateManagement {..." */ 0xff)
                        let memPos_6 := mload(64)
                        mstore(memPos_6, iszero(iszero(value_4)))
                        return(memPos_6, 32)
                    }
                    case 0x60f63fc9 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _10 := sload(4)
                        let memPos_7 := mload(64)
                        mstore(memPos_7, and(_10, 0xffffffffffffffffffffffffffffffff))
                        mstore(add(memPos_7, 32), shr(128, _10))
                        return(memPos_7, 64)
                    }
                    case 0x61c0afb2 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPos_8 := mload(64)
                        mstore(memPos_8, /** @src 0:533:569  "bytes32 public immutable DEPLOY_HASH" */ loadimmutable("19"))
                        /// @src 0:176:4956  "contract StateManagement {..."
                        return(memPos_8, 32)
                    }
                    case 0x62ec9192 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value_5 := calldataload(4)
                        /// @src 0:4377:4474  "assembly {..."
                        tstore(value_5, add(tload(value_5), /** @src 0:176:4956  "contract StateManagement {..." */ 1))
                        return(0, 0)
                    }
                    case 0x6e4d2a34 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _11 := sload(0)
                        let memPos_9 := mload(64)
                        mstore(memPos_9, _11)
                        return(memPos_9, 32)
                    }
                    case 0x74530819 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPtr := 0
                        memPtr := mload(64)
                        let newFreePtr := add(memPtr, 64)
                        if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr))
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x41)
                            revert(0, 0x24)
                        }
                        mstore(64, newFreePtr)
                        mstore(memPtr, 5)
                        let _12 := add(memPtr, 32)
                        mstore(_12, "hello")
                        let memPos_10 := mload(64)
                        mstore(memPos_10, 32)
                        let length_1 := mload(memPtr)
                        mstore(add(memPos_10, 32), length_1)
                        mcopy(add(memPos_10, 64), _12, length_1)
                        mstore(add(add(memPos_10, length_1), 64), 0)
                        return(memPos_10, add(sub(add(memPos_10, and(add(length_1, 31), not(31))), memPos_10), 64))
                    }
                    case 0x8aa0391a {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 96) { revert(0, 0) }
                        mstore(0, calldataload(4))
                        mstore(32, /** @src 0:2686:2695  "nestedMap" */ 0x08)
                        /// @src 0:176:4956  "contract StateManagement {..."
                        let dataSlot_2 := keccak256(0, 64)
                        mstore(0, calldataload(36))
                        mstore(32, dataSlot_2)
                        sstore(keccak256(0, 64), calldataload(68))
                        return(0, 0)
                    }
                    case 0x8f63640e {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let value_6 := and(shr(8, sload(/** @src 0:715:743  "address public storedAddress" */ 2)), /** @src 0:176:4956  "contract StateManagement {..." */ sub(shl(160, 1), 1))
                        let memPos_11 := mload(64)
                        mstore(memPos_11, value_6)
                        return(memPos_11, 32)
                    }
                    case 0x90d92e76 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPos_12 := mload(64)
                        mstore(memPos_12, /** @src 0:452:488  "uint256 public immutable DEPLOY_TIME" */ loadimmutable("15"))
                        /// @src 0:176:4956  "contract StateManagement {..."
                        return(memPos_12, 32)
                    }
                    case 0x9a0363bb {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _13 := sload(/** @src 0:749:777  "bytes32 public storedBytes32" */ 3)
                        /// @src 0:176:4956  "contract StateManagement {..."
                        let memPos_13 := mload(64)
                        mstore(memPos_13, _13)
                        return(memPos_13, 32)
                    }
                    case 0x9a295e73 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPos_14 := mload(64)
                        mstore(memPos_14, /** @src 0:284:289  "12345" */ 0x3039)
                        /// @src 0:176:4956  "contract StateManagement {..."
                        mstore(add(memPos_14, 32), /** @src 0:332:354  "keccak256(\"benchmark\")" */ 0xfe6e943664ea20c614f5e9ef10a77775da30c9e509ae648d83f4197fe516f21e)
                        /// @src 0:176:4956  "contract StateManagement {..."
                        mstore(add(memPos_14, 64), /** @src 0:4925:4936  "DEPLOY_TIME" */ loadimmutable("15"))
                        /// @src 0:176:4956  "contract StateManagement {..."
                        mstore(add(memPos_14, 96), and(/** @src 0:4938:4946  "DEPLOYER" */ loadimmutable("17"), /** @src 0:176:4956  "contract StateManagement {..." */ sub(shl(160, 1), 1)))
                        return(memPos_14, 128)
                    }
                    case 0x9a5009ac {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value_7 := calldataload(4)
                        /// @src 0:1352:1381  "uint256[10] public fixedArray"
                        let _14 := iszero(lt(value_7, /** @src 0:176:4956  "contract StateManagement {..." */ 0x0a))
                        /// @src 0:1352:1381  "uint256[10] public fixedArray"
                        if _14
                        {
                            revert(/** @src 0:176:4956  "contract StateManagement {..." */ 0, 0)
                        }
                        _14 := 0
                        let _15 := sload(add(0x0a, value_7))
                        let memPos_15 := mload(64)
                        mstore(memPos_15, _15)
                        return(memPos_15, 32)
                    }
                    case 0x9a9bdca7 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value_8 := calldataload(4)
                        /// @src 0:1317:1346  "uint256[] public dynamicArray"
                        if iszero(lt(value_8, /** @src 0:176:4956  "contract StateManagement {..." */ sload(/** @src 0:1317:1346  "uint256[] public dynamicArray" */ 9)))
                        {
                            revert(/** @src 0:176:4956  "contract StateManagement {..." */ 0, 0)
                        }
                        /// @src 0:1317:1346  "uint256[] public dynamicArray"
                        let slot_1, offset_1 := storage_array_index_access_uint256_dyn(value_8)
                        /// @src 0:176:4956  "contract StateManagement {..."
                        let value_9 := shr(shl(3, offset_1), sload(/** @src 0:1317:1346  "uint256[] public dynamicArray" */ slot_1))
                        /// @src 0:176:4956  "contract StateManagement {..."
                        let memPos_16 := mload(64)
                        mstore(memPos_16, value_9)
                        return(memPos_16, 32)
                    }
                    case 0x9ba71853 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let var_size_1 := calldataload(4)
                        /// @src 0:3612:3638  "if (size > 100) size = 100"
                        if /** @src 0:3616:3626  "size > 100" */ gt(var_size_1, /** @src 0:3623:3626  "100" */ 0x64)
                        /// @src 0:3612:3638  "if (size > 100) size = 100"
                        {
                            /// @src 0:3628:3638  "size = 100"
                            var_size_1 := /** @src 0:3623:3626  "100" */ 0x64
                        }
                        /// @src 0:3671:3690  "new uint256[](size)"
                        let expr_mpos := allocate_and_zero_memory_array_array_uint256_dyn(var_size_1)
                        /// @src 0:3705:3718  "uint256 i = 0"
                        let var_i := /** @src 0:176:4956  "contract StateManagement {..." */ 0
                        /// @src 0:3700:3770  "for (uint256 i = 0; i < size; i++) {..."
                        for { }
                        /** @src 0:3720:3728  "i < size" */ lt(var_i, var_size_1)
                        /// @src 0:3705:3718  "uint256 i = 0"
                        {
                            /// @src 0:3730:3733  "i++"
                            var_i := /** @src 0:176:4956  "contract StateManagement {..." */ add(/** @src 0:3730:3733  "i++" */ var_i, /** @src 0:176:4956  "contract StateManagement {..." */ 1)
                        }
                        /// @src 0:3730:3733  "i++"
                        {
                            /// @src 0:176:4956  "contract StateManagement {..."
                            mstore(/** @src 0:3749:3759  "src[i] = i" */ memory_array_index_access_uint256_dyn(expr_mpos, var_i), /** @src 0:176:4956  "contract StateManagement {..." */ var_i)
                        }
                        /// @src 0:3802:3821  "new uint256[](size)"
                        let expr_mpos_1 := allocate_and_zero_memory_array_array_uint256_dyn(var_size_1)
                        /// @src 0:3836:3849  "uint256 i = 0"
                        let var_i_1 := /** @src 0:176:4956  "contract StateManagement {..." */ 0
                        /// @src 0:3831:3906  "for (uint256 i = 0; i < size; i++) {..."
                        for { }
                        /** @src 0:3851:3859  "i < size" */ lt(var_i_1, var_size_1)
                        /// @src 0:3836:3849  "uint256 i = 0"
                        {
                            /// @src 0:3861:3864  "i++"
                            var_i_1 := /** @src 0:176:4956  "contract StateManagement {..." */ add(/** @src 0:3861:3864  "i++" */ var_i_1, /** @src 0:176:4956  "contract StateManagement {..." */ 1)
                        }
                        /// @src 0:3861:3864  "i++"
                        {
                            /// @src 0:176:4956  "contract StateManagement {..."
                            mstore(/** @src 0:3880:3895  "dst[i] = src[i]" */ memory_array_index_access_uint256_dyn(expr_mpos_1, var_i_1), /** @src 0:176:4956  "contract StateManagement {..." */ mload(/** @src 0:3889:3895  "src[i]" */ memory_array_index_access_uint256_dyn(expr_mpos, var_i_1)))
                        }
                        /// @src 0:3926:3949  "size > 0 ? size - 1 : 0"
                        let expr := /** @src 0:176:4956  "contract StateManagement {..." */ 0
                        /// @src 0:3926:3949  "size > 0 ? size - 1 : 0"
                        switch /** @src 0:3926:3934  "size > 0" */ iszero(iszero(var_size_1))
                        case /** @src 0:3926:3949  "size > 0 ? size - 1 : 0" */ 0 {
                            expr := /** @src 0:176:4956  "contract StateManagement {..." */ 0
                        }
                        default /// @src 0:3926:3949  "size > 0 ? size - 1 : 0"
                        {
                            /// @src 0:176:4956  "contract StateManagement {..."
                            let diff := add(var_size_1, not(0))
                            if gt(diff, var_size_1)
                            {
                                mstore(0, shl(224, 0x4e487b71))
                                mstore(4, 0x11)
                                revert(0, 0x24)
                            }
                            /// @src 0:3926:3949  "size > 0 ? size - 1 : 0"
                            expr := diff
                        }
                        /// @src 0:176:4956  "contract StateManagement {..."
                        let _16 := mload(/** @src 0:3922:3950  "dst[size > 0 ? size - 1 : 0]" */ memory_array_index_access_uint256_dyn(expr_mpos_1, expr))
                        /// @src 0:176:4956  "contract StateManagement {..."
                        let memPos_17 := mload(64)
                        mstore(memPos_17, _16)
                        return(memPos_17, 32)
                    }
                    case 0x9c6f010c {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        /// @src 0:4226:4279  "assembly {..."
                        let var_value := tload(/** @src 0:176:4956  "contract StateManagement {..." */ calldataload(4))
                        let memPos_18 := mload(64)
                        mstore(memPos_18, var_value)
                        return(memPos_18, 32)
                    }
                    case 0xae713d2a {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let oldLen_1 := sload(/** @src 0:3037:3049  "dynamicArray" */ 0x09)
                        /// @src 0:176:4956  "contract StateManagement {..."
                        if iszero(oldLen_1)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x31)
                            revert(0, 0x24)
                        }
                        let newLen := add(oldLen_1, not(0))
                        let slot_2, offset_2 := storage_array_index_access_uint256_dyn(newLen)
                        let _17 := sload(slot_2)
                        sstore(slot_2, and(_17, not(shl(shl(3, offset_2), not(0)))))
                        sstore(/** @src 0:3037:3049  "dynamicArray" */ 0x09, /** @src 0:176:4956  "contract StateManagement {..." */ newLen)
                        return(0, 0)
                    }
                    case 0xb2df5978 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _18 := sload(0)
                        let memPos_19 := mload(64)
                        mstore(memPos_19, _18)
                        return(memPos_19, 32)
                    }
                    case 0xbae4ab0d {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _19 := shr(192, sload(/** @src 0:1000:1021  "uint64 public packedF" */ 5))
                        /// @src 0:176:4956  "contract StateManagement {..."
                        let memPos_20 := mload(64)
                        mstore(memPos_20, _19)
                        return(memPos_20, 32)
                    }
                    case 0xbba50db2 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        mstore(0, calldataload(4))
                        mstore(32, /** @src 0:2368:2376  "valueMap" */ 0x06)
                        /// @src 0:176:4956  "contract StateManagement {..."
                        let _20 := sload(keccak256(0, 64))
                        let memPos_21 := mload(64)
                        mstore(memPos_21, _20)
                        return(memPos_21, 32)
                    }
                    case 0xc1b8411a {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPos_22 := mload(64)
                        mstore(memPos_22, and(/** @src 0:494:527  "address public immutable DEPLOYER" */ loadimmutable("17"), /** @src 0:176:4956  "contract StateManagement {..." */ sub(shl(160, 1), 1)))
                        return(memPos_22, 32)
                    }
                    case 0xc3278189 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let value_10 := and(sload(/** @src 0:919:940  "uint64 public packedC" */ 5), /** @src 0:176:4956  "contract StateManagement {..." */ 0xffffffffffffffff)
                        let memPos_23 := mload(64)
                        mstore(memPos_23, value_10)
                        return(memPos_23, 32)
                    }
                    case 0xcefe1833 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let value_11 := and(sload(/** @src 0:687:709  "bool public storedBool" */ 2), /** @src 0:176:4956  "contract StateManagement {..." */ 0xff)
                        let memPos_24 := mload(64)
                        mstore(memPos_24, iszero(iszero(value_11)))
                        return(memPos_24, 32)
                    }
                    case 0xcfe5cee4 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        let value_12 := 0
                        value_12 := calldataload(4)
                        let _21 := and(value_12, 0xffffffffffffffffffffffffffffffff)
                        if iszero(eq(value_12, _21)) { revert(0, 0) }
                        let value_13 := 0
                        value_13 := calldataload(36)
                        if iszero(eq(value_13, and(value_13, 0xffffffffffffffffffffffffffffffff))) { revert(0, 0) }
                        sstore(4, or(_21, and(shl(128, value_13), not(0xffffffffffffffffffffffffffffffff))))
                        return(0, 0)
                    }
                    case 0xdaae8ba2 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        mstore(0, calldataload(4))
                        mstore(32, /** @src 0:1103:1146  "mapping(uint256 => uint256) public valueMap" */ 6)
                        /// @src 0:176:4956  "contract StateManagement {..."
                        let _22 := sload(keccak256(0, 64))
                        let memPos_25 := mload(64)
                        mstore(memPos_25, _22)
                        return(memPos_25, 32)
                    }
                    case 0xe465acab {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPos_26 := mload(64)
                        mstore(memPos_26, /** @src 0:284:289  "12345" */ 0x3039)
                        /// @src 0:176:4956  "contract StateManagement {..."
                        return(memPos_26, 32)
                    }
                    case 0xe93ccaa3 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let value_14 := and(sload(4), 0xffffffffffffffffffffffffffffffff)
                        let memPos_27 := mload(64)
                        mstore(memPos_27, value_14)
                        return(memPos_27, 32)
                    }
                    case 0xeb790438 {
                        if callvalue() { revert(0, 0) }
                        let param_6, param_7 := abi_decode_uint256t_uint256(calldatasize())
                        mstore(0, param_6)
                        mstore(0x20, /** @src 0:2839:2848  "nestedMap" */ 0x08)
                        /// @src 0:176:4956  "contract StateManagement {..."
                        let dataSlot_3 := keccak256(0, 64)
                        mstore(0, param_7)
                        mstore(0x20, dataSlot_3)
                        let _23 := sload(keccak256(0, 64))
                        let memPos_28 := mload(64)
                        mstore(memPos_28, _23)
                        return(memPos_28, 0x20)
                    }
                    case 0xf36745d8 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let value_15 := and(shr(64, sload(/** @src 0:946:967  "uint64 public packedD" */ 5)), /** @src 0:176:4956  "contract StateManagement {..." */ 0xffffffffffffffff)
                        let memPos_29 := mload(64)
                        mstore(memPos_29, value_15)
                        return(memPos_29, 32)
                    }
                    case 0xf6b9be5b {
                        if callvalue() { revert(0, 0) }
                        let param_8, param_9 := abi_decode_uint256t_uint256(calldatasize())
                        mstore(0, param_8)
                        mstore(0x20, /** @src 0:2464:2472  "valueMap" */ 0x06)
                        /// @src 0:176:4956  "contract StateManagement {..."
                        sstore(keccak256(0, 64), param_9)
                        return(0, 0)
                    }
                    case 0xfa196518 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPos_30 := mload(64)
                        mstore(memPos_30, /** @src 0:332:354  "keccak256(\"benchmark\")" */ 0xfe6e943664ea20c614f5e9ef10a77775da30c9e509ae648d83f4197fe516f21e)
                        /// @src 0:176:4956  "contract StateManagement {..."
                        return(memPos_30, 32)
                    }
                    case 0xfac8b339 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _24 := sload(/** @src 0:658:681  "int256 public storedInt" */ 1)
                        /// @src 0:176:4956  "contract StateManagement {..."
                        let memPos_31 := mload(64)
                        mstore(memPos_31, _24)
                        return(memPos_31, 32)
                    }
                }
                revert(0, 0)
            }
            function abi_decode_uint256t_uint256(dataEnd) -> value0, value1
            {
                if slt(add(dataEnd, not(3)), 64) { revert(0, 0) }
                value0 := calldataload(4)
                value1 := calldataload(36)
            }
            function abi_decode_address() -> value
            {
                value := calldataload(4)
                if iszero(eq(value, and(value, sub(shl(160, 1), 1)))) { revert(0, 0) }
            }
            function storage_array_index_access_uint256_dyn(index) -> slot, offset
            {
                if iszero(lt(index, sload(/** @src 0:3262:3274  "dynamicArray" */ 0x09)))
                /// @src 0:176:4956  "contract StateManagement {..."
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x32)
                    revert(0, 0x24)
                }
                mstore(/** @src -1:-1:-1 */ 0, /** @src 0:3262:3274  "dynamicArray" */ 0x09)
                /// @src 0:176:4956  "contract StateManagement {..."
                slot := add(keccak256(/** @src -1:-1:-1 */ 0, /** @src 0:176:4956  "contract StateManagement {..." */ 0x20), index)
                offset := /** @src -1:-1:-1 */ 0
            }
            /// @src 0:176:4956  "contract StateManagement {..."
            function array_allocation_size_array_uint256_dyn(length) -> size
            {
                if gt(length, 0xffffffffffffffff)
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x41)
                    revert(0, 0x24)
                }
                size := add(shl(5, length), 0x20)
            }
            function allocate_and_zero_memory_array_array_uint256_dyn(length) -> memPtr
            {
                let _1 := array_allocation_size_array_uint256_dyn(length)
                let memPtr_1 := /** @src -1:-1:-1 */ 0
                /// @src 0:176:4956  "contract StateManagement {..."
                memPtr_1 := mload(64)
                let newFreePtr := add(memPtr_1, and(add(_1, 31), not(31)))
                if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr_1))
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:176:4956  "contract StateManagement {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x41)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:176:4956  "contract StateManagement {..." */ 0x24)
                }
                mstore(64, newFreePtr)
                mstore(memPtr_1, length)
                memPtr := memPtr_1
                calldatacopy(add(memPtr_1, 32), calldatasize(), add(array_allocation_size_array_uint256_dyn(length), not(31)))
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
        data ".metadata" hex"a264697066735822122059ab35e6a80e3d4f2df96d057ee163c8618751e77371e99784c50e75f89fcc1e64736f6c634300081c0033"
    }
}