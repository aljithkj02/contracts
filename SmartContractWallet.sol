// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

contract Consumer {
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function deposit() public payable {}
}

contract SmartContractWallet {
    address payable public owner;
    
    mapping(address => uint) public allowance;
    mapping(address => bool) public isAllowedToSend;

    mapping(address => bool) public guardians;

    address payable nextOwner;
    mapping(address => mapping(address => bool)) public nextOwnerGuardianVotedBool;
    uint guardianResetCount;
    uint public constant confirmationsFromGuardiansForReset = 3;

    constructor(){
        owner = payable(msg.sender);
    }

    function setGuardians(address _guardian, bool _isGuardian) public {
        require(owner == msg.sender, "You are not the owner !, aborting");
        guardians[_guardian] = _isGuardian;
    }

    function proposeNewOwner(address payable _newOwner) public {
        require(guardians[msg.sender], "You are not a guardian of this wallet!, go away!, aborting");
        require(nextOwnerGuardianVotedBool[_newOwner][msg.sender] == false, "You already voted!, aborting");

        if(owner != _newOwner){
            nextOwner = _newOwner;
            guardianResetCount = 0;
        }

        guardianResetCount++;

        if(guardianResetCount >= confirmationsFromGuardiansForReset){
            owner = nextOwner;
            nextOwner = payable(address(0));
        }
    }

    function setAllowance(address _for, uint _amount) public {
        require(owner == msg.sender, "You are not the owner !, aborting");

        allowance[_for] = _amount;
        if(allowance[_for] > 0) {
            isAllowedToSend[_for] = true;
        }else {
            isAllowedToSend[_for] = false;
        }
    }

    function transfer(address payable _to, uint _amount, bytes memory _payload) public returns(bytes memory) {

        if(msg.sender != owner){
            require(isAllowedToSend[msg.sender], "You are not allowed to send anything from this Smart Contract!, aborting");
            require(allowance[msg.sender] >= _amount, "You are trying to send more than you are allowed to !, aborting");
        }

        (bool success, bytes memory returnData) = _to.call{ value: _amount }(_payload);
        require(success, "Aborting, call was not successful!");

        return returnData;
    }

    receive() external payable { }
}