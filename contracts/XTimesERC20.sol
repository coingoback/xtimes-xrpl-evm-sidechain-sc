// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";

import "./extension/TreasuryOwnable.sol";

/**
 * @title XTimes ERC20 Token
 * @author Cointimes Team
 * @notice Contract for the XTimes ERC20 Token
 * @custom:site https://docs.cointimes.network/
 */

contract XTimesERC20 is ERC20Capped, TreasuryOwnable {
    /** @dev XTimes cap so that never exists more than 1 billion tokens at a time */
    uint32 public constant MAX_TOKEN_SUPPLY = 1_000_000_000;

    /** @dev  */
    uint32 public constant INITIAL_TREASURE_SUPPLY = 200_000;

    constructor()
        ERC20("X-Times", "XTIMES")
        ERC20Capped(MAX_TOKEN_SUPPLY * 10 ** decimals())
        TreasuryOwnable()
        {}

    function maxSupply() external view returns (uint256)  {
        return cap();
    }

    function establishTreasury(address treasureAddress) external onlyOwner {
        _defineTreasureOnce(treasureAddress);
        _mint(treasure(), INITIAL_TREASURE_SUPPLY * 10 ** decimals());
    }

    function issueTokensToTreasure(uint256 value) external canIssueTokensToTreasure(value) {
        require(value > 0, "Invalid amount: Must be greater than 0");
        _mint(treasure(), value);
    }

    function burnFromTreasure(uint256 value) external canBurnTreasureFounds(value) {
        require(value > 0, "Invalid amount: Must be greater than 0");
        _burn(treasure(), value);
    }

    function transferFromTreasure(address to, uint256 value) external canMoveTreasureFounds(value) {
        require(value > 0, "Invalid amount: Must be greater than 0");
        _transfer(treasure(), to, value);
    }
}
