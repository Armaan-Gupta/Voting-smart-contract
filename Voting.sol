// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "./VotingToken.sol";

contract VotingSystem {
    
    struct Voter {
        bool weight;
        bool voted;
        uint vote;
    }

    struct Candidate {
        string name;
        uint voteCount;
    }

    address public chairperson;
    mapping (address => Voter) public voters;
    Candidate[] public candidates;
    VotingToken public votingToken;

    constructor(string[] memory candidateNames, address _votingTokenAddress) {
        chairperson = msg.sender;
        voters[chairperson].weight = true;

        for (uint i = 0; i<candidateNames.length; i++) {
            candidates.push(Candidate({
                name: candidateNames[i],
                voteCount: 0
            }));
        }

        votingToken = VotingToken(_votingTokenAddress);
    }

    function giveRightToVote(address voter) public {
        require(
            msg.sender == chairperson,
            "Only chairperson can give right to vote."
        );
        require(
            !voters[voter].voted,
            "The voter already voted."
        );
        require(voters[voter].weight == false);
        votingToken.mint(voter, 1);
        voters[voter].weight = true;
    }

    function vote(uint proposal) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight == true, "Has no right to vote");
        require(!sender.voted, "Already voted");
        sender.voted = true;
        sender.vote = proposal;

        votingToken.transferFrom(msg.sender, address(this), 1);

        candidates[proposal].voteCount += 1;
    }

    function winningCandidate() public view returns(uint winningCandidate_) {
        uint winningVoteCount = 0;
        for (uint p=0; p<candidates.length; p++) {
            if (candidates[p].voteCount > winningVoteCount) {
                winningVoteCount = candidates[p].voteCount;
                winningCandidate_ = p;
            }
        }
    }

    function winnerName() public view returns(string memory winnerName_) {
        winnerName_ = candidates[winningCandidate()].name;
    }
}