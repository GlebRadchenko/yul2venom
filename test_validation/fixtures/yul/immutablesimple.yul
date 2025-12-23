
/// @use-src 0:"test_validation/fixtures/solidity/ImmutableSimple.sol"
object "ImmutableSimple_20" {
    code {
        /// @src 0:58:253  "contract ImmutableSimple {..."
        mstore(64, memoryguard(160))
        if callvalue() { revert_error_ca66f745a3ce8ff40e2ccaf1ad45db7774001b90d25810abd9040049be7bf4bb() }

        constructor_ImmutableSimple_20()

        let _1 := allocate_unbounded()
        codecopy(_1, dataoffset("ImmutableSimple_20_deployed"), datasize("ImmutableSimple_20_deployed"))

        setimmutable(_1, "3", mload(128))

        return(_1, datasize("ImmutableSimple_20_deployed"))

        function allocate_unbounded() -> memPtr {
            memPtr := mload(64)
        }

        function revert_error_ca66f745a3ce8ff40e2ccaf1ad45db7774001b90d25810abd9040049be7bf4bb() {
            revert(0, 0)
        }

        function cleanup_t_rational_7_by_1(value) -> cleaned {
            cleaned := value
        }

        function cleanup_t_uint256(value) -> cleaned {
            cleaned := value
        }

        function identity(value) -> ret {
            ret := value
        }

        function convert_t_rational_7_by_1_to_t_uint256(value) -> converted {
            converted := cleanup_t_uint256(identity(cleanup_t_rational_7_by_1(value)))
        }

        /// @ast-id 11
        /// @src 0:120:161  "constructor() {..."
        function constructor_ImmutableSimple_20() {

            /// @src 0:120:161  "constructor() {..."

            /// @src 0:153:154  "7"
            let expr_7 := 0x07
            /// @src 0:144:154  "stored = 7"
            let _2 := convert_t_rational_7_by_1_to_t_uint256(expr_7)
            let _3 := _2
            mstore(128, _3)
            let expr_8 := _2

        }
        /// @src 0:58:253  "contract ImmutableSimple {..."

    }
    /// @use-src 0:"test_validation/fixtures/solidity/ImmutableSimple.sol"
    object "ImmutableSimple_20_deployed" {
        code {
            /// @src 0:58:253  "contract ImmutableSimple {..."
            mstore(64, memoryguard(128))

            if iszero(lt(calldatasize(), 4))
            {
                let selector := shift_right_224_unsigned(calldataload(0))
                switch selector

                case 0x24ba3473
                {
                    // readStored()

                    external_fun_readStored_19()
                }

                default {}
            }

            revert_error_42b3090547df1d2001c96683413b8cf91c1b902ef5e3cb8d9f6f304cf7446f74()

            function shift_right_224_unsigned(value) -> newValue {
                newValue :=

                shr(224, value)

            }

            function allocate_unbounded() -> memPtr {
                memPtr := mload(64)
            }

            function revert_error_ca66f745a3ce8ff40e2ccaf1ad45db7774001b90d25810abd9040049be7bf4bb() {
                revert(0, 0)
            }

            function revert_error_dbdddcbe895c83990c08b3492a0e83918d802a52331272ac6fdb6a7c4aea3b1b() {
                revert(0, 0)
            }

            function abi_decode_tuple_(headStart, dataEnd)   {
                if slt(sub(dataEnd, headStart), 0) { revert_error_dbdddcbe895c83990c08b3492a0e83918d802a52331272ac6fdb6a7c4aea3b1b() }

            }

            function cleanup_t_uint256(value) -> cleaned {
                cleaned := value
            }

            function abi_encode_t_uint256_to_t_uint256_fromStack(value, pos) {
                mstore(pos, cleanup_t_uint256(value))
            }

            function abi_encode_tuple_t_uint256__to_t_uint256__fromStack(headStart , value0) -> tail {
                tail := add(headStart, 32)

                abi_encode_t_uint256_to_t_uint256_fromStack(value0,  add(headStart, 0))

            }

            function external_fun_readStored_19() {

                if callvalue() { revert_error_ca66f745a3ce8ff40e2ccaf1ad45db7774001b90d25810abd9040049be7bf4bb() }
                abi_decode_tuple_(4, calldatasize())
                let ret_0 :=  fun_readStored_19()
                let memPos := allocate_unbounded()
                let memEnd := abi_encode_tuple_t_uint256__to_t_uint256__fromStack(memPos , ret_0)
                return(memPos, sub(memEnd, memPos))

            }

            function revert_error_42b3090547df1d2001c96683413b8cf91c1b902ef5e3cb8d9f6f304cf7446f74() {
                revert(0, 0)
            }

            function zero_value_for_split_t_uint256() -> ret {
                ret := 0
            }

            /// @ast-id 19
            /// @src 0:167:251  "function readStored() external view returns (uint256) {..."
            function fun_readStored_19() -> var__14 {
                /// @src 0:212:219  "uint256"
                let zero_t_uint256_1 := zero_value_for_split_t_uint256()
                var__14 := zero_t_uint256_1

                /// @src 0:238:244  "stored"
                let _2 := loadimmutable("3")
                let expr_16 := _2
                /// @src 0:231:244  "return stored"
                var__14 := expr_16
                leave

            }
            /// @src 0:58:253  "contract ImmutableSimple {..."

        }

        data ".metadata" hex"a2646970667358221220279c7ff358ec2e779574d66a83084479eda3b688d820ac9cf4f39381cbff344b64736f6c634300081e0033"
    }

}

