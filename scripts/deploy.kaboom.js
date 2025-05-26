const hre = require("hardhat");



async function main() {
  NFT_NAME = "Kaboom Pass"
  NFT_SYMBOL = "KABOOM"

  const [addr1] = await hre.ethers.getSigners();
  const kaboomContract = await ethers.getContractFactory("Kaboom_Pass");
  this.kaboomContract = await kaboomContract.connect(addr1).deploy(NFT_NAME, NFT_SYMBOL);
  const Kaboom_Distributor = await ethers.getContractFactory("Kaboom_Distributor");
  this.Kaboom_Distributor = await Kaboom_Distributor.connect(addr1).deploy(this.kaboomContract.target, "0x0000000000000000000000000000000000000000");
  const addModeratorTx = await this.kaboomContract.connect(addr1).addModerator(this.Kaboom_Distributor.target);
  console.log("Kaboom_Pass deployed to:", this.kaboomContract.target);
  console.log("Kaboom_Distributor deployed to:", this.Kaboom_Distributor.target);
  
  await new Promise(r => setTimeout(r, 60000));
  
  await hre.run("verify:verify", {
    address: this.kaboomContract.target,
    constructorArguments: [NFT_NAME, NFT_SYMBOL]
  });
  await hre.run("verify:verify", {
    address: this.Kaboom_Distributor.target,
    constructorArguments: [this.kaboomContract.target, "0x0000000000000000000000000000000000000000"],
    contract: `contracts/Kaboom_Pass/Kaboom_Distributor.sol:Kaboom_Distributor`
  });

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
