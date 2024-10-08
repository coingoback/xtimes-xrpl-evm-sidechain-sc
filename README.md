# XTimes ERC20 Token
![Xrp](https://img.shields.io/badge/Xrp-black?style=for-the-badge&logo=xrp&logoColor=white)![Solidity](https://img.shields.io/badge/Solidity-%23363636.svg?style=for-the-badge&logo=solidity&logoColor=white)![Ethereum](https://img.shields.io/badge/Ethereum-3C3C3D?style=for-the-badge&logo=Ethereum&logoColor=white)



Smart Contract code for the `XTimes` **ERC20** Token from `Cointimes`, being developed to be deployed on `XRPL-EVM` sidechain.



##### Running Locally

Use `just` command to list available commands from `just` recipe.

```shell
$just node # Start a local Hardhat node to interact with
$just deploy XTimesERC20 localhost # Deploy the contract to running Hardhat local node
$just run-script inspectXTimesContract localhost # Inspect information for deployed contract
just run-script performXtimesFlow localhost # Interacts with the contract performing its initialization and establishing the treasury, appointing a treasurer and a secretary to perform issue(mint)/burn/transfer of XTimes tokens from/to the treasurer.

```



**Notice**: This contract is functional but not complete nor bulletproof. It uses interaction scripts to test the expected and desired functionality, but it does not cover all cases for possible bugs.
