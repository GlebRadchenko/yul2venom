# @version ^0.4.0

struct Element:
    id: uint256
    value: uint256

@external
def processStructs(input: DynArray[Element, 10]) -> DynArray[Element, 10]:
    output: DynArray[Element, 10] = []
    for elem: Element in input:
        output.append(Element(id=elem.id, value=elem.value + 1))
    return output
