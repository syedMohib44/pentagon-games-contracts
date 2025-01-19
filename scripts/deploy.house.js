const hre = require("hardhat");


async function main() {
  NFT_NAME = "LineCityEstate"
  NFT_SYMBOL = "LCE"

  const [addr1] = await hre.ethers.getSigners();
  const houseContract = await ethers.getContractFactory("LineCityEstate");
  this.houseContract = await houseContract.connect(addr1).deploy(NFT_NAME, NFT_SYMBOL);
 
  console.log("House deployed to:", this.houseContract.target);
  await new Promise(r => setTimeout(r, 60000));
  await hre.run("verify:verify", {
    address: this.houseContract.target,
    constructorArguments: [NFT_NAME, NFT_SYMBOL],
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
