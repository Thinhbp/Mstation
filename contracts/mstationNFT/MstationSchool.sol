pragma solidity ^0.8.4;
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interface/IMstationCharacter.sol";
import "../interface/IMstationNFT.sol";

contract MstationSchool is
    Initializable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeMath for uint256;
    using SafeMath for uint16;

    uint256 private nonceRandom;
    address public treasury;
    address public burnWallet;
    address public burnNFTWallet;
    address public mstationAddress;
    ERC20Upgradeable public bscsAddress;
    ERC20Upgradeable public bscdAddress;

    struct UpgradePlan {
        uint16 fromLevel;
        uint16 toLevel;
        uint256 amountBSCS;
        uint256 amountBSCD;
        uint16 rateFailure;
    }
    mapping(uint256 => UpgradePlan) public upgradePlans;

    struct Student {
        uint16 level;
        uint256 tokenId;
        address contractAddress;
    }
    mapping(uint256 => Student) public students;
    uint256 burnNumerator;
    uint256 constant burnFeeDenominator = 100000;
    uint256 private nonceRandom2;
    uint256 public mstFeeTotal;
    uint256 public bscdFeeTotal;

    function initialize() public initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        nonceRandom = 99;
        nonceRandom2 = 88;
        burnNumerator = 10000;
    }

    function initData(
        address _treausy,
        address _burnWallet,
        address _BSCSAddress,
        address _BSCDAddress,
        uint256[] memory amountBSCS,
        uint256[] memory amountBSCD,
        uint16[] memory rateFailure
    ) public onlyOwner {
        require(_treausy != address(0));
        require(_burnWallet != address(0));
        require(_BSCSAddress != address(0));
        require(_BSCDAddress != address(0));
        require(amountBSCS.length == amountBSCD.length);
        treasury = payable(_treausy);
        burnWallet = payable(_burnWallet);
        bscsAddress = ERC20Upgradeable(_BSCSAddress);
        bscdAddress = ERC20Upgradeable(_BSCDAddress);
        burnNFTWallet = _burnWallet;

        for (uint16 index = 0; index < amountBSCS.length; index++) {
            delete upgradePlans[index + 1];
            UpgradePlan memory plan = UpgradePlan(
                index + 1,
                index + 2,
                amountBSCS[index],
                amountBSCD[index],
                rateFailure[index]
            );

            upgradePlans[index + 1] = plan;
        }
    }

    function Upgrade(address _nftAddress, uint256 _tokenId)
        public
        payable
        nonReentrant
    {
        require(students[_tokenId].level < 10, "You are max level");
        require(_nftAddress != address(0), "contract invalid");
        require(_tokenId > 0, "token invalid");
        require(
            IMstationCharacter(_nftAddress).ownerOf(_tokenId) == _msgSender(),
            "INVALID_OWNER"
        );

        if (students[_tokenId].level == 0) {
            Student memory newStudent = Student(1, _tokenId, _nftAddress);
            students[_tokenId] = newStudent;
        }
        uint16 nftLevel = students[_tokenId].level;
        UpgradePlan memory plan = upgradePlans[nftLevel];
        require(
            bscdAddress.balanceOf(address(_msgSender())) >= plan.amountBSCD,
            "Balance insufficient"
        );
        require(
            bscsAddress.balanceOf(address(_msgSender())) >= plan.amountBSCS,
            "Balance insufficient"
        );

        if (plan.amountBSCD > 0) {
            bscdFeeTotal = bscdFeeTotal + plan.amountBSCD;
            _safeERC20Transfer(
                bscdAddress,
                _msgSender(),
                burnWallet,
                plan.amountBSCD.mul(burnNumerator).div(burnFeeDenominator)
            );
            _safeERC20Transfer(
                bscdAddress,
                _msgSender(),
                treasury,
                plan.amountBSCD.mul(burnFeeDenominator - burnNumerator).div(
                    burnFeeDenominator
                )
            );
        }

        if (plan.amountBSCS > 0) {
            mstFeeTotal = mstFeeTotal + plan.amountBSCS;
            _safeERC20Transfer(
                bscsAddress,
                _msgSender(),
                burnWallet,
                plan.amountBSCS.mul(burnNumerator).div(burnFeeDenominator)
            );

            _safeERC20Transfer(
                bscsAddress,
                _msgSender(),
                treasury,
                plan.amountBSCS.mul(burnFeeDenominator - burnNumerator).div(
                    burnFeeDenominator
                )
            );
        }

        if (upgradePlans[nftLevel].rateFailure > 0) {
            require(
                IERC721(_nftAddress).isApprovedForAll(
                    _msgSender(),
                    address(this)
                ),
                "REQUIRE_APPROVE_TOKEN_NFT"
            );
        }

        bool upgradeFailed = _calculateUpgradeFailed(nftLevel);
        if (upgradeFailed) {
            _burnNFT(_nftAddress, _tokenId);
        } else {
            _upgradeNFT(_nftAddress, _tokenId);
        }
    }

    function _calculateUpgradeFailed(uint16 _fromLevel)
        internal
        returns (bool)
    {
        uint16 rateFailure = upgradePlans[_fromLevel].rateFailure;
        uint256 randomNum = _random(0, 100);
        if (randomNum < rateFailure) {
            return true;
        }
        return false;
    }

    /**
     * random charactor type;
     */
    function _upgradeNFT(address _nftAddress, uint256 _tokenId) internal {
        students[_tokenId].level = students[_tokenId].level + 1;
        IMstationCharacter(_nftAddress).upgradeLevel(
            _tokenId,
            uint256(students[_tokenId].level)
        );
        emit UpgradeLevel(
            students[_tokenId].contractAddress,
            _tokenId,
            true,
            students[_tokenId].level
        );
    }

    function _burnNFT(address _nftAddress, uint256 _tokenId) internal {
        // transfer NFT to
        // IMstationCharacter(students[_tokenId].contractAddress).safeTransferFrom(
        //         _msgSender(),
        //         burnWallet,
        //         _tokenId
        //     );
        // emit UpgradeLevel(
        //     students[_tokenId].contractAddress,
        //     _tokenId,
        //     false,
        //     0
        // );
        // delete students[_tokenId];

        students[_tokenId].level = students[_tokenId].level - 1;
        IMstationCharacter(_nftAddress).upgradeLevel(
            _tokenId,
            uint256(students[_tokenId].level)
        );
        emit UpgradeLevel(
            students[_tokenId].contractAddress,
            _tokenId,
            true,
            students[_tokenId].level
        );
    }

    function forceUpgrade(
        address _nftAddress,
        uint256 _tokenId,
        uint16 _level
    ) public nonReentrant onlyOwner {
        if (students[_tokenId].level == 0) {
            Student memory newStudent = Student(1, _tokenId, _nftAddress);
            students[_tokenId] = newStudent;
        }
        students[_tokenId].level = _level;
        IMstationCharacter(_nftAddress).upgradeLevel(
            _tokenId,
            uint256(students[_tokenId].level)
        );
    }

    function forceUpgrade8(address _nftAddress, uint256 _tokenId)
        external
        nonReentrant
        onlyOwner
    {
        forceUpgrade(_nftAddress, _tokenId, 6);
    }

    function forceUpgrade9(address _nftAddress, uint256 _tokenId)
        external
        nonReentrant
        onlyOwner
    {
        forceUpgrade(_nftAddress, _tokenId, 9);
    }

    /**
     * @notice
     */
    function updateUpgradeFee(
        uint256[] memory amountBSCS,
        uint256[] memory amountBSCD,
        uint16[] memory rateFailure
    ) external onlyOwner {
        require(amountBSCS.length == amountBSCD.length);

        for (uint16 index = 0; index < amountBSCS.length; index++) {
            delete upgradePlans[index + 1];
            UpgradePlan memory plan = UpgradePlan(
                index + 1,
                index + 2,
                amountBSCS[index],
                amountBSCD[index],
                rateFailure[index]
            );

            upgradePlans[index + 1] = plan;
        }
    }

    /**
     * @notice
     */
    function updateBurnWallet(address _burnNFTWallet) external onlyOwner {
        burnNFTWallet = _burnNFTWallet;
    }

    function updateBurn(uint256 _burnNumerator) external onlyOwner {
        burnNumerator = _burnNumerator;
    }

    function getLevel(uint256 _tokenId) public view returns (uint256) {
        return students[_tokenId].level;
    }

    function _safeERC20Transfer(
        ERC20Upgradeable erc20,
        address _from,
        address _to,
        uint256 _amount
    ) private {
        erc20.transferFrom(_from, _to, _amount);
    }

    /**
     * @dev generate a random number
     * @param min min number include
     * @param max max number exclude
     */
    function _random(uint256 min, uint256 max)
        internal
        returns (uint256 randomnumber)
    {
        randomnumber = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    nonceRandom2,
                    msg.sender,
                    nonceRandom
                )
            )
        ).mod(max - min);
        randomnumber = randomnumber + min;
        nonceRandom = nonceRandom.add(1);
        nonceRandom2 = nonceRandom2.add(randomnumber);
        return randomnumber;
    }

    event UpgradeLevel(
        address _nftAddress,
        uint256 _tokenId,
        bool result,
        uint16 newLevel
    );
}
