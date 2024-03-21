// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/Multisend.sol";

contract DeployMultisend is Script {
    // The expected address of the deployed Multisend contract.
    address public constant MULTISEND_ADDRESS = 0x481185517386d925E1E3Be12ff490f6d3c204915;
    // The salt for the Multisend contract.
    bytes32 private constant SALT = 0x5552736d6b76f4a5e8bc99cf20a26c02322bac6d9929800a427a31e9b31ca96d;
    // The expected init code hash of the Multisend contract.
    bytes32 private constant EXPECTED_CODE_HASH = 0xc642c602d6b339b144150e163f7ea0c6db4dc8c856d1258655a7604a00f71634;
    Multisend public multisend; // The deployed Multisend contract.
    address public deployer; // The address that deployed the Multisend contract.

    /**
    * @dev Asserts that the init code hash of the Multisend contract matches the expected value.
    */
    function assertCodeHash() internal pure {
        bytes32 initCodeHash = keccak256(type(Multisend).creationCode);
        require(initCodeHash == EXPECTED_CODE_HASH, "Unexpected init code hash");
    }

    function assertMultisendAddress() public view {
        require(address(multisend) == MULTISEND_ADDRESS, "Deployed address does not match expected address");
    }

    function run() external {
        assertCodeHash(); // Assert that the init code hash of the Multisend contract matches the expected value.
        uint256 key = vm.envUint("PRIVATE_KEY"); // Get the private key from the environment.
        deployer = vm.addr(key); // Get the address of the private key.
        vm.startBroadcast(key); // Start the broadcast with the private key.
        multisend = new Multisend{salt: SALT}(); // Deploy the Multisend contract with the specified salt.
        assertMultisendAddress(); // Assert that the address of the deployed Multisend contract matches the expected address.
        vm.stopBroadcast(); // Stop the broadcast.
    }
}