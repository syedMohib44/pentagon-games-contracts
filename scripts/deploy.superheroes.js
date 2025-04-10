const hre = require("hardhat");


// async function main() {
//   NFT_NAME = "BlockChainSuperHeros"
//   NFT_SYMBOL = "BCSH"
//   Min_GasToTransfer = 260000
//   LZ_ENDPOINT = "0xae92d5aD7583AD66E49A0c67BAd18F6ba52dDDc1"
//   const [addr1] = await hre.ethers.getSigners();
//   const bcshContract = await ethers.getContractFactory("Blockchain_Superheroes");
//   this.bcshContract = await bcshContract.connect(addr1).deploy(NFT_NAME, NFT_SYMBOL, Min_GasToTransfer, LZ_ENDPOINT);
//   const BCSH_Distributor = await ethers.getContractFactory("BCSH_Distributor");
//   this.BCSH_Distributor = await BCSH_Distributor.connect(addr1).deploy(this.bcshContract.target);
//   const addModeratorTx = await this.bcshContract.connect(addr1).AddModerator(this.BCSH_Distributor.target);
//   console.log("Blockchain_Superheroes deployed to:", this.bcshContract.target);
//   console.log("BCSH_Distributor deployed to:", this.BCSH_Distributor.target);
//   await new Promise(r => setTimeout(r, 60000));
//   await hre.run("verify:verify", {
//     address: this.bcshContract.target,
//     constructorArguments: [NFT_NAME, NFT_SYMBOL, Min_GasToTransfer, LZ_ENDPOINT],
//   });
//   await hre.run("verify:verify", {
//     address: this.BCSH_Distributor.target,
//     constructorArguments: [this.bcshContract.target],
//   });

// }

// main().catch((error) => {
//   console.error(error);
//   process.exitCode = 1;
// });


async function main() {
  NFT_NAME = "BlockchainSuperheros"
  NFT_SYMBOL = "BCSH"
  Min_GasToTransfer = 3000000
  LZ_ENDPOINT = "0x1a44076050125825900e736c501f859c50fE728c"
  const [addr1] = await hre.ethers.getSigners();
  const bcshContract = await ethers.getContractFactory("Blockchain_Superheroes");
  this.bcshContract = await bcshContract.connect(addr1).deploy(NFT_NAME, NFT_SYMBOL, Min_GasToTransfer, LZ_ENDPOINT);
  const BCSH_Distributor = await ethers.getContractFactory("BCSH_Distributor");
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
    contract: `contracts/SuperHeroes/BCSH_Distributor.sol:BCSH_Distributor`
  });

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
