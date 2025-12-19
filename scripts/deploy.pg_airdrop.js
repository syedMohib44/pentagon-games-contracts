const hre = require("hardhat");


async function main() {
  const [addr1] = await hre.ethers.getSigners();
  const nftMiningAirdropContract = await ethers.getContractFactory("PG_Airdrop");
  this.nftMiningAirdropContract = await nftMiningAirdropContract.connect(addr1).deploy();

  console.log("PG_Airdrop deployed to:", this.nftMiningAirdropContract.target);

  await new Promise(r => setTimeout(r, 60000));

  await hre.run("verify:verify", {
    address: this.nftMiningAirdropContract.target,
    contract: "contracts/Mining/PG_Airdrop.sol:PG_Airdrop"
  });

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
