// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract TryCatchRepro {
    function externalFail(uint256 x) public pure {
        require(x < 10, "Too big");
    }

    function tryCatchTest(uint256 x) public view returns (bool) {
        try this.externalFail(x) {
            return true;
        } catch {
            return false;
        }
    }
}
