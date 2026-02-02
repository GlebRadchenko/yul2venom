object "InitStringTest_39" {
    code {
        {
            /// @src 0:211:591  "contract InitStringTest {..."
            mstore(64, memoryguard(0x80))
            if callvalue() { revert(0, 0) }
            let programSize := datasize("InitStringTest_39")
            let argSize := sub(codesize(), programSize)
            let memoryDataOffset := allocate_memory(argSize)
            codecopy(memoryDataOffset, programSize, argSize)
            let _1 := add(memoryDataOffset, argSize)
            if slt(sub(_1, memoryDataOffset), 64)
            {
                revert(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 0:211:591  "contract InitStringTest {..."
            let offset := mload(memoryDataOffset)
            if gt(offset, sub(shl(64, 1), 1))
            {
                revert(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 0:211:591  "contract InitStringTest {..."
            let value0 := abi_decode_string_fromMemory(add(memoryDataOffset, offset), _1)
            let offset_1 := mload(add(memoryDataOffset, 32))
            if gt(offset_1, sub(shl(64, 1), 1))
            {
                revert(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 0:211:591  "contract InitStringTest {..."
            let value1 := abi_decode_string_fromMemory(add(memoryDataOffset, offset_1), _1)
            let newLen := mload(value0)
            if gt(newLen, sub(shl(64, 1), 1))
            {
                mstore(/** @src -1:-1:-1 */ 0, /** @src 0:211:591  "contract InitStringTest {..." */ shl(224, 0x4e487b71))
                mstore(4, 0x41)
                revert(/** @src -1:-1:-1 */ 0, /** @src 0:211:591  "contract InitStringTest {..." */ 0x24)
            }
            let _2 := sload(/** @src -1:-1:-1 */ 0)
            /// @src 0:211:591  "contract InitStringTest {..."
            let length := /** @src -1:-1:-1 */ 0
            /// @src 0:211:591  "contract InitStringTest {..."
            length := shr(1, _2)
            let outOfPlaceEncoding := and(_2, 1)
            if iszero(outOfPlaceEncoding) { length := and(length, 0x7f) }
            if eq(outOfPlaceEncoding, lt(length, 32))
            {
                mstore(/** @src -1:-1:-1 */ 0, /** @src 0:211:591  "contract InitStringTest {..." */ shl(224, 0x4e487b71))
                mstore(4, 0x22)
                revert(/** @src -1:-1:-1 */ 0, /** @src 0:211:591  "contract InitStringTest {..." */ 0x24)
            }
            if gt(length, 31)
            {
                mstore(/** @src -1:-1:-1 */ 0, 0)
                /// @src 0:211:591  "contract InitStringTest {..."
                let data := keccak256(/** @src -1:-1:-1 */ 0, /** @src 0:211:591  "contract InitStringTest {..." */ 32)
                let deleteStart := add(data, shr(5, add(newLen, 31)))
                if lt(newLen, 32) { deleteStart := data }
                let _3 := add(data, shr(5, add(length, 31)))
                let start := deleteStart
                for { } lt(start, _3) { start := add(start, 1) }
                {
                    sstore(start, /** @src -1:-1:-1 */ 0)
                }
            }
            /// @src 0:211:591  "contract InitStringTest {..."
            let srcOffset := /** @src -1:-1:-1 */ 0
            /// @src 0:211:591  "contract InitStringTest {..."
            srcOffset := 32
            switch gt(newLen, 31)
            case 1 {
                let loopEnd := and(newLen, not(31))
                mstore(/** @src -1:-1:-1 */ 0, 0)
                /// @src 0:211:591  "contract InitStringTest {..."
                let dstPtr := keccak256(/** @src -1:-1:-1 */ 0, /** @src 0:211:591  "contract InitStringTest {..." */ srcOffset)
                let i := /** @src -1:-1:-1 */ 0
                /// @src 0:211:591  "contract InitStringTest {..."
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
                sstore(/** @src -1:-1:-1 */ 0, /** @src 0:211:591  "contract InitStringTest {..." */ add(shl(1, newLen), 1))
            }
            default {
                let value := /** @src -1:-1:-1 */ 0
                /// @src 0:211:591  "contract InitStringTest {..."
                if newLen
                {
                    value := mload(add(value0, srcOffset))
                }
                sstore(/** @src -1:-1:-1 */ 0, /** @src 0:211:591  "contract InitStringTest {..." */ or(and(value, not(shr(shl(3, newLen), not(0)))), shl(1, newLen)))
            }
            let newLen_1 := mload(value1)
            if gt(newLen_1, sub(shl(64, 1), 1))
            {
                mstore(/** @src -1:-1:-1 */ 0, /** @src 0:211:591  "contract InitStringTest {..." */ shl(224, 0x4e487b71))
                mstore(4, 0x41)
                revert(/** @src -1:-1:-1 */ 0, /** @src 0:211:591  "contract InitStringTest {..." */ 0x24)
            }
            let _4 := sload(1)
            let length_1 := /** @src -1:-1:-1 */ 0
            /// @src 0:211:591  "contract InitStringTest {..."
            length_1 := shr(1, _4)
            let outOfPlaceEncoding_1 := and(_4, 1)
            if iszero(outOfPlaceEncoding_1)
            {
                length_1 := and(length_1, 0x7f)
            }
            if eq(outOfPlaceEncoding_1, lt(length_1, 32))
            {
                mstore(/** @src -1:-1:-1 */ 0, /** @src 0:211:591  "contract InitStringTest {..." */ shl(224, 0x4e487b71))
                mstore(4, 0x22)
                revert(/** @src -1:-1:-1 */ 0, /** @src 0:211:591  "contract InitStringTest {..." */ 0x24)
            }
            if gt(length_1, 31)
            {
                mstore(/** @src -1:-1:-1 */ 0, /** @src 0:211:591  "contract InitStringTest {..." */ 1)
                let data_1 := keccak256(/** @src -1:-1:-1 */ 0, /** @src 0:211:591  "contract InitStringTest {..." */ 32)
                let deleteStart_1 := add(data_1, shr(5, add(newLen_1, 31)))
                if lt(newLen_1, 32) { deleteStart_1 := data_1 }
                let _5 := add(data_1, shr(5, add(length_1, 31)))
                let start_1 := deleteStart_1
                for { } lt(start_1, _5) { start_1 := add(start_1, 1) }
                {
                    sstore(start_1, /** @src -1:-1:-1 */ 0)
                }
            }
            /// @src 0:211:591  "contract InitStringTest {..."
            let srcOffset_1 := /** @src -1:-1:-1 */ 0
            /// @src 0:211:591  "contract InitStringTest {..."
            srcOffset_1 := 32
            switch gt(newLen_1, 31)
            case 1 {
                let loopEnd_1 := and(newLen_1, not(31))
                mstore(/** @src -1:-1:-1 */ 0, /** @src 0:211:591  "contract InitStringTest {..." */ 1)
                let dstPtr_1 := keccak256(/** @src -1:-1:-1 */ 0, /** @src 0:211:591  "contract InitStringTest {..." */ srcOffset_1)
                let i_1 := /** @src -1:-1:-1 */ 0
                /// @src 0:211:591  "contract InitStringTest {..."
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
                let value_1 := /** @src -1:-1:-1 */ 0
                /// @src 0:211:591  "contract InitStringTest {..."
                if newLen_1
                {
                    value_1 := mload(add(value1, srcOffset_1))
                }
                sstore(1, or(and(value_1, not(shr(shl(3, newLen_1), not(0)))), shl(1, newLen_1)))
            }
            let _6 := mload(64)
            let _7 := datasize("InitStringTest_39_deployed")
            codecopy(_6, dataoffset("InitStringTest_39_deployed"), _7)
            return(_6, _7)
        }
        function allocate_memory(size) -> memPtr
        {
            memPtr := mload(64)
            let newFreePtr := add(memPtr, and(add(size, 31), not(31)))
            if or(gt(newFreePtr, sub(shl(64, 1), 1)), lt(newFreePtr, memPtr))
            {
                mstore(/** @src -1:-1:-1 */ 0, /** @src 0:211:591  "contract InitStringTest {..." */ shl(224, 0x4e487b71))
                mstore(4, 0x41)
                revert(/** @src -1:-1:-1 */ 0, /** @src 0:211:591  "contract InitStringTest {..." */ 0x24)
            }
            mstore(64, newFreePtr)
        }
        function abi_decode_string_fromMemory(offset, end) -> array
        {
            if iszero(slt(add(offset, 0x1f), end)) { revert(0, 0) }
            let length := mload(offset)
            if gt(length, sub(shl(64, 1), 1))
            {
                mstore(/** @src -1:-1:-1 */ 0, /** @src 0:211:591  "contract InitStringTest {..." */ shl(224, 0x4e487b71))
                mstore(4, 0x41)
                revert(/** @src -1:-1:-1 */ 0, /** @src 0:211:591  "contract InitStringTest {..." */ 0x24)
            }
            let array_1 := allocate_memory(add(and(add(length, 0x1f), not(31)), 0x20))
            mstore(array_1, length)
            if gt(add(add(offset, length), 0x20), end)
            {
                revert(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 0:211:591  "contract InitStringTest {..."
            mcopy(add(array_1, 0x20), add(offset, 0x20), length)
            mstore(add(add(array_1, length), 0x20), /** @src -1:-1:-1 */ 0)
            /// @src 0:211:591  "contract InitStringTest {..."
            array := array_1
        }
    }
    /// @use-src 0:"foundry/src/init/InitStringTest.sol"
    object "InitStringTest_39_deployed" {
        code {
            {
                /// @src 0:211:591  "contract InitStringTest {..."
                mstore(64, memoryguard(0x80))
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x06fdde03 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        /// @src 0:241:259  "string public name"
                        let value := /** @src 0:211:591  "contract InitStringTest {..." */ 0
                        let slot := 0
                        slot := 0
                        let memPtr := 0
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
                        value := memPtr
                        let memPos := mload(64)
                        return(memPos, sub(abi_encode_string(memPos, memPtr), memPos))
                    }
                    case 0x15070401 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPtr_1 := 0
                        memPtr_1 := mload(64)
                        let ret_1 := 0
                        let slotValue_1 := sload(/** @src 0:576:582  "symbol" */ 0x01)
                        /// @src 0:211:591  "contract InitStringTest {..."
                        let length_1 := 0
                        length_1 := shr(/** @src 0:576:582  "symbol" */ 0x01, /** @src 0:211:591  "contract InitStringTest {..." */ slotValue_1)
                        let outOfPlaceEncoding_1 := and(slotValue_1, /** @src 0:576:582  "symbol" */ 0x01)
                        /// @src 0:211:591  "contract InitStringTest {..."
                        if iszero(outOfPlaceEncoding_1)
                        {
                            length_1 := and(length_1, 0x7f)
                        }
                        if eq(outOfPlaceEncoding_1, lt(length_1, 32))
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x22)
                            revert(0, 0x24)
                        }
                        mstore(memPtr_1, length_1)
                        switch outOfPlaceEncoding_1
                        case 0 {
                            mstore(add(memPtr_1, 32), and(slotValue_1, not(255)))
                            ret_1 := add(add(memPtr_1, shl(5, iszero(iszero(length_1)))), 32)
                        }
                        case 1 {
                            mstore(0, /** @src 0:576:582  "symbol" */ 0x01)
                            /// @src 0:211:591  "contract InitStringTest {..."
                            let dataPos_1 := keccak256(0, 32)
                            let i_1 := 0
                            for { } lt(i_1, length_1) { i_1 := add(i_1, 32) }
                            {
                                mstore(add(add(memPtr_1, i_1), 32), sload(dataPos_1))
                                dataPos_1 := add(dataPos_1, /** @src 0:576:582  "symbol" */ 0x01)
                            }
                            /// @src 0:211:591  "contract InitStringTest {..."
                            ret_1 := add(add(memPtr_1, i_1), 32)
                        }
                        let newFreePtr_1 := add(memPtr_1, and(add(sub(ret_1, memPtr_1), 31), not(31)))
                        if or(gt(newFreePtr_1, 0xffffffffffffffff), lt(newFreePtr_1, memPtr_1))
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x41)
                            revert(0, 0x24)
                        }
                        mstore(64, newFreePtr_1)
                        let memPos_1 := mload(64)
                        return(memPos_1, sub(abi_encode_string(memPos_1, memPtr_1), memPos_1))
                    }
                    case 0x17d7de7c {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPtr_2 := 0
                        memPtr_2 := mload(64)
                        let ret_2 := 0
                        let slotValue_2 := sload(0)
                        let length_2 := 0
                        length_2 := shr(1, slotValue_2)
                        let outOfPlaceEncoding_2 := and(slotValue_2, 1)
                        if iszero(outOfPlaceEncoding_2)
                        {
                            length_2 := and(length_2, 0x7f)
                        }
                        if eq(outOfPlaceEncoding_2, lt(length_2, 32))
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x22)
                            revert(0, 0x24)
                        }
                        mstore(memPtr_2, length_2)
                        switch outOfPlaceEncoding_2
                        case 0 {
                            mstore(add(memPtr_2, 32), and(slotValue_2, not(255)))
                            ret_2 := add(add(memPtr_2, shl(5, iszero(iszero(length_2)))), 32)
                        }
                        case 1 {
                            mstore(0, 0)
                            let dataPos_2 := keccak256(0, 32)
                            let i_2 := 0
                            for { } lt(i_2, length_2) { i_2 := add(i_2, 32) }
                            {
                                mstore(add(add(memPtr_2, i_2), 32), sload(dataPos_2))
                                dataPos_2 := add(dataPos_2, 1)
                            }
                            ret_2 := add(add(memPtr_2, i_2), 32)
                        }
                        let newFreePtr_2 := add(memPtr_2, and(add(sub(ret_2, memPtr_2), 31), not(31)))
                        if or(gt(newFreePtr_2, 0xffffffffffffffff), lt(newFreePtr_2, memPtr_2))
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x41)
                            revert(0, 0x24)
                        }
                        mstore(64, newFreePtr_2)
                        let memPos_2 := mload(64)
                        return(memPos_2, sub(abi_encode_string(memPos_2, memPtr_2), memPos_2))
                    }
                    case 0x95d89b41 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let memPtr_3 := 0
                        memPtr_3 := mload(64)
                        let ret_3 := 0
                        let slotValue_3 := sload(/** @src 0:265:285  "string public symbol" */ 1)
                        /// @src 0:211:591  "contract InitStringTest {..."
                        let length_3 := 0
                        length_3 := shr(/** @src 0:265:285  "string public symbol" */ 1, /** @src 0:211:591  "contract InitStringTest {..." */ slotValue_3)
                        let outOfPlaceEncoding_3 := and(slotValue_3, /** @src 0:265:285  "string public symbol" */ 1)
                        /// @src 0:211:591  "contract InitStringTest {..."
                        if iszero(outOfPlaceEncoding_3)
                        {
                            length_3 := and(length_3, 0x7f)
                        }
                        if eq(outOfPlaceEncoding_3, lt(length_3, 32))
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x22)
                            revert(0, 0x24)
                        }
                        mstore(memPtr_3, length_3)
                        switch outOfPlaceEncoding_3
                        case 0 {
                            mstore(add(memPtr_3, 32), and(slotValue_3, not(255)))
                            ret_3 := add(add(memPtr_3, shl(5, iszero(iszero(length_3)))), 32)
                        }
                        case 1 {
                            mstore(0, /** @src 0:265:285  "string public symbol" */ 1)
                            /// @src 0:211:591  "contract InitStringTest {..."
                            let dataPos_3 := keccak256(0, 32)
                            let i_3 := 0
                            for { } lt(i_3, length_3) { i_3 := add(i_3, 32) }
                            {
                                mstore(add(add(memPtr_3, i_3), 32), sload(dataPos_3))
                                dataPos_3 := add(dataPos_3, /** @src 0:265:285  "string public symbol" */ 1)
                            }
                            /// @src 0:211:591  "contract InitStringTest {..."
                            ret_3 := add(add(memPtr_3, i_3), 32)
                        }
                        let newFreePtr_3 := add(memPtr_3, and(add(sub(ret_3, memPtr_3), 31), not(31)))
                        if or(gt(newFreePtr_3, 0xffffffffffffffff), lt(newFreePtr_3, memPtr_3))
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x41)
                            revert(0, 0x24)
                        }
                        mstore(64, newFreePtr_3)
                        let memPos_3 := mload(64)
                        return(memPos_3, sub(abi_encode_string(memPos_3, memPtr_3), memPos_3))
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
        }
        data ".metadata" hex"a264697066735822122080cd3659fd16ae2d59c5fa44485c568555addda24c720a76e8aaa4c0b8775ce564736f6c634300081c0033"
    }
}