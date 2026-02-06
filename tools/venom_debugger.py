#!/usr/bin/env python3
"""CLI utilities for tracing/disassembling bytecode and inspecting panic paths."""

import sys
import json
import argparse
from typing import Dict, List, Tuple, Any
from dataclasses import dataclass, asdict


VERSION = "1.0.0"

# Panic code definitions
PANIC_CODES = {
    0x01: ("ASSERTION_FAILED", "assert() condition failed"),
    0x11: ("ARITHMETIC_OVERFLOW", "Arithmetic overflow/underflow"),
    0x12: ("DIVISION_BY_ZERO", "Division or modulo by zero"),
    0x21: ("ENUM_OVERFLOW", "Invalid enum conversion"),
    0x22: ("STORAGE_ARRAY", "Incorrect storage byte array encoding"),
    0x31: ("POP_EMPTY_ARRAY", "pop() on empty array"),
    0x32: ("ARRAY_OUT_OF_BOUNDS", "Array index out of bounds"),
    0x41: ("MEMORY_ALLOCATION", "Too much memory allocated"),
    0x51: ("ZERO_INTERNAL_FUNCTION", "Called zero-initialized function pointer"),
}

PANIC_SELECTOR = bytes.fromhex("4e487b71")

# =============================================================================
# EVM Opcodes
# =============================================================================

OPCODES: Dict[int, Tuple[str, int, int]] = {
    0x00: ("STOP", 0, 0), 0x01: ("ADD", 2, 1), 0x02: ("MUL", 2, 1),
    0x03: ("SUB", 2, 1), 0x04: ("DIV", 2, 1), 0x05: ("SDIV", 2, 1),
    0x06: ("MOD", 2, 1), 0x07: ("SMOD", 2, 1), 0x08: ("ADDMOD", 3, 1),
    0x09: ("MULMOD", 3, 1), 0x0A: ("EXP", 2, 1), 0x0B: ("SIGNEXTEND", 2, 1),
    0x10: ("LT", 2, 1), 0x11: ("GT", 2, 1), 0x12: ("SLT", 2, 1),
    0x13: ("SGT", 2, 1), 0x14: ("EQ", 2, 1), 0x15: ("ISZERO", 1, 1),
    0x16: ("AND", 2, 1), 0x17: ("OR", 2, 1), 0x18: ("XOR", 2, 1),
    0x19: ("NOT", 1, 1), 0x1A: ("BYTE", 2, 1), 0x1B: ("SHL", 2, 1),
    0x1C: ("SHR", 2, 1), 0x1D: ("SAR", 2, 1), 0x20: ("SHA3", 2, 1),
    0x30: ("ADDRESS", 0, 1), 0x31: ("BALANCE", 1, 1), 0x32: ("ORIGIN", 0, 1),
    0x33: ("CALLER", 0, 1), 0x34: ("CALLVALUE", 0, 1),
    0x35: ("CALLDATALOAD", 1, 1), 0x36: ("CALLDATASIZE", 0, 1),
    0x37: ("CALLDATACOPY", 3, 0), 0x38: ("CODESIZE", 0, 1),
    0x39: ("CODECOPY", 3, 0), 0x3A: ("GASPRICE", 0, 1),
    0x3B: ("EXTCODESIZE", 1, 1), 0x3C: ("EXTCODECOPY", 4, 0),
    0x3D: ("RETURNDATASIZE", 0, 1), 0x3E: ("RETURNDATACOPY", 3, 0),
    0x3F: ("EXTCODEHASH", 1, 1), 0x40: ("BLOCKHASH", 1, 1),
    0x41: ("COINBASE", 0, 1), 0x42: ("TIMESTAMP", 0, 1),
    0x43: ("NUMBER", 0, 1), 0x44: ("DIFFICULTY", 0, 1),
    0x45: ("GASLIMIT", 0, 1), 0x46: ("CHAINID", 0, 1),
    0x47: ("SELFBALANCE", 0, 1), 0x48: ("BASEFEE", 0, 1),
    0x50: ("POP", 1, 0), 0x51: ("MLOAD", 1, 1), 0x52: ("MSTORE", 2, 0),
    0x53: ("MSTORE8", 2, 0), 0x54: ("SLOAD", 1, 1), 0x55: ("SSTORE", 2, 0),
    0x56: ("JUMP", 1, 0), 0x57: ("JUMPI", 2, 0), 0x58: ("PC", 0, 1),
    0x59: ("MSIZE", 0, 1), 0x5A: ("GAS", 0, 1), 0x5B: ("JUMPDEST", 0, 0),
    0x5C: ("TLOAD", 1, 1), 0x5D: ("TSTORE", 2, 0), 0x5E: ("MCOPY", 3, 0),
    0x5F: ("PUSH0", 0, 1),
    0xF3: ("RETURN", 2, 0), 0xFD: ("REVERT", 2, 0),
    0xFE: ("INVALID", 0, 0), 0xFF: ("SELFDESTRUCT", 1, 0),
}

# Add PUSH1-PUSH32, DUP1-DUP16, SWAP1-SWAP16, LOG0-LOG4
for i in range(1, 33):
    OPCODES[0x60 + i - 1] = (f"PUSH{i}", 0, 1)
for i in range(16):
    OPCODES[0x80 + i] = (f"DUP{i+1}", 0, 1)
    OPCODES[0x90 + i] = (f"SWAP{i+1}", 0, 0)
for i in range(5):
    OPCODES[0xA0 + i] = (f"LOG{i}", 2 + i, 0)


# =============================================================================
# Data Classes
# =============================================================================

@dataclass
class TraceStep:
    """Single step in execution trace"""
    step: int
    pc: int
    opcode: str
    stack_depth: int
    stack_top: List[str]  # Top 5 as hex strings
    
    def to_dict(self) -> dict:
        return asdict(self)


@dataclass
class PanicInfo:
    """Information about a detected panic"""
    detected: bool
    panic_type: str
    panic_code: int
    panic_name: str
    description: str
    pc: int
    step: int
    stack_at_panic: List[str]
    likely_causes: List[str]
    
    def to_dict(self) -> dict:
        return asdict(self)


@dataclass
class MemoryAnalysis:
    """Memory state analysis"""
    step: int
    pc: int
    free_pointer: int
    stack_depth: int
    arrays_found: List[Dict]
    
    def to_dict(self) -> dict:
        return asdict(self)


# =============================================================================
# EVM Tracer Core
# =============================================================================

class EVMTracer:
    """Minimal EVM execution tracer"""
    
    def __init__(self, bytecode: bytes, calldata: bytes = b"", max_steps: int = 10000):
        self.code = bytecode
        self.calldata = calldata
        self.max_steps = max_steps
        
        # State
        self.pc = 0
        self.stack: List[int] = []
        self.memory: bytearray = bytearray(1024 * 1024)
        self.storage: Dict[int, int] = {}
        self.transient_storage: Dict[int, int] = {}
        self.gas = 10_000_000
        self.stopped = False
        self.reverted = False
        self.return_data = b""
        
        # Tracing
        self.step_count = 0
        self.trace: List[TraceStep] = []
        self.jumpdests = self._find_jumpdests()
        self.last_mstores: List[Tuple[int, int]] = []
        
    def _find_jumpdests(self) -> set:
        dests = set()
        pc = 0
        while pc < len(self.code):
            op = self.code[pc]
            if op == 0x5B:
                dests.add(pc)
            if 0x60 <= op <= 0x7F:
                pc += (op - 0x60 + 2)
            else:
                pc += 1
        return dests
    
    def _stack_top(self, n: int = 5) -> List[str]:
        if not self.stack:
            return []
        top = self.stack[-n:] if len(self.stack) >= n else self.stack
        return [f"0x{v:x}" for v in reversed(top)]
    
    def _mem_read(self, offset: int, size: int) -> bytes:
        if offset + size > len(self.memory):
            self.memory.extend(bytearray(offset + size - len(self.memory) + 1024))
        return bytes(self.memory[offset:offset+size])
    
    def _mem_write(self, offset: int, data: bytes):
        if offset + len(data) > len(self.memory):
            self.memory.extend(bytearray(offset + len(data) - len(self.memory) + 1024))
        self.memory[offset:offset+len(data)] = data
    
    def step(self, record: bool = True) -> bool:
        """Execute one instruction. Returns False if stopped."""
        if self.pc >= len(self.code) or self.stopped:
            return False
        
        pc_before = self.pc
        op = self.code[self.pc]
        name = OPCODES.get(op, ("UNKNOWN", 0, 0))[0]
        
        if record:
            self.trace.append(TraceStep(
                step=self.step_count,
                pc=pc_before,
                opcode=name,
                stack_depth=len(self.stack),
                stack_top=self._stack_top(5)
            ))
        
        # Track MSTORE for panic detection
        if op == 0x52 and len(self.stack) >= 2:
            self.last_mstores.append((self.stack[-1], self.stack[-2]))
            if len(self.last_mstores) > 5:
                self.last_mstores.pop(0)
        
        try:
            self._execute(op, name)
        except Exception as e:
            self.stopped = True
            return False
        
        self.step_count += 1
        return not self.stopped and self.step_count < self.max_steps
    
    def _execute(self, op: int, name: str):
        """Execute a single opcode"""
        MASK256 = (1 << 256) - 1
        
        if op == 0x00:  # STOP
            self.stopped = True
        elif op == 0x01:  # ADD
            self.stack.append((self.stack.pop() + self.stack.pop()) & MASK256)
            self.pc += 1
        elif op == 0x02:  # MUL
            self.stack.append((self.stack.pop() * self.stack.pop()) & MASK256)
            self.pc += 1
        elif op == 0x03:  # SUB
            self.stack.append((self.stack.pop() - self.stack.pop()) & MASK256)
            self.pc += 1
        elif op == 0x04:  # DIV
            a, b = self.stack.pop(), self.stack.pop()
            self.stack.append(a // b if b != 0 else 0)
            self.pc += 1
        elif op == 0x06:  # MOD
            a, b = self.stack.pop(), self.stack.pop()
            self.stack.append(a % b if b != 0 else 0)
            self.pc += 1
        elif op == 0x10:  # LT
            self.stack.append(1 if self.stack.pop() < self.stack.pop() else 0)
            self.pc += 1
        elif op == 0x11:  # GT
            self.stack.append(1 if self.stack.pop() > self.stack.pop() else 0)
            self.pc += 1
        elif op == 0x14:  # EQ
            self.stack.append(1 if self.stack.pop() == self.stack.pop() else 0)
            self.pc += 1
        elif op == 0x15:  # ISZERO
            self.stack.append(1 if self.stack.pop() == 0 else 0)
            self.pc += 1
        elif op == 0x16:  # AND
            self.stack.append(self.stack.pop() & self.stack.pop())
            self.pc += 1
        elif op == 0x17:  # OR
            self.stack.append(self.stack.pop() | self.stack.pop())
            self.pc += 1
        elif op == 0x18:  # XOR
            self.stack.append(self.stack.pop() ^ self.stack.pop())
            self.pc += 1
        elif op == 0x19:  # NOT
            self.stack.append(MASK256 ^ self.stack.pop())
            self.pc += 1
        elif op == 0x1A:  # BYTE
            i, x = self.stack.pop(), self.stack.pop()
            self.stack.append((x >> (248 - i * 8)) & 0xFF if i < 32 else 0)
            self.pc += 1
        elif op == 0x1B:  # SHL
            shift, val = self.stack.pop(), self.stack.pop()
            self.stack.append((val << shift) & MASK256 if shift < 256 else 0)
            self.pc += 1
        elif op == 0x1C:  # SHR
            shift, val = self.stack.pop(), self.stack.pop()
            self.stack.append(val >> shift if shift < 256 else 0)
            self.pc += 1
        elif op == 0x20:  # SHA3
            offset, size = self.stack.pop(), self.stack.pop()
            data = self._mem_read(offset, size)
            import hashlib
            self.stack.append(int.from_bytes(hashlib.sha256(data).digest(), 'big'))
            self.pc += 1
        elif op == 0x30:  # ADDRESS
            self.stack.append(0xDEADBEEF)
            self.pc += 1
        elif op == 0x32:  # ORIGIN
            self.stack.append(0xCAFE)
            self.pc += 1
        elif op == 0x33:  # CALLER
            self.stack.append(0xBEEF)
            self.pc += 1
        elif op == 0x34:  # CALLVALUE
            self.stack.append(0)
            self.pc += 1
        elif op == 0x35:  # CALLDATALOAD
            offset = self.stack.pop()
            data = self.calldata[offset:offset+32] if offset < len(self.calldata) else b""
            self.stack.append(int.from_bytes(data.ljust(32, b'\x00'), 'big'))
            self.pc += 1
        elif op == 0x36:  # CALLDATASIZE
            self.stack.append(len(self.calldata))
            self.pc += 1
        elif op == 0x37:  # CALLDATACOPY
            mem_off, data_off, size = self.stack.pop(), self.stack.pop(), self.stack.pop()
            data = self.calldata[data_off:data_off+size] if data_off < len(self.calldata) else b""
            self._mem_write(mem_off, data.ljust(size, b'\x00'))
            self.pc += 1
        elif op == 0x38:  # CODESIZE
            self.stack.append(len(self.code))
            self.pc += 1
        elif op == 0x39:  # CODECOPY
            mem_off, code_off, size = self.stack.pop(), self.stack.pop(), self.stack.pop()
            code_data = self.code[code_off:code_off+size] if code_off < len(self.code) else b""
            self._mem_write(mem_off, code_data.ljust(size, b'\x00'))
            self.pc += 1
        elif op == 0x3D:  # RETURNDATASIZE
            self.stack.append(len(self.return_data))
            self.pc += 1
        elif op == 0x3E:  # RETURNDATACOPY
            mem_off, data_off, size = self.stack.pop(), self.stack.pop(), self.stack.pop()
            data = self.return_data[data_off:data_off+size] if data_off < len(self.return_data) else b""
            self._mem_write(mem_off, data.ljust(size, b'\x00'))
            self.pc += 1
        elif op == 0x50:  # POP
            self.stack.pop()
            self.pc += 1
        elif op == 0x51:  # MLOAD
            offset = self.stack.pop()
            self.stack.append(int.from_bytes(self._mem_read(offset, 32), 'big'))
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
            self.stack.append(self.storage.get(self.stack.pop(), 0))
            self.pc += 1
        elif op == 0x55:  # SSTORE
            key, value = self.stack.pop(), self.stack.pop()
            self.storage[key] = value
            self.pc += 1
        elif op == 0x56:  # JUMP
            dest = self.stack.pop()
            if dest not in self.jumpdests:
                raise ValueError(f"Invalid jump: {dest}")
            self.pc = dest
        elif op == 0x57:  # JUMPI
            dest, cond = self.stack.pop(), self.stack.pop()
            if cond != 0:
                if dest not in self.jumpdests:
                    raise ValueError(f"Invalid jump: {dest}")
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
        elif op == 0x5C:  # TLOAD
            self.stack.append(self.transient_storage.get(self.stack.pop(), 0))
            self.pc += 1
        elif op == 0x5D:  # TSTORE
            key, value = self.stack.pop(), self.stack.pop()
            self.transient_storage[key] = value
            self.pc += 1
        elif op == 0x5E:  # MCOPY
            dest, src, size = self.stack.pop(), self.stack.pop(), self.stack.pop()
            self._mem_write(dest, self._mem_read(src, size))
            self.pc += 1
        elif op == 0x5F:  # PUSH0
            self.stack.append(0)
            self.pc += 1
        elif 0x60 <= op <= 0x7F:  # PUSH1-PUSH32
            size = op - 0x60 + 1
            self.stack.append(int.from_bytes(self.code[self.pc+1:self.pc+1+size], 'big'))
            self.pc += 1 + size
        elif 0x80 <= op <= 0x8F:  # DUP1-DUP16
            self.stack.append(self.stack[-(op - 0x80 + 1)])
            self.pc += 1
        elif 0x90 <= op <= 0x9F:  # SWAP1-SWAP16
            depth = op - 0x90 + 2
            self.stack[-1], self.stack[-depth] = self.stack[-depth], self.stack[-1]
            self.pc += 1
        elif 0xA0 <= op <= 0xA4:  # LOG0-LOG4
            offset, size = self.stack.pop(), self.stack.pop()
            for _ in range(op - 0xA0):
                self.stack.pop()  # Pop topics
            self.pc += 1
        elif op == 0xF3:  # RETURN
            offset, size = self.stack.pop(), self.stack.pop()
            self.return_data = bytes(self._mem_read(offset, size))
            self.stopped = True
        elif op == 0xFD:  # REVERT
            offset, size = self.stack.pop(), self.stack.pop()
            self.return_data = bytes(self._mem_read(offset, size))
            self.reverted = True
            self.stopped = True
        elif op == 0xFE:  # INVALID
            raise ValueError("INVALID opcode")
        else:
            raise NotImplementedError(f"Opcode 0x{op:02x} ({name})")
    
    def run(self) -> Tuple[bool, bytes]:
        """Run until stopped or max steps"""
        while self.step():
            pass
        return (not self.reverted, self.return_data)
    
    def get_free_pointer(self) -> int:
        """Get current Solidity free memory pointer (0x40)"""
        if len(self.memory) >= 0x60:
            return int.from_bytes(self.memory[0x40:0x60], 'big')
        return 0


# =============================================================================
# Analysis Functions
# =============================================================================

def detect_panic(bytecode: bytes, calldata: bytes, max_steps: int = 10000) -> PanicInfo:
    """Detect and analyze panic in bytecode execution"""
    tracer = EVMTracer(bytecode, calldata, max_steps)
    
    while not tracer.stopped and tracer.step_count < max_steps:
        pc = tracer.pc
        if pc >= len(tracer.code):
            break
        
        op = tracer.code[pc]
        
        # Detect REVERT with panic signature
        if op == 0xFD and len(tracer.stack) >= 2:
            offset, size = tracer.stack[-1], tracer.stack[-2]
            if size >= 36:
                revert_data = bytes(tracer._mem_read(offset, min(size, 256)))
                if len(revert_data) >= 4 and revert_data[:4] == PANIC_SELECTOR:
                    code = int.from_bytes(revert_data[4:36], 'big') if len(revert_data) >= 36 else 0
                    info = PANIC_CODES.get(code, ("UNKNOWN", "Unknown panic code"))
                    
                    causes = []
                    if code == 0x32:
                        causes = [
                            "Array index >= array.length",
                            "Accessing empty array (length=0)",
                            "Array length corrupted in memory",
                            "Incorrect calldata parsing affecting array size"
                        ]
                    elif code == 0x11:
                        causes = [
                            "Integer overflow in addition/multiplication",
                            "Integer underflow in subtraction",
                            "Unchecked block not used where expected"
                        ]
                    
                    return PanicInfo(
                        detected=True,
                        panic_type=info[0],
                        panic_code=code,
                        panic_name=f"Panic(0x{code:02x})",
                        description=info[1],
                        pc=pc,
                        step=tracer.step_count,
                        stack_at_panic=[f"0x{v:x}" for v in tracer.stack[-8:]],
                        likely_causes=causes
                    )
        
        try:
            tracer._execute(op, OPCODES.get(op, ("UNKNOWN", 0, 0))[0])
        except:
            break
        tracer.step_count += 1
    
    return PanicInfo(
        detected=False, panic_type="NONE", panic_code=0,
        panic_name="", description="No panic detected",
        pc=tracer.pc, step=tracer.step_count,
        stack_at_panic=[], likely_causes=[]
    )


def disassemble(bytecode: bytes, limit: int = None) -> List[str]:
    """Disassemble EVM bytecode"""
    pc, output, count = 0, [], 0
    
    while pc < len(bytecode):
        if limit and count >= limit:
            output.append(f"... (truncated at {limit})")
            break
        
        op = bytecode[pc]
        name = OPCODES.get(op, (f"UNKNOWN(0x{op:02x})", 0, 0))[0]
        
        if 0x60 <= op <= 0x7F:
            push_len = op - 0x5F
            data = bytecode[pc+1:pc+1+push_len]
            output.append(f"{pc:04x}: {name} 0x{data.hex()}")
            pc += 1 + push_len
        else:
            output.append(f"{pc:04x}: {name}")
            pc += 1
        count += 1
    
    return output


def analyze_memory(bytecode: bytes, calldata: bytes, target_step: int) -> MemoryAnalysis:
    """Analyze memory state at specific step"""
    tracer = EVMTracer(bytecode, calldata, target_step + 100)
    
    while not tracer.stopped and tracer.step_count < target_step:
        try:
            tracer.step(record=False)
        except:
            break
    
    # Find potential arrays
    fp = tracer.get_free_pointer()
    arrays = []
    if fp > 0x80 and fp < len(tracer.memory):
        for offset in range(0x80, min(fp, len(tracer.memory) - 32), 32):
            length = int.from_bytes(tracer.memory[offset:offset+32], 'big')
            if 0 < length < 100:
                arrays.append({"offset": f"0x{offset:x}", "length": length})
    
    return MemoryAnalysis(
        step=tracer.step_count,
        pc=tracer.pc,
        free_pointer=fp,
        stack_depth=len(tracer.stack),
        arrays_found=arrays
    )


def calculate_struct_layout(num_elements: int, fmp_init: int = 0x100) -> Dict:
    """Calculate memory layout for struct array allocation"""
    array_base = fmp_init
    ptr_array_size = 32 + num_elements * 32
    ptr_array_size_aligned = (ptr_array_size + 31) & ~31
    
    fmp = fmp_init + ptr_array_size_aligned
    struct_addrs = []
    
    for i in range(num_elements):
        struct_addrs.append(fmp)
        fmp += 64  # 64 bytes per struct
    
    return {
        "initial_fmp": f"0x{fmp_init:x}",
        "array_base": f"0x{array_base:x}",
        "pointer_array_size": ptr_array_size_aligned,
        "struct_addresses": [f"0x{a:x}" for a in struct_addrs],
        "final_fmp": f"0x{fmp:x}"
    }


# =============================================================================
# Utility Functions
# =============================================================================

def load_bytecode(path: str) -> bytes:
    """Load bytecode from file (handles hex and binary)"""
    with open(path, 'rb') as f:
        content = f.read()
    try:
        return bytes.fromhex(content.decode('ascii').strip())
    except:
        return content


def format_output(data: Any, as_json: bool) -> str:
    """Format output for human or machine consumption"""
    if as_json:
        if hasattr(data, 'to_dict'):
            return json.dumps(data.to_dict(), indent=2)
        return json.dumps(data, indent=2)
    return str(data)


# =============================================================================
# Command Handlers
# =============================================================================

def cmd_trace(args):
    """Trace bytecode execution"""
    bytecode = load_bytecode(args.bytecode)
    calldata = bytes.fromhex(args.calldata) if args.calldata else b""
    
    tracer = EVMTracer(bytecode, calldata, args.max_steps)
    success, return_data = tracer.run()
    
    if args.json:
        result = {
            "success": success,
            "steps": tracer.step_count,
            "return_data": return_data.hex() if return_data else "",
            "final_pc": tracer.pc,
            "trace": [s.to_dict() for s in tracer.trace[-20:]] if args.verbose else []
        }
        print(json.dumps(result, indent=2))
    else:
        print(f"Tracing {len(bytecode)} bytes with {len(calldata)} bytes calldata")
        print("=" * 60)
        
        if args.verbose:
            for step in tracer.trace[-50:]:
                print(f"[{step.step:5d}] PC={step.pc:04x} {step.opcode:12s} stack={step.stack_top}")
        
        print("=" * 60)
        print(f"Execution: {'SUCCESS' if success else 'REVERTED'}")
        print(f"Steps: {tracer.step_count}")
        print(f"Return: {return_data.hex()[:64]}..." if len(return_data) > 32 else f"Return: {return_data.hex()}")


def cmd_panic(args):
    """Detect and analyze panic"""
    bytecode = load_bytecode(args.bytecode)
    calldata = bytes.fromhex(args.calldata) if args.calldata else b""
    
    panic = detect_panic(bytecode, calldata, args.max_steps)
    
    if args.json:
        print(json.dumps(panic.to_dict(), indent=2))
        return 2 if panic.detected else 0
    
    if panic.detected:
        print("=" * 60)
        print(f"PANIC DETECTED: {panic.panic_name}")
        print("=" * 60)
        print(f"Type:        {panic.panic_type}")
        print(f"Description: {panic.description}")
        print(f"PC:          0x{panic.pc:04x}")
        print(f"Step:        {panic.step}")
        print()
        print("Stack at panic:")
        for i, v in enumerate(panic.stack_at_panic):
            print(f"  [{i}] {v}")
        print()
        print("Likely causes:")
        for cause in panic.likely_causes:
            print(f"  • {cause}")
        return 2
    else:
        print("No panic detected")
        return 0


def cmd_disasm(args):
    """Disassemble bytecode"""
    bytecode = load_bytecode(args.bytecode)
    lines = disassemble(bytecode, args.limit)
    
    if args.json:
        print(json.dumps({"instructions": lines}, indent=2))
    else:
        print(f"Disassembling {len(bytecode)} bytes")
        print("-" * 50)
        for line in lines:
            print(line)


def cmd_memory(args):
    """Analyze memory at step"""
    bytecode = load_bytecode(args.bytecode)
    calldata = bytes.fromhex(args.calldata) if args.calldata else b""
    
    analysis = analyze_memory(bytecode, calldata, args.step)
    
    if args.json:
        print(json.dumps(analysis.to_dict(), indent=2))
    else:
        print(f"Memory Analysis at step {analysis.step}")
        print("=" * 50)
        print(f"PC:           0x{analysis.pc:04x}")
        print(f"Free pointer: 0x{analysis.free_pointer:x}")
        print(f"Stack depth:  {analysis.stack_depth}")
        if analysis.arrays_found:
            print(f"Arrays found:")
            for arr in analysis.arrays_found:
                print(f"  - offset={arr['offset']}, length={arr['length']}")


def cmd_layout(args):
    """Calculate memory layout"""
    layout = calculate_struct_layout(args.elements, args.fmp)
    
    if args.json:
        print(json.dumps(layout, indent=2))
    else:
        print(f"Memory Layout for {args.elements} element struct array")
        print("=" * 50)
        print(f"Initial FMP:      {layout['initial_fmp']}")
        print(f"Array base:       {layout['array_base']}")
        print(f"Ptr array size:   {layout['pointer_array_size']} bytes")
        print(f"Struct addresses: {', '.join(layout['struct_addresses'])}")
        print(f"Final FMP:        {layout['final_fmp']}")


# =============================================================================
# Main Entry Point
# =============================================================================

def main():
    parser = argparse.ArgumentParser(
        description="Venom Debugger - Production-Grade Debugging Toolkit",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s trace bytecode.bin deadbeef --max-steps 500
  %(prog)s panic bytecode.bin calldata --json
  %(prog)s disasm bytecode.bin --limit 100
  %(prog)s memory bytecode.bin calldata --step 50
  %(prog)s layout 3 --fmp 256
        """
    )
    parser.add_argument("--version", action="version", version=f"%(prog)s {VERSION}")
    parser.add_argument("--json", action="store_true", help="Output as JSON (for AI agents)")
    
    subparsers = parser.add_subparsers(dest="command", required=True)
    
    # trace
    p = subparsers.add_parser("trace", help="Trace bytecode execution")
    p.add_argument("bytecode", help="Bytecode file")
    p.add_argument("calldata", nargs="?", default="", help="Calldata hex")
    p.add_argument("--max-steps", type=int, default=500)
    p.add_argument("-v", "--verbose", action="store_true")
    p.set_defaults(func=cmd_trace)
    
    # panic
    p = subparsers.add_parser("panic", help="Detect and analyze panic")
    p.add_argument("bytecode", help="Bytecode file")
    p.add_argument("calldata", nargs="?", default="", help="Calldata hex")
    p.add_argument("--max-steps", type=int, default=10000)
    p.set_defaults(func=cmd_panic)
    
    # disasm
    p = subparsers.add_parser("disasm", help="Disassemble bytecode")
    p.add_argument("bytecode", help="Bytecode file")
    p.add_argument("--limit", "-l", type=int, help="Limit instructions")
    p.set_defaults(func=cmd_disasm)
    
    # memory
    p = subparsers.add_parser("memory", help="Analyze memory at step")
    p.add_argument("bytecode", help="Bytecode file")
    p.add_argument("calldata", nargs="?", default="", help="Calldata hex")
    p.add_argument("--step", type=int, default=100)
    p.set_defaults(func=cmd_memory)
    
    # layout
    p = subparsers.add_parser("layout", help="Calculate struct array memory layout")
    p.add_argument("elements", type=int, help="Number of elements")
    p.add_argument("--fmp", type=int, default=0x100, help="Initial free memory pointer")
    p.set_defaults(func=cmd_layout)
    
    args = parser.parse_args()
    
    try:
        result = args.func(args)
        sys.exit(result if isinstance(result, int) else 0)
    except FileNotFoundError as e:
        print(f"Error: File not found: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
