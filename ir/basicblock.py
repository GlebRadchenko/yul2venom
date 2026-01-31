from __future__ import annotations
import json
import re
from typing import Any, Iterator, Optional, Sequence, Union, List

# Minimal shims to replace vyper dependencies
class CompilerPanic(Exception): pass

# Constants
BB_TERMINATORS = frozenset(["jmp", "djmp", "jnz", "ret", "return", "revert", "stop", "sink"])
NO_OUTPUT_INSTRUCTIONS = frozenset([
    "mstore", "sstore", "istore", "tstore", "dloadbytes",
    "calldatacopy", "mcopy", "returndatacopy", "codecopy", "extcodecopy",
    "return", "ret", "sink", "revert", "assert", "assert_unreachable",
    "selfdestruct", "stop", "invalid", "jmp", "djmp", "jnz", "log", "nop",
    "log0", "log1", "log2", "log3", "log4", "invoke", "pop", "mstore8",  # invoke has multi-return handled specially
])

class IROperand:
    """
    Base class for all IR operands.
    
    Operands can be literals, variables, or labels used in IR instructions.
    """
    def __init__(self, value: Any) -> None:
        self.value = value

    @property
    def name(self) -> str:
        return str(self.value)

    def __repr__(self) -> str:
        return str(self.value)

    def __eq__(self, other):
        return isinstance(other, IROperand) and self.value == other.value

    def __hash__(self):
        return hash(self.value)

class IRLiteral(IROperand):
    """
    Literal constant value in IR.
    
    Can represent integers or string constants. Integers are displayed
    in hex for large values (>=1024) for readability.
    """
    def __init__(self, value: Union[int, str]) -> None:
        super().__init__(value)

    def __repr__(self) -> str:
        if isinstance(self.value, str):
            return f'"{self.value}"'
        if abs(self.value) < 1024:
            return str(self.value)
        return f"0x{self.value:x}"

class IRVariable(IROperand):
    """
    SSA variable in IR.
    
    Variables are prefixed with '%' and represent values produced by instructions.
    Names are sanitized to remove special characters.
    """
    def __init__(self, name: str) -> None:
        # Strip ALL quotes and sanitize name BEFORE storing
        name = str(name).replace('"', '').replace("'", "").replace(':', '_').replace('.', '_')
        if not name.startswith("%"):
            name = f"%{name}"
        super().__init__(name)

    @property
    def plain_name(self) -> str:
        return self.value.strip("%")
    
    def __repr__(self) -> str:
        return str(self.value)

class IRLabel(IROperand):
    """
    Label for basic blocks and jump targets.
    
    Labels are identifiers that name basic blocks and can be targets
    of control flow instructions (jmp, jnz, djmp).
    """
    _IS_IDENTIFIER = re.compile("[0-9a-zA-Z_]*")

    def __repr__(self):
        if self._IS_IDENTIFIER.fullmatch(self.value):
            return self.value
        return json.dumps(self.value)

class IRInstruction:
    """
    Single instruction in the IR.
    
    An instruction has an opcode, operands, optional outputs, and optional annotation.
    Instructions may be terminators (jmp, ret, etc.) that end basic blocks.
    """
    def __init__(self, opcode: str, operands: List[IROperand], outputs: Optional[List[IRVariable]] = None, annotation: str = None):
        self.opcode = opcode
        self.operands = list(operands)
        self._outputs = list(outputs) if outputs else []
        self.annotation = annotation
        self.parent = None

    @property
    def is_bb_terminator(self) -> bool:
        return self.opcode in BB_TERMINATORS

    @property
    def has_outputs(self) -> bool:
        return len(self._outputs) > 0

    def get_outputs(self) -> List[IRVariable]:
        return list(self._outputs)
        
    def get_label_operands(self) -> Iterator[IRLabel]:
        return (op for op in self.operands if isinstance(op, IRLabel))

    def __repr__(self) -> str:
        s = ""
        if len(self._outputs) > 0:
            s += f"{', '.join(map(str, self._outputs))} = "
        
        opcode_str = f"{self.opcode} " if self.opcode != "assign" else ""
        s += opcode_str
        
        # Venom convention: jmp/call args not reversed, others reversed
        ops = self.operands
        if self.opcode == "invoke":
             # invoke label, arg1, arg2 -> label is first, args reversed
             # Keep invoke reversal if it's a calling convention
             ops = [ops[0]] + list(reversed(ops[1:]))
        # elif self.opcode not in ("jmp", "jnz", "djmp", "phi"):
        #      ops = reversed(ops)

        s += ", ".join([(f"@{op}" if isinstance(op, IRLabel) else str(op)) for op in ops])

        if self.annotation:
            s = f"{s: <30} ; {self.annotation}"
        return f"{s: <30}"

class IRBasicBlock:
    """
    Basic block containing a sequence of instructions.
    
    A basic block is a sequence of instructions with:
    - Single entry point (the label)
    - Single exit point (the terminator instruction)
    - No internal control flow
    """
    def __init__(self, label: IRLabel, parent: Any) -> None:
        self.label = label
        self.parent = parent
        self.instructions = []

    @property
    def is_terminated(self) -> bool:
        if not self.instructions: return False
        return self.instructions[-1].is_bb_terminator

    def append_instruction(self, opcode: str, *args, ret: Optional[IRVariable] = None, annotation: str = None):
        # Wrap int -> IRLiteral, handle YulLiteral
        processed_args = []
        for a in args:
            if isinstance(a, int): 
                processed_args.append(IRLiteral(a))
            elif isinstance(a, IROperand): 
                processed_args.append(a)
            elif hasattr(a, 'value') and hasattr(a, '__class__') and 'YulLiteral' in a.__class__.__name__:
                # YulLiteral with string value - convert to hex bytes (left-aligned, 32-byte padded)
                val = a.value
                if isinstance(val, str) and val.startswith('"') and val.endswith('"'):
                    inner = val.strip('"')
                    inner_bytes = inner.encode('utf-8')[:32]  # Max 32 bytes
                    hex_val = int.from_bytes(inner_bytes.ljust(32, b'\x00'), 'big')
                    processed_args.append(IRLiteral(hex_val))
                else:
                    # Try to convert to int
                    try:
                        processed_args.append(IRLiteral(int(val)))
                    except (ValueError, TypeError):
                        processed_args.append(IRLiteral(0))
            else: 
                try:
                    processed_args.append(IRLiteral(int(a)))  # Fallback
                except (ValueError, TypeError):
                    processed_args.append(IRLiteral(0))

        outputs = [ret] if ret else []
        if ret is None and opcode not in NO_OUTPUT_INSTRUCTIONS:
             # Auto-alloc output
             ret = self.parent.get_next_variable()
             outputs = [ret]

        inst = IRInstruction(opcode, processed_args, outputs, annotation)
        inst.parent = self
        self.instructions.append(inst)
        return ret

    def append_instruction1(self, opcode: str, *args, ret: Optional[IRVariable] = None, **kwargs):
        # Same as append_instruction
        return self.append_instruction(opcode, *args, ret=ret, **kwargs)
        
    def insert_instruction(self, inst: IRInstruction, index: int):
        inst.parent = self
        self.instructions.insert(index, inst)

    def __repr__(self) -> str:
        s = f"{repr(self.label)}:\n"
        for inst in self.instructions:
            s += f"    {str(inst).strip()}\n"
        return s
