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
  // 0x01FdcC3cFeeb608eE4E43b49A3Cc015eB5514307
  // address is proxy admin
  // ProxyAdmin, ImplementationApprovalRegistry
  const initData = this.EchoVaultFactory.interface.encodeFunctionData("initialize", ["0x7613B4638c4b034aB9E859Ba8f07429B5d6f9845", "0xb91d3247eF5166f01260a4255AAf8239D1445Cbd"]);

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
