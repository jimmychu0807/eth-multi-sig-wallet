import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-solhint";
import "hardhat-deploy";

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  defaultNetwork: "hardhat",
  namedAccounts: {
    deployer: {
      default: 0
    },
    // private key: 0x8166f546bab6da521a8369cab06c5d2b9e46670292d85c875ee9ec20e84ffb61
    alice: "0xcd3B766CCDd6AE721141F452C550Ca635964ce71",
    // private key: 0xea6c44ac03bff858b476bba40716402b03e41b8e97e276d1baec7c37d42484a0
    bob: "0x2546BcD3c84621e976D8185a91A922aE77ECEc30",
    // private key: 0x689af8efa8c651a91ad287602527f3af2fe9f6501a7ac4b061667b5a93e037fd
    charlie: "0xbDA5747bFD65F08deb54cb465eB87D40e51B197E",
  },
  networks: {
    hardhat: {
      live: false,
      saveDeployments: false,
      tags: ["local", "test"]
    },
    localhost: {
      live: false,
      saveDeployments: true,
      url: "http://localhost:8545",
      tags: ["local"]
    }
  }
};

export default config;
