# @version ^0.4.0
"""
Comprehensive Vyper Research Contract
=====================================
Tests various language features for Venom IR analysis:
- Loops (for range with different bounds)
- Immutables  
- Storage variables
- Internal function calls
- Enums
- Events  
- Structs
- Dynamic arrays
- Mappings
"""

# Enum definition
enum State:
    IDLE
    ACTIVE
    PAUSED
    STOPPED

# Struct definition  
struct UserData:
    balance: uint256
    level: uint8
    active: bool

# Immutables (set once in constructor)
MULTIPLIER: public(immutable(uint256))
OWNER: public(immutable(address))

# Storage variables
counter: public(uint256)
state: public(State)
users: public(HashMap[address, UserData])
values: public(DynArray[uint256, 100])

# Constants
MAX_ITERATIONS: constant(uint256) = 50
BASE_VALUE: constant(uint256) = 1000

# Events
event StateChanged:
    new_state: State
    changer: address

event ValueAdded:
    index: uint256
    value: uint256

@deploy
def __init__(multiplier: uint256):
    MULTIPLIER = multiplier
    OWNER = msg.sender
    self.state = State.IDLE
    self.counter = 0

# ===== LOOP PATTERNS =====

@external
def sum_to_n(n: uint256) -> uint256:
    """Fixed-bound loop: sum 0 to n"""
    total: uint256 = 0
    for i: uint256 in range(n, bound=MAX_ITERATIONS):
        total += i
    return total

@external
def sum_range(start: uint256, end: uint256) -> uint256:
    """Variable start/end loop"""
    total: uint256 = 0
    for i: uint256 in range(start, end, bound=MAX_ITERATIONS):
        total += i
    return total

@external
def sum_array(arr: DynArray[uint256, 100]) -> uint256:
    """Loop over dynamic array"""
    total: uint256 = 0
    for val: uint256 in arr:
        total += val
    return total

@external
def factorial(n: uint256) -> uint256:
    """Nested operations in loop"""
    result: uint256 = 1
    for i: uint256 in range(1, n + 1, bound=20):
        result = result * i
    return result

# ===== INTERNAL CALLS =====

@internal
def _double(x: uint256) -> uint256:
    return x * 2

@internal
def _add_with_mul(a: uint256, b: uint256) -> uint256:
    """Internal call that uses immutable"""
    return (a + b) * MULTIPLIER

@external
def call_internal(x: uint256) -> uint256:
    """Chain internal calls"""
    doubled: uint256 = self._double(x)
    return self._add_with_mul(doubled, x)

# ===== STORAGE OPERATIONS =====

@external
def increment() -> uint256:
    self.counter += 1
    return self.counter

@external
def set_user(user: address, balance: uint256, level: uint8):
    """Write to struct in mapping"""
    self.users[user] = UserData(balance=balance, level=level, active=True)

@external
@view
def get_user_balance(user: address) -> uint256:
    """Read from struct in mapping"""
    return self.users[user].balance

@external
def add_value(val: uint256):
    """Append to dynamic array"""
    self.values.append(val)
    log ValueAdded(len(self.values) - 1, val)

# ===== ENUM OPERATIONS =====

@external
def change_state(new_state: State):
    """Enum assignment with event"""
    self.state = new_state
    log StateChanged(new_state, msg.sender)

@external
@view
def is_active() -> bool:
    """Enum comparison"""
    return self.state == State.ACTIVE

# ===== COMPLEX CONTROL FLOW =====

@external
def complex_flow(x: uint256) -> uint256:
    """Switch-like if/elif chain with loop"""
    result: uint256 = 0
    
    if x < 10:
        result = 1
    elif x < 20:
        result = 2
    elif x < 30:
        # Loop inside branch
        for i: uint256 in range(x, bound=30):
            result += i
    else:
        result = x * MULTIPLIER
    
    self.counter += result
    return result

@external
@view  
def get_constants() -> (uint256, uint256):
    """Return multiple values"""
    return (MAX_ITERATIONS, BASE_VALUE)
