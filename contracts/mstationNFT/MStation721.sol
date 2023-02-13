// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./BaseMStationNFT.sol";

contract MStation721 is Initializable, BaseMStationNFT {
    using SafeMath for uint256;

    function initialize(
        address _factory,
        address _school,
        string calldata _name,
        uint256 _rarity,
        uint256[] calldata _minValues,
        uint256[] calldata _maxValues,
        uint16[] calldata _configs
    ) public initializer {
        __Ownable_init();
        base_initialize("MStation", _name);
        factory = _factory;
        mstationSchool = _school;
        rarity = _rarity;
        minValues = _minValues;
        maxValues = _maxValues;
        configs = _configs; // 0: adv, 1: disadv, 2: damageType, 3: role
        maxSupply = _rarity; // init 100.000 NFT for all with rarity
    }

    function breed(address _sender, uint256 _tokenId)
        external
        returns (uint16[] memory attribute)
    {
        require(_msgSender() == factory, "INVALID_FACTORY");
        require(minValues.length > 5 && maxValues.length > 5, "INVALID_VALUE");
        require(configs.length > 1, "INVALID_CONFIG");

        attribute = new uint16[](6);

        attribute[0] = uint16(random(1, 100)); //getStrength();
        attribute[1] = uint16(random(1, 100)); //getStamina();
        attribute[2] = uint16(random(1, 100)); //getVitality();
        attribute[3] = uint16(random(1, 100)); //getCourage();
        attribute[4] = uint16(random(1, 100)); //getDexterity();
        attribute[5] = uint16(random(1, 100)); //getIntelligence();

        super.Breed(
            _sender,
            _tokenId,
            attribute[0],
            attribute[1],
            attribute[2],
            attribute[3],
            attribute[4],
            attribute[5],
            attribute[configs[0]],
            attribute[configs[1]]
        );
    }

    function _breed(address _sender, uint256 _tokenId)
        internal
        returns (uint16[] memory attribute)
    {
        attribute = new uint16[](6);

        attribute[0] = uint16(random(1, 100)); //getStrength();
        attribute[1] = uint16(random(1, 100)); //getStamina();
        attribute[2] = uint16(random(1, 100)); //getVitality();
        attribute[3] = uint16(random(1, 100)); //getCourage();
        attribute[4] = uint16(random(1, 100)); //getDexterity();
        attribute[5] = uint16(random(1, 100)); //getIntelligence();

        super.Breed(
            _sender,
            _tokenId,
            attribute[0],
            attribute[1],
            attribute[2],
            attribute[3],
            attribute[4],
            attribute[5],
            attribute[configs[0]],
            attribute[configs[1]]
        );
    }

    function updateMaxSupply(uint256 totalMetaverse) external {
        require(totalMetaverse > 0, "total metaverse is zero");
        require(
            _msgSender() == factory || _msgSender() == owner(),
            "INVALID_FACTORY"
        );
        maxSupply = totalMetaverse.mul(uint256(rarity)).div(100000);
    }

    function updateFactory(address _factory) external onlyOwner {
        require(_factory != address(0));
        factory = _factory;
    }

    function updateAttribute(
        uint256[] calldata _minValues,
        uint256[] calldata _maxValues
    ) external onlyOwner {
        require(_minValues.length > 0, "input");
        minValues = _minValues;
        maxValues = _maxValues;
    }

    function testBreed(address _sender, uint256 _tokenId) external onlyOwner {
        _breed(_sender, _tokenId);
    }
}
