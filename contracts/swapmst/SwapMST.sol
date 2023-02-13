// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/security/Pausable.sol";




contract SwapMST is Ownable , Pausable{

    address public mstToken  ; //Main
    // address public mstToken = address(0x271F9561a5B496F775a0D008816D691592F18dBf) ; //test
    address public bscsToken ; //Main
    // address public bscsToken = address(0xd16f49F42Ced6d32eaCdAbe6F449781fC9D2bb06) ; //test
    uint256 public rateSwap;

    constructor(address _mstToken, address _bscsToken, uint256 _rateSwap)  {
        mstToken = _mstToken;
        bscsToken = _bscsToken;
        rateSwap = _rateSwap;

    }

    function setToken(address _mstToken, address _bscsToken) public onlyOwner{
        mstToken = _mstToken;
        bscsToken = _bscsToken;
        
    }

    function setRate(uint256 _rateSwap) public onlyOwner{
        rateSwap = _rateSwap;
    }
    
    function swap(uint256 _amount) public whenNotPaused() {
        uint256 balanceUser = IERC20(mstToken).balanceOf(msg.sender);
        require(_amount <= balanceUser, "LIMIT");
        uint256 receivedBSCS = _amount/rateSwap;
        require(IERC20(mstToken).transferFrom(msg.sender, address(this), _amount),"Transfer fail");
        require(IERC20(bscsToken).transfer(msg.sender, receivedBSCS),"Transfer fail");
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

    function pause() public onlyOwner whenNotPaused {
        _pause();
    }

    function unpause() public onlyOwner whenPaused {
        _unpause();
    }

}