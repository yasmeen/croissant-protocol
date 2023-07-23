// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.13;

import "@gnosis.pm/zodiac/contracts/core/Module.sol";
import {IDai} from "./interfaces/IDai.sol"; // Maker DAO DAI
import {ISavingsDai} from "./interfaces/ISavingsDai.sol"; // Maker DAO sDAI
import {IDelay} from "./interfaces/IDelay.sol"; // Gnosis Safe Zodiac's Delay modifier
import {ISavingsDaiOracle} from "./interfaces/ISavingsDaiOracle.sol"; // Maker DAO sDAI oracle for DSR

contract CroissantPay is Module {
    IDai public dai;
    ISavingsDai public savingsDai;
    IDelay public delay;
    ISavingsDaiOracle public savingsDaiOracle;

    function setUp() public override {
        dai = IDai(address(0x73967c6a0904aa032c103b4104747e88c566b1a2));
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
            Enum.Operation.Call
        );
    }
}
