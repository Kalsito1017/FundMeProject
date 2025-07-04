// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Update the import path below if you have installed chainlink contracts via npm/yarn or foundry
import {AggregatorV3Interface} from "chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract MockV3Aggregator is AggregatorV3Interface {
    int256 private answer;
    uint8 public override decimals;

    constructor(uint8 _decimals, int256 _initialAnswer) {
        decimals = _decimals;
        answer = _initialAnswer;
    }

    function latestRoundData()
        external
        view
        override
        returns (uint80, int256, uint256, uint256, uint80)
    {
        return (0, answer, 0, 0, 0);
    }

    function description() external pure override returns (string memory) {
        return "MockV3Aggregator";
    }

    function version() external pure override returns (uint256) {
        return 1;
    }

    function getAnswer() external view returns (int256) {
        return answer;
    }

    function setAnswer(int256 _answer) external {
        answer = _answer;
    }

    // Implement missing functions from AggregatorV3Interface
    function getRoundData(
        uint80 _roundId
    )
        external
        view
        override
        returns (uint80, int256, uint256, uint256, uint80)
    {
        return (_roundId, answer, 0, 0, 0);
    }
}
