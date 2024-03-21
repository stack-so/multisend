// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/Multisend.sol";

contract MockToken is ERC20 {
    constructor(string memory name, string memory symbol, uint8 decimals) ERC20(name, symbol, decimals) {
        _mint(msg.sender, 50000000 * 10 ** decimals);
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract MultisendTest is Test {
    Multisend public multisend;
    MockToken public mockToken;
    address public issuer = address(1);
    address public claimer = address(2);

    function setUp() public {
        multisend = new Multisend();
        mockToken = new MockToken("Mock Token", "MT", 18);
    }

    function testSendErc20() public {
        uint256 totalClaimable = 5000;
        mockToken.mint(issuer, totalClaimable);
        vm.prank(issuer);
        mockToken.approve(address(multisend), totalClaimable);

        address mockTokenAddress = address(mockToken);
        address[] memory claimers = new address[](4);
        claimers[0] = claimer;
        claimers[1] = address(3);
        claimers[2] = address(4);
        claimers[3] = address(5);

        uint256[] memory amounts = new uint256[](4);
        amounts[0] = 5;
        amounts[1] = 995;
        amounts[2] = 2000;
        amounts[3] = 2000;

        vm.prank(issuer);
        multisend.sendERC20(mockTokenAddress, claimers, amounts, totalClaimable);

        assertEq(mockToken.balanceOf(claimer), 5);
        assertEq(mockToken.balanceOf(address(3)), 995);
        assertEq(mockToken.balanceOf(address(4)), 2000);
        assertEq(mockToken.balanceOf(address(5)), 2000);
    }

    function testFuzzSendErc20(uint256[] memory amounts) public {
        address[] memory claimers = new address[](amounts.length);
        for (uint256 i = 0; i < amounts.length; i++) {
            claimers[i] = vm.addr(i + 1);
        }

        uint256 totalClaimable = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            vm.assume(amounts[i] < 50000000);
            totalClaimable += amounts[i];
        }

        mockToken.mint(issuer, totalClaimable);
        vm.prank(issuer);
        mockToken.approve(address(multisend), totalClaimable);

        address mockTokenAddress = address(mockToken);
        vm.prank(issuer);
        multisend.sendERC20(mockTokenAddress, claimers, amounts, totalClaimable);

        for (uint256 i = 0; i < claimers.length; i++) {
            assertEq(mockToken.balanceOf(claimers[i]), amounts[i]);
        }
    }

    function testSendErc20Equal() public {
        uint256 totalClaimable = 5000;
        uint256 equalAmount = 1000;
        mockToken.mint(issuer, totalClaimable);
        vm.prank(issuer);
        mockToken.approve(address(multisend), totalClaimable);

        address mockTokenAddress = address(mockToken);
        address[] memory claimers = new address[](5);
        claimers[0] = claimer;
        claimers[1] = address(3);
        claimers[2] = address(4);
        claimers[3] = address(5);
        claimers[4] = address(6);

        vm.prank(issuer);
        multisend.sendERC20Equal(mockTokenAddress, claimers, equalAmount);

        for (uint256 i = 0; i < claimers.length; i++) {
            assertEq(mockToken.balanceOf(claimers[i]), equalAmount);
        }
    }

    function testFuzzSendErc20Equal(uint256 equalAmount) public {
        address[] memory claimers = new address[](5);
        claimers[0] = claimer;
        claimers[1] = address(3);
        claimers[2] = address(4);
        claimers[3] = address(5);
        claimers[4] = address(6);

        uint256 maxClaimable = type(uint256).max / 5;
        vm.assume(maxClaimable >= equalAmount);

        uint256 totalClaimable = equalAmount * claimers.length;
        mockToken.mint(issuer, totalClaimable);
        vm.prank(issuer);
        mockToken.approve(address(multisend), totalClaimable);

        address mockTokenAddress = address(mockToken);
        vm.prank(issuer);
        multisend.sendERC20Equal(mockTokenAddress, claimers, equalAmount);

        for (uint256 i = 0; i < claimers.length; i++) {
            assertEq(mockToken.balanceOf(claimers[i]), equalAmount);
        }
    }

    function testCannotSendWithInsufficientBalance() public {
        uint256 totalClaimable = 5000;
        mockToken.mint(issuer, totalClaimable - 1);
        vm.prank(issuer);
        mockToken.approve(address(multisend), totalClaimable);

        address mockTokenAddress = address(mockToken);
        address[] memory claimers = new address[](1);
        claimers[0] = claimer;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = totalClaimable;

        vm.prank(issuer);
        vm.expectRevert("TRANSFER_FROM_FAILED");
        multisend.sendERC20(mockTokenAddress, claimers, amounts, totalClaimable);
    }

    function testCannotSendWithMismatchedArrayLengths() public {
        uint256 totalClaimable = 5000;
        mockToken.mint(issuer, totalClaimable);
        vm.prank(issuer);
        mockToken.approve(address(multisend), totalClaimable);

        address mockTokenAddress = address(mockToken);
        address[] memory claimers = new address[](2);
        claimers[0] = claimer;
        claimers[1] = address(3);

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = totalClaimable;

        vm.prank(issuer);
        vm.expectRevert("Address and amount array lengths must match");
        multisend.sendERC20(mockTokenAddress, claimers, amounts, totalClaimable);
    }

    function test_SendErc20_revert() public {
        uint256 totalClaimable = 1000;
        mockToken.mint(issuer, totalClaimable);
        vm.prank(issuer);
        mockToken.approve(address(multisend), totalClaimable);
        vm.prank(issuer);

        address mockTokenAddress = address(mockToken);

        address[] memory claimers = new address[](2);
        claimers[0] = claimer;
        claimers[1] = address(3);

        // amounts are greater than balance
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 1000;
        amounts[1] = 995;

        vm.expectRevert();
        multisend.sendERC20(mockTokenAddress, claimers, amounts, totalClaimable);
        assertEq(mockToken.balanceOf(address(claimer)), 0);
        assertEq(mockToken.balanceOf(address(3)), 0);
    }

    function test_SendErc20Equal() public {
        uint256 totalClaimable = 1000;
        mockToken.mint(issuer, totalClaimable);
        vm.prank(issuer);
        mockToken.approve(address(multisend), totalClaimable);
        vm.prank(issuer);

        address mockTokenAddress = address(mockToken);

        address[] memory claimers = new address[](100);
        for (uint160 i = 0; i < 100; i++) {
            claimers[i] = address(i);
        }

        uint256[] memory amounts = new uint256[](100);
        for (uint256 i = 0; i < 100; i++) {
            amounts[i] = 10;
        }

        multisend.sendERC20(mockTokenAddress, claimers, amounts, totalClaimable);
        for (uint160 i = 0; i < 100; i++) {
            assertEq(mockToken.balanceOf(address(i)), 10);
        }

        // amounts are greater than balance, expect revert
        uint256[] memory amounts2 = new uint256[](100);
        for (uint256 i = 0; i < 100; i++) {
            amounts2[i] = 11;
        }

        vm.expectRevert();
        multisend.sendERC20(mockTokenAddress, claimers, amounts2, totalClaimable);
    }
}