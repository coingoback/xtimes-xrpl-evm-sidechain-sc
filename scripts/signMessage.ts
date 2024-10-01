import { viem } from "hardhat";

async function main() {
    console.log("-- Sign Message Demo Script");

    const [acc1, acc2] = await viem.getWalletClients();

    const signableMessage = {
        message: 'Hello World!'
    }

    console.log('-- Signing message with Account 1')
    const acc1SignedMessage = await acc1.signMessage(signableMessage);
    console.log(acc1.account.address, acc1SignedMessage);

    console.log('-- Signing message with Account 2')
    const acc2SignedMessage = await acc2.signMessage(signableMessage);
    console.log(acc2.account.address, acc2SignedMessage);
}

main()
