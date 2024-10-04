// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title XTimes ERC20 Token
 * @author Cointimes Team
 * @notice Contract for the XTimes ERC20 Token
 * @custom:site https://docs.cointimes.network/
 */

contract XTimesERC20 is ERC20, Ownable {
    uint256 private MAX_TOKEN_SUPPLY = 1_000_000_000 * 10 ** decimals();

    constructor()
        ERC20("X-Times", "XTIMES")
        Ownable(msg.sender) {}

    function maxSupply() public view returns (uint256)  {
        return MAX_TOKEN_SUPPLY;
    }

    function mint(address account, uint256 value) external onlyOwner {
        require(value > 0, "Invalid amount");
        require(totalSupply() + value <= MAX_TOKEN_SUPPLY, "Maximum token supply reached!");
        _mint(account, value);
    }
}
