import type { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox-viem";

const { vars } = require("hardhat/config");

const config: HardhatUserConfig = {
  solidity: "0.8.27",

  networks: {
    // XRPL EVM Sidechain Devnet
    xrplevm_devnet: {
      url: "https://rpc-evm-sidechain.xrpl.org",
      chainId: 1440002,
      accounts: [
        vars.get('XRPL_EVM_SIDECHAIN_KEY_DEVNET')
      ]
    }
  }
};

export default config;
