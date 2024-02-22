// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract OurToken is ERC20 {
    address private owner;

    constructor(uint256 initialSupply) ERC20("OurToken", "OTK") {
        _mint(msg.sender, initialSupply);
        owner = msg.sender;
    }

    // Test-only function to mint tokens
    function testMint(address to, uint256 amount) public {
        require(msg.sender == owner, "Only the owner can mint in tests");
        _mint(to, amount);
    }
}
