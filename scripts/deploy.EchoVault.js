const hre = require("hardhat");


async function main() {
  const [addr1] = await hre.ethers.getSigners();

  const EchoVaultProxyAdmin = await ethers.getContractFactory("EchoVaultProxyAdmin");
  this.EchoVaultProxyAdmin = await EchoVaultProxyAdmin.connect(addr1).deploy();

  const EchoVault = await ethers.getContractFactory("EchoVault");
  this.EchoVault = await EchoVault.connect(addr1).deploy();

  const ImplementationApprovalRegistry = await ethers.getContractFactory("ImplementationApprovalRegistry");
  this.ImplementationApprovalRegistry = await ImplementationApprovalRegistry.connect(addr1).deploy();

  const PumpFunBondingCurve = await ethers.getContractFactory("PumpFunBondingCurve");
  this.PumpFunBondingCurve = await PumpFunBondingCurve.connect(addr1).deploy();

  await new Promise(r => setTimeout(r, 60000));

  const PumpFunBondingCurveRegistery = await ethers.getContractFactory("PumpFunBondingCurveRegistery");
  this.PumpFunBondingCurveRegistery = await PumpFunBondingCurveRegistery.connect(addr1).deploy(this.PumpFunBondingCurve.target);

  console.log("EchoVault deployed to:", this.EchoVault.target);

  await new Promise(r => setTimeout(r, 60000));

  await hre.run("verify:verify", {
    address: this.EchoVaultProxyAdmin.target,
    contract: "contracts/EchoVault/EchoVaultProxyAdmin.sol:EchoVaultProxyAdmin"
  });

  await hre.run("verify:verify", {
    address: this.EchoVault.target,
    contract: "contracts/EchoVault/EchoVault.sol:EchoVault"
  });

  await hre.run("verify:verify", {
    address: this.ImplementationApprovalRegistry.target,
    contract: "contracts/EchoVault/ImplementationApprovalRegistry.sol:ImplementationApprovalRegistry"
  });

  await hre.run("verify:verify", {
    address: this.PumpFunBondingCurve.target,
    contract: "contracts/EchoVault/PumpFunBondingCurve.sol:PumpFunBondingCurve"
  });

  await hre.run("verify:verify", {
    address: this.PumpFunBondingCurveRegistery.target,
    contract: "contracts/EchoVault/PumpFunBondingCurveRegistery.sol:PumpFunBondingCurveRegistery",
    constructorArguments: [this.PumpFunBondingCurve.target]
  });

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
