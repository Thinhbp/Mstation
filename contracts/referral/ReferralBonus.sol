pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "../interface/IMstationNFTUtils.sol";

contract ReferralBonus is
    Initializable,
    ContextUpgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeERC20Upgradeable for IERC20;
    using SafeMath for uint256;

    struct UserReward {
        uint256 rewardAmount;
        uint256 deptAmount;
    }

    // pause claim reward
    bool public pause;
    // max total bonus for all user per day
    uint256 public rewardPerInvitation;
    // lfw token address
    IERC20 public rewardTokenAddress;
    // rewardWallet wallet store LFW for withdraw user reward
    address public rewardWallet;
    // mapping reward for user
    mapping(address => UserReward) public userRewards;
    // user address => claim id => status
    mapping(address => mapping(uint256 => bool)) public userRewarded;
    // mapping(address => address) referralers; mapping user address referrered by user address
    mapping(address => bool) public whitelistOperator;

    uint256 bonusPercent;
    // mapping(address => mapping(address => UserReward)) public referralLogs;
    mapping(address => UserReward) public userRewards2;
    // A referral by B => when A mint, B get bonus
    mapping(address => address) referralAddress;
    mapping(address => uint256) claimed;
    mapping(uint32 => address) public addressConfigs;
    // Set limit amount token claimed by each user

    uint256 public limitAmount;

    



    // constructor
    function initialize(
        uint256 _rewardPerInvitation,
        address _rewardTokenAddress,
        address _rewardWallet,
        address _operator
    ) public initializer {
        require(_rewardPerInvitation > 0, "rewardPerInvitation is zero");
        __Context_init();
        __Ownable_init();
        __ReentrancyGuard_init();
        pause = false;
        rewardPerInvitation = _rewardPerInvitation;
        rewardTokenAddress = IERC20(_rewardTokenAddress);
        rewardWallet = _rewardWallet;
        whitelistOperator[_operator] = true;
        bonusPercent = 10000;
    }

    function initData(uint256 _bonusPercent) public onlyOwner {
        bonusPercent = _bonusPercent;
    }

    function setRewardTokenAddress(address _rewardTokenAddress)
        external
        onlyOwner
    {
        require(address(_rewardTokenAddress) != address(0));
        rewardTokenAddress = IERC20(_rewardTokenAddress);
    }

    function setRewardTokenWalletAddress(address _rewardWallet)
        external
        onlyOwner
    {
        require(address(_rewardWallet) != address(0));
        rewardWallet = _rewardWallet;
    }

    function setPause(bool _pause) external onlyOwner {
        pause = _pause;
    }

    function setLimitClaim(uint256 _amountLimit) external onlyOwner {
        require(_amountLimit > 0, "amountLimit is zero");
        limitAmount = _amountLimit;
    }

    function updateRewardPerInvitation(uint256 _rewardPerInvitation)
        external
        onlyOwner
    {
        require(_rewardPerInvitation > 0, "rewardPerInvitation is zero");
        rewardPerInvitation = _rewardPerInvitation;
    }

    /**
     * @notice need setup reward token address and treasury wallet
     */
    function claimBonusReward(
        uint256 _amount,
        uint256 _claimId,
        bytes calldata _signature
    ) external nonReentrant {
        require(_msgSender() != address(0) && _msgSender() != address(this));
        require(!pause, "ReferralBonus: Maintain");
        require(!userRewarded[_msgSender()][_claimId], "CLAIMED");
        require(claimed[_msgSender()] < limitAmount, "LIMITED");
        require(
            !IMstationNFTUtils(addressConfigs[1]).isBlockAddress(_msgSender()),
            "Blacklist"
        );

        // validate signature
        bytes32 messageHash = keccak256(
            abi.encodePacked(_msgSender(), _amount, _claimId)
        );
        bytes32 ethSignedMessageHash = getEthSignedHash(messageHash);
        address signerAddress = verify(ethSignedMessageHash, _signature);
        require(whitelistOperator[signerAddress], "INVALID_SIGNER");

        userRewards[_msgSender()].deptAmount =
            userRewards[_msgSender()].deptAmount +
            _amount;
        userRewarded[_msgSender()][_claimId] = true;
        claimed[_msgSender()] = claimed[_msgSender()] + _amount;
        require(
            rewardTokenAddress.transfer(_msgSender(), _amount) == true,
            "ReferralBonus: Transfer reward failed"
        );

        emit ClaimBonusRewardSuccess(_msgSender(), _amount, _claimId);
    }


    function claimBonusRewardNew(
        uint256 _amount,
        uint256 _claimId,
        bytes calldata _signature
    ) external nonReentrant {
        require(_msgSender() != address(0) && _msgSender() != address(this));
        require(!pause, "ReferralBonus: Maintain");
        require(!userRewarded[_msgSender()][_claimId], "CLAIMED");
        require(claimed[_msgSender()] <= limitAmount, "LIMITED");
        require(
            !IMstationNFTUtils(addressConfigs[1]).isBlockAddress(_msgSender()),
            "Blacklist"
        );

        // validate signature
        bytes32 messageHash = keccak256(
            abi.encodePacked(_msgSender(), _amount, _claimId)
        );
        bytes32 ethSignedMessageHash = getEthSignedHash(messageHash);
        address signerAddress = verify(ethSignedMessageHash, _signature);
        require(whitelistOperator[signerAddress], "INVALID_SIGNER");

        userRewards[_msgSender()].deptAmount =
            userRewards[_msgSender()].deptAmount +
            _amount;
        userRewarded[_msgSender()][_claimId] = true;
        claimed[_msgSender()] = claimed[_msgSender()] + _amount;
        require(
            rewardTokenAddress.transfer(_msgSender(), _amount) == true,
            "ReferralBonus: Transfer reward failed"
        );

        emit ClaimBonusRewardSuccess(_msgSender(), _amount, _claimId);
    }

    function claimBonusRewardNewest(
        uint256 _amount,
        uint256 _claimId,
        bytes calldata _signature
    ) external nonReentrant {
        require(_msgSender() != address(0) && _msgSender() != address(this));
        require(!pause, "ReferralBonus: Maintain");
        require(!userRewarded[_msgSender()][_claimId], "CLAIMED");
        //require(_amount <= limitAmount, "LIMITED");
        require(
            !IMstationNFTUtils(addressConfigs[1]).isBlockAddress(_msgSender()),
            "Blacklist"
        );

        // validate signature
        bytes32 messageHash = keccak256(
            abi.encodePacked(_msgSender(), _amount, _claimId)
        );
        bytes32 ethSignedMessageHash = getEthSignedHash(messageHash);
        address signerAddress = verify(ethSignedMessageHash, _signature);
        require(whitelistOperator[signerAddress], "INVALID_SIGNER");

        userRewards[_msgSender()].deptAmount =
            userRewards[_msgSender()].deptAmount +
            _amount;
        userRewarded[_msgSender()][_claimId] = true;
        claimed[_msgSender()] = claimed[_msgSender()] + _amount;
        require(
            rewardTokenAddress.transfer(_msgSender(), _amount) == true,
            "ReferralBonus: Transfer reward failed"
        );

        emit ClaimBonusRewarNewest(_msgSender(), _amount, _claimId);
    }

    function bond(address _refferer) external {
        require(_refferer != address(0x0));
        require(referralAddress[_msgSender()] == address(0), "Bonded");
        referralAddress[_msgSender()] = _refferer;
        emit NewBond(_msgSender(), _refferer);
    }

    function makeBonus(uint256 _totalValue) external nonReentrant {
        if (referralAddress[_msgSender()] != address(0)) {
            address _refferer = referralAddress[_msgSender()];
            userRewards2[_refferer].rewardAmount =
                userRewards2[_refferer].rewardAmount +
                _totalValue.mul(bonusPercent).div(100_000);
        }
    }

    function claimBonusReward2() external nonReentrant {
        require(_msgSender() != address(0) && _msgSender() != address(this));
        require(!pause, "ReferralBonus: Maintain");
        require(
            userRewards2[_msgSender()].rewardAmount >
                userRewards2[_msgSender()].deptAmount
        );

        uint256 _amount = userRewards2[_msgSender()].rewardAmount -
            userRewards2[_msgSender()].deptAmount;

        userRewards2[_msgSender()].deptAmount =
            userRewards2[_msgSender()].deptAmount +
            _amount;
        require(
            rewardTokenAddress.transferFrom(
                payable(rewardWallet),
                _msgSender(),
                _amount
            ) == true,
            "ReferralBonus: Transfer reward failed"
        );

        emit ClaimBonusRewardSuccess2(_msgSender(), _amount);
    }

    /**
     * @notice get user pending reward
     */
    function getPendingReward() public view returns (uint256) {
        require(_msgSender() != address(0) && _msgSender() != address(this));
        return
            userRewards2[_msgSender()].rewardAmount -
            userRewards2[_msgSender()].deptAmount;
    }

    /**
     * @notice get referral of user
     */
    function getReferral() public view returns (address) {
        require(_msgSender() != address(0) && _msgSender() != address(this));
        require(referralAddress[_msgSender()] != address(0));

        return referralAddress[_msgSender()];
    }

    function setWhitelistOperator(address[] calldata _operator, bool _whitelist)
        external
        onlyOwner
    {
        require(_operator.length > 0, "Total invalid");
        for (uint256 index = 0; index < _operator.length; index++) {
            whitelistOperator[_operator[index]] = _whitelist;
        }
    }

    function updateAddressConfigs(
        uint32[] memory ids,
        address[] memory _address
    ) external onlyOwner {
        for (uint256 i = 0; i < ids.length; i++) {
            addressConfigs[ids[i]] = _address[i];
        }
    }

    /**
     * @notice Transfer ETH and return the success status.
     * @dev This function only forwards 30,000 gas to the callee.
     */
    function _safeTransferETH(address to, uint256 value)
        internal
        returns (bool)
    {
        (bool success, ) = to.call{value: value, gas: 30_000}(new bytes(0));
        return success;
    }

  function validateSignature(
        uint256 _amount,
        uint256 _claimId,
        bytes calldata _signature
    ) external nonReentrant returns (address signerAddress) {
        // validate signature
        bytes32 messageHash = keccak256(
            abi.encodePacked(_msgSender(), _amount, _claimId)
        );
        bytes32 ethSignedMessageHash = getEthSignedHash(messageHash);
        signerAddress = verify(ethSignedMessageHash, _signature);
    }
    
    function getEthSignedHash(bytes32 _messageHash)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    _messageHash
                )
            );
    }

    function verify(bytes32 _ethSignedMessageHash, bytes memory _signature)
        internal
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        internal
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }

    event NewReferral(address indexed owner, uint256 amount);
    event NewBond(address indexed owner, address referrer);
    event ClaimBonusRewardSuccess(
        address indexed owner,
        uint256 amount,
        uint256 claimId
    );
    event ClaimBonusRewardSuccess2(address indexed owner, uint256 amount);
    event ClaimBonusRewarNewest(
        address indexed owner,
        uint256 amount,
        uint256 claimId
    );
}