# @version ^0.4.0
"""
Mega Test - Comprehensive Vyper Contract for IR Research
==========================================================
Mirrors patterns from Solidity test contracts to understand native Venom IR generation.

Patterns Covered:
- OpcodeBasics: sub, div, lt, gt, shl, slt, mul, loops
- MegaTest: enums, structs, mappings, inheritance override, internal calls, events
- StorageMemoryTest: storage read/write, mapping access, memory arrays
- ComplexFeaturesTest: immutables, constants, enums, complex control flow, overrides
- LoopCheck: struct arrays, memory iteration
"""

# ==============================
# ENUMS
# ==============================
flag State:
    IDLE
    ACTIVE
    PAUSED
    STOPPED

# ==============================
# STRUCTS
# ==============================
struct Element:
    id: uint256
    value: uint256

struct Config:
    minVal: uint256
    maxVal: uint256
    admin: address

# ==============================
# IMMUTABLES & CONSTANTS
# ==============================
IMMUTABLE_VAL: public(immutable(uint256))
CONSTANT_VAL: constant(uint256) = 123
MAX_ITERATIONS: constant(uint256) = 100

# ==============================
# STORAGE VARIABLES
# ==============================
counter: public(uint256)
state: public(State)
config: public(Config)
balances: public(HashMap[address, uint256])
vals: public(DynArray[uint256, 100])

# ==============================
# EVENTS
# ==============================
event StateChanged:
    old_state: State
    new_state: State
    changer: address

event BaseLog:
    val: uint256

event LogElement:
    index: uint256
    id: uint256
    value: uint256

event Debug:
    tag: uint256
    val: uint256

# ==============================
# CONSTRUCTOR
# ==============================
@deploy
def __init__(val: uint256):
    IMMUTABLE_VAL = val
    self.state = State.IDLE
    self.counter = 0
    self.config = Config(minVal=10, maxVal=100, admin=msg.sender)

# ==============================
# OPCODE BASICS (Pure Arithmetic)
# ==============================
@external
@pure
def test_sub(a: uint256, b: uint256) -> uint256:
    """SUB opcode - checked subtraction"""
    return a - b

@external
@pure
def test_div(a: uint256, b: uint256) -> uint256:
    """DIV opcode - unsigned division"""
    return a // b

@external
@pure
def test_lt(a: uint256, b: uint256) -> uint256:
    """LT opcode - less than comparison"""
    if a < b:
        return 1
    return 0

@external
@pure
def test_gt(a: uint256, b: uint256) -> uint256:
    """GT opcode - greater than comparison"""
    if a > b:
        return 1
    return 0

@external
@pure
def test_shl(shift_amt: uint256, val: uint256) -> uint256:
    """SHL opcode - left shift"""
    return val << shift_amt

@external
@pure
def test_slt(a: uint256, b: uint256) -> uint256:
    """SLT opcode - signed less than via unsafe cast"""
    # Vyper doesn't have direct signed int256, use convert
    a_signed: int256 = convert(a, int256)
    b_signed: int256 = convert(b, int256)
    if a_signed < b_signed:
        return 1
    return 0

@external
@pure
def test_lt_literal(b: uint256) -> uint256:
    """LT with literal constant"""
    a: uint256 = 10
    if a < b:
        return 1
    return 0

@external
@pure
def test_mul(a: uint256, b: uint256) -> uint256:
    """MUL opcode - checked multiplication"""
    return a * b

@external
@pure
def test_loop_lt(limit: uint256) -> uint256:
    """Loop with LT condition"""
    count: uint256 = 0
    for i: uint256 in range(limit, bound=MAX_ITERATIONS):
        count += 1
    return count

# ==============================
# INTERNAL FUNCTION CALLS
# ==============================
@internal
@pure
def _internal_calc(x: uint256, y: uint256) -> uint256:
    """Internal pure function - will be inlined"""
    return x * y + 1

@external
@pure
def run_calc(a: uint256) -> uint256:
    """External calling internal"""
    return self._internal_calc(a, 10)

@internal
@pure
def _double(x: uint256) -> uint256:
    """Simple double - for inlining test"""
    return x * 2

@internal
def _add_with_mul(a: uint256, b: uint256) -> uint256:
    """Uses immutable - reads deploy-time constant"""
    return (a + b) * IMMUTABLE_VAL

@external
def call_internal(x: uint256) -> uint256:
    """Chain of internal calls"""
    doubled: uint256 = self._double(x)
    return self._add_with_mul(doubled, x)

# ==============================
# STORAGE OPERATIONS
# ==============================
@external
def set_val(val: uint256):
    """Simple storage write"""
    self.counter = val

@external
@view
def get_val() -> uint256:
    """Simple storage read"""
    return self.counter

@external
def increment() -> uint256:
    """Storage read-modify-write"""
    self.counter += 1
    return self.counter

@external
def set_balance(user: address, amount: uint256):
    """Mapping write"""
    self.balances[user] = amount

@external
@view
def get_balance(user: address) -> uint256:
    """Mapping read"""
    return self.balances[user]

# ==============================
# ENUM OPERATIONS
# ==============================
@external
def update_state(new_state: State):
    """Enum assignment with event"""
    assert new_state != State.STOPPED, "Cannot stop"
    old: State = self.state
    self.state = new_state
    log StateChanged(old, new_state, msg.sender)

@external
@view
def is_active() -> bool:
    """Enum comparison"""
    return self.state == State.ACTIVE

# ==============================
# STRUCT OPERATIONS
# ==============================
@external
@view
def check_config(x: uint256) -> bool:
    """Struct field access in condition"""
    return x >= self.config.minVal and x <= self.config.maxVal

@external
def set_config(minVal: uint256, maxVal: uint256):
    """Struct write"""
    self.config.minVal = minVal
    self.config.maxVal = maxVal

# ==============================
# ARRAY OPERATIONS  
# ==============================
@external
def memory_array_sum(arr: DynArray[uint256, 100]) -> uint256:
    """Loop over dynamic array parameter"""
    total: uint256 = 0
    for val: uint256 in arr:
        total += val
    return total

@external
def process_elements(elements: DynArray[Element, 50]) -> DynArray[Element, 50]:
    """Struct array transformation"""
    result: DynArray[Element, 50] = []
    for i: uint256 in range(len(elements), bound=50):
        elem: Element = elements[i]
        log LogElement(i, elem.id, elem.value)
        result.append(Element(id=elem.id, value=elem.value * 2))
    return result

@external
def add_value(val: uint256):
    """Dynamic array append"""
    self.vals.append(val)

@external
@view
def get_values_len() -> uint256:
    """Dynamic array length"""
    return len(self.vals)

# ==============================
# COMPLEX CONTROL FLOW
# ==============================
@external
def complex_flow(x: uint256) -> uint256:
    """Nested if/elif/else with side effects"""
    if x < 10:
        self.counter += 1
        return 1
    elif x < 20:
        self.counter += 2
        return 2
    else:
        if self.state == State.IDLE:
            self.state = State.ACTIVE
        else:
            self.state = State.PAUSED
        return 3

@external
@pure
def nested_loops(n: uint256, m: uint256) -> uint256:
    """Nested loop pattern"""
    total: uint256 = 0
    for i: uint256 in range(n, bound=50):
        for j: uint256 in range(m, bound=50):
            total += i * j
    return total

@external
@pure
def early_return(x: uint256) -> uint256:
    """Multiple return points"""
    if x == 0:
        return 0
    if x == 1:
        return 1
    if x < 10:
        return x * 2
    return x * x

# ==============================
# IMMUTABLES & CONSTANTS
# ==============================
@external
@view
def get_immutable() -> uint256:
    """Immutable read (codecopy pattern)"""
    return IMMUTABLE_VAL

@external
@pure
def get_constant() -> uint256:
    """Constant inline"""
    return CONSTANT_VAL

@external
@view
def get_both() -> (uint256, uint256):
    """Multiple return values"""
    return (IMMUTABLE_VAL, CONSTANT_VAL)

# ==============================
# BITWISE OPERATIONS
# ==============================
@external
@pure
def test_and(a: uint256, b: uint256) -> uint256:
    """AND opcode"""
    return a & b

@external
@pure
def test_or(a: uint256, b: uint256) -> uint256:
    """OR opcode"""
    return a | b

@external
@pure
def test_xor(a: uint256, b: uint256) -> uint256:
    """XOR opcode"""
    return a ^ b

@external
@pure
def test_not(a: uint256) -> uint256:
    """NOT opcode"""
    return ~a

@external
@pure
def test_shr(shift_amt: uint256, val: uint256) -> uint256:
    """SHR opcode - right shift"""
    return val >> shift_amt

# ==============================
# OVERFLOW CHECKS (Checked Math)
# ==============================
@external
@pure
def checked_add(a: uint256, b: uint256) -> uint256:
    """Checked addition - triggers assert on overflow"""
    return a + b

@external
@pure
def checked_sub(a: uint256, b: uint256) -> uint256:
    """Checked subtraction - triggers assert on underflow"""
    return a - b

@external
@pure
def checked_mul(a: uint256, b: uint256) -> uint256:
    """Checked multiplication - triggers assert on overflow"""
    return a * b

# ==============================
# HASH OPERATIONS
# ==============================
@external
@pure
def hash_two(a: uint256, b: uint256) -> bytes32:
    """Keccak256 of two values"""
    return keccak256(concat(convert(a, bytes32), convert(b, bytes32)))

# ==============================
# CALLER/ORIGIN/BLOCK INFO
# ==============================
@external
@view
def get_caller() -> address:
    """CALLER opcode"""
    return msg.sender

@external
@view
def get_block_info() -> (uint256, uint256, bytes32):
    """Block context opcodes"""
    return (block.number, block.timestamp, block.prevrandao)

@external
@view
def get_tx_info() -> (uint256, address):
    """Transaction context"""
    return (tx.gasprice, tx.origin)
