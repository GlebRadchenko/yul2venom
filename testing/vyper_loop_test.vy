# @version ^0.4.0

@external
@view
def sum_array(arr: DynArray[uint256, 100]) -> uint256:
    """Sum elements of array - will have a loop."""
    total: uint256 = 0
    for i: uint256 in range(len(arr), bound=100):
        total += arr[i]
    return total

@external
@pure
def sum_fixed_3() -> uint256:
    """Sum 0+1+2 - loop with len 3."""
    total: uint256 = 0
    for i: uint256 in range(3):
        total += i
    return total

@external
@pure
def sum_fixed_n(n: uint256) -> uint256:
    """Sum 0 to n-1 - loop with variable len."""
    total: uint256 = 0
    for i: uint256 in range(n, bound=100):
        total += i
    return total
