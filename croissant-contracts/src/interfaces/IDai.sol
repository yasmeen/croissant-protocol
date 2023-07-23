// SPDX-License-Identifier: AGPL-3.0-or-later

/// IDai.sol -- An interface for the Dai.sol

pragma solidity ^0.8.13;

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
