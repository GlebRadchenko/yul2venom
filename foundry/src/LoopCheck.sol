// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract LoopCheck {
    struct Element {
        uint256 id;
        uint256 value;
    }

    event log_element(uint256 index, uint256 id, uint256 value);

    function process(
        Element[] memory elements
    ) public returns (Element[] memory) {
        // This mirrors processStructs in MegaTest
        uint len = elements.length;
        assembly {
            log3(0, 0, 0xDDDDDDDD, len, 0)
        }
        for (uint256 i = 0; i < elements.length; i++) {
            emit log_element(i, elements[i].id, elements[i].value); // Log element
            // uint val = elements[i].value;
            elements[i].value += 1;
        }
        return elements;
    }
}
