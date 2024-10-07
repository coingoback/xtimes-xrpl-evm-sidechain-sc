// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title XTimes ERC20 Token
 * @author Cointimes Team
 * @notice Contract for the XTimes ERC20 Token
 * @custom:site https://docs.cointimes.network/
 */

contract XTimesERC20 is ERC20Capped, Ownable {
    /** @dev XTimes cap so that never exists more than 1 billion tokens at a time */
    uint32 public constant MAX_TOKEN_SUPPLY = 1_000_000_000;

    constructor()
        ERC20("X-Times", "XTIMES")
        ERC20Capped(MAX_TOKEN_SUPPLY * 10 ** decimals())
        Ownable(msg.sender)
        {}

    function maxSupply() public view returns (uint256)  {
        return cap();
    }

    function mint(address account, uint256 value) external onlyOwner {
        require(value > 0, "Invalid amount");
        _mint(account, value);
    }
}
