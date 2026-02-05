#!/usr/bin/env python3
"""
Minimal EVM Tracer for Debugging Yul2Venom Bytecode

This tracer executes EVM bytecode step-by-step, logging:
- Program counter
- Opcode name
- Stack state (before and after)
- Memory writes

Usage:
    python3 evm_tracer.py <bytecode_hex_file> [calldata_hex]
"""

import sys
from typing import List, Dict, Optional, Tuple

# EVM Opcodes
OPCODES: Dict[int, Tuple[str, int, int]] = {
    # opcode: (name, stack_pops, stack_pushes)
    0x00: ("STOP", 0, 0),
    0x01: ("ADD", 2, 1),
    0x02: ("MUL", 2, 1),
    0x03: ("SUB", 2, 1),
    0x04: ("DIV", 2, 1),
    0x05: ("SDIV", 2, 1),
    0x06: ("MOD", 2, 1),
    0x07: ("SMOD", 2, 1),
    0x08: ("ADDMOD", 3, 1),
    0x09: ("MULMOD", 3, 1),
    0x0A: ("EXP", 2, 1),
    0x0B: ("SIGNEXTEND", 2, 1),
    0x10: ("LT", 2, 1),
    0x11: ("GT", 2, 1),
    0x12: ("SLT", 2, 1),
    0x13: ("SGT", 2, 1),
    0x14: ("EQ", 2, 1),
    0x15: ("ISZERO", 1, 1),
    0x16: ("AND", 2, 1),
    0x17: ("OR", 2, 1),
    0x18: ("XOR", 2, 1),
    0x19: ("NOT", 1, 1),
    0x1A: ("BYTE", 2, 1),
    0x1B: ("SHL", 2, 1),
    0x1C: ("SHR", 2, 1),
    0x1D: ("SAR", 2, 1),
    0x20: ("SHA3", 2, 1),
    0x30: ("ADDRESS", 0, 1),
    0x31: ("BALANCE", 1, 1),
    0x32: ("ORIGIN", 0, 1),
    0x33: ("CALLER", 0, 1),
    0x34: ("CALLVALUE", 0, 1),
    0x35: ("CALLDATALOAD", 1, 1),
    0x36: ("CALLDATASIZE", 0, 1),
    0x37: ("CALLDATACOPY", 3, 0),
    0x38: ("CODESIZE", 0, 1),
    0x39: ("CODECOPY", 3, 0),
    0x3A: ("GASPRICE", 0, 1),
    0x3B: ("EXTCODESIZE", 1, 1),
    0x3C: ("EXTCODECOPY", 4, 0),
    0x3D: ("RETURNDATASIZE", 0, 1),
    0x3E: ("RETURNDATACOPY", 3, 0),
    0x3F: ("EXTCODEHASH", 1, 1),
    0x40: ("BLOCKHASH", 1, 1),
    0x41: ("COINBASE", 0, 1),
    0x42: ("TIMESTAMP", 0, 1),
    0x43: ("NUMBER", 0, 1),
    0x44: ("DIFFICULTY", 0, 1),
    0x45: ("GASLIMIT", 0, 1),
    0x46: ("CHAINID", 0, 1),
    0x47: ("SELFBALANCE", 0, 1),
    0x48: ("BASEFEE", 0, 1),
    0x50: ("POP", 1, 0),
    0x51: ("MLOAD", 1, 1),
    0x52: ("MSTORE", 2, 0),
    0x53: ("MSTORE8", 2, 0),
    0x54: ("SLOAD", 1, 1),
    0x55: ("SSTORE", 2, 0),
    0x56: ("JUMP", 1, 0),
    0x57: ("JUMPI", 2, 0),
    0x58: ("PC", 0, 1),
    0x59: ("MSIZE", 0, 1),
    0x5A: ("GAS", 0, 1),
    0x5B: ("JUMPDEST", 0, 0),
    0x5F: ("PUSH0", 0, 1),
    0x80: ("DUP1", 0, 1),
    0x81: ("DUP2", 0, 1),
    0x82: ("DUP3", 0, 1),
    0x83: ("DUP4", 0, 1),
    0x84: ("DUP5", 0, 1),
    0x85: ("DUP6", 0, 1),
    0x86: ("DUP7", 0, 1),
    0x87: ("DUP8", 0, 1),
    0x88: ("DUP9", 0, 1),
    0x89: ("DUP10", 0, 1),
    0x8A: ("DUP11", 0, 1),
    0x8B: ("DUP12", 0, 1),
    0x8C: ("DUP13", 0, 1),
    0x8D: ("DUP14", 0, 1),
    0x8E: ("DUP15", 0, 1),
    0x8F: ("DUP16", 0, 1),
    0x90: ("SWAP1", 0, 0),
    0x91: ("SWAP2", 0, 0),
    0x92: ("SWAP3", 0, 0),
    0x93: ("SWAP4", 0, 0),
    0x94: ("SWAP5", 0, 0),
    0x95: ("SWAP6", 0, 0),
    0x96: ("SWAP7", 0, 0),
    0x97: ("SWAP8", 0, 0),
    0x98: ("SWAP9", 0, 0),
    0x99: ("SWAP10", 0, 0),
    0x9A: ("SWAP11", 0, 0),
    0x9B: ("SWAP12", 0, 0),
    0x9C: ("SWAP13", 0, 0),
    0x9D: ("SWAP14", 0, 0),
    0x9E: ("SWAP15", 0, 0),
    0x9F: ("SWAP16", 0, 0),
    0x5C: ("TLOAD", 1, 1),      # Cancun: Transient SLOAD
    0x5D: ("TSTORE", 2, 0),     # Cancun: Transient SSTORE
    0x5E: ("MCOPY", 3, 0),      # Cancun: Memory copy
    0xF3: ("RETURN", 2, 0),
    0xFD: ("REVERT", 2, 0),
    0xFE: ("INVALID", 0, 0),
    0xFF: ("SELFDESTRUCT", 1, 0),
}

# Add PUSH1-PUSH32
for i in range(1, 33):
    OPCODES[0x60 + i - 1] = (f"PUSH{i}", 0, 1)

# Add LOG0-LOG4
for i in range(5):
    OPCODES[0xA0 + i] = (f"LOG{i}", 2 + i, 0)


class EVMTracer:
    def __init__(self, bytecode: bytes, calldata: bytes = b"", max_steps: int = 10000,
                 address: int = 0xDEADBEEF, caller: int = 0xBEEF, origin: int = 0xCAFE):
        self.code = bytecode
        self.calldata = calldata
        self.max_steps = max_steps
        
        # Environment
        self.address = address  # Contract address
        self.caller = caller    # msg.sender
        self.origin = origin    # tx.origin
        
        # State
        self.pc = 0
        self.stack: List[int] = []
        self.memory: bytearray = bytearray(1024 * 1024)  # 1MB
        self.storage: Dict[int, int] = {}
        self.transient_storage: Dict[int, int] = {}  # Cancun: Transient storage
        self.gas = 10_000_000
        self.stopped = False
        self.reverted = False
        self.return_data = b""
        
        # Tracing
        self.step_count = 0
        self.trace_log: List[str] = []
        self.jumpdests: set = self._find_jumpdests()
        
    def _find_jumpdests(self) -> set:
        """Find all valid JUMPDEST positions"""
        dests = set()
        pc = 0
        while pc < len(self.code):
            op = self.code[pc]
            if op == 0x5B:  # JUMPDEST
                dests.add(pc)
            # Skip PUSH data
            if 0x60 <= op <= 0x7F:
                pc += (op - 0x60 + 2)
            else:
                pc += 1
        return dests
    
    def _log(self, msg: str):
        self.trace_log.append(msg)
        print(msg)
    
    def _stack_top(self, n: int = 5) -> str:
        """Format top n stack items"""
        if not self.stack:
            return "[]"
        top = self.stack[-n:] if len(self.stack) >= n else self.stack
        return "[" + ", ".join(f"0x{v:x}" for v in reversed(top)) + "]"
    
    def _mem_read(self, offset: int, size: int) -> bytes:
        if offset + size > len(self.memory):
            self.memory.extend(bytearray(offset + size - len(self.memory) + 1024))
        return bytes(self.memory[offset:offset+size])
    
    def _mem_write(self, offset: int, data: bytes):
        if offset + len(data) > len(self.memory):
            self.memory.extend(bytearray(offset + len(data) - len(self.memory) + 1024))
        self.memory[offset:offset+len(data)] = data
    
    def step(self) -> bool:
        """Execute one instruction. Returns False if stopped."""
        if self.pc >= len(self.code) or self.stopped:
            return False
        
        pc_before = self.pc  # Save PC before execution
        op = self.code[self.pc]
        
        if op in OPCODES:
            name, pops, pushes = OPCODES[op]
        elif 0x60 <= op <= 0x7F:
            name = f"PUSH{op - 0x60 + 1}"
            pops, pushes = 0, 1
        else:
            name = f"UNKNOWN(0x{op:02x})"
            pops, pushes = 0, 0
        
        # Log before execution
        stack_before = self._stack_top(8)
        
        # For GT/LT, capture operands before execution
        gt_a, gt_b = None, None
        if name in ("GT", "LT") and len(self.stack) >= 2:
            gt_a, gt_b = self.stack[-1], self.stack[-2]
        
        # For MSTORE, capture offset and value before execution
        mstore_offset, mstore_value = None, None
        if name == "MSTORE" and len(self.stack) >= 2:
            mstore_offset, mstore_value = self.stack[-1], self.stack[-2]
        
        # Execute
        try:
            self._execute(op, name)
        except Exception as e:
            self._log(f"[{self.step_count:5d}] PC={pc_before:04x} {name:12s} STACK={stack_before}")
            self._log(f"         ERROR: {e}")
            self.stopped = True
            return False
        
        # Log after execution  
        stack_after = self._stack_top(8)
        
        # Special logging for key instructions
        if name == "GT":
            result = self.stack[-1] if self.stack else "?"
            self._log(f"[{self.step_count:5d}] PC={pc_before:04x} {name:12s} GT(0x{gt_a:x}, 0x{gt_b:x})={result} STACK={stack_after}")
        elif name == "LT":
            result = self.stack[-1] if self.stack else "?"
            self._log(f"[{self.step_count:5d}] PC={pc_before:04x} {name:12s} LT(0x{gt_a:x}, 0x{gt_b:x})={result} STACK={stack_after}")
        elif name == "JUMPI":
            self._log(f"[{self.step_count:5d}] PC={pc_before:04x} {name:12s} -> PC={self.pc:04x} STACK={stack_after}")
        elif name == "JUMP":
            self._log(f"[{self.step_count:5d}] PC={pc_before:04x} {name:12s} -> PC={self.pc:04x} STACK={stack_after}")
        elif name.startswith("MSTORE"):
            self._log(f"[{self.step_count:5d}] PC={pc_before:04x} {name:12s} MSTORE(0x{mstore_offset:x}, 0x{mstore_value:x}) STACK={stack_after}")
        elif "MLOAD" in name:
            val = self.stack[-1] if self.stack else "?"
            self._log(f"[{self.step_count:5d}] PC={self.pc:04x} {name:12s} loaded=0x{val:x} STACK={stack_after}")
        else:
            # Only log every 100th instruction for others
            if self.step_count % 100 == 0:
                self._log(f"[{self.step_count:5d}] PC={pc_before:04x} {name:12s} STACK={stack_after}")
        
        self.step_count += 1
        return not self.stopped and self.step_count < self.max_steps
    
    def _execute(self, op: int, name: str):
        """Execute a single opcode"""
        # STOP
        if op == 0x00:
            self.stopped = True
            return
        
        # Arithmetic
        if op == 0x01:  # ADD
            a, b = self.stack.pop(), self.stack.pop()
            self.stack.append((a + b) & ((1 << 256) - 1))
            self.pc += 1
        elif op == 0x02:  # MUL
            a, b = self.stack.pop(), self.stack.pop()
            self.stack.append((a * b) & ((1 << 256) - 1))
            self.pc += 1
        elif op == 0x03:  # SUB
            a, b = self.stack.pop(), self.stack.pop()
            self.stack.append((a - b) & ((1 << 256) - 1))
            self.pc += 1
        elif op == 0x04:  # DIV
            a, b = self.stack.pop(), self.stack.pop()
            self.stack.append(a // b if b != 0 else 0)
            self.pc += 1
        elif op == 0x06:  # MOD
            a, b = self.stack.pop(), self.stack.pop()
            self.stack.append(a % b if b != 0 else 0)
            self.pc += 1
        
        # Comparison
        elif op == 0x10:  # LT
            a, b = self.stack.pop(), self.stack.pop()
            self.stack.append(1 if a < b else 0)
            self.pc += 1
        elif op == 0x11:  # GT
            a, b = self.stack.pop(), self.stack.pop()
            self.stack.append(1 if a > b else 0)
            self.pc += 1
        elif op == 0x12:  # SLT
            a, b = self.stack.pop(), self.stack.pop()
            # Signed comparison
            if a >= (1 << 255):
                a -= (1 << 256)
            if b >= (1 << 255):
                b -= (1 << 256)
            self.stack.append(1 if a < b else 0)
            self.pc += 1
        elif op == 0x13:  # SGT
            a, b = self.stack.pop(), self.stack.pop()
            if a >= (1 << 255):
                a -= (1 << 256)
            if b >= (1 << 255):
                b -= (1 << 256)
            self.stack.append(1 if a > b else 0)
            self.pc += 1
        elif op == 0x14:  # EQ
            a, b = self.stack.pop(), self.stack.pop()
            self.stack.append(1 if a == b else 0)
            self.pc += 1
        elif op == 0x15:  # ISZERO
            a = self.stack.pop()
            self.stack.append(1 if a == 0 else 0)
            self.pc += 1
        
        # Bitwise
        elif op == 0x16:  # AND
            a, b = self.stack.pop(), self.stack.pop()
            self.stack.append(a & b)
            self.pc += 1
        elif op == 0x17:  # OR
            a, b = self.stack.pop(), self.stack.pop()
            self.stack.append(a | b)
            self.pc += 1
        elif op == 0x18:  # XOR
            a, b = self.stack.pop(), self.stack.pop()
            self.stack.append(a ^ b)
            self.pc += 1
        elif op == 0x19:  # NOT
            a = self.stack.pop()
            self.stack.append(((1 << 256) - 1) ^ a)
            self.pc += 1
        elif op == 0x1B:  # SHL
            shift, val = self.stack.pop(), self.stack.pop()
            self.stack.append((val << shift) & ((1 << 256) - 1) if shift < 256 else 0)
            self.pc += 1
        elif op == 0x1C:  # SHR
            shift, val = self.stack.pop(), self.stack.pop()
            self.stack.append(val >> shift if shift < 256 else 0)
            self.pc += 1
        
        # Environment
        elif op == 0x34:  # CALLVALUE
            self.stack.append(0)  # No value sent
            self.pc += 1
        elif op == 0x35:  # CALLDATALOAD
            offset = self.stack.pop()
            data = self.calldata[offset:offset+32] if offset < len(self.calldata) else b""
            data = data.ljust(32, b'\x00')
            self.stack.append(int.from_bytes(data, 'big'))
            self.pc += 1
        elif op == 0x36:  # CALLDATASIZE
            self.stack.append(len(self.calldata))
            self.pc += 1
        elif op == 0x37:  # CALLDATACOPY
            mem_off, data_off, size = self.stack.pop(), self.stack.pop(), self.stack.pop()
            data = self.calldata[data_off:data_off+size] if data_off < len(self.calldata) else b""
            data = data.ljust(size, b'\x00')
            self._mem_write(mem_off, data)
            self.pc += 1
        elif op == 0x38:  # CODESIZE
            self.stack.append(len(self.code))
            self.pc += 1
        elif op == 0x39:  # CODECOPY
            mem_off, code_off, size = self.stack.pop(), self.stack.pop(), self.stack.pop()
            code_data = self.code[code_off:code_off+size] if code_off < len(self.code) else b""
            code_data = code_data.ljust(size, b'\x00')
            self._mem_write(mem_off, code_data)
            self.pc += 1
        elif op == 0x30:  # ADDRESS
            self.stack.append(self.address)
            self.pc += 1
        elif op == 0x32:  # ORIGIN
            self.stack.append(self.origin)
            self.pc += 1
        elif op == 0x33:  # CALLER
            self.stack.append(self.caller)
            self.pc += 1
        elif op == 0x20:  # SHA3/KECCAK256
            import hashlib
            offset, size = self.stack.pop(), self.stack.pop()
            data = self._mem_read(offset, size)
            # Use keccak256 (note: Python's hashlib doesn't have keccak, 
            # so we use a mock for tracing purposes)
            result = int.from_bytes(hashlib.sha256(data).digest(), 'big')
            self.stack.append(result)
            self.pc += 1
        elif op == 0x1A:  # BYTE
            i, x = self.stack.pop(), self.stack.pop()
            if i < 32:
                self.stack.append((x >> (248 - i * 8)) & 0xFF)
            else:
                self.stack.append(0)
            self.pc += 1
        elif op == 0x3D:  # RETURNDATASIZE
            self.stack.append(len(self.return_data))
            self.pc += 1
        elif op == 0x3E:  # RETURNDATACOPY
            mem_off, data_off, size = self.stack.pop(), self.stack.pop(), self.stack.pop()
            data = self.return_data[data_off:data_off+size] if data_off < len(self.return_data) else b""
            data = data.ljust(size, b'\x00')
            self._mem_write(mem_off, data)
            self.pc += 1
        
        # Stack/Memory/Storage
        elif op == 0x50:  # POP
            self.stack.pop()
            self.pc += 1
        elif op == 0x51:  # MLOAD
            offset = self.stack.pop()
            data = self._mem_read(offset, 32)
            self.stack.append(int.from_bytes(data, 'big'))
            self.pc += 1
        elif op == 0x52:  # MSTORE
            offset, value = self.stack.pop(), self.stack.pop()
            self._mem_write(offset, value.to_bytes(32, 'big'))
            self.pc += 1
        elif op == 0x53:  # MSTORE8
            offset, value = self.stack.pop(), self.stack.pop()
            self._mem_write(offset, bytes([value & 0xFF]))
            self.pc += 1
        elif op == 0x54:  # SLOAD
            key = self.stack.pop()
            self.stack.append(self.storage.get(key, 0))
            self.pc += 1
        elif op == 0x55:  # SSTORE
            key, value = self.stack.pop(), self.stack.pop()
            self.storage[key] = value
            self.pc += 1
        
        # Control flow
        elif op == 0x56:  # JUMP
            dest = self.stack.pop()
            if dest not in self.jumpdests:
                raise ValueError(f"Invalid jump destination: {dest}")
            self.pc = dest
        elif op == 0x57:  # JUMPI
            dest, cond = self.stack.pop(), self.stack.pop()
            if cond != 0:
                if dest not in self.jumpdests:
                    raise ValueError(f"Invalid jump destination: {dest}")
                self.pc = dest
            else:
                self.pc += 1
        elif op == 0x58:  # PC
            self.stack.append(self.pc)
            self.pc += 1
        elif op == 0x59:  # MSIZE
            self.stack.append(len(self.memory))
            self.pc += 1
        elif op == 0x5A:  # GAS
            self.stack.append(self.gas)
            self.pc += 1
        elif op == 0x5B:  # JUMPDEST
            self.pc += 1
        elif op == 0x5C:  # TLOAD (transient storage load)
            key = self.stack.pop()
            self.stack.append(self.transient_storage.get(key, 0))
            self.pc += 1
        elif op == 0x5D:  # TSTORE (transient storage store)
            key, value = self.stack.pop(), self.stack.pop()
            self.transient_storage[key] = value
            self.pc += 1
        elif op == 0x5E:  # MCOPY
            dest, src, size = self.stack.pop(), self.stack.pop(), self.stack.pop()
            data = self._mem_read(src, size)
            self._mem_write(dest, data)
            self.pc += 1
        
        # PUSH0
        elif op == 0x5F:
            self.stack.append(0)
            self.pc += 1
        
        # PUSH1-PUSH32
        elif 0x60 <= op <= 0x7F:
            size = op - 0x60 + 1
            value = int.from_bytes(self.code[self.pc+1:self.pc+1+size], 'big')
            self.stack.append(value)
            self.pc += 1 + size
        
        # DUP1-DUP16
        elif 0x80 <= op <= 0x8F:
            depth = op - 0x80 + 1
            self.stack.append(self.stack[-depth])
            self.pc += 1
        
        # SWAP1-SWAP16
        elif 0x90 <= op <= 0x9F:
            depth = op - 0x90 + 2
            self.stack[-1], self.stack[-depth] = self.stack[-depth], self.stack[-1]
            self.pc += 1
        
        # RETURN
        elif op == 0xF3:
            offset, size = self.stack.pop(), self.stack.pop()
            self.return_data = bytes(self._mem_read(offset, size))
            self.stopped = True
        
        # REVERT
        elif op == 0xFD:
            offset, size = self.stack.pop(), self.stack.pop()
            self.return_data = bytes(self._mem_read(offset, size))
            self.reverted = True
            self.stopped = True
        
        # INVALID
        elif op == 0xFE:
            raise ValueError("INVALID opcode")
        
        else:
            raise NotImplementedError(f"Opcode 0x{op:02x} ({name}) not implemented")
    
    def run(self) -> Tuple[bool, bytes]:
        """Run until stopped or max steps reached"""
        while self.step():
            pass
        
        if self.step_count >= self.max_steps:
            self._log(f"\n=== MAX STEPS ({self.max_steps}) REACHED - LIKELY INFINITE LOOP ===")
        
        return (not self.reverted, self.return_data)


def main():
    import argparse
    parser = argparse.ArgumentParser(description='EVM Bytecode Tracer')
    parser.add_argument('bytecode_file', nargs='?', help='Path to bytecode file')
    parser.add_argument('calldata', nargs='?', default='', help='Hex-encoded calldata')
    parser.add_argument('--address', type=lambda x: int(x, 16), default=0xDEADBEEF,
                        help='Contract address (hex, default: 0xDEADBEEF)')
    parser.add_argument('--caller', type=lambda x: int(x, 16), default=0xBEEF,
                        help='msg.sender (hex, default: 0xBEEF)')
    parser.add_argument('--origin', type=lambda x: int(x, 16), default=0xCAFE,
                        help='tx.origin (hex, default: 0xCAFE)')
    parser.add_argument('--eoa', action='store_true',
                        help='Simulate EOA call (sets origin=caller)')
    parser.add_argument('--max-steps', type=int, default=500,
                        help='Maximum execution steps (default: 500)')
    args = parser.parse_args()
    
    if not args.bytecode_file:
        # Default: load the LoopCheckCalldata bytecode
        bytecode_file = "output/LoopCheckCalldata_opt_runtime.bin"
        # Calldata for processStructs with 1 element:
        # selector (4 bytes) + offset (32 bytes) + length (32 bytes) + element (64 bytes)
        # Element: id=10, value=100
        selector = bytes.fromhex("e296f284")  # processStructs selector
        offset = (32).to_bytes(32, 'big')  # offset to array
        length = (1).to_bytes(32, 'big')  # 1 element
        elem_id = (10).to_bytes(32, 'big')
        elem_value = (100).to_bytes(32, 'big')
        calldata = selector + offset + length + elem_id + elem_value
    else:
        bytecode_file = args.bytecode_file
        calldata = bytes.fromhex(args.calldata) if args.calldata else b""
    
    # Handle --eoa flag  
    caller = args.caller
    origin = args.origin
    if args.eoa:
        # EOA call: same address for both
        origin = caller
        print(f"EOA mode: caller=origin=0x{caller:x}")
    
    # Load bytecode
    with open(bytecode_file, 'rb') as f:
        content = f.read()
        # Handle hex-encoded files
        try:
            bytecode = bytes.fromhex(content.decode('ascii').strip())
        except:
            bytecode = content
    
    print(f"Loaded {len(bytecode)} bytes of bytecode")
    print(f"Calldata: {len(calldata)} bytes: {calldata.hex() if calldata else 'empty'}")
    print(f"Address: 0x{args.address:x}, Caller: 0x{caller:x}, Origin: 0x{origin:x}")
    print("=" * 80)
    
    tracer = EVMTracer(bytecode, calldata, max_steps=args.max_steps,
                       address=args.address, caller=caller, origin=origin)
    success, return_data = tracer.run()
    
    print("=" * 80)
    print(f"Execution {'SUCCESS' if success else 'REVERTED'}")
    print(f"Steps: {tracer.step_count}")
    print(f"Return data ({len(return_data)} bytes): {return_data.hex() if return_data else 'empty'}")
    
    # Dump final memory state (first 512 bytes)
    print("\nMemory dump (first 256 bytes):")
    for i in range(0, 256, 32):
        chunk = tracer.memory[i:i+32]
        print(f"  {i:04x}: {chunk.hex()}")


if __name__ == "__main__":
    main()
