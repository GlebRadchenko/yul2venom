// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Edge Cases Benchmark
/// @notice Tests edge cases: fallback, revert, try-catch, enums, selfdestruct alternatives
contract Edge {
    // ========== Enums ==========
    enum Status {
        Pending,
        Active,
        Paused,
        Completed,
        Failed
    }
    Status public currentStatus;

    // ========== Custom Errors ==========
    error CustomError(uint256 code, string message);
    error ZeroValue();
    error Unauthorized(address caller);

    // ========== Fallback ==========
    fallback() external payable {
        // Accept and ignore
    }

    receive() external payable {
        // Accept ETH
    }

    // ========== Enum Operations ==========
    function setStatus(Status s) external {
        currentStatus = s;
    }

    function getStatus() external view returns (Status) {
        return currentStatus;
    }

    function statusToUint() external view returns (uint256) {
        return uint256(currentStatus);
    }

    function uintToStatus(uint256 val) external pure returns (Status) {
        require(val <= uint256(type(Status).max), "invalid status");
        return Status(val);
    }

    // ========== Revert Variants ==========
    function revertEmpty() external pure {
        revert();
    }

    function revertMessage(string calldata msg_) external pure {
        revert(msg_);
    }

    function revertCustom(uint256 code) external pure {
        revert CustomError(code, "custom error");
    }

    function revertZeroValue() external pure {
        revert ZeroValue();
    }

    function revertUnauthorized() external view {
        revert Unauthorized(msg.sender);
    }

    // ========== Require ==========
    function requireTrue(bool condition) external pure returns (bool) {
        require(condition, "condition failed");
        return true;
    }

    function requireValue(uint256 x) external pure returns (uint256) {
        require(x > 0, "must be positive");
        return x;
    }

    // ========== Assert ==========
    function assertCondition(bool condition) external pure returns (bool) {
        assert(condition);
        return true;
    }

    // ========== Try-Catch Variants ==========
    function tryCall(
        uint256 x
    ) external view returns (bool success, uint256 result) {
        try this.mayFail(x) returns (uint256 r) {
            return (true, r);
        } catch {
            return (false, 0);
        }
    }

    function tryCallWithReason(
        uint256 x
    ) external view returns (bool, string memory) {
        try this.mayFail(x) returns (uint256) {
            return (true, "");
        } catch Error(string memory reason) {
            return (false, reason);
        } catch {
            return (false, "unknown");
        }
    }

    function tryCallWithPanic(uint256 x) external view returns (bool, uint256) {
        try this.mayPanic(x) returns (uint256) {
            return (true, 0);
        } catch Panic(uint256 code) {
            return (false, code);
        } catch {
            return (false, 999);
        }
    }

    function mayFail(uint256 x) external pure returns (uint256) {
        require(x < 100, "too large");
        return x * 2;
    }

    function mayPanic(uint256 x) external pure returns (uint256) {
        // Causes panic 0x12 (division by zero) if x == 0
        return 100 / x;
    }

    // ========== Gas Operations ==========
    function checkGas() external view returns (uint256) {
        return gasleft();
    }

    function gasHeavyLoop(uint256 n) external pure returns (uint256) {
        if (n > 1000) n = 1000;
        uint256 sum = 0;
        for (uint256 i = 0; i < n; i++) {
            sum += i * i; // Some computation
        }
        return sum;
    }

    // ========== Block Info ==========
    function getBlockInfo() external view returns (uint256, uint256, address) {
        return (block.number, block.timestamp, block.coinbase);
    }

    function getBlockhash(uint256 blockNum) external view returns (bytes32) {
        return blockhash(blockNum);
    }

    function getChainInfo()
        external
        view
        returns (uint256 chainId, uint256 baseFee)
    {
        chainId = block.chainid;
        baseFee = block.basefee;
    }

    // ========== Msg/Tx Info ==========
    function getMsgInfo() external payable returns (address, uint256, bytes4) {
        return (msg.sender, msg.value, msg.sig);
    }

    function getTxInfo()
        external
        view
        returns (address origin, uint256 gasprice)
    {
        return (tx.origin, tx.gasprice);
    }

    // ========== Address Operations ==========
    function getBalance(address addr) external view returns (uint256) {
        return addr.balance;
    }

    function getCodeSize(address addr) external view returns (uint256 size) {
        assembly {
            size := extcodesize(addr)
        }
    }

    function getCodeHash(address addr) external view returns (bytes32 hash) {
        assembly {
            hash := extcodehash(addr)
        }
    }

    // ========== Create/Create2 (if needed) ==========
    function createContract(
        bytes memory bytecode
    ) external returns (address addr) {
        assembly {
            addr := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        require(addr != address(0), "create failed");
    }

    function create2Contract(
        bytes memory bytecode,
        bytes32 salt
    ) external returns (address addr) {
        assembly {
            addr := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "create2 failed");
    }
}
