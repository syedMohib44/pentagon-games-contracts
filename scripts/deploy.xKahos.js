const hre = require("hardhat");


async function main() {
  const [addr1] = await hre.ethers.getSigners();
  // const xKahos = await ethers.getContractFactory("xKHAOS");
  const KhaosReward = await ethers.getContractFactory("KhaosReward");


  // this.xKahos = await xKahos.connect(addr1).deploy();
  // console.log("xKahos deployed to:", this.xKahos.target);


  this.KhaosReward = await KhaosReward.connect(addr1).deploy();
  console.log("KhaosReward deployed to:", this.KhaosReward.target);

  await new Promise(r => setTimeout(r, 60000));

  // await hre.run("verify:verify", {
  //   address: this.xKahos.target,
  //   contract: "contracts/Khaos/xKHAOS.sol:xKHAOS",
  // });

  await hre.run("verify:verify", {
    address: this.KhaosReward.target,
    contract: "contracts/Khaos/KhaosRewards.sol:KhaosReward"
  });

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
