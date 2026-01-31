// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

enum State {
    IDLE,
    ACTIVE,
    PAUSED,
    STOPPED
}

struct Config {
    uint256 minVal;
    uint256 maxVal;
    address admin;
}

contract Base {
    uint256 public baseVal;

    event BaseLog(uint256 val);

    function setBase(uint256 _val) public virtual {
        baseVal = _val;
        emit BaseLog(_val);
    }

    function logic(uint256 x) public pure virtual returns (uint256) {
        return x + 1;
    }
}

contract Middle is Base {
    uint256 public middleVal;

    function setBase(uint256 _val) public virtual override {
        super.setBase(_val * 2);
        middleVal = _val;
    }

    function logic(uint256 x) public pure virtual override returns (uint256) {
        return super.logic(x) * 2;
    }
}

contract MegaTest is Middle {
    State public state;
    Config public config;
    mapping(address => uint256) public balances;
    address public lib; // For delegatecall

    struct Element {
        uint256 id;
        uint256 value;
    }

    function processStructs(
        Element[] calldata input
    ) external pure returns (Element[] memory output) {
        return _mapElements(input);
    }

    function _mapElements(
        Element[] calldata input
    ) internal pure returns (Element[] memory output) {
        output = new Element[](input.length);
        for (uint256 i = 0; i < input.length; i++) {
            output[i] = Element({id: input[i].id, value: input[i].value * 2});
        }
    }

    constructor(address _lib) {
        lib = _lib;
        state = State.IDLE;
        config.minVal = 10;
        config.maxVal = 100;
        config.admin = msg.sender;
    }

    // Override Middle logic
    function setBase(uint256 _val) public override {
        // Calls Middle.setBase -> Base.setBase
        super.setBase(_val);
        // Logic: if input 10:
        // Middle calls Base(20) -> baseVal=20
        // Middle sets middleVal=10
    }

    // Custom logic accessing storage structs/enums
    function updateState(State _newState) public {
        require(_newState != State.STOPPED, "Cannot stop");
        state = _newState;
    }

    // Explicit receive function to silence warnings
    receive() external payable {}

    // Diamond-like delegatecall pattern
    fallback() external payable {
        address _lib = lib;
        require(_lib != address(0), "Lib not set");
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), _lib, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function checkConfig(uint256 x) public view returns (bool) {
        return x >= config.minVal && x <= config.maxVal;
    }

    // Internal call test
    function internalCalc(
        uint256 x,
        uint256 y
    ) internal pure returns (uint256) {
        return x * y + 1;
    }

    function runCalc(uint256 a) public pure returns (uint256) {
        return internalCalc(a, 10);
    }

    // ============ TRANSIENT STORAGE TEST ============
    // Uses EIP-1153 tstore/tload opcodes (Cancun+)

    function setTransient(uint256 slot, uint256 value) public {
        assembly {
            tstore(slot, value)
        }
    }

    function getTransient(uint256 slot) public view returns (uint256 result) {
        assembly {
            result := tload(slot)
        }
    }

    function transientCounter() public returns (uint256) {
        uint256 current;
        assembly {
            current := tload(0x100)
            tstore(0x100, add(current, 1))
        }
        return current + 1;
    }

    // ============ RECURSIVE CALL PATTERN ============
    // callA -> callB -> callC -> (if depth < max) -> callA
    // Uses transient storage to track recursion depth

    uint256 constant RECURSION_SLOT = 0x200;
    uint256 constant MAX_RECURSION = 3;

    event Debug(uint256 tag, uint256 val);

    function callA(uint256 value) public returns (uint256) {
        uint256 depth;
        assembly {
            depth := tload(RECURSION_SLOT)
            tstore(RECURSION_SLOT, add(depth, 1))
        }
        emit Debug(100, value);
        emit Debug(101, depth);

        // Add some computation
        uint256 result = value + 1;
        emit Debug(102, result);

        // Chain to callB
        result = callB(result);

        // Decrement depth on way out
        assembly {
            let d := tload(RECURSION_SLOT)
            tstore(RECURSION_SLOT, sub(d, 1))
        }

        return result;
    }

    function callB(uint256 value) internal returns (uint256) {
        emit Debug(200, value);
        // Middle of chain: multiply by 2
        uint256 result = value * 2;
        emit Debug(201, result);

        // Chain to callC
        result = callC(result);

        return result;
    }

    function callC(uint256 value) internal returns (uint256) {
        uint256 depth;
        assembly {
            depth := tload(RECURSION_SLOT)
        }
        emit Debug(300, value);
        emit Debug(301, depth);

        // Recursive condition: if depth < MAX_RECURSION, call back to callA
        if (depth < MAX_RECURSION) {
            // Recurse back to callA
            return callA(value);
        } else {
            // Base case: return accumulated value
            return value;
        }
    }

    function getRecursionDepth() public view returns (uint256 depth) {
        assembly {
            depth := tload(RECURSION_SLOT)
        }
    }
}
