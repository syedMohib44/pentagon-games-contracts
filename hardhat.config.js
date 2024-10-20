require('dotenv').config();
require("@nomicfoundation/hardhat-toolbox");


const PRIVATE_KEY = process.env.PRIVATE_KEY
const CORE_API_KEY = process.env.CORE_API_KEY
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.22",
        settings: {

          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      }
    ],
  },
  networks: {
    coretestnet: {
      url: `https://rpc.test.btcs.network`,
      accounts: [PRIVATE_KEY]
    },
    pentestnet: {
      url: `https://rpc-testnet.pentagon.games`,
      accounts: [PRIVATE_KEY]
    },
    polygonamoy: {
      url: `https://rpc-amoy.polygon.technology`,
      accounts: [PRIVATE_KEY]
    }
  },
  etherscan: {
    apiKey: {
      coretestnet: process.env.CORE_TESTNET_API_KEY,
      polygonamoy: process.env.AMOY_API_KEY,
      pentestnet: 'pentestnet'
    },
    customChains: [
      {
        network: "coretestnet",
        chainId: 1115,
        urls: {
          apiURL: "https://api.test.btcs.network/api",
          browserURL: "https://scan.test.btcs.network"
        }
      },
      {
        network: "pentestnet",
        chainId: 555555,
        urls: {
          apiURL: "https://api.explorer-testnet.pentagon.zeeve.online/api",
          browserURL: "https://explorer-testnet.pentagon.games/"
        }
      },
      {
        network: "polygonamoy",
        chainId: 80002,
        urls: {
          apiURL: "https://api-amoy.polygonscan.com/api",
          browserURL: "https://amoy.polygonscan.com/"
        }
      }
    ]
  }

};