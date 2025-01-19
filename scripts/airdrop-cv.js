const fs = require("fs");

const ethers = require('ethers')

async function main() {
    const users = [
    ]

    let current = users[0];
    // Replace with your contract's name and deployed address
    const contractName = "BCSH_Distributor"; // Your contract name
    const contractAddress = "0xBDf459b77d44Ef271d8Df7afd55B968FDF1dA645"; // Replace with your deployed address
    const contractABI = [{ "type": "constructor", "stateMutability": "nonpayable", "inputs": [{ "type": "address", "name": "_blockchainSuperheroes", "internalType": "address" }, { "type": "address", "name": "_cggToken", "internalType": "contract IERC20" }] }, { "type": "event", "name": "Mint", "inputs": [{ "type": "address", "name": "_owner", "internalType": "address", "indexed": false }, { "type": "uint256", "name": "token", "internalType": "uint256", "indexed": false }], "anonymous": false }, { "type": "event", "name": "OwnershipTransferred", "inputs": [{ "type": "address", "name": "previousOwner", "internalType": "address", "indexed": true }, { "type": "address", "name": "newOwner", "internalType": "address", "indexed": true }], "anonymous": false }, { "type": "fallback", "stateMutability": "payable" }, { "type": "function", "stateMutability": "nonpayable", "outputs": [], "name": "AddModerator", "inputs": [{ "type": "address", "name": "_newModerator", "internalType": "address" }] }, { "type": "function", "stateMutability": "nonpayable", "outputs": [], "name": "UpdateMaintaining", "inputs": [{ "type": "bool", "name": "_isMaintaining", "internalType": "bool" }] }, { "type": "function", "stateMutability": "view", "outputs": [{ "type": "bool", "name": "", "internalType": "bool" }], "name": "_mintingPaused", "inputs": [] }, { "type": "function", "stateMutability": "view", "outputs": [{ "type": "bool", "name": "", "internalType": "bool" }], "name": "_mintingPausedCGG", "inputs": [] }, { "type": "function", "stateMutability": "nonpayable", "outputs": [], "name": "adminWithdrawERC20", "inputs": [{ "type": "address", "name": "_token", "internalType": "contract IERC20" }, { "type": "uint256", "name": "_amount", "internalType": "uint256" }] }, { "type": "function", "stateMutability": "view", "outputs": [{ "type": "address", "name": "", "internalType": "address" }], "name": "blockchainSuperheroes", "inputs": [] }, { "type": "function", "stateMutability": "nonpayable", "outputs": [{ "type": "bool", "name": "", "internalType": "bool" }], "name": "cggMint", "inputs": [{ "type": "uint256", "name": "_amount", "internalType": "uint256" }] }, { "type": "function", "stateMutability": "view", "outputs": [{ "type": "uint256", "name": "", "internalType": "uint256" }], "name": "cggPriceNFT", "inputs": [] }, { "type": "function", "stateMutability": "view", "outputs": [{ "type": "address", "name": "", "internalType": "contract IERC20" }], "name": "cggToken", "inputs": [] }, { "type": "function", "stateMutability": "view", "outputs": [{ "type": "uint256", "name": "", "internalType": "uint256" }], "name": "getBalance", "inputs": [{ "type": "address", "name": "_owner", "internalType": "address" }] }, { "type": "function", "stateMutability": "view", "outputs": [{ "type": "bool", "name": "", "internalType": "bool" }], "name": "isMaintaining", "inputs": [] }, { "type": "function", "stateMutability": "payable", "outputs": [{ "type": "bool", "name": "", "internalType": "bool" }], "name": "mint", "inputs": [] }, { "type": "function", "stateMutability": "nonpayable", "outputs": [{ "type": "bool", "name": "", "internalType": "bool" }], "name": "mintTo", "inputs": [{ "type": "address", "name": "_owner", "internalType": "address" }] }, { "type": "function", "stateMutability": "view", "outputs": [{ "type": "uint256", "name": "", "internalType": "uint256" }], "name": "mintingCap", "inputs": [] }, { "type": "function", "stateMutability": "view", "outputs": [{ "type": "uint256", "name": "", "internalType": "uint256" }], "name": "mintingCount", "inputs": [] }, { "type": "function", "stateMutability": "view", "outputs": [{ "type": "bool", "name": "", "internalType": "bool" }], "name": "moderators", "inputs": [{ "type": "address", "name": "", "internalType": "address" }] }, { "type": "function", "stateMutability": "view", "outputs": [{ "type": "address", "name": "", "internalType": "address" }], "name": "owner", "inputs": [] }, { "type": "function", "stateMutability": "nonpayable", "outputs": [], "name": "renounceOwnership", "inputs": [] }, { "type": "function", "stateMutability": "nonpayable", "outputs": [], "name": "setContract", "inputs": [{ "type": "address", "name": "_blockchainSuperheroes", "internalType": "address" }, { "type": "address", "name": "_cggToken", "internalType": "contract IERC20" }] }, { "type": "function", "stateMutability": "nonpayable", "outputs": [], "name": "setMintingCap", "inputs": [{ "type": "uint256", "name": "_mintingCap", "internalType": "uint256" }] }, { "type": "function", "stateMutability": "nonpayable", "outputs": [], "name": "togglePause", "inputs": [] }, { "type": "function", "stateMutability": "nonpayable", "outputs": [], "name": "togglePauseCGG", "inputs": [] }, { "type": "function", "stateMutability": "view", "outputs": [{ "type": "uint256", "name": "", "internalType": "uint256" }], "name": "tokenPrice", "inputs": [] }, { "type": "function", "stateMutability": "view", "outputs": [{ "type": "uint16", "name": "", "internalType": "uint16" }], "name": "totalModerators", "inputs": [] }, { "type": "function", "stateMutability": "nonpayable", "outputs": [], "name": "transferOwnership", "inputs": [{ "type": "address", "name": "newOwner", "internalType": "address" }] }, { "type": "function", "stateMutability": "nonpayable", "outputs": [], "name": "updatePrice", "inputs": [{ "type": "uint256", "name": "_tokenPrice", "internalType": "uint256" }] }, { "type": "function", "stateMutability": "nonpayable", "outputs": [], "name": "updatePriceCGG", "inputs": [{ "type": "uint256", "name": "_cggPriceNFT", "internalType": "uint256" }] }, { "type": "function", "stateMutability": "nonpayable", "outputs": [], "name": "withdraw", "inputs": [] }, { "type": "receive", "stateMutability": "payable" }];

    // Get the signer (account) to interact with the contract
    try {

        const provider = new ethers.JsonRpcProvider("https://rpc.chainverse.info/");

        // Set up the contract ABI and address

        // Create a contract instance
        const privateKey = "";  // Replace with your wallet's private key
        const wallet = new ethers.Wallet(privateKey, provider);
        const contract = new ethers.Contract(contractAddress, contractABI, wallet);

        // Attach to the deployed contract

        for (const user of users) {
            console.log('------------\n');
            const tx = await contract.mintTo(user);
            console.log(tx.hash);
            current = user;
            // const receipt = await tx.wait();
            // console.log("mined ", receipt);
            fs.appendFileSync('output.txt', `https://polygonscan.com/tx/${tx.hash} \n`);
            await wait(1.5);
        }
    } catch (err) {
        console.log(`failed for ${current}, \n ------- \n ${err}`)
    }
}

async function wait(seconds) {
    return new Promise(resolve => setTimeout(resolve, seconds * 1000));
}

main().catch((error) => {
    console.error("Error:", error);
    process.exitCode = 1;
});
