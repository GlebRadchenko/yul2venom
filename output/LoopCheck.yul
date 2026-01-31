object "LoopCheck_67" {
    code {
        {
            /// @src 0:58:735  "contract LoopCheck {..."
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := datasize("LoopCheck_67_deployed")
            codecopy(_1, dataoffset("LoopCheck_67_deployed"), _2)
            return(_1, _2)
        }
    }
    /// @use-src 0:"contracts/LoopCheck.sol"
    object "LoopCheck_67_deployed" {
        code {
            {
                /// @src 0:58:735  "contract LoopCheck {..."
                mstore(64, 128)
                if iszero(lt(calldatasize(), 4))
                {
                    if eq(0x9759c210, shr(224, calldataload(0)))
                    {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 32) { revert(0, 0) }
                        let offset := calldataload(4)
                        if gt(offset, 0xffffffffffffffff) { revert(0, 0) }
                        if iszero(slt(add(offset, 35), calldatasize())) { revert(0, 0) }
                        let length := calldataload(add(4, offset))
                        if gt(length, 0xffffffffffffffff) { panic_error_0x41() }
                        let dst := allocate_memory(add(shl(5, length), 32))
                        let array := dst
                        mstore(dst, length)
                        dst := add(dst, 32)
                        let srcEnd := add(add(offset, shl(6, length)), 36)
                        if gt(srcEnd, calldatasize()) { revert(0, 0) }
                        let src := add(offset, 36)
                        for { } lt(src, srcEnd) { src := add(src, 64) }
                        {
                            if slt(sub(calldatasize(), src), 64) { revert(0, 0) }
                            let value := allocate_memory_1129()
                            let value_1 := 0
                            value_1 := calldataload(src)
                            mstore(value, value_1)
                            let value_2 := 0
                            value_2 := calldataload(add(src, 32))
                            mstore(add(value, 32), value_2)
                            mstore(dst, value)
                            dst := add(dst, 32)
                        }
                        let ret := fun_process(array)
                        let memPos := mload(64)
                        return(memPos, sub(abi_encode_array_struct_Element_dyn(memPos, ret), memPos))
                    }
                }
                revert(0, 0)
            }
            function panic_error_0x41()
            {
                mstore(0, shl(224, 0x4e487b71))
                mstore(4, 0x41)
                revert(0, 0x24)
            }
            function allocate_memory_1129() -> memPtr
            {
                memPtr := mload(64)
                let newFreePtr := add(memPtr, 64)
                if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr)) { panic_error_0x41() }
                mstore(64, newFreePtr)
            }
            function allocate_memory(size) -> memPtr
            {
                memPtr := mload(64)
                let newFreePtr := add(memPtr, and(add(size, 31), not(31)))
                if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr)) { panic_error_0x41() }
                mstore(64, newFreePtr)
            }
            function abi_encode_array_struct_Element_dyn(headStart, value0) -> tail
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
                    let _1 := mload(srcPtr)
                    mstore(pos, mload(_1))
                    mstore(add(pos, 32), mload(add(_1, 32)))
                    pos := add(pos, 64)
                    srcPtr := add(srcPtr, 32)
                }
                tail := pos
            }
            function memory_array_index_access_struct_Element_dyn(baseRef, index) -> addr
            {
                if iszero(lt(index, mload(baseRef)))
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x32)
                    revert(0, 0x24)
                }
                addr := add(add(baseRef, shl(5, index)), 32)
            }
            /// @ast-id 66 @src 0:220:733  "function process(..."
            function fun_process(var_elements_mpos) -> var_mpos
            {
                /// @src 0:409:472  "assembly {..."
                log3(0, 0, 0xDDDDDDDD, /** @src 0:58:735  "contract LoopCheck {..." */ mload(/** @src 0:384:399  "elements.length" */ var_elements_mpos), /** @src 0:409:472  "assembly {..." */ 0)
                /// @src 0:486:499  "uint256 i = 0"
                let var_i := /** @src 0:409:472  "assembly {..." */ 0
                /// @src 0:481:702  "for (uint256 i = 0; i < elements.length; i++) {..."
                for { }
                /** @src 0:690:691  "1" */ 0x01
                /// @src 0:486:499  "uint256 i = 0"
                {
                    /// @src 0:522:525  "i++"
                    var_i := /** @src 0:58:735  "contract LoopCheck {..." */ add(/** @src 0:522:525  "i++" */ var_i, /** @src 0:690:691  "1" */ 0x01)
                }
                /// @src 0:522:525  "i++"
                {
                    /// @src 0:501:520  "i < elements.length"
                    if iszero(lt(var_i, /** @src 0:58:735  "contract LoopCheck {..." */ mload(/** @src 0:505:520  "elements.length" */ var_elements_mpos)))
                    /// @src 0:501:520  "i < elements.length"
                    { break }
                    /// @src 0:58:735  "contract LoopCheck {..."
                    let _1 := mload(/** @src 0:561:572  "elements[i]" */ mload(memory_array_index_access_struct_Element_dyn(var_elements_mpos, var_i)))
                    /// @src 0:58:735  "contract LoopCheck {..."
                    let _2 := mload(/** @src 0:577:594  "elements[i].value" */ add(/** @src 0:577:588  "elements[i]" */ mload(memory_array_index_access_struct_Element_dyn(var_elements_mpos, var_i)), /** @src 0:577:594  "elements[i].value" */ 32))
                    /// @src 0:546:595  "log_element(i, elements[i].id, elements[i].value)"
                    let _3 := /** @src 0:58:735  "contract LoopCheck {..." */ mload(64)
                    mstore(_3, var_i)
                    mstore(add(_3, /** @src 0:577:594  "elements[i].value" */ 32), /** @src 0:58:735  "contract LoopCheck {..." */ _1)
                    mstore(add(_3, 64), _2)
                    /// @src 0:546:595  "log_element(i, elements[i].id, elements[i].value)"
                    log1(_3, /** @src 0:58:735  "contract LoopCheck {..." */ 96, /** @src 0:546:595  "log_element(i, elements[i].id, elements[i].value)" */ 0x69348690a07fbe97aaa549760ac0199cafdd19759a893cbe59a2f07f6fef5bbc)
                    /// @src 0:669:686  "elements[i].value"
                    let _4 := add(/** @src 0:669:680  "elements[i]" */ mload(memory_array_index_access_struct_Element_dyn(var_elements_mpos, var_i)), /** @src 0:577:594  "elements[i].value" */ 32)
                    /// @src 0:58:735  "contract LoopCheck {..."
                    let _5 := mload(/** @src 0:669:691  "elements[i].value += 1" */ _4)
                    /// @src 0:58:735  "contract LoopCheck {..."
                    let sum := add(_5, /** @src 0:690:691  "1" */ 0x01)
                    /// @src 0:58:735  "contract LoopCheck {..."
                    if gt(_5, sum)
                    {
                        mstore(/** @src 0:409:472  "assembly {..." */ 0, /** @src 0:58:735  "contract LoopCheck {..." */ shl(224, 0x4e487b71))
                        mstore(4, 0x11)
                        revert(/** @src 0:409:472  "assembly {..." */ 0, /** @src 0:58:735  "contract LoopCheck {..." */ 0x24)
                    }
                    mstore(_4, sum)
                }
                /// @src 0:711:726  "return elements"
                var_mpos := var_elements_mpos
            }
        }
        data ".metadata" hex"a264697066735822122047e6f249bde8160005d293cf8435bbd14c70ae263644acfb7fd070c3fb31f7d664736f6c634300081c0033"
    }
}