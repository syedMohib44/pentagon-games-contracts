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
  const initData = this.EchoVaultFactory.interface.encodeFunctionData("initialize", ["0xFDc0c8eE2E728509A4b37572dB983b6CB500025D", "0xda8888DFaCB2e39373F510CD84E46A923AfBABb2"]);

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
