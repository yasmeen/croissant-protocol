// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.13;

import {AggregatorInterface} from "./AggregatorInterface.sol";

interface ISavingsDaiOracle is AggregatorInterface {
    function DAI_PRICE_FEED_ADDRESS() external view returns (address);
    function POT_ADDRESS() external view returns (address);
}
