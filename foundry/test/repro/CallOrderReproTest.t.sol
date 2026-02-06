// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

interface ICallOrderRepro {
    function readBalance(address token, address account) external view returns (uint256);
}

contract MockBalanceToken {
    mapping(address => uint256) public balances;

    function setBalance(address account, uint256 amount) external {
        balances[account] = amount;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
}

contract CallOrderReproTest is Test {
    address internal sut;
    MockBalanceToken internal token;

    function setUp() public {
        // Repro artifacts may be produced as runtime-only or combined output depending
        // on test harness mode; load the first available candidate.
        string[3] memory candidates = [
            string("output/CallOrderRepro_opt_runtime.bin"),
            string("output/CallOrderRepro_opt.bin"),
            string("output/CallOrderRepro.bin")
        ];
        bytes memory bytecode;
        bool loaded;
        for (uint256 i = 0; i < candidates.length; i++) {
            try vm.readFileBinary(candidates[i]) returns (bytes memory code) {
                if (code.length > 0) {
                    bytecode = code;
                    loaded = true;
                    break;
                }
            } catch {
                // continue
            }
        }
        require(loaded, "CallOrderRepro bytecode not found");
        sut = address(0x7777);
        vm.etch(sut, bytecode);

        token = new MockBalanceToken();
    }

    function test_balanceExpressionOrder() public {
        token.setBalance(address(this), 123456789);
        uint256 got = ICallOrderRepro(sut).readBalance(address(token), address(this));
        assertEq(got, 123456789);
    }
}
