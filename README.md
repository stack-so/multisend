# Multisend Contract

The Multisend contract is a Solidity smart contract designed to allow users to send ERC20 tokens to multiple addresses in a single transaction. It simplifies the process of distributing tokens to numerous recipients, offering both efficiency and convenience.

## Features

- **sendERC20**: Send ERC20 tokens to multiple addresses with varying amounts.
- **sendERC20Equal**: Distribute an equal amount of ERC20 tokens to multiple addresses.
- **RewardSent Event**: Emits a `RewardSent` event upon successful distribution of tokens.
- **ReentrancyGuard**: Incorporates ReentrancyGuard to mitigate reentrancy attacks.
- **Solmate Library**: Utilizes the [Solmate](https://github.com/transmissions11/solmate) library for safe ERC20 token transactions.

## Usage

### Sending ERC20 Tokens with Different Amounts

To distribute ERC20 tokens to various addresses with differing amounts, utilize the `sendERC20` function as follows:

- `tokenAddress`: The ERC20 token's address to send.
- `_addresses`: An array of recipient addresses.
- `_amounts`: An array detailing the amounts to send to each recipient. The lengths of `_addresses` and `_amounts` must align.
- `_totalAmount`: The total tokens to send. This should be pre-calculated off-chain.

#### Example

```solidity
address tokenAddress = 0x1234...;
address[] memory recipients = [0xabc..., 0xdef..., 0xghi...];
uint256[] memory amounts = [100, 200, 300];
uint256 totalAmount = 600;

multisend.sendERC20(tokenAddress, recipients, amounts, totalAmount);
```

### Sending Equal Amounts of ERC20 Tokens
For distributing an equal amount of ERC20 tokens across multiple addresses, use the sendERC20Equal function with:

- `tokenAddress`: The ERC20 token's address.
- `_addresses`: An array of recipient addresses.
- `_amount`: The amount of tokens each recipient will receive.

#### Example

```solidity
address tokenAddress = 0x1234...;
address[] memory recipients = [0xabc..., 0xdef..., 0xghi...];
uint256 amount = 100;

multisend.sendERC20Equal(tokenAddress, recipients, amount);
```

## Testing
The Multisend contract includes a thorough test suite developed in Solidity using the Foundry framework. This suite tests various scenarios to verify the contract's reliability.

### Running Tests
Installation: First, install Foundry by following the Foundry Installation guide.
Preparation: Clone the repository and navigate to the project's directory.
Execution: Execute the tests with forge test. This compiles the contracts and runs the test suite, outputting results in the console.
Contributing
Contributions to the Multisend contract are encouraged! For bugs or feature suggestions, please open an issue or submit a pull request on GitHub.

## License
The Multisend contract is made available under the MIT License.

## Authors
Developed at [Stack Technologies, Inc.](https://www.stack.so), with contributions from @diff99 and @strangechances.
