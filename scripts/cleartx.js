const { ethers, JsonRpcProvider } = require('ethers')

const run = async () => {
    const provider = new JsonRpcProvider('https://polygon-rpc.com/');
    const wallet = new ethers.Wallet("7a323dd01f866e472b41f8dfdb70b446dfae53593da6724c90b8d28a4f05ad2a", provider);

    const start = 12318;
    for (let index = 12318; index < 12319; index++) {
        const tx = {
            to: wallet,
            value: ethers.parseEther('0'), // Sending 0 MATIC to yourself
            nonce: index, // Use the same nonce as the stuck transaction
            gasLimit: 2100000,
            gasPrice: ethers.parseUnits('300', 'gwei'), // Adjust as needed
        };
        const transaction = await wallet.sendTransaction(tx);
        console.log(`Transaction hash: ${transaction.hash}`);
    }

}

run();