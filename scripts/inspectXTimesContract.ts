import { viem } from "hardhat";
import { xrplevmDevnet } from "../chains";

import { config } from "hardhat";
import { HttpNetworkAccountsConfig } from "hardhat/types";

const { vars } = require("hardhat/config");

async function getPublicClient() {
    return await viem.getPublicClient({ chain: xrplevmDevnet });
}

async function getWalletClient() {
    const { xrplevm_devnet } = config.networks;
    const [address] = (xrplevm_devnet.accounts as HttpNetworkAccountsConfig as `0x${string}`[]);

    return await viem.getWalletClient(address, {chain: xrplevmDevnet});
}

async function getContractAt(contractName: string, address: `0x${string}`)  {
    const config = {
        client: {
            public: await getPublicClient(),
            wallet: await getWalletClient()
        }
    };

    return await viem.getContractAt(contractName, address, config);
}

function getExplorerUrl() {
    return xrplevmDevnet.blockExplorers.default.url;
}

async function main() {
    const xtimesAddress = vars.get('XTIMES_ERC20_ADDRESS');

    const xtimes = await getContractAt("XTimesERC20", xtimesAddress);

    const name = await xtimes.read.name();
    const symbol = await xtimes.read.symbol();
    const decimals = await xtimes.read.decimals();
    const totalSupply = await xtimes.read.totalSupply();

    const explorerURL = getExplorerUrl();

    const xtimesDeployedInfo = `
    XTimes contract at ${xtimesAddress}
        Name = ${name}
        Symbol = ${symbol}
        Decimals = ${decimals}
        Total Supply = Ⓧ  ${totalSupply}

    Check contract on explorer: ${explorerURL}/address/${xtimesAddress}`;

    console.log(xtimesDeployedInfo);
}

main();
