object "MathLib_81" {
    code {
        {
            /// @src 0:201:948  "library MathLib {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("MathLib_81_deployed")
            codecopy(_1, dataoffset("MathLib_81_deployed"), _2)
            setimmutable(_1, "library_deploy_address", address())
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/bench/ExternalLibrary.sol"
    object "MathLib_81_deployed" {
        code {
            {
                /// @src 0:201:948  "library MathLib {..."
                mstore(64, memoryguard(0x80))
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x2e4c697f {
                        let param, param_1 := abi_decode_uint256t_uint256(calldatasize())
                        /// @src 0:644:662  "uint256 result = 1"
                        let var_result := /** @src 0:661:662  "1" */ 0x01
                        /// @src 0:677:690  "uint256 i = 0"
                        let var_i := /** @src 0:201:948  "library MathLib {..." */ 0
                        /// @src 0:672:745  "for (uint256 i = 0; i < exp; i++) {..."
                        for { }
                        /** @src 0:692:699  "i < exp" */ lt(var_i, param_1)
                        /// @src 0:677:690  "uint256 i = 0"
                        {
                            /// @src 0:701:704  "i++"
                            var_i := /** @src 0:201:948  "library MathLib {..." */ add(/** @src 0:701:704  "i++" */ var_i, /** @src 0:661:662  "1" */ 0x01)
                        }
                        /// @src 0:701:704  "i++"
                        {
                            /// @src 0:720:734  "result *= base"
                            var_result := checked_mul_uint256(var_result, param)
                        }
                        /// @src 0:201:948  "library MathLib {..."
                        let memPos := mload(64)
                        mstore(memPos, var_result)
                        return(memPos, 32)
                    }
                    case 0x771602f7 {
                        let param_2, param_3 := abi_decode_uint256t_uint256(calldatasize())
                        let sum := add(param_2, param_3)
                        if gt(param_2, sum)
                        {
                            mstore(0, shl(224, 0x4e487b71))
                            mstore(4, 0x11)
                            revert(0, 0x24)
                        }
                        let memPos_1 := mload(64)
                        mstore(memPos_1, sum)
                        return(memPos_1, 32)
                    }
                    case 0xc8a4ac9c {
                        let param_4, param_5 := abi_decode_uint256t_uint256(calldatasize())
                        let ret := /** @src 0:512:517  "a * b" */ checked_mul_uint256(/** @src 0:201:948  "library MathLib {..." */ param_4, param_5)
                        let memPos_2 := mload(64)
                        mstore(memPos_2, ret)
                        return(memPos_2, 32)
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
            function checked_mul_uint256(x, y) -> product
            {
                product := mul(x, y)
                if iszero(or(iszero(x), eq(y, div(product, x))))
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x11)
                    revert(0, 0x24)
                }
            }
        }
        data ".metadata" hex"a264697066735822122035bc0018beaa74fa319dc2c55adf38d7c3442e05c7e2d0a3e8da446bbae383a264736f6c634300081c0033"
    }
}