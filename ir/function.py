from __future__ import annotations
import textwrap
from typing import Iterator, Optional, Dict, Any
from .basicblock import IRBasicBlock, IRLabel, IRVariable

class IRFunction:
    def __init__(self, name: IRLabel, ctx: Any = None, num_inputs: int = 0, num_outputs: int = 0):
        self.name = name
        self.ctx = ctx
        self._basic_block_dict: Dict[str, IRBasicBlock] = {}
        self.last_variable = 0
        
        # Function signature for Venom type checker
        self.num_inputs = num_inputs
        self.num_outputs = num_outputs
        
        # No implicit entry block
        # self.append_basic_block(IRBasicBlock(name, self))

    def append_basic_block(self, bb: IRBasicBlock):
        self._basic_block_dict[bb.label.value] = bb

    @property
    def entry(self) -> IRBasicBlock:
        return next(iter(self._basic_block_dict.values()))

    def get_basic_block(self, label: Optional[str] = None) -> IRBasicBlock:
        if label is None:
            return next(reversed(self._basic_block_dict.values()))
        return self._basic_block_dict[label]

    def get_basic_blocks(self) -> Iterator[IRBasicBlock]:
        return iter(self._basic_block_dict.values())

    def get_next_variable(self) -> IRVariable:
        self.last_variable += 1
        return IRVariable(f"%{self.last_variable}")

    def __repr__(self) -> str:
        # Match Venom format: function name { \n ... blocks ... \n }
        ret = f"function {self.name} {{\n"
        for bb in self.get_basic_blocks():
            bb_str = textwrap.indent(str(bb), "  ")
            ret += f"{bb_str}\n"
        ret = ret.strip() + "\n}"
        return ret
