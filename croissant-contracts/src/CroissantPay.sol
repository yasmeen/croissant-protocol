// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.13;

import "@gnosis.pm/zodiac/contracts/core/Module.sol";
import "zodiac/Delay.sol"; // Gnosis Safe Zodiac's Delay modifier
import {SavingsDai} from "maker-dao/SavingsDai.sol"; // Maker DAO sDAI contract
import {SavingsDaiOracle} from "maker-dao/SavingsDaiOracle.sol"; // sDAI oracle for DSR

contract CroissantPay is Module {
    SavingsDai public savingsDai;
    Delay public delay;
    SavingsDaiOracle public savingsDaiOracle;

    function setUp(bytes memory initializeParams) public override {
        (address _savingsDai, address _delay, address _savingsDaiOracle) =
        abi.decode(initializeParams, (address, address, address));

        savingsDai = SavingsDai(_savingsDai);
        delay = Delay(_delay);
        savingsDaiOracle = SavingsDaiOracle(_savingsDaiOracle);
    }

    function schedulePayment(address to, uint256 amount, uint256 date) external {
        uint256 depositAmount = calculateDepositAmount(amount, date);
        depositToSDai(depositAmount);
        delayPayment(to, depositAmount, date);
    }

    function calculateDepositAmount(uint256 amount, uint256 date) internal view returns (uint256) {
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
      address goerliDai = 0x73967c6a0904aA032C103b4104747E88c566B1A2;
      bytes memory data = abi.encodeWithSignature("transfer(address,uint256)", to, amount);
      delay.execTransactionFromModule(goerliDai, 0, data, Enum.Operation.Call);
    }
}
