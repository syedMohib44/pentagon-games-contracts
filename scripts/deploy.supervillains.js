const hre = require("hardhat");



async function main() {
  NFT_NAME = "BlockchainSupervillains"
  NFT_SYMBOL = "BCSV"
  Min_GasToTransfer = 3000000
  LZ_ENDPOINT = "0x82b7dc04A4ABCF2b4aE570F317dcab49f5a10f24"
  const [addr1] = await hre.ethers.getSigners();
  console.log(addr1)
  const bcshContract = await ethers.getContractFactory("Blockchain_Supervillains");
  this.bcshContract = await bcshContract.connect(addr1).deploy(NFT_NAME, NFT_SYMBOL, Min_GasToTransfer, LZ_ENDPOINT);
  const BCSH_Distributor = await ethers.getContractFactory("BCSV_Distributor");
  this.BCSH_Distributor = await BCSH_Distributor.connect(addr1).deploy(this.bcshContract.target, "0x7F73B66d4e6e67bCdeaF277b9962addcDabBFC4d");
  await new Promise(r => setTimeout(r, 60000));
  const addModeratorTx = await this.bcshContract.connect(addr1).addModerator(this.BCSH_Distributor.target);
  console.log("Blockchain_Superheroes deployed to:", this.bcshContract.target);
  console.log("BCSH_Distributor deployed to:", this.BCSH_Distributor.target);

  await hre.run("verify:verify", {
    address: this.bcshContract.target,
    constructorArguments: [NFT_NAME, NFT_SYMBOL, Min_GasToTransfer, LZ_ENDPOINT],
    contract: "contracts/SuperVillain/SuperVillainsWithMint_SKL.sol:Blockchain_Supervillains"
  });

  await hre.run("verify:verify", {
    address: this.BCSH_Distributor.target,
    constructorArguments: [this.bcshContract.target, "0x7F73B66d4e6e67bCdeaF277b9962addcDabBFC4d"],
    contract: "contracts/SuperVillain/BCSV_Distributor.sol:BCSV_Distributor"
  });

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
