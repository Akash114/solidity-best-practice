// test/MyToken.t.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/MyToken.sol";

contract MyTokenTest is Test {
    MyToken public token;
    address public owner;
    address public user;

    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);

    function setUp() public {
        owner = address(this);
        user = address(0x1);
        token = new MyToken();
    }

    function testInitialSupply() public {
        assertEq(token.totalSupply(), 100000 * 10**18);
        assertEq(token.balanceOf(owner), 100000 * 10**18);
    }

    function testMint() public {
        uint256 amount = 1000 * 10**18;
        vm.expectEmit(true, false, false, true);
        emit Mint(user, amount);
        token.mint(user, amount);
        assertEq(token.balanceOf(user), amount);
    }

    function testBurn() public {
        uint256 amount = 1000 * 10**18;
        token.transfer(user, amount);
        vm.prank(user);
        vm.expectEmit(true, false, false, true);
        emit Burn(user, amount);
        token.burn(amount);
        assertEq(token.balanceOf(user), 0);
    }

    function testFailMintExceedsMaxSupply() public {
        token.mint(user, token.MAX_SUPPLY());
    }

    function testPause() public {
        token.pause();
        assertTrue(token.paused());
        vm.expectRevert("Pausable: paused");
        token.transfer(user, 100);
    }

    function testUnpause() public {
        token.pause();
        token.unpause();
        assertFalse(token.paused());
        assertTrue(token.transfer(user, 100));
    }

    function testFuzz_Mint(address to, uint256 amount) public {
        vm.assume(to != address(0) && amount > 0 && amount <= token.MAX_SUPPLY() - token.totalSupply());
        token.mint(to, amount);
        assertEq(token.balanceOf(to), amount);
    }

    function invariant_totalSupplyNeverExceedsMax() public {
        assertLe(token.totalSupply(), token.MAX_SUPPLY());
    }
}