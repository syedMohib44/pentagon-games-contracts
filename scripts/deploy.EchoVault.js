const hre = require("hardhat");


async function main() {
  const [addr1] = await hre.ethers.getSigners();
  const EchoVault = await ethers.getContractFactory("EchoVault");


  this.EchoVault = await EchoVault.connect(addr1).deploy("NFTProf", "PROF", "0xB2e3e82a95f5c4c47E30A5b420Ac4f99d32EF61f", "0xB2e3e82a95f5c4c47E30A5b420Ac4f99d32EF61f");
  console.log("EchoVault deployed to:", this.EchoVault.target);

  await new Promise(r => setTimeout(r, 60000));

  await hre.run("verify:verify", {
    address: this.EchoVault.target,
    contract: "contracts/EchoVault/EchoVault.sol:EchoVault",
    constructorArguments: ["NFTProf", "PROF", "0xB2e3e82a95f5c4c47E30A5b420Ac4f99d32EF61f", "0xB2e3e82a95f5c4c47E30A5b420Ac4f99d32EF61f"]
  });

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
