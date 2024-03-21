// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/Multisend.sol";
import "../script/DeployMultisend.s.sol";

contract DeployMultisendTest is Test {
    DeployMultisend private deployScript;
    Multisend private multisend;
    address private deployer;

    function setUp() public {
        vm.setEnv("PRIVATE_KEY", "0xa11ce");
        deployScript = new DeployMultisend();
        deployScript.run();
        deployer = deployScript.deployer();
        multisend = Multisend(deployScript.multisend());
    }

    function test_DeployedMultisend() public view {
        assertEq(address(multisend), deployScript.MULTISEND_ADDRESS());
    }
}