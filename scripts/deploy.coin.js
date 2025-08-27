const hre = require("hardhat");


async function main() {
  const [addr1] = await hre.ethers.getSigners();
  const gunniesCoin = await ethers.getContractFactory("Coin");
  this.gunniesCoin = await gunniesCoin.connect(addr1).deploy();

  console.log("GunniesCoin deployed to:", this.gunniesCoin.target);

  await new Promise(r => setTimeout(r, 60000));
  await hre.run("verify:verify", {
    address: this.gunniesCoin.target,
    contract: "contracts/Gunnies/Coin.sol:Coin"
  });

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
