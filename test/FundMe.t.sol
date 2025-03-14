// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe public fundMe;

    function setUp() public {
        fundMe = new FundMe(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
    }

/*
    function test_fund() public {
         console.log("Funded");

        hoax(address(1), 10 ether);
        fundMe.fund{value: 1 ether }();
        assertEq(fundMe.s_funders(0), address(1));
    
    }
*/


    function test_NotEnoughFunds() public {
        hoax(address(1), 10 ether);

        console.log("Revert happened");

        vm.expectRevert();
        fundMe.fund{value: 0.001 ether}();
    }

    function test_isOwner() public {
        assertEq(fundMe.i_owner(), address(this));
        console.log(fundMe.i_owner());
    }

    function test_minimun_value() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
        console.log(fundMe.MINIMUM_USD());
    }
    
    
    

}