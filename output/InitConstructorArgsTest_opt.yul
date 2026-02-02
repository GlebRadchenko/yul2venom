object "InitConstructorArgsTest_55" {
    code {
        {
            /// @src 0:229:745  "contract InitConstructorArgsTest {..."
            let _1 := memoryguard(0x80)
            if callvalue() { revert(0, 0) }
            let programSize := datasize("InitConstructorArgsTest_55")
            let argSize := sub(codesize(), programSize)
            let newFreePtr := add(_1, and(add(argSize, 31), not(31)))
            if or(gt(newFreePtr, sub(shl(64, 1), 1)), lt(newFreePtr, _1))
            {
                mstore(/** @src -1:-1:-1 */ 0, /** @src 0:229:745  "contract InitConstructorArgsTest {..." */ shl(224, 0x4e487b71))
                mstore(4, 0x41)
                revert(/** @src -1:-1:-1 */ 0, /** @src 0:229:745  "contract InitConstructorArgsTest {..." */ 0x24)
            }
            mstore(64, newFreePtr)
            codecopy(_1, programSize, argSize)
            if slt(sub(add(_1, argSize), _1), 96)
            {
                revert(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 0:229:745  "contract InitConstructorArgsTest {..."
            let value := mload(_1)
            let value_1 := mload(add(_1, 32))
            let _2 := and(value_1, sub(shl(160, 1), 1))
            if iszero(eq(value_1, _2))
            {
                revert(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 0:229:745  "contract InitConstructorArgsTest {..."
            let value_2 := mload(add(_1, 64))
            let _3 := iszero(iszero(value_2))
            if iszero(eq(value_2, _3))
            {
                revert(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 0:229:745  "contract InitConstructorArgsTest {..."
            sstore(/** @src -1:-1:-1 */ 0, /** @src 0:229:745  "contract InitConstructorArgsTest {..." */ value)
            let _4 := sload(1)
            sstore(1, or(or(and(_4, not(sub(shl(168, 1), 1))), _2), and(shl(160, _3), shl(160, 255))))
            let _5 := mload(64)
            let _6 := datasize("InitConstructorArgsTest_55_deployed")
            codecopy(_5, dataoffset("InitConstructorArgsTest_55_deployed"), _6)
            return(_5, _6)
        }
    }
    /// @use-src 0:"foundry/src/init/InitConstructorArgsTest.sol"
    object "InitConstructorArgsTest_55_deployed" {
        code {
            {
                /// @src 0:229:745  "contract InitConstructorArgsTest {..."
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x02fb0c5e {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        mstore(_1, iszero(iszero(and(shr(160, sload(/** @src 0:320:338  "bool public active" */ 1)), /** @src 0:229:745  "contract InitConstructorArgsTest {..." */ 0xff))))
                        return(_1, 32)
                    }
                    case 0x20965255 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _2 := sload(0)
                        let memPos := mload(64)
                        mstore(memPos, _2)
                        return(memPos, 32)
                    }
                    case 0x22f3e2d4 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let value := and(shr(160, sload(/** @src 0:730:736  "active" */ 0x01)), /** @src 0:229:745  "contract InitConstructorArgsTest {..." */ 0xff)
                        let memPos_1 := mload(64)
                        mstore(memPos_1, iszero(iszero(value)))
                        return(memPos_1, 32)
                    }
                    case 0x3fa4f245 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _3 := sload(0)
                        let memPos_2 := mload(64)
                        mstore(memPos_2, _3)
                        return(memPos_2, 32)
                    }
                    case 0x893d20e8 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let value_1 := and(sload(/** @src 0:646:651  "owner" */ 0x01), /** @src 0:229:745  "contract InitConstructorArgsTest {..." */ sub(shl(160, 1), 1))
                        let memPos_3 := mload(64)
                        mstore(memPos_3, value_1)
                        return(memPos_3, 32)
                    }
                    case 0x8da5cb5b {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let value_2 := and(sload(/** @src 0:294:314  "address public owner" */ 1), /** @src 0:229:745  "contract InitConstructorArgsTest {..." */ sub(shl(160, 1), 1))
                        let memPos_4 := mload(64)
                        mstore(memPos_4, value_2)
                        return(memPos_4, 32)
                    }
                }
                revert(0, 0)
            }
        }
        data ".metadata" hex"a26469706673582212205dfbd72deb87fa29a29c5d3ae24329427d46d12c7961c8971b24777de322315164736f6c634300081c0033"
    }
}