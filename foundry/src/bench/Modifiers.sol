// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Modifiers Benchmark
/// @notice Tests various modifier patterns for transpiler verification
contract Modifiers {
    // ========== State ==========
    address public owner;
    bool public paused;
    uint256 public counter;
    mapping(address => bool) public admins;

    // ========== Events ==========
    event ActionPerformed(address indexed caller, string action);
    event GuardTriggered(string guard);

    // ========== Errors ==========
    error NotOwner();
    error NotAdmin();
    error Paused();
    error InvalidValue(uint256 value);

    constructor() {
        owner = msg.sender;
        admins[msg.sender] = true;
    }

    // ========== Basic Modifiers ==========

    /// @notice Simple ownership check
    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    /// @notice Simple admin check
    modifier onlyAdmin() {
        if (!admins[msg.sender]) revert NotAdmin();
        _;
    }

    /// @notice Pausable guard
    modifier whenNotPaused() {
        if (paused) revert Paused();
        _;
    }

    // ========== Modifiers with Arguments ==========

    /// @notice Value bounds check
    modifier valueInRange(uint256 min, uint256 max) {
        if (msg.value < min || msg.value > max) revert InvalidValue(msg.value);
        _;
    }

    /// @notice Generic value check
    modifier minValue(uint256 min) {
        require(msg.value >= min, "Below minimum");
        _;
    }

    // ========== Nested Modifiers (with code before and after _) ==========

    /// @notice Reentrancy-style guard
    modifier noReentrancy() {
        uint256 before = counter;
        _;
        require(counter == before + 1, "Reentrancy detected");
    }

    /// @notice Logging modifier
    modifier logged(string memory action) {
        emit GuardTriggered(action);
        _;
        emit ActionPerformed(msg.sender, action);
    }

    // ========== Edge Case Modifiers: _ Placement ==========

    /// @notice _ at beginning (post-execution code only)
    modifier afterOnly() {
        _;
        counter += 1000; // Always adds 1000 after function
    }

    /// @notice _ in middle (code before and after)
    modifier middlePlacement() {
        uint256 preValue = counter;
        _;
        require(counter > preValue, "Counter must increase");
    }

    /// @notice No _ at all (blocking modifier - function body never executes)
    modifier neverRuns() {
        revert("Blocked by modifier");
        _; // Unreachable but required by compiler
    }

    /// @notice Conditional _ execution
    modifier conditionalExec(bool shouldRun) {
        if (shouldRun) {
            _;
        }
        // If !shouldRun, function body doesn't execute
    }

    /// @notice Multiple state changes around _
    modifier complexWrapper(uint256 addBefore, uint256 addAfter) {
        counter += addBefore;
        _;
        counter += addAfter;
    }

    // ========== Functions with Single Modifier ==========

    function setOwner(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    function setPaused(bool _paused) external onlyOwner {
        paused = _paused;
    }

    function addAdmin(address admin) external onlyOwner {
        admins[admin] = true;
    }

    function removeAdmin(address admin) external onlyOwner {
        admins[admin] = false;
    }

    // ========== Functions with Multiple Modifiers ==========

    function adminAction() external onlyAdmin whenNotPaused returns (bool) {
        counter++;
        return true;
    }

    function ownerAction() external onlyOwner whenNotPaused returns (uint256) {
        counter += 10;
        return counter;
    }

    function restrictedAction() external onlyOwner onlyAdmin whenNotPaused {
        counter += 100;
    }

    // ========== Functions with Argument Modifiers ==========

    function depositInRange()
        external
        payable
        valueInRange(0.1 ether, 1 ether)
    {
        counter += msg.value;
    }

    function depositMin() external payable minValue(0.01 ether) {
        counter += msg.value;
    }

    // ========== Functions with Nested Modifiers ==========

    function safeIncrement() external noReentrancy {
        counter++;
    }

    function loggedIncrement() external logged("increment") {
        counter++;
    }

    function fullProtection()
        external
        onlyOwner
        whenNotPaused
        noReentrancy
        logged("full")
    {
        counter++;
    }

    // ========== View Functions with Modifiers ==========

    function getCounter() external view onlyAdmin returns (uint256) {
        return counter;
    }

    // ========== Pure Functions ==========

    function pureAdd(uint256 a, uint256 b) external pure returns (uint256) {
        return a + b;
    }

    // ========== Getter for Testing ==========

    function getState() external view returns (address, bool, uint256) {
        return (owner, paused, counter);
    }

    // ========== Edge Case Functions: _ Placement ==========

    /// @notice Uses afterOnly - counter increases by 5 in function, then 1000 in modifier
    function incrementWithAfterMod() external afterOnly {
        counter += 5;
    }

    /// @notice Uses middlePlacement - validates counter increased
    function incrementWithMiddleMod() external middlePlacement {
        counter += 10;
    }

    /// @notice Should always revert - neverRuns modifier blocks execution
    function blockedFunction() external neverRuns {
        counter += 999; // Never executes
    }

    /// @notice Conditional execution based on parameter
    function conditionalIncrement(
        bool shouldRun
    ) external conditionalExec(shouldRun) {
        counter += 50;
    }

    /// @notice Complex wrapper adds values before and after
    function wrappedIncrement() external complexWrapper(100, 200) {
        counter += 1; // Total: 100 + 1 + 200 = 301
    }

    /// @notice Multiple edge case modifiers stacked
    function multiEdgeCase() external afterOnly middlePlacement {
        counter += 7; // middlePlacement validates increase, afterOnly adds 1000
    }
}
