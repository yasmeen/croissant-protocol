// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.13;

import "ds-test/test.sol";
import "../src/CroissantPay.sol";

contract CroissantPayTest is DSTest {
    CroissantPay croissant;
    SavingsDai savingsDai;
    Delay delay;
    SavingsDaiOracle savingsDaiOracle;

    function beforeEach() public {
        // Replace these addresses with the actual deployed contract addresses on Goerli
        address savingsDaiAddress = 0xD8134205b0328F5676aaeFb3B2a0DC15f4029d8C;
        address delayAddress = 0xD62129BF40CD1694b3d9D9847367783a1A4d5cB4;
        address savingsDaiOracleAddress = 0xdF53542ff2262166c5009ddE52D3abAc313d651c;

        savingsDai = SavingsDai(savingsDaiAddress);
        delay = Delay(delayAddress);
        savingsDaiOracle = SavingsDaiOracle(savingsDaiOracleAddress);
        croissant = new CroissantPay(savingsDai, delay, savingsDaiOracle);

        bytes memory initializeParams = abi.encode(savingsDai, delay, savingsDaiOracle);
        croissant.setUp(initializeParams);
    }

    function testSetUp() public {
        Assert.equal(address(croissant.savingsDai()), address(savingsDai), "SavingsDai address should be set correctly");
        Assert.equal(address(croissant.delay()), address(delay), "Delay address should be set correctly");
        Assert.equal(address(croissant.savingsDaiOracle()), address(savingsDaiOracle), "SavingsDaiOracle address should be set correctly");
    }

    function test_schedulePayment() public {
        address recipient = 0x751f1308A2070D32B7E89A37e2Ed84643e7DE6d5;
        uint256 initialBalance = savingsDai.balanceOf(recipient);
        uint256 amount = 100; // Replace this with the actual amount
        uint256 date = block.timestamp + 7 days; // One week from now

        croissant.schedulePayment(recipient, amount, date);

        // Since the payment is delayed, the balance should not increase immediately
        assertEq(savingsDai.balanceOf(recipient), initialBalance);
        
        // Add a check after the delay has passed to ensure that the balance has increased
        // This will depend on your testing framework and how it handles time manipulation
    }
}
