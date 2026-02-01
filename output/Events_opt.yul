object "Events_146" {
    code {
        {
            
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            
            let _2 := datasize("Events_146_deployed")
            codecopy(_1, dataoffset("Events_146_deployed"), _2)
            return(_1, _2)
        }
    }
    
    object "Events_146_deployed" {
        code {
            {
                
                let _1 := memoryguard(0x80)
                mstore(64, _1)
                
                {
                    switch shr(224, calldataload(0))
                    case 0x2536f127 {
                        
                        
                        let offset := calldataload(4)
                        
                        let value0, value1 := abi_decode_string_calldata(add(4, offset), calldatasize())
                        mstore(_1, 32)
                        
                        log1(_1, sub( abi_encode_string_calldata(value0, value1, add(_1, 32)),  _1), 0x617cf8a4400dd7963ed519ebe655a16e8da1282bb8fea36a21f634af912f54ab)
                        
                        return(0, 0)
                    }
                    case 0x309818a4 {
                        
                        
                        let var_count := calldataload(4)
                        
                        if  gt(var_count,  0x64)
                        
                        {
                            
                            var_count :=  0x64
                        }
                        
                        let var_i :=  0
                        
                        for { }
                         lt(var_i, var_count)
                        
                        {
                            
                            var_i :=  add( var_i,  1)
                        }
                        
                        {
                            
                            let _2 :=  mload(64)
                            mstore(_2, var_i)
                            
                            log1(_2,  32,  0x12d199749b3f4c44df8d9386c63d725b7756ec47204f3aa0bf05ea832f89effb)
                        }
                        
                        return(0, 0)
                    }
                    case 0x7ea47d4b {
                        
                        
                        let offset_1 := calldataload(68)
                        
                        let value2, value3 := abi_decode_string_calldata(add(4, offset_1), calldatasize())
                        
                        let _3 :=  mload(64)
                        mstore(_3, calldataload(36))
                        mstore(add(_3, 32), 64)
                        
                        log3(_3, sub( abi_encode_string_calldata(value2, value3, add(_3, 64)),  _3), 0x5bc8cccb2e4db71ecfb93e6240a44bedb48dc3b393064e139b7bc6d27d257d59,  caller(),  calldataload(4))
                        return(0, 0)
                    }
                    case 0xb12c11e4 {
                        
                        
                        
                        log4( 0, 0,  0x39eb0fba179eb98affc7a0a67edf5a0d4cc6ee08a1ebd277c8bb980da58adc22,  calldataload(4), calldataload(36), calldataload(68))
                        return(0, 0)
                    }
                    case 0xc76f0635 {
                        
                        
                        let offset_2 := calldataload(4)
                        
                        let value0_1, value1_1 := abi_decode_string_calldata(add(4, offset_2), calldatasize())
                        
                        let _4 :=  mload(64)
                        mstore(_4, 32)
                        
                        log1(_4, sub( abi_encode_string_calldata(value0_1, value1_1, add(_4, 32)),  _4), 0x9ee3485561a302141390e6d886e41f4922a82c93c6ab2d9f52c30cbd682994f1)
                        
                        return(0, 0)
                    }
                    case 0xd0ee85c8 {
                        
                        
                        
                        let _5 :=  mload(64)
                        mstore(_5, calldataload(4))
                        
                        log1(_5,  32,  0x12d199749b3f4c44df8d9386c63d725b7756ec47204f3aa0bf05ea832f89effb)
                        
                        return(0, 0)
                    }
                    case 0xfa31e50b {
                        
                        
                        
                        let _6 :=  mload(64)
                        mstore(_6, calldataload(36))
                        
                        log2(_6,  32,  0xc254f246ab6ea865f412958066d69e30165cc2edb333036518db581d9176a2d0,  calldataload(4))
                        return(0, 0)
                    }
                }
                revert(0, 0)
            }
            function abi_decode_string_calldata(offset, end) -> arrayPos, length
            {
                if iszero(slt(add(offset, 0x1f), end)) { revert(0, 0) }
                length := calldataload(offset)
                
                arrayPos := add(offset, 0x20)
                if gt(add(add(offset, length), 0x20), end) { revert(0, 0) }
            }
            function abi_encode_string_calldata(start, length, pos) -> end
            {
                mstore(pos, length)
                calldatacopy(add(pos, 0x20), start, length)
                mstore(add(add(pos, length), 0x20),  0)
                
                end := add(add(pos, and(add(length, 31), not(31))), 0x20)
            }
        }
        data ".metadata" hex"a26469706673582212202b5112c1f41c8f28f4304a62ef647cb429a83584c125d368cbfab7c43fdd773464736f6c634300081c0033"
    }
}