const hre = require("hardhat");


async function main() {
  const [addr1] = await hre.ethers.getSigners();

  const EchoVaultFactoryProxyAdmin = await ethers.getContractFactory("EchoVaultFactoryProxyAdmin");
  this.EchoVaultFactoryProxyAdmin = await EchoVaultFactoryProxyAdmin.connect(addr1).deploy();
  await this.EchoVaultFactoryProxyAdmin.waitForDeployment();

  console.log("EchoVaultFactoryProxyAdmin deployed to:", this.EchoVaultFactoryProxyAdmin.target);


  const EchoVaultFactory = await ethers.getContractFactory("EchoVaultFactory");
  this.EchoVaultFactory = await EchoVaultFactory.connect(addr1).deploy();
  await this.EchoVaultFactory.waitForDeployment();

  console.log("EchoVaultFactory deployed to:", this.EchoVaultFactory.target);

  // ProxyAdmin, ImplementationApprovalRegistry, PentaswapV2Router02, lpLocker
  const initData = this.EchoVaultFactory.interface.encodeFunctionData("initialize", ["0xc2C031280E02146Cac5CbBFf725f90deB2D7c98d", "0x14ee10ae6A0bE3f18012064BDBF8DA3b90146f6E", "0x60b70E46178CEf34E71B61BDE2E79bbB7bA41706", "0x0000000000000000000000000000000000000000"]);
  console.log("Generated initData:", initData);

  const EchoVaultFactoryProxy = await ethers.getContractFactory("EchoVaultFactoryProxy");
  this.EchoVaultFactoryProxy = await EchoVaultFactoryProxy.connect(addr1).deploy(this.EchoVaultFactory.target, this.EchoVaultFactoryProxyAdmin.target, initData);

  console.log("EchoVaultFactoryProxy deployed to:", this.EchoVaultFactoryProxy.target);


  await new Promise(r => setTimeout(r, 60000));

  // await this.EchoVault.connect(addr1).transferOwnership('0xfD7068dD81706F1b72125F6BF5608fc39561C32A');

  await hre.run("verify:verify", {
    address: this.EchoVaultFactoryProxyAdmin.target,
    contract: "contracts/EchoVault/EchoVaultFactoryProxyAdmin.sol:EchoVaultFactoryProxyAdmin"
  });

  await hre.run("verify:verify", {
    address: this.EchoVaultFactory.target,
    contract: "contracts/EchoVault/EchoVaultFactory.sol:EchoVaultFactory"
  });

  await hre.run("verify:verify", {
    address: this.EchoVaultFactoryProxy.target,
    contract: "contracts/EchoVault/EchoVaultFactoryProxy.sol:EchoVaultFactoryProxy",
    constructorArguments: [this.EchoVaultFactory.target, this.EchoVaultFactoryProxyAdmin.target, initData]
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
