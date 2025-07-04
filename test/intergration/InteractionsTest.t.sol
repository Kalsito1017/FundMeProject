// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {Test} from "lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether; // Instead of 0.1 ether
    uint256 constant STARTING_BALANCE = 10 ether; // 5 ETH in wei
    uint256 constant GAS_PRICE = 1;
    function setUp() external {
        DeployFundMe deployer = new DeployFundMe();
        fundMe = deployer.run();
        vm.deal(USER, STARTING_BALANCE); // Give this contract
    }
    function testUserCanFundInteractions() public {
        FundFundMe fundFundme = new FundFundMe();

        // Give USER ETH
        vm.deal(USER, STARTING_BALANCE);

        // USER calls fundFundMe and sends ETH
        vm.prank(USER);
        fundFundme.fundFundMe{value: SEND_VALUE};

        // OWNER withdraws
        address owner = fundMe.getOwner();
        vm.prank(owner);
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        // Check funds withdrawn
        assertEq(address(fundMe).balance, 0);
    }
}
