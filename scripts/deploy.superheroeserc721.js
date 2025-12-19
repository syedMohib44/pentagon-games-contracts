const hre = require("hardhat");

async function main() {
  NFT_NAME = "BlockchainSuperheroes"
  NFT_SYMBOL = "BCSH"
  const [addr1] = await hre.ethers.getSigners();

  const bcshContract = await ethers.getContractFactory("Blockchain_Superheroes_ERC721");
  this.bcshContract = await bcshContract.connect(addr1).deploy(NFT_NAME, NFT_SYMBOL);
  const BCSH_Distributor = await ethers.getContractFactory("BCSH_Distributor");
  this.BCSH_Distributor = await BCSH_Distributor.connect(addr1).deploy(this.bcshContract.target);
  const addModeratorTx = await this.bcshContract.connect(addr1).addModerator(this.BCSH_Distributor.target);
  console.log("Blockchain_Superheroes deployed to:", this.bcshContract.target);
  console.log("BCSH_Distributor deployed to:", this.BCSH_Distributor.target);
  await new Promise(r => setTimeout(r, 60000));
  await hre.run("verify:verify", {
    address: this.bcshContract.target,
    constructorArguments: [NFT_NAME, NFT_SYMBOL]
  });
  await hre.run("verify:verify", {
    address: this.BCSH_Distributor.target,
    constructorArguments: [this.bcshContract.target],
    contract: `contracts/SuperHeroes/BCSH_Distributor.sol:BCSH_Distributor`
  });

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
