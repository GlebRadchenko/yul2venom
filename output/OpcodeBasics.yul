object "OpcodeBasics_184" {
    code {
        {
            /// @src 0:57:1677  "contract OpcodeBasics {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("OpcodeBasics_184_deployed")
            codecopy(_1, dataoffset("OpcodeBasics_184_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/OpcodeBasics.sol"
    object "OpcodeBasics_184_deployed" {
        code {
            {
                /// @src 0:57:1677  "contract OpcodeBasics {..."
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x12daf456 {
                        if callvalue() { revert(0, 0) }
                        let param, param_1 := abi_decode_uint256t_uint256(calldatasize())
                        /// @src 0:703:716  "a > b ? 1 : 0"
                        let expr := /** @src 0:57:1677  "contract OpcodeBasics {..." */ 0
                        /// @src 0:703:716  "a > b ? 1 : 0"
                        switch /** @src 0:703:708  "a > b" */ gt(param, param_1)
                        case /** @src 0:703:716  "a > b ? 1 : 0" */ 0 {
                            expr := /** @src 0:57:1677  "contract OpcodeBasics {..." */ 0
                        }
                        default /// @src 0:703:716  "a > b ? 1 : 0"
                        {
                            expr := /** @src 0:711:712  "1" */ 0x01
                        }
                        /// @src 0:57:1677  "contract OpcodeBasics {..."
                        mstore(_1, and(/** @src 0:696:716  "return a > b ? 1 : 0" */ expr, /** @src 0:57:1677  "contract OpcodeBasics {..." */ 0xff))
                        return(_1, 32)
                    }
                    case 0x17fafa3b {
                        if callvalue() { revert(0, 0) }
                        let param_2, param_3 := abi_decode_uint256t_uint256(calldatasize())
                        let ret := fun_test_sub(param_2, param_3)
                        let memPos := mload(64)
                        mstore(memPos, ret)
                        return(memPos, 32)
                    }
                    case 0x24c61d38 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        /// @src 0:1111:1124  "a < b ? 1 : 0"
                        let expr_1 := /** @src 0:57:1677  "contract OpcodeBasics {..." */ 0
                        /// @src 0:1111:1124  "a < b ? 1 : 0"
                        switch /** @src 0:1111:1116  "a < b" */ lt(/** @src 0:1092:1094  "10" */ 0x0a, /** @src 0:57:1677  "contract OpcodeBasics {..." */ calldataload(4))
                        case /** @src 0:1111:1124  "a < b ? 1 : 0" */ 0 {
                            expr_1 := /** @src 0:57:1677  "contract OpcodeBasics {..." */ 0
                        }
                        default /// @src 0:1111:1124  "a < b ? 1 : 0"
                        {
                            expr_1 := /** @src 0:57:1677  "contract OpcodeBasics {..." */ 1
                        }
                        let memPos_1 := mload(64)
                        mstore(memPos_1, and(/** @src 0:1104:1124  "return a < b ? 1 : 0" */ expr_1, /** @src 0:57:1677  "contract OpcodeBasics {..." */ 0xff))
                        return(memPos_1, 32)
                    }
                    case 0x35d7a7cf {
                        if callvalue() { revert(0, 0) }
                        let param_4, param_5 := abi_decode_uint256t_uint256(calldatasize())
                        /// @src 0:960:989  "int256(a) < int256(b) ? 1 : 0"
                        let expr_2 := /** @src 0:57:1677  "contract OpcodeBasics {..." */ 0
                        /// @src 0:960:989  "int256(a) < int256(b) ? 1 : 0"
                        switch /** @src 0:960:981  "int256(a) < int256(b)" */ slt(param_4, /** @src 0:972:981  "int256(b)" */ param_5)
                        case /** @src 0:960:989  "int256(a) < int256(b) ? 1 : 0" */ 0 {
                            expr_2 := /** @src 0:57:1677  "contract OpcodeBasics {..." */ 0
                        }
                        default /// @src 0:960:989  "int256(a) < int256(b) ? 1 : 0"
                        {
                            expr_2 := /** @src 0:984:985  "1" */ 0x01
                        }
                        /// @src 0:57:1677  "contract OpcodeBasics {..."
                        let memPos_2 := mload(64)
                        mstore(memPos_2, and(/** @src 0:953:989  "return int256(a) < int256(b) ? 1 : 0" */ expr_2, /** @src 0:57:1677  "contract OpcodeBasics {..." */ 0xff))
                        return(memPos_2, 32)
                    }
                    case 0x59a11321 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let var_limit := calldataload(4)
                        /// @src 0:1510:1542  "if (limit > 10000) limit = 10000"
                        if /** @src 0:1514:1527  "limit > 10000" */ gt(var_limit, /** @src 0:1522:1527  "10000" */ 0x2710)
                        /// @src 0:1510:1542  "if (limit > 10000) limit = 10000"
                        {
                            /// @src 0:1529:1542  "limit = 10000"
                            var_limit := /** @src 0:1522:1527  "10000" */ 0x2710
                        }
                        /// @src 0:1552:1569  "uint256 count = 0"
                        let var_count := /** @src 0:57:1677  "contract OpcodeBasics {..." */ 0
                        /// @src 0:1584:1597  "uint256 i = 0"
                        let var_i := /** @src 0:57:1677  "contract OpcodeBasics {..." */ 0
                        /// @src 0:1579:1647  "for (uint256 i = 0; i < limit; i++) {..."
                        for { }
                        /** @src 0:1599:1608  "i < limit" */ lt(var_i, var_limit)
                        /// @src 0:1584:1597  "uint256 i = 0"
                        {
                            /// @src 0:1610:1613  "i++"
                            var_i := /** @src 0:57:1677  "contract OpcodeBasics {..." */ add(/** @src 0:1610:1613  "i++" */ var_i, /** @src 0:57:1677  "contract OpcodeBasics {..." */ 1)
                        }
                        /// @src 0:1610:1613  "i++"
                        {
                            /// @src 0:57:1677  "contract OpcodeBasics {..."
                            if eq(var_count, not(0))
                            {
                                mstore(0, shl(224, 0x4e487b71))
                                mstore(4, 0x11)
                                revert(0, 0x24)
                            }
                            /// @src 0:1629:1636  "count++"
                            var_count := /** @src 0:57:1677  "contract OpcodeBasics {..." */ add(var_count, 1)
                        }
                        let memPos_3 := mload(64)
                        mstore(memPos_3, var_count)
                        return(memPos_3, 32)
                    }
                    case 0x5a0db89e {
                        if callvalue() { revert(0, 0) }
                        let param_6, param_7 := abi_decode_uint256t_uint256(calldatasize())
                        let memPos_4 := mload(64)
                        mstore(memPos_4, mul(param_6, param_7))
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
                        /// @src 0:589:602  "a < b ? 1 : 0"
                        let expr_3 := /** @src 0:57:1677  "contract OpcodeBasics {..." */ 0
                        /// @src 0:589:602  "a < b ? 1 : 0"
                        switch /** @src 0:589:594  "a < b" */ lt(param_10, param_11)
                        case /** @src 0:589:602  "a < b ? 1 : 0" */ 0 {
                            expr_3 := /** @src 0:57:1677  "contract OpcodeBasics {..." */ 0
                        }
                        default /// @src 0:589:602  "a < b ? 1 : 0"
                        {
                            expr_3 := /** @src 0:597:598  "1" */ 0x01
                        }
                        /// @src 0:57:1677  "contract OpcodeBasics {..."
                        let memPos_6 := mload(64)
                        mstore(memPos_6, and(/** @src 0:582:602  "return a < b ? 1 : 0" */ expr_3, /** @src 0:57:1677  "contract OpcodeBasics {..." */ 0xff))
                        return(memPos_6, 32)
                    }
                    case 0xf21b1150 {
                        if callvalue() { revert(0, 0) }
                        let param_12, param_13 := abi_decode_uint256t_uint256(calldatasize())
                        let ret_1 := fun_test_div(param_12, param_13)
                        let memPos_7 := mload(64)
                        mstore(memPos_7, ret_1)
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
            /// @ast-id 21 @src 0:85:287  "function test_sub(uint256 a, uint256 b) external pure returns (uint256) {..."
            function fun_test_sub(var_a, var_b) -> var
            {
                /// @src 0:148:155  "uint256"
                var := /** @src 0:57:1677  "contract OpcodeBasics {..." */ 0
                /// @src 0:239:258  "if (b > a) return 0"
                if /** @src 0:243:248  "b > a" */ gt(var_b, var_a)
                /// @src 0:239:258  "if (b > a) return 0"
                {
                    /// @src 0:250:258  "return 0"
                    var := /** @src 0:57:1677  "contract OpcodeBasics {..." */ 0
                    /// @src 0:250:258  "return 0"
                    leave
                }
                /// @src 0:57:1677  "contract OpcodeBasics {..."
                let diff := sub(var_a, var_b)
                if gt(diff, var_a)
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x11)
                    revert(0, 0x24)
                }
                /// @src 0:268:280  "return a - b"
                var := diff
            }
            /// @ast-id 41 @src 0:293:495  "function test_div(uint256 a, uint256 b) external pure returns (uint256) {..."
            function fun_test_div(var_a, var_b) -> var
            {
                /// @src 0:356:363  "uint256"
                var := /** @src 0:57:1677  "contract OpcodeBasics {..." */ 0
                /// @src 0:450:456  "b == 0"
                let _1 := iszero(var_b)
                /// @src 0:446:466  "if (b == 0) return 0"
                if /** @src 0:450:456  "b == 0" */ _1
                /// @src 0:446:466  "if (b == 0) return 0"
                {
                    /// @src 0:458:466  "return 0"
                    var := /** @src 0:57:1677  "contract OpcodeBasics {..." */ 0
                    /// @src 0:458:466  "return 0"
                    leave
                }
                /// @src 0:57:1677  "contract OpcodeBasics {..."
                _1 := 0
                /// @src 0:476:488  "return a / b"
                var := /** @src 0:57:1677  "contract OpcodeBasics {..." */ div(var_a, var_b)
            }
        }
        data ".metadata" hex"a2646970667358221220ccca923e221e2f4b35e53271b8e617caa6881153521fd77329c0e1c55d15d93a64736f6c634300081c0033"
    }
}