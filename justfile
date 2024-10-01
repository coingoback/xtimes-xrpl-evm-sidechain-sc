default:
    just --list

build:
    npx hardhat compile

node:
    npx hardhat node

clean:
    npx hardhat clean
    rm -rf coverage
    rm coverage.json

test:
    npx hardhat test

test-gas:
    REPORT_GAS=true \
        npx hardhat test

coverage:
    SOLIDITY_COVERAGE=true \
        npx hardhat coverage
