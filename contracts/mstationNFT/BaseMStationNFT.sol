// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract BaseMStationNFT is
    Initializable,
    ERC721URIStorageUpgradeable,
    ERC721EnumerableUpgradeable,
    OwnableUpgradeable
{
    /**
     * rarity : [0 -> SSR, 1 -> SR, 2 -> R]
     * teamId: [0->n]
     */
    struct HeroAttribute {
        uint16 strength;
        uint16 stamina;
        uint16 vitality;
        uint16 courage;
        uint16 dexterity;
        uint16 intelligence;
        uint16 breed;
        uint16 level;
        uint16 rarity;
        uint16 teamId; // type of hero
        uint16 talent; // disavantage value
        uint16 skill; // advantage value
        uint16 combat; // fight speed
    }

    struct HeroCombat {
        uint256 lastCombatBlock;
        uint256 health;
        uint256 physicalAttack;
        uint256 magicalAttack;
        uint256 defense;
        uint256 magicResistance;
        uint256 accuracy;
    }

    using SafeMath for uint256;
    bool public mintStart;
    // a token_id[address] whitelist mapping, only allow address can mint a specific token_id
    address public factory;
    address public mstationSchool;
    mapping(uint256 => address) public whitelisted; //reverse for future
    // mapping attribute of hero by hero id
    mapping(uint256 => HeroAttribute) private heroAttributes;
    mapping(uint256 => HeroCombat) public heroCombats;

    string public baseUri;
    uint256 public dropPrice; //reverse for future

    mapping(uint256 => uint256[]) public dropList; //reverse for future
    // nonce for generate random number
    uint256 private nonce;
    uint256 private nonce2;
    uint256 private nonce3;

    struct WhitelistBoxMinter {
        uint256 total;
        uint256 startBlock;
        uint256 endBlock;
        uint256 totalMinted;
    }
    mapping(address => WhitelistBoxMinter) whitelistBoxMinters;

    uint256 public maxSupply;
    uint256 public rarity;
    uint256[] minValues;
    uint256[] maxValues;
    uint256 public tokePrefix; // use for count supplied nft
    uint256 nonceRandom;

    uint16 advantageIndex; // reverse for future
    uint256[] public configs; // config value for any logic
    uint256 totalSupplied;
    bool isTransfer;
    mapping(address => bool) whitelistContracts;
    mapping(uint256 => bool) hideHero;

    function base_initialize(string memory name, string memory symbol)
        public
        initializer
    {
        __Ownable_init();
        __ERC165_init_unchained();
        __ERC721_init_unchained(name, symbol);
        nonce = 9;
        nonce2 = 99;
        nonce3 = 999;
        mintStart = true;
    }

    function Breed(
        address _sender,
        uint256 _tokenId,
        uint16 _strength,
        uint16 _stamina,
        uint16 _vitality,
        uint16 _courage,
        uint16 _dexterity,
        uint16 _intelligence,
        uint16 _advantage,
        uint16 _disadvantage
    ) internal {
        require(mintStart, "disabled");
        require(_msgSender() == factory, "INVALID_FACTORY");
        HeroAttribute memory atrs = HeroAttribute(
            _strength,
            _stamina,
            _vitality,
            _courage,
            _dexterity,
            _intelligence,
            0,
            1,
            1,
            0,
            _disadvantage,
            _advantage,
            0
        );
        heroAttributes[_tokenId] = atrs;

        _safeMint(_sender, _tokenId);
        totalSupplied = totalSupplied + 1;
        hideHero[_tokenId] = true;
    }

    function upgradeLevel(uint256 _tokenId, uint256 _newLevel) external {
        require(_msgSender() == mstationSchool, "INVALID_SCHOOL");
        heroAttributes[_tokenId].level = uint16(_newLevel);
        emit NewUpgrade(_msgSender(), _tokenId);
    }

    function toogleMint() external onlyOwner {
        mintStart = !mintStart;
    }

    function setMStationSchoolAddress(address _school) public onlyOwner {
        mstationSchool = _school;
    }

    function reveal(uint256 _tokenId) external {
        require(_msgSender() == factory, "INVALID_FACTORY");
        hideHero[_tokenId] = false;
    }

    /**
     * @dev set base uri that is used to return nft uri.
     * Can only be called by the current owner. No validation is done
     * for the input.
     * @param uri new base uri
     */
    function setBaseURI(string calldata uri) public onlyOwner {
        baseUri = uri;
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return baseUri;
    }

    /**
     */
    function setMaxSupply(uint16 _max) public onlyOwner {
        maxSupply = _max;
    }

    function updateConfig(uint256[] calldata _configs) public onlyOwner {
        configs = _configs;
    }

    function setTransfer(bool _isTransfer) public onlyOwner {
        isTransfer = _isTransfer;
    }

    function setWhitelistContract(
        address[] calldata _contracts,
        bool _isTransfer
    ) public onlyOwner {
        for (uint256 i = 0; i < _contracts.length; i++) {
            whitelistContracts[_contracts[i]] = _isTransfer;
        }
    }

    function resetHide(uint256[] calldata _from) external onlyOwner {
        for (uint256 i = 0; i < _from.length; i++) {
            hideHero[_from[i]] = false;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    )
        internal
        virtual
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
    {
        if (!isTransfer) {
            require(whitelistContracts[to] || whitelistContracts[from], "FORB");
        }

        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
    {
        ERC721URIStorageUpgradeable._burn(tokenId);
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        return ERC721URIStorageUpgradeable.tokenURI(tokenId);
    }

    /**
     * @dev get all NFT base attributes
     */
    function attributes(uint256 _tokenId)
        public
        view
        virtual
        returns (
            uint16,
            uint16,
            uint16,
            uint16,
            uint16,
            uint16
        )
    {
        // require(_exists(_tokenId), "Token not existed");
        // require(!hideHero[_tokenId], "Hidden");
        // HeroAttribute memory hero = heroAttributes[_tokenId];
        // return (
        //     hero.strength,
        //     hero.stamina,
        //     hero.vitality,
        //     hero.courage,
        //     hero.dexterity,
        //     hero.intelligence
        // );
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function getLevel(uint256 _tokenId)
        external
        view
        returns (uint256 heroLevel)
    {
        require(_exists(_tokenId), "Token not existed");
        heroLevel = heroAttributes[_tokenId].level;
    }

    /**
     * @dev get all NFT base attributes
     */
    function getHeroAttribute(uint256 _tokenId)
        external
        view
        returns (HeroAttribute memory hero)
    {
        require(_exists(_tokenId), "Token not existed");
        if (_tokenId > 36072) {
            require(!hideHero[_tokenId], "Hidden");
        }
        hero = heroAttributes[_tokenId];
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev generate a random number
     * @param min min number include
     * @param max max number exclude
     */
    function random(uint256 min, uint256 max)
        internal
        returns (uint256 randomnumber)
    {
        randomnumber = uint256(
            keccak256(
                abi.encodePacked(
                    nonceRandom,
                    block.number,
                    nonce3,
                    nonceRandom,
                    msg.sender,
                    nonce
                )
            )
        ).mod(max - min);
        randomnumber = randomnumber + min;
        nonce = nonce.add(13);
        nonce3 = nonce3.add(95);
        nonceRandom = block.timestamp;
        return randomnumber;
    }

    function random2(uint256 min, uint256 max)
        internal
        returns (uint256 randomnumber)
    {
        randomnumber = uint256(
            keccak256(
                abi.encodePacked(
                    nonceRandom,
                    //block.number,
                    nonce3,
                    //nonceRandom,
                    msg.sender,
                    nonce
                )
            )
        ).mod(max - min);
        randomnumber = randomnumber + min;
        nonce = nonce.add(13);
        nonce3 = nonce3.add(95);
        nonceRandom = block.timestamp;
        return randomnumber;
    }

    // events list
    event NewUpgrade(address _from, uint256 _tokenId);
}
