const hre = require("hardhat");


async function main() {
  const [addr1] = await hre.ethers.getSigners();
  const ZOR_MINING_AIRDROP = await ethers.getContractFactory("ZOR_MINING_AIRDROP");


  this.ZOR_MINING_AIRDROP = await ZOR_MINING_AIRDROP.connect(addr1).deploy();
  console.log("ZOR_MINING_AIRDROP deployed to:", this.ZOR_MINING_AIRDROP.target);

  await new Promise(r => setTimeout(r, 60000));

  await hre.run("verify:verify", {
    address: this.ZOR_MINING_AIRDROP.target,
    contract: "contracts/ZOR/ZOR_MINING_AIRDROP.sol:ZOR_MINING_AIRDROP"
  });

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
