pragma solidity ^0.8.4;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interface/IUniswapV2Router01.sol";
import "../interface/IMstationCharacter.sol";

contract MstationNFTUtils is Initializable, OwnableUpgradeable {
    using SafeMath for uint256;
    mapping(address => bool) operatorAddress;
    mapping(address => bool) blacklistAddress;
    mapping(uint256 => bool) blacklistNFT;

    function initialize() public initializer {
        __Ownable_init();
        operatorAddress[
            address(0x4BFBE60Cd5B7D6A73f12dba42014CB744b0C5D4a)
        ] = true;
        operatorAddress[_msgSender()] = true;
    }

    function isBlockAddress(address _address)
        external
        returns (bool isBlocked)
    {
        isBlocked = blacklistAddress[_address];
    }

    function isBlockNFT(uint256 _tokenId) external returns (bool isBlocked) {
        isBlocked = blacklistNFT[_tokenId];
    }

    function setBlacklistAddress(address[] calldata _address, bool _blacklist)
        external
        onlyOwner
    {
        require(_address.length > 0, "INVALID_INPUT");
        for (uint256 i = 0; i < _address.length; i++) {
            blacklistAddress[_address[i]] = _blacklist;
        }
    }

    function setBlacklistNFT(uint256[] calldata _nfts, bool _blacklist)
        external
        onlyOwner
    {
        require(_nfts.length > 0, "INVALID_INPUT");
        for (uint256 i = 0; i < _nfts.length; i++) {
            blacklistNFT[_nfts[i]] = _blacklist;
        }
    }

    function setOperatorAddress(address _pveAddress, bool _whitelist)
        external
        onlyOwner
    {
        require(_pveAddress != address(0x0), "INVALID_INPUT");
        operatorAddress[_pveAddress] = _whitelist;
    }
}
