pragma solidity ^0.5.0;

contract Voting {
  uint256 public votePrice = 5000000000000000;
  uint public num_candidate = 0;
  string public question;
  address owner;

  struct Candidate {
    uint id;
    string name;
    uint num_vote;
  }

  mapping(uint => Candidate) public candidates;

  constructor() public {
    owner = msg.sender;
  }

  function setQuestion(string memory _question) public {
    require(msg.sender == owner);
    question = _question;
  }

  function addCandidate(string memory _name) public {
    require(msg.sender == owner);
    num_candidate++;
    candidates[num_candidate] = Candidate(num_candidate, _name, 0);
  }

  function voteCandidate(uint _id, uint _num_vote) public payable {
    require(_num_vote * votePrice <= msg.value);
    Candidate memory _candidate = candidates[_id];
    _candidate.num_vote += _num_vote;
    candidates[_id] = _candidate;
  }
}