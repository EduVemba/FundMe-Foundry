// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe public fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 100 ether;
    uint256 constant GAS_PRICE = 1;


    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function setUp() public {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER, STARTING_BALANCE);
    }


   function test_fund() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE }();
        assertEq(address(fundMe).balance, SEND_VALUE);
    
    }


    function test_NotEnoughFunds() public {
        hoax(address(1), 10 ether);

        console.log("Revert happened");

        vm.expectRevert();
        fundMe.fund{value: 0.001 ether}();
    }

    function test_minimun_value() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
        console.log(fundMe.MINIMUM_USD());
    }
    

    function testFundFailWithoutEnoughEth() public {
        vm.expectRevert(); // The next line should revert
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.s_addressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testContratcBalanceAfterWitdraw() public {
        vm.prank(fundMe.i_owner());
        fundMe.cheaperWithdraw();
        assertEq(address(fundMe).balance, 0);
    } 

    function testOnlyOwnerCanWithdraw() public {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
        console.log("Only the address", fundMe.i_owner() , "can withdraw");
    }


    function testAddsFunderToArray() public funded {
        address funder = fundMe.s_funders(0);

        assertEq(funder, USER);
    }


    function testReceive() public {
        vm.prank(USER);
        (bool success, )  = address(fundMe).call{value: SEND_VALUE}("");
        assertTrue(success);
        console.log("Receive function is called");
    }

     function testFallback() public {
        vm.prank(USER);
        (bool success, )  = address(fundMe).call{value: SEND_VALUE}("0x1234");
        assertTrue(success);
        console.log("Fallback function is called");
    }

    function testWithDraeWithSingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        uint256 startingFunderBalance = address(fundMe).balance;
        // Act
        uint256 gasStart = gasleft(); // 1000
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 gasEnd = gasleft(); // 800
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log("Gas used: ", gasUsed);

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFunderBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function testWithDraeWithSingleFunderCheaper() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        uint256 startingFunderBalance = address(fundMe).balance;
        // Act
        uint256 gasStart = gasleft(); // 1000
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();

        uint256 gasEnd = gasleft(); // 800
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log("Gas used: ", gasUsed);

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFunderBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        // Act
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i),  STARTING_BALANCE );
            fundMe.fund{value: SEND_VALUE}();
        }
       

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(startingOwnerBalance + startingFundMeBalance == fundMe.getOwner().balance);
    }

}