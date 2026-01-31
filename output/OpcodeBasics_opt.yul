object "OpcodeBasics_163" {
    code {
        {
            /// @src 0:57:1246  "contract OpcodeBasics {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("OpcodeBasics_163_deployed")
            codecopy(_1, dataoffset("OpcodeBasics_163_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"contracts/OpcodeBasics.sol"
    object "OpcodeBasics_163_deployed" {
        code {
            {
                /// @src 0:57:1246  "contract OpcodeBasics {..."
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x12daf456 {
                        if callvalue() { revert(0, 0) }
                        let param, param_1 := abi_decode_uint256t_uint256(calldatasize())
                        /// @src 0:501:514  "a > b ? 1 : 0"
                        let expr := /** @src 0:57:1246  "contract OpcodeBasics {..." */ 0
                        /// @src 0:501:514  "a > b ? 1 : 0"
                        switch /** @src 0:501:506  "a > b" */ gt(param, param_1)
                        case /** @src 0:501:514  "a > b ? 1 : 0" */ 0 {
                            expr := /** @src 0:57:1246  "contract OpcodeBasics {..." */ 0
                        }
                        default /// @src 0:501:514  "a > b ? 1 : 0"
                        {
                            expr := /** @src 0:509:510  "1" */ 0x01
                        }
                        /// @src 0:57:1246  "contract OpcodeBasics {..."
                        mstore(_1, and(/** @src 0:494:514  "return a > b ? 1 : 0" */ expr, /** @src 0:57:1246  "contract OpcodeBasics {..." */ 0xff))
                        return(_1, 32)
                    }
                    case 0x17fafa3b {
                        if callvalue() { revert(0, 0) }
                        let param_2, param_3 := abi_decode_uint256t_uint256(calldatasize())
                        let diff := sub(param_2, param_3)
                        if gt(diff, param_2)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        let memPos := mload(64)
                        mstore(memPos, diff)
                        return(memPos, 32)
                    }
                    case 0x24c61d38 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        /// @src 0:909:922  "a < b ? 1 : 0"
                        let expr_1 := /** @src 0:57:1246  "contract OpcodeBasics {..." */ 0
                        /// @src 0:909:922  "a < b ? 1 : 0"
                        switch /** @src 0:909:914  "a < b" */ lt(/** @src 0:890:892  "10" */ 0x0a, /** @src 0:57:1246  "contract OpcodeBasics {..." */ calldataload(4))
                        case /** @src 0:909:922  "a < b ? 1 : 0" */ 0 {
                            expr_1 := /** @src 0:57:1246  "contract OpcodeBasics {..." */ 0
                        }
                        default /// @src 0:909:922  "a < b ? 1 : 0"
                        {
                            expr_1 := /** @src 0:57:1246  "contract OpcodeBasics {..." */ 1
                        }
                        let memPos_1 := mload(64)
                        mstore(memPos_1, and(/** @src 0:902:922  "return a < b ? 1 : 0" */ expr_1, /** @src 0:57:1246  "contract OpcodeBasics {..." */ 0xff))
                        return(memPos_1, 32)
                    }
                    case 0x35d7a7cf {
                        if callvalue() { revert(0, 0) }
                        let param_4, param_5 := abi_decode_uint256t_uint256(calldatasize())
                        /// @src 0:758:787  "int256(a) < int256(b) ? 1 : 0"
                        let expr_2 := /** @src 0:57:1246  "contract OpcodeBasics {..." */ 0
                        /// @src 0:758:787  "int256(a) < int256(b) ? 1 : 0"
                        switch /** @src 0:758:779  "int256(a) < int256(b)" */ slt(param_4, /** @src 0:770:779  "int256(b)" */ param_5)
                        case /** @src 0:758:787  "int256(a) < int256(b) ? 1 : 0" */ 0 {
                            expr_2 := /** @src 0:57:1246  "contract OpcodeBasics {..." */ 0
                        }
                        default /// @src 0:758:787  "int256(a) < int256(b) ? 1 : 0"
                        {
                            expr_2 := /** @src 0:782:783  "1" */ 0x01
                        }
                        /// @src 0:57:1246  "contract OpcodeBasics {..."
                        let memPos_2 := mload(64)
                        mstore(memPos_2, and(/** @src 0:751:787  "return int256(a) < int256(b) ? 1 : 0" */ expr_2, /** @src 0:57:1246  "contract OpcodeBasics {..." */ 0xff))
                        return(memPos_2, 32)
                    }
                    case 0x59a11321 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let value := calldataload(4)
                        /// @src 0:1121:1138  "uint256 count = 0"
                        let var_count := /** @src 0:57:1246  "contract OpcodeBasics {..." */ 0
                        /// @src 0:1153:1166  "uint256 i = 0"
                        let var_i := /** @src 0:57:1246  "contract OpcodeBasics {..." */ 0
                        /// @src 0:1148:1216  "for (uint256 i = 0; i < limit; i++) {..."
                        for { }
                        /** @src 0:1168:1177  "i < limit" */ lt(var_i, value)
                        /// @src 0:1153:1166  "uint256 i = 0"
                        {
                            /// @src 0:1179:1182  "i++"
                            var_i := /** @src 0:57:1246  "contract OpcodeBasics {..." */ add(/** @src 0:1179:1182  "i++" */ var_i, /** @src 0:57:1246  "contract OpcodeBasics {..." */ 1)
                        }
                        /// @src 0:1179:1182  "i++"
                        {
                            /// @src 0:57:1246  "contract OpcodeBasics {..."
                            if eq(var_count, not(0))
                            {
                                mstore(0, shl(224, 0x4e487b71))
                                mstore(4, 0x11)
                                revert(0, 0x24)
                            }
                            /// @src 0:1198:1205  "count++"
                            var_count := /** @src 0:57:1246  "contract OpcodeBasics {..." */ add(var_count, 1)
                        }
                        let memPos_3 := mload(64)
                        mstore(memPos_3, var_count)
                        return(memPos_3, 32)
                    }
                    case 0x5a0db89e {
                        if callvalue() { revert(0, 0) }
                        let param_6, param_7 := abi_decode_uint256t_uint256(calldatasize())
                        let product := mul(param_6, param_7)
                        if iszero(or(iszero(param_6), eq(param_7, div(product, param_6))))
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        let memPos_4 := mload(64)
                        mstore(memPos_4, product)
                        return(memPos_4, 32)
                    }
                    case 0x5d6c9250 {
                        if callvalue() { revert(0, 0) }
                        let param_8, param_9 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_5 := mload(64)
                        mstore(memPos_5, shl(param_8, param_9))
                        return(memPos_5, 32)
                    }
                    case 0x62d2c41d {
                        if callvalue() { revert(0, 0) }
                        let param_10, param_11 := abi_decode_uint256t_uint256(calldatasize())
                        /// @src 0:387:400  "a < b ? 1 : 0"
                        let expr_3 := /** @src 0:57:1246  "contract OpcodeBasics {..." */ 0
                        /// @src 0:387:400  "a < b ? 1 : 0"
                        switch /** @src 0:387:392  "a < b" */ lt(param_10, param_11)
                        case /** @src 0:387:400  "a < b ? 1 : 0" */ 0 {
                            expr_3 := /** @src 0:57:1246  "contract OpcodeBasics {..." */ 0
                        }
                        default /// @src 0:387:400  "a < b ? 1 : 0"
                        {
                            expr_3 := /** @src 0:395:396  "1" */ 0x01
                        }
                        /// @src 0:57:1246  "contract OpcodeBasics {..."
                        let memPos_6 := mload(64)
                        mstore(memPos_6, and(/** @src 0:380:400  "return a < b ? 1 : 0" */ expr_3, /** @src 0:57:1246  "contract OpcodeBasics {..." */ 0xff))
                        return(memPos_6, 32)
                    }
                    case 0xf21b1150 {
                        if callvalue() { revert(0, 0) }
                        let param_12, param_13 := abi_decode_uint256t_uint256(calldatasize())
                        if iszero(param_13)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x12)
                            revert(0, 0x24)
                        }
                        let memPos_7 := mload(64)
                        mstore(memPos_7, div(param_12, param_13))
                        return(memPos_7, 32)
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
        }
        data ".metadata" hex"a2646970667358221220088d106c157ec7ce706fe8205fa4e4040a5c2716302a970af1b0ddee747191cf64736f6c634300081c0033"
    }
}