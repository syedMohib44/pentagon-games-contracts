const hre = require("hardhat");



async function main() {
  NFT_NAME = "BCSH_Aarin"
  NFT_SYMBOL = "BCSH"
  Min_GasToTransfer = 3000000
  LZ_ENDPOINT = "0x1a44076050125825900e736c501f859c50fE728c"
  const [addr1] = await hre.ethers.getSigners();
  const bcshContract = await ethers.getContractFactory("Blockchain_Superheroes_V2");
  this.bcshContract = await bcshContract.connect(addr1).deploy(NFT_NAME, NFT_SYMBOL, Min_GasToTransfer, LZ_ENDPOINT);
  const BCSH_Distributor = await ethers.getContractFactory("BCSH_Distributor_V2");
  this.BCSH_Distributor = await BCSH_Distributor.connect(addr1).deploy(this.bcshContract.target, "0x0EE959fF4dCd09De340e37013Bf1bf96407d5273");
  const addModeratorTx = await this.bcshContract.connect(addr1).addModerator(this.BCSH_Distributor.target);
  console.log("Blockchain_Superheroes deployed to:", this.bcshContract.target);
  console.log("BCSH_Distributor deployed to:", this.BCSH_Distributor.target);
  await new Promise(r => setTimeout(r, 60000));
  await hre.run("verify:verify", {
    address: this.bcshContract.target,
    constructorArguments: [NFT_NAME, NFT_SYMBOL, Min_GasToTransfer, LZ_ENDPOINT],
  });
  await hre.run("verify:verify", {
    address: this.BCSH_Distributor.target,
    constructorArguments: [this.bcshContract.target, "0x0EE959fF4dCd09De340e37013Bf1bf96407d5273"],
    contract: `contracts/FoundationHero/BCSH_Distributor_V2.sol:BCSH_Distributor_V2`
  });

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
