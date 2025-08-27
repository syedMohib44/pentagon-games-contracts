const hre = require("hardhat");


async function main() {
  const [addr1] = await hre.ethers.getSigners();
  const pgWhitelistV2 = await ethers.getContractFactory("PGWhitelistV2");
  this.pgWhitelistV2 = await pgWhitelistV2.connect(addr1).deploy();

  console.log("PGWhitelistV2 deployed to:", this.pgWhitelistV2.target);

  // const pgWhitelist = await ethers.getContractFactory("PGWhitelist");
  // this.pgWhitelist = await pgWhitelist.connect(addr1).deploy();

  // console.log("pgWhitelist deployed to:", this.pgWhitelist.target);


  // const pgLogin = await ethers.getContractFactory("PGLogin");
  // this.pgLogin = await pgLogin.connect(addr1).deploy(addr1, 1);

  // console.log("pgWhitelist deployed to:", this.pgLogin.target);

  await new Promise(r => setTimeout(r, 60000));
  await hre.run("verify:verify", {
    address: this.pgWhitelistV2.target,
    contract: "contracts/Misc/PGWhitelistV2.sol:PGWhitelistV2"
  });

  // await hre.run("verify:verify", {
  //   address: this.pgWhitelist.target,
  //   contract: "contracts/Misc/PGWhitelist.sol:PGWhitelist"
  // });

  // await hre.run("verify:verify", {
  //   address: this.pgLogin.target,
  //   contract: "contracts/Misc/PGLogin.sol:PGLogin",
  //   constructorArguments: [addr1.address, 1]
  // });

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
