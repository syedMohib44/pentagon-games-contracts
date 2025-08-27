const hre = require("hardhat");


async function main() {
  const [addr1] = await hre.ethers.getSigners();
  const gunniesKarrot = await ethers.getContractFactory("Karrot");
  this.gunniesKarrot = await gunniesKarrot.connect(addr1).deploy();

  console.log("GunniesKarrot deployed to:", this.gunniesKarrot.target);

  await new Promise(r => setTimeout(r, 60000));
  await hre.run("verify:verify", {
    address: this.gunniesKarrot.target,
    contract: "contracts/Gunnies/Karrot.sol:Karrot"
  });

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
