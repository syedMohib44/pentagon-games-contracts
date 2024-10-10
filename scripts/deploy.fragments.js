const hre = require("hardhat");
const path = require('path');
const fs = require('fs');
const XLSX = require('xlsx');


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

// Convert the sheet to JSON (optional, you can work with the raw data)
const jsonData = XLSX.utils.sheet_to_json(worksheet);

const run = async () => {
  for (const result of jsonData) {

    const nameEth = Object.values(result)[col['Name_eth']];
    const classId = Object.values(result)[0];
    const totalSupply = Object.values(result)[16];

    if (typeof (nameEth) == "string" && nameEth) {
      const ticker = `c${nameEth.toUpperCase()}`;

      if (typeof (totalSupply) == 'number' && totalSupply) {
        const supplyWei = hre.ethers.parseEther(totalSupply.toString());
        const [addr1] = await hre.ethers.getSigners();
        const cToken = await ethers.getContractFactory("Fragments");
        this.cToken = await cToken.connect(addr1).deploy(ticker, ticker, supplyWei);
        // console.log(result, ' ++ ', ticker, ' === ', supplyWei)
        const data = `${classId} \t ${ticker} \t\t\t ${this.cToken.target} \n`
        await new Promise(r => setTimeout(r, 60000));

        await hre.run("verify:verify", {
          address: this.cToken.target,
          constructorArguments: [ticker, ticker, supplyWei],
          contract: `contracts/PentaPets/Fragments.sol:Fragments`
        });
        fs.appendFile('fragmentsmapping.txt', data, 'utf-8', (err) => {
          if (err) {
            console.error('Error writing to file:', err);
          } else {
            console.log('File has been written successfully');
          }
        })
      }
    }
    // console.log(result[key])
  }
}
run();