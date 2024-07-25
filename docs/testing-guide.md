# Smart Contract Testing Guide with Foundry

This guide provides a comprehensive approach to testing smart contracts using Foundry, including various types of tests and testing mechanisms.

## Table of Contents

1. [Introduction to Testing with Foundry](#introduction-to-testing-with-foundry)
2. [Setting Up Your Test Environment](#setting-up-your-test-environment)
3. [Types of Tests](#types-of-tests)
   - [Unit Tests](#unit-tests)
   - [Integration Tests](#integration-tests)
   - [Functional Tests](#functional-tests)
   - [Property-Based Tests](#property-based-tests)
4. [Testing Mechanisms](#testing-mechanisms)
   - [State Tests](#state-tests)
   - [Behavior Tests](#behavior-tests)
   - [Event Tests](#event-tests)
   - [Revert Tests](#revert-tests)
   - [Fuzzing](#fuzzing)
   - [Invariant Tests](#invariant-tests)
   - [Differential Tests](#differential-tests)
   - [Fork Tests](#fork-tests)
5. [Gas Optimization Testing](#gas-optimization-testing)
6. [Continuous Integration for Tests](#continuous-integration-for-tests)
7. [Best Practices](#best-practices)

## Introduction to Testing with Foundry

Foundry provides a robust testing framework for Solidity smart contracts. It allows you to write and run tests directly in Solidity, making it easier to test complex contract interactions.

## Setting Up Your Test Environment

1. Ensure Foundry is installed and up to date:

   ```bash
   foundryup

2. Create a new test file in the test/ directory:

    ```
    touch test/MyContract.t.sol

3. Basic structure of a test file:

    ```
    // SPDX-License-Identifier: MIT
    pragma solidity ^0.8.13;

    import "forge-std/Test.sol";
    import "../src/MyContract.sol";

    contract MyContractTest is Test {
        MyContract public myContract;

        function setUp() public {
            myContract = new MyContract();
        }

        // Tests go here
    }

## Types of Tests

### Unit Tests

Unit tests focus on testing individual functions or components of your smart contract in isolation.

Example:

    function testDeposit() public {
        uint256 depositAmount = 100;
        myContract.deposit{value: depositAmount}();
        assertEq(myContract.balanceOf(address(this)), depositAmount);
    }


### Integration Tests
Integration tests verify that different components of your system work correctly together.

Example:
    
    
    function testDepositAndWithdraw() public {
    
        uint256 depositAmount = 100;
        myContract.deposit{value: depositAmount}();
        myContract.withdraw(depositAmount);
        assertEq(myContract.balanceOf(address(this)), 0);
    
    }

### Functional Tests

Functional tests ensure that the contract behaves correctly for specific use cases or scenarios.

Example:

    function testCompleteWorkflow() public {
    
        myContract.startAuction();
        vm.warp(block.timestamp + 1 days);
        myContract.placeBid{value: 100}();
        vm.warp(block.timestamp + 7 days);
        myContract.endAuction();
        assertEq(myContract.highestBidder(), address(this));
    
    }


### Property-Based Tests

Property-based tests verify that certain properties or invariants of your contract hold true for a wide range of inputs.

Example:

    function testPropertyDepositWithdraw(uint256 amount) public {
      
        vm.assume(amount > 0 && amount < address(this).balance);
        uint256 initialBalance = address(this).balance;
        myContract.deposit{value: amount}();
        myContract.withdraw(amount);
        assertEq(address(this).balance, initialBalance);
    
    }

### Testing Mechanisms

#### State Tests

State tests verify that the contract's state variables are correctly updated after certain operations.

Example:

    ```
    function testStateAfterDeposit() public {
    
        uint256 depositAmount = 100;
        myContract.deposit{value: depositAmount}();
        assertEq(myContract.totalDeposits(), depositAmount);
    
    }

#### Behavior Tests

Behavior tests ensure that the contract behaves as expected under different conditions.

Example:

    function testBehaviorUnderDifferentRoles() public {
    
        myContract.grantRole(ADMIN_ROLE, address(1));
        vm.prank(address(1));
        myContract.performAdminAction();
        assertTrue(myContract.actionPerformed());
        
    }

#### Event Tests

Event tests verify that the contract emits the correct events with the right parameters.

Example:

    function testEventEmission() public {
    
        vm.expectEmit(true, false, false, true);
        emit Deposit(address(this), 100);
        myContract.deposit{value: 100}();
        
    }

#### Revert Tests

Revert tests ensure that the contract reverts under specific conditions with the correct error message.

Example:

    function testRevertOnInsufficientBalance() public {
    
        vm.expectRevert("Insufficient balance");
        myContract.withdraw(address(this).balance + 1);
    
    }

#### Fuzzing 

Fuzzing involves testing a contract with a large number of randomly generated inputs to find edge cases or unexpected behaviors.

Example:

    function testFuzz_Deposit(uint256 amount) public {

        vm.assume(amount > 0 && amount < address(this).balance);
        myContract.deposit{value: amount}();
        assertEq(myContract.balanceOf(address(this)), amount);
    
    }

#### Invariant Tests

Invariant tests verify that certain conditions always hold true, regardless of the state of the contract.

Example:

    function invariant_totalSupplyNeverExceedsMax() public {
    
        assertLe(myContract.totalSupply(), myContract.MAX_SUPPLY());
    
    }

#### Differential Tests  

Differential tests compare the behavior of two different implementations of the same functionality.

Example:

    function testDifferential_Implementation() public {
    
        MyContractV1 v1 = new MyContractV1();
        MyContractV2 v2 = new MyContractV2();
        
        v1.someFunction(42);
        v2.someFunction(42);
    
        assertEq(v1.someValue(), v2.someValue());
    }

#### Fork Tests

Fork tests allow you to test your contract against a forked version of a live network.

Example:

    function testFork_Mainnet() public {

        vm.createSelectFork("mainnet");
        // Test against mainnet state
        address daiAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        IERC20 dai = IERC20(daiAddress);
        assertGt(dai.totalSupply(), 0);
    
    }

### Gas Optimization Testing

1. Use Foundry's gas report:

    ```
    forge test --gas-report

2. Test gas usage in specific scenarios:

    ```
    function testGasUsage_SomeFunction() public {

        uint256 gasBefore = gasleft();
        myContract.someFunction(42);
        uint256 gasUsed = gasBefore - gasleft();
        assertLt(gasUsed, 50000);
    
    }

### Continuous Integration for Tests

1. Set up a GitHub Actions workflow (.github/workflows/test.yml)

```
name: Tests

on: [push]

jobs:
  check:
    name: Foundry project
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          submodules: recursive
      - name: Install Foundry
        uses: foundry-rs/foundry-toolchain@v1
      - name: Run tests
        run: forge test
      - name: Run snapshot
        run: forge snapshot

```

### Best Practices

1. Use descriptive test names that explain the scenario being tested.
2. Test both positive and negative scenarios.
3. Use setUp function to initialize the contract state before each test.
4. Use Foundry's cheatcodes (vm) to manipulate blockchain state.
5. Test edge cases and boundary conditions.
6. Use fuzzing to test with a wide range of inputs.
7. Keep tests independent of each other.
8. Use fixtures or factory functions to create complex test scenarios.
9. Regularly update and maintain your tests as your contract evolves.
10. Use a combination of different test types and mechanisms to ensure comprehensive coverage.
11. Regularly run gas optimization tests to keep your contract efficient.
12. Use fork tests to ensure your contract works correctly with external dependencies on live networks.

Remember, a well-tested smart contract is crucial for security and reliability. Utilize a variety of testing approaches to cover all aspects of your contract's functionality and behavior.
