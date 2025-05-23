const hre = require("hardhat");


async function main() {
  const [addr1] = await hre.ethers.getSigners();
  const xRUNZ_v2 = await ethers.getContractFactory("CZ_DailyRunz_Checkin");

  
  this.xRUNZ_v2 = await xRUNZ_v2.connect(addr1).deploy();
  console.log("CZ_DailyRunz_Checkin deployed to:", this.xRUNZ_v2.target);

  await new Promise(r => setTimeout(r, 60000));

  // await hre.run("verify:verify", {
  //   address: this.xRUNZ_v2.target,
  //   contract: "contracts/xRUNZ/CZ_DailyRunz_Checkin.sol:CZ_DailyRunz_Checkin"
  // });

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
