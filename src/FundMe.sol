// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {AggregatorV3Interface} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();
contract FundMe {
    using PriceConverter for uint256;
    uint256 public constant MIN_USD = 5e18;
    address[] public s_funders;
    mapping(address => uint256) public s_addresstoAmountFunded;

    address public immutable i_owner;
    AggregatorV3Interface public s_priceFeed;
    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }
    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MIN_USD,
            "You need to spend more ETH!"
        );

        s_addresstoAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }
    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }
    function getPriceFeed() external view returns (address) {
        return address(s_priceFeed);
    }
    function cheaperWithdraw() public onlyOwner {
        uint256 fundersCount = s_funders.length;
        for (
            uint256 funderIndex = 0;
            funderIndex < fundersCount;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addresstoAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }
    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addresstoAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        // transfer
        //send
        //call(reccomended)
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }
    modifier onlyOwner() {
        if (msg.sender != i_owner) {
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
    function getAddressToAmountFunded(
        address funder
    ) external view returns (uint256) {
        return s_addresstoAmountFunded[funder];
    }
    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }
    function getOwner() external view returns (address) {
        return i_owner;
    }
}
