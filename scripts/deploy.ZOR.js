const hre = require("hardhat");


async function main() {
  const [addr1] = await hre.ethers.getSigners();
  const ZOR = await ethers.getContractFactory("ZOR");

  
  this.ZOR = await ZOR.connect(addr1).deploy();
  console.log("ZOR deployed to:", this.ZOR.target);

  await new Promise(r => setTimeout(r, 60000));

  await hre.run("verify:verify", {
    address: this.ZOR.target,
    contract: "contracts/ZOR/ZOR.sol:ZOR"
  });

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
