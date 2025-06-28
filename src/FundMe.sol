// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();
contract FundMe {
    using PriceConverter for uint256;
    uint256 public constant minUSD = 5e18;
    address[] public funders;
    mapping(address funders => uint256 amountfunded)
        public addresstoAmountFunded;

    address public immutable owner;
    constructor() {
        owner = msg.sender;
    }
    function fund() public payable {
        require(
            msg.value.getConversionRate() >= minUSD,
            "didnt spend enough ETH"
        );
        funders.push(msg.sender);
        addresstoAmountFunded[msg.sender] += msg.value;
    }
    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addresstoAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        // transfer
        //send
        //call(reccomended)
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwner();
        }
        _; // this is required to insert the body of the function using this modifier
    }
    receive() external payable {
        fund();
    }
    fallback() external payable {
        fund();
    }
}
