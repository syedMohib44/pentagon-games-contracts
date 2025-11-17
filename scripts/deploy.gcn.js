const hre = require("hardhat");

async function main() {
  const [addr1] = await hre.ethers.getSigners();

  // Use the fully qualified name to specify the exact contract
  const GCNShardsContract = await ethers.getContractFactory(
    "contracts/Gunnies/GCNShards.sol:GCNShards"
  );

  this.GCNShardsContract = await GCNShardsContract.connect(addr1).deploy();

  // It's better to wait for the deployment to be confirmed
  await this.GCNShardsContract.waitForDeployment();


  const GCNNFTContract = await ethers.getContractFactory(
    "contracts/Gunnies/GCN721Main.sol:GCN721Main"
  );
  console.log("GCNShards deployed to:", this.GCNShardsContract.target);

  this.GCNNFTContract = await GCNNFTContract.connect(addr1).deploy();

  // It's better to wait for the deployment to be confirmed
  await this.GCNNFTContract.waitForDeployment();
  console.log("GCNNFTContract deployed to:", this.GCNNFTContract.target);


  const GCNCraftingRouter = await ethers.getContractFactory(
    "contracts/Gunnies/GCNCraftingRouter.sol:GCNCraftingRouter"
  );
  this.GCNCraftingRouter = await GCNCraftingRouter.connect(addr1).deploy(this.GCNShardsContract.target, this.GCNNFTContract.target, "0x0000000000000000000000000000000000000000");

  // It's better to wait for the deployment to be confirmed
  await this.GCNCraftingRouter.waitForDeployment();
  console.log("GCNCraftingRouter deployed to:", this.GCNCraftingRouter.target, [this.GCNShardsContract.target, this.GCNNFTContract.target, "0x0000000000000000000000000000000000000000"]);

  // A 60-second wait is good for public networks to allow for block propagation
  console.log("Waiting for 60 seconds before verification...");


  await new Promise(r => setTimeout(r, 60000));

  await hre.run("verify:verify", {
    address: this.GCNShardsContract.target,
    contract: "contracts/Gunnies/GCNShards.sol:GCNShards"
  });

  await hre.run("verify:verify", {
    address: this.GCNNFTContract.target,
    contract: "contracts/Gunnies/GCN721Main.sol:GCN721Main"
  });

  await hre.run("verify:verify", {
    address: this.GCNCraftingRouter.target,
    contract: "contracts/Gunnies/GCNCraftingRouter.sol:GCNCraftingRouter",
    constructorArguments: [this.GCNShardsContract.target, this.GCNNFTContract.target, "0x0000000000000000000000000000000000000000"]
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});