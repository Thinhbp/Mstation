pragma solidity ^0.8.4;

interface IBSCD {
    function claimReward(address _to, uint256 value) external;
}
