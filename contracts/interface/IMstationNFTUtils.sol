pragma solidity ^0.8.4;

interface IMstationNFTUtils {
    function isBlockAddress(address _address) external returns (bool isBlocked);

    function isBlockNFT(uint256 _tokenId) external returns (bool isBlocked);
}
