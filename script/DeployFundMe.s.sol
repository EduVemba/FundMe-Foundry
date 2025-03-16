// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    FundMe public fundMe;
   

    function setUp() public {}

    function run() public  returns (FundMe) {
        // Before startBroadcast -> Not a "real" tx
        HelperConfig helperConfig = new HelperConfig();

        address EthUsdpriceFeed = helperConfig.activeNetwork();

        // After startBroadcast -> Real tx
        vm.startBroadcast();
        fundMe = new FundMe(EthUsdpriceFeed);
        vm.stopBroadcast();

        return fundMe;
    }
}

