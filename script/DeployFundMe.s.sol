// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "lib/forge-std/src/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();

        // ✅ Get config struct from getter
        HelperConfig.NetworkConfig memory config = helperConfig
            .getActiveNetworkConfig();
        address priceFeedAddress = config.priceFeedAddress;

        vm.startBroadcast();
        FundMe fundMe = new FundMe(priceFeedAddress);
        vm.stopBroadcast();

        return fundMe;
    }
}
