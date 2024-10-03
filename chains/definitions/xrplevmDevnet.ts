import { defineChain } from "viem"

export const xrplevmDevnet = defineChain({
    id: 1440002,
    name: 'XRPL EVM Sidechain Devnet',
    nativeCurrency: {
        decimals: 18,
        name: 'eXRP',
        symbol: 'XRP'
    },
    rpcUrls: {
        default: {
            http: ['https://rpc-evm-sidechain.xrpl.org'],
        },
    },
    blockExplorers: {
        default: {
            name: 'XRPL EVM Sidechain Devnet Explorer',
            url: 'https://explorer.xrplevm.org',
            apiUrl: 'https://explorer.xrplevm.org/api',
        },
    },
    testnet: true
});
