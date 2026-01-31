// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NoSelector {
    fallback() external payable {
        // Just return 1
        assembly {
            mstore(0, 15)
            return(0, 32)
        }
    }
}
