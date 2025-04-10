const hre = require("hardhat");


async function main() {
  const [addr1] = await hre.ethers.getSigners();
  const expedition = await ethers.getContractFactory("Expedition");
  //PEN -> USDT
  // StakeToken is reward token which is USDT here
  // lpToken would be PEN token
  this.expedition = await expedition.connect(addr1).deploy('0xde38A82580EF1071549312f59a304427248741e3', false, '0xB2e3e82a95f5c4c47E30A5b420Ac4f99d32EF61f', '0xB2e3e82a95f5c4c47E30A5b420Ac4f99d32EF61f');
  await new Promise(r => setTimeout(r, 30000));

  // xWPENx TEST
  await this.expedition.connect(addr1).addPool('0xa15dCbeF3Ec498C9d6f7bE9655bbec61bcf331BF', 2553226, 2578516, 100, '115740740000000', 0, 50, 50);
  
  // await new Promise(r => setTimeout(r, 30000));
  // await this.expedition.connect(addr1).transferOwnership('0xB2e3e82a95f5c4c47E30A5b420Ac4f99d32EF61f');



  console.log("Farming deployed to:", this.expedition.target);

  await new Promise(r => setTimeout(r, 60000));

  await hre.run("verify:verify", {
    address: this.expedition.target,
    constructorArguments: ['0x4356592b6CB360c25EfC2f6AFC2bB55266A1ab7E', false, '0xB2e3e82a95f5c4c47E30A5b420Ac4f99d32EF61f', '0xB2e3e82a95f5c4c47E30A5b420Ac4f99d32EF61f']
  });

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
