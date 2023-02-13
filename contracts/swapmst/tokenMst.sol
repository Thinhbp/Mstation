// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract tokenMst is ERC20 {
    constructor() public ERC20("mst", "MST") {
    }

    function mintToken(uint _amount, address _to) public {
        _mint(_to, _amount);
    }
}