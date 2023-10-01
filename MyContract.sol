// SPDX-License-Identifier: MIT

pragma solidity 0.8.5;

contract MyContract {
    event ErrorLogging(string reason);
    event ErrorLogCode(uint code);
    event ErrorLogLowLevelData(bytes lowLeveldata);

    struct Transaction {
        uint amount;
        uint timestamp;
        address from;
        address to;
    }

    struct Balance {
        uint totalAmount;
        uint depositCount;
        uint withdrawCount;
        mapping(uint => Transaction) deposits;
        mapping(uint => Transaction) withdrawals;
    }

    mapping(address => Balance) public bank;

    function deposit() public payable {
        bank[msg.sender].totalAmount += msg.value;
        
        bank[msg.sender].deposits[bank[msg.sender].depositCount] = Transaction(msg.value, block.timestamp, msg.sender, msg.sender);
        bank[msg.sender].depositCount++;
    } 

    function getDepositTransaction(uint _index) public view returns(Transaction memory) {
        return bank[msg.sender].deposits[_index];
    }

    function withdraw(address payable _to, uint _amount) public {
        // require(bank[msg.sender].totalAmount >= _amount, "You don't have that much money in your bank!");

        // if(bank[msg.sender].totalAmount < _amount){
        //     revert NotAllowed("You don't have that much money in your bank!");
        // }

        WillThrowError will = new WillThrowError();

        try will.aFunction(){
            require(bank[msg.sender].totalAmount >= _amount, "You don't have that much money in your bank!");

            bank[msg.sender].totalAmount -= _amount;

            bank[msg.sender].withdrawals[bank[msg.sender].withdrawCount] = Transaction(_amount, block.timestamp, msg.sender, _to);
            bank[msg.sender].withdrawCount++;
            
            _to.transfer(_amount);
        }catch Error(string memory reason){
            emit ErrorLogging(reason);
        }catch Panic(uint code){
            emit ErrorLogCode(code);
        }catch(bytes memory lowLevelData ){
            emit ErrorLogLowLevelData(lowLevelData);
        }
    }

    function getWithdrawTransaction(uint _index) public view returns(Transaction memory) {
        return bank[msg.sender].withdrawals[_index];
    }

}

contract WillThrowError {
    error NotAllowed(string);

    function aFunction() public pure {
        // require(false, "You are not allowed!");
        // assert(false);
        revert NotAllowed('Something went wrong!');
    }
}