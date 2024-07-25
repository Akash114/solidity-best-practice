# Smart Contract Development Guide with Foundry

This guide provides detailed, practical steps for developing smart contracts using Foundry.

## Table of Contents

1. [Setting Up Your Foundry Project](#setting-up-your-foundry-project)
2. [Writing Smart Contracts](#writing-smart-contracts)
3. [Managing Dependencies](#managing-dependencies)
4. [Writing Tests](#writing-tests)
5. [Gas Optimization](#gas-optimization)
6. [Deployment Scripts](#deployment-scripts)
7. [Documentation](#documentation)
8. [Continuous Integration](#continuous-integration)
9. [Security Considerations](#security-considerations)

## Setting Up Your Foundry Project

### Install Foundry

```
curl -L https://foundry.paradigm.xyz | bash
foundryup
```


### Create a new project

```
forge init my_project
cd my_project
```

### Project structure

```

my_project/
├── lib/
├── src/
├── test/
├── script/
└── foundry.toml
```

### Writing Smart Contracts

Create your contract in the src/ directory

```
src/MyToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20, Ownable {
    uint256 public constant MAX_SUPPLY = 1000000 * 10**18;

    constructor() ERC20("MyToken", "MTK") {
        _mint(msg.sender, MAX_SUPPLY);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        require(totalSupply() + amount <= MAX_SUPPLY, "Exceeds max supply");
        _mint(to, amount);
    }
}
```


### Use Foundry's cheatcodes for advanced functionality

```bash
import "forge-std/console.sol";

contract MyContract {
    function debugFunction() public view {
        console.log("This is a debug message");
    }
}
```

### Managing Dependencies

Install OpenZeppelin contracts

```
forge install OpenZeppelin/openzeppelin-contracts
```

Add remappings to foundry.toml

```
[profile.default]
remappings = ["@openzeppelin/=lib/openzeppelin-contracts/"]
```

### Writing Tests

Create test files in the test/ directory

```
// test/MyToken.t.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/MyToken.sol";

contract MyTokenTest is Test {
    MyToken public token;
    address public owner;
    address public user;

    function setUp() public {
        owner = address(this);
        user = address(0x1);
        token = new MyToken();
    }

    function testInitialSupply() public {
        assertEq(token.totalSupply(), token.MAX_SUPPLY());
    }

    function testMint() public {
        uint256 amount = 1000 * 10**18;
        token.mint(user, amount);
        assertEq(token.balanceOf(user), amount);
    }
}

```

Run tests

```
forge test
```

Use Foundry's fuzzing capabilities

```
function testFuzzMint(address to, uint256 amount) public {
    vm.assume(to != address(0) && amount <= token.MAX_SUPPLY());
    token.mint(to, amount);
    assertEq(token.balanceOf(to), amount);
}
```

### Gas Optimization

Use Foundry's gas reporting

```
forge test --gas-report
```

Optimize your contract

- Use unchecked blocks for arithmetic that can't overflow
- Pack variables to use fewer storage slots
- Use events instead of storing data you don't need on-chain

### Deployment Scripts

Create a deployment script in the script/ directory

```
// script/DeployMyToken.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/MyToken.sol";

contract DeployMyToken is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        MyToken token = new MyToken();

        vm.stopBroadcast();
    }
}
```

Run the deployment script

```
forge script script/DeployMyToken.s.sol:DeployMyToken --rpc-url <your_rpc_url> --broadcast
```

### Documentation

Use NatSpec comments for all public functions and state variables

```
/// @notice Mints new tokens to the specified address
/// @param to The address to receive the minted tokens
/// @param amount The amount of tokens to mint
function mint(address to, uint256 amount) external onlyOwner {
    // Function implementation
}
```

Generate documentation

```
forge doc
```

### Continuous Integration

1. Set up a CI pipeline using GitHub Actions or similar tools

2. Include steps for:

- Compiling contracts
- Running tests
- Checking gas usage
- Generating documentation



### Security Considerations

1. Use Foundry's capabilities to test edge cases and potential vulnerabilities
2. Consider using static analysis tools like Slither in your development process
3. Always conduct thorough testing before deploying to mainnet
4. Consider professional audits for complex or high-value contracts

Remember to always refer back to the design principles and best practices while developing your smart contracts. This guide focuses on the practical aspects of using Foundry for development, testing, and deployment.
