// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.13;

import "ds-test/test.sol";
import "../src/Croissant.sol";

contract CroissantTest is DSTest {
    Croissant croissant;
    SavingsDai savingsDai;
    Delay delay;
    SavingsDaiOracle savingsDaiOracle;

    function beforeEach() public {
        // Replace these addresses with the actual deployed contract addresses on Goerli
        address savingsDaiAddress = 0x0000000000000000000000000000000000000000;
        address delayAddress = 0x0000000000000000000000000000000000000000;
        address savingsDaiOracleAddress = 0x0000000000000000000000000000000000000000;

        savingsDai = SavingsDai(savingsDaiAddress);
        delay = Delay(delayAddress);
        savingsDaiOracle = SavingsDaiOracle(savingsDaiOracleAddress);
        croissant = new Croissant(savingsDai, delay, savingsDaiOracle);

        bytes memory initializeParams = abi.encode(savingsDai, delay, savingsDaiOracle);
        croissant.setUp(initializeParams);
    }

    function testSetUp() public {
        Assert.equal(address(croissant.savingsDai()), address(savingsDai), "SavingsDai address should be set correctly");
        Assert.equal(address(croissant.delay()), address(delay), "Delay address should be set correctly");
        Assert.equal(address(croissant.savingsDaiOracle()), address(savingsDaiOracle), "SavingsDaiOracle address should be set correctly");
    }

    function test_schedulePayment() public {
        address recipient = 0x0000000000000000000000000000000000000000;
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
