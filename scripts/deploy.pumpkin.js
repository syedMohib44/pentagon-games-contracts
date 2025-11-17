const hre = require("hardhat");


async function main() {
  const [addr1] = await hre.ethers.getSigners();
  
  const pumpkinContract = await ethers.getContractFactory("Pumpkin");
  this.pumpkinContract = await pumpkinContract.connect(addr1).deploy();

  console.log("Pumpkin deployed to:", this.pumpkinContract.target);

  await new Promise(r => setTimeout(r, 60000));
  await hre.run("verify:verify", {
    address: this.pumpkinContract.target
  });

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
