object "ExternalLibraryTest_320" {
    code {
        {
            /// @src 0:1712:3309  "contract ExternalLibraryTest {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("ExternalLibraryTest_320_deployed")
            codecopy(_1, dataoffset("ExternalLibraryTest_320_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/bench/ExternalLibrary.sol"
    object "ExternalLibraryTest_320_deployed" {
        code {
            {
                /// @src 0:1712:3309  "contract ExternalLibraryTest {..."
                mstore(64, memoryguard(0x80))
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x6245a978 {
                        if callvalue() { revert(0, 0) }
                        let param, param_1 := abi_decode_array_uint256_dyn_calldata(calldatasize())
                        /// @src 0:2983:3012  "uint256[] memory arrMem = arr"
                        let var_arrMem_mpos := /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ abi_decode_available_length_array_uint256_dyn(/** @src 0:2983:3012  "uint256[] memory arrMem = arr" */ param, param_1, /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ calldatasize())
                        /// @src 0:3029:3049  "ArrayLib.max(arrMem)"
                        let _1 := /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ mload(64)
                        /// @src 0:3029:3049  "ArrayLib.max(arrMem)"
                        mstore(_1, /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ shl(225, 0x1dfb6f4b))
                        /// @src 0:3029:3049  "ArrayLib.max(arrMem)"
                        let _2 := delegatecall(gas(), /** @src 0:3029:3037  "ArrayLib" */ linkersymbol("foundry/src/bench/ExternalLibrary.sol:ArrayLib"), /** @src 0:3029:3049  "ArrayLib.max(arrMem)" */ _1, sub(abi_encode_array_uint256_dyn(add(_1, /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 4), /** @src 0:3029:3049  "ArrayLib.max(arrMem)" */ var_arrMem_mpos), _1), _1, 32)
                        if iszero(_2)
                        {
                            /// @src 0:1712:3309  "contract ExternalLibraryTest {..."
                            let pos := mload(64)
                            returndatacopy(pos, 0, returndatasize())
                            revert(pos, returndatasize())
                        }
                        /// @src 0:3029:3049  "ArrayLib.max(arrMem)"
                        let expr := /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 0
                        /// @src 0:3029:3049  "ArrayLib.max(arrMem)"
                        if _2
                        {
                            let _3 := 32
                            if gt(32, returndatasize()) { _3 := returndatasize() }
                            finalize_allocation(_1, _3)
                            let value0 := /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 0
                            if slt(sub(/** @src 0:3029:3049  "ArrayLib.max(arrMem)" */ add(_1, _3), _1), /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 32) { revert(0, 0) }
                            value0 := mload(/** @src 0:3029:3049  "ArrayLib.max(arrMem)" */ _1)
                            expr := value0
                        }
                        /// @src 0:1712:3309  "contract ExternalLibraryTest {..."
                        let memPos := mload(64)
                        mstore(memPos, expr)
                        return(memPos, /** @src 0:3029:3049  "ArrayLib.max(arrMem)" */ 32)
                    }
                    case /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 0x66c8f273 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 96) { revert(0, 0) }
                        /// @src 0:3247:3258  "MathLib.add"
                        let expr_address := /** @src 0:3247:3254  "MathLib" */ linkersymbol("foundry/src/bench/ExternalLibrary.sol:MathLib")
                        /// @src 0:3247:3264  "MathLib.add(a, b)"
                        let _4 := /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ mload(64)
                        /// @src 0:3247:3264  "MathLib.add(a, b)"
                        mstore(_4, /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ shl(224, 0x771602f7))
                        mstore(/** @src 0:3247:3264  "MathLib.add(a, b)" */ add(_4, /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 4), calldataload(4))
                        mstore(add(/** @src 0:3247:3264  "MathLib.add(a, b)" */ _4, /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 36), calldataload(36))
                        /// @src 0:3247:3264  "MathLib.add(a, b)"
                        let _5 := delegatecall(gas(), expr_address, _4, /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 68, /** @src 0:3247:3264  "MathLib.add(a, b)" */ _4, /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 32)
                        /// @src 0:3247:3264  "MathLib.add(a, b)"
                        if iszero(_5)
                        {
                            /// @src 0:1712:3309  "contract ExternalLibraryTest {..."
                            let pos_1 := mload(64)
                            returndatacopy(pos_1, 0, returndatasize())
                            revert(pos_1, returndatasize())
                        }
                        /// @src 0:3247:3264  "MathLib.add(a, b)"
                        let expr_1 := /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 0
                        /// @src 0:3247:3264  "MathLib.add(a, b)"
                        if _5
                        {
                            let _6 := /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 32
                            /// @src 0:3247:3264  "MathLib.add(a, b)"
                            if gt(/** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 32, /** @src 0:3247:3264  "MathLib.add(a, b)" */ returndatasize()) { _6 := returndatasize() }
                            finalize_allocation(_4, _6)
                            let value0_1 := /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 0
                            if slt(sub(/** @src 0:3247:3264  "MathLib.add(a, b)" */ add(_4, _6), _4), /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 32) { revert(0, 0) }
                            value0_1 := mload(/** @src 0:3247:3264  "MathLib.add(a, b)" */ _4)
                            expr_1 := value0_1
                        }
                        /// @src 0:3281:3300  "MathLib.mul(sum, c)"
                        let _7 := /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ mload(64)
                        /// @src 0:3281:3300  "MathLib.mul(sum, c)"
                        mstore(_7, /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ shl(226, 0x32292b27))
                        mstore(/** @src 0:3281:3300  "MathLib.mul(sum, c)" */ add(_7, /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 4), expr_1)
                        mstore(add(/** @src 0:3281:3300  "MathLib.mul(sum, c)" */ _7, /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 36), calldataload(68))
                        /// @src 0:3281:3300  "MathLib.mul(sum, c)"
                        let _8 := delegatecall(gas(), expr_address, _7, /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 68, /** @src 0:3281:3300  "MathLib.mul(sum, c)" */ _7, /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 32)
                        /// @src 0:3281:3300  "MathLib.mul(sum, c)"
                        if iszero(_8)
                        {
                            /// @src 0:1712:3309  "contract ExternalLibraryTest {..."
                            let pos_2 := mload(64)
                            returndatacopy(pos_2, 0, returndatasize())
                            revert(pos_2, returndatasize())
                        }
                        /// @src 0:3281:3300  "MathLib.mul(sum, c)"
                        let expr_2 := /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 0
                        /// @src 0:3281:3300  "MathLib.mul(sum, c)"
                        if _8
                        {
                            let _9 := /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 32
                            /// @src 0:3281:3300  "MathLib.mul(sum, c)"
                            if gt(/** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 32, /** @src 0:3281:3300  "MathLib.mul(sum, c)" */ returndatasize()) { _9 := returndatasize() }
                            finalize_allocation(_7, _9)
                            let value0_2 := /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 0
                            if slt(sub(/** @src 0:3281:3300  "MathLib.mul(sum, c)" */ add(_7, _9), _7), /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 32) { revert(0, 0) }
                            value0_2 := mload(/** @src 0:3281:3300  "MathLib.mul(sum, c)" */ _7)
                            expr_2 := value0_2
                        }
                        /// @src 0:1712:3309  "contract ExternalLibraryTest {..."
                        let memPos_1 := mload(64)
                        mstore(memPos_1, expr_2)
                        return(memPos_1, 32)
                    }
                    case 0x7c3ffef2 {
                        if callvalue() { revert(0, 0) }
                        let param_2, param_3 := abi_decode_uint256t_uint256(calldatasize())
                        /// @src 0:2009:2026  "MathLib.add(a, b)"
                        let _10 := /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ mload(64)
                        /// @src 0:2009:2026  "MathLib.add(a, b)"
                        mstore(_10, /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ shl(224, 0x771602f7))
                        mstore(/** @src 0:2009:2026  "MathLib.add(a, b)" */ add(_10, /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 4), param_2)
                        mstore(add(/** @src 0:2009:2026  "MathLib.add(a, b)" */ _10, /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 36), param_3)
                        /// @src 0:2009:2026  "MathLib.add(a, b)"
                        let _11 := delegatecall(gas(), /** @src 0:2009:2016  "MathLib" */ linkersymbol("foundry/src/bench/ExternalLibrary.sol:MathLib"), /** @src 0:2009:2026  "MathLib.add(a, b)" */ _10, 68, _10, /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 32)
                        /// @src 0:2009:2026  "MathLib.add(a, b)"
                        if iszero(_11)
                        {
                            /// @src 0:1712:3309  "contract ExternalLibraryTest {..."
                            let pos_3 := mload(64)
                            returndatacopy(pos_3, 0, returndatasize())
                            revert(pos_3, returndatasize())
                        }
                        /// @src 0:2009:2026  "MathLib.add(a, b)"
                        let expr_3 := /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 0
                        /// @src 0:2009:2026  "MathLib.add(a, b)"
                        if _11
                        {
                            let _12 := /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 32
                            /// @src 0:2009:2026  "MathLib.add(a, b)"
                            if gt(/** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 32, /** @src 0:2009:2026  "MathLib.add(a, b)" */ returndatasize()) { _12 := returndatasize() }
                            finalize_allocation(_10, _12)
                            let value0_3 := /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 0
                            if slt(sub(/** @src 0:2009:2026  "MathLib.add(a, b)" */ add(_10, _12), _10), /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 32) { revert(0, 0) }
                            value0_3 := mload(/** @src 0:2009:2026  "MathLib.add(a, b)" */ _10)
                            expr_3 := value0_3
                        }
                        /// @src 0:1712:3309  "contract ExternalLibraryTest {..."
                        sstore(0, expr_3)
                        let memPos_2 := mload(64)
                        mstore(memPos_2, expr_3)
                        return(memPos_2, 32)
                    }
                    case 0xabcc11d8 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _13 := sload(0)
                        let memPos_3 := mload(64)
                        mstore(memPos_3, _13)
                        return(memPos_3, 32)
                    }
                    case 0xbd2c7195 {
                        if callvalue() { revert(0, 0) }
                        let param_4, param_5 := abi_decode_uint256t_uint256(calldatasize())
                        /// @src 0:2194:2211  "MathLib.mul(a, b)"
                        let _14 := /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ mload(64)
                        /// @src 0:2194:2211  "MathLib.mul(a, b)"
                        mstore(_14, /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ shl(226, 0x32292b27))
                        mstore(/** @src 0:2194:2211  "MathLib.mul(a, b)" */ add(_14, /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 4), param_4)
                        mstore(add(/** @src 0:2194:2211  "MathLib.mul(a, b)" */ _14, /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 36), param_5)
                        /// @src 0:2194:2211  "MathLib.mul(a, b)"
                        let _15 := delegatecall(gas(), /** @src 0:2194:2201  "MathLib" */ linkersymbol("foundry/src/bench/ExternalLibrary.sol:MathLib"), /** @src 0:2194:2211  "MathLib.mul(a, b)" */ _14, 68, _14, /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 32)
                        /// @src 0:2194:2211  "MathLib.mul(a, b)"
                        if iszero(_15)
                        {
                            /// @src 0:1712:3309  "contract ExternalLibraryTest {..."
                            let pos_4 := mload(64)
                            returndatacopy(pos_4, 0, returndatasize())
                            revert(pos_4, returndatasize())
                        }
                        /// @src 0:2194:2211  "MathLib.mul(a, b)"
                        let expr_4 := /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 0
                        /// @src 0:2194:2211  "MathLib.mul(a, b)"
                        if _15
                        {
                            let _16 := /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 32
                            /// @src 0:2194:2211  "MathLib.mul(a, b)"
                            if gt(/** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 32, /** @src 0:2194:2211  "MathLib.mul(a, b)" */ returndatasize()) { _16 := returndatasize() }
                            finalize_allocation(_14, _16)
                            let value0_4 := /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 0
                            if slt(sub(/** @src 0:2194:2211  "MathLib.mul(a, b)" */ add(_14, _16), _14), /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 32) { revert(0, 0) }
                            value0_4 := mload(/** @src 0:2194:2211  "MathLib.mul(a, b)" */ _14)
                            expr_4 := value0_4
                        }
                        /// @src 0:1712:3309  "contract ExternalLibraryTest {..."
                        let memPos_4 := mload(64)
                        mstore(memPos_4, expr_4)
                        return(memPos_4, 32)
                    }
                    case 0xbe1beee0 {
                        if callvalue() { revert(0, 0) }
                        let param_6, param_7 := abi_decode_array_uint256_dyn_calldata(calldatasize())
                        /// @src 0:2771:2800  "uint256[] memory arrMem = arr"
                        let var_arrMem_mpos_1 := /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ abi_decode_available_length_array_uint256_dyn(/** @src 0:2771:2800  "uint256[] memory arrMem = arr" */ param_6, param_7, /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ calldatasize())
                        /// @src 0:2817:2837  "ArrayLib.sum(arrMem)"
                        let _17 := /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ mload(64)
                        /// @src 0:2817:2837  "ArrayLib.sum(arrMem)"
                        mstore(_17, /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ shl(225, 13266375))
                        /// @src 0:2817:2837  "ArrayLib.sum(arrMem)"
                        let _18 := delegatecall(gas(), /** @src 0:2817:2825  "ArrayLib" */ linkersymbol("foundry/src/bench/ExternalLibrary.sol:ArrayLib"), /** @src 0:2817:2837  "ArrayLib.sum(arrMem)" */ _17, sub(abi_encode_array_uint256_dyn(add(_17, /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 4), /** @src 0:2817:2837  "ArrayLib.sum(arrMem)" */ var_arrMem_mpos_1), _17), _17, 32)
                        if iszero(_18)
                        {
                            /// @src 0:1712:3309  "contract ExternalLibraryTest {..."
                            let pos_5 := mload(64)
                            returndatacopy(pos_5, 0, returndatasize())
                            revert(pos_5, returndatasize())
                        }
                        /// @src 0:2817:2837  "ArrayLib.sum(arrMem)"
                        let expr_5 := /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 0
                        /// @src 0:2817:2837  "ArrayLib.sum(arrMem)"
                        if _18
                        {
                            let _19 := 32
                            if gt(32, returndatasize()) { _19 := returndatasize() }
                            finalize_allocation(_17, _19)
                            let value0_5 := /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 0
                            if slt(sub(/** @src 0:2817:2837  "ArrayLib.sum(arrMem)" */ add(_17, _19), _17), /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 32) { revert(0, 0) }
                            value0_5 := mload(/** @src 0:2817:2837  "ArrayLib.sum(arrMem)" */ _17)
                            expr_5 := value0_5
                        }
                        /// @src 0:1712:3309  "contract ExternalLibraryTest {..."
                        let memPos_5 := mload(64)
                        mstore(memPos_5, expr_5)
                        return(memPos_5, /** @src 0:2817:2837  "ArrayLib.sum(arrMem)" */ 32)
                    }
                    case /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 0xbe2e7302 {
                        if callvalue() { revert(0, 0) }
                        let param_8, param_9 := abi_decode_uint256t_uint256(calldatasize())
                        let sum := add(param_8, param_9)
                        if gt(param_8, sum)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        let memPos_6 := mload(64)
                        mstore(memPos_6, sum)
                        return(memPos_6, 32)
                    }
                    case 0xc1ade926 {
                        if callvalue() { revert(0, 0) }
                        let param_10, param_11 := abi_decode_uint256t_uint256(calldatasize())
                        /// @src 0:2377:2399  "MathLib.pow(base, exp)"
                        let _20 := /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ mload(64)
                        /// @src 0:2377:2399  "MathLib.pow(base, exp)"
                        mstore(_20, /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ shl(224, 0x2e4c697f))
                        mstore(/** @src 0:2377:2399  "MathLib.pow(base, exp)" */ add(_20, /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 4), param_10)
                        mstore(add(/** @src 0:2377:2399  "MathLib.pow(base, exp)" */ _20, /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 36), param_11)
                        /// @src 0:2377:2399  "MathLib.pow(base, exp)"
                        let _21 := delegatecall(gas(), /** @src 0:2377:2384  "MathLib" */ linkersymbol("foundry/src/bench/ExternalLibrary.sol:MathLib"), /** @src 0:2377:2399  "MathLib.pow(base, exp)" */ _20, 68, _20, /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 32)
                        /// @src 0:2377:2399  "MathLib.pow(base, exp)"
                        if iszero(_21)
                        {
                            /// @src 0:1712:3309  "contract ExternalLibraryTest {..."
                            let pos_6 := mload(64)
                            returndatacopy(pos_6, 0, returndatasize())
                            revert(pos_6, returndatasize())
                        }
                        /// @src 0:2377:2399  "MathLib.pow(base, exp)"
                        let expr_6 := /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 0
                        /// @src 0:2377:2399  "MathLib.pow(base, exp)"
                        if _21
                        {
                            let _22 := /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 32
                            /// @src 0:2377:2399  "MathLib.pow(base, exp)"
                            if gt(/** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 32, /** @src 0:2377:2399  "MathLib.pow(base, exp)" */ returndatasize()) { _22 := returndatasize() }
                            finalize_allocation(_20, _22)
                            let value0_6 := /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 0
                            if slt(sub(/** @src 0:2377:2399  "MathLib.pow(base, exp)" */ add(_20, _22), _20), /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 32) { revert(0, 0) }
                            value0_6 := mload(/** @src 0:2377:2399  "MathLib.pow(base, exp)" */ _20)
                            expr_6 := value0_6
                        }
                        /// @src 0:1712:3309  "contract ExternalLibraryTest {..."
                        let memPos_7 := mload(64)
                        mstore(memPos_7, expr_6)
                        return(memPos_7, 32)
                    }
                }
                revert(0, 0)
            }
            function abi_decode_array_uint256_dyn_calldata(dataEnd) -> value0, value1
            {
                if slt(add(dataEnd, not(3)), 32) { revert(0, 0) }
                let offset := calldataload(4)
                if gt(offset, 0xffffffffffffffff) { revert(0, 0) }
                if iszero(slt(add(offset, 35), dataEnd))
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:1712:3309  "contract ExternalLibraryTest {..."
                let length := calldataload(add(4, offset))
                if gt(length, 0xffffffffffffffff)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:1712:3309  "contract ExternalLibraryTest {..."
                if gt(add(add(offset, shl(5, length)), 36), dataEnd)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:1712:3309  "contract ExternalLibraryTest {..."
                value0 := add(offset, 36)
                value1 := length
            }
            function abi_decode_uint256t_uint256(dataEnd) -> value0, value1
            {
                if slt(add(dataEnd, not(3)), 64) { revert(0, 0) }
                value0 := calldataload(4)
                value1 := calldataload(36)
            }
            function finalize_allocation(memPtr, size)
            {
                let newFreePtr := add(memPtr, and(add(size, 31), not(31)))
                if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr))
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x41)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 0x24)
                }
                mstore(64, newFreePtr)
            }
            function abi_decode_available_length_array_uint256_dyn(offset, length, end) -> array
            {
                if gt(length, 0xffffffffffffffff)
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ shl(224, 0x4e487b71))
                    mstore(4, 0x41)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 0:1712:3309  "contract ExternalLibraryTest {..." */ 0x24)
                }
                let _1 := shl(5, length)
                let memPtr := mload(64)
                finalize_allocation(memPtr, add(_1, 0x20))
                array := memPtr
                let dst := memPtr
                mstore(memPtr, length)
                dst := add(memPtr, 0x20)
                let srcEnd := add(offset, _1)
                if gt(srcEnd, end)
                {
                    revert(/** @src -1:-1:-1 */ 0, 0)
                }
                /// @src 0:1712:3309  "contract ExternalLibraryTest {..."
                let src := offset
                for { } lt(src, srcEnd) { src := add(src, 0x20) }
                {
                    mstore(dst, calldataload(src))
                    dst := add(dst, 0x20)
                }
            }
            function abi_encode_array_uint256_dyn(headStart, value0) -> tail
            {
                let tail_1 := add(headStart, 32)
                mstore(headStart, 32)
                let pos := tail_1
                let length := mload(value0)
                mstore(tail_1, length)
                pos := add(headStart, 64)
                let srcPtr := add(value0, 32)
                let i := 0
                for { } lt(i, length) { i := add(i, 1) }
                {
                    mstore(pos, mload(srcPtr))
                    pos := add(pos, 32)
                    srcPtr := add(srcPtr, 32)
                }
                tail := pos
            }
        }
        data ".metadata" hex"a264697066735822122041449beefdc086550ece5d572524811f51571d240b4944add1e35b748d76b04964736f6c634300081c0033"
    }
}