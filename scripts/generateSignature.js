
const accounts = await web3.eth.getAccounts();

const signer = accounts[0];
const recipient = accounts[1];
const amount = 100;

const encoded = web3.eth.abi.encodeParameters(
    ["address", "uint256"],
    [recipient, amount]
);

const messageHash = web3.utils.keccak256(encoded);

// Sign the raw hash using the local Remix VM account
const signature = await web3.eth.sign(messageHash, signer);

console.log("Signer:", signer);
console.log("Recipient:", recipient);
console.log("Hash:", messageHash);
console.log("Signature:", signature);
