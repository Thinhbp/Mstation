pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "../interface/IUniswapV2Router02.sol";

contract MStationTreasury is
    Initializable,
    ContextUpgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeERC20Upgradeable for IERC20;
    using SafeMath for uint256;

    struct Transaction {
        bool isDeposit;
        uint256 tId;
        uint256 amount;
        address owner;
    }
    // pause swap
    bool public pause;
    // swapped mst
    uint256 public mstIssued;
    //
    uint256 public mstMonthlyEmission;
    // MST token address
    address public mstTokenAddress;
    // BSCS token address
    address public bscsTokenAddress;
    // pancake router
    address public router;
    // path swap
    address[] pathSwap;

    // mapping wallet => transaction counter;
    mapping(address => uint256) walletTransCounter;
    uint256 depositCounter;
    // mapping wallet => deposit transaction info;
    mapping(uint256 => Transaction) depositTransactions;
    // mapping wallet => withdraw transaction info;
    mapping(uint256 => Transaction) withdrawTransactions;

    // constructor
    function initialize(
        uint256 _mstMonthlyEmission,
        address _router,
        address _mstTokenAddress,
        address _bscsTokenAddress,
        address[] calldata _pathSwap
    ) public initializer {
        __Context_init();
        __Ownable_init();
        __ReentrancyGuard_init();
        pause = false;
        mstMonthlyEmission = _mstMonthlyEmission;
        router = _router;
        mstTokenAddress = _mstTokenAddress;
        bscsTokenAddress = _bscsTokenAddress;
        pathSwap = _pathSwap;
    }

    function setTokenAddress(
        address _mstTokenAddress,
        address _bscsTokenAddress
    ) external onlyOwner {
        require(address(_mstTokenAddress) != address(0), "INVALID_INPUT");
        require(address(_bscsTokenAddress) != address(0), "INVALID_INPUT");
        mstTokenAddress = _mstTokenAddress;
        bscsTokenAddress = _bscsTokenAddress;
        emit SetTokenAddress(_mstTokenAddress, _bscsTokenAddress);
    }

    function setRouterAddress(address _router) external onlyOwner {
        require(address(_router) != address(0), "INVALID_INPUT");
        router = _router;
    }

    function setPathAddress(address[] calldata _pathSwap) external onlyOwner {
        require(pathSwap.length > 0, "INVALID_INPUT");
        pathSwap = _pathSwap;
    }

    function setPause(bool _pause) external onlyOwner {
        pause = _pause;
    }

    /**
     * @notice
     */
    function estimateSwap(uint256 _amountIn)
        external
        view
        returns (uint256 amountOut)
    {
        require(!pause, "Paused");
        require(pathSwap.length > 0, "INVALID_PATH");
        require(_amountIn > 0, "INVALID_AMOUNT_IN");

        uint256[] memory amounts = IUniswapV2Router02(router).getAmountsOut(
            _amountIn,
            pathSwap
        );
        amountOut = amounts[amounts.length - 1].mul(99).div(100);
    }

    /**
     * @notice estimate price of any token by path
     * _amount = amount token from
     * _path[0] = from token
     * _path[end] = to token
     */
    function estimatePrice(uint256 _amount, address[] calldata _path)
        external
        view
        returns (uint256 amountOut)
    {
        require(_path.length > 0, "INVALID_PATH");
        require(_amount > 0, "INVALID_AMOUNT_IN");

        uint256[] memory amounts = IUniswapV2Router02(router).getAmountsOut(
            _amount,
            _path
        );
        amountOut = amounts[amounts.length - 1].mul(1010).div(1000);
    }

    /**
     * @notice
     */
    function swap(uint256 _amountIn, uint256 _amountOutMin)
        external
        nonReentrant
        returns (uint256 amountOut)
    {
        require(!pause, "Paused");
        require(pathSwap.length > 0, "INVALID_PATH");
        require(_amountIn > 0, "INVALID_AMOUNT_IN");

        uint256[] memory amounts = IUniswapV2Router02(router).getAmountsOut(
            _amountIn,
            pathSwap
        );
        amountOut = amounts[amounts.length - 1].mul(1010).div(1000);
        uint256 mstBalance = IERC20(mstTokenAddress).balanceOf(address(this));
        require(amountOut <= mstBalance, "BALANCE");
        require(amountOut >= _amountOutMin, "INVALID_AMOUNT_OUT");

        bool transferBscs = IERC20(bscsTokenAddress).transferFrom(
            _msgSender(),
            address(this),
            _amountIn
        );
        require(transferBscs, "TRANSFER_BSCS");

        bool transferMST = IERC20(mstTokenAddress).transfer(
            _msgSender(),
            amountOut
        );
        require(transferMST, "TRANSFER_MST");
        mstIssued = mstIssued + amountOut;

        emit Swapped(_msgSender(), amountOut);
    }

    function depositMST() external nonReentrant {
        require(!pause, "Paused");
        uint256 mstBalance = IERC20(mstTokenAddress).balanceOf(address(this));
        uint256 userBalance = IERC20(mstTokenAddress).balanceOf(_msgSender());
        uint256 amountDeposit = mstMonthlyEmission - mstBalance;
        require(userBalance >= amountDeposit, "INVALID_BALANCE");
        bool transferMST = IERC20(mstTokenAddress).transferFrom(
            _msgSender(),
            address(this),
            amountDeposit
        );
        require(transferMST, "DEPOSIT_FAILED");
        mstIssued = 0;

        emit Deposited(_msgSender(), amountDeposit);
    }

    function rescueStuckErc20(address _token) external onlyOwner {
        uint256 _amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(owner(), _amount);
        emit Rescued(_msgSender(), _amount);
    }

    function depositTokenOffchain(address _tokenAddress, uint256 _amountIn)
        external
    {
        require(
            _tokenAddress == mstTokenAddress ||
                _tokenAddress == bscsTokenAddress,
            "UNSUPPORT"
        );

        walletTransCounter[_msgSender()] = walletTransCounter[_msgSender()] + 1;
        bool transfer = IERC20(_tokenAddress).transferFrom(
            _msgSender(),
            address(this),
            _amountIn
        );
        require(transfer, "DEPOSIT_FAILED");
        depositCounter += 1;
        depositTransactions[depositCounter] = Transaction(
            true,
            depositCounter,
            _amountIn,
            _msgSender()
        );
        emit DepositToken(
            _msgSender(),
            _tokenAddress,
            _amountIn,
            depositCounter
        );
    }

    event Swapped(address receiver, uint256 amount);
    event SetTokenAddress(address token1, address token2);
    event Deposited(address sender, uint256 amount);
    event Rescued(address sender, uint256 amount);
    event DepositToken(
        address user,
        address token,
        uint256 amount,
        uint256 transId
    );
}
