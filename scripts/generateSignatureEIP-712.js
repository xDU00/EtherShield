
// ============================================
// 1. ACCOUNT CONFIGURATION
// ============================================

const accounts = await web3.eth.getAccounts();

const signer = accounts[0];
const recipient = accounts[1];

const amount = "100";

// Latest deployed SecureSignature contract
const contractAddress =
    "0x7b96aF9Bd211cBf6BA5b0dd53aa61Dc5806b6AcE";


// ============================================
// 2. CONTRACT ABI
// ============================================

const SecureSignatureABI = [
    {
        inputs: [],
        name: "domainSeparator",
        outputs: [
            {
                internalType: "bytes32",
                name: "",
                type: "bytes32"
            }
        ],
        stateMutability: "view",
        type: "function"
    },
    {
        inputs: [
            {
                internalType: "address",
                name: "",
                type: "address"
            }
        ],
        name: "nonces",
        outputs: [
            {
                internalType: "uint256",
                name: "",
                type: "uint256"
            }
        ],
        stateMutability: "view",
        type: "function"
    }
];


// ============================================
// 3. CONTRACT INSTANCE
// ============================================

const contract = new web3.eth.Contract(
    SecureSignatureABI,
    contractAddress
);


// ============================================
// 4. BLOCKCHAIN INFORMATION
// ============================================
const chainId = 1;

const block = await web3.eth.getBlock("latest");

const deadline = Number(block.timestamp) + 3600;

// Get actual nonce from smart contract
const nonce = await contract.methods
    .nonces(signer)
    .call();


// ============================================
// 5. EIP-712 DOMAIN
// ============================================

const domain = {
    name: "EtherShield",
    version: "1",
    chainId: Number(chainId),
    verifyingContract: contractAddress
};


// ============================================
// 6. EIP-712 TYPED DATA
// ============================================

const typedData = {
    types: {
        EIP712Domain: [
            { name: "name", type: "string" },
            { name: "version", type: "string" },
            { name: "chainId", type: "uint256" },
            { name: "verifyingContract", type: "address" }
        ],

        Authorization: [
            { name: "signer", type: "address" },
            { name: "recipient", type: "address" },
            { name: "amount", type: "uint256" },
            { name: "nonce", type: "uint256" },
            { name: "deadline", type: "uint256" }
        ]
    },

    primaryType: "Authorization",

    domain: domain,

    message: {
        signer: signer,
        recipient: recipient,
        amount: amount,
        nonce: nonce.toString(),
        deadline: deadline.toString()
    }
};


// ============================================
// 7. CALCULATE DOMAIN SEPARATOR
// ============================================

const domainTypeHash = web3.utils.keccak256(
    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
);

const nameHash = web3.utils.keccak256("EtherShield");

const versionHash = web3.utils.keccak256("1");

const encodedDomain = web3.eth.abi.encodeParameters(
    [
        "bytes32",
        "bytes32",
        "bytes32",
        "uint256",
        "address"
    ],
    [
        domainTypeHash,
        nameHash,
        versionHash,
        chainId,
        contractAddress
    ]
);

const calculatedDomain = web3.utils.keccak256(
    encodedDomain
);


// ============================================
// 8. GET ON-CHAIN DOMAIN
// ============================================

const onChainDomain = await contract.methods
    .domainSeparator()
    .call();

const domainMatches =
    calculatedDomain.toLowerCase() ===
    onChainDomain.toLowerCase();


// ============================================
// 9. CALCULATE AUTHORIZATION STRUCT HASH
// ============================================

const authTypeHash = web3.utils.keccak256(
    "Authorization(address signer,address recipient,uint256 amount,uint256 nonce,uint256 deadline)"
);

const encodedAuthorization = web3.eth.abi.encodeParameters(
    [
        "bytes32",
        "address",
        "address",
        "uint256",
        "uint256",
        "uint256"
    ],
    [
        authTypeHash,
        signer,
        recipient,
        amount,
        nonce,
        deadline
    ]
);

const structHash = web3.utils.keccak256(
    encodedAuthorization
);


// ============================================
// 10. CALCULATE EIP-712 DIGEST
// ============================================

const digest = web3.utils.keccak256(
    "0x1901" +
    calculatedDomain.slice(2) +
    structHash.slice(2)
);


// ============================================
// 11. GENERATE SIGNATURE
// ============================================
// ============================================
// 11. GENERATE SIGNATURE
// ============================================

if (!domainMatches) {
    throw new Error(
        "Domain separator mismatch! Check contract deployment."
    );
}

const signature = await web3.currentProvider.request({
    method: "eth_signTypedData_v4",
    params: [
        signer,
        typedData
    ]
});


// ============================================
// 12. RECOVER SIGNER
// ============================================

const recoveredSigner = web3.eth.accounts.recover(
    digest,
    signature,
    true
);

const signatureValid =
    recoveredSigner.toLowerCase() ===
    signer.toLowerCase();


// ============================================
// 13. DISPLAY RESULTS
// ============================================

console.log("========== ACCOUNT INFORMATION ==========");

console.log("Signer:", signer);
console.log("Recipient:", recipient);
console.log("Amount:", amount);
console.log("Nonce:", nonce);
console.log("Deadline:", deadline);

console.log("========== DOMAIN INFORMATION ==========");

console.log("Chain ID:", chainId);
console.log("Contract:", contractAddress);

console.log("Domain Type Hash:", domainTypeHash);
console.log("Name Hash:", nameHash);
console.log("Version Hash:", versionHash);

console.log("Calculated Domain:", calculatedDomain);
console.log("On-chain Domain:", onChainDomain);
console.log("Domain Matches:", domainMatches);

console.log("========== AUTHORIZATION HASH ==========");

console.log("Authorization Type Hash:", authTypeHash);
console.log("Struct Hash:", structHash);
console.log("EIP-712 Digest:", digest);

console.log("========== SIGNATURE VERIFICATION ==========");

console.log("Signature:", signature);
console.log("Expected Signer:", signer);
console.log("Recovered Signer:", recoveredSigner);
console.log("Signature Valid:", signatureValid);

console.log("========================================");