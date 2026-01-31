// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract ConstantTest {
    uint256 public constant MY_CONST = 123;
    uint256 public immutable IMMUTABLE_VAL;

    constructor(uint256 val) {
        IMMUTABLE_VAL = val;
    }

    function getConstant() external pure returns (uint256) {
        return MY_CONST;
    }

    function getImmutable() external view returns (uint256) {
        return IMMUTABLE_VAL;
    }
}
