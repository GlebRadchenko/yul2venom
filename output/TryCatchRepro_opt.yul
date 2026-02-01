object "TryCatchRepro_36" {
    code {
        {
            /// @src 0:58:364  "contract TryCatchRepro {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("TryCatchRepro_36_deployed")
            codecopy(_1, dataoffset("TryCatchRepro_36_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"foundry/src/TryCatchRepro.sol"
    object "TryCatchRepro_36_deployed" {
        code {
            {
                /// @src 0:58:364  "contract TryCatchRepro {..."
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x36c28556 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        if iszero(/** @src 0:150:156  "x < 10" */ lt(/** @src 0:58:364  "contract TryCatchRepro {..." */ calldataload(4), /** @src 0:154:156  "10" */ 0x0a))
                        /// @src 0:58:364  "contract TryCatchRepro {..."
                        {
                            mstore(_1, shl(229, 4594637))
                            mstore(add(_1, 4), 32)
                            mstore(add(_1, 36), 7)
                            mstore(add(_1, 68), "Too big")
                            revert(_1, 100)
                        }
                        return(0, 0)
                    }
                    case 0xdb59397b {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let ret := fun_tryCatchTest(calldataload(4))
                        let memPos := mload(64)
                        mstore(memPos, iszero(iszero(ret)))
                        return(memPos, 32)
                    }
                }
                revert(0, 0)
            }
            /// @ast-id 35 @src 0:181:362  "function tryCatchTest(uint256 x) public view returns (bool) {..."
            function fun_tryCatchTest(var_x) -> var
            {
                /// @src 0:235:239  "bool"
                let var_1 := /** @src 0:58:364  "contract TryCatchRepro {..." */ 0
                /// @src 0:235:239  "bool"
                var := /** @src 0:58:364  "contract TryCatchRepro {..." */ 0
                /// @src 0:255:275  "this.externalFail(x)"
                if iszero(extcodesize(/** @src 0:255:259  "this" */ address()))
                /// @src 0:255:275  "this.externalFail(x)"
                {
                    /// @src 0:58:364  "contract TryCatchRepro {..."
                    revert(0, 0)
                }
                /// @src 0:255:275  "this.externalFail(x)"
                let _1 := /** @src 0:58:364  "contract TryCatchRepro {..." */ mload(64)
                /// @src 0:255:275  "this.externalFail(x)"
                mstore(_1, /** @src 0:58:364  "contract TryCatchRepro {..." */ shl(225, 0x1b6142ab))
                mstore(/** @src 0:255:275  "this.externalFail(x)" */ add(_1, 4), /** @src 0:58:364  "contract TryCatchRepro {..." */ var_x)
                /// @src 0:255:275  "this.externalFail(x)"
                let trySuccessCondition := staticcall(gas(), /** @src 0:255:259  "this" */ address(), /** @src 0:255:275  "this.externalFail(x)" */ _1, 36, _1, /** @src 0:58:364  "contract TryCatchRepro {..." */ 0)
                /// @src 0:255:275  "this.externalFail(x)"
                if trySuccessCondition
                {
                    /// @src 0:58:364  "contract TryCatchRepro {..."
                    if gt(_1, 0xffffffffffffffff)
                    {
                        mstore(0, shl(224, 0x4e487b71))
                        mstore(/** @src 0:255:275  "this.externalFail(x)" */ 4, /** @src 0:58:364  "contract TryCatchRepro {..." */ 0x41)
                        revert(0, /** @src 0:255:275  "this.externalFail(x)" */ 36)
                    }
                    /// @src 0:58:364  "contract TryCatchRepro {..."
                    mstore(64, _1)
                    var_1 := 0
                }
                /// @src 0:251:356  "try this.externalFail(x) {..."
                switch iszero(trySuccessCondition)
                case 0 {
                    /// @src 0:290:301  "return true"
                    var := /** @src 0:297:301  "true" */ 0x01
                    /// @src 0:290:301  "return true"
                    leave
                }
                default /// @src 0:251:356  "try this.externalFail(x) {..."
                {
                    /// @src 0:333:345  "return false"
                    var := /** @src 0:58:364  "contract TryCatchRepro {..." */ var_1
                    /// @src 0:333:345  "return false"
                    leave
                }
            }
        }
        data ".metadata" hex"a2646970667358221220255eed0b11f5012f3f021aa47314ed68ce79e0aaa6a1655becbe9e4a014d500064736f6c634300081c0033"
    }
}