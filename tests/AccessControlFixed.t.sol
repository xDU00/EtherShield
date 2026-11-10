// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/member2/AccessControlFixed.sol";

contract AccessControlFixedTest is Test {
    AccessControlFixed target;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.prank(owner);
        target = new AccessControlFixed{value: 5 ether}();
    }

    function test_attackerCannotSetFee() public {
        vm.expectRevert(AccessControlFixed.NotOwner.selector);
        vm.prank(attacker);
        target.setFeeRate(100);
    }

    function test_attackerCannotTakeOwnership() public {
        vm.expectRevert(AccessControlFixed.NotOwner.selector);
        vm.prank(attacker);
        target.setOwner(attacker);
    }

    function test_attackerCannotWithdraw() public {
        vm.expectRevert(AccessControlFixed.NotOwner.selector);
        vm.prank(attacker);
        target.withdraw();
        assertEq(address(target).balance, 5 ether);
    }

    function test_ownerStillWorks() public {
        vm.prank(owner);
        target.setFeeRate(2);
        assertEq(target.feeRate(), 2);
    }

    // fuzzing: Forge tries many random callers
    function testFuzz_nobodyButOwnerCanSetFee(address caller) public {
        vm.assume(caller != owner);
        vm.expectRevert(AccessControlFixed.NotOwner.selector);
        vm.prank(caller);
        target.setFeeRate(100);
    }
}