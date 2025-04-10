const hre = require("hardhat");


async function main() {
  const [addr1] = await hre.ethers.getSigners();
  const WPC = await ethers.getContractFactory("WPC");

  
  this.WPC = await WPC.connect(addr1).deploy();
  console.log("WPC deployed to:", this.WPC.target);

  await new Promise(r => setTimeout(r, 60000));

  await hre.run("verify:verify", {
    address: this.WPC.target,
    contract: "contracts/WPC/WPC.sol:WPC"
  });

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
