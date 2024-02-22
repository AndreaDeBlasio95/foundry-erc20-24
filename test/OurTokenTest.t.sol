// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    address public constant alice = address(1);
    address public constant bob = address(2);

    uint256 public constant INITIAL_SUPPLY = 1000 * 10 ** 18;

    function setUp() public {
        ourToken = new OurToken(INITIAL_SUPPLY);
        vm.label(address(this), "Contract");
        vm.label(alice, "Alice");
        vm.label(bob, "Bob");
        ourToken.transfer(alice, 200);
    }

    function testInitialSupply() public {
        assertEq(ourToken.totalSupply(), INITIAL_SUPPLY);
    }

    function testApproveAndAllowance() public {
        vm.startPrank(alice);
        ourToken.approve(address(this), 100);
        vm.stopPrank();

        uint256 allowance = ourToken.allowance(alice, address(this));
        assertEq(allowance, 100, "Allowance should be 100");
    }

    function testTransferFrom() public {
        // Alice approves this contract to spend on her behalf
        vm.startPrank(alice);
        ourToken.approve(address(this), 150);
        vm.stopPrank();

        // This contract now tries to transfer from Alice to Bob
        ourToken.transferFrom(alice, bob, 150);

        assertEq(ourToken.balanceOf(bob), 150, "Bob should receive 150 tokens");
        assertEq(
            ourToken.allowance(alice, address(this)),
            0,
            "Allowance should be 0 after transfer"
        );
    }

    function testDirectTransfer() public {
        // Transfer 100 tokens from this contract (which holds the initial supply) to Alice
        uint256 additionalAmount = 100 * 10 ** 18; // Amount to transfer in this test
        uint256 initialAliceBalance = ourToken.balanceOf(alice); // Get initial balance of Alice
        ourToken.transfer(alice, additionalAmount);

        // Calculate expected balance after transfer
        uint256 expectedAliceBalance = initialAliceBalance + additionalAmount;
        assertEq(
            ourToken.balanceOf(alice),
            expectedAliceBalance,
            "Alice should have 300 tokens after transfer"
        );
    }

    function testTransferEvent() public {
        uint256 amount = 100;
        // Ensure the correct setup for the initial supply
        ourToken = new OurToken(INITIAL_SUPPLY);

        // Transfer to Alice and expect the correct event
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(this), alice, amount);
        ourToken.transfer(alice, amount);
    }

    function testApprovalEvent() public {
        vm.expectEmit(true, true, true, true);
        emit Approval(address(this), bob, 200);
        ourToken.approve(bob, 200);
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
