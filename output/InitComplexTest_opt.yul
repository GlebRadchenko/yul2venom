object "InitComplexTest_91" {
    code {
        {
            /// @src 0:300:1169  "contract InitComplexTest {..."
            let _1 := memoryguard(0x80)
            if callvalue() { revert(0, 0) }
            let programSize := datasize("InitComplexTest_91")
            let argSize := sub(codesize(), programSize)
            let newFreePtr := add(_1, and(add(argSize, 31), not(31)))
            if or(gt(newFreePtr, sub(shl(64, 1), 1)), lt(newFreePtr, _1))
            {
                mstore(/** @src -1:-1:-1 */ 0, /** @src 0:300:1169  "contract InitComplexTest {..." */ shl(224, 0x4e487b71))
                mstore(4, 0x41)
                revert(/** @src -1:-1:-1 */ 0, /** @src 0:300:1169  "contract InitComplexTest {..." */ 0x24)
            }
            mstore(64, newFreePtr)
            codecopy(_1, programSize, argSize)
            if slt(sub(add(_1, argSize), _1), 64)
            {
                revert(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 0:300:1169  "contract InitComplexTest {..."
            let value := mload(_1)
            let _2 := and(value, sub(shl(160, 1), 1))
            if iszero(eq(value, _2))
            {
                revert(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 0:300:1169  "contract InitComplexTest {..."
            let value_1 := mload(add(_1, 32))
            if /** @src 0:556:576  "_owner != address(0)" */ iszero(/** @src 0:300:1169  "contract InitComplexTest {..." */ _2)
            {
                let memPtr := mload(64)
                mstore(memPtr, shl(229, 4594637))
                mstore(add(memPtr, 4), 32)
                mstore(add(memPtr, 36), 13)
                mstore(add(memPtr, 68), "Invalid owner")
                revert(memPtr, 100)
            }
            if /** @src 0:612:630  "_initialSupply > 0" */ iszero(value_1)
            /// @src 0:300:1169  "contract InitComplexTest {..."
            {
                let memPtr_1 := mload(64)
                mstore(memPtr_1, shl(229, 4594637))
                mstore(add(memPtr_1, 4), 32)
                mstore(add(memPtr_1, 36), 14)
                mstore(add(memPtr_1, 68), "Invalid supply")
                revert(memPtr_1, 100)
            }
            sstore(/** @src -1:-1:-1 */ 0, /** @src 0:300:1169  "contract InitComplexTest {..." */ or(and(sload(/** @src -1:-1:-1 */ 0), /** @src 0:300:1169  "contract InitComplexTest {..." */ not(sub(shl(160, 1), 1))), _2))
            sstore(1, value_1)
            let _3 := sload(/** @src 0:857:879  "ownerBalance += amount" */ 0x02)
            /// @src 0:300:1169  "contract InitComplexTest {..."
            let sum := add(_3, value_1)
            if gt(_3, sum)
            {
                mstore(/** @src -1:-1:-1 */ 0, /** @src 0:300:1169  "contract InitComplexTest {..." */ shl(224, 0x4e487b71))
                mstore(4, 0x11)
                revert(/** @src -1:-1:-1 */ 0, /** @src 0:300:1169  "contract InitComplexTest {..." */ 0x24)
            }
            sstore(/** @src 0:857:879  "ownerBalance += amount" */ 0x02, /** @src 0:300:1169  "contract InitComplexTest {..." */ sum)
            /// @src 0:759:794  "Initialized(_owner, _initialSupply)"
            let _4 := /** @src 0:300:1169  "contract InitComplexTest {..." */ mload(64)
            mstore(_4, value_1)
            /// @src 0:759:794  "Initialized(_owner, _initialSupply)"
            log2(_4, /** @src 0:300:1169  "contract InitComplexTest {..." */ 32, /** @src 0:759:794  "Initialized(_owner, _initialSupply)" */ 0x25ff68dd81b34665b5ba7e553ee5511bf6812e12adb4a7e2c0d9e26b3099ce79, _2)
            /// @src 0:300:1169  "contract InitComplexTest {..."
            let _5 := mload(64)
            let _6 := datasize("InitComplexTest_91_deployed")
            codecopy(_5, dataoffset("InitComplexTest_91_deployed"), _6)
            return(_5, _6)
        }
    }
    /// @use-src 0:"foundry/src/init/InitComplexTest.sol"
    object "InitComplexTest_91_deployed" {
        code {
            {
                /// @src 0:300:1169  "contract InitComplexTest {..."
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x18160ddd {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        mstore(_1, sload(/** @src 0:357:383  "uint256 public totalSupply" */ 1))
                        /// @src 0:300:1169  "contract InitComplexTest {..."
                        return(_1, 32)
                    }
                    case 0x722713f7 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _2 := sload(/** @src 0:962:974  "ownerBalance" */ 0x02)
                        /// @src 0:300:1169  "contract InitComplexTest {..."
                        let memPos := mload(64)
                        mstore(memPos, _2)
                        return(memPos, 32)
                    }
                    case 0x893d20e8 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let value := and(sload(0), sub(shl(160, 1), 1))
                        let memPos_1 := mload(64)
                        mstore(memPos_1, value)
                        return(memPos_1, 32)
                    }
                    case 0x8da5cb5b {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let value_1 := and(sload(0), sub(shl(160, 1), 1))
                        let memPos_2 := mload(64)
                        mstore(memPos_2, value_1)
                        return(memPos_2, 32)
                    }
                    case 0xbedcf003 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _3 := sload(/** @src 0:389:416  "uint256 public ownerBalance" */ 2)
                        /// @src 0:300:1169  "contract InitComplexTest {..."
                        let memPos_3 := mload(64)
                        mstore(memPos_3, _3)
                        return(memPos_3, 32)
                    }
                    case 0xc4e41b22 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), not(3)), 0) { revert(0, 0) }
                        let _4 := sload(/** @src 0:1149:1160  "totalSupply" */ 0x01)
                        /// @src 0:300:1169  "contract InitComplexTest {..."
                        let memPos_4 := mload(64)
                        mstore(memPos_4, _4)
                        return(memPos_4, 32)
                    }
                }
                revert(0, 0)
            }
        }
        data ".metadata" hex"a26469706673582212202c68de5d6a6e3ada02a6f443026adccfe300da943e5d29da68f9013a36494cd764736f6c634300081c0033"
    }
}