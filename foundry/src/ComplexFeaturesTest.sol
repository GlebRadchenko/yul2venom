// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Base {
    function getVirtual() public pure virtual returns (uint256) {
        return 100;
    }
}

contract ComplexFeaturesTest is Base {
    // Immutables & Constants
    uint256 public immutable IMMUTABLE_VAL;
    uint256 constant CONSTANT_VAL = 123;
    
    // Enum
    enum State { IDLE, BUSY, ERROR }
    State public currentState;

    // Storage
    uint256 public counter;

    constructor(uint256 _val) {
        IMMUTABLE_VAL = _val;
        currentState = State.IDLE;
    }

    // External View (Immutable read)
    function getImmutable() external view returns (uint256) {
        return IMMUTABLE_VAL;
    }

    // Pure (Constant read)
    function getConstant() external pure returns (uint256) {
        return CONSTANT_VAL;
    }

    // Override
    function getVirtual() public pure override returns (uint256) {
        return 200;
    }

    // Complex Control Flow
    function complexFlow(uint256 x) public returns (uint256) {
        if (x < 10) {
            counter += 1;
            return 1;
        } else if (x < 20) {
            counter += 2;
            return 2;
        } else {
            if (currentState == State.IDLE) {
                currentState = State.BUSY;
            } else {
                currentState = State.ERROR;
            }
            return 3;
        }
    }

    // Internal function call
    function internalCall(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function callInternal(uint256 a) public pure returns (uint256) {
        return internalCall(a, 10);
    }
}
