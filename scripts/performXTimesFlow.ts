import { config, viem, network, ignition } from "hardhat";
import XTimesERC20Module from "../ignition/modules/XTimesERC20";


import "fs";
import { rmSync } from "fs";
import { formatUnits } from "viem";

async function main() {
    console.log('Hello World!');

    console.log('Deleting previous deployment folder...');
    rmSync(`contracts/ignition/deployments/chain-31337`, {recursive: true, force:true});

    // console.log('Resetting node...');
    // await network.provider.request({ method: "hardhat_reset", params: []});

    console.log('Deploying contract on node...');
    const {xtimes} = await ignition.deploy(XTimesERC20Module);
    const decimals = (await xtimes.read.decimals() as number);

    const maxSupply = async () => formatUnits(
        (await xtimes.read.maxSupply() as bigint),
        decimals
    );

    const totalSupply = async () => formatUnits(
        (await xtimes.read.totalSupply() as bigint),
        decimals
    );

    const balanceOf = async (addr: `0x${string}`) => formatUnits(
        (await xtimes.read.balanceOf([addr]) as bigint),
        decimals
    );

    console.log(`XTimes deployed to ${await xtimes.address}`);
    console.log(`Max supply is '${await maxSupply()}'`);

    const [owner, treasure, treasurer, secretary, someoneElse ] = await viem.getWalletClients();

    await xtimes.write.establishTreasury([treasure.account.address]);
    console.log(`Treasury established! Supply is '${await totalSupply()}'`);

    await xtimes.write.appointTreasurer([treasurer.account.address]);
    console.log(`Treasurer appointment to '${treasurer.account.address}'`);

    await xtimes.write.issueTokensToTreasure([200_000_000000000000000000n], {account: treasurer.account});
    console.log(`Treasurer issued 200_000 new tokens. Supply is '${await totalSupply()}'`);

    await xtimes.write.appointSecretary([secretary.account.address], {account: treasurer.account});
    console.log(`Secretary appointment to '${secretary.account.address}'`);

    await xtimes.write.transferFromTreasure([someoneElse.account.address, 10_000_000000000000000000n], {account: secretary.account});
    console.log(`Secretary moved 10_000 tokens from treasure founds to account '${someoneElse.account.address}'`);

    console.log(`Secretary account has ${await balanceOf(secretary.account.address)} $XTimes!`);
    console.log(`Account '${someoneElse.account.address}' now has ${await balanceOf(someoneElse.account.address)} $XTimes!`);

    await xtimes.write.burnFromTreasure([50_000_000000000000000000n], {account: treasurer.account});
    console.log(`Treasurer burned 50_000 tokens from treasure founds. Supply is '${await totalSupply()}'`);

    await xtimes.write.burnFromTreasure([25_000_000000000000000000n], {account: secretary.account});
    console.log(`Secretary burned 25_000 tokens from treasure founds. Supply is '${await totalSupply()}'`);

    console.log('Resetting node...');
    await network.provider.request({ method: "hardhat_reset", params: [] });
}

main();
