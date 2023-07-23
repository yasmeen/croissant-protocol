// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.13;

import {SavingsDai} from "maker-dao/SavingsDai.sol"; // Maker DAO sDAI contract

interface MockPotLike {
    function chi() external view returns (uint256);
    function rho() external view returns (uint256);
    function dsr() external view returns (uint256);
    function drip() external returns (uint256);
    function join(uint256) external;
    function exit(uint256) external;
}

contract MockSavingsDai {
    SavingsDai public savingsDai;

    constructor(address _savingsDai) {
        pot = MockPotLike(0xD8134205b0328F5676aaeFb3B2a0DC15f4029d8C);
        savingsDai = SavingsDai(_savingsDai);
    }
    
    // --- ERC20 Data ---
    string  public constant name     = "Savings Dai";
    string  public constant symbol   = "sDAI";
    string  public constant version  = "1";
    uint8   public constant decimals = 18;
    uint256 public totalSupply;

    mapping (address => uint256)                      public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => uint256)                      public nonces;

    // --- Data ---
    MockPotLike     public immutable pot;

    uint256 private constant RAY = 10 ** 27;

    // These variables will store the parameters of the last call to `deposit` and `withdraw`
    uint256 public lastDepositAssets;
    address public lastDepositReceiver;
    
    uint256 public lastWithdrawAssets;
    address public lastWithdrawReceiver;
    address public lastWithdrawOwner;

    function deposit(uint256 assets, address receiver) public returns (uint256 shares) {
        // Instead of actually executing the deposit, we just record the parameters
        lastDepositAssets = assets;
        lastDepositReceiver = receiver;

        // Mock implementation: update the balance and return assets as shares
        balanceOf[receiver] += assets;

        return assets; // Mock implementation: return assets as shares
    }

    function withdraw(uint256 assets, address receiver, address owner) public returns (uint256 shares) {
        // Instead of actually executing the withdraw, we just record the parameters
        lastWithdrawAssets = assets;
        lastWithdrawReceiver = receiver;
        lastWithdrawOwner = owner;

        return assets; // Mock implementation: return assets as shares
    }

    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;

        return true;
    }

    function _rpow(uint256 x, uint256 n) internal pure returns (uint256 z) {
        assembly {
            switch x case 0 {switch n case 0 {z := RAY} default {z := 0}}
            default {
                switch mod(n, 2) case 0 { z := RAY } default { z := x }
                let half := div(RAY, 2)  // for rounding.
                for { n := div(n, 2) } n { n := div(n,2) } {
                    let xx := mul(x, x)
                    if iszero(eq(div(xx, x), x)) { revert(0,0) }
                    let xxRound := add(xx, half)
                    if lt(xxRound, xx) { revert(0,0) }
                    x := div(xxRound, RAY)
                    if mod(n,2) {
                        let zx := mul(z, x)
                        if and(iszero(iszero(x)), iszero(eq(div(zx, x), z))) { revert(0,0) }
                        let zxRound := add(zx, half)
                        if lt(zxRound, zx) { revert(0,0) }
                        z := div(zxRound, RAY)
                    }
                }
            }
        }
    }

    function convertToShares(uint256 assets) public view returns (uint256) {
        return assets;
    }

    function _burn(uint256 assets, uint256 shares, address receiver, address owner) internal {
        uint256 balance = balanceOf[owner];
        require(balance >= shares, "SavingsDai/insufficient-balance");

        if (owner != msg.sender) {
            uint256 allowed = allowance[owner][msg.sender];
            if (allowed != type(uint256).max) {
                require(allowed >= shares, "SavingsDai/insufficient-allowance");

                unchecked {
                    allowance[owner][msg.sender] = allowed - shares;
                }
            }
        }

        unchecked {
            balanceOf[owner] = balance - shares; // note: we don't need overflow checks b/c require(balance >= value) and balance <= totalSupply
            totalSupply      = totalSupply - shares;
        }
    }

    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets) {
        _burn(assets, shares, receiver, owner);
    }
}
