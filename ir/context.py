import textwrap
from dataclasses import dataclass, field
from typing import Dict, Optional, Iterator, List, Union
from .function import IRFunction
from .basicblock import IRLabel, IRVariable

@dataclass
class DataItem:
    data: Union[IRLabel, bytes]

    def __str__(self):
        if isinstance(self.data, IRLabel):
            return f"@{self.data}"
        else:
            assert isinstance(self.data, bytes)
            return f'x"{self.data.hex()}"'

@dataclass
class DataSection:
    label: IRLabel
    data_items: List[DataItem] = field(default_factory=list)

    def __str__(self):
        # NOTE: Using raw label string assuming IRLabel.__str__ includes @ or logic handles it.
        # Vyper parser expects "dbsection 100_data:"
        return f"dbsection {self.label}:" + "\n" + "\n".join(f"  db {item}" for item in self.data_items)

class IRContext:
    def __init__(self) -> None:
        self.functions: Dict[str, IRFunction] = {}
        self.entry_function: Optional[IRFunction] = None
        self.last_label = 0
        self.last_variable = 0
        self.data_segment: List[DataSection] = []

    def create_function(self, name: str, num_inputs: int = 0, num_outputs: int = 0) -> IRFunction:
        label = IRLabel(name)
        fn = IRFunction(label, self, num_inputs=num_inputs, num_outputs=num_outputs)
        self.functions[name] = fn
        return fn

    def get_next_label(self, suffix: str = "") -> IRLabel:
        if suffix:
            suffix = f"_{suffix}"
        self.last_label += 1
        return IRLabel(f"{self.last_label}{suffix}")

    def get_next_variable(self) -> IRVariable:
        self.last_variable += 1
        return IRVariable(f"%{self.last_variable}")

    def append_data_section(self, name: IRLabel) -> None:
        self.data_segment.append(DataSection(name))

    def append_data_item(self, data: Union[IRLabel, bytes]) -> None:
        assert len(self.data_segment) > 0
        self.data_segment[-1].data_items.append(DataItem(data))

    def __repr__(self) -> str:
        s = []
        # Print GLOBAL first if exists, then alphabetic others
        if "global" in self.functions:
            s.append(str(self.functions["global"]))
            s.append("\n")
            
        for name in sorted(self.functions.keys()):
            if name == "global": continue
            s.append(str(self.functions[name]))
            s.append("\n")
            
        if self.data_segment:
            s.append("data readonly {")
            for ds in self.data_segment:
                s.append(textwrap.indent(str(ds), "  "))
            s.append("}")
            s.append("\n")

        return "\n".join(s)
