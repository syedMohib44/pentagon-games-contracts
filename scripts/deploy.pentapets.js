const hre = require("hardhat");
const path = require('path');
const fs = require('fs');
const XLSX = require('xlsx');


async function main() {

  const filePath = path.resolve(__dirname, '../public/pentapets.csv');
  const results = [];

  const col = {
    'class_id_eth': 0,
    'Name_eth': 1,
    'Rarity_eth': 2,
    'Number of V1_eth': 3,
    'Fragments per V1_eth': 4,
    'class_id_pol': 6,
    'Name_pol': 7,
    'Rarity_pol': 8,
    'Number of V1_pol': 9,
    'Fragments per V1_pol': 10,
    'Name': 12,
    'Rarity': 13,
    'Total V1': 14,
    'User V2': 15,
    'Team v2': 16,
    'Max V2': 17,
    'Max ERC Tokens': 18,
    'NB V1 to get 1xV2': 19,
    'Fragments per V1': 20,
    'TOTAL FRAGMENTS': 22,
    'MAX NB OF V2': 23
  }

  const workbook = XLSX.readFile(filePath);

  const sheetName = workbook.SheetNames[0];

  // Get the sheet data
  const worksheet = workbook.Sheets[sheetName];
  let maxERC721Token = [];
  let maxERC20Tokens = [];
  let classIdArr = [];
  const addresses = [];

  // Convert the sheet to JSON (optional, you can work with the raw data)
  const jsonData = XLSX.utils.sheet_to_json(worksheet);

  for (const result of jsonData) {
    const classId = Object.values(result)[0];
    const maxERC20 = Object.values(result)[16];
    const maxERC721 = Object.values(result)[15];

    const totalSupply = Object.values(result)[16];
    if (typeof (classId) == "number" && classId) {

      if (typeof (totalSupply) == 'number' && totalSupply) {
        if (typeof (maxERC721) == 'number' && maxERC721) {
          maxERC20Tokens.push(maxERC20)
          maxERC721Token.push(maxERC721);
          classIdArr.push(classId);
        }
      }
    }
    // console.log(result[key])
  }
  classIdArr = classIdArr.slice(0, 6);
  maxERC721Token = maxERC721Token.slice(0, 6);
  maxERC20Tokens = maxERC20Tokens.slice(0, 6);

  console.log(`${classIdArr}, \n\n ${maxERC721Token}`)

  NFT_NAME = "PentaPets"
  NFT_SYMBOL = "PP"
  const erc20Frags = [
    "0xbd57A13e6B99c06f79621b4EA6d9710a2e91269d",
    "0x34A046CF230b8a44Eac5B2C06797A8aCB68Cde87",
    "0xe7C9C21fC29ec01E88d077C3Ccb80914ccf3fb1C",
    "0x2B5D0D3F64dd3aEBd105326745AA64b105cD681f",
    "0x56788C25be05e3387C0e5b4dAF4859A032031E2C",
    "0xD5FEeCbD879DD980a639b0eE2737e5245904F8c4"];

  const [addr1] = await hre.ethers.getSigners();
  const ppContract = await ethers.getContractFactory("PentaPets");
  this.ppContract = await ppContract.connect(addr1).deploy(NFT_NAME, NFT_SYMBOL, classIdArr, maxERC721Token);
  const ppDistributor = await ethers.getContractFactory("PentaPets_Distributor");
  this.ppDistributor = await ppDistributor.connect(addr1).deploy(this.ppContract.target, classIdArr, erc20Frags);
  const addModeratorTx = await this.ppContract.connect(addr1).AddModerator(this.ppDistributor.target);
  console.log("PentaPets deployed to:", this.ppContract.target);
  console.log("PentaPets_Distributor deployed to:", this.ppDistributor.target);

  await new Promise(r => setTimeout(r, 60000));

  await hre.run("verify:verify", {
    address: this.ppContract.target,
    constructorArguments: [NFT_NAME, NFT_SYMBOL, classIdArr, maxERC721Token],
    contract: `contracts/PentaPets/PentaPets.sol:PentaPets`
  });
  await hre.run("verify:verify", {
    address: this.ppDistributor.target,
    constructorArguments: [this.ppContract.target, classIdArr, erc20Frags],
    contract: `contracts/PentaPets/PentaPets_Distributor.sol:PentaPets_Distributor`
  });

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
