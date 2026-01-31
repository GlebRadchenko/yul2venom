# pragma version ^0.4.0

struct Element:
    id: uint256
    value: uint256

@external
@pure
def process_array(data: DynArray[Element, 10]) -> DynArray[Element, 10]:
    """Simple array processing - similar to LoopCheckCalldata"""
    result: DynArray[Element, 10] = []
    for elem: Element in data:
        result.append(Element(id=elem.id, value=elem.value + 1))
    return result
