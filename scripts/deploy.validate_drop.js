const hre = require("hardhat");


async function main() {
  const [addr1] = await hre.ethers.getSigners();
  const ValidatedEngagementReceiptDrop = await ethers.getContractFactory("ValidatedEngagementReceiptDrop");
  this.ValidatedEngagementReceiptDrop = await ValidatedEngagementReceiptDrop.connect(addr1).deploy();

  console.log("ValidatedEngagementReceiptDrop deployed to:", this.ValidatedEngagementReceiptDrop.target);

  await new Promise(r => setTimeout(r, 60000));
  // await this.nftMiningAirdropContract.connect(addr1).transferOwnership('0xB2e3e82a95f5c4c47E30A5b420Ac4f99d32EF61f');
  // await new Promise(r => setTimeout(r, 60000));

  await hre.run("verify:verify", {
    address: this.ValidatedEngagementReceiptDrop.target,
    contract: "contracts/ValidatedEngagementReceiptDrop/ValidatedEngagementReceiptDrop.sol:ValidatedEngagementReceiptDrop"
  });

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
