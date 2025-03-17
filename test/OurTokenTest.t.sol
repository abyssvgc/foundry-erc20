//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from "script/DeployOurToken.s.sol";
import {OurToken} from "src/OurToken.sol";

event Transfer(address indexed from, address indexed to, uint256 value);

event Approval(address indexed owner, address indexed spender, uint256 value);

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        vm.prank(msg.sender);
        ourToken.transfer(bob, STARTING_BALANCE);
    }

    function testBobBalance() public view {
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE);
    }

    function testAllowances() public {
        uint256 initialAllowance = 1000;

        //Bob approves Alice to spend 1000 tokens
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function testTransferFromOneAccountToAnother() public {
        uint256 transferAmount = 10 ether;

        // Bob transfers tokens to Alice directly
        vm.prank(bob);
        bool success = ourToken.transfer(alice, transferAmount);

        assertTrue(success);
        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function test_RevertWhen_TransferExceedsBalance() public {
        uint256 balancePlusSome = STARTING_BALANCE + 1;

        vm.prank(bob);
        vm.expectRevert();
        ourToken.transfer(alice, balancePlusSome);
    }

    function testTransferEmitsEvent() public {
        uint256 transferAmount = 10 ether;

        vm.prank(bob);
        vm.expectEmit(true, true, false, true);
        emit Transfer(bob, alice, transferAmount); // This is the event we expect
        ourToken.transfer(alice, transferAmount);
    }

    function testApprovalEmitsEvent() public {
        uint256 approvalAmount = 100 ether;

        vm.prank(bob);
        vm.expectEmit(true, true, false, true);
        emit Approval(bob, alice, approvalAmount); // This is the event we expect
        ourToken.approve(alice, approvalAmount);
    }

    function testIncrementAllowance() public {
        uint256 initialAllowance = 100;
        uint256 incrementAmount = 50;

        vm.startPrank(bob);
        ourToken.approve(alice, initialAllowance);

        // Some ERC20 tokens have increaseAllowance - if your implementation has it:
        // ourToken.increaseAllowance(alice, incrementAmount);

        // Alternative approach (generic for all ERC20s)
        ourToken.approve(alice, initialAllowance + incrementAmount);
        vm.stopPrank();

        assertEq(ourToken.allowance(bob, alice), initialAllowance + incrementAmount);
    }

    function testDecrementAllowance() public {
        uint256 initialAllowance = 100;
        uint256 decrementAmount = 50;

        vm.startPrank(bob);
        ourToken.approve(alice, initialAllowance);

        // Some ERC20 tokens have decreaseAllowance - if your implementation has it:
        // ourToken.decreaseAllowance(alice, decrementAmount);

        // Alternative approach (generic for all ERC20s)
        ourToken.approve(alice, initialAllowance - decrementAmount);
        vm.stopPrank();

        assertEq(ourToken.allowance(bob, alice), initialAllowance - decrementAmount);
    }

    function test_RevertWhen_TransferFromWithoutApproval() public {
        vm.prank(alice);
        vm.expectRevert();
        ourToken.transferFrom(bob, alice, 100);
    }

    function testTokenMetadata() public view {
        // Verificar los metadatos del token
        assertEq(ourToken.name(), "OurToken"); // Ajusta según el nombre real de tu token
        assertEq(ourToken.symbol(), "OT"); // Ajusta según el símbolo real de tu token
        assertEq(ourToken.decimals(), 18); // ERC20 estándar usa 18 decimales
    }

    function testTotalSupply() public view {
        // Suponiendo que el total supply es igual al balance inicial de deployer + bob
        uint256 expectedTotalSupply = STARTING_BALANCE + ourToken.balanceOf(msg.sender);
        assertEq(ourToken.totalSupply(), expectedTotalSupply);
    }

    function testZeroTransfer() public {
        uint256 preBobBalance = ourToken.balanceOf(bob);
        uint256 preAliceBalance = ourToken.balanceOf(alice);

        vm.prank(bob);
        bool success = ourToken.transfer(alice, 0);

        assertTrue(success);
        assertEq(ourToken.balanceOf(bob), preBobBalance);
        assertEq(ourToken.balanceOf(alice), preAliceBalance);
    }
}
