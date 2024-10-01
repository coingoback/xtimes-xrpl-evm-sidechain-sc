default:
    just --list

build:
    npx hardhat compile

test:
    npx hardhat test

coverage:
    SOLIDITY_COVERAGE=true npx hardhat coverage
