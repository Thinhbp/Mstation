pragma solidity ^0.8.4;

interface IMstationNFT {
    function getLevel(uint256 _sender) external returns (uint16);
}
