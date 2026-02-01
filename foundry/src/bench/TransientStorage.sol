// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title TransientStorage Benchmark
/// @notice Tests EIP-1153 transient storage (TLOAD/TSTORE) - requires Cancun
/// @dev Transient storage is cleared after each transaction

contract TransientStorage {
    // Regular storage for comparison
    uint256 public regularStorage;

    // ========== Basic Transient Operations ==========

    /// @notice Store a value in transient storage
    function tstore(uint256 slot, uint256 value) external {
        assembly {
            tstore(slot, value)
        }
    }

    /// @notice Load a value from transient storage
    function tload(uint256 slot) external view returns (uint256 value) {
        assembly {
            value := tload(slot)
        }
    }

    /// @notice Store and load in same call (value persists within tx)
    function tstoreAndLoad(
        uint256 slot,
        uint256 value
    ) external returns (uint256 loaded) {
        assembly {
            tstore(slot, value)
            loaded := tload(slot)
        }
    }

    // ========== Reentrancy Lock Pattern ==========

    uint256 private constant LOCK_SLOT = 0x1234;

    /// @notice Check if currently locked
    function isLocked() public view returns (bool locked) {
        assembly {
            locked := tload(LOCK_SLOT)
        }
    }

    /// @notice Set lock
    function setLock() external {
        assembly {
            tstore(LOCK_SLOT, 1)
        }
    }

    /// @notice Clear lock
    function clearLock() external {
        assembly {
            tstore(LOCK_SLOT, 0)
        }
    }

    modifier nonReentrant() {
        bool locked;
        assembly {
            locked := tload(LOCK_SLOT)
        }
        require(!locked, "ReentrancyGuard: reentrant call");
        assembly {
            tstore(LOCK_SLOT, 1)
        }
        _;
        assembly {
            tstore(LOCK_SLOT, 0)
        }
    }

    /// @notice Function protected by transient reentrancy guard
    function protectedFunction() external nonReentrant returns (uint256) {
        return 42;
    }

    // ========== Multiple Slots ==========

    /// @notice Store to multiple slots
    function tstoreMultiple(
        uint256[] calldata slots,
        uint256[] calldata values
    ) external {
        require(slots.length == values.length, "Length mismatch");
        for (uint256 i = 0; i < slots.length; i++) {
            assembly {
                tstore(
                    calldataload(add(slots.offset, mul(i, 32))),
                    calldataload(add(values.offset, mul(i, 32)))
                )
            }
        }
    }

    /// @notice Load from multiple slots
    function tloadMultiple(
        uint256[] calldata slots
    ) external view returns (uint256[] memory values) {
        values = new uint256[](slots.length);
        for (uint256 i = 0; i < slots.length; i++) {
            uint256 slot = slots[i];
            uint256 value;
            assembly {
                value := tload(slot)
            }
            values[i] = value;
        }
    }

    // ========== Transient vs Regular Storage ==========

    /// @notice Store in regular storage
    function storeRegular(uint256 value) external {
        regularStorage = value;
    }

    /// @notice Store in transient storage (cheaper, but cleared after tx)
    function storeTransient(uint256 value) external {
        assembly {
            tstore(0, value)
        }
    }

    /// @notice Get both values
    function getBoth()
        external
        view
        returns (uint256 regular, uint256 transient_)
    {
        regular = regularStorage;
        assembly {
            transient_ := tload(0)
        }
    }

    // ========== Counter Pattern ==========

    uint256 private constant COUNTER_SLOT = 0x5678;

    /// @notice Increment transient counter
    function incrementTransientCounter() external returns (uint256 newValue) {
        assembly {
            let current := tload(COUNTER_SLOT)
            newValue := add(current, 1)
            tstore(COUNTER_SLOT, newValue)
        }
    }

    /// @notice Get transient counter value
    function getTransientCounter() external view returns (uint256 value) {
        assembly {
            value := tload(COUNTER_SLOT)
        }
    }

    /// @notice Reset transient counter
    function resetTransientCounter() external {
        assembly {
            tstore(COUNTER_SLOT, 0)
        }
    }

    // ========== Complex Type in Transient ==========

    /// @notice Store address in transient storage
    function tstoreAddress(uint256 slot, address addr) external {
        assembly {
            tstore(slot, addr)
        }
    }

    /// @notice Load address from transient storage
    function tloadAddress(uint256 slot) external view returns (address addr) {
        assembly {
            addr := tload(slot)
        }
    }

    /// @notice Store bytes32 in transient storage
    function tstoreBytes32(uint256 slot, bytes32 data) external {
        assembly {
            tstore(slot, data)
        }
    }

    /// @notice Load bytes32 from transient storage
    function tloadBytes32(uint256 slot) external view returns (bytes32 data) {
        assembly {
            data := tload(slot)
        }
    }

    // ========== Callback Pattern ==========

    uint256 private constant CALLBACK_SENDER_SLOT = 0xABCD;

    /// @notice Save sender in transient storage before callback
    function executeWithCallback(
        address target,
        bytes calldata data
    ) external returns (bytes memory result) {
        assembly {
            tstore(CALLBACK_SENDER_SLOT, caller())
        }
        (bool success, bytes memory returnData) = target.call(data);
        require(success, "Callback failed");
        assembly {
            tstore(CALLBACK_SENDER_SLOT, 0)
        }
        return returnData;
    }

    /// @notice Get the original sender during callback
    function getCallbackSender() external view returns (address sender) {
        assembly {
            sender := tload(CALLBACK_SENDER_SLOT)
        }
    }
}
