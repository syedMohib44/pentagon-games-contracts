const hre = require("hardhat");


async function main() {
  const [addr1] = await hre.ethers.getSigners();
  const friendsAndFamilyContract = await ethers.getContractFactory("FriendsAndFamily");
  this.friendsAndFamilyContract = await friendsAndFamilyContract.connect(addr1).deploy();
  
  console.log("FriendsAndFamily deployed to:", this.friendsAndFamilyContract.target);
  
  // await new Promise(r => setTimeout(r, 60000));
  // const addModeratorTx = await this.friendsAndFamilyContract.connect(addr1).transferOwnership('0xB2e3e82a95f5c4c47E30A5b420Ac4f99d32EF61f');
  await new Promise(r => setTimeout(r, 60000));

  await hre.run("verify:verify", {
    address: this.friendsAndFamilyContract.target
  });

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
