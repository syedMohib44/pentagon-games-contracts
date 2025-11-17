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
          metadata: {
            bytecodeHash: "none", // disable ipfs
            useLiteralContent: true, // use source code
          },
          optimizer: {
            enabled: true,
            runs: 200,
          },
          viaIR: true
        },
      }
    ],
  },
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true
    },
    eth: {
      url: 'https://eth.llamarpc.com',
      accounts: [PRIVATE_KEY]
    },
    coretestnet: {
      url: `https://rpc.test.btcs.network`,
      accounts: [PRIVATE_KEY]
    },
    core: {
      url: `https://rpc.coredao.org`,
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
    monadtestnet: {
      url: "https://testnet-rpc.monad.xyz",
      accounts: [PRIVATE_KEY]
    },
    pentestnet: {
      url: `https://rpc-testnet.pentagon.games`,
      accounts: [PRIVATE_KEY],
      gas: 2100000,
      gasPrice: 8000000000, // Adjust as necessary
      timeout: 1000000 // Adjust the timeout as needed
    },
    penmainnet: {
      url: `https://rpc.pentagon.games`,
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
      accounts: [PRIVATE_KEY]
    },
    nebula: {
      url: `https://mainnet-proxy.skalenodes.com/v1/green-giddy-denebola`,
      accounts: [PRIVATE_KEY]
    },
    arbitrumOne: {
      url: 'https://arb1.arbitrum.io/rpc',
      accounts: [PRIVATE_KEY]
    },
    // nebula: {
    //   url: 'https://testnet.skalenodes.com/v1/lanky-ill-funny-testnet',
    //   accounts: [PRIVATE_KEY]
    // },
    polygonamoy: {
      url: `https://rpc-amoy.polygon.technology`,
      accounts: [PRIVATE_KEY],
      gasPrice: 30000000000
    },
    avax: {
      url: `https://api.avax.network/ext/bc/C/rpc`,
      accounts: [PRIVATE_KEY]
    }
  },
  etherscan: {
  enabled: true,
    apiKey: {
      mainnet: process.env.ETH_API_KEY,
      coretestnet: process.env.CORE_TESTNET_API_KEY,
      monadtestnet: process.env.ETH_API_KEY,
      core: process.env.CORE_API_KEY,
      polygonamoy: process.env.ETH_API_KEY,
      arbitrumOne: process.env.ARB_API_KEY,
      polygon: process.env.AMOY_API_KEY,
      bsc: process.env.BNB_API_KEY,
      xai: process.env.XAI_API_KEY,
      pentestnet: 'pentestnet',
      penmainnet: 'penmainnet',
      avalanche: 'avalanche',
      nebula: 'nebula'
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
        network: "core",
        chainId: 1116,
        urls: {
          apiURL: "https://openapi.coredao.org//api/",
          browserURL: "https://scan.coredao.org/"
        }
      },
      // {
      //   network: "nebula",
      //   chainId: 37084624,
      //   urls: {
      //     apiURL: "https://internal.explorer.testnet.skalenodes.com:10001/api/",
      //     browserURL: "https://lanky-ill-funny-testnet.explorer.testnet.skalenodes.com/"
      //   }
      // },
      {
        network: "chainverse",
        chainId: 5555,
        urls: {
          apiURL: "https://explorer.chainverse.info/:///api",
          browserURL: "https://explorer.chainverse.info/"
        }
      },
      // {
      //   network: "monadtestnet",
      //   chainId: 10143,
      //   urls: {
      //     apiURL: "https://testnet.monadscan.com/api", 
      //     browserURL: "https://testnet.monadscan.com"
      //   }
      // },
      {
        network: "nebula",
        chainId: 1482601649,
        urls: {
          // Correct public API URL
          apiURL: "https://green-giddy-denebola.explorer.mainnet.skalenodes.com/api",
          browserURL: "https://green-giddy-denebola.explorer.mainnet.skalenodes.com/"
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
        network: "penmainnet",
        chainId: 3344,
        urls: {
          apiURL: "https://explorer.pentagon.games/api",
          browserURL: "https://explorer.pentagon.games/"
        }
      },
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
          apiURL: "https://api.etherscan.io/v2/api?chainid=80002",
          browserURL: "https://amoy.polygonscan.com/"
        }
      }
    ]
  },
  sourcify: {
    enabled: false,
    apiUrl: "https://sourcify-api-monad.blockvision.org",
    browserUrl: "https://testnet.monadexplorer.com",
  },

};