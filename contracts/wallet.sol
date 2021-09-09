pragma solidity 0.6.0;
pragma experimental ABIEncoderV2;

contract Wallet {
    address [] public approvers;
    uint public quorum;
    struct Transfer {
        uint id;
        uint amount;
        address payable to;
        uint approvals;
        bool sent; 
        
    }
    Transfer[] public transfers;
    mapping(address => mapping(uint => bool)) public approvals;
    //uint public nextId;
    
    constructor(address[] memory _approvers, uint _quorum ) public {
        approvers = _approvers;
        quorum = _quorum;
    }
    

    function getApprovers() external view returns(address[] memory) {
        return approvers;
    }
    
    
    function getTransfers() external view returns(Transfer[] memory) {
        return transfers;
    }
    
    // function createTransfer(uint amount, address payable to) public {
    //     transfers[nextId] = Transfer(nextId, amount, to, 0, false); 
    //     nextId++;
    // }
    function createTransfer(uint amount, address payable to) external onlyApproval() {
    transfers.push(Transfer(transfers.length, amount, to, 0, false));

    }
    
    function approveTransfers(uint id) external onlyApproval() {
        require(transfers[id].sent == false, 'transfer has already been sent');
        require(approvals[msg.sender][id] == false, 'this transfer has been approved');
        
        approvals[msg.sender][id] = true;
        transfers[id].approvals++;
        
        if(transfers[id].approvals >= quorum) {
           transfers[id].sent = true;
           address payable to;transfers[id].to;
           uint amount = transfers[id].amount;
           to.transfer(amount);
        }
    }
    
    receive() external payable { 
        
    }
    
    modifier onlyApproval() {
        bool allowed = false;
        for(uint i = 0; i < approvers.length; i++) {
         if(approvers[i] == msg.sender) {
             allowed = true;
         }   
        }
        require(allowed == true, 'only approver allowed');
        _;
        
    }
}