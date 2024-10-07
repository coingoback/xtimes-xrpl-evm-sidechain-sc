import { config, viem, network } from "hardhat";
import { vars } from "hardhat/config";
import { HttpNetworkAccountsConfig } from "hardhat/types";

import { formatUnits } from "viem";

import { xrplevmDevnet } from "../chains";

import "fs";
import { existsSync } from "fs";

async function getPublicClient() {
    return await viem.getPublicClient({ chain: xrplevmDevnet });
}

async function getWalletClient() {
    const { xrplevm_devnet } = config.networks;
    const [address] = (xrplevm_devnet.accounts as HttpNetworkAccountsConfig as `0x${string}`[]);

    return await viem.getWalletClient(address, {chain: xrplevmDevnet});
}

async function getContractAt(contractName: string, address: `0x${string}`)  {
    if (network.name === 'localhost') {
        return await viem.getContractAt(contractName, address);
    }

    const config = {
        client: {
            public: await getPublicClient(),
            wallet: await getWalletClient()
        }
    };

    return await viem.getContractAt(contractName, address, config);
}

async function getContractAddress() {
    const chainId = network.name === 'localhost' ? '31337' : network.config.chainId;

    const ignitionPath = `ignition/deployments/chain-${chainId}/deployed_addresses.json`;

    if (existsSync(ignitionPath)) {
        const data = require(`../${ignitionPath}`);
        return data["XTimesERC20Module#XTimesERC20"];
    }

    return vars.get('XTIMES_ERC20_ADDRESS');
}

function getExplorerUrl() {
    if (network.name === 'localhost') {
        return 'https://simple-blockexplorer-erhant.vercel.app';
    }

    return xrplevmDevnet.blockExplorers.default.url;
}

async function main() {
    const xtimesAddress = await getContractAddress();

    const xtimes = await getContractAt("XTimesERC20", xtimesAddress);

    const name = await xtimes.read.name();
    const symbol = await xtimes.read.symbol();
    const decimals = (await xtimes.read.decimals() as number);

    const totalSupply:string = formatUnits(
        (await xtimes.read.totalSupply() as bigint),
        decimals
    );
    const maxSupply: string = formatUnits(
        (await xtimes.read.maxSupply() as bigint),
        decimals
    );

    const explorerURL = getExplorerUrl();

    const xtimesDeployedInfo = `
    XTimes contract at ${xtimesAddress}
        Name = ${name}
        Symbol = ${symbol}
        Decimals = ${decimals}
        Total Supply = Ⓧ  ${totalSupply}
        Max Supply = Ⓧ  ${maxSupply}

    Check contract on explorer: ${explorerURL}/address/${xtimesAddress}`;

    console.log(xtimesDeployedInfo);
}

main();
