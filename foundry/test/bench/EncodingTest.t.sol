// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/bench/Encoding.sol";

/**
 * @title EncodingTest
 * @dev Benchmark test for Encoding contract with bytecode injection support.
 *
 * Usage:
 *   # Test with default path
 *   forge test --match-contract EncodingTest
 *
 *   # Test with custom bytecode
 *   BYTECODE_PATH="path/to/bytecode.bin" forge test --match-contract EncodingTest
 *
 *   # Test with native Solc (no injection)
 *   BYTECODE_PATH="" forge test --match-contract EncodingTest
 */
contract EncodingTest is Test {
    Encoding target;
    address targetAddr;

    function setUp() public {
        string memory bytecodePath = vm.envOr(
            "BYTECODE_PATH",
            string("../output/Encoding_opt.bin")
        );

        if (bytes(bytecodePath).length > 0) {
            try vm.readFileBinary(bytecodePath) returns (bytes memory code) {
                targetAddr = address(0x7777);
                vm.etch(targetAddr, code);
                target = Encoding(targetAddr);
            } catch {
                target = new Encoding();
                targetAddr = address(target);
            }
        } else {
            target = new Encoding();
            targetAddr = address(target);
        }
    }

    // ========== ABI Encode ==========
    function test_abiEncode() public view {
        bytes memory result = target.abiEncode(1, 2);
        (uint256 a, uint256 b) = abi.decode(result, (uint256, uint256));
        assertEq(a, 1);
        assertEq(b, 2);
    }

    function test_abiEncodePacked() public view {
        bytes memory result = target.abiEncodePacked(1, 2);
        assertEq(result.length, 64); // Two uint256s packed
    }

    function test_abiEncodeWithSelector() public view {
        bytes4 selector = bytes4(keccak256("transfer(address,uint256)"));
        bytes memory result = target.abiEncodeWithSelector(selector, 100);
        assertEq(bytes4(result), selector);
    }

    // ========== Multiple Types ==========
    function test_encodeMultiple() public view {
        bytes memory result = target.encodeMultiple(
            42,
            address(0xBEEF),
            bytes32(uint256(123)),
            "hello"
        );
        assertTrue(result.length > 0);
    }

    function test_encodePackedMixed() public view {
        bytes memory result = target.encodePackedMixed(1, 2, 3);
        // 1 byte + 2 bytes + 32 bytes = 35 bytes
        assertEq(result.length, 35);
    }

    // ========== Hashing ==========
    function test_keccak256Hash() public view {
        bytes32 result = target.keccak256Hash(hex"deadbeef");
        assertEq(result, keccak256(hex"deadbeef"));
    }

    function test_keccak256Encode() public view {
        bytes32 result = target.keccak256Encode(1, 2);
        assertEq(result, keccak256(abi.encode(1, 2)));
    }

    function test_keccak256Packed() public view {
        bytes32 result = target.keccak256Packed(1, 2);
        assertEq(result, keccak256(abi.encodePacked(uint256(1), uint256(2))));
    }

    // ========== Decode ==========
    function test_decodePair() public view {
        bytes memory encoded = abi.encode(uint256(100), uint256(200));
        (uint256 a, uint256 b) = target.decodePair(encoded);
        assertEq(a, 100);
        assertEq(b, 200);
    }
}
