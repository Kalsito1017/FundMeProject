// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {MockV3Aggregator} from "test/mocks/MockV3Aggregator.t.sol";
import {console} from "lib/forge-std/src/console.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    MockV3Aggregator public mockV3Aggregator;
    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 10 ether; // 5 ETH in wei
    uint256 constant SEND_VALUE = 10 ether; // Instead of 0.1 ether
    uint256 constant GAS_PRICE = 1 gwei; // Set gas price to 1 gwei for testing
    receive() external payable {}
    function setUp() external {
        // Deploy the mock price feed contract with 8 decimals and initial answer of 2000e8
        mockV3Aggregator = new MockV3Aggregator(8, 2000e8);
        fundMe = new FundMe(address(mockV3Aggregator)); // ✅ Pass its address
        vm.deal(USER, STARTING_BALANCE); // Give the funder some ETH
    }
    function testFundFailsWithoutEnoughEth() public {
        // Attempt to fund with 0 ETH, should revert
        vm.expectRevert();
        fundMe.fund();
    }
    function TestFundedUpdateDataStructure() public {
        // Act
        vm.prank(USER); // Simulate the funder calling the function
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }
    function testAddsfUNDERToFundersArray() public {
        // Arrange
        vm.prank(USER); // Simulate the funder calling the function
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }
    function testOnlyOwnerCanWithdraw() public {
        // Arrange
        vm.prank(USER); // Simulate a user trying to withdraw
        vm.expectRevert(); // Expect revert with NotOwner error
        fundMe.withdraw();
    }
    function testWithDrawWithASingleFunder() public {
        // Arrange
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}(); // Fund the contract

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner()); // Simulate the owner calling withdraw
        fundMe.withdraw();
        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
    }
    function testWithDrawWithMultipleFundersCheaper() public {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1; // Each funder sends 1 ETH
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE); // Simulate each funder
            fundMe.fund{value: SEND_VALUE}(); // Each funder funds the contract
        }
        // The owner is the deployer of the contract
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        vm.startPrank(fundMe.getOwner()); // Start a prank as the owner
        fundMe.cheaperWithdraw(); // Withdraw again to ensure the funders' balances are reset
        vm.stopPrank(); // Stop the prank

        // Assert
        assert(address(fundMe).balance == 0);
        assert(
            startingOwnerBalance + startingFundMeBalance ==
                fundMe.getOwner().balance
        );
    }
    function testWithDrawWithMultipleFunders() public {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1; // Each funder sends 1 ETH
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE); // Simulate each funder
            fundMe.fund{value: SEND_VALUE}(); // Each funder funds the contract
        }
        // The owner is the deployer of the contract
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        vm.startPrank(fundMe.getOwner()); // Start a prank as the owner
        fundMe.withdraw(); // Withdraw again to ensure the funders' balances are reset
        vm.stopPrank(); // Stop the prank

        // Assert
        assert(address(fundMe).balance == 0);
        assert(
            startingOwnerBalance + startingFundMeBalance ==
                fundMe.getOwner().balance
        );
    }
}
