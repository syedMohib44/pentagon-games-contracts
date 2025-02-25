const hre = require("hardhat");


async function main() {
  const [addr1] = await hre.ethers.getSigners();
  const miningContract = await ethers.getContractFactory("MiningFee");
  this.miningContract = await miningContract.connect(addr1).deploy();

  console.log("Farming deployed to:", this.miningContract.target);

  await new Promise(r => setTimeout(r, 60000));
  await hre.run("verify:verify", {
    address: this.miningContract.target
  });

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
