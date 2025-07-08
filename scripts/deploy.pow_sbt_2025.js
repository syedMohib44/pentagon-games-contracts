const hre = require("hardhat");



async function main() {
  NFT_NAME = "POW_SBT_2025"
  NFT_SYMBOL = "POW_25"

  const [addr1] = await hre.ethers.getSigners();
  const pow_25 = await ethers.getContractFactory("POW_SBT_2025");
  this.pow_25 = await pow_25.connect(addr1).deploy(NFT_NAME, NFT_SYMBOL);

  console.log("POW_SBT_2025 deployed to:", this.pow_25.target);

  await new Promise(r => setTimeout(r, 60000));
  await hre.run("verify:verify", {
    address: this.pow_25.target,
    constructorArguments: [NFT_NAME, NFT_SYMBOL]
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
