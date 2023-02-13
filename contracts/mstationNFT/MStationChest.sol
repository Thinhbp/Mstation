// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

contract MStationChest is
    Initializable,
    ERC1155Upgradeable,
    OwnableUpgradeable,
    AccessControlEnumerableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeMath for uint256;
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant CONTRACT_ROLE = keccak256("CONTRACT_ROLE");
    uint256 public openChestFee;
    // store lfwToken
    address public treasury;
    // auto legendary chest id
    uint256 public openChestId;
    // disable open chest
    bool public lockChest;

    // events list
    event ItemMint(address minter, uint256 token_id, uint256 amount);
    event ItemMintBatch(address minter, uint256[] token_id, uint256[] amount);
    event ItemBurn(address minter, uint256 token_id, uint256 amount);
    event ItemBurnBatch(address minter, uint256[] token_id, uint256[] amount);
    event OpenTreasuryChest(
        uint256 chest_id,
        address minter,
        uint256 token_id,
        uint256 amount
    );

    function initialize() public initializer {
        __Ownable_init();
        __ERC1155_init("MStationChest");
        __ReentrancyGuard_init();
        __AccessControlEnumerable_init_unchained();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    // @dev update uri of token
    function setBaseUri(string calldata uri) external onlyOwner {
        _setURI(uri);
    }

    /** 
    / @dev mint more item for sender
    / @param _minter address of receiver
    / @param _tokenId id of item
    / @param _amount of item
    */
    function mintItem(
        address _minter,
        uint256 _tokenId,
        uint256 _amount
    ) external nonReentrant {
        require(
            hasRole(OPERATOR_ROLE, _msgSender()),
            "MStationChest:INVALID_OPERATOR"
        );
        _mint(_minter, _tokenId, _amount, "");
        emit ItemMint(_minter, _tokenId, _amount);
    }

    /**
     * operator can mint some NFT1155 depend on game type
     */
    function mintItems(
        address _minter,
        uint256[] memory _tokenIds,
        uint256[] memory _amounts,
        bytes memory data
    ) external nonReentrant {
        require(
            hasRole(OPERATOR_ROLE, _msgSender()),
            "MStationChest:INVALID_OPERATOR"
        );
        require(_minter != address(0), "MStationChest: INVALID_MINTER");
        require(
            _tokenIds.length == _amounts.length,
            "MStationChest: INVALID_AMOUNT"
        );

        _mintBatch(_minter, _tokenIds, _amounts, data);
        emit ItemMintBatch(_minter, _tokenIds, _amounts);
    }

    /**
     * only contract of MStation can call it.
     * support for mint key, chest,
     */
    function mintChestKey(
        address _minter,
        uint256[] memory _tokenIds,
        uint256[] memory _amounts,
        bytes memory data
    ) external nonReentrant {
        require(
            hasRole(CONTRACT_ROLE, _msgSender()),
            "MStationChest:INVALID_CONTRACT_ROLE"
        );
        require(_minter != address(0), "MStationChest: INVALID_MINTER");
        require(
            _tokenIds.length == _amounts.length,
            "MStationChest: INVALID_AMOUNT"
        );

        _mintBatch(_minter, _tokenIds, _amounts, data);
        emit ItemMintBatch(_minter, _tokenIds, _amounts);
    }

    /**
     * @notice: user have to pay mint fee before mint.
     */

    /**
     * @dev Destroys `amount` tokens of token type `id` from `account`
     * if item imported to game it must be burned
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens of token type `id`.
     */
    function burnItem(uint256 tokenId, uint256 amount) external {
        require(
            msg.sender != address(0),
            "MStationChest: burn from the zero address"
        );

        _burn(msg.sender, tokenId, amount);
        emit ItemBurn(msg.sender, tokenId, amount);
    }

    /**
     * @dev
     *
     * Requirements:
     * - `account` cannot be the zero address.
     * - `ids` and `amounts` must have the same length.
     */
    function burnBatchItem(uint256[] memory tokenIds, uint256[] memory amounts)
        external
    {
        require(
            msg.sender != address(0),
            "MStationChest: burn from the zero address"
        );
        require(
            msg.sender != address(this),
            "MStationChest: burn from this contract address"
        );
        require(
            tokenIds.length == amounts.length,
            "MStationChest: ids and amounts length mismatch"
        );

        _burnBatch(msg.sender, tokenIds, amounts);
        emit ItemBurnBatch(msg.sender, tokenIds, amounts);
    }

    /**
     * Requirements: chest tokenid server 1: 1001100249
     * - `sender` cannot be the zero address.
     * - `ids` and `amounts` must have the same length.
     */
    function openChest(uint256 tokenId, uint256 amount) external payable {
        require(
            msg.sender != address(this),
            "MStationChest: burn from this contract address"
        );
        require(
            msg.value == openChestFee.mul(amount),
            "MStationChest: OPEN_FEE_INVALID"
        );
        require(tokenId == 1001100249, "MStationChest: INVALID_CHEST");
        if (openChestFee > 0) {
            payable(treasury).transfer(msg.value);
        }
        _burn(msg.sender, tokenId, amount);

        openChestId = openChestId.add(1);
        emit OpenTreasuryChest(openChestId, msg.sender, tokenId, amount);
    }

    function updateOpenChestFee(uint256 _baseFee) public onlyOwner {
        openChestFee = _baseFee;
    }

    //@dev update treasury wallet address.
    function setTreasury(address _treasury) external onlyOwner {
        require(_treasury != address(0) && _treasury != address(this));
        treasury = _treasury;
    }

    /**
     * @dev Can only be called by the current owner.
     * @param _wallet grant wallet address
     * @param _role role
     */
    function grantContractRole(string memory _role, address _wallet)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        grantRole(keccak256(abi.encodePacked(_role)), _wallet);
    }

    /**
     * @dev Can only be called by the current owner.
     * @param _wallet grant wallet address
     * @param _role role
     */
    function revokeContractRole(string memory _role, address _wallet)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        revokeRole(keccak256(abi.encodePacked(_role)), _wallet);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(AccessControlEnumerableUpgradeable, ERC1155Upgradeable)
        returns (bool)
    {
        return this.supportsInterface(interfaceId);
    }
}
