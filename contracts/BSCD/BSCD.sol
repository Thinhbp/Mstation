// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.4;
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./Interfaces/ILosslessERC20.sol";
import "./Interfaces/ILosslessController.sol";

contract BSCDToken is
    OwnableUpgradeable,
    ILERC20,
    AccessControlEnumerableUpgradeable,
    ReentrancyGuardUpgradeable
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bool pause;
    mapping(address => bool) public blacklist;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    address public recoveryAdmin;
    address private recoveryAdminCandidate;
    bytes32 private recoveryAdminKeyHash;
    address public override admin;
    uint256 public timelockPeriod;
    uint256 public losslessTurnOffTimestamp;
    bool public isLosslessOn;
    ILssController public lossless;

    event SetPause(bool isPause);
    event SetBlacklists(address[] _addrs, bool _isWL);
    event SetTimelock(uint256 timelock);
    event SetLossless(address lossless);

    function initialize(
        address admin_,
        address recoveryAdmin_,
        uint256 timelockPeriod_,
        address lossless_
    ) public initializer {
        __Ownable_init();
        __AccessControl_init();
        __ReentrancyGuard_init();
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _name = "BSCDium Token";
        _symbol = "BSCD";
        admin = admin_;
        recoveryAdmin = recoveryAdmin_;
        recoveryAdminCandidate = address(0);
        recoveryAdminKeyHash = "";
        timelockPeriod = timelockPeriod_;
        losslessTurnOffTimestamp = 0;
        lossless = ILssController(lossless_);
        isLosslessOn = true;
    }

    function claimReward(address _to, uint256 value) external nonReentrant {
        require(hasRole(MINTER_ROLE, _msgSender()), "Caller is not minter");
        require(!pause, "PAUSE");

        _mint(_to, value);
    }

    function updatePause(bool _pause) external onlyOwner {
        pause = _pause;
        emit SetPause(_pause);
    }

    function updateTimeLock(uint256 timelockPeriod_) external onlyOwner {
        timelockPeriod = timelockPeriod_;
        emit SetTimelock(timelockPeriod_);
    }

    function updateLossless(address lossless_) external onlyOwner {
        lossless = ILssController(lossless_);
        emit SetLossless(lossless_);
    }

    function setBlacklists(address[] calldata _addrs, bool _isBL)
        external
        onlyOwner
    {
        require(_addrs.length > 0, "INVALID_ADDRESS");
        for (uint32 i = 0; i < _addrs.length; i++) {
            blacklist[_addrs[i]] = _isBL;
        }
        emit SetBlacklists(_addrs, _isBL);
    }

    // function _beforeTokenTransfer(
    //     address from,
    //     address to,
    //     uint256 amount
    // ) internal virtual override(ERC20Upgradeable) {
    //     require(!blacklist[from], "BLACKLIST");
    // }

    /**
     * @dev Burns a specific amount of tokens.
     * @param amount The amount of lowest token units to be burned.
     */
    function burn(uint256 amount) external nonReentrant {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Can only be called by the current owner.
     * @param _wallet grant wallet address
     * @param _role role
     */
    function grantContractRole(string memory _role, address _wallet)
        external
        onlyOwner
    {
        grantRole(keccak256(abi.encodePacked(_role)), _wallet);
    }

    /**
     * @dev Can only be called by the current owner.
     * @param _wallet grant wallet address
     * @param _role role
     */
    function revokeContractRole(string memory _role, address _wallet)
        external
        onlyOwner
    {
        revokeRole(keccak256(abi.encodePacked(_role)), _wallet);
    }

    // --- LOSSLESS modifiers ---

    modifier lssAprove(address spender, uint256 amount) {
        if (isLosslessOn) {
            lossless.beforeApprove(_msgSender(), spender, amount);
        }
        _;
    }

    modifier lssTransfer(address recipient, uint256 amount) {
        if (isLosslessOn) {
            lossless.beforeTransfer(_msgSender(), recipient, amount);
        }
        _;
    }

    modifier lssTransferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) {
        if (isLosslessOn) {
            lossless.beforeTransferFrom(
                _msgSender(),
                sender,
                recipient,
                amount
            );
        }
        _;
    }

    modifier lssIncreaseAllowance(address spender, uint256 addedValue) {
        if (isLosslessOn) {
            lossless.beforeIncreaseAllowance(_msgSender(), spender, addedValue);
        }
        _;
    }

    modifier lssDecreaseAllowance(address spender, uint256 subtractedValue) {
        if (isLosslessOn) {
            lossless.beforeDecreaseAllowance(
                _msgSender(),
                spender,
                subtractedValue
            );
        }
        _;
    }

    modifier onlyRecoveryAdmin() {
        require(
            _msgSender() == recoveryAdmin,
            "LERC20: Must be recovery admin"
        );
        _;
    }

    modifier lssMint(address account, uint256 amount) {
        if (isLosslessOn) {
            lossless.beforeMint(account, amount);
        }
        _;
    }

    // --- LOSSLESS management ---
    function transferOutBlacklistedFunds(address[] calldata from)
        external
        override
    {
        require(
            _msgSender() == address(lossless),
            "LERC20: Only lossless contract"
        );

        uint256 fromLength = from.length;
        uint256 totalAmount = 0;

        for (uint256 i = 0; i < fromLength; ) {
            address fromAddress = from[i];
            uint256 fromBalance = _balances[fromAddress];
            _balances[fromAddress] = 0;
            totalAmount += fromBalance;
            emit Transfer(fromAddress, address(lossless), fromBalance);
            unchecked {
                i++;
            }
        }

        _balances[address(lossless)] += totalAmount;
    }

    function setLosslessAdmin(address newAdmin)
        external
        override
        onlyRecoveryAdmin
    {
        require(newAdmin != admin, "LERC20: Cannot set same address");
        emit NewAdmin(newAdmin);
        admin = newAdmin;
    }

    function transferRecoveryAdminOwnership(address candidate, bytes32 keyHash)
        external
        override
        onlyRecoveryAdmin
    {
        recoveryAdminCandidate = candidate;
        recoveryAdminKeyHash = keyHash;
        emit NewRecoveryAdminProposal(candidate);
    }

    function acceptRecoveryAdminOwnership(bytes memory key) external override {
        require(
            _msgSender() == recoveryAdminCandidate,
            "LERC20: Must be canditate"
        );
        require(keccak256(key) == recoveryAdminKeyHash, "LERC20: Invalid key");
        emit NewRecoveryAdmin(recoveryAdminCandidate);
        recoveryAdmin = recoveryAdminCandidate;
        recoveryAdminCandidate = address(0);
    }

    function proposeLosslessTurnOff() external override onlyRecoveryAdmin {
        require(
            losslessTurnOffTimestamp == 0,
            "LERC20: TurnOff already proposed"
        );
        require(isLosslessOn, "LERC20: Lossless already off");
        losslessTurnOffTimestamp = block.timestamp + timelockPeriod;
        emit LosslessTurnOffProposal(losslessTurnOffTimestamp);
    }

    function executeLosslessTurnOff() external override onlyRecoveryAdmin {
        require(losslessTurnOffTimestamp != 0, "LERC20: TurnOff not proposed");
        require(
            losslessTurnOffTimestamp <= block.timestamp,
            "LERC20: Time lock in progress"
        );
        isLosslessOn = false;
        losslessTurnOffTimestamp = 0;
        emit LosslessOff();
    }

    function executeLosslessTurnOn() external override onlyRecoveryAdmin {
        require(!isLosslessOn, "LERC20: Lossless already on");
        losslessTurnOffTimestamp = 0;
        isLosslessOn = true;
        emit LosslessOn();
    }

    function getAdmin() public view virtual override returns (address) {
        return admin;
    }

    // --- ERC20 methods ---

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        lssTransfer(recipient, amount)
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        lssAprove(spender, amount)
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    )
        public
        virtual
        override
        lssTransferFrom(sender, recipient, amount)
        returns (bool)
    {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "LERC20: transfer amount exceeds allowance"
        );
        _transfer(sender, recipient, amount);

        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        override
        lssIncreaseAllowance(spender, addedValue)
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        override
        lssDecreaseAllowance(spender, subtractedValue)
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "LERC20: decreased allowance below zero"
        );
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "LERC20: transfer from the zero address");
        require(!blacklist[sender], "BLACKLIST");

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "LERC20: transfer amount exceeds balance"
        );
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function mint(address to, uint256 amount)
        public
        virtual
        lssMint(to, amount)
    {
        require(_msgSender() == admin, "LERC20: Must be admin");
        _mint(to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "LERC20: mint to the zero address");

        _totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
