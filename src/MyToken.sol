// src/MyToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/// @title MyToken - A simple ERC20 token with minting and burning capabilities
/// @notice This contract implements a basic ERC20 token with additional features
contract MyToken is ERC20, Ownable, Pausable {
    /// @notice Maximum supply of tokens
    uint256 public constant MAX_SUPPLY = 1000000 * 10**18;

    /// @notice Emitted when new tokens are minted
    /// @param to The address receiving the minted tokens
    /// @param amount The amount of tokens minted
    event Mint(address indexed to, uint256 amount);

    /// @notice Emitted when tokens are burned
    /// @param from The address from which tokens are burned
    /// @param amount The amount of tokens burned
    event Burn(address indexed from, uint256 amount);

    /// @notice Creates the token and mints the initial supply to the contract creator
    constructor() ERC20("MyToken", "MTK") {
        _mint(msg.sender, 100000 * 10**18); // Initial supply
    }

    /// @notice Mints new tokens to the specified address
    /// @param to The address to receive the minted tokens
    /// @param amount The amount of tokens to mint
    /// @dev Only callable by the contract owner when not paused
    function mint(address to, uint256 amount) external onlyOwner whenNotPaused {
        require(totalSupply() + amount <= MAX_SUPPLY, "Exceeds max supply");
        _mint(to, amount);
        emit Mint(to, amount);
    }

    /// @notice Burns tokens from the caller's address
    /// @param amount The amount of tokens to burn
    /// @dev Callable by any token holder when not paused
    function burn(uint256 amount) public whenNotPaused {
        _burn(msg.sender, amount);
        emit Burn(msg.sender, amount);
    }

    /// @notice Pauses all token transfers and minting
    /// @dev Only callable by the contract owner
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice Unpauses all token transfers and minting
    /// @dev Only callable by the contract owner
    function unpause() external onlyOwner {
        _unpause();
    }

    /// @notice Overrides the ERC20 transfer function to add the whenNotPaused modifier
    function transfer(address to, uint256 amount) public virtual override whenNotPaused returns (bool) {
        return super.transfer(to, amount);
    }

    /// @notice Overrides the ERC20 transferFrom function to add the whenNotPaused modifier
    function transferFrom(address from, address to, uint256 amount) public virtual override whenNotPaused returns (bool) {
        return super.transferFrom(from, to, amount);
    }
}