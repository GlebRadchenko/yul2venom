// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

contract LoopCheckCalldata {
    struct Element {
        uint256 id;
        uint256 value;
    }

    function processStructs(
        Element[] calldata input
    ) external pure returns (Element[] memory output) {
        output = new Element[](input.length);
        for (uint256 i = 0; i < input.length; i++) {
            output[i] = Element({id: input[i].id, value: input[i].value + 1});
        }
    }
}
