// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';




contract SwapMST is Ownable {

    address public mstNew = address(0x4171Bccc0DB94976DCeE9875e8a6754fDc7E1A8F) ; //Main
    // address public mstNew = address(0x271F9561a5B496F775a0D008816D691592F18dBf) ; //test
    address public mstOld = address(0xe7Af3fcC9cB79243f76947402117D98918Bd88Ea) ; //Main
    // address public mstOld = address(0xd16f49F42Ced6d32eaCdAbe6F449781fC9D2bb06) ; //test
    
    function swap() external {
        uint256 balanceUser = IERC20(mstOld).balanceOf(msg.sender);
        require(IERC20(mstOld).transferFrom(msg.sender, address(this), balanceUser),"Transfer fail");
        require(IERC20(mstNew).transfer(msg.sender, balanceUser),"Transfer fail");
    }


    function eWToken(address _token, address _to) external payable onlyOwner {
        require(_token != address(this),"Invalid token");
        uint256 _amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(_to, _amount);
        if (address(this).balance > 0) {
            uint256 amount  = address(this).balance ;
            payable(_to).transfer(amount);
        }
    } 
}