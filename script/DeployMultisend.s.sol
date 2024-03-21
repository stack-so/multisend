// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/Multisend.sol";

contract DeployMultisend is Script {
    // The expected address of the deployed Multisend contract.
    address public constant MULTISEND_ADDRESS = 0x00000000a58CDd07F6434960b0127405cfC384be;
    // The salt for the Multisend contract.
    bytes32 private constant SALT = 0x4b8edb66695026f0ae2cf7164ad22d2edc2a64955dc628bb00bf37facd71a228;
    // The expected init code hash of the Multisend contract.
    bytes32 private constant EXPECTED_CODE_HASH = 0x2fa81e896b138adb5a92b1eef5c8b39d8232a42efb34bbdc1e0806c5dce77e07;
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