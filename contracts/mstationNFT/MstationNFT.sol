// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.4;
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "../interface/IMstationCharacter.sol";

contract MstationNFT is Initializable, OwnableUpgradeable {
    using SafeMath for uint256;

    struct CharacterContract {
        uint256 id;
        uint256 rarity;
        address contractAddress;
    }

    struct SkillSet {
        uint16 skill1;
        uint16 skill2;
        uint16 skill3;
        uint16 skill4;
        uint16 skill5;
        uint16 skill6;
        uint16 skill7;
        uint16 skill8;
        uint16 skill9;
        uint16 skill10;
        uint16 skill11;
        uint16 skill12;
        uint16 skill13;
        uint16 skill14;
        uint16 skill15;
        uint16 skill16;
    }

    struct Hero {
        address nftAddress;
        uint256 tokenId;
        uint256 feeMST;
        uint256 feeBUSD;
        uint16[] attributes;
    }

    bool isInitialized;
    uint256 private nonceRandom;
    address public treasury;
    address public burnWallet;
    ERC20Upgradeable public bscsAddress;
    ERC20Upgradeable public bscdAddress;
    ERC20Upgradeable public busdAddress;
    uint256 private maxSupply;
    uint256 private totalSupplied;
    uint256[] nftSlots;
    uint256 baseMintFee;
    uint256 baseMintLimitedFee;
    uint256 tokenMintLimitedFee;
    uint16 public serviceFee; // 10.000 = 10%

    CharacterContract[] public characterContracts;

    uint256 public tokenId;
    mapping(uint256 => bool) public blackList;
    mapping(uint256 => bool) public priorityList;
    uint256 bnbMintFee;
    uint256 private nonceRandom2;
    uint256 private nonceRandom3;
    mapping(uint16 => CharacterContract) characterContractMap;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    mapping(address => mapping(uint256 => Hero)) userClaimable;
    mapping(address => uint256) public userClaimCounter;
    mapping(address => uint256) public userMintBlock;
    address public referralAddress;
    address public walletAddress;



    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    function initialize() public initializer {
        __Ownable_init();
        nonceRandom = 19;
        nonceRandom2 = 19;
        nonceRandom3 = 199;
        totalSupplied = 0;
        serviceFee = 10000; //10%
        tokenId = 0;
        bnbMintFee = 200000000000000; //0.0002 BNB
    }

    function initData(
        address _treausy,
        address _burnWallet,
        address _BSCSAddress,
        address _BSCDAddress,
        uint256 _initalSupply,
        uint256 _baseMintFee,
        uint256 _baseMintLimitedFee,
        uint256 _tokenMintLimitedFee
    ) public onlyOwner {
        require(_treausy != address(0));
        require(_initalSupply > 0);
        require(_baseMintFee > 0);
        treasury = payable(_treausy);
        burnWallet = payable(_burnWallet);
        baseMintFee = _baseMintFee;
        baseMintLimitedFee = _baseMintLimitedFee;
        tokenMintLimitedFee = _tokenMintLimitedFee;
        bscsAddress = ERC20Upgradeable(_BSCSAddress);
        bscdAddress = ERC20Upgradeable(_BSCDAddress);
        busdAddress = ERC20Upgradeable(
            0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
        );
        _updateSupply(_initalSupply);
    }

    /**
     * for mint new hero
     */
    function BreedPack(uint16 _quantity) public payable nonReentrant {
        require(_quantity <= 15, "QUANTITY");
        require(msg.value >= bnbMintFee.mul(_quantity), "FEE");
        require(!AddressUpgradeable.isContract(_msgSender()), "SENDER");
        uint256 burnAmount = baseMintFee.mul(_quantity).mul(serviceFee).div(
            100000
        );
        uint256 refAmount = baseMintFee.mul(_quantity).div(10);

        bscsAddress.transferFrom(_msgSender(), burnWallet, burnAmount);
        bscsAddress.transferFrom(_msgSender(), referralAddress, refAmount);
        bscsAddress.transferFrom(
            _msgSender(),
            walletAddress,
            baseMintFee.mul(_quantity).sub(burnAmount + refAmount)
        );
        userMintBlock[_msgSender()] = block.number;
        for (uint16 i = 0; i < _quantity; i++) {
            tokenId = tokenId.add(1);
            _breedNFT(tokenId, baseMintFee, 0, _msgSender());
        }
        emit DepositToWallet(refAmount);
    }

    /**
     * for claim minted hero
     */
    function Claim(uint256 _randomId) public payable nonReentrant {
        uint256 total = userClaimCounter[_msgSender()];
        require(total > 0, "INVALID_CLAIM");
        require(block.number > userMintBlock[_msgSender()], "INVALID_BLOCK");
        for (uint16 i = 0; i < total; i++) {
            Hero memory aHero = userClaimable[_msgSender()][i];
            IMstationCharacter(aHero.nftAddress).reveal(aHero.tokenId);
            emit NewBreed(
                aHero.nftAddress,
                _msgSender(),
                aHero.tokenId,
                aHero.feeMST,
                aHero.feeBUSD,
                aHero.attributes
            );
            delete userClaimable[_msgSender()][i];
        }
        userClaimCounter[_msgSender()] = 0;
    }

    function _breedNFT(
        uint256 _nftTokenId,
        uint256 _feeBSCS,
        uint256 _feeBUSD,
        address _user
    ) internal {
        address _nftAddress = _randomCharacter();
        require(_nftAddress != address(0), "INVALID_NFT_ADDRESS");
        uint16[] memory attributes;
        (attributes) = IMstationCharacter(_nftAddress).breed(
            _user,
            _nftTokenId
        );
        Hero memory newHero = Hero(
            _nftAddress,
            _nftTokenId,
            _feeBSCS,
            _feeBUSD,
            attributes
        );
        userClaimable[_user][userClaimCounter[_user]] = newHero;
        userClaimCounter[_user] += 1;
    }

    /**
     * @notice total metaverse is the total character, if we change the total we need update to all NFT contract.
     */

    function growUp(uint256 _totalMetaverse) public onlyOwner {
        require(characterContracts.length > 0, "Character not initialized");
        if (_totalMetaverse == 0) {
            _updateSupply(maxSupply + 1000);
        } else {
            _updateSupply(_totalMetaverse);
        }
    }

    function _updateSupply(uint256 _totalSupply) internal {
        if (characterContracts.length > 0) {
            maxSupply = _totalSupply;
            for (uint16 i = 0; i < characterContracts.length; i++) {
                IMstationCharacter(characterContracts[i].contractAddress)
                    .updateMaxSupply(_totalSupply);
            }
        }
    }

    function updateToken(address _newToken) external onlyOwner {
        require(_newToken != address(0),"Zero address");
        bscsAddress = ERC20Upgradeable(_newToken);
    }

    /**
     * @notice rarity 2500 = 2.5%
     * must call after initData
     */
    function updateRarity(
        address[] memory characterAddress,
        uint256[] memory rarities
    ) external onlyOwner {
        require(characterAddress.length == rarities.length);
        delete characterContracts;

        for (uint16 index = 0; index < characterAddress.length; index++) {
            CharacterContract memory character = CharacterContract(
                index,
                rarities[index],
                characterAddress[index]
            );
            characterContractMap[index] = character;
            characterContracts.push(character);
        }
    }

    function getBreedSlot() public view returns (uint256) {
        return nftSlots.length;
    }

    /**
     * call from MStationSchool when upgrade level failure
     */
    function dead(
        address _nftAddress,
        address _user,
        uint256 _tokenId
    ) external {}

    function _randomCharacter() internal returns (address _nftAddress) {
        require(characterContracts.length > 11, "Character not initialized");
        uint256 _randomNumber = _random(0, 9996);
        for (uint16 i = 0; i < characterContracts.length; i++) {
            if (_randomNumber < characterContracts[i].rarity) {
                _nftAddress = characterContracts[i].contractAddress;
                return _nftAddress;
            }
        }
    }

    function _safeERC20Transfer(
        ERC20Upgradeable erc20,
        address _from,
        address _to,
        uint256 _amount
    ) private {
        erc20.transferFrom(_from, _to, _amount);
    }

    function updateBNBFee(uint256 _bnbMintFee) external onlyOwner {
        bnbMintFee = _bnbMintFee;
    }

    function updateServiceFee(uint16 _serviceFee) external onlyOwner {
        serviceFee = _serviceFee;
    }

    function claimMintFee() external onlyOwner {
        uint256 amount = address(this).balance;
        (bool result, ) = _msgSender().call{value: amount, gas: 30000}("");
        require(result, "Failed to transfer Ether");
    }

    function updatetotalSupplied(uint256 _totalSupplied) external onlyOwner {
        totalSupplied = _totalSupplied;
    }

    function updateReferralAddress(address _referralAddress)
        external
        onlyOwner
    {
        referralAddress = _referralAddress;
    }

    function updateWalletAddress(address _address) external onlyOwner {
        walletAddress = _address;
    }


    function _random(uint256 min, uint256 max)
        internal
        returns (uint256 randomnumber)
    {
        randomnumber = uint256(
            keccak256(
                abi.encodePacked(
                    tokenId,
                    nonceRandom3,
                    block.timestamp,
                    nonceRandom2,
                    msg.sender,
                    nonceRandom
                )
            )
        ).mod(max - min);
        randomnumber = randomnumber + min;
        nonceRandom = nonceRandom.add(11);
        nonceRandom2 = randomnumber.mul(2);
        nonceRandom3 = nonceRandom3.add(77);
        return randomnumber;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    event NewBreed(
        address _nftAddress,
        address _user,
        uint256 _tokenId,
        uint256 _mintFeeBSCS,
        uint256 _mintFeeBUSD,
        uint16[] _attributes
    );
    event DepositToWallet(uint256 _amount);
}
