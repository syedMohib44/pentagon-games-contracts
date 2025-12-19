const hre = require("hardhat");


async function main() {
  const [addr1] = await hre.ethers.getSigners();

  const EmotiCoinFactoryProxyAdmin = await ethers.getContractFactory("EmotiCoinFactoryProxyAdmin");
  this.EmotiCoinFactoryProxyAdmin = await EmotiCoinFactoryProxyAdmin.connect(addr1).deploy();
  await this.EmotiCoinFactoryProxyAdmin.waitForDeployment();

  console.log("EmotiCoinFactoryProxyAdmin deployed to:", this.EmotiCoinFactoryProxyAdmin.target);


  const EmotiCoinFactory = await ethers.getContractFactory("EmotiCoinFactory");
  this.EmotiCoinFactory = await EmotiCoinFactory.connect(addr1).deploy();
  await this.EmotiCoinFactory.waitForDeployment();

  console.log("EmotiCoinFactory deployed to:", this.EmotiCoinFactory.target);

  // ProxyAdmin, ImplementationApprovalRegistry, PentaswapV2Router02, lpLocker
  const initData = this.EmotiCoinFactory.interface.encodeFunctionData("initialize", ["0x125C89A513D62cd2280e75533cC377b7C39Ed5b9", "0x93C444D9b887E7cA45e913976ff33Ac16fb157Db", "0x60b70E46178CEf34E71B61BDE2E79bbB7bA41706", "0x0000000000000000000000000000000000000000"]);
  console.log("Generated initData:", initData);

  const EmotiCoinFactoryProxy = await ethers.getContractFactory("EmotiCoinFactoryProxy");
  this.EmotiCoinFactoryProxy = await EmotiCoinFactoryProxy.connect(addr1).deploy(this.EmotiCoinFactory.target, this.EmotiCoinFactoryProxyAdmin.target, initData);

  console.log("EmotiCoinFactoryProxy deployed to:", this.EmotiCoinFactoryProxy.target);


  await new Promise(r => setTimeout(r, 60000));

  // await this.EmotiCoin.connect(addr1).transferOwnership('0xfD7068dD81706F1b72125F6BF5608fc39561C32A');

  await hre.run("verify:verify", {
    address: this.EmotiCoinFactoryProxyAdmin.target,
    contract: "contracts/EmotiCoin/EmotiCoinFactoryProxyAdmin.sol:EmotiCoinFactoryProxyAdmin"
  });

  await hre.run("verify:verify", {
    address: this.EmotiCoinFactory.target,
    contract: "contracts/EmotiCoin/EmotiCoinFactory.sol:EmotiCoinFactory"
  });

  await hre.run("verify:verify", {
    address: this.EmotiCoinFactoryProxy.target,
    contract: "contracts/EmotiCoin/EmotiCoinFactoryProxy.sol:EmotiCoinFactoryProxy",
    constructorArguments: [this.EmotiCoinFactory.target, this.EmotiCoinFactoryProxyAdmin.target, initData]
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

