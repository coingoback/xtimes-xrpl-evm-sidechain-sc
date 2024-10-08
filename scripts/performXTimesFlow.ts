import { config, viem, network, ignition } from "hardhat";
import XTimesERC20Module from "../ignition/modules/XTimesERC20";


import "fs";
import { rmSync } from "fs";

async function main() {
    console.log('Hello World!');

    console.log('Deleting previous deployment folder...');
    rmSync(`contracts/ignition/deployments/chain-31337`, {recursive: true, force:true});

    // console.log('Resetting node...');
    // await network.provider.request({ method: "hardhat_reset", params: []});

    console.log('Deploying contract on node...');
    const {xtimes} = await ignition.deploy(XTimesERC20Module);

    console.log(`XTimes deployed to ${await xtimes.address}`);
    console.log(`Max supply is '${await xtimes.read.maxSupply()}'`);

    const [owner, treasure, treasurer, secretary, someoneElse ] = await viem.getWalletClients();

    await xtimes.write.establishTreasury([treasure.account.address]);
    console.log(`Treasury established! Supply is '${await xtimes.read.totalSupply()}'`);

    await xtimes.write.appointTreasurer([treasurer.account.address]);
    console.log(`Treasurer appointment to '${treasurer.account.address}'`);

    await xtimes.write.mint([200_000_000000000000000000n], {account: treasurer.account});
    console.log(`Treasurer minted 200_000 tokens. Supply is '${await xtimes.read.totalSupply()}'`);

    await xtimes.write.appointSecretary([secretary.account.address], {account: treasurer.account});
    console.log(`Secretary appointment to '${secretary.account.address}'`);

    //await xtimes.write.mint([20_000n], {account: secretary.account});

    console.log('Resetting node...');
    await network.provider.request({ method: "hardhat_reset", params: [] });
}

main();
