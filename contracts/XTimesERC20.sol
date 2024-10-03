// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title XTimes ERC20 Token
 * @author Cointimes Team
 * @notice Contract for the XTimes ERC20 Token
 * @custom:site https://docs.cointimes.network/
 */

contract XTimesERC20 is ERC20 {
    constructor() ERC20("X-Times", "XTIMES") {}
}
