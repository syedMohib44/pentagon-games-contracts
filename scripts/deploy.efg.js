const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  const treasuryAddress = deployer.address; // Change this to your actual treasury wallet

  console.log("Deploying contracts with the account:", deployer.address);

  // 1. Deploy EFG (The NFT Contract)
  const EFG = await hre.ethers.getContractFactory("EFG");
  const efg = await EFG.deploy();
  await efg.waitForDeployment();
  const efgAddress = await efg.getAddress();
  console.log("EFG deployed to:", efgAddress);

  // 2. Deploy EFGDistributor
  // Constructor: address _efg, address payable _treasury
  const EFGDistributor = await hre.ethers.getContractFactory("EFGDistributor");
  const distributor = await EFGDistributor.deploy(efgAddress, treasuryAddress);
  await distributor.waitForDeployment();
  const distributorAddress = await distributor.getAddress();
  console.log("EFGDistributor deployed to:", distributorAddress);

  // 3. Setup Permissions
  // The Distributor needs moderator role to call efg.mint()
  console.log("Setting up permissions...");
  const addModTx = await efg.addModerator(distributorAddress);
  await addModTx.wait();
  
  // Optional: Set the distributor address on the EFG contract if needed for logic
  const setDistTx = await efg.setDistributor(distributorAddress);
  await setDistTx.wait();
  console.log("Permissions and Distributor reference set.");

  // 4. Wait for Block Confirmations (Better for verification than a static timeout)
  console.log("Waiting for block confirmations...");
  const deploymentReceipt = await distributor.deploymentTransaction().wait(6);

  // 5. Verification
  console.log("Starting verification...");

  try {
    await hre.run("verify:verify", {
      address: efgAddress,
      constructorArguments: [],
    });

    await hre.run("verify:verify", {
      address: distributorAddress,
      constructorArguments: [efgAddress, treasuryAddress],
    });
    console.log("Verification complete!");
  } catch (error) {
    console.error("Verification failed:", error.message);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});