const { ethers } = require("ethers");
const fs = require("fs");
require("dotenv").config();

const RPC_URL = "https://rpc-amoy.polygon.technology/";
const CONTRACT_ADDRESS = "0xCe4A196e00Bf998e057851ee82B74963CB3e1093";
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const OUTPUT_FILE = "./test_results1.json";
const CONCURRENCY = 1;
const TOTAL_ITERATIONS = 100;

const ABI = [
    "function erc20Mint() public returns (bool)",
    "event Mint(address indexed owner, uint256 token)",
    "event ZORRewarded(address indexed owner, uint256 amount)",
];


const provider = new ethers.JsonRpcProvider(RPC_URL);
const wallet = new ethers.Wallet(PRIVATE_KEY, provider);
const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, wallet);


const results = [];


async function processMint(iteration, nonce) {
    const result = {
        iteration,
        txHash: null,
        status: null,
        reward: null,
        error: null,
        timestamp: new Date().toISOString(),
    };

    try {
        console.log(`Executing mint #${iteration} with nonce ${nonce}...`);
        const tx = await contract.erc20Mint({ nonce });
        const receipt = await tx.wait();


        const mintEvent = receipt.logs
            .map((log) => {
                try {
                    return contract.interface.parseLog(log);
                } catch {
                    return null;
                }
            })
            .find((log) => log && log.name === "Mint");

        const zorEvent = receipt.logs
            .map((log) => {
                try {
                    return contract.interface.parseLog(log);
                } catch {
                    return null;
                }
            })
            .find((log) => log && log.name === "ZORRewarded");

        result.txHash = receipt.transactionHash;
        result.status = "success";
        if (mintEvent) {
            result.reward = {
                type: "NFT",
                owner: mintEvent.args.owner,
                tokenId: mintEvent.args.token.toString(),
            };
        } else if (zorEvent) {
            result.reward = {
                type: "ZOR",
                owner: zorEvent.args.owner,
                amount: ethers.formatUnits(zorEvent.args.amount, 18),
            };
        } else {
            result.reward = "No Mint or ZORRewarded event emitted";
        }

        console.log(`Mint #${iteration} succeeded: ${result.txHash}`);
    } catch (error) {
        result.status = "failed";
        result.error = error.message;
        console.error(`Mint #${iteration} failed: ${error.message}`);
    }

    return result;
}


async function testMint() {
    console.log(`Starting ${TOTAL_ITERATIONS} mint transactions with ${CONCURRENCY} concurrent calls...`);

    let nonce = await wallet.getNonce();
    let currentIteration = 1;

    while (currentIteration <= TOTAL_ITERATIONS) {
        const batch = [];

        for (let i = 0; i < CONCURRENCY && currentIteration <= TOTAL_ITERATIONS; i++) {
            batch.push(await processMint(currentIteration, nonce));
            nonce++;
            currentIteration++;
            await new Promise(r => setTimeout(r, 30000));
        }


        const batchResults = await Promise.all(batch);
        results.push(...batchResults);


        fs.writeFileSync(OUTPUT_FILE, JSON.stringify(results, null, 2));


        nonce = await wallet.getNonce();
    }

    console.log(`Completed ${TOTAL_ITERATIONS} mint transactions. Results saved to ${OUTPUT_FILE}`);
}

testMint().catch((error) => {
    console.error("Script failed:", error);
});