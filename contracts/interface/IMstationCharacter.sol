pragma solidity ^0.8.4;

interface IMstationCharacter {
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
        uint16 teamId;
        uint16 talent;
        uint16 skill;
        uint16 combat; // damage type
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

    function ownerOf(uint256 tokenId) external view returns (address);

    function breed(address _sender, uint256 _tokenId)
        external
        returns (uint16[] memory);

    function dead(
        address _contract,
        address _user,
        uint256 _tokenId
    ) external;

    function updateMaxSupply(uint256 totalMetaverse) external;

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external;

    function attributes(uint256 _tokenId)
        external
        view
        returns (
            uint16,
            uint16,
            uint16,
            uint16,
            uint16,
            uint16
        );

    function upgradeLevel(uint256 _tokenId, uint256 _newLevel) external;

    // function combatInfo(uint256 _tokenId)
    //     external
    //     view
    //     returns (
    //         HeroCombat memory hero
    //     );

    function getLevel(uint256 _tokenId) external view returns (uint16);

    function getHeroAttribute(uint256 _tokenId)
        external
        view
        returns (HeroAttribute memory hero);

    function resetHide(uint256[] calldata _from) external;

    function reveal(uint256 _tokenId) external;
}
