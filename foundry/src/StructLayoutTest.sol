// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StructLayoutTest {
    struct Element {
        uint256 id;
        uint256 value;
    }

    function testStructArray() public pure returns (Element[] memory) {
        Element[] memory arr = new Element[](1);
        arr[0] = Element(10, 20);
        return arr;
    }
}
