# @version 0.4.3

struct Element:
    id: uint256
    value: uint256

@external
def processStructs(input: DynArray[Element, 10]) -> DynArray[Element, 10]:
    output: DynArray[Element, 10] = []
    for elem: Element in input:
        new_elem: Element = Element(id=elem.id, value=elem.value * 2)
        output.append(new_elem)
    return output
