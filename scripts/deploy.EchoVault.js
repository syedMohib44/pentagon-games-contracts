const hre = require("hardhat");


async function main() {
  const [addr1] = await hre.ethers.getSigners();
  const EchoVault = await ethers.getContractFactory("EchoVault");


  this.EchoVault = await EchoVault.connect(addr1).deploy("Noi", "GABBA", "0x0000000000000000000000000000000000000000", "0x64580f95d510aF1Ea24B73F6d4481894BFfd296C");
  console.log("EchoVault deployed to:", this.EchoVault.target);

  await new Promise(r => setTimeout(r, 60000));

  await this.EchoVault.connect(addr1).transferOwnership('0xfD7068dD81706F1b72125F6BF5608fc39561C32A');

  await hre.run("verify:verify", {
    address: this.EchoVault.target,
    contract: "contracts/EchoVault/EchoVault.sol:EchoVault",
    constructorArguments: ["Noi", "GABBA", "0x0000000000000000000000000000000000000000", "0x64580f95d510aF1Ea24B73F6d4481894BFfd296C"]
  });

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
