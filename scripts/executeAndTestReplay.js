const contractAddress =
    "0x7b96aF9Bd211cBf6BA5b0dd53aa61Dc5806b6AcE";

const accounts = await web3.eth.getAccounts();

const signer = accounts[0];
const relayer = accounts[2];

const recipient = accounts[1];

const amount = "100";
const nonce = "0";
const deadline = "1794091113";

const signature =
    "0x39c0d6212f8084b5c8252c3514bdac1e1e2e3b5af87c1f79552283874f33a7877c0dc307d379f0425c1e23337ab70a70b2f0654f1b99aab2df506d1c5c1646a61b";

const ABI = [
    {
        inputs: [
            { name: "signer", type: "address" },
            { name: "recipient", type: "address" },
            { name: "amount", type: "uint256" },
            { name: "nonce", type: "uint256" },
            { name: "deadline", type: "uint256" },
            { name: "signature", type: "bytes" }
        ],
        name: "executePayment",
        outputs: [],
        stateMutability: "nonpayable",
        type: "function"
    },
    {
        inputs: [{ name: "", type: "address" }],
        name: "nonces",
        outputs: [{ name: "", type: "uint256" }],
        stateMutability: "view",
        type: "function"
    },
    {
        inputs: [{ name: "", type: "address" }],
        name: "balances",
        outputs: [{ name: "", type: "uint256" }],
        stateMutability: "view",
        type: "function"
    }
];

const contract = new web3.eth.Contract(ABI, contractAddress);

// Check initial state
const nonceBefore = await contract.methods.nonces(signer).call();
const balanceBefore = await contract.methods.balances(recipient).call();

console.log("========== BEFORE PAYMENT ==========");
console.log("Nonce:", nonceBefore);
console.log("Recipient Balance:", balanceBefore);

if (nonceBefore.toString() !== nonce) {
    throw new Error("Unexpected nonce. Generate a fresh signature first.");
}

// Execute payment through a relayer
const receipt = await contract.methods.executePayment(
    signer,
    recipient,
    amount,
    nonce,
    deadline,
    signature
).send({
    from: relayer,
    gas: 300000
});

console.log("========== PAYMENT EXECUTED ==========");
console.log("Transaction Hash:", receipt.transactionHash);

// Check updated state
const nonceAfter = await contract.methods.nonces(signer).call();
const balanceAfter = await contract.methods.balances(recipient).call();

console.log("========== AFTER PAYMENT ==========");
console.log("Nonce:", nonceAfter);
console.log("Recipient Balance:", balanceAfter);

// Attempt replay using the exact same signature
console.log("========== REPLAY ATTACK TEST ==========");

try {
    await contract.methods.executePayment(
        signer,
        recipient,
        amount,
        nonce,
        deadline,
        signature
    ).send({
        from: relayer,
        gas: 300000
    });

    console.log("ERROR: Replay was accepted!");

} catch (error) {
    console.log("Replay rejected successfully.");
    console.log("Reason:", error.message);
}