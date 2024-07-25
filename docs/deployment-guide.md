# Smart Contract Deployment Guide with Foundry

This guide provides a step-by-step approach to deploying smart contracts using Foundry.

## Table of Contents

1. [Introduction](#introduction)
2. [Prerequisites](#prerequisites)
3. [Deployment Script](#deployment-script)
4. [Configuration](#configuration)
5. [Deployment Process](#deployment-process)
6. [Verifying Contracts](#verifying-contracts)
7. [Post-Deployment Steps](#post-deployment-steps)
8. [Best Practices](#best-practices)

## Introduction

Deploying smart contracts is a critical step in the development process. Foundry provides powerful tools to streamline this process and make it more reliable.

## Prerequisites

- Foundry installed and updated to the latest version
- A compiled smart contract
- Access to an Ethereum node (local or remote)
- Sufficient ETH for gas fees in your deployer account

## Deployment Script

Create a deployment script in the `script/` directory of your Foundry project:

```solidity
// script/DeployMyContract.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/MyContract.sol";

contract DeployMyContract is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        MyContract myContract = new MyContract();

        vm.stopBroadcast();
    }
}
```

## Configuration

1. Set up your .env file with necessary environment variables:

```
PRIVATE_KEY=your_private_key_here
ETHERSCAN_API_KEY=your_etherscan_api_key_here
RPC_URL=your_rpc_url_here
```

2. Update your foundry.toml file:

```
[profile.default]
src = 'src'
out = 'out'
libs = ['lib']
remappings = ['@openzeppelin/=lib/openzeppelin-contracts/']

[rpc_endpoints]
mainnet = "${RPC_URL}"

[etherscan]
mainnet = { key = "${ETHERSCAN_API_KEY}" }
```

## Deployment Process

1. Compile your contracts:

```
forge build
```

2. Run the deployment script:

```
forge script script/DeployMyContract.s.sol:DeployMyContract --rpc-url ${RPC_URL} --broadcast --verify -vvvv
```

This command will:

- Run the deployment script
- Broadcast the transaction to the specified network
- Attempt to verify the contract on Etherscan

## Verifying Contracts

If the automatic verification fails, you can manually verify your contract:

```
forge verify-contract --chain-id 1 <DEPLOYED_CONTRACT_ADDRESS> src/MyContract.sol:MyContract --watch --constructor-args $(cast abi-encode "constructor()" <arg1> <arg2>)
```

Replace <DEPLOYED_CONTRACT_ADDRESS>, <arg1>, <arg2>, etc., with your actual values.


## Post-Deployment Steps

- Save the deployed contract address for future reference.
- Update any frontend applications or other contracts that need to interact with this newly deployed contract.
- Perform a test transaction to ensure the contract is working as expected on the live network.

## Best Practices

1. Use a testnet first: Always deploy to a testnet (like Goerli or Sepolia) before deploying to mainnet.
2. Double-check everything: Verify all parameters, addresses, and initial values before deploying.
3. Gas optimization: Monitor the gas costs of your deployment and optimize if necessary.
4. Keep private keys secure: Never commit private keys to your repository. Always use environment variables.
5. Version control: Tag your repository with the version you're deploying.
6. Documentation: Document the deployment process, including any specific parameters or steps taken.
7. Monitoring: Set up monitoring for your deployed contract to track usage and potential issues.
8. Upgradeability: If your contract is upgradeable, document the upgrade process clearly.
9. Multi-sig wallets: Consider using a multi-sig wallet for contract ownership and critical functions.
10. Emergency stop: Implement and test any emergency stop or pause functionality before deployment.

Remember, deploying a smart contract is a significant step. Always double-check your work and consider having your deployment process reviewed by another developer before executing on mainnet.
