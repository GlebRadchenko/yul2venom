# @version ^0.4.0

# Vyper contract to test nested loops for comparing with Yul transpiled version.
# This mimics the LoopCheckCalldata pattern: memory pre-allocation loop + element processing loop.

struct Element:
    id: uint256
    value: uint256

@external
@pure
def process_elements(input: DynArray[Element, 100]) -> DynArray[Element, 100]:
    """
    Process array of elements - adds 1 to each value.
    This creates a nested loop pattern:
    1. Memory allocation loop (implicit in DynArray creation)
    2. Element processing loop
    """
    output: DynArray[Element, 100] = []
    
    # This creates an inner loop that processes each element
    for i: uint256 in range(len(input), bound=100):
        elem: Element = input[i]
        new_elem: Element = Element(id=elem.id, value=elem.value + 1)
        output.append(new_elem)
    
    return output

@external
@pure
def nested_sum(outer_count: uint256, inner_count: uint256) -> uint256:
    """
    Explicit nested loops - outer variable must survive inner loop.
    This is closer to what the Yul code does.
    """
    total: uint256 = 0
    outer_val: uint256 = 0
    
    for i: uint256 in range(outer_count, bound=10):
        outer_val = i * 10  # This variable is used INSIDE inner loop
        for j: uint256 in range(inner_count, bound=10):
            total += outer_val + j  # Uses BOTH outer_val AND j
    
    return total
