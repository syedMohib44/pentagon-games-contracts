const hre = require("hardhat");


async function main() {
  const [addr1] = await hre.ethers.getSigners();
  const gunniesKillerContract = await ethers.getContractFactory("GunniesKiller");
  this.gunniesKillerContract = await gunniesKillerContract.connect(addr1).deploy();

  console.log("GunniesKiller deployed to:", this.gunniesKillerContract.target);

  await new Promise(r => setTimeout(r, 60000));
  await hre.run("verify:verify", {
    address: this.gunniesKillerContract.target
  });

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
