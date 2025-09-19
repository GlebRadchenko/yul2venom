object "SimpleStorage_224" {
    code {
        /// @src 0:957:1979  "contract SimpleStorage {..."
        mstore(64, memoryguard(128))
        if callvalue() { revert_error_ca66f745a3ce8ff40e2ccaf1ad45db7774001b90d25810abd9040049be7bf4bb() }

        constructor_SimpleStorage_224()

        let _1 := allocate_unbounded()
        codecopy(_1, dataoffset("SimpleStorage_224_deployed"), datasize("SimpleStorage_224_deployed"))

        return(_1, datasize("SimpleStorage_224_deployed"))

        function allocate_unbounded() -> memPtr {
            memPtr := mload(64)
        }

        function revert_error_ca66f745a3ce8ff40e2ccaf1ad45db7774001b90d25810abd9040049be7bf4bb() {
            revert(0, 0)
        }

        function shift_left_0(value) -> newValue {
            newValue :=

            shl(0, value)

        }

        function update_byte_slice_20_shift_0(value, toInsert) -> result {
            let mask := 0xffffffffffffffffffffffffffffffffffffffff
            toInsert := shift_left_0(toInsert)
            value := and(value, not(mask))
            result := or(value, and(toInsert, mask))
        }

        function cleanup_t_uint160(value) -> cleaned {
            cleaned := and(value, 0xffffffffffffffffffffffffffffffffffffffff)
        }

        function identity(value) -> ret {
            ret := value
        }

        function convert_t_uint160_to_t_uint160(value) -> converted {
            converted := cleanup_t_uint160(identity(cleanup_t_uint160(value)))
        }

        function convert_t_uint160_to_t_address(value) -> converted {
            converted := convert_t_uint160_to_t_uint160(value)
        }

        function convert_t_address_to_t_address(value) -> converted {
            converted := convert_t_uint160_to_t_address(value)
        }

        function prepare_store_t_address(value) -> ret {
            ret := value
        }

        function update_storage_value_offset_0_t_address_to_t_address(slot, value_0) {
            let convertedValue_0 := convert_t_address_to_t_address(value_0)
            sstore(slot, update_byte_slice_20_shift_0(sload(slot), prepare_store_t_address(convertedValue_0)))
        }

        /// @ast-id 133
        /// @src 0:1212:1261  "constructor() {..."
        function constructor_SimpleStorage_224() {

            /// @src 0:1212:1261  "constructor() {..."

            /// @src 0:1244:1254  "msg.sender"
            let expr_129 := caller()
            /// @src 0:1236:1254  "owner = msg.sender"
            update_storage_value_offset_0_t_address_to_t_address(0x02, expr_129)
            let expr_130 := expr_129

        }
        /// @src 0:957:1979  "contract SimpleStorage {..."

    }
    /// @use-src 0:"test_validation/fixtures/solidity/MainnetComponents.sol"
    object "SimpleStorage_224_deployed" {
        code {
            /// @src 0:957:1979  "contract SimpleStorage {..."
            mstore(64, memoryguard(128))

            if iszero(lt(calldatasize(), 4))
            {
                let selector := shift_right_224_unsigned(calldataload(0))
                switch selector

                case 0x2e1a7d4d
                {
                    // withdraw(uint256)

                    external_fun_withdraw_211()
                }

                case 0x2e64cec1
                {
                    // retrieve()

                    external_fun_retrieve_167()
                }

                case 0x6057361d
                {
                    // store(uint256)

                    external_fun_store_159()
                }

                case 0x8da5cb5b
                {
                    // owner()

                    external_fun_owner_112()
                }

                case 0xd0e30db0
                {
                    // deposit()

                    external_fun_deposit_179()
                }

                case 0xf8b2cb4f
                {
                    // getBalance(address)

                    external_fun_getBalance_223()
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
