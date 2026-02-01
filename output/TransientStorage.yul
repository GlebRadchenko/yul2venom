object "TransientStorage_308" {
    code {
        {
            /// @src 0:236:6096  "contract TransientStorage {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("TransientStorage_308_deployed")
            codecopy(_1, dataoffset("TransientStorage_308_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/bench/TransientStorage.sol"
    object "TransientStorage_308_deployed" {
        code {
            {
                /// @src 0:236:6096  "contract TransientStorage {..."
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x0198214f {
                        if callvalue() { revert(0, 0) }
                        let param, param_1 := abi_decode_uint256t_uint256(calldatasize())
                        /// @src 0:514:566  "assembly {..."
                        tstore(param, param_1)
                        /// @src 0:236:6096  "contract TransientStorage {..."
                        return(0, 0)
                    }
                    case 0x021e9894 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        if iszero(/** @src 0:1731:1738  "!locked" */ iszero(/** @src 0:1655:1714  "assembly {..." */ tload(4660)))
                        /// @src 0:236:6096  "contract TransientStorage {..."
                        {
                            mstore(_1, shl(229, 4594637))
                            mstore(add(_1, 4), 32)
                            mstore(add(_1, 36), 31)
                            mstore(add(_1, 68), "ReentrancyGuard: reentrant call")
                            revert(_1, 100)
                        }
                        /// @src 0:1784:1837  "assembly {..."
                        tstore(/** @src 0:1655:1714  "assembly {..." */ 4660, /** @src 0:1784:1837  "assembly {..." */ 1)
                        /// @src 0:1857:1910  "assembly {..."
                        tstore(/** @src 0:1655:1714  "assembly {..." */ 4660, /** @src 0:236:6096  "contract TransientStorage {..." */ 0)
                        let memPos := mload(64)
                        mstore(memPos, /** @src 0:2073:2075  "42" */ 0x2a)
                        /// @src 0:236:6096  "contract TransientStorage {..."
                        return(memPos, 32)
                    }
                    case 0x26367258 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let ret := /** @src 0:6018:6088  "assembly {..." */ tload(43981)
                        /// @src 0:236:6096  "contract TransientStorage {..."
                        let memPos_1 := mload(64)
                        mstore(memPos_1, and(ret, sub(shl(160, 1), 1)))
                        return(memPos_1, 32)
                    }
                    case 0x33b08b86 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _2 := sload(0)
                        let memPos_2 := mload(64)
                        mstore(memPos_2, _2)
                        return(memPos_2, 32)
                    }
                    case 0x48b050eb {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        /// @src 0:4830:4882  "assembly {..."
                        let var_addr := tload(/** @src 0:236:6096  "contract TransientStorage {..." */ calldataload(4))
                        let memPos_3 := mload(64)
                        mstore(memPos_3, and(var_addr, sub(shl(160, 1), 1)))
                        return(memPos_3, 32)
                    }
                    case 0x55eef3b7 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        /// @src 0:4387:4443  "assembly {..."
                        tstore(22136, /** @src 0:236:6096  "contract TransientStorage {..." */ 0)
                        return(0, 0)
                    }
                    case 0x6086a859 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        /// @src 0:3937:4087  "assembly {..."
                        let var_newValue := add(tload(22136), 1)
                        tstore(22136, var_newValue)
                        /// @src 0:236:6096  "contract TransientStorage {..."
                        let memPos_4 := mload(64)
                        mstore(memPos_4, var_newValue)
                        return(memPos_4, 32)
                    }
                    case 0x6fae1c2b {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        let value := 0
                        value := calldataload(4)
                        if iszero(eq(value, and(value, sub(shl(160, 1), 1)))) { revert(0, 0) }
                        let offset := calldataload(36)
                        if gt(offset, 0xffffffffffffffff) { revert(0, 0) }
                        if iszero(slt(add(offset, 35), calldatasize())) { revert(0, 0) }
                        let length := calldataload(add(4, offset))
                        if gt(length, 0xffffffffffffffff) { revert(0, 0) }
                        if gt(add(add(offset, length), 36), calldatasize()) { revert(0, 0) }
                        /// @src 0:5587:5658  "assembly {..."
                        tstore(43981, caller())
                        /// @src 0:5709:5726  "target.call(data)"
                        let _3 := /** @src 0:236:6096  "contract TransientStorage {..." */ mload(64)
                        calldatacopy(_3, add(offset, 36), length)
                        let _4 := add(_3, length)
                        mstore(_4, 0)
                        /// @src 0:5709:5726  "target.call(data)"
                        let expr_component := call(gas(), value, /** @src 0:236:6096  "contract TransientStorage {..." */ 0, /** @src 0:5709:5726  "target.call(data)" */ _3, sub(/** @src 0:236:6096  "contract TransientStorage {..." */ _4, /** @src 0:5709:5726  "target.call(data)" */ _3), /** @src 0:236:6096  "contract TransientStorage {..." */ 0, 0)
                        /// @src 0:5709:5726  "target.call(data)"
                        let data := /** @src 0:236:6096  "contract TransientStorage {..." */ 0
                        switch returndatasize()
                        case 0 { data := 96 }
                        default {
                            let _5 := returndatasize()
                            if gt(_5, 0xffffffffffffffff)
                            {
                                mstore(0, shl(224, 0x4e487b71))
                                mstore(4, 0x41)
                                revert(0, 36)
                            }
                            let memPtr := allocate_memory(add(and(add(_5, 0x1f), not(31)), 32))
                            mstore(memPtr, _5)
                            data := memPtr
                            returndatacopy(add(memPtr, 32), 0, returndatasize())
                        }
                        if iszero(expr_component)
                        {
                            let memPtr_1 := mload(64)
                            mstore(memPtr_1, shl(229, 4594637))
                            mstore(add(memPtr_1, 4), 32)
                            mstore(add(memPtr_1, 36), 15)
                            mstore(add(memPtr_1, 68), "Callback failed")
                            revert(memPtr_1, 100)
                        }
                        /// @src 0:5781:5845  "assembly {..."
                        tstore(/** @src 0:5587:5658  "assembly {..." */ 43981, /** @src 0:236:6096  "contract TransientStorage {..." */ 0)
                        let memPos_5 := mload(64)
                        mstore(memPos_5, 32)
                        let length_1 := mload(data)
                        mstore(add(memPos_5, 32), length_1)
                        mcopy(add(memPos_5, 64), add(data, 32), length_1)
                        mstore(add(add(memPos_5, length_1), 64), 0)
                        return(memPos_5, add(sub(add(memPos_5, and(add(length_1, 0x1f), not(31))), memPos_5), 64))
                    }
                    case 0x7aba6f37 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        /// @src 0:1403:1456  "assembly {..."
                        tstore(4660, 1)
                        /// @src 0:236:6096  "contract TransientStorage {..."
                        return(0, 0)
                    }
                    case 0x93affe51 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _6 := sload(0)
                        /// @src 0:3644:3699  "assembly {..."
                        let var_transient := tload(/** @src 0:236:6096  "contract TransientStorage {..." */ 0)
                        let memPos_6 := mload(64)
                        mstore(memPos_6, _6)
                        mstore(add(memPos_6, 32), var_transient)
                        return(memPos_6, 64)
                    }
                    case 0x9c6f010c {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        /// @src 0:4830:4882  "assembly {..."
                        let var_addr_1 := tload(/** @src 0:236:6096  "contract TransientStorage {..." */ calldataload(4))
                        let memPos_7 := mload(64)
                        mstore(memPos_7, var_addr_1)
                        return(memPos_7, 32)
                    }
                    case 0xa4e2d634 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let ret_1 := /** @src 0:1269:1328  "assembly {..." */ tload(4660)
                        /// @src 0:236:6096  "contract TransientStorage {..."
                        let memPos_8 := mload(64)
                        mstore(memPos_8, iszero(iszero(ret_1)))
                        return(memPos_8, 32)
                    }
                    case 0xaa3e6e46 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        let value_1 := 0
                        value_1 := calldataload(36)
                        if iszero(eq(value_1, and(value_1, sub(shl(160, 1), 1)))) { revert(0, 0) }
                        /// @src 0:514:566  "assembly {..."
                        tstore(/** @src 0:236:6096  "contract TransientStorage {..." */ calldataload(4), /** @src 0:514:566  "assembly {..." */ value_1)
                        /// @src 0:236:6096  "contract TransientStorage {..."
                        return(0, 0)
                    }
                    case 0xc19b8036 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        /// @src 0:1535:1588  "assembly {..."
                        tstore(4660, /** @src 0:236:6096  "contract TransientStorage {..." */ 0)
                        return(0, 0)
                    }
                    case 0xd417df16 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        /// @src 0:4830:4882  "assembly {..."
                        let var_addr_2 := tload(/** @src 0:236:6096  "contract TransientStorage {..." */ calldataload(4))
                        let memPos_9 := mload(64)
                        mstore(memPos_9, var_addr_2)
                        return(memPos_9, 32)
                    }
                    case 0xd45d94f3 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        let offset_1 := calldataload(4)
                        if gt(offset_1, 0xffffffffffffffff) { revert(0, 0) }
                        let value0, value1 := abi_decode_array_uint256_dyn_calldata(add(4, offset_1), calldatasize())
                        let offset_2 := calldataload(36)
                        if gt(offset_2, 0xffffffffffffffff) { revert(0, 0) }
                        let value2, value3 := abi_decode_array_uint256_dyn_calldata(add(4, offset_2), calldatasize())
                        if iszero(/** @src 0:2299:2328  "slots.length == values.length" */ eq(value1, value3))
                        /// @src 0:236:6096  "contract TransientStorage {..."
                        {
                            let memPtr_2 := mload(64)
                            mstore(memPtr_2, shl(229, 4594637))
                            mstore(add(memPtr_2, 4), 32)
                            mstore(add(memPtr_2, 36), 15)
                            mstore(add(memPtr_2, 68), "Length mismatch")
                            revert(memPtr_2, 100)
                        }
                        /// @src 0:2363:2376  "uint256 i = 0"
                        let var_i := /** @src 0:236:6096  "contract TransientStorage {..." */ 0
                        /// @src 0:2358:2621  "for (uint256 i = 0; i < slots.length; i++) {..."
                        for { }
                        /** @src 0:2378:2394  "i < slots.length" */ lt(var_i, value1)
                        /// @src 0:2363:2376  "uint256 i = 0"
                        {
                            /// @src 0:2396:2399  "i++"
                            var_i := /** @src 0:236:6096  "contract TransientStorage {..." */ add(/** @src 0:2396:2399  "i++" */ var_i, /** @src 0:236:6096  "contract TransientStorage {..." */ 1)
                        }
                        /// @src 0:2396:2399  "i++"
                        {
                            /// @src 0:2415:2611  "assembly {..."
                            let _7 := shl(5, var_i)
                            tstore(calldataload(add(value0, _7)), calldataload(add(value2, _7)))
                        }
                        /// @src 0:236:6096  "contract TransientStorage {..."
                        return(0, 0)
                    }
                    case 0xd97d9360 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let ret_2 := /** @src 0:4222:4283  "assembly {..." */ tload(22136)
                        /// @src 0:236:6096  "contract TransientStorage {..."
                        let memPos_10 := mload(64)
                        mstore(memPos_10, ret_2)
                        return(memPos_10, 32)
                    }
                    case 0xde3e7e17 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let offset_3 := calldataload(4)
                        if gt(offset_3, 0xffffffffffffffff) { revert(0, 0) }
                        let value0_1, value1_1 := abi_decode_array_uint256_dyn_calldata(add(4, offset_3), calldatasize())
                        let memPtr_3 := allocate_memory(array_allocation_size_array_uint256_dyn(value1_1))
                        mstore(memPtr_3, value1_1)
                        let dataSize := array_allocation_size_array_uint256_dyn(value1_1)
                        let dataStart := add(memPtr_3, 32)
                        calldatacopy(dataStart, calldatasize(), add(dataSize, not(31)))
                        /// @src 0:2846:2859  "uint256 i = 0"
                        let var_i_1 := /** @src 0:236:6096  "contract TransientStorage {..." */ 0
                        /// @src 0:2841:3064  "for (uint256 i = 0; i < slots.length; i++) {..."
                        for { }
                        /** @src 0:236:6096  "contract TransientStorage {..." */ 1
                        /// @src 0:2846:2859  "uint256 i = 0"
                        {
                            /// @src 0:2879:2882  "i++"
                            var_i_1 := /** @src 0:236:6096  "contract TransientStorage {..." */ add(/** @src 0:2879:2882  "i++" */ var_i_1, /** @src 0:236:6096  "contract TransientStorage {..." */ 1)
                        }
                        /// @src 0:2879:2882  "i++"
                        {
                            /// @src 0:2861:2877  "i < slots.length"
                            let _8 := iszero(lt(var_i_1, value1_1))
                            if _8 { break }
                            /// @src 0:236:6096  "contract TransientStorage {..."
                            _8 := 0
                            let _9 := shl(5, var_i_1)
                            /// @src 0:2962:3023  "assembly {..."
                            let _10 := tload(/** @src 0:236:6096  "contract TransientStorage {..." */ calldataload(add(value0_1, _9)))
                            if iszero(lt(var_i_1, mload(memPtr_3)))
                            {
                                mstore(0, shl(224, 0x4e487b71))
                                mstore(4, 0x32)
                                revert(0, 0x24)
                            }
                            mstore(add(add(memPtr_3, _9), 32), _10)
                        }
                        let memPos_11 := mload(64)
                        let tail := add(memPos_11, 32)
                        mstore(memPos_11, 32)
                        let pos := tail
                        let length_2 := mload(memPtr_3)
                        mstore(tail, length_2)
                        pos := add(memPos_11, 64)
                        let srcPtr := dataStart
                        let i := 0
                        for { } lt(i, length_2) { i := add(i, 1) }
                        {
                            mstore(pos, mload(srcPtr))
                            pos := add(pos, 32)
                            srcPtr := add(srcPtr, 32)
                        }
                        return(memPos_11, sub(pos, memPos_11))
                    }
                    case 0xe0087a17 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        sstore(0, calldataload(4))
                        return(0, 0)
                    }
                    case 0xe7b8fa1c {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        /// @src 0:3400:3449  "assembly {..."
                        tstore(/** @src 0:236:6096  "contract TransientStorage {..." */ 0, calldataload(4))
                        return(0, 0)
                    }
                    case 0xef602f74 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(0, 0) }
                        /// @src 0:514:566  "assembly {..."
                        tstore(/** @src 0:236:6096  "contract TransientStorage {..." */ calldataload(4), calldataload(36))
                        return(0, 0)
                    }
                    case 0xfadc3640 {
                        if callvalue() { revert(0, 0) }
                        let param_2, param_3 := abi_decode_uint256t_uint256(calldatasize())
                        /// @src 0:961:1047  "assembly {..."
                        tstore(param_2, param_3)
                        let var_loaded := tload(param_2)
                        /// @src 0:236:6096  "contract TransientStorage {..."
                        let memPos_12 := mload(64)
                        mstore(memPos_12, var_loaded)
                        return(memPos_12, 32)
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
            function abi_decode_array_uint256_dyn_calldata(offset, end) -> arrayPos, length
            {
                if iszero(slt(add(offset, 0x1f), end)) { revert(0, 0) }
                length := calldataload(offset)
                if gt(length, 0xffffffffffffffff) { revert(0, 0) }
                arrayPos := add(offset, 0x20)
                if gt(add(add(offset, shl(5, length)), 0x20), end) { revert(0, 0) }
            }
            function allocate_memory(size) -> memPtr
            {
                memPtr := mload(64)
                let newFreePtr := add(memPtr, and(add(size, 31), not(31)))
                if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr))
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:236:6096  "contract TransientStorage {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x41)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:236:6096  "contract TransientStorage {..." */ 0x24)
                }
                mstore(64, newFreePtr)
            }
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
        }
        data ".metadata" hex"a26469706673582212208477506ecc4646e4d52f59a300641589104adc55f8657f6ef4c1497dfdced20264736f6c634300081c0033"
    }
}