const hre = require("hardhat");


async function main() {
  const [addr1] = await hre.ethers.getSigners();
  const WPEN = await ethers.getContractFactory("WPEN");

  
  this.WPEN = await WPEN.connect(addr1).deploy();
  console.log("WPEN deployed to:", this.WPEN.target);

  await new Promise(r => setTimeout(r, 60000));

  await hre.run("verify:verify", {
    address: this.WPEN.target,
    contract: "contracts/WPEN/WPEN.sol:WPEN"
  });

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
