pragma solidity ^0.8.4;

interface IMstationMiningUtils {
    struct Miner {
        uint16 level;
        uint256 startBlock;
        uint256 rewardPerBlock; //advantageAttribute
        address contractAddress;
        address owner;
        uint32 poolId;
    }

    function getAdvantage(uint256 _tokenId, address _nftAddress)
        external
        view
        returns (uint256 adv);

    function updateRefillFee(
        uint256[] calldata _refill80Fee,
        uint256[] calldata _refill5Fee,
        uint256[] calldata _refill0Fee
    ) external;

    function getRefillFee(
        uint256 _tokenId,
        uint256 _workedBlock,
        address _nftAddress
    ) external view returns (uint256 _fee);

    function calculateRw(
        uint256 _tokenId,
        uint256 numWorkingBlock,
        uint256 workedBlock,
        uint256 rewardMultiplier,
        uint256 miningRatio,
        Miner memory miner
    ) external returns (uint256 rewardAmount);
}
