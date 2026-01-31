// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MinimalLoop {
    struct Element {
        uint256 id;
        uint256 value;
    }

    function process(
        Element[] calldata input
    ) external pure returns (uint256 id0, uint256 id1) {
        Element[] memory output = new Element[](input.length);
        for (uint256 i = 0; i < input.length; i++) {
            output[i] = Element({id: input[i].id, value: input[i].value + 1});
        }
        id0 = output[0].id;
        id1 = output[1].id;
    }
}
