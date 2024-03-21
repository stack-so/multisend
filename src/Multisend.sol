// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "solmate/tokens/ERC20.sol";
import "solmate/utils/ReentrancyGuard.sol";
import "solmate/utils/SafeTransferLib.sol";

/**
 * @title Multisend
 * @author diff99
 * @author strangechances
 * @notice A contract for sending ERC20 tokens to multiple addresses in a single transaction.
 */
contract Multisend is ReentrancyGuard {
    /**
     * @notice Emitted when rewards are sent to multiple recipients.
     * @param tokenAddress The address of the ERC20 token being sent.
     * @param totalAmount The total amount of tokens sent.
     * @param recipientCount The number of recipients.
     * @param issuer The address of the issuer initiating the reward distribution.
     */
    event RewardSent(address indexed tokenAddress, uint256 totalAmount, uint256 recipientCount, address indexed issuer);

    /**
     * @notice Sends ERC20 tokens to multiple addresses with different amounts.
     * @param tokenAddress The address of the ERC20 token to be sent.
     * @param _addresses An array of recipient addresses.
     * @param _amounts An array of amounts to be sent to each recipient.
     * @param _totalAmount The total amount of tokens to be sent.
     */
    function sendERC20(address tokenAddress, address[] calldata _addresses, uint256[] calldata _amounts, uint256 _totalAmount) external nonReentrant {
        require(_addresses.length == _amounts.length, "Address and amount array lengths must match");

        SafeTransferLib.safeTransferFrom(ERC20(tokenAddress), msg.sender, address(this), _totalAmount);

        for (uint256 i = 0; i < _addresses.length; i++) {
            SafeTransferLib.safeTransfer(ERC20(tokenAddress), _addresses[i], _amounts[i]);
        }

        emit RewardSent(tokenAddress, _totalAmount, _addresses.length, msg.sender);
    }

    /**
     * @notice Sends an equal amount of ERC20 tokens to multiple addresses.
     * @param tokenAddress The address of the ERC20 token to be sent.
     * @param _addresses An array of recipient addresses.
     * @param _amount The amount of tokens to be sent to each recipient.
     */
    function sendERC20Equal(address tokenAddress, address[] calldata _addresses, uint256 _amount) external nonReentrant {
        SafeTransferLib.safeTransferFrom(ERC20(tokenAddress), msg.sender, address(this), _addresses.length * _amount);

        for (uint256 i = 0; i < _addresses.length; i++) {
            SafeTransferLib.safeTransfer(ERC20(tokenAddress), _addresses[i], _amount);
        }

        emit RewardSent(tokenAddress, _addresses.length * _amount, _addresses.length, msg.sender);
    }
}