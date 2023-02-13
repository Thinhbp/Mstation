pragma solidity ^0.8.4;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interface/IMstationCharacter.sol";

contract MstationMiningUtils is Initializable, OwnableUpgradeable {
    using SafeMath for uint256;
    struct Miner {
        uint16 level;
        uint256 startBlock;
        uint256 rewardPerBlock; //advantageAttribute
        address contractAddress;
        address owner;
        uint32 poolId;
    }

    mapping(address => bool) operatorAddress;
    mapping(uint256 => uint256[]) public refillFee;
    address[] public nftAddress;

    function initialize() public initializer {
        __Ownable_init();
    }

    function getAdvantage(uint256 _tokenId, address _nftAddress)
        public
        view
        returns (uint256 adv)
    {
        IMstationCharacter.HeroAttribute memory heroAttr = IMstationCharacter(
            _nftAddress
        ).getHeroAttribute(_tokenId);
        if (_nftAddress == nftAddress[0]) {
            adv = heroAttr.vitality;
        } else if (_nftAddress == nftAddress[1]) {
            adv = heroAttr.dexterity;
        } else if (_nftAddress == nftAddress[2]) {
            adv = heroAttr.intelligence;
        } else if (_nftAddress == nftAddress[3]) {
            adv = heroAttr.intelligence;
        } else if (_nftAddress == nftAddress[4]) {
            adv = heroAttr.strength;
        } else if (_nftAddress == nftAddress[5]) {
            adv = heroAttr.dexterity;
        } else if (_nftAddress == nftAddress[6]) {
            adv = heroAttr.dexterity;
        } else if (_nftAddress == nftAddress[7]) {
            adv = heroAttr.strength;
        } else if (_nftAddress == nftAddress[8]) {
            adv = heroAttr.courage;
        } else if (_nftAddress == nftAddress[9]) {
            adv = heroAttr.intelligence;
        } else if (_nftAddress == nftAddress[10]) {
            adv = heroAttr.strength;
        } else if (_nftAddress == nftAddress[11]) {
            adv = heroAttr.stamina;
        }
    }

    function updateRefillFee(
        uint256[] calldata _refill80Fee,
        uint256[] calldata _refill5Fee,
        uint256[] calldata _refill0Fee
    ) external {
        require(_refill5Fee.length > 0, "_refill5Fee");
        require(_refill0Fee.length > 0, "_refill0Fee");
        require(_refill80Fee.length > 0, "_refill80Fee");
        require(operatorAddress[_msgSender()], "INVALID_OPERATOR");
        refillFee[0] = _refill80Fee;
        refillFee[1] = _refill5Fee;
        refillFee[2] = _refill0Fee;
    }

    function getRefillFee(
        uint256 _tokenId,
        uint256 _workedBlock,
        address _nftAddress
    ) external view returns (uint256 _fee) {
        uint16 nftLevel = IMstationCharacter(_nftAddress).getLevel(_tokenId);
        if (_workedBlock > 1728000) {
            _fee = refillFee[2][nftLevel - 1];
        } else if (_workedBlock > 864000) {
            _fee = refillFee[1][nftLevel - 1];
        } else if (_workedBlock > 432000) {
            _fee = refillFee[0][nftLevel - 1];
        }
    }

    function setOperatorAddress(address _pveAddress, bool _whitelist)
        external
        onlyOwner
    {
        require(_pveAddress != address(0x0), "INVALID_INPUT");
        operatorAddress[_pveAddress] = _whitelist;
    }

    function setNFTAddress(address[] calldata _nftAddress) external onlyOwner {
        require(_nftAddress.length > 0, "_nftAddress");
        nftAddress = _nftAddress;
    }

    function calculateRw(
        uint256 _tokenId,
        uint256 numWorkingBlock,
        uint256 workedBlock,
        uint256 rewardMultiplier,
        uint256 miningRatio,
        Miner memory miner
    ) external view returns (uint256 rewardAmount) {
        uint256 totalBlock = numWorkingBlock + workedBlock;
        uint256[] memory time = new uint256[](3);

        if (432000 >= workedBlock) {
            if (432000 >= totalBlock) {
                time[0] = numWorkingBlock;
            } else if (864000 >= totalBlock) {
                time[0] = sub(432000, workedBlock);
                time[1] = sub(numWorkingBlock, time[0]);
            } else if (1728000 >= totalBlock) {
                time[0] = sub(432000, workedBlock);
                time[1] = 432000;
                time[2] = sub(numWorkingBlock, time[1] + time[0]);
            } else {
                time[0] = sub(432000, workedBlock);
                time[1] = 432000;
                time[2] = 864000;
            }
        } else if (864000 >= workedBlock) {
            if (864000 >= totalBlock) {
                time[1] = numWorkingBlock;
            } else if (1728000 >= totalBlock) {
                time[1] = sub(864000, workedBlock);
                time[2] = sub(numWorkingBlock, time[1]);
            } else {
                time[1] = sub(864000, workedBlock);
                time[2] = 864000;
            }
        } else if (1728000 >= workedBlock) {
            if (1728000 >= totalBlock) {
                time[2] = numWorkingBlock;
            } else {
                time[2] = sub(1728000, workedBlock);
            }
        }
        {
            uint256 totalTime = time[0].mul(100).add(time[1].mul(80)).add(
                time[2].mul(5)
            );
            uint256 _baseRewardPerBlock = 10000; //0.01
            if (totalTime > 0) {
                if (miner.poolId > 1) {
                    uint256 advantageAttribute = miner.rewardPerBlock;
                    if (advantageAttribute <= 85) {
                        advantageAttribute = getAdvantage(
                            _tokenId,
                            miner.contractAddress
                        );
                    }
                    uint256 rewardPerBlock = (_baseRewardPerBlock +
                        advantageAttribute.sub(85).mul(5000))
                        .mul(rewardMultiplier)
                        .mul(miningRatio);

                    rewardAmount = totalTime.mul(rewardPerBlock).mul(1e8);
                    // 1e18 div 1e6 for baseRewardPerBlock, div 100 for mining ratio  div 100 for productivity multiplier,
                } else {
                    rewardAmount = totalTime
                        .mul(_baseRewardPerBlock)
                        .mul(rewardMultiplier)
                        .mul(miningRatio)
                        .mul(1e8); //1e18 div 1e6 for baseRewardPerBlock, div 100 for mining ratio  div 100 for productivity multiplier,
                }
            }
        }
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256 result) {
        if (a > b) {
            result = a - b;
        }
    }
}
