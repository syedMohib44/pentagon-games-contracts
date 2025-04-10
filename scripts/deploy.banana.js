const hre = require("hardhat");


async function main() {

  const [addr1] = await hre.ethers.getSigners();
  // const bananaContract = await ethers.getContractFactory("BANANA");
  // this.bananaContract = await bananaContract.connect(addr1).deploy();
 
  // console.log("BANANA deployed to:", this.bananaContract.target);
  await new Promise(r => setTimeout(r, 60000));
  await hre.run("verify:verify", {
    address: '0x70b8C11D954A5bEee2fB011C0e4406F4AF961E99',
    contract: "contracts/Banana/Banana.sol:BANANA"
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
