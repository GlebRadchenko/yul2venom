object "ControlFlow_331" {
    code {
        {
            /// @src 0:158:2613  "contract ControlFlow {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("ControlFlow_331_deployed")
            codecopy(_1, dataoffset("ControlFlow_331_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/bench/ControlFlow.sol"
    object "ControlFlow_331_deployed" {
        code {
            {
                /// @src 0:158:2613  "contract ControlFlow {..."
                mstore(64, memoryguard(0x80))
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x236744b0 {
                        if callvalue() { revert(0, 0) }
                        let param, param_1 := abi_decode_uint256t_uint256(calldatasize())
                        let var_skipEvery := param_1
                        let var_n := param
                        /// @src 0:2371:2393  "if (n > 1000) n = 1000"
                        if /** @src 0:2375:2383  "n > 1000" */ gt(param, /** @src 0:2379:2383  "1000" */ 0x03e8)
                        /// @src 0:2371:2393  "if (n > 1000) n = 1000"
                        {
                            /// @src 0:2385:2393  "n = 1000"
                            var_n := /** @src 0:2379:2383  "1000" */ 0x03e8
                        }
                        /// @src 0:2403:2436  "if (skipEvery == 0) skipEvery = 1"
                        if /** @src 0:2407:2421  "skipEvery == 0" */ iszero(param_1)
                        /// @src 0:2403:2436  "if (skipEvery == 0) skipEvery = 1"
                        {
                            /// @src 0:2423:2436  "skipEvery = 1"
                            var_skipEvery := /** @src 0:2435:2436  "1" */ 0x01
                        }
                        /// @src 0:2446:2463  "uint256 count = 0"
                        let var_count := /** @src 0:158:2613  "contract ControlFlow {..." */ 0
                        /// @src 0:2478:2491  "uint256 i = 0"
                        let var_i := /** @src 0:158:2613  "contract ControlFlow {..." */ 0
                        /// @src 0:2473:2583  "for (uint256 i = 0; i < n; i++) {..."
                        for { }
                        /** @src 0:2493:2498  "i < n" */ lt(var_i, var_n)
                        /// @src 0:2478:2491  "uint256 i = 0"
                        {
                            /// @src 0:2500:2503  "i++"
                            var_i := /** @src 0:158:2613  "contract ControlFlow {..." */ add(/** @src 0:2500:2503  "i++" */ var_i, /** @src 0:158:2613  "contract ControlFlow {..." */ 1)
                        }
                        /// @src 0:2500:2503  "i++"
                        {
                            /// @src 0:158:2613  "contract ControlFlow {..."
                            if iszero(var_skipEvery)
                            {
                                mstore(0, shl(224, 0x4e487b71))
                                mstore(4, 0x12)
                                revert(0, 0x24)
                            }
                            /// @src 0:2519:2551  "if (i % skipEvery == 0) continue"
                            if /** @src 0:2523:2541  "i % skipEvery == 0" */ iszero(/** @src 0:158:2613  "contract ControlFlow {..." */ mod(var_i, var_skipEvery))
                            /// @src 0:2519:2551  "if (i % skipEvery == 0) continue"
                            {
                                /// @src 0:2543:2551  "continue"
                                continue
                            }
                            /// @src 0:2565:2572  "count++"
                            var_count := increment_uint256(var_count)
                        }
                        /// @src 0:158:2613  "contract ControlFlow {..."
                        let memPos := mload(64)
                        mstore(memPos, var_count)
                        return(memPos, 32)
                    }
                    case 0x5a5e80e7 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let var_n_1 := calldataload(4)
                        /// @src 0:774:798  "if (n > 10000) n = 10000"
                        if /** @src 0:778:787  "n > 10000" */ gt(var_n_1, /** @src 0:782:787  "10000" */ 0x2710)
                        /// @src 0:774:798  "if (n > 10000) n = 10000"
                        {
                            /// @src 0:789:798  "n = 10000"
                            var_n_1 := /** @src 0:782:787  "10000" */ 0x2710
                        }
                        /// @src 0:808:821  "uint256 i = 0"
                        let var_i_1 := /** @src 0:158:2613  "contract ControlFlow {..." */ 0
                        /// @src 0:831:873  "while (i < n) {..."
                        for { }
                        /** @src 0:838:843  "i < n" */ lt(var_i_1, var_n_1)
                        /// @src 0:831:873  "while (i < n) {..."
                        { }
                        {
                            /// @src 0:859:862  "i++"
                            var_i_1 := increment_uint256(var_i_1)
                        }
                        /// @src 0:158:2613  "contract ControlFlow {..."
                        let memPos_1 := mload(64)
                        mstore(memPos_1, var_i_1)
                        return(memPos_1, 32)
                    }
                    case 0x6954c6ec {
                        if callvalue() { revert(0, 0) }
                        let param_2, param_3 := abi_decode_uint256t_uint256(calldatasize())
                        let var_inner := param_3
                        let var_outer := param_2
                        /// @src 0:1059:1087  "if (outer > 100) outer = 100"
                        if /** @src 0:1063:1074  "outer > 100" */ gt(param_2, /** @src 0:1071:1074  "100" */ 0x64)
                        /// @src 0:1059:1087  "if (outer > 100) outer = 100"
                        {
                            /// @src 0:1076:1087  "outer = 100"
                            var_outer := /** @src 0:1071:1074  "100" */ 0x64
                        }
                        /// @src 0:1097:1125  "if (inner > 100) inner = 100"
                        if /** @src 0:1101:1112  "inner > 100" */ gt(param_3, /** @src 0:1071:1074  "100" */ 0x64)
                        /// @src 0:1097:1125  "if (inner > 100) inner = 100"
                        {
                            /// @src 0:1114:1125  "inner = 100"
                            var_inner := /** @src 0:1071:1074  "100" */ 0x64
                        }
                        /// @src 0:1135:1152  "uint256 count = 0"
                        let var_count_1 := /** @src 0:158:2613  "contract ControlFlow {..." */ 0
                        /// @src 0:1167:1180  "uint256 i = 0"
                        let var_i_2 := /** @src 0:158:2613  "contract ControlFlow {..." */ 0
                        /// @src 0:1162:1298  "for (uint256 i = 0; i < outer; i++) {..."
                        for { }
                        /** @src 0:1182:1191  "i < outer" */ lt(var_i_2, var_outer)
                        /// @src 0:1167:1180  "uint256 i = 0"
                        {
                            /// @src 0:1193:1196  "i++"
                            var_i_2 := /** @src 0:158:2613  "contract ControlFlow {..." */ add(/** @src 0:1193:1196  "i++" */ var_i_2, /** @src 0:158:2613  "contract ControlFlow {..." */ 1)
                        }
                        /// @src 0:1193:1196  "i++"
                        {
                            /// @src 0:1217:1230  "uint256 j = 0"
                            let var_j := /** @src 0:158:2613  "contract ControlFlow {..." */ 0
                            /// @src 0:1212:1288  "for (uint256 j = 0; j < inner; j++) {..."
                            for { }
                            /** @src 0:1232:1241  "j < inner" */ lt(var_j, var_inner)
                            /// @src 0:1217:1230  "uint256 j = 0"
                            {
                                /// @src 0:1243:1246  "j++"
                                var_j := /** @src 0:158:2613  "contract ControlFlow {..." */ add(/** @src 0:1243:1246  "j++" */ var_j, /** @src 0:158:2613  "contract ControlFlow {..." */ 1)
                            }
                            /// @src 0:1243:1246  "j++"
                            {
                                /// @src 0:1266:1273  "count++"
                                var_count_1 := increment_uint256(var_count_1)
                            }
                        }
                        /// @src 0:158:2613  "contract ControlFlow {..."
                        let memPos_2 := mload(64)
                        mstore(memPos_2, var_count_1)
                        return(memPos_2, 32)
                    }
                    case 0x8a2592b1 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let var_n_2 := calldataload(4)
                        /// @src 0:297:321  "if (n > 10000) n = 10000"
                        if /** @src 0:301:310  "n > 10000" */ gt(var_n_2, /** @src 0:305:310  "10000" */ 0x2710)
                        /// @src 0:297:321  "if (n > 10000) n = 10000"
                        {
                            /// @src 0:312:321  "n = 10000"
                            var_n_2 := /** @src 0:305:310  "10000" */ 0x2710
                        }
                        /// @src 0:349:364  "uint256 sum = 0"
                        let var_sum := /** @src 0:158:2613  "contract ControlFlow {..." */ 0
                        /// @src 0:379:392  "uint256 i = 0"
                        let var_i_3 := /** @src 0:158:2613  "contract ControlFlow {..." */ 0
                        /// @src 0:374:439  "for (uint256 i = 0; i < n; i++) {..."
                        for { }
                        /** @src 0:394:399  "i < n" */ lt(var_i_3, var_n_2)
                        /// @src 0:379:392  "uint256 i = 0"
                        {
                            /// @src 0:401:404  "i++"
                            var_i_3 := /** @src 0:158:2613  "contract ControlFlow {..." */ add(/** @src 0:401:404  "i++" */ var_i_3, /** @src 0:158:2613  "contract ControlFlow {..." */ 1)
                        }
                        /// @src 0:401:404  "i++"
                        {
                            /// @src 0:158:2613  "contract ControlFlow {..."
                            let sum := add(var_sum, var_i_3)
                            if gt(var_sum, sum)
                            {
                                mstore(0, shl(224, 0x4e487b71))
                                mstore(4, 0x11)
                                revert(0, 0x24)
                            }
                            /// @src 0:420:428  "sum += i"
                            var_sum := sum
                        }
                        /// @src 0:158:2613  "contract ControlFlow {..."
                        let memPos_3 := mload(64)
                        mstore(memPos_3, var_sum)
                        return(memPos_3, 32)
                    }
                    case 0x950b9954 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let ret := fun_ifElse(calldataload(4))
                        let memPos_4 := mload(64)
                        mstore(memPos_4, ret)
                        return(memPos_4, 32)
                    }
                    case 0x9d25173f {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let var_n_3 := calldataload(4)
                        /// @src 0:543:567  "if (n > 10000) n = 10000"
                        if /** @src 0:547:556  "n > 10000" */ gt(var_n_3, /** @src 0:551:556  "10000" */ 0x2710)
                        /// @src 0:543:567  "if (n > 10000) n = 10000"
                        {
                            /// @src 0:558:567  "n = 10000"
                            var_n_3 := /** @src 0:551:556  "10000" */ 0x2710
                        }
                        /// @src 0:577:594  "uint256 count = 0"
                        let var_count_2 := /** @src 0:158:2613  "contract ControlFlow {..." */ 0
                        /// @src 0:609:622  "uint256 i = 0"
                        let var_i_4 := /** @src 0:158:2613  "contract ControlFlow {..." */ 0
                        /// @src 0:604:668  "for (uint256 i = 0; i < n; i++) {..."
                        for { }
                        /** @src 0:624:629  "i < n" */ lt(var_i_4, var_n_3)
                        /// @src 0:609:622  "uint256 i = 0"
                        {
                            /// @src 0:631:634  "i++"
                            var_i_4 := /** @src 0:158:2613  "contract ControlFlow {..." */ add(/** @src 0:631:634  "i++" */ var_i_4, /** @src 0:158:2613  "contract ControlFlow {..." */ 1)
                        }
                        /// @src 0:631:634  "i++"
                        {
                            /// @src 0:650:657  "count++"
                            var_count_2 := increment_uint256(var_count_2)
                        }
                        /// @src 0:158:2613  "contract ControlFlow {..."
                        let memPos_5 := mload(64)
                        mstore(memPos_5, var_count_2)
                        return(memPos_5, 32)
                    }
                    case 0xaa093375 {
                        if callvalue() { revert(0, 0) }
                        let param_4, param_5 := abi_decode_uint256t_uint256(calldatasize())
                        /// @src 0:1462:1475  "a > b ? a : b"
                        let expr := /** @src 0:158:2613  "contract ControlFlow {..." */ 0
                        /// @src 0:1462:1475  "a > b ? a : b"
                        switch /** @src 0:1462:1467  "a > b" */ gt(param_4, param_5)
                        case /** @src 0:1462:1475  "a > b ? a : b" */ 0 { expr := param_5 }
                        default { expr := param_4 }
                        /// @src 0:158:2613  "contract ControlFlow {..."
                        let memPos_6 := mload(64)
                        mstore(memPos_6, expr)
                        return(memPos_6, 32)
                    }
                    case 0xb055da2f {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let ret_1 := fun_earlyReturn(calldataload(4))
                        let memPos_7 := mload(64)
                        mstore(memPos_7, ret_1)
                        return(memPos_7, 32)
                    }
                    case 0xf602a6af {
                        if callvalue() { revert(0, 0) }
                        let param_6, param_7 := abi_decode_uint256t_uint256(calldatasize())
                        let var_n_4 := param_6
                        /// @src 0:2061:2083  "if (n > 1000) n = 1000"
                        if /** @src 0:2065:2073  "n > 1000" */ gt(param_6, /** @src 0:2069:2073  "1000" */ 0x03e8)
                        /// @src 0:2061:2083  "if (n > 1000) n = 1000"
                        {
                            /// @src 0:2075:2083  "n = 1000"
                            var_n_4 := /** @src 0:2069:2073  "1000" */ 0x03e8
                        }
                        /// @src 0:2093:2110  "uint256 count = 0"
                        let var_count_3 := /** @src 0:158:2613  "contract ControlFlow {..." */ 0
                        /// @src 0:2125:2138  "uint256 i = 0"
                        let var_i_5 := /** @src 0:158:2613  "contract ControlFlow {..." */ 0
                        /// @src 0:2120:2221  "for (uint256 i = 0; i < n; i++) {..."
                        for { }
                        /** @src 0:2140:2145  "i < n" */ lt(var_i_5, var_n_4)
                        /// @src 0:2125:2138  "uint256 i = 0"
                        {
                            /// @src 0:2147:2150  "i++"
                            var_i_5 := /** @src 0:158:2613  "contract ControlFlow {..." */ add(/** @src 0:2147:2150  "i++" */ var_i_5, /** @src 0:158:2613  "contract ControlFlow {..." */ 1)
                        }
                        /// @src 0:2147:2150  "i++"
                        {
                            /// @src 0:2166:2189  "if (i == breakAt) break"
                            if /** @src 0:2170:2182  "i == breakAt" */ eq(var_i_5, param_7)
                            /// @src 0:2166:2189  "if (i == breakAt) break"
                            {
                                /// @src 0:2184:2189  "break"
                                break
                            }
                            /// @src 0:2203:2210  "count++"
                            var_count_3 := increment_uint256(var_count_3)
                        }
                        /// @src 0:158:2613  "contract ControlFlow {..."
                        let memPos_8 := mload(64)
                        mstore(memPos_8, var_count_3)
                        return(memPos_8, 32)
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
            /// @ast-id 208 @src 0:1488:1699  "function ifElse(uint256 x) external pure returns (uint256) {..."
            function fun_ifElse(var_x) -> var
            {
                /// @src 0:1538:1545  "uint256"
                var := /** @src 0:158:2613  "contract ControlFlow {..." */ 0
                /// @src 0:1557:1693  "if (x < 10) {..."
                switch /** @src 0:1561:1567  "x < 10" */ lt(var_x, /** @src 0:1565:1567  "10" */ 0x0a)
                case /** @src 0:1557:1693  "if (x < 10) {..." */ 0 {
                    /// @src 0:1608:1693  "if (x < 100) {..."
                    switch /** @src 0:1612:1619  "x < 100" */ lt(var_x, /** @src 0:1616:1619  "100" */ 0x64)
                    case /** @src 0:1608:1693  "if (x < 100) {..." */ 0 {
                        /// @src 0:1674:1682  "return 3"
                        var := /** @src 0:1681:1682  "3" */ 0x03
                        /// @src 0:1674:1682  "return 3"
                        leave
                    }
                    default /// @src 0:1608:1693  "if (x < 100) {..."
                    {
                        /// @src 0:1635:1643  "return 2"
                        var := /** @src 0:1642:1643  "2" */ 0x02
                        /// @src 0:1635:1643  "return 2"
                        leave
                    }
                }
                default /// @src 0:1557:1693  "if (x < 10) {..."
                {
                    /// @src 0:1583:1591  "return 1"
                    var := /** @src 0:1590:1591  "1" */ 0x01
                    /// @src 0:1583:1591  "return 1"
                    leave
                }
            }
            /// @ast-id 232 @src 0:1747:1900  "function earlyReturn(uint256 x) external pure returns (uint256) {..."
            function fun_earlyReturn(var_x) -> var
            {
                /// @src 0:1802:1809  "uint256"
                var := /** @src 0:158:2613  "contract ControlFlow {..." */ 0
                /// @src 0:1821:1841  "if (x == 0) return 0"
                if /** @src 0:1825:1831  "x == 0" */ iszero(var_x)
                /// @src 0:1821:1841  "if (x == 0) return 0"
                {
                    /// @src 0:1833:1841  "return 0"
                    var := /** @src 0:158:2613  "contract ControlFlow {..." */ 0
                    /// @src 0:1833:1841  "return 0"
                    leave
                }
                /// @src 0:1851:1871  "if (x == 1) return 1"
                if /** @src 0:1855:1861  "x == 1" */ eq(var_x, /** @src 0:1860:1861  "1" */ 0x01)
                /// @src 0:1851:1871  "if (x == 1) return 1"
                {
                    /// @src 0:1863:1871  "return 1"
                    var := /** @src 0:1860:1861  "1" */ 0x01
                    /// @src 0:1863:1871  "return 1"
                    leave
                }
                /// @src 0:158:2613  "contract ControlFlow {..."
                let product := shl(/** @src 0:1860:1861  "1" */ 0x01, /** @src 0:158:2613  "contract ControlFlow {..." */ var_x)
                if iszero(eq(/** @src 0:1892:1893  "2" */ 0x02, /** @src 0:158:2613  "contract ControlFlow {..." */ div(product, var_x)))
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x11)
                    revert(0, 0x24)
                }
                /// @src 0:1881:1893  "return x * 2"
                var := product
            }
        }
        data ".metadata" hex"a2646970667358221220e33a295210b5023e82df2ee00536800bb5ff40b9c77014b933dbffbd6244f56864736f6c634300081c0033"
    }
}