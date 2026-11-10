const contractAddress =
    "0x7b96aF9Bd211cBf6BA5b0dd53aa61Dc5806b6AcE";

const signer =
    "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4";

const recipient =
    "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2";

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
        name: "debugRecovery",
        outputs: [
            { name: "structHash", type: "bytes32" },
            { name: "digest", type: "bytes32" },
            { name: "recoveredSigner", type: "address" },
            { name: "valid", type: "bool" }
        ],
        stateMutability: "view",
        type: "function"
    }
];

const contract = new web3.eth.Contract(ABI, contractAddress);

const result = await contract.methods.debugRecovery(
    signer,
    recipient,
    amount,
    nonce,
    deadline,
    signature
).call();

console.log("========== ON-CHAIN VERIFICATION ==========");
console.log("Struct Hash:", result[0]);
console.log("Digest:", result[1]);
console.log("Recovered Signer:", result[2]);
console.log("Signature Valid:", result[3]);