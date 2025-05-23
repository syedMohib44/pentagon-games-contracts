const hre = require("hardhat");



async function main() {
  NFT_NAME = "BCSH_Aarin_Receipt"
  NFT_SYMBOL = "BCSH"

  const [addr1] = await hre.ethers.getSigners();
  const bcshContract = await ethers.getContractFactory("BCSH_Hero_Receipt");
  this.bcshContract = await bcshContract.connect(addr1).deploy(NFT_NAME, NFT_SYMBOL);

  console.log("Blockchain_Superheroes deployed to:", this.bcshContract.target);

  await new Promise(r => setTimeout(r, 60000));
  await hre.run("verify:verify", {
    address: this.bcshContract.target,
    constructorArguments: [NFT_NAME, NFT_SYMBOL]
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
