const hre = require("hardhat");

async function main() {
  const [addr1] = await hre.ethers.getSigners();

  const gunniesSBTContract = await ethers.getContractFactory("Gunnies");
  
  // FIX: Separate the name and symbol into two strings
  this.gunniesSBTContract = await gunniesSBTContract.connect(addr1).deploy("Gunnies", "GNS");

  await this.gunniesSBTContract.waitForDeployment();
  console.log("Gunnies deployed to:", this.gunniesSBTContract.target);

  const gunniesSBTDistributorContract = await ethers.getContractFactory("GunniesDistributor");
  this.gunniesSBTDistributorContract = await gunniesSBTDistributorContract.connect(addr1).deploy(this.gunniesSBTContract.target);

  await this.gunniesSBTDistributorContract.waitForDeployment();
  console.log("GunniesDistributor deployed to:", this.gunniesSBTDistributorContract.target);

  console.log("Waiting for block confirmations...");
  await new Promise(r => setTimeout(r, 60000));

  const addModeratorTx = await this.gunniesSBTContract.connect(addr1).addModerator(this.gunniesSBTDistributorContract.target);
  await addModeratorTx.wait();
  console.log("Distributor added as Moderator.");

  // FIX: Also update verification arguments
  await hre.run("verify:verify", {
    address: this.gunniesSBTContract.target,
    constructorArguments: ["Gunnies", "GSBT"]
  });

  await hre.run("verify:verify", {
    address: this.gunniesSBTDistributorContract.target,
    constructorArguments: [this.gunniesSBTContract.target]
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});