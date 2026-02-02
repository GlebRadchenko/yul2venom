/// @use-src 0:"src/init/InitInheritanceTest.sol"
object "InitInheritanceTest_162" {
    code {
        {
            /// @src 0:887:2085  "contract InitInheritanceTest is BaseLevel3 {..."
            let _1 := memoryguard(0x0120)
            if callvalue() { revert(0, 0) }
            let programSize := datasize("InitInheritanceTest_162")
            let argSize := sub(codesize(), programSize)
            let newFreePtr := add(_1, and(add(argSize, 31), not(31)))
            if or(gt(newFreePtr, sub(shl(64, 1), 1)), lt(newFreePtr, _1))
            {
                mstore(/** @src -1:-1:-1 */ 0, /** @src 0:887:2085  "contract InitInheritanceTest is BaseLevel3 {..." */ shl(224, 0x4e487b71))
                mstore(4, 0x41)
                revert(/** @src -1:-1:-1 */ 0, /** @src 0:887:2085  "contract InitInheritanceTest is BaseLevel3 {..." */ 0x24)
            }
            mstore(64, newFreePtr)
            codecopy(_1, programSize, argSize)
            if slt(sub(add(_1, argSize), _1), 160)
            {
                revert(/** @src -1:-1:-1 */ 0, 0)
            }
            /// @src 0:887:2085  "contract InitInheritanceTest is BaseLevel3 {..."
            let value0 := abi_decode_address_fromMemory(_1)
            let value1 := abi_decode_address_fromMemory(add(_1, 32))
            let value := mload(add(_1, 64))
            let value3 := abi_decode_address_fromMemory(add(_1, 96))
            let value4 := abi_decode_address_fromMemory(add(_1, 128))
            /// @src 0:320:332  "weth = _weth"
            mstore(/** @src 0:887:2085  "contract InitInheritanceTest is BaseLevel3 {..." */ 128, /** @src 0:320:332  "weth = _weth" */ value0)
            /// @src 0:514:528  "owner = _owner"
            mstore(/** @src 0:887:2085  "contract InitInheritanceTest is BaseLevel3 {..." */ 160, /** @src 0:514:528  "owner = _owner" */ value1)
            /// @src 0:767:783  "config = _config"
            mstore(192, value)
            /// @src 0:1347:1365  "sender0 = _sender0"
            mstore(224, value3)
            /// @src 0:1375:1393  "sender1 = _sender1"
            mstore(256, value4)
            /// @src 0:887:2085  "contract InitInheritanceTest is BaseLevel3 {..."
            sstore(/** @src -1:-1:-1 */ 0, /** @src 0:887:2085  "contract InitInheritanceTest is BaseLevel3 {..." */ or(and(sload(/** @src -1:-1:-1 */ 0), /** @src 0:887:2085  "contract InitInheritanceTest is BaseLevel3 {..." */ not(255)), 1))
            sstore(1, /** @src 0:1438:1453  "block.timestamp" */ timestamp())
            /// @src 0:887:2085  "contract InitInheritanceTest is BaseLevel3 {..."
            let _2 := mload(64)
            let _3 := datasize("InitInheritanceTest_162_deployed")
            codecopy(_2, dataoffset("InitInheritanceTest_162_deployed"), _3)
            setimmutable(_2, "4", mload(128))
            setimmutable(_2, "19", mload(160))
            setimmutable(_2, "39", mload(/** @src 0:767:783  "config = _config" */ 192))
            /// @src 0:887:2085  "contract InitInheritanceTest is BaseLevel3 {..."
            setimmutable(_2, "63", mload(/** @src 0:1347:1365  "sender0 = _sender0" */ 224))
            /// @src 0:887:2085  "contract InitInheritanceTest is BaseLevel3 {..."
            setimmutable(_2, "65", mload(/** @src 0:1375:1393  "sender1 = _sender1" */ 256))
            /// @src 0:887:2085  "contract InitInheritanceTest is BaseLevel3 {..."
            return(_2, _3)
        }
        function abi_decode_address_fromMemory(offset) -> value
        {
            value := mload(offset)
            if iszero(eq(value, and(value, sub(shl(160, 1), 1)))) { revert(0, 0) }
        }
    }
    /// @use-src 0:"src/init/InitInheritanceTest.sol"
    object "InitInheritanceTest_162_deployed" {
        code {
            {
                /// @src 0:887:2085  "contract InitInheritanceTest is BaseLevel3 {..."
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                if iszero(lt(calldatasize(), 4))
                {
                    switch shr(224, calldataload(0))
                    case 0x02fb0c5e {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                        mstore(_1, iszero(iszero(and(sload(0), 0xff))))
                        return(_1, 32)
                    }
                    case 0x107c279f { external_fun_getWeth() }
                    case 0x1783770b { external_fun_getSender0() }
                    case 0x22f3e2d4 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                        let value := and(sload(0), 0xff)
                        let memPos := mload(64)
                        mstore(memPos, iszero(iszero(value)))
                        return(memPos, 32)
                    }
                    case 0x3fc8cef3 { external_fun_getWeth() }
                    case 0x6351613b { external_fun_getSender0() }
                    case 0x762e2988 { external_fun_getSender1() }
                    case 0x79502c55 { external_fun_config() }
                    case 0x7e05f5a8 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                        let _2 := sload(/** @src 0:2067:2076  "createdAt" */ 0x01)
                        /// @src 0:887:2085  "contract InitInheritanceTest is BaseLevel3 {..."
                        let memPos_1 := mload(64)
                        mstore(memPos_1, _2)
                        return(memPos_1, 32)
                    }
                    case 0x893d20e8 { external_fun_getOwner() }
                    case 0x8da5cb5b { external_fun_getOwner() }
                    case 0xc3f909d4 { external_fun_config() }
                    case 0xcf09e0d0 {
                        if callvalue() { revert(0, 0) }
                        if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                        let _3 := sload(/** @src 0:1129:1153  "uint256 public createdAt" */ 1)
                        /// @src 0:887:2085  "contract InitInheritanceTest is BaseLevel3 {..."
                        let memPos_2 := mload(64)
                        mstore(memPos_2, _3)
                        return(memPos_2, 32)
                    }
                    case 0xf34e0e7b { external_fun_getSender1() }
                }
                revert(0, 0)
            }
            function external_fun_getWeth()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                let memPos := mload(64)
                mstore(memPos, and(/** @src 0:1534:1538  "weth" */ loadimmutable("4"), /** @src 0:887:2085  "contract InitInheritanceTest is BaseLevel3 {..." */ 0xffffffffffffffffffffffffffffffffffffffff))
                return(memPos, 32)
            }
            function external_fun_getSender0()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                let memPos := mload(64)
                mstore(memPos, and(/** @src 0:1798:1805  "sender0" */ loadimmutable("63"), /** @src 0:887:2085  "contract InitInheritanceTest is BaseLevel3 {..." */ 0xffffffffffffffffffffffffffffffffffffffff))
                return(memPos, 32)
            }
            function external_fun_getSender1()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                let memPos := mload(64)
                mstore(memPos, and(/** @src 0:1889:1896  "sender1" */ loadimmutable("65"), /** @src 0:887:2085  "contract InitInheritanceTest is BaseLevel3 {..." */ 0xffffffffffffffffffffffffffffffffffffffff))
                return(memPos, 32)
            }
            function external_fun_config()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                let memPos := mload(64)
                mstore(memPos, /** @src 0:603:634  "uint256 public immutable config" */ loadimmutable("39"))
                /// @src 0:887:2085  "contract InitInheritanceTest is BaseLevel3 {..."
                return(memPos, 32)
            }
            function external_fun_getOwner()
            {
                if callvalue() { revert(0, 0) }
                if slt(add(calldatasize(), 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc), 0) { revert(0, 0) }
                let memPos := mload(64)
                mstore(memPos, and(/** @src 0:1620:1625  "owner" */ loadimmutable("19"), /** @src 0:887:2085  "contract InitInheritanceTest is BaseLevel3 {..." */ 0xffffffffffffffffffffffffffffffffffffffff))
                return(memPos, 32)
            }
        }
        data ".metadata" hex"a164736f6c634300081e000a"
    }
}

