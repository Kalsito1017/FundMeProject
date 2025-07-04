// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract HelperConfig {
    struct NetworkConfig {
        address priceFeedAddress;
    }

    NetworkConfig public activeNetworkConfig; // <-- this must be public

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 31337) {
            activeNetworkConfig = getAnvilConfig();
        } else {
            activeNetworkConfig = getSepoliaEthConfig(); // fallback
        }
    }

    function getSepoliaEthConfig()
        internal
        pure
        returns (NetworkConfig memory)
    {
        return
            NetworkConfig({
                priceFeedAddress: 0x694AA1769357215DE4FAC081bf1f309aDC325306
            });
    }

    function getAnvilConfig() internal pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                priceFeedAddress: 0x694AA1769357215DE4FAC081bf1f309aDC325306
            });
    }
    function getActiveNetworkConfig()
        external
        view
        returns (NetworkConfig memory)
    {
        return activeNetworkConfig;
    }
}
