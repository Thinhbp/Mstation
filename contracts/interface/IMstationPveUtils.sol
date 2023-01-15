pragma solidity ^0.8.4;

interface IMstationPveUtils {
    struct PillFee {
        uint256 amountMST;
        uint256 amountBSCD;
    }

    function calculatePoolReward(uint256[] memory _feeBSCD) external;

    function updateRewardConfig(
        uint16[] calldata level,
        uint16[] calldata numBattle,
        uint256[] calldata rewardMST,
        uint256[] calldata rewardBSCD
    ) external;

    function getPoolReward(uint256 heroLevel, uint256 dungeonLevel)
        external
        returns (uint256 _amount);

    function getPillFee(
        uint256 _tokenId,
        uint256 _heroLevel,
        address _nftAddress
    ) external view returns (PillFee memory _amount);
}
