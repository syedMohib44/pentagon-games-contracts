const hre = require("hardhat");


async function main() {
  const [addr1] = await hre.ethers.getSigners();
  const paymentProcessor = await ethers.getContractFactory("PaymentProcessor");
  this.paymentProcessor = await paymentProcessor.connect(addr1).deploy();

  console.log("PaymentProcessor deployed to:", this.paymentProcessor.target);

  await new Promise(r => setTimeout(r, 60000));
  await hre.run("verify:verify", {
    address: this.paymentProcessor.target,
    contract: "contracts/PaymentProcessor/PaymentProcessor.sol:PaymentProcessor"
  });

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
