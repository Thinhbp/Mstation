pragma solidity 0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

/**
 * @title TokenVesting
 * @dev A token holder contract that can release its token balance gradually like a
 * typical vesting scheme, with a cliff and vesting period. Optionally revocable by the
 * owner.
 */
contract TokenVesting is
    Initializable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeMath for uint256;
    using SafeERC20Upgradeable for ERC20Upgradeable;

    event Released(address beneficiary, uint256 amount);
    event Revoked(address beneficiary, ERC20Upgradeable token);

    struct VestingSchedule {
        // beneficiary of tokens after they are released
        address beneficiary;
        // start time of the vesting period
        uint256 releaseTimestamp;
        // total amount of tokens to be released at the end of the vesting
        uint256 amount;
        // amount of tokens released
        uint256 released;
        // whether or not the vesting has been revoked
        bool revoked;
    }
    //
    mapping(address => mapping(uint256 => VestingSchedule)) vestingSchedules;
    mapping(address => uint16) vestingCounts;
    ERC20Upgradeable token;
    uint256 public cliff;
    uint256 public start;
    bool public revocable;
    mapping(address => bool) public revoked;

    function initialize(
        address _token,
        uint256 _start,
        uint256 _cliff,
        bool _revocable
    ) public initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        require(_token != address(0x0));
        token = ERC20Upgradeable(_token);
        revocable = _revocable;
        cliff = _start.add(_cliff);
        start = _start;
    }

    //IDO Wallet A, total vesting 100.000 MST, claim day 29 monthly, 6 months. => 1 month = 100.000/6
    function createVesting(
        address beneficiary,
        uint256 totalVesting,
        uint256[] calldata claimTimestamps
    ) external {
        // verify
        require(beneficiary != address(0), "INVALID_BENEFICIARY");
        require(totalVesting > 0, "INVALID_AMOUNT");
        require(claimTimestamps.length > 0, "INVALID_TIME");

        for (uint256 i = 0; i < claimTimestamps.length; i++) {
            VestingSchedule memory aVesting = VestingSchedule(
                beneficiary,
                claimTimestamps[i],
                totalVesting.div(claimTimestamps.length),
                0,
                false
            );
            vestingSchedules[beneficiary][i] = aVesting;
        }
        vestingCounts[beneficiary] = uint16(claimTimestamps.length);
    }

    /**
     * @notice Transfers vested tokens to beneficiary.
     */
    function release(address beneficiary) external nonReentrant {
        require(!revoked[beneficiary], "beneficiary_revoked");
        require(getCurrentTime() > cliff, "cliff");

        uint256 currentTime = getCurrentTime();
        uint16 vestingCount = vestingCounts[beneficiary];
        uint256 unreleased = 0;
        for (uint16 i = 0; i < vestingCount; i++) {
            VestingSchedule memory vesting = vestingSchedules[beneficiary][i];
            if (currentTime >= vesting.releaseTimestamp) {
                unreleased = unreleased + (vesting.amount - vesting.released);
                vestingSchedules[beneficiary][i].released = vestingSchedules[
                    beneficiary
                ][i].amount;
            }
        }
        require(unreleased > 0, "INVALID_AMOUNT");

        bool result = token.transfer(beneficiary, unreleased);
        require(result, "TRANSFER_FAILED");

        emit Released(beneficiary, unreleased);
    }

    /**
     * @notice Allows the owner to revoke the vesting. Tokens already vested
     * remain in the contract, the rest are returned to the owner.
     */
    function revoke(address beneficiary) public onlyOwner {
        require(revocable, "revocable");
        revoked[beneficiary] = true;
        uint256 refund = 0;
        uint16 vestingCount = vestingCounts[beneficiary];
        for (uint16 i = 0; i < vestingCount; i++) {
            VestingSchedule memory vesting = vestingSchedules[beneficiary][i];
            if (vesting.released < vesting.amount) {
                vestingSchedules[beneficiary][i].revoked = true;
                refund = refund + (vesting.amount - vesting.released);
            }
        }

        bool result = token.transfer(_msgSender(), refund);
        require(result, "TRANSFER_FAILED");
        emit Revoked(beneficiary, token);
    }

    /**
     * @dev Calculates the amount that has already vested but hasn't been released yet.
     */
    function releasableAmount(address beneficiary)
        public
        view
        returns (uint256 vestedAmount)
    {
        uint256 currentTime = getCurrentTime();
        uint16 vestingCount = vestingCounts[beneficiary];
        if (getCurrentTime() < cliff) {
            return 0;
        }
        for (uint16 i = 0; i < vestingCount; i++) {
            VestingSchedule memory vesting = vestingSchedules[beneficiary][i];
            if (
                vesting.amount > vesting.released &&
                !vesting.revoked &&
                currentTime >= vesting.releaseTimestamp
            ) {
                vestedAmount =
                    vestedAmount +
                    (vesting.amount - vesting.released);
            }
        }
    }

    function getCurrentTime() internal view virtual returns (uint256) {
        return block.timestamp;
    }

    function rescueStuckErc20(address _token) external onlyOwner {
        uint256 _amount = ERC20Upgradeable(_token).balanceOf(address(this));
        ERC20Upgradeable(_token).transfer(owner(), _amount);
    }
}
