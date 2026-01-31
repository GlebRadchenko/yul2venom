#!/usr/bin/env python3
"""
Inspect Bytecode - Simple EVM bytecode disassembler.

Usage:
    python3 inspect_bytecode.py <file.bin> [--limit N]
    
Disassembles EVM bytecode to human-readable assembly format.
Supports all standard EVM opcodes including PUSHn, DUPn, SWAPn.
"""

import sys
import argparse


# EVM opcode table
OPCODES = {
    0x00: 'STOP', 0x01: 'ADD', 0x02: 'MUL', 0x03: 'SUB', 0x04: 'DIV', 0x05: 'SDIV',
    0x06: 'MOD', 0x07: 'SMOD', 0x08: 'ADDMOD', 0x09: 'MULMOD', 0x0A: 'EXP',
    0x0B: 'SIGNEXTEND',
    0x10: 'LT', 0x11: 'GT', 0x12: 'SLT', 0x13: 'SGT', 0x14: 'EQ', 0x15: 'ISZERO',
    0x16: 'AND', 0x17: 'OR', 0x18: 'XOR', 0x19: 'NOT', 0x1A: 'BYTE', 0x1B: 'SHL',
    0x1C: 'SHR', 0x1D: 'SAR',
    0x20: 'SHA3',
    0x30: 'ADDRESS', 0x31: 'BALANCE', 0x32: 'ORIGIN', 0x33: 'CALLER',
    0x34: 'CALLVALUE', 0x35: 'CALLDATALOAD', 0x36: 'CALLDATASIZE', 0x37: 'CALLDATACOPY',
    0x38: 'CODESIZE', 0x39: 'CODECOPY', 0x3A: 'GASPRICE', 0x3B: 'EXTCODESIZE',
    0x3C: 'EXTCODECOPY', 0x3D: 'RETURNDATASIZE', 0x3E: 'RETURNDATACOPY',
    0x3F: 'EXTCODEHASH',
    0x40: 'BLOCKHASH', 0x41: 'COINBASE', 0x42: 'TIMESTAMP', 0x43: 'NUMBER',
    0x44: 'DIFFICULTY', 0x45: 'GASLIMIT', 0x46: 'CHAINID', 0x47: 'SELFBALANCE',
    0x48: 'BASEFEE', 0x49: 'BLOBHASH', 0x4A: 'BLOBBASEFEE',
    0x50: 'POP', 0x51: 'MLOAD', 0x52: 'MSTORE', 0x53: 'MSTORE8', 0x54: 'SLOAD',
    0x55: 'SSTORE', 0x56: 'JUMP', 0x57: 'JUMPI', 0x58: 'PC', 0x59: 'MSIZE',
    0x5A: 'GAS', 0x5B: 'JUMPDEST', 0x5C: 'TLOAD', 0x5D: 'TSTORE', 0x5E: 'MCOPY', 
    0x5F: 'PUSH0',
    0xA0: 'LOG0', 0xA1: 'LOG1', 0xA2: 'LOG2', 0xA3: 'LOG3', 0xA4: 'LOG4',
    0xF0: 'CREATE', 0xF1: 'CALL', 0xF2: 'CALLCODE', 0xF3: 'RETURN',
    0xF4: 'DELEGATECALL', 0xF5: 'CREATE2', 0xFA: 'STATICCALL', 0xFD: 'REVERT',
    0xFE: 'INVALID', 0xFF: 'SELFDESTRUCT'
}

# Add DUP1-16 and SWAP1-16
for i in range(16):
    OPCODES[0x80 + i] = f'DUP{i + 1}'
    OPCODES[0x90 + i] = f'SWAP{i + 1}'

# Add PUSH1-32
for i in range(32):
    OPCODES[0x60 + i] = f'PUSH{i + 1}'


def disassemble(bytecode: bytes, limit: int = None) -> list:
    """
    Disassemble EVM bytecode.
    
    Args:
        bytecode: Raw bytes to disassemble
        limit: Optional limit on number of instructions
        
    Returns:
        List of disassembled instruction strings
    """
    pc = 0
    output = []
    count = 0
    
    while pc < len(bytecode):
        if limit and count >= limit:
            output.append(f"... (truncated at {limit} instructions)")
            break
            
        op = bytecode[pc]
        op_name = OPCODES.get(op, f'UNKNOWN(0x{op:02x})')
        
        # PUSH instructions have immediate data
        if 0x60 <= op <= 0x7F:
            push_len = op - 0x5F
            data_start = pc + 1
            data_end = data_start + push_len
            
            if data_end > len(bytecode):
                data = bytecode[data_start:]
                data_hex = data.hex().ljust(push_len * 2, '?')
                output.append(f"{pc:04x}: {op_name} 0x{data_hex} (INCOMPLETE)")
                break
            else:
                data = bytecode[data_start:data_end]
                output.append(f"{pc:04x}: {op_name} 0x{data.hex()}")
                pc = data_end
        else:
            output.append(f"{pc:04x}: {op_name}")
            pc += 1
            
        count += 1
            
    return output


def main():
    parser = argparse.ArgumentParser(
        description="Disassemble EVM bytecode"
    )
    parser.add_argument("file", help="Path to binary bytecode file")
    parser.add_argument(
        "--limit", "-l",
        type=int,
        help="Limit number of instructions to display"
    )
    parser.add_argument(
        "--hex",
        action="store_true",
        help="Input file is hex-encoded text (not raw binary)"
    )
    args = parser.parse_args()

    try:
        with open(args.file, 'rb') as f:
            content = f.read()
        
        # Handle hex-encoded files
        if args.hex or not any(b > 0x7f for b in content[:100]):
            try:
                hex_str = content.decode('utf-8').strip()
                if hex_str.startswith('0x'):
                    hex_str = hex_str[2:]
                bytecode = bytes.fromhex(hex_str)
            except:
                bytecode = content
        else:
            bytecode = content
            
        print(f"Disassembling {len(bytecode)} bytes from {args.file}")
        print("-" * 50)
        
        lines = disassemble(bytecode, limit=args.limit)
        for line in lines:
            print(line)
            
    except FileNotFoundError:
        print(f"Error: File not found: {args.file}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
