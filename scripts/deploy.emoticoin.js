const hre = require("hardhat");


async function main() {
  const [addr1] = await hre.ethers.getSigners();

  const EmotiCoinProxyAdmin = await ethers.getContractFactory("EmotiCoinProxyAdmin");
  this.EmotiCoinProxyAdmin = await EmotiCoinProxyAdmin.connect(addr1).deploy();
  console.log("EmotiCoinProxyAdmin deployed to:", this.EmotiCoinProxyAdmin.target);

  const EmotiCoin = await ethers.getContractFactory("EmotiCoin");
  this.EmotiCoin = await EmotiCoin.connect(addr1).deploy();

  const ImplementationApprovalRegistry = await ethers.getContractFactory("ImplementationApprovalRegistry");
  this.ImplementationApprovalRegistry = await ImplementationApprovalRegistry.connect(addr1).deploy();
  console.log("ImplementationApprovalRegistry deployed to:", this.ImplementationApprovalRegistry.target);


  await new Promise(r => setTimeout(r, 60000));

  await hre.run("verify:verify", {
    address: this.EmotiCoinProxyAdmin.target,
    contract: "contracts/EmotiCoin/EmotiCoinProxyAdmin.sol:EmotiCoinProxyAdmin"
  });

  await hre.run("verify:verify", {
    address: this.EmotiCoin.target,
    contract: "contracts/EmotiCoin/EmotiCoin.sol:EmotiCoin"
  });

  await hre.run("verify:verify", {
    address: this.ImplementationApprovalRegistry.target,
    contract: "contracts/EmotiCoin/ImplementationApprovalRegistry.sol:ImplementationApprovalRegistry"
  });

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
