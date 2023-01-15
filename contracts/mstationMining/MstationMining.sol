pragma solidity ^0.8.4;
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interface/IMstationCharacter.sol";
import "../interface/IBSCD.sol";
import "../interface/IMstationMiningUtils.sol";
import "../interface/IMstationNFTUtils.sol";

contract MstationMining is
    Initializable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    IERC721Receiver,
    IERC1155ReceiverUpgradeable,
    AccessControlUpgradeable
{
    using SafeMath for uint256;
    struct Pool {
        uint32 poolId;
        uint32 requireLevel;
        uint32[] requireAttribute;
    }

    uint256 private nonceRandom;
    address public treasury;
    address public burnWallet;
    address public mstationAddress; // Utils address
    ERC20Upgradeable public reward0Address;
    ERC20Upgradeable public reward1Address;
    IBSCD iBscdToken;
    uint256 public miningRatio; // 100 = 100;
    uint256 public baseRewardPerBlock; // 10 = 0.01 => 1000 = 1
    uint16 minLevel;
    uint256[] public rewardMultiplier;
    mapping(uint256 => mapping(uint256 => uint256)) rewardProductivities; // dont use
    uint256[] public bscdLevelMultiplier;
    mapping(address => mapping(uint32 => Pool)) public poolInfos;
    mapping(uint256 => uint256) public workedInfo;
    mapping(uint256 => IMstationMiningUtils.Miner) public miners;
    mapping(address => uint256[]) public _ownedTokens;
    mapping(uint256 => uint256) public _ownedTokensIndex;
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    uint256 public kVariable;
    uint256[] public refillFee;
    uint256[] public refillAllFee;
    uint256[] public refill80Fee;
    bool pauseMining;
    bool pauseClaimReward;
    mapping(uint32 => address) public addressConfigs;
    mapping(uint256 => address) public userNFT;
    mapping(address => bool) private whitelistNFTContract;

    modifier onlyWhitelistNFT(uint256 _tokenId) {
        require(
            !IMstationNFTUtils(addressConfigs[1]).isBlockNFT(_tokenId),
            "Blacklist"
        );
        _;
    }

    function initialize() public initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        __AccessControl_init();
        baseRewardPerBlock = 10000; //0.01 => 10000/1000000
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function initData(
        address _treausy,
        address _burnWallet,
        address _BSCSAddress,
        address _BSCDAddress
    ) public onlyOwner {
        require(_treausy != address(0));
        require(_burnWallet != address(0));
        require(_BSCSAddress != address(0));
        require(_BSCDAddress != address(0));
        treasury = payable(_treausy);
        burnWallet = payable(_burnWallet);
        reward0Address = ERC20Upgradeable(_BSCSAddress);
        reward1Address = ERC20Upgradeable(_BSCDAddress);
        iBscdToken = IBSCD(_BSCDAddress);
    }

    function work(
        address _contract,
        uint256 _tokenId,
        uint32 _poolId
    ) external nonReentrant {
        // require(!pauseMining, "MAINTAIN");
        // _work(_contract, _tokenId, _poolId);
        // emit StartWork(_contract, _tokenId, _poolId);
    }

    function _work(
        address _contract,
        uint256 _tokenId,
        uint32 _poolId
    ) internal {
        require(miners[_tokenId].startBlock <= 0, "WORKING");
        uint16 minerLevel = 1;
        uint256 advantage = 0;
        Pool memory pool = poolInfos[_contract][_poolId];
        require(pool.poolId > 0, "INVALID_POOL");
        if (_poolId > 1) {
            IMstationCharacter.HeroAttribute
                memory heroAttr = IMstationCharacter(_contract)
                    .getHeroAttribute(_tokenId);
            require(pool.requireAttribute[0] <= heroAttr.strength, "STRENGTH");
            require(pool.requireAttribute[1] <= heroAttr.stamina, "STAMINA");
            require(pool.requireAttribute[2] <= heroAttr.vitality, "VITALITY");
            require(pool.requireAttribute[3] <= heroAttr.courage, "COURAGE");
            require(
                pool.requireAttribute[4] <= heroAttr.dexterity,
                "DEXTERITY"
            );
            require(
                pool.requireAttribute[5] <= heroAttr.intelligence,
                "INTELLIGENCE"
            );
            require(heroAttr.level > 1, "LEVEL");
            minerLevel = heroAttr.level;
            advantage = IMstationMiningUtils(mstationAddress).getAdvantage(
                _tokenId,
                _contract
            );
        } else {
            minerLevel = IMstationCharacter(_contract).getLevel(_tokenId);
        }

        IMstationCharacter(_contract).safeTransferFrom(
            _msgSender(),
            address(this),
            _tokenId
        );

        miners[_tokenId] = IMstationMiningUtils.Miner(
            minerLevel,
            block.number,
            advantage,
            _contract,
            _msgSender(),
            _poolId
        );
    }

    function quitWork(uint256 _tokenId) external nonReentrant {
        // require(miners[_tokenId].startBlock > 0, "Not working");
        // require(
        //     miners[_tokenId].owner == _msgSender() || _msgSender() == owner(),
        //     "Not NFT owner"
        // );
        // require(
        //     !IMstationNFTUtils(addressConfigs[1]).isBlockAddress(_msgSender()),
        //     "Blacklist"
        // );
        // address tokenOwner = miners[_tokenId].owner;
        // IMstationCharacter(miners[_tokenId].contractAddress).safeTransferFrom(
        //     address(this),
        //     tokenOwner,
        //     _tokenId
        // );
        // _claimRw(tokenOwner, _tokenId, true);
        // emit QuitWork(
        //     miners[_tokenId].contractAddress,
        //     _tokenId,
        //     miners[_tokenId].poolId
        // );
        // delete miners[_tokenId];
    }

    function forceQuit(uint256 _tokenId) external {
        require(hasRole(OPERATOR_ROLE, _msgSender()), "INVALID_OPERATOR");
        require(miners[_tokenId].startBlock > 0, "You are not working");
        IMstationCharacter(miners[_tokenId].contractAddress).safeTransferFrom(
            address(this),
            miners[_tokenId].owner,
            _tokenId
        );
        delete miners[_tokenId];
    }

    function claimReward(uint256 _tokenId) external nonReentrant {
        // require(!pauseClaimReward, "MAINTAIN");
        // require(
        //     !IMstationNFTUtils(addressConfigs[1]).isBlockAddress(_msgSender()),
        //     "Blacklist"
        // );
        // require(miners[_tokenId].startBlock > 0, "INVALID_START_BLOCK");
        // require(
        //     block.number > miners[_tokenId].startBlock + 1,
        //     "INVALID_WORKED_BLOCK"
        // );
        // require(miners[_tokenId].owner == _msgSender(), "You are not owner");
        // _claimRw(_msgSender(), _tokenId, false);
    }

    function calculateRw(uint256 _tokenId)
        internal
        returns (uint256 rewardAmount)
    {
        uint256 numWorkingBlock = block.number.sub(miners[_tokenId].startBlock);
        IMstationMiningUtils.Miner memory miner = miners[_tokenId];

        try
            IMstationMiningUtils(mstationAddress).calculateRw(
                _tokenId,
                numWorkingBlock,
                workedInfo[_tokenId],
                rewardMultiplier[miner.level - 1],
                miningRatio,
                miner
            )
        returns (uint256 result) {
            rewardAmount = result;
        } catch {}
        require(rewardAmount > 0, "INVALID_REWARD");
        workedInfo[_tokenId] = workedInfo[_tokenId].add(numWorkingBlock);
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256 result) {
        if (a > b) {
            result = a - b;
        }
    }

    function workBatch(
        address[] calldata _contracts,
        uint256[] calldata _tIds,
        uint32 _poolId
    ) external nonReentrant {
        // require(!pauseMining, "MAINTAIN");
        // require(_tIds.length < 10, "_tokenIds");
        // for (uint256 i = 0; i < _tIds.length; i++) {
        //     _work(_contracts[i], _tIds[i], _poolId);
        // }
        // emit StartWorkBatch(_contracts, _tIds, _poolId);
    }

    function claimRewardBatch(uint256[] calldata _tokenIds)
        external
        nonReentrant
    {
        // require(!pauseClaimReward, "MAINTAIN");
        // require(_tokenIds.length <= 10, "INVALID_TOKEN");
        // uint256 tReward = 0;
        // uint32 pId = 0;
        // for (uint256 i = 0; i < _tokenIds.length; i++) {
        //     uint256 _tokenId = _tokenIds[i];
        //     require(miners[_tokenId].startBlock > 0, "INVALID_START_BLOCK");
        //     require(
        //         block.number > miners[_tokenId].startBlock + 1,
        //         "INVALID_WORKED_BLOCK"
        //     );
        //     require(
        //         miners[_tokenId].owner == _msgSender(),
        //         "You are not owner"
        //     );
        //     tReward += calculateRw(_tokenId);
        //     pId = miners[_tokenId].poolId;
        //     miners[_tokenId].startBlock = block.number;
        // }
        // iBscdToken.claimReward(_msgSender(), tReward);
        // emit NewClaimRewardBatch(_tokenIds, tReward, pId);
    }

    function refill(address _nftAddress, uint256 _tokenId) public nonReentrant {
        // require(
        //     IMstationCharacter(_nftAddress).ownerOf(_tokenId) == _msgSender(),
        //     "INVALID_OWNER"
        // );
        // uint256 _fee = IMstationMiningUtils(mstationAddress).getRefillFee(
        //     _tokenId,
        //     workedInfo[_tokenId],
        //     _nftAddress
        // );
        // require(_fee > 0, "INVALID_FEE");
        // reward1Address.transferFrom(_msgSender(), burnWallet, _fee);
        // workedInfo[_tokenId] = 0;
        // emit NewRefill(_nftAddress, _tokenId, _fee);
    }

    function getMinerInfo(uint256 _tokenId)
        public
        view
        returns (IMstationMiningUtils.Miner memory)
    {
        return miners[_tokenId];
    }

    function _claimRw(
        address _owner,
        uint256 _tokenId,
        bool quit
    ) internal {
        uint256 rewardAmount = calculateRw(_tokenId);
        if (!quit) {
            miners[_tokenId].startBlock = block.number;
        }
        iBscdToken.claimReward(_owner, rewardAmount);
        emit NewClaimReward(_tokenId, rewardAmount, miners[_tokenId].poolId);
    }

    function updateRefillFee(
        uint256[] calldata _refill80Fee,
        uint256[] calldata _refill5Fee,
        uint256[] calldata _refill0Fee
    ) public {
        require(hasRole(OPERATOR_ROLE, _msgSender()), "INVALID_OPERATOR");
        IMstationMiningUtils(mstationAddress).updateRefillFee(
            _refill80Fee,
            _refill5Fee,
            _refill0Fee
        );
    }

    /**
     * @notice
     */
    function updateRewardConfigs(
        uint256 _miningRatio,
        uint256 _baseRewardPerBlock,
        uint256 _k,
        uint256[] calldata _rewardMultiplier,
        uint256[] calldata _bscdMultiplier
    ) external {
        require(_miningRatio > 0, "INVALID_MINING_RATIO");
        require(hasRole(OPERATOR_ROLE, _msgSender()), "INVALID_OPERATOR");
        miningRatio = _miningRatio;
        if (_rewardMultiplier.length > 0) {
            rewardMultiplier = _rewardMultiplier;
        }
    }

    // function updateNFTAddressOfPool(
    //     address[] calldata _nftContracts,
    //     uint32[] calldata _poolIds,
    //     uint32[] calldata requiredLevel,
    //     uint32[] calldata requiredAttribute
    // ) external onlyOwner {
    //     require(_nftContracts.length > 0, "_nftContracts");
    //     require(_poolIds.length > 0, "_poolIds");
    //     for (uint32 i = 0; i < _nftContracts.length; i++) {
    //         for (uint32 j = 0; j < _poolIds.length; j++) {
    //             poolInfos[_nftContracts[i]][_poolIds[j]].poolId = _poolIds[j];
    //             poolInfos[_nftContracts[i]][_poolIds[j]]
    //                 .requireLevel = requiredLevel[j];
    //             poolInfos[_nftContracts[i]][_poolIds[j]]
    //                 .requireAttribute = requiredAttribute;
    //         }
    //     }
    // }

    // function updatePause(bool _pauseMining, bool _pauseClaim)
    //     external
    //     onlyOwner
    // {
    //     pauseMining = _pauseMining;
    //     pauseClaimReward = _pauseClaim;
    // }

    // function updateUtilsAddress(address _utils) external onlyOwner {
    //     mstationAddress = _utils;
    // }

    function updateAddressConfigs(
        uint32[] memory ids,
        address[] memory _address
    ) external onlyOwner {
        for (uint256 i = 0; i < ids.length; i++) {
            addressConfigs[ids[i]] = _address[i];
        }
    }

    function importNFT(
        address[] calldata _contract,
        uint256[] calldata _tokenId
    ) external {
        for (uint16 i = 0; i < _tokenId.length; i++) {
            require(whitelistNFTContract[_contract[i]], "INVALID_CONTRACT");
            IMstationCharacter(_contract[i]).safeTransferFrom(
                _msgSender(),
                address(this),
                _tokenId[i]
            );
            userNFT[_tokenId[i]] = _msgSender();
        }

        emit ImportNFT(_msgSender(), _contract, _tokenId);
    }

    function exportNFT(
        address[] calldata _contract,
        uint256[] calldata _tokenId
    ) external {
        for (uint16 i = 0; i < _tokenId.length; i++) {
            bool isImported = false;
            if (
                miners[_tokenId[i]].owner == _msgSender() ||
                userNFT[_tokenId[i]] == _msgSender()
            ) {
                isImported = true;
            }
            require(isImported, "NOT_IMPORTED");
            IMstationCharacter(_contract[i]).safeTransferFrom(
                address(this),
                _msgSender(),
                _tokenId[i]
            );
        }

        emit ExportNFT(_msgSender(), _contract, _tokenId);
    }

    function whitelistContract(address[] calldata _contracts, bool _whitelist)
        external
        onlyOwner
    {
        for (uint16 i = 0; i < _contracts.length; i++) {
            whitelistNFTContract[_contracts[i]] = _whitelist;
        }
    }

    function _random(uint256 min, uint256 max)
        internal
        returns (uint256 randomnumber)
    {
        randomnumber = uint256(
            keccak256(
                abi.encodePacked(block.timestamp, msg.sender, nonceRandom)
            )
        ).mod(max - min);
        randomnumber = randomnumber + min;
        nonceRandom = nonceRandom.add(99);
        return randomnumber;
    }

    /**
     * @dev Can only be called by the current owner.
     * @param _wallet grant wallet address
     * @param _role role
     */
    function grantContractRole(
        string memory _role,
        address _wallet,
        bool _revoke
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_revoke) {
            revokeRole(keccak256(abi.encodePacked(_role)), _wallet);
        } else {
            grantRole(keccak256(abi.encodePacked(_role)), _wallet);
        }
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) external virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) external virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes memory
    ) external virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(AccessControlUpgradeable, IERC165Upgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    event StartWork(address _nft, uint256 _tId, uint32 _pId);
    event StartWorkBatch(address[] _nft, uint256[] _tId, uint32 _pId);
    event QuitWork(address _nft, uint256 _tId, uint32 _pId);
    event NewClaimReward(uint256 _tId, uint256 _r, uint32 _pId);
    event NewClaimRewardBatch(uint256[] _tId, uint256 _r, uint32 _pId);
    event NewRefill(address _nft, uint256 _tId, uint256 _fee);
    event NewMiner(address _nft, uint256 _tId, uint256 _adv, uint16 _level);
    event ImportNFT(address _owner, address[] _nft, uint256[] _tId);
    event ExportNFT(address _owner, address[] _nft, uint256[] _tId);
}
