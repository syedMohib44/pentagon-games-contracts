const hre = require("hardhat");


async function main() {
  const [addr1] = await hre.ethers.getSigners();

  // const CharacterNFT = await ethers.getContractFactory("CharacterNFT");
  // this.CharacterNFT = await CharacterNFT.connect(addr1).deploy();
  // await this.CharacterNFT.waitForDeployment();

  // console.log("CharacterNFT deployed to:", this.CharacterNFT.target);


  // const EthPackBridge = await ethers.getContractFactory("EthPackBridge");
  // this.EthPackBridge = await EthPackBridge.connect(addr1).deploy();
  // await this.EthPackBridge.waitForDeployment();

  // console.log("EthPackBridge deployed to:", this.EthPackBridge.target);


  // const AutoDungeon = await ethers.getContractFactory("AutoDungeon");
  // this.AutoDungeon = await AutoDungeon.connect(addr1).deploy(this.CharacterNFT.target, this.EthPackBridge.target);
  // await this.AutoDungeon.waitForDeployment();

  // console.log("AutoDungeon deployed to:", this.AutoDungeon.target);


  const PackSales = await ethers.getContractFactory("PackSales");
  this.PackSales = await PackSales.connect(addr1).deploy("0x21Ec95441C7cb2fce29e2e2aa700dB866e383fFe", "0x9bb4EB544791fB3Bd5162E8A6d20a0144877B9f6");
  await this.PackSales.waitForDeployment();

  console.log("PackSales deployed to:", this.PackSales.target);


  // const SoulForge = await ethers.getContractFactory("SoulForge");
  // this.SoulForge = await SoulForge.connect(addr1).deploy(this.CharacterNFT.target, this.AutoDungeon.target, this.EthPackBridge.target);
  // await this.SoulForge.waitForDeployment();

  // console.log("SoulForge deployed to:", this.SoulForge.target);


  await new Promise(r => setTimeout(r, 60000));


  // await hre.run("verify:verify", {
  //   address: this.CharacterNFT.target,
  //   contract: "contracts/EtherFantasy/CharacterNFT.sol:CharacterNFT"
  // });

  // await hre.run("verify:verify", {
  //   address: this.EthPackBridge.target,
  //   contract: "contracts/EtherFantasy/EthPackBridge.sol:EthPackBridge",
  // });
  
  // await hre.run("verify:verify", {
  //   address: this.AutoDungeon.target,
  //   contract: "contracts/EtherFantasy/AutoDungeon.sol:AutoDungeon",
  //   constructorArguments: [this.CharacterNFT.target, this.EthPackBridge.target]
  // });

  await hre.run("verify:verify", {
    address: this.PackSales.target,
    contract: "contracts/EtherFantasy/PackSales.sol:PackSales",
    constructorArguments: ["0x21Ec95441C7cb2fce29e2e2aa700dB866e383fFe", "0x9bb4EB544791fB3Bd5162E8A6d20a0144877B9f6"]
  });

  // await hre.run("verify:verify", {
  //   address: this.SoulForge.target,
  //   contract: "contracts/EtherFantasy/SoulForge.sol:SoulForge",
  //   constructorArguments: [this.CharacterNFT.target, this.AutoDungeon.target, this.EthPackBridge.target]
  // });

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
