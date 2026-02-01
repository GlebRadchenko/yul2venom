object "Edge_516" {
    code {
        {
            
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            
            let _2 := datasize("Edge_516_deployed")
            codecopy(_1, dataoffset("Edge_516_deployed"), _2)
            return(_1, _2)
        }
    }
    
    object "Edge_516_deployed" {
        code {
            {
                
                mstore(64, 128)
                
                {
                    switch shr(224, calldataload(0))
                    case 0x00819439 { external_fun_getBlockInfo() }
                    case 0x0a8ef17a {
                        external_fun_tryCallWithReason()
                    }
                    case 0x0e95a841 { external_fun_mayPanic() }
                    case 0x21cae483 { external_fun_getChainInfo() }
                    case 0x2c49bf51 { external_fun_gasHeavyLoop() }
                    case 0x2e49d78b { external_fun_setStatus() }
                    case 0x3f88ca72 { external_fun_tryCall() }
                    case 0x45bcc413 { external_fun_uintToStatus() }
                    case 0x4926c4c6 { external_fun_revertEmpty() }
                    case 0x4e69d560 { external_fun_getStatus() }
                    case 0x502178de { external_fun_requireValue() }
                    case 0x54ccfcf6 {
                        external_fun_revertZeroValue()
                    }
                    case 0x585da3e6 { external_fun_statusToUint() }
                    case 0x5e878508 { external_fun_getTxInfo() }
                    case 0x67ebb3ef { external_fun_requireTrue() }
                    case 0x6de0e656 {
                        external_fun_assertCondition()
                    }
                    case 0x81ea4408 { external_fun_getCodeHash() }
                    case 0x8f46a686 {
                        external_fun_revertUnauthorized()
                    }
                    case 0x90042baf { external_fun_createContract() }
                    case 0x9a9b5d41 { external_fun_revertMessage() }
                    case 0x9ddd1ea1 {
                        external_fun_tryCallWithPanic()
                    }
                    case 0xadaae636 { external_fun_getMsgInfo() }
                    case 0xb51c4f96 { external_fun_getCodeSize() }
                    case 0xd4e6a2b0 { external_fun_revertCustom() }
                    case 0xd78d008b { external_fun_mayFail() }
                    case 0xe9413d38 { external_fun_getBlockhash() }
                    case 0xeca7ed0a { external_fun_checkGas() }
                    case 0xef8a9235 { external_fun_getStatus() }
                    case 0xf8b2cb4f { external_fun_getBalance() }
                    case 0xfdf45d9e {
                        external_fun_create2Contract()
                    }
                }
                if iszero(calldatasize()) { stop() }
                stop()
            }
            function external_fun_getBlockInfo()
            {
                
                
                let memPos := mload(64)
                mstore(memPos,  number())
                
                mstore(add(memPos, 32),  timestamp())
                
                mstore(add(memPos, 64),  coinbase())
                
                return(memPos, 96)
            }
            function abi_decode_uint256(dataEnd) -> value0
            {
                if slt(add(dataEnd, not(3)), 32) { revert(0, 0) }
                value0 := calldataload(4)
            }
            function external_fun_tryCallWithReason()
            {
                
                let ret, ret_1 := fun_tryCallWithReason(abi_decode_uint256(calldatasize()))
                let memPos := mload(64)
                mstore(memPos, iszero(iszero(ret)))
                mstore(add(memPos, 32), 64)
                let length := mload(ret_1)
                mstore(add(memPos, 64), length)
                mcopy(add(memPos, 96), add(ret_1, 32), length)
                mstore(add(add(memPos, length), 96),  0)
                
                return(memPos, add(sub(add(memPos, and(add(length, 31), not(31))), memPos), 96))
            }
            function abi_encode_uint256(headStart, value0) -> tail
            {
                tail := add(headStart, 32)
                mstore(headStart, value0)
            }
            function external_fun_mayPanic()
            {
                
                let _1 := abi_decode_uint256(calldatasize())
                if iszero(_1)
                {
                    mstore( 0,  shl(224, 0x4e487b71))
                    mstore(4, 0x12)
                    revert( 0,  0x24)
                }
                let memPos := mload(64)
                mstore(memPos, div( 0x64,  _1))
                return(memPos, 32)
            }
            function external_fun_getChainInfo()
            {
                
                
                let memPos := mload(64)
                mstore(memPos,  chainid())
                
                mstore(add(memPos, 32),  basefee())
                
                return(memPos, 64)
            }
            function external_fun_gasHeavyLoop()
            {
                
                let var_n := abi_decode_uint256(calldatasize())
                
                if  gt(var_n,  0x03e8)
                
                {
                    
                    var_n :=  0x03e8
                }
                
                let var_sum :=  0
                
                let var_i :=  0
                
                for { }
                 lt(var_i, var_n)
                
                {
                    
                    var_i :=  add( var_i,  1)
                }
                
                {
                    
                    let product := mul(var_i, var_i)
                    
                    let sum := add(var_sum, product)
                    
                    
                    var_sum := sum
                }
                
                let memPos := mload(64)
                mstore(memPos, var_sum)
                return(memPos, 32)
            }
            function external_fun_setStatus()
            {
                
                if slt(add(calldatasize(), not(3)), 32)
                {
                    revert( 0, 0)
                }
                
                let value := calldataload(4)
                let _1 := iszero(lt(value, 5))
                if _1
                {
                    revert( 0, 0)
                }
                
                _1 :=  0
                
                let value_1 := and(sload( 0),  not(255))
                sstore( 0,  or(value_1, and(value, 255)))
                return( 0, 0)
            }
            
            function abi_encode_bool_uint256(headStart, value0, value1) -> tail
            {
                tail := add(headStart, 64)
                mstore(headStart, iszero(iszero(value0)))
                mstore(add(headStart, 32), value1)
            }
            function external_fun_tryCall()
            {
                
                let ret, ret_1 := fun_tryCall(abi_decode_uint256(calldatasize()))
                let memPos := mload(64)
                return(memPos, sub(abi_encode_bool_uint256(memPos, ret, ret_1), memPos))
            }
            function abi_encode_enum_Status(headStart, value0) -> tail
            {
                tail := add(headStart, 32)
                if iszero(lt(value0, 5))
                {
                    mstore( 0,  shl(224, 0x4e487b71))
                    mstore(4, 0x21)
                    revert( 0,  0x24)
                }
                mstore(headStart, value0)
            }
            function external_fun_uintToStatus()
            {
                
                let _1 := abi_decode_uint256(calldatasize())
                if  gt(_1,  4)
                {
                    let memPtr := mload(64)
                    mstore(memPtr, shl(229, 4594637))
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 14)
                    mstore(add(memPtr, 68), "invalid status")
                    revert(memPtr, 100)
                }
                if iszero(lt(_1, 5))
                {
                    mstore( 0,  shl(224, 0x4e487b71))
                    mstore(4, 0x21)
                    revert( 0,  0x24)
                }
                let memPos := mload(64)
                return(memPos, sub(abi_encode_enum_Status(memPos, _1), memPos))
            }
            function external_fun_revertEmpty()
            {
                
                
                revert(0, 0)
            }
            function external_fun_getStatus()
            {
                
                
                let value := and(sload(0), 0xff)
                let memPos := mload(64)
                return(memPos, sub(abi_encode_enum_Status(memPos, value), memPos))
            }
            function external_fun_requireValue()
            {
                
                let _1 := abi_decode_uint256(calldatasize())
                if  iszero(_1)
                
                {
                    let memPtr := mload(64)
                    mstore(memPtr, shl(229, 4594637))
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 16)
                    mstore(add(memPtr, 68), "must be positive")
                    revert(memPtr, 100)
                }
                let memPos := mload(64)
                mstore(memPos, _1)
                return(memPos, 32)
            }
            function external_fun_revertZeroValue()
            {
                
                
                
                mstore( 0,  shl(224, 0x7c946ed7))
                revert( 0, 4)
            }
            function external_fun_statusToUint()
            {
                
                
                let value := and(sload(0), 0xff)
                if iszero(lt(value, 5))
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x21)
                    revert(0, 0x24)
                }
                let memPos := mload(64)
                mstore(memPos, value)
                return(memPos, 32)
            }
            function external_fun_getTxInfo()
            {
                
                
                let memPos := mload(64)
                mstore(memPos,  origin())
                
                mstore(add(memPos, 32),  gasprice())
                
                return(memPos, 64)
            }
            function abi_decode_bool(dataEnd) -> value0
            {
                if slt(add(dataEnd, not(3)), 32) { revert(0, 0) }
                let value := calldataload(4)
                if iszero(eq(value, iszero(iszero(value))))
                {
                    revert( 0, 0)
                }
                
                value0 := value
            }
            function external_fun_requireTrue()
            {
                
                if iszero(abi_decode_bool(calldatasize()))
                {
                    let memPtr := mload(64)
                    mstore(memPtr, shl(229, 4594637))
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 16)
                    mstore(add(memPtr, 68), "condition failed")
                    revert(memPtr, 100)
                }
                let memPos := mload(64)
                mstore(memPos,  0x01)
                
                return(memPos, 32)
            }
            function external_fun_assertCondition()
            {
                
                if iszero(abi_decode_bool(calldatasize()))
                {
                    mstore( 0,  shl(224, 0x4e487b71))
                    mstore(4, 0x01)
                    revert( 0,  0x24)
                }
                let memPos := mload(64)
                mstore(memPos,  0x01)
                
                return(memPos, 32)
            }
            function abi_decode_address(dataEnd) -> value0
            {
                if slt(add(dataEnd, not(3)), 32) { revert(0, 0) }
                let value := calldataload(4)
                
                
                value0 := value
            }
            function external_fun_getCodeHash()
            {
                
                
                let var_hash := extcodehash( abi_decode_address(calldatasize()))
                let memPos := mload(64)
                mstore(memPos, var_hash)
                return(memPos, 32)
            }
            function external_fun_revertUnauthorized()
            {
                
                
                
                mstore( 0,  shl(225, 0x472511eb))
                
                mstore(4,  caller())
                
                revert( 0, 36)
            }
            
            function finalize_allocation(memPtr, size)
            {
                let newFreePtr := add(memPtr, and(add(size, 31), not(31)))
                
                mstore(64, newFreePtr)
            }
            function array_allocation_size_bytes(length) -> size
            {
                
                size := add(and(add(length, 31), not(31)), 0x20)
            }
            function abi_decode_bytes(offset, end) -> array
            {
                if iszero(slt(add(offset, 0x1f), end)) { revert(0, 0) }
                let length := calldataload(offset)
                let _1 := array_allocation_size_bytes(length)
                let memPtr := mload(64)
                finalize_allocation(memPtr, _1)
                mstore(memPtr, length)
                if gt(add(add(offset, length), 0x20), end)
                {
                    revert( 0, 0)
                }
                
                calldatacopy(add(memPtr, 0x20), add(offset, 0x20), length)
                mstore(add(add(memPtr, length), 0x20),  0)
                
                array := memPtr
            }
            function abi_encode_address(headStart, value0) -> tail
            {
                tail := add(headStart, 32)
                mstore(headStart, and(value0, sub(shl(160, 1), 1)))
            }
            function external_fun_createContract()
            {
                
                if slt(add(calldatasize(), not(3)), 32)
                {
                    revert( 0, 0)
                }
                
                let offset := calldataload(4)
                
                
                let value0 := abi_decode_bytes(add(4, offset), calldatasize())
                
                let var_addr := create( 0,  add(value0,  32),  mload(value0))
                
                if  iszero( and( var_addr,  sub(shl(160, 1), 1)))
                {
                    let memPtr := mload(64)
                    mstore(memPtr, shl(229, 4594637))
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 13)
                    mstore(add(memPtr, 68), "create failed")
                    revert(memPtr, 100)
                }
                let memPos := mload(64)
                return(memPos, sub(abi_encode_address(memPos, var_addr), memPos))
            }
            function external_fun_revertMessage()
            {
                
                if slt(add(calldatasize(), not(3)), 32)
                {
                    revert( 0, 0)
                }
                
                let offset := calldataload(4)
                
                
                if iszero(slt(add(offset, 35), calldatasize()))
                {
                    revert( 0, 0)
                }
                
                let length := calldataload(add(4, offset))
                
                
                if gt(add(add(offset, length), 36), calldatasize())
                {
                    revert( 0, 0)
                }
                
                let _1 :=  mload(64)
                
                mstore(_1,  shl(229, 4594637))
                mstore( add(_1,  4), 32)
                mstore(add( _1,  36), length)
                calldatacopy(add( _1,  68), add(offset, 36), length)
                mstore(add(add( _1,  length), 68),  0)
                
                revert(_1, add(sub( add( _1,  and(add(length, 0x1f), not(31))),  _1),  68))
            }
            function external_fun_tryCallWithPanic()
            {
                
                let ret, ret_1 := fun_tryCallWithPanic(abi_decode_uint256(calldatasize()))
                let memPos := mload(64)
                return(memPos, sub(abi_encode_bool_uint256(memPos, ret, ret_1), memPos))
            }
            function external_fun_getMsgInfo()
            {
                
                let memPos := mload(64)
                mstore(memPos,  caller())
                
                mstore(add(memPos, 32),  callvalue())
                
                mstore(add(memPos, 64),  and(calldataload( 0),  shl(224, 0xffffffff)))
                
                return(memPos, 96)
            }
            function external_fun_getCodeSize()
            {
                
                
                let var_size := extcodesize( abi_decode_address(calldatasize()))
                let memPos := mload(64)
                mstore(memPos, var_size)
                return(memPos, 32)
            }
            function external_fun_revertCustom()
            {
                
                let _1 := abi_decode_uint256(calldatasize())
                
                let _2 :=  mload(64)
                
                mstore(_2, shl(224, 0x97ea5a2f))
                
                mstore( add(_2,  4), _1)
                mstore(add( _2,  36), 64)
                mstore(add( _2,  68), 12)
                mstore(add( _2,  100), "custom error")
                
                revert(_2, 132)
            }
            
            function external_fun_mayFail()
            {
                
                let _1 := abi_decode_uint256(calldatasize())
                if iszero( lt(_1,  0x64))
                
                {
                    let memPtr := mload(64)
                    mstore(memPtr, shl(229, 4594637))
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 9)
                    mstore(add(memPtr, 68), "too large")
                    revert(memPtr,  0x64)
                }
                
                let product := shl(1, _1)
                
                let memPos := mload(64)
                let tail := add(memPos, 32)
                mstore(memPos, product)
                return(memPos, sub(tail, memPos))
            }
            function external_fun_getBlockhash()
            {
                
                
                let var :=  blockhash( abi_decode_uint256(calldatasize()))
                let memPos := mload(64)
                mstore(memPos, var)
                return(memPos, 32)
            }
            function external_fun_checkGas()
            {
                
                
                let ret :=  gas()
                
                let memPos := mload(64)
                mstore(memPos, ret)
                return(memPos, 32)
            }
            function external_fun_getBalance()
            {
                
                
                let var :=  balance( abi_decode_address(calldatasize()))
                let memPos := mload(64)
                mstore(memPos, var)
                return(memPos, 32)
            }
            function external_fun_create2Contract()
            {
                
                if slt(add(calldatasize(), not(3)), 64)
                {
                    revert( 0, 0)
                }
                
                let offset := calldataload(4)
                
                
                let value0 := abi_decode_bytes(add(4, offset), calldatasize())
                
                let var_addr := create2( 0,  add(value0,  32),  mload(value0),  calldataload(36))
                if  iszero( and( var_addr,  sub(shl(160, 1), 1)))
                {
                    let memPtr := mload(64)
                    mstore(memPtr, shl(229, 4594637))
                    mstore(add(memPtr, 4), 32)
                    mstore(add(memPtr, 36), 14)
                    mstore(add(memPtr, 68), "create2 failed")
                    revert(memPtr, 100)
                }
                let memPos := mload(64)
                return(memPos, sub(abi_encode_address(memPos, var_addr), memPos))
            }
            function abi_decode_uint256_fromMemory(headStart, dataEnd) -> value0
            {
                if slt(sub(dataEnd, headStart), 32) { revert(0, 0) }
                value0 := mload(headStart)
            }
            function allocate_memory_array_string() -> memPtr
            {
                let size := add(and(add( 0,  31), not(31)), 0x20)
                let memPtr_1 := mload(64)
                finalize_allocation(memPtr_1, size)
                memPtr := memPtr_1
                mstore(memPtr_1, 0)
            }
            function return_data_selector() -> sig
            {
                if gt(returndatasize(), 3)
                {
                    returndatacopy(0, 0, 4)
                    sig := shr(224, mload(0))
                }
            }
            function try_decode_error_message() -> ret
            {
                if lt(returndatasize(), 0x44) { leave }
                let data := mload(64)
                returndatacopy(data, 4, add(returndatasize(), not(3)))
                let offset := mload(data)
                if or(gt(offset, 0xffffffffffffffff), gt(add(offset, 0x24), returndatasize())) { leave }
                let msg := add(data, offset)
                let length := mload(msg)
                
                if gt(add(add(msg, length), 0x20), add(add(data, returndatasize()), not(3))) { leave }
                finalize_allocation(data, add(add(offset, length), 0x20))
                ret := msg
            }
            function copy_literal_to_memory_24695ee963d29f0f52edfdea1e830d2fcfc9052d5ba70b194bddd0afbbc89765() -> memPtr
            {
                let size :=  0
                
                let _1 := 0
                
                size := 64
                let memPtr_1 := mload(64)
                finalize_allocation(memPtr_1, 64)
                mstore(memPtr_1, 7)
                memPtr := memPtr_1
                mstore(add(memPtr_1, 32), "unknown")
            }
            /// @ast-id 247 @src 0:2496:2827  "function tryCallWithReason(..."
            function fun_tryCallWithReason(var_x) -> var, var_mpos
            {
                
                var :=  0
                
                var_mpos :=  96
                
                let _1 :=  mload(64)
                
                mstore(_1,  shl(224, 0xd78d008b))
                
                let trySuccessCondition := staticcall(gas(),  address(),  _1, sub(abi_encode_uint256(add(_1, 4), var_x), _1), _1, 32)
                let expr :=  0
                
                if trySuccessCondition
                {
                    let _2 := 32
                    if gt(32, returndatasize()) { _2 := returndatasize() }
                    finalize_allocation(_1, _2)
                    expr := abi_decode_uint256_fromMemory(_1, add(_1, _2))
                }
                
                switch iszero(trySuccessCondition)
                case 0 {
                    
                    var :=  0x01
                    
                    var_mpos :=  allocate_memory_array_string()
                    
                    leave
                }
                default 
                {
                    if eq(147028384, return_data_selector())
                    {
                        
                        let _3 := try_decode_error_message()
                        if _3
                        {
                            
                            var :=  0
                            
                            var_mpos := _3
                            leave
                        }
                    }
                    
                    var :=  0
                    
                    var_mpos :=  copy_literal_to_memory_24695ee963d29f0f52edfdea1e830d2fcfc9052d5ba70b194bddd0afbbc89765()
                    
                    leave
                }
            }
            
            
            /// @ast-id 208 @src 0:2249:2490  "function tryCall(..."
            function fun_tryCall(var_x) -> var_success, var_result
            {
                
                let _1 :=  mload(64)
                
                mstore(_1,  shl(224, 0xd78d008b))
                mstore( add(_1, 4),  var_x)
                
                let trySuccessCondition := staticcall(gas(),  address(),  _1, 36, _1,  32)
                
                let expr :=  0
                
                if trySuccessCondition
                {
                    let _2 :=  32
                    
                    if gt( 32,  returndatasize()) { _2 := returndatasize() }
                    finalize_allocation(_1, _2)
                    expr := abi_decode_uint256_fromMemory(_1, add(_1, _2))
                }
                
                switch iszero(trySuccessCondition)
                case 0 {
                    
                    var_success :=  0x01
                    
                    var_result := expr
                    leave
                }
                default 
                {
                    
                    var_success :=  0
                    
                    var_result :=  0
                    
                    leave
                }
            }
            
            function try_decode_panic_data() -> success, data
            {
                if gt(returndatasize(), 0x23)
                {
                    returndatacopy(0, 4, 0x20)
                    success := 1
                    data := mload(0)
                }
            }
            /// @ast-id 286 @src 0:2833:3127  "function tryCallWithPanic(uint256 x) external view returns (bool, uint256) {..."
            function fun_tryCallWithPanic(var_x) -> var, var_1
            {
                
                var :=  0
                
                var_1 :=  0
                
                let _1 :=  mload(64)
                
                mstore(_1,  shl(224, 0x0e95a841))
                
                let trySuccessCondition := staticcall(gas(),  address(),  _1, sub(abi_encode_uint256(add(_1, 4), var_x), _1), _1, 32)
                let expr :=  0
                
                if trySuccessCondition
                {
                    let _2 := 32
                    if gt(32, returndatasize()) { _2 := returndatasize() }
                    finalize_allocation(_1, _2)
                    expr := abi_decode_uint256_fromMemory(_1, add(_1, _2))
                }
                
                switch iszero(trySuccessCondition)
                case 0 {
                    
                    var :=  0x01
                    
                    var_1 :=  0
                    
                    leave
                }
                default 
                {
                    if eq(1313373041, return_data_selector())
                    {
                        
                        let _3, _4 := try_decode_panic_data()
                        if _3
                        {
                            
                            var :=  0
                            
                            var_1 := _4
                            leave
                        }
                    }
                    
                    var :=  0
                    
                    var_1 :=  0x03e7
                    
                    leave
                }
            }
        }
        data ".metadata" hex"a2646970667358221220331e96b4f7cf62ec126673fb660c55814874336261216d27f3bb99519d6e18b564736f6c634300081c0033"
    }
}