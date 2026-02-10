
pragma solidity ^0.8.20;

contract StudentSavingsWallet {

    mapping(address => uint256) private balances;

    // Transaction structure
    struct Transaction {
        address user;
        uint256 amount;
        string txType; // "Deposit" or "Withdraw"
        uint256 timestamp;
    }

    // Store all transactions
    Transaction[] private transactions;

    
    // DEPOSIT FUNCTION
   
    function deposit() public payable {
        require(msg.value > 0, "Must send ETH");

        balances[msg.sender] += msg.value;

        transactions.push(Transaction(
            msg.sender,
            msg.value,
            "Deposit",
            block.timestamp
        ));
    }


    // WITHDRAW FUNCTION
    
    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;

        payable(msg.sender).transfer(amount);

        transactions.push(Transaction(
            msg.sender,
            amount,
            "Withdraw",
            block.timestamp
        ));
    }

   
    // VIEW BALANCE
    
    function getMyBalance() public view returns (uint256) {
        return balances[msg.sender];
    }

   
    // VIEW ALL TRANSACTIONS
   
    function getAllTransactions() public view returns (Transaction[] memory) {
        return transactions;
    }
}
