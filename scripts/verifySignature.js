const contractAddress = "0x7b96aF9Bd211cBf6BA5b0dd53aa61Dc5806b6AcE";

const code = await web3.eth.getCode(contractAddress);

console.log("Script chain ID:", await web3.eth.getChainId());
console.log("Contract bytecode length:", code.length);
const chainId = 1;
const contract = new web3.eth.Contract(
    [{
        inputs: [],
        name: "debugDomainInputs",
        outputs: [
            { type: "uint256" },
            { type: "address" },
            { type: "bytes32" },
            { type: "bytes32" },
            { type: "bytes32" },
            { type: "bytes32" }
        ],
        stateMutability: "view",
        type: "function"
    }],
    contractAddress
);

const result = await contract.methods.debugDomainInputs().call();

console.log("Contract chain ID:", result[0]);
console.log("Contract address:", result[1]);
console.log("Domain:", result[5]);