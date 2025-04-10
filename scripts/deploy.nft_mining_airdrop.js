const hre = require("hardhat");


async function main() {
  const [addr1] = await hre.ethers.getSigners();
  const nftMiningAirdropContract = await ethers.getContractFactory("NFT_MINING_AIRDROP");
  this.nftMiningAirdropContract = await nftMiningAirdropContract.connect(addr1).deploy();

  console.log("Farming deployed to:", this.nftMiningAirdropContract.target);

  await new Promise(r => setTimeout(r, 60000));
  // await this.nftMiningAirdropContract.connect(addr1).transferOwnership('0xB2e3e82a95f5c4c47E30A5b420Ac4f99d32EF61f');
  // await new Promise(r => setTimeout(r, 60000));

  await hre.run("verify:verify", {
    address: this.nftMiningAirdropContract.target,
    contract: "contracts/Mining/NFT_MINING_AIRDROP.sol:NFT_MINING_AIRDROP"
  });

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
