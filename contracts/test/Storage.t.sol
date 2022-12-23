// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";


contract Token {
    address immutable owner;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    string name;

    constructor(string memory _name) {
        owner = msg.sender;
        name = _name;
    }

    function mint(address user, uint256 amount) external {
        require(msg.sender == owner, "Only owner is allowed to mint");
        balanceOf[user] += amount;
    }
}


contract StorageTest is Test {
    address Ali = makeAddr("Ali");

    function testLoadBalance() public {
        Token t = new Token("Hi");
        t.mint(Ali, 1 ether);

        // Compute the slot at which Ali's balance is stored in the Token contract
        bytes32 aliBalanceSlot = keccak256(
            abi.encodePacked(uint256(uint160(Ali)), uint256(1))
        );

        // Now load Ali's balance
        uint256 aliBalance = uint256(vm.load(address(t), aliBalanceSlot));

        // Make sure that the loaded balance matches Ali's real balance
        assertEq(aliBalance, t.balanceOf(Ali));
    }
}