pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "../interface/IMstationNFTUtils.sol";

contract MStationWallet is
    Initializable,
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
    struct UserProfile {
        uint16 status; // 1: normal, 2: limited
        uint16 credit;
        uint16 class;
        uint256 totalDeposit;
        uint256 totalWithdraw;
        uint256 balance;
        uint256 lockedAmount;
    }
    // pause swap
    bool public pause;
    // mapping(address => address) referralers; mapping user address referrered by user address
    mapping(address => bool) public whitelistOperator;
    mapping(uint32 => address) public addressConfigs;
    address public mstTokenAddress;
    // BSCS token address
    address public bscsTokenAddress;
    // mapping wallet => transaction counter;
    mapping(address => uint256) walletTransCounter;
    uint256 depositCounter;
    // mapping wallet => deposit transaction info;
    mapping(uint256 => Transaction) depositTransactions;
    // mapping wallet => withdraw transaction info;
    mapping(uint256 => Transaction) public withdrawTransactions;
    // mapping user address => profile
    mapping(address => UserProfile) userProfiles;

    uint256 balanceMint;
    uint256 balanceGameReward;
    address public feeWallet;
    uint public maxAmount; 
    uint public maxBSCD;

    // constructor
    function initialize(
        address _mstTokenAddress,
        address _bscdTokenAddress,
        address _operator,
        address _feeWallet
    ) public initializer {
        __Context_init();
        __Ownable_init();
        __ReentrancyGuard_init();
        mstTokenAddress = _mstTokenAddress;
        bscsTokenAddress = _bscdTokenAddress;
        whitelistOperator[_operator] = true;
        feeWallet = _feeWallet;
        addressConfigs[1] = 0xf086642A6f854bcd53773E8E91F2D611Ad1888e8;
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

    function setFeeAddress(address _feeWallet) external onlyOwner {
        feeWallet = _feeWallet;
    }

    function setPause(bool _pause) external onlyOwner {
        pause = _pause;
    }

    // function setmaxAmount(uint _maxAmount) external onlyOwner {
    //     maxAmount = _maxAmount;
    // }

    function setmaxAmount(uint _maxAmount, uint _maxBSCD) external onlyOwner {
        maxAmount = _maxAmount;
        maxBSCD = _maxBSCD;
    }


    function rescueStuckErc20(address _token) external onlyOwner {
        uint256 _amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(owner(), _amount);
        emit Rescued(_msgSender(), _amount);
    }

    // function depositTokenOnchain(address _tokenAddress, uint256 _amountIn)
    //     external
    //     nonReentrant
    // {
    //     require(
    //         _tokenAddress == mstTokenAddress ||
    //             _tokenAddress == bscsTokenAddress,
    //         "UNSUPPORT"
    //     );

    //     walletTransCounter[_msgSender()] = walletTransCounter[_msgSender()] + 1;
    //     bool transfer = IERC20(_tokenAddress).transferFrom(
    //         _msgSender(),
    //         address(this),
    //         _amountIn
    //     );

    //     //Check BSCS 
    //     uint bscsBalance = IERC20(mstTokenAddress).balanceOf(address(this));
    //     //Check BSCD
    //     uint bscdBalance = IERC20(bscsTokenAddress).balanceOf(address(this));
    //     if (bscsBalance > maxAmount && feeWallet != address(0)) {
    //         IERC20(mstTokenAddress).transfer(feeWallet, bscsBalance - maxAmount);
    //     }

    //     if (bscdBalance  > maxBSCD && feeWallet != address(0)) {
    //         IERC20(bscsTokenAddress).transfer(feeWallet, bscdBalance - maxBSCD);
    //     }
    //     require(transfer, "DEPOSIT_FAILED");
    //     depositCounter += 1;
    //     depositTransactions[depositCounter] = Transaction(
    //         true,
    //         depositCounter,
    //         _amountIn,
    //         _msgSender()
    //     );
    //     emit DepositToken(
    //         _msgSender(),
    //         _tokenAddress,
    //         _amountIn,
    //         depositCounter
    //     );
    // }


    function depositTokenOnchain(address _tokenAddress, uint256 _amountIn)
        external
        nonReentrant
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
         //Check BSCS 
        uint bscsBalance = IERC20(mstTokenAddress).balanceOf(address(this));
        //Check BSCD
        uint bscdBalance = IERC20(bscsTokenAddress).balanceOf(address(this));


        if (bscsBalance > maxAmount && feeWallet != address(0)) {
            IERC20(mstTokenAddress).transfer(feeWallet, bscsBalance - maxAmount);
        }

        if (bscdBalance > maxBSCD && feeWallet != address(0)) {
            IERC20(bscsTokenAddress).transfer(feeWallet, bscdBalance - maxBSCD);
        }


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

    // function withdrawTokenOffchain(
    //     address _tokenAddress,
    //     uint256 _amountIn,
    //     uint256 _requestId,
    //     uint256 _createTime,
    //     bytes calldata _signature
    // ) external nonReentrant {
    //     require(block.timestamp <= (_createTime + 3 * 60), "EXPIRED");
    //     require(!pause, "PAUSED");
    //     require(
    //         _tokenAddress == mstTokenAddress ||
    //             _tokenAddress == bscsTokenAddress,
    //         "UNSUPPORT"
    //     );
    //     // require(
    //     //     !IMstationNFTUtils(addressConfigs[1]).isBlockAddress(_msgSender()),
    //     //     "Blacklist"
    //     // );
    //     require(
    //         withdrawTransactions[_requestId].amount == 0,
    //         "INVALID_REQUEST"
    //     );
    //     if (_tokenAddress == mstTokenAddress) {
    //         require(_amountIn >= 50 * 1e18, "MIN");
    //     } else if (_tokenAddress == bscsTokenAddress) {
    //         require((_amountIn  >= 2000 * 1e18), "MINIMUM");
    //     }

    //     // validate balance
    //     bytes32 ethSignedMessageHash = getEthSignedHash(
    //         keccak256(
    //             abi.encodePacked(
    //                 _msgSender(),
    //                 _tokenAddress,
    //                 _amountIn,
    //                 _requestId,
    //                 _createTime
    //             )
    //         )
    //     );
    //     address signerAddress = verify(ethSignedMessageHash, _signature);
    //     require(whitelistOperator[signerAddress], "INVALID_SIGNER");
    //     uint256 feeAmount = (_amountIn * 15) / 100;
    //     bool transfer = IERC20(_tokenAddress).transfer(
    //         _msgSender(),
    //         (_amountIn - feeAmount)
    //     );
    //     require(transfer, "WITHDRAW_FAILED");
    //     // IERC20(_tokenAddress).transfer(feeWallet, feeAmount);
    //     withdrawTransactions[_requestId] = Transaction(
    //         false,
    //         _requestId,
    //         _amountIn,
    //         _msgSender()
    //     );
    //     emit WithdrawToken(_msgSender(), _tokenAddress, (_amountIn - feeAmount), _requestId);
    // }
    //  function withdrawTokenOffchainNewest(
    //     address _tokenAddress,
    //     uint256 _amountIn,
    //     uint256 _requestId,
    //     uint256 _createTime,
    //     bytes calldata _signature
    // ) external nonReentrant {
    //     require(block.timestamp <= (_createTime + 3 * 60), "EXPIRED");
    //     require(!pause, "PAUSED");
    //     require(
    //         _tokenAddress == mstTokenAddress ||
    //             _tokenAddress == bscsTokenAddress,
    //         "UNSUPPORT"
    //     );
    //     // require(
    //     //     !IMstationNFTUtils(addressConfigs[1]).isBlockAddress(_msgSender()),
    //     //     "Blacklist"
    //     // );
    //     require(
    //         withdrawTransactions[_requestId].amount == 0,
    //         "INVALID_REQUEST"
    //     );
        

    //     // validate balance
    //     bytes32 ethSignedMessageHash = getEthSignedHash(
    //         keccak256(
    //             abi.encodePacked(
    //                 _msgSender(),
    //                 _tokenAddress,
    //                 _amountIn,
    //                 _requestId,
    //                 _createTime
    //             )
    //         )
    //     );
    //     address signerAddress = verify(ethSignedMessageHash, _signature);
    //     require(whitelistOperator[signerAddress], "INVALID_SIGNER");
    //     uint256 feeAmount = (_amountIn * 15) / 100;
    //     bool transfer = IERC20(_tokenAddress).transfer(
    //         _msgSender(),
    //         (_amountIn - feeAmount)
    //     );
    //     require(transfer, "WITHDRAW_FAILED");
    //     IERC20(_tokenAddress).transfer(feeWallet, feeAmount);

    //     //Check BSCS 
    //     uint bscsBalance = IERC20(mstTokenAddress).balanceOf(address(this));
    //     if (bscsBalance > maxAmount && feeWallet != address(0)) {
    //         IERC20(mstTokenAddress).transfer(feeWallet, bscsBalance - maxAmount);
    //     }


    //     withdrawTransactions[_requestId] = Transaction(
    //         false,
    //         _requestId,
    //         _amountIn,
    //         _msgSender()
    //     );
    //     emit WithdrawToken(_msgSender(), _tokenAddress, (_amountIn - feeAmount), _requestId);
    // }



    function withdrawTokenOffchainNewest(
        address _tokenAddress,
        uint256 _amountIn,
        uint256 _requestId,
        uint256 _createTime,
        bytes calldata _signature
    ) external nonReentrant {
        require(block.timestamp <= (_createTime + 3 * 60), "EXPIRED");
        require(!pause, "PAUSED");
        require(
            _tokenAddress == mstTokenAddress ||
                _tokenAddress == bscsTokenAddress,
            "UNSUPPORT"
        );
        // require(
        //     !IMstationNFTUtils(addressConfigs[1]).isBlockAddress(_msgSender()),
        //     "Blacklist"
        // );
        require(
            withdrawTransactions[_requestId].amount == 0,
            "INVALID_REQUEST"
        );
        

        // validate balance
        bytes32 ethSignedMessageHash = getEthSignedHash(
            keccak256(
                abi.encodePacked(
                    _msgSender(),
                    _tokenAddress,
                    _amountIn,
                    _requestId,
                    _createTime
                )
            )
        );
        address signerAddress = verify(ethSignedMessageHash, _signature);
        require(whitelistOperator[signerAddress], "INVALID_SIGNER");
        uint256 feeAmount = (_amountIn * 15) / 100;
        bool transfer = IERC20(_tokenAddress).transfer(
            _msgSender(),
            (_amountIn - feeAmount)
        );
        require(transfer, "WITHDRAW_FAILED");
        IERC20(_tokenAddress).transfer(feeWallet, feeAmount);

        //Check BSCS 
        uint bscsBalance = IERC20(mstTokenAddress).balanceOf(address(this));
        //Check BSCD
        uint bscdBalance = IERC20(bscsTokenAddress).balanceOf(address(this));


        if (bscsBalance > maxAmount && feeWallet != address(0)) {
            IERC20(mstTokenAddress).transfer(feeWallet, bscsBalance - maxAmount);
        }

        if (bscdBalance > maxBSCD && feeWallet != address(0)) {
            IERC20(bscsTokenAddress).transfer(feeWallet, bscdBalance - maxBSCD);
        }


        withdrawTransactions[_requestId] = Transaction(
            false,
            _requestId,
            _amountIn,
            _msgSender()
        );
        emit WithdrawToken(_msgSender(), _tokenAddress, (_amountIn - feeAmount), _requestId);
    }

    function validateSignature(
        address _user,
        address _tokenAddress,
        uint256 _amountIn,
        uint256 _requestId,
        uint256 _createTime,
        bytes calldata _signature
    ) external nonReentrant {
        bytes32 ethSignedMessageHash = getEthSignedHash(
            keccak256(
                abi.encodePacked(
                    _user,
                    _tokenAddress,
                    _amountIn,
                    _requestId,
                    _createTime
                )
            )
        );
        address signerAddress = verify(ethSignedMessageHash, _signature);
        emit Signature(
            _user,
            _tokenAddress,
            _amountIn,
            _requestId,
            signerAddress
        );
    }

    function depositReward(address _tokenAddress, uint256 _amountIn)
        external
        nonReentrant
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
        emit DepositReward(_msgSender(), _tokenAddress, _amountIn);
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

    function updateAddressConfigs(
        uint32[] memory ids,
        address[] memory _address
    ) external onlyOwner {
        for (uint256 i = 0; i < ids.length; i++) {
            addressConfigs[ids[i]] = _address[i];
        }
    }

    event SetTokenAddress(address token1, address token2);
    event Rescued(address sender, uint256 amount);
    event DepositToken(
        address user,
        address token,
        uint256 amount,
        uint256 transId
    );
    event WithdrawToken(
        address user,
        address token,
        uint256 amount,
        uint256 transId
    );
    event DepositReward(address admin, address token, uint256 amount);
    event Signature(
        address admin,
        address token,
        uint256 amount,
        uint256 requestId,
        address signer
    );
}
