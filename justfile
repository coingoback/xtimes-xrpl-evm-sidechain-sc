default:
    just --list

build:
    npx hardhat compile

deploy module network:
    npx hardhat ignition deploy ./ignition/modules/{{module}}.ts --network {{network}}

node:
    npx hardhat node

clean:
    npx hardhat clean
    rm -rf coverage
    rm coverage.json

run-script script:
    npx hardhat run scripts/{{script}}.ts --network localhost

test:
    npx hardhat test

test-gas:
    REPORT_GAS=true \
        npx hardhat test

coverage:
    SOLIDITY_COVERAGE=true \
        npx hardhat coverage
