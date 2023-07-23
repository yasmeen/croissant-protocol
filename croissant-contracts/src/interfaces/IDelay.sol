// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.13;

enum Operation {
    Call,
    DelegateCall
}

interface IDelay {
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
