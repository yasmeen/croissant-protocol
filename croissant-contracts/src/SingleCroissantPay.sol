// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.13;

import "@gnosis.pm/zodiac/contracts/core/Module.sol";

interface IDai {
    // --- ERC20 Data ---
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function version() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function nonces(address owner) external view returns (uint256);

    // --- Events ---
    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);

    // --- ERC20 Mutations ---
    function transfer(address dst, uint wad) external returns (bool);
    function transferFrom(address src, address dst, uint wad) external returns (bool);
    function approve(address usr, uint wad) external returns (bool);
    function mint(address usr, uint wad) external;
    function burn(address usr, uint wad) external;

    // --- Alias ---
    function push(address usr, uint wad) external;
    function pull(address usr, uint wad) external;
    function move(address src, address dst, uint wad) external;

    // --- Approve by signature ---
    function permit(address holder, address spender, uint256 nonce, uint256 expiry,
                    bool allowed, uint8 v, bytes32 r, bytes32 s) external;
}

interface ISavingsDai {
    // --- ERC20 Data ---
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function version() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function nonces(address owner) external view returns (uint256);

    // --- Events ---
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares);
    event Withdraw(address indexed sender, address indexed receiver, address indexed owner, uint256 assets, uint256 shares);
    event Referral(uint16 indexed referral, address indexed owner, uint256 assets, uint256 shares);

    // --- ERC20 Mutations ---
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

    // --- ERC-4626 ---
    function asset() external view returns (address);
    function totalAssets() external view returns (uint256);
    function convertToShares(uint256 assets) external view returns (uint256);
    function convertToAssets(uint256 shares) external view returns (uint256);
    function maxDeposit(address owner) external pure returns (uint256);
    function previewDeposit(uint256 assets) external view returns (uint256);
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);
    function deposit(uint256 assets, address receiver, uint16 referral) external returns (uint256 shares);
    function maxMint(address owner) external pure returns (uint256);
    function previewMint(uint256 shares) external view returns (uint256);
    function mint(uint256 shares, address receiver) external returns (uint256 assets);
    function mint(uint256 shares, address receiver, uint16 referral) external returns (uint256 assets);
    function maxWithdraw(address owner) external view returns (uint256);
    function previewWithdraw(uint256 assets) external view returns (uint256);
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);
    function maxRedeem(address owner) external view returns (uint256);
    function previewRedeem(uint256 shares) external view returns (uint256);
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);

    // --- Approve by signature ---
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        bytes calldata signature
    ) external;

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

interface IDelay {
    enum Operation {
        Call,
        DelegateCall
    }

    event DelaySetup(
        address indexed initiator,
        address indexed owner,
        address indexed avatar,
        address target
    );
    event TransactionAdded(
        uint256 indexed queueNonce,
        bytes32 indexed txHash,
        address to,
        uint256 value,
        bytes data,
        Operation operation
    );

    function txCooldown() external view returns (uint256);
    function txExpiration() external view returns (uint256);
    function txNonce() external view returns (uint256);
    function queueNonce() external view returns (uint256);
    function txHash(uint256 nonce) external view returns (bytes32);
    function txCreatedAt(uint256 nonce) external view returns (uint256);

    function setTxCooldown(uint256 cooldown) external;
    function setTxExpiration(uint256 expiration) external;
    function setTxNonce(uint256 nonce) external;

    function execTransactionFromModule(
        address to,
        uint256 value,
        bytes calldata data,
        Operation operation
    ) external returns (bool success);

    function executeNextTx(
        address to,
        uint256 value,
        bytes calldata data,
        Operation operation
    ) external;

    function skipExpired() external;
    function getTransactionHash(
        address to,
        uint256 value,
        bytes memory data,
        Operation operation
    ) external pure returns (bytes32);

    function getTxHash(uint256 nonce) external view returns (bytes32);
    function getTxCreatedAt(uint256 nonce) external view returns (uint256);
}

interface AggregatorInterface {
  function latestAnswer() external view returns (int256);

  function latestTimestamp() external view returns (uint256);

  function latestRound() external view returns (uint256);

  function getAnswer(uint256 roundId) external view returns (int256);

  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);

  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}

interface ISavingsDaiOracle is AggregatorInterface {
    function DAI_PRICE_FEED_ADDRESS() external view returns (address);
    function POT_ADDRESS() external view returns (address);
}

contract CroissantPay is Module {
    IDai public dai;
    ISavingsDai public savingsDai;
    IDelay public delay;
    ISavingsDaiOracle public savingsDaiOracle;

    function setUp(bytes memory initializeParams) public override {
        dai = IDai(address(0x73967c6a0904aA032C103b4104747E88c566B1A2));
        savingsDai = ISavingsDai(address(0xD8134205b0328F5676aaeFb3B2a0DC15f4029d8C));
        delay = IDelay(address(0xD62129BF40CD1694b3d9D9847367783a1A4d5cB4));
        savingsDaiOracle = ISavingsDaiOracle(address(0xdF53542ff2262166c5009ddE52D3abAc313d651c));
    }

    function schedulePayment(
        address to,
        uint256 amount,
        uint256 date
    ) external {
        // Approve the CroissantPay contract to spend the user's sDai
        savingsDai.approve(address(this), amount);

        uint256 depositAmount = calculateDepositAmount(amount, date);
        depositToSDai(depositAmount);
        delayPayment(to, depositAmount, date);
    }

    function calculateDepositAmount(
        uint256 amount,
        uint256 date
    ) internal view returns (uint256) {
        // Calculate the amount of DAI to deposit today using the Dai Savings Rate (DSR)
        uint256 dsr = uint256(savingsDaiOracle.latestAnswer());
        uint256 timeUntilDate = date - block.timestamp; // This is the time in seconds
        uint256 yearsUntilDate = timeUntilDate / (365 * 1 days); // Convert the time to years
        return amount / ((dsr / 1e27) ** yearsUntilDate);
    }

    function depositToSDai(uint256 amount) internal {
        // Call the SavingsDai contract to convert DAI to sDAI and deposit it
        savingsDai.deposit(amount, address(this));
    }

    function delayPayment(address to, uint256 amount, uint256 date) internal {
        // Schedule the payment using the Zodiac delay modifier

        // 1. Convert DAI to sDAI shares
        uint256 sDaiShares = savingsDai.convertToShares(amount);

        // 2. Redeem sDAI for DAI
        savingsDai.redeem(sDaiShares, address(this), address(this));

        // 3. Schedule the transfer
        bytes memory data = abi.encodeWithSignature(
            "transfer(address,uint256)",
            to,
            amount
        );

        delay.execTransactionFromModule(
            to,
            amount,
            data,
            IDelay.Operation.Call
        );
    }
}
