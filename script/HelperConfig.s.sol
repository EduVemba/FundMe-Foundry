// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

// 1. Deploy mocks when we are on the local anvil chain
// 2. keep track of contract address across different chains.
// Sepolia ETH/USD : {0x694AA1769357215DE4FAC081bf1f309aDC325306}
// Mainnet ETH/USD : {0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419}
// anvil ETH/USD : {0x8A753747A1Fa494EC906cE90E9f37563A8AF630e}

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";

import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    NetworkConfig public activeNetwork;

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetwork = getSepoliatEthConfig();
        } 
         else if (block.chainid == 1) {
            activeNetwork =  getMainnetConfig();
        }
        else {
           activeNetwork = getAnvilConfig();
        }
    }

    function getMainnetConfig() public returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        return sepoliaConfig;
    }


    
    function getSepoliatEthConfig() public returns (NetworkConfig memory) {
        // price feed address 
         NetworkConfig memory sepoliaConfig = NetworkConfig(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return sepoliaConfig;
    }


    function getAnvilConfig() public returns (NetworkConfig memory) {
        if (activeNetwork.priceFeed != address(0)) {
            return activeNetwork;
        }

        // price feed address
        // vrf adress 
        // gas cost
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed : address(mockPriceFeed)}); 
        return anvilConfig;
    }
}