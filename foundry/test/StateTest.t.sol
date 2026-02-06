// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

// Interface for StorageMemoryTest
interface IStorageMemoryTest {
    function getVal() external view returns (uint256);
    function setVal(uint256 _val) external;
    function getBalance(address user) external view returns (uint256);
    function setBalance(address user, uint256 amount) external;
    function memoryArraySum(
        uint256[] memory arr
    ) external pure returns (uint256);
}

// Interface for ConstantTest
interface IConstantTest {
    function getConstant() external pure returns (uint256);
    function getImmutable() external view returns (uint256);
    function MY_CONST() external pure returns (uint256);
    function IMMUTABLE_VAL() external view returns (uint256);
}

/**
 * @title StateTests
 * @notice Consolidated tests for storage, memory, constants, and immutables
 * @dev Tests: StorageMemoryTest, ConstantTest
 */
contract StateTests is Test {
    // ===== Section: Storage & Memory =====

    IStorageMemoryTest storageTarget;

    function deployStorageMemory() internal {
        bytes memory runtimeCode = vm.readFileBinary(
            "../output/StorageMemoryTest_opt_runtime.bin"
        );
        address addr = address(0xCAFE);
        vm.etch(addr, runtimeCode);
        storageTarget = IStorageMemoryTest(addr);
    }

    function test_Storage_Val() public {
        deployStorageMemory();
        assertEq(storageTarget.getVal(), 0, "Initial value wrong");

        storageTarget.setVal(12345);
        assertEq(storageTarget.getVal(), 12345, "Set value wrong");
    }

    function test_Storage_Mapping() public {
        deployStorageMemory();
        address user1 = address(0x1);
        address user2 = address(0x2);

        storageTarget.setBalance(user1, 100);
        storageTarget.setBalance(user2, 200);

        assertEq(storageTarget.getBalance(user1), 100, "User1 balance wrong");
        assertEq(storageTarget.getBalance(user2), 200, "User2 balance wrong");
    }

    function test_Memory_ArraySum() public {
        deployStorageMemory();
        uint256[] memory arr = new uint256[](3);
        arr[0] = 10;
        arr[1] = 20;
        arr[2] = 30;

        uint256 sum = storageTarget.memoryArraySum(arr);
        assertEq(sum, 60, "Array sum wrong");
    }

    // ===== Section: Constants & Immutables =====

    IConstantTest constantTarget;

    function deployConstants() internal {
        bytes memory runtimeCode = vm.readFileBinary(
            "../output/ConstantTest_opt_runtime.bin"
        );
        address addr = address(0xBEEF);
        vm.etch(addr, runtimeCode);
        constantTarget = IConstantTest(addr);
    }

    function test_Constant_Getters() public {
        deployConstants();
        assertEq(constantTarget.getConstant(), 123, "Constant should be 123");
        assertEq(
            constantTarget.MY_CONST(),
            123,
            "MY_CONST getter should return 123"
        );
    }

    function test_Immutable_Getters() public {
        deployConstants();
        assertEq(constantTarget.getImmutable(), 999, "Immutable should be 999");
        assertEq(
            constantTarget.IMMUTABLE_VAL(),
            999,
            "IMMUTABLE_VAL getter should return 999"
        );
    }
}
