
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
contract VulnerableSignature {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    mapping(address => uint256) public balances;

    event PaymentExecuted(
        address indexed signer,
        address indexed recipient,
        uint256 amount
    );

    function executePayment(
        address recipient,
        uint256 amount,
        bytes calldata signature
    ) external {
        // Hash the authorization
        bytes32 messageHash = keccak256(
            abi.encode(recipient, amount)
        );

        // Recover the signer's address
        address signer = messageHash.toEthSignedMessageHash().recover(signature);

        require(signer != address(0), "Invalid signature");

        // Execute payment
        balances[recipient] += amount;

        emit PaymentExecuted(signer, recipient, amount);
    }
}
