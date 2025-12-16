// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Voting
 * @dev A simple voting contract for proposals
 */
contract Voting {
    struct Proposal {
        string description;
        uint256 voteCount;
        bool executed;
    }

    address public owner;
    Proposal[] public proposals;
    mapping(address => mapping(uint256 => bool)) public hasVoted;
    mapping(address => bool) public isVoter;

    event ProposalCreated(uint256 indexed proposalId, string description);
    event Voted(uint256 indexed proposalId, address indexed voter);
    event VoterAdded(address indexed voter);
    event VoterRemoved(address indexed voter);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    modifier onlyVoter() {
        require(isVoter[msg.sender], "Not a registered voter");
        _;
    }

    constructor() {
        owner = msg.sender;
        isVoter[msg.sender] = true;
    }

    function addVoter(address _voter) external onlyOwner {
        require(!isVoter[_voter], "Already a voter");
        isVoter[_voter] = true;
        emit VoterAdded(_voter);
    }

    function removeVoter(address _voter) external onlyOwner {
        require(isVoter[_voter], "Not a voter");
        require(_voter != owner, "Cannot remove owner");
        isVoter[_voter] = false;
        emit VoterRemoved(_voter);
    }

    function createProposal(string calldata _description) external onlyVoter {
        proposals.push(Proposal({
            description: _description,
            voteCount: 0,
            executed: false
        }));
        emit ProposalCreated(proposals.length - 1, _description);
    }

    function vote(uint256 _proposalId) external onlyVoter {
        require(_proposalId < proposals.length, "Invalid proposal");
        require(!hasVoted[msg.sender][_proposalId], "Already voted");
        require(!proposals[_proposalId].executed, "Proposal already executed");

        hasVoted[msg.sender][_proposalId] = true;
        proposals[_proposalId].voteCount++;
        emit Voted(_proposalId, msg.sender);
    }

    function getProposalCount() external view returns (uint256) {
        return proposals.length;
    }

    function getProposal(uint256 _proposalId) external view returns (
        string memory description,
        uint256 voteCount,
        bool executed
    ) {
        require(_proposalId < proposals.length, "Invalid proposal");
        Proposal storage proposal = proposals[_proposalId];
        return (proposal.description, proposal.voteCount, proposal.executed);
    }
}
