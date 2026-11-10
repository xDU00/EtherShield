// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/secure/secureSignature.sol";

contract SecureSignatureTest is Test {
    SecureSignature secure;

    uint256 private constant PRIVATE_KEY = 0xA11CE;

    address signer;
    address recipient;
    address relayer;

    function setUp() public {
        secure = new SecureSignature();

        signer = vm.addr(PRIVATE_KEY);
        recipient = makeAddr("recipient");
        relayer = makeAddr("relayer");

        vm.warp(1800000000);
    }

    // Reproduce the contract's EIP-712 signing process.
    function getDigest(
        address _signer,
        address _recipient,
        uint256 amount,
        uint256 nonce,
        uint256 deadline
    ) internal view returns (bytes32) {

        bytes32 domainTypeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );

        bytes32 authTypeHash = keccak256(
            "Authorization(address signer,address recipient,uint256 amount,uint256 nonce,uint256 deadline)"
        );

        bytes32 domainSeparator = keccak256(
            abi.encode(
                domainTypeHash,
                keccak256("EtherShield"),
                keccak256("1"),
                block.chainid,
                address(secure)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(
                authTypeHash,
                _signer,
                _recipient,
                amount,
                nonce,
                deadline
            )
        );

        return keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                structHash
            )
        );
    }

    function signAuthorization(
        address _signer,
        address _recipient,
        uint256 amount,
        uint256 nonce,
        uint256 deadline
    ) internal returns (bytes memory) {

        bytes32 digest = getDigest(
            _signer,
            _recipient,
            amount,
            nonce,
            deadline
        );

        (uint8 v, bytes32 r, bytes32 s) =
            vm.sign(PRIVATE_KEY, digest);

        return abi.encodePacked(r, s, v);
    }

    // 1. Valid signature should succeed.
    function test_ValidSignature() public {
        uint256 amount = 100;
        uint256 deadline = block.timestamp + 1 days;

        bytes memory signature = signAuthorization(
            signer,
            recipient,
            amount,
            0,
            deadline
        );

        vm.prank(relayer);

        secure.executePayment(
            signer,
            recipient,
            amount,
            0,
            deadline,
            signature
        );

        assertEq(secure.balances(recipient), amount);
        assertEq(secure.nonces(signer), 1);
    }

    // 2. Expired signature must fail.
    function test_RevertWhen_SignatureExpired() public {
        uint256 deadline = block.timestamp + 100;

        bytes memory signature = signAuthorization(
            signer,
            recipient,
            100,
            0,
            deadline
        );

        vm.warp(deadline + 1);

        vm.expectRevert(
            abi.encodeWithSignature(
                "Error(string)",
                "Signature expired"
            )
        );

        secure.executePayment(
            signer,
            recipient,
            100,
            0,
            deadline,
            signature
        );
    }

    // 3. Replayed signature must fail.
    function test_RevertWhen_SignatureReplayed() public {
        uint256 deadline = block.timestamp + 1 days;

        bytes memory signature = signAuthorization(
            signer,
            recipient,
            100,
            0,
            deadline
        );

        secure.executePayment(
            signer,
            recipient,
            100,
            0,
            deadline,
            signature
        );

        vm.expectRevert(
            abi.encodeWithSignature(
                "Error(string)",
                "Invalid nonce"
            )
        );

        secure.executePayment(
            signer,
            recipient,
            100,
            0,
            deadline,
            signature
        );
    }

    // 4. Modified amount must fail.
    function test_RevertWhen_AmountModified() public {
        uint256 deadline = block.timestamp + 1 days;

        bytes memory signature = signAuthorization(
            signer,
            recipient,
            100,
            0,
            deadline
        );

        vm.expectRevert(
            abi.encodeWithSignature(
                "Error(string)",
                "Invalid signature"
            )
        );

        secure.executePayment(
            signer,
            recipient,
            200,
            0,
            deadline,
            signature
        );
    }

    // 5. Modified recipient must fail.
    function test_RevertWhen_RecipientModified() public {
        uint256 deadline = block.timestamp + 1 days;

        bytes memory signature = signAuthorization(
            signer,
            recipient,
            100,
            0,
            deadline
        );

        address attacker = makeAddr("attacker");

        vm.expectRevert(
            abi.encodeWithSignature(
                "Error(string)",
                "Invalid signature"
            )
        );

        secure.executePayment(
            signer,
            attacker,
            100,
            0,
            deadline,
            signature
        );
    }

    // 6. Wrong signer must fail.
    function test_RevertWhen_WrongSigner() public {
        uint256 deadline = block.timestamp + 1 days;

        bytes memory signature = signAuthorization(
            signer,
            recipient,
            100,
            0,
            deadline
        );

        address fakeSigner = makeAddr("fakeSigner");

        vm.expectRevert(
            abi.encodeWithSignature(
                "Error(string)",
                "Invalid signature"
            )
        );

        secure.executePayment(
            fakeSigner,
            recipient,
            100,
            0,
            deadline,
            signature
        );
    }

    // 7. Wrong nonce must fail.
    function test_RevertWhen_WrongNonce() public {
        uint256 deadline = block.timestamp + 1 days;

        bytes memory signature = signAuthorization(
            signer,
            recipient,
            100,
            0,
            deadline
        );

        vm.expectRevert(
            abi.encodeWithSignature(
                "Error(string)",
                "Invalid nonce"
            )
        );

        secure.executePayment(
            signer,
            recipient,
            100,
            1,
            deadline,
            signature
        );
    }

    // 8. Signature from another chain must fail.
    function test_RevertWhen_ChainIdChanges() public {
        uint256 deadline = block.timestamp + 1 days;

        bytes memory signature = signAuthorization(
            signer,
            recipient,
            100,
            0,
            deadline
        );

        vm.chainId(block.chainid + 1);

        vm.expectRevert(
            abi.encodeWithSignature(
                "Error(string)",
                "Invalid signature"
            )
        );

        secure.executePayment(
            signer,
            recipient,
            100,
            0,
            deadline,
            signature
        );
    }

    // 9. Signature is valid exactly at the deadline.
    function test_ValidSignatureAtExactDeadline() public {
        uint256 deadline = block.timestamp + 100;

        bytes memory signature = signAuthorization(
            signer,
            recipient,
            100,
            0,
            deadline
        );

        vm.warp(deadline);

        secure.executePayment(
            signer,
            recipient,
            100,
            0,
            deadline,
            signature
        );

        assertEq(secure.balances(recipient), 100);
    }
}