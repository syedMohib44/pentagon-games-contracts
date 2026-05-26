const hre = require("hardhat");


async function main() {
  const [addr1] = await hre.ethers.getSigners();
  
  const disperseContract = await ethers.getContractFactory("Disperse");
  this.disperseContract = await disperseContract.connect(addr1).deploy();

  console.log("GunniesKiller deployed to:", this.disperseContract.target);

  await new Promise(r => setTimeout(r, 60000));
  await hre.run("verify:verify", {
    address: this.disperseContract.target
  });

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
