// SPDX-License-Identifier: MIT

pragma solidity 0.8.5;

contract CheckOwner {
    address owner;

    constructor(){
        owner = msg.sender;
    }

    modifier isOwner(){
        require(owner == msg.sender, "You are not the owner!");
        _;
    }
}

contract ModifierExample is CheckOwner {
    uint myUint;

    constructor(){
        myUint = 5;
    }

    function updateUint(uint _newUint) public isOwner {
        myUint = _newUint;
    }

    function getter() public view isOwner returns(uint) {
        return myUint;
    }
}