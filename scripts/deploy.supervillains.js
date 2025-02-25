const hre = require("hardhat");



async function main() {
  NFT_NAME = "BlockchainSupervillains"
  NFT_SYMBOL = "BCSH"
  Min_GasToTransfer = 3000000
  LZ_ENDPOINT = "0x82b7dc04A4ABCF2b4aE570F317dcab49f5a10f24"
  const [addr1] = await hre.ethers.getSigners();
  const bcshContract = await ethers.getContractFactory("Blockchain_Supervillains");
  this.bcshContract = await bcshContract.connect(addr1).deploy(NFT_NAME, NFT_SYMBOL, Min_GasToTransfer, LZ_ENDPOINT);
  const BCSH_Distributor = await ethers.getContractFactory("BCSV_Distributor");
  this.BCSH_Distributor = await BCSH_Distributor.connect(addr1).deploy(this.bcshContract.target);
  const addModeratorTx = await this.bcshContract.connect(addr1).AddModerator(this.BCSH_Distributor.target);
  console.log("Blockchain_Superheroes deployed to:", this.bcshContract.target);
  console.log("BCSH_Distributor deployed to:", this.BCSH_Distributor.target);
  await new Promise(r => setTimeout(r, 60000));
  await hre.run("verify:verify", {
    address: this.bcshContract.target,
    constructorArguments: [NFT_NAME, NFT_SYMBOL, Min_GasToTransfer, LZ_ENDPOINT],
  });
  await hre.run("verify:verify", {
    address: this.BCSH_Distributor.target,
    constructorArguments: [this.bcshContract.target],
  });

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
