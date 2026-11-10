
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract SecureSignature {
    using ECDSA for bytes32;

    mapping(address => uint256) public nonces;
    mapping(address => uint256) public balances;

    bytes32 private constant DOMAIN_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );

    bytes32 private constant AUTH_TYPEHASH =
        keccak256(
            "Authorization(address signer,address recipient,uint256 amount,uint256 nonce,uint256 deadline)"
        );

    bytes32 private constant NAME_HASH =
        keccak256("EtherShield");

    bytes32 private constant VERSION_HASH =
        keccak256("1");

    event PaymentExecuted(
        address indexed signer,
        address indexed recipient,
        uint256 amount
    );

    function domainSeparator() public view returns (bytes32) {
        return keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                NAME_HASH,
                VERSION_HASH,
                block.chainid,
                address(this)
            )
        );
    }

    function executePayment(
        address signer,
        address recipient,
        uint256 amount,
        uint256 nonce,
        uint256 deadline,
        bytes calldata signature
    ) external {
        // 1. Check expiration
        require(block.timestamp <= deadline, "Signature expired");

        // 2. Check nonce
        require(nonce == nonces[signer], "Invalid nonce");

        // 3. Create the structured authorization hash
        bytes32 structHash = keccak256(
            abi.encode(
                AUTH_TYPEHASH,
                signer,
                recipient,
                amount,
                nonce,
                deadline
            )
        );

        // 4. Apply EIP-712 domain separation
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator(),
                structHash
            )
        );

        // 5. Verify signature
        address recoveredSigner = digest.recover(signature);

        require(
            recoveredSigner == signer,
            "Invalid signature"
        );

        // 6. Consume nonce
        nonces[signer]++;

        // 7. Execute payment
        balances[recipient] += amount;

        emit PaymentExecuted(signer, recipient, amount);
    }
    function debugRecovery(
    address signer,
    address recipient,
    uint256 amount,
    uint256 nonce,
    uint256 deadline,
    bytes calldata signature
) external view returns (
    bytes32 structHash,
    bytes32 digest,
    address recoveredSigner,
    bool valid
) {
    structHash = keccak256(
        abi.encode(
            AUTH_TYPEHASH,
            signer,
            recipient,
            amount,
            nonce,
            deadline
        )
    );

    digest = keccak256(
        abi.encodePacked(
            "\x19\x01",
            domainSeparator(),
            structHash
        )
    );

    recoveredSigner = ECDSA.recover(digest, signature);

    valid = recoveredSigner == signer;
}
function debugDomainInputs()
    external
    view
    returns (
        uint256 chainId,
        address verifyingContract,
        bytes32 domainTypeHash,
        bytes32 nameHash,
        bytes32 versionHash,
        bytes32 calculatedDomain
    )
{
    return (
        block.chainid,
        address(this),
        DOMAIN_TYPEHASH,
        NAME_HASH,
        VERSION_HASH,
        domainSeparator()
    );
}
}
