module MyModule::VotingDAO {
    use aptos_framework::signer;
    use std::vector;

    /// Struct representing a voting proposal
    struct Proposal has store, key {
        title: vector<u8>,        // Title of the proposal
        yes_votes: u64,           // Number of yes votes
        no_votes: u64,            // Number of no votes
        voters: vector<address>,  // List of addresses that have voted
        is_active: bool,          // Whether voting is still active
    }

    /// Error codes
    const E_PROPOSAL_NOT_FOUND: u64 = 1;
    const E_ALREADY_VOTED: u64 = 2;
    const E_PROPOSAL_INACTIVE: u64 = 3;

    /// Function to create a new voting proposal
    public fun create_proposal(creator: &signer, title: vector<u8>) {
        let proposal = Proposal {
            title,
            yes_votes: 0,
            no_votes: 0,
            voters: vector::empty<address>(),
            is_active: true,
        };
        move_to(creator, proposal);
    }

    /// Function for users to vote on a proposal
    public fun vote_on_proposal(
        voter: &signer, 
        proposal_owner: address, 
        vote_yes: bool
    ) acquires Proposal {
        let voter_address = signer::address_of(voter);
        let proposal = borrow_global_mut<Proposal>(proposal_owner);
        
        // Check if proposal is active
        assert!(proposal.is_active, E_PROPOSAL_INACTIVE);
        
        // Check if user has already voted
        assert!(!vector::contains(&proposal.voters, &voter_address), E_ALREADY_VOTED);
        
        // Record the vote
        if (vote_yes) {
            proposal.yes_votes = proposal.yes_votes + 1;
        } else {
            proposal.no_votes = proposal.no_votes + 1;
        };
        
        // Add voter to the list
        vector::push_back(&mut proposal.voters, voter_address);
    }
}