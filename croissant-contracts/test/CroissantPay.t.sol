// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.13;

import {Test} from "../lib/forge-std/src/Test.sol";
import {console2 as console} from "../lib/forge-std/src/console2.sol";
import "../src/CroissantPay.sol";
import "../src/MockDai.sol";
import "../src/MockSavingsDai.sol";
import "../src/MockSavingsDaiOracle.sol";
import "../src/MockDelay.sol";

contract CroissantPayTest is Test {
    CroissantPay croissant;
    MockDai dai;
    MockSavingsDai savingsDai;
    MockDelay delay;
    MockSavingsDaiOracle savingsDaiOracle;

    function setUp() private {
        // address daiAddress = 0x73967c6a0904aa032c103b4104747e88c566b1a2
        address savingsDaiAddress = 0xD8134205b0328F5676aaeFb3B2a0DC15f4029d8C;
        address delayAddress = 0xD62129BF40CD1694b3d9D9847367783a1A4d5cB4;
        // address savingsDaiOracleAddress = 0xdF53542ff2262166c5009ddE52D3abAc313d651c;

        // create mock dai and mint 10000
        dai = new MockDai();
        dai.mint(address(this), 10000);

        savingsDai = new MockSavingsDai(savingsDaiAddress);

        uint256 mockDsr = 2 * 10 ** 27;
        savingsDaiOracle = new MockSavingsDaiOracle(mockDsr);
        croissant = new CroissantPay();

        // Create new MockDelay
        delay = new MockDelay(delayAddress);

        bytes memory initializeParams = abi.encode(
            dai,
            savingsDai,
            delay,
            savingsDaiOracle
        );
        croissant.setUp(initializeParams);
    }

    function test_schedulePayment() public {
        setUp();

        uint256 amount = 100;
        // savingsDai.deposit(amount, address(this));
        // assertEq(savingsDai.balanceOf(address(this)), amount);

        address recipient = 0x751f1308A2070D32B7E89A37e2Ed84643e7DE6d5;
        dai.mint(recipient, amount);

        uint256 initialDaiBalance = dai.balanceOf(recipient);
        uint256 initialSDaiBalance = savingsDai.balanceOf(recipient);

        uint256 date = block.timestamp + 7 days; // One week from now

        // Schedule actual payment
        croissant.schedulePayment(recipient, amount, date);

        // Since the payment is delayed, the balance should not increase immediately
        assertEq(savingsDai.balanceOf(recipient), initialSDaiBalance);

        // TODO Add a check after the delay has passed to ensure that the balance has increased
    }
}
