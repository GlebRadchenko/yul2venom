// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title LibraryUser
 * @dev Simple contract that uses an external library for testing library linking.
 *
 * This is used to test the yul2venom library_addresses feature:
 * - prepare: detects SimpleMath library via linkersymbol
 * - config: user fills in library address
 * - transpile: embeds library address in bytecode
 */

/// @dev Simple math library with external functions
library SimpleMath {
    function double(uint256 x) external pure returns (uint256) {
        return x * 2;
    }

    function triple(uint256 x) external pure returns (uint256) {
        return x * 3;
    }
}

/// @dev Contract that uses the library via DELEGATECALL
contract LibraryUser {
    function computeDouble(uint256 x) external pure returns (uint256) {
        return SimpleMath.double(x);
    }

    function computeTriple(uint256 x) external pure returns (uint256) {
        return SimpleMath.triple(x);
    }

    function computeBoth(uint256 x) external pure returns (uint256, uint256) {
        return (SimpleMath.double(x), SimpleMath.triple(x));
    }
}
