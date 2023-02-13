pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// OwnableUpgradeable,
contract MStationPoolFake is Ownable, ReentrancyGuard, ERC20 {
    constructor(string memory poolName, string memory symbol)
        ERC20(poolName, symbol)
    {}

    /*
     * @notice Initialize the contract
     * @param _stakedToken: staked token address
     * @param _rewardToken: reward token address
     * @param _rewardPerBlock: reward per block (in rewardToken)
     * @param _startBlock: start block
     * @param _bonusEndBlock: end block
     * @param _poolLimitPerUser: pool limit per user in stakedToken (if any, else 0)
     * @param _poolCap: pool cap in stakedToken (if any, else 0)
     * @param _admin: admin address with ownership
     * @param _nftAddress: address with NFT contract
     * @param _nftIds: list token id of NFT
     * @param _minStakeForNFT: minimum amount of token have to stake to earn NFT
     * @param _blockStakeForNFT: minimum block have to stake to earn NFT
     */
    function claimTokens() external {}
}
