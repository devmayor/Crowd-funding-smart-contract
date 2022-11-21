// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Campaign {
  struct Request {
    string description;
    uint value;
    address payable recipient;
    bool complete;
    uint approvalCount;
    mapping(address => bool) approvers;
  }
  uint requestCount;
  mapping(uint => Request) public requests;
  address public manager;
  uint public minimumContribution;
  mapping(address => bool) public approvers;
  uint contributorsCount = 0;


  modifier AdminOnly() {
    require(msg.sender == manager, "You don't have access");
    _;
  }

  constructor(uint minimun) public {
    manager = msg.sender;
    minimumContribution = minimun;
  }

  function contribute() public payable {
    uint amount = msg.value;
    require(amount > minimumContribution);
    approvers[msg.sender] = true;
    contributorsCount++;
  }

  function createRequest(string memory description, uint value, address payable recipient) public AdminOnly {
    Request storage newRequest = requests[requestCount++];
      newRequest.description = description;
      newRequest.value = value;
      newRequest.recipient = recipient;
      newRequest.complete = false;
      newRequest.approvalCount = 0;

  }
  function approveRequest(uint requestIndex) public  {
    Request storage request = requests[requestIndex];
    require(approvers[msg.sender]);
    require(!request.approvers[msg.sender]);

    request.approvers[msg.sender] = true;
    request.approvalCount++;

  }

  function finalizeRequest(uint requestIndex) public AdminOnly payable {
    Request storage request = requests[requestIndex];
    require(request.approvalCount > (contributorsCount/2));
    require(!request.complete);


    request.recipient.transfer(request.value);
    request.complete = true;
  }
  
}
