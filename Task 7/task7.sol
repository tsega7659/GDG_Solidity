
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CrowdFund {

    /* =============================================================
                            STEP 1
    ============================================================= */
    
    struct Campaign {
        address owner;
        uint256 goal;
        uint256 pledged;
        uint256 startAt;
        uint256 endAt;
        bool claimed;
    }

    /* =============================================================
                            STEP 2
    ============================================================= */
    
    uint256 public campaignCount;

    mapping(uint256 => Campaign) public campaigns;

    mapping(uint256 => mapping(address => uint256)) public pledgedAmount;


    /* =============================================================
                            STEP 3
    ============================================================= */
    
    function create(uint256 _goal, uint256 _duration) external {
        require(_goal > 0, "Goal must be > 0");
        require(_duration > 0, "Duration must be > 0");

        campaignCount++;

        campaigns[campaignCount] = Campaign({
            owner: msg.sender,
            goal: _goal,
            pledged: 0,
            startAt: block.timestamp,
            endAt: block.timestamp + _duration,
            claimed: false
        });
    }


    /* =============================================================
                            STEP 4
    ============================================================= */
    
    function pledge(uint256 _id) external payable {
        Campaign storage campaign = campaigns[_id];

        require(block.timestamp < campaign.endAt, "Campaign ended");
        require(msg.value > 0, "Must send ETH");

        campaign.pledged += msg.value;
        pledgedAmount[_id][msg.sender] += msg.value;
    }


    /* =============================================================
                            STEP 5
    ============================================================= */
    
    function claim(uint256 _id) external {
        Campaign storage campaign = campaigns[_id];

        require(msg.sender == campaign.owner, "Not owner");
        require(block.timestamp >= campaign.endAt, "Campaign not ended");
        require(campaign.pledged >= campaign.goal, "Goal not reached");
        require(!campaign.claimed, "Already claimed");

        campaign.claimed = true;

        (bool success, ) = payable(campaign.owner).call{value: campaign.pledged}("");
        require(success, "Transfer failed");
    }


    /* =============================================================
                            STEP 6
    ============================================================= */
    
    function refund(uint256 _id) external {
        Campaign storage campaign = campaigns[_id];

        require(block.timestamp >= campaign.endAt, "Campaign not ended");
        require(campaign.pledged < campaign.goal, "Goal was reached");

        uint256 bal = pledgedAmount[_id][msg.sender];
        require(bal > 0, "Nothing to refund");

        pledgedAmount[_id][msg.sender] = 0;

        (bool success, ) = payable(msg.sender).call{value: bal}("");
        require(success, "Refund failed");
    }
}
