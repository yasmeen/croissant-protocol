// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.13;

import "@gnosis.pm/zodiac/contracts/core/Modifier.sol";
import "zodiac/Delay.sol";

contract MockDelay {
    Delay public delay;

    constructor(address _delay) {
        delay = Delay(_delay);
    }

    // These variables will store the parameters of the last call to `execTransactionFromModule`
    address public lastTo;
    uint256 public lastValue;
    bytes public lastData;
    Enum.Operation public lastOperation;
    
    function execTransactionFromModule(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation
    ) public returns (bool success) {
        // Instead of actually executing the transaction, we just record the parameters
        lastTo = to;
        lastValue = value;
        lastData = data;
        lastOperation = operation;

        return true;
    }
}
