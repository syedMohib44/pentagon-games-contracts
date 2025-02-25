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
    eth: {
      url: 'https://mainnet.infura.io/v3/2142eded1e254fe08c4b37b74f1ccc41',
      accounts: [PRIVATE_KEY]
    },
    coretestnet: {
      url: `https://rpc.test.btcs.network`,
      accounts: [PRIVATE_KEY]
    },
    xai: {
      url: `https://rpc.test.btcs.network`,
      accounts: [PRIVATE_KEY]
    },
    bsc: {
      url: `https://bsc-dataseed.binance.org/`,
      accounts: [PRIVATE_KEY]
    },
    pentestnet: {
      url: `https://rpc-testnet.pentagon.games`,
      accounts: [PRIVATE_KEY],
      gas: 2100000,
      gasPrice: 8000000000, // Adjust as necessary
      timeout: 1000000 // Adjust the timeout as needed
    },
    chainverse: {
      url: `https://rpc.chainverse.info/`,
      accounts: [PRIVATE_KEY],
      gas: 2100000,
      gasPrice: 600000000000, // Adjust as necessary
    },
    polygon: {
      url: `https://polygon-rpc.com/`,
      accounts: [PRIVATE_KEY],
      gas: 21000000,
      gasPrice: 3000000000000, // Adjust as necessary
    },
    arbitrumOne: {
      url: 'https://arb1.arbitrum.io/rpc',
      accounts: [PRIVATE_KEY]
    },
    polygonamoy: {
      url: `https://rpc-amoy.polygon.technology`,
      accounts: [PRIVATE_KEY]
    },
    avax: {
      url: `https://api.avax.network/ext/bc/C/rpc`,
      accounts: [PRIVATE_KEY]
    }
  },
  etherscan: {
    apiKey: {
      mainnet: process.env.ETH_API_KEY,
      coretestnet: process.env.CORE_TESTNET_API_KEY,
      polygonamoy: process.env.AMOY_API_KEY,
      arbitrumOne: process.env.ARB_API_KEY,
      polygon: process.env.AMOY_API_KEY,
      bsc: process.env.BNB_API_KEY,
      xai: process.env.XAI_API_KEY,
      pentestnet: 'pentestnet',
      avalanche: 'avalanche'
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
        network: "chainverse",
        chainId: 5555,
        urls: {
          apiURL: "https://explorer.chainverse.info/:///api",
          browserURL: "https://explorer.chainverse.info/"
        }
      },
      {
        network: "arbitrumOne",
        chainId: 42161,
        urls: {
          apiURL: "https://api.arbiscan.io/api",
          browserURL: "https://arbiscan.io/"
        }
      },
      // {
      //   network: "bnb",
      //   chainId: 56,
      //   urls: {
      //     apiURL: "https://bscscan.com/apis",
      //     browserURL: "https://bscscan.com/"
      //   }
      // },
      {
        network: "pentestnet",
        chainId: 555555,
        urls: {
          apiURL: "https://explorer-testnet.pentagon.games/api",
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