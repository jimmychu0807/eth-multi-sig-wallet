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
  },
  networks: {
    hardhat: {
      live: false,
      tags: ["local", "test"]
    },
    localhost: {
      live: false,
      url: "http://localhost:8545",
      tags: ["local"]
    }
  }
};

export default config;
