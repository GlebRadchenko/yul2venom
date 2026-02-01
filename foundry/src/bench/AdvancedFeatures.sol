// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title AdvancedFeatures Benchmark
/// @notice Tests advanced Solidity features: abi.encodeCall, bytes1-31, user-defined value types

// ========== User-Defined Value Types ==========
type TokenId is uint256;
type Amount is uint128;
type Percentage is uint8;

// ========== External Interface for encodeCall ==========
interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract AdvancedFeatures {
    // ========== User-Defined Value Types ==========

    TokenId public lastTokenId;
    mapping(TokenId => address) public tokenOwners;
    mapping(address => Amount) public userAmounts;

    function mintToken(address to) external returns (TokenId) {
        TokenId id = TokenId.wrap(TokenId.unwrap(lastTokenId) + 1);
        lastTokenId = id;
        tokenOwners[id] = to;
        return id;
    }

    function getTokenOwner(TokenId id) external view returns (address) {
        return tokenOwners[id];
    }

    function setAmount(address user, Amount amt) external {
        userAmounts[user] = amt;
    }

    function getAmount(address user) external view returns (Amount) {
        return userAmounts[user];
    }

    function addAmounts(Amount a, Amount b) external pure returns (Amount) {
        return Amount.wrap(Amount.unwrap(a) + Amount.unwrap(b));
    }

    function percentageToUint(Percentage p) external pure returns (uint256) {
        return uint256(Percentage.unwrap(p));
    }

    // ========== abi.encodeCall ==========

    function encodeTransfer(
        address to,
        uint256 amount
    ) external pure returns (bytes memory) {
        return abi.encodeCall(IERC20.transfer, (to, amount));
    }

    function encodeApprove(
        address spender,
        uint256 amount
    ) external pure returns (bytes memory) {
        return abi.encodeCall(IERC20.approve, (spender, amount));
    }

    function encodeBalanceOf(
        address account
    ) external pure returns (bytes memory) {
        return abi.encodeCall(IERC20.balanceOf, (account));
    }

    // Compare with manual encoding
    function encodeTransferManual(
        address to,
        uint256 amount
    ) external pure returns (bytes memory) {
        return abi.encodeWithSelector(IERC20.transfer.selector, to, amount);
    }

    // ========== Fixed-Size Byte Arrays ==========

    bytes1 public storedBytes1;
    bytes2 public storedBytes2;
    bytes4 public storedBytes4;
    bytes8 public storedBytes8;
    bytes16 public storedBytes16;
    bytes20 public storedBytes20;
    bytes32 public storedBytes32;

    function setBytes1(bytes1 val) external {
        storedBytes1 = val;
    }

    function setBytes2(bytes2 val) external {
        storedBytes2 = val;
    }

    function setBytes4(bytes4 val) external {
        storedBytes4 = val;
    }

    function setBytes8(bytes8 val) external {
        storedBytes8 = val;
    }

    function setBytes16(bytes16 val) external {
        storedBytes16 = val;
    }

    function setBytes20(bytes20 val) external {
        storedBytes20 = val;
    }

    function setBytes32(bytes32 val) external {
        storedBytes32 = val;
    }

    // Conversions
    function addressToBytes20(address addr) external pure returns (bytes20) {
        return bytes20(addr);
    }

    function bytes20ToAddress(bytes20 b) external pure returns (address) {
        return address(b);
    }

    function bytes4Selector() external pure returns (bytes4) {
        return IERC20.transfer.selector;
    }

    function extractBytes4FromBytes32(
        bytes32 data
    ) external pure returns (bytes4) {
        return bytes4(data);
    }

    function extractBytes8FromBytes32(
        bytes32 data
    ) external pure returns (bytes8) {
        return bytes8(data);
    }

    // Operations on fixed bytes
    function xorBytes4(bytes4 a, bytes4 b) external pure returns (bytes4) {
        return a ^ b;
    }

    function andBytes4(bytes4 a, bytes4 b) external pure returns (bytes4) {
        return a & b;
    }

    function orBytes4(bytes4 a, bytes4 b) external pure returns (bytes4) {
        return a | b;
    }

    function notBytes4(bytes4 a) external pure returns (bytes4) {
        return ~a;
    }

    // Index access
    function getByteAt(
        bytes32 data,
        uint8 index
    ) external pure returns (bytes1) {
        require(index < 32, "Index out of bounds");
        return data[index];
    }

    // Bytes concatenation
    function concatBytes(
        bytes1 a,
        bytes1 b
    ) external pure returns (bytes memory) {
        return bytes.concat(a, b);
    }

    function concatMultiple(
        bytes4 a,
        bytes4 b,
        bytes8 c
    ) external pure returns (bytes memory) {
        return bytes.concat(a, b, c);
    }

    // ========== String Concatenation ==========

    function concatStrings(
        string calldata a,
        string calldata b
    ) external pure returns (string memory) {
        return string.concat(a, b);
    }

    function concatThreeStrings(
        string calldata a,
        string calldata b,
        string calldata c
    ) external pure returns (string memory) {
        return string.concat(a, b, c);
    }
}
