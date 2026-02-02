/// @use-src 0:"src/init/InitMultiImmutableTest.sol"
object "InitMultiImmutableTest_161" {
    code {
        {
            /// @src 0:176:1918  "contract InitMultiImmutableTest {..."
            let _1 := memoryguard(0x01a0)
            if callvalue() { revert(0, 0) }
            let programSize := datasize("InitMultiImmutableTest_161")
            let argSize := sub(codesize(), programSize)
            let newFreePtr := add(_1, and(add(argSize, 31), not(31)))
            if or(gt(newFreePtr, sub(shl(64, 1), 1)), lt(newFreePtr, _1))
            {
                mstore(/** @src -1:-1:-1 */ 0, /** @src 0:176:1918  "contract InitMultiImmutableTest {..." */ shl(224, 0x4e487b71))
                mstore(4, 0x41)
                revert(/** @src -1:-1:-1 */ 0, /** @src 0:176:1918  "contract InitMultiImmutableTest {..." */ 0x24)
            }
            mstore(64, newFreePtr)
            codecopy(_1, programSize, argSize)
            if slt(sub(add(_1, argSize), _1), 288)
            {
                revert(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 0:176:1918  "contract InitMultiImmutableTest {..."
            let value0 := abi_decode_address_fromMemory(_1)
            let value1 := abi_decode_address_fromMemory(add(_1, 32))
            let value2 := abi_decode_address_fromMemory(add(_1, 64))
            let value := mload(add(_1, 96))
            let value_1 := mload(add(_1, 128))
            let value_2 := mload(add(_1, 160))
            if iszero(eq(value_2, and(value_2, sub(shl(128, 1), 1))))
            {
                revert(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 0:176:1918  "contract InitMultiImmutableTest {..."
            let value6 := abi_decode_bool_fromMemory(add(_1, 192))
            let value7 := abi_decode_bool_fromMemory(add(_1, 224))
            let value_3 := mload(add(_1, 256))
            /// @src 0:870:884  "addr1 = _addr1"
            mstore(/** @src 0:176:1918  "contract InitMultiImmutableTest {..." */ 128, /** @src 0:870:884  "addr1 = _addr1" */ value0)
            /// @src 0:894:908  "addr2 = _addr2"
            mstore(/** @src 0:176:1918  "contract InitMultiImmutableTest {..." */ 160, /** @src 0:894:908  "addr2 = _addr2" */ value1)
            /// @src 0:918:932  "addr3 = _addr3"
            mstore(/** @src 0:176:1918  "contract InitMultiImmutableTest {..." */ 192, /** @src 0:918:932  "addr3 = _addr3" */ value2)
            /// @src 0:942:956  "uint1 = _uint1"
            mstore(/** @src 0:176:1918  "contract InitMultiImmutableTest {..." */ 224, /** @src 0:942:956  "uint1 = _uint1" */ value)
            /// @src 0:966:980  "uint2 = _uint2"
            mstore(/** @src 0:176:1918  "contract InitMultiImmutableTest {..." */ 256, /** @src 0:966:980  "uint2 = _uint2" */ value_1)
            /// @src 0:990:1014  "uint128val = _uint128val"
            mstore(/** @src 0:176:1918  "contract InitMultiImmutableTest {..." */ 288, /** @src 0:990:1014  "uint128val = _uint128val" */ value_2)
            /// @src 0:1024:1038  "flag1 = _flag1"
            mstore(320, value6)
            /// @src 0:1048:1062  "flag2 = _flag2"
            mstore(352, value7)
            /// @src 0:1072:1084  "hash = _hash"
            mstore(384, value_3)
            /// @src 0:176:1918  "contract InitMultiImmutableTest {..."
            sstore(/** @src -1:-1:-1 */ 0, /** @src 0:176:1918  "contract InitMultiImmutableTest {..." */ 1)
            let _2 := mload(64)
            let _3 := datasize("InitMultiImmutableTest_161_deployed")
            codecopy(_2, dataoffset("InitMultiImmutableTest_161_deployed"), _3)
            setimmutable(_2, "4", mload(128))
            setimmutable(_2, "6", mload(160))
            setimmutable(_2, "8", mload(192))
            setimmutable(_2, "10", mload(224))
            setimmutable(_2, "12", mload(256))
            setimmutable(_2, "14", mload(288))
            setimmutable(_2, "16", mload(/** @src 0:1024:1038  "flag1 = _flag1" */ 320))
            /// @src 0:176:1918  "contract InitMultiImmutableTest {..."
            setimmutable(_2, "18", mload(/** @src 0:1048:1062  "flag2 = _flag2" */ 352))
            /// @src 0:176:1918  "contract InitMultiImmutableTest {..."
            setimmutable(_2, "20", mload(/** @src 0:1072:1084  "hash = _hash" */ 384))
            /// @src 0:176:1918  "contract InitMultiImmutableTest {..."
            return(_2, _3)
        }
        function abi_decode_address_fromMemory(offset) -> value
        {
            value := mload(offset)
            if iszero(eq(value, and(value, sub(shl(160, 1), 1)))) { revert(0, 0) }
        }
        function abi_decode_bool_fromMemory(offset) -> value
        {
            value := mload(offset)
            if iszero(eq(value, iszero(iszero(value)))) { revert(0, 0) }
        }
    }
    /// @use-src 0:"src/init/InitMultiImmutableTest.sol"
    object "InitMultiImmutableTest_161_deployed" {
        code {
            {
                /// @src 0:176:1918  "contract InitMultiImmutableTest {..."
                mstore(64, memoryguard(0x80))
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x09bd5a60 { external_fun_hash() }
                    case 0x2b1254f5 { external_fun_getUint1() }
                    case 0x3004511f {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                        let memPos := mload(64)
                        mstore(memPos, iszero(iszero(/** @src 0:505:532  "bool public immutable flag2" */ loadimmutable("18"))))
                        /// @src 0:176:1918  "contract InitMultiImmutableTest {..."
                        return(memPos, 32)
                    }
                    case 0x3895857a { external_fun_getAddr3() }
                    case 0x446fd9f0 { external_fun_getUint128() }
                    case 0x49ed7394 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                        let memPos_1 := mload(64)
                        mstore(memPos_1, iszero(iszero(/** @src 0:472:499  "bool public immutable flag1" */ loadimmutable("16"))))
                        /// @src 0:176:1918  "contract InitMultiImmutableTest {..."
                        return(memPos_1, 32)
                    }
                    case 0x5e6feab4 { external_fun_getUint1() }
                    case 0x61bc221a {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                        let _1 := sload(0)
                        let memPos_2 := mload(64)
                        mstore(memPos_2, _1)
                        return(memPos_2, 32)
                    }
                    case 0x6cc7149d {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                        let memPos_3 := mload(64)
                        mstore(memPos_3, iszero(iszero(/** @src 0:1720:1725  "flag1" */ loadimmutable("16"))))
                        /// @src 0:176:1918  "contract InitMultiImmutableTest {..."
                        mstore(add(memPos_3, 32), iszero(iszero(/** @src 0:1727:1732  "flag2" */ loadimmutable("18"))))
                        /// @src 0:176:1918  "contract InitMultiImmutableTest {..."
                        return(memPos_3, 64)
                    }
                    case 0x76392f75 { external_fun_getAddr2() }
                    case 0x8ada066e {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                        let _2 := sload(0)
                        let memPos_4 := mload(64)
                        mstore(memPos_4, _2)
                        return(memPos_4, 32)
                    }
                    case 0x8de38f98 { external_fun_getAddr2() }
                    case 0x9347e6d7 { external_fun_getAddr3() }
                    case 0x94d78e6c { external_fun_getUint2() }
                    case 0xafd9ee11 { external_fun_getUint2() }
                    case 0xd13319c4 { external_fun_hash() }
                    case 0xdb4d39a5 { external_fun_getAddr1() }
                    case 0xeabe09ad { external_fun_getAddr1() }
                    case 0xf8d57b9c { external_fun_getUint128() }
                }
                revert(0, 0)
            }
            function external_fun_hash()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                let memPos := mload(64)
                mstore(memPos, /** @src 0:538:567  "bytes32 public immutable hash" */ loadimmutable("20"))
                /// @src 0:176:1918  "contract InitMultiImmutableTest {..."
                return(memPos, 32)
            }
            function external_fun_getUint1()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                let memPos := mload(64)
                mstore(memPos, /** @src 0:1448:1453  "uint1" */ loadimmutable("10"))
                /// @src 0:176:1918  "contract InitMultiImmutableTest {..."
                return(memPos, 32)
            }
            function external_fun_getAddr3()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                let memPos := mload(64)
                mstore(memPos, and(/** @src 0:1361:1366  "addr3" */ loadimmutable("8"), /** @src 0:176:1918  "contract InitMultiImmutableTest {..." */ 0xffffffffffffffffffffffffffffffffffffffff))
                return(memPos, 32)
            }
            function external_fun_getUint128()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                let memPos := mload(64)
                mstore(memPos, and(/** @src 0:1624:1634  "uint128val" */ loadimmutable("14"), /** @src 0:176:1918  "contract InitMultiImmutableTest {..." */ 0xffffffffffffffffffffffffffffffff))
                return(memPos, 32)
            }
            function external_fun_getAddr2()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                let memPos := mload(64)
                mstore(memPos, and(/** @src 0:1274:1279  "addr2" */ loadimmutable("6"), /** @src 0:176:1918  "contract InitMultiImmutableTest {..." */ 0xffffffffffffffffffffffffffffffffffffffff))
                return(memPos, 32)
            }
            function external_fun_getUint2()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                let memPos := mload(64)
                mstore(memPos, /** @src 0:1535:1540  "uint2" */ loadimmutable("12"))
                /// @src 0:176:1918  "contract InitMultiImmutableTest {..."
                return(memPos, 32)
            }
            function external_fun_getAddr1()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                let memPos := mload(64)
                mstore(memPos, and(/** @src 0:1187:1192  "addr1" */ loadimmutable("4"), /** @src 0:176:1918  "contract InitMultiImmutableTest {..." */ 0xffffffffffffffffffffffffffffffffffffffff))
                return(memPos, 32)
            }
        }
        data ".metadata" hex"a164736f6c634300081e000a"
    }
}

