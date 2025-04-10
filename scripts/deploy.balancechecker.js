const hre = require("hardhat");


async function main() {
  const [addr1] = await hre.ethers.getSigners();
  const balanceChecker = await ethers.getContractFactory("BalanceChecker");
  this.balanceChecker = await balanceChecker.connect(addr1).deploy();
  
  console.log("BalanceChecker deployed to:", this.balanceChecker.target);
  
  await new Promise(r => setTimeout(r, 60000));

  await hre.run("verify:verify", {
    address: this.balanceChecker.target
  });

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
