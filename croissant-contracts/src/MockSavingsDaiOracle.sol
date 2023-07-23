// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.13;

contract MockSavingsDaiOracle {
    uint256 public dsr;

    constructor(uint256 _dsr) {
        dsr = _dsr;
    }

    function latestAnswer() external view returns (int256) {
        // Convert the DSR to an int256 before returning it
        return int256(dsr);
    }

    // Implement other functions from the SavingsDaiOracle interface as needed...
}
