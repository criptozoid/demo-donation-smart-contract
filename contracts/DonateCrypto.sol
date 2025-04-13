// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

// senha1 SMARTCONTRACT


struct Campaign {
    address creator;
    uint256 goalAmount;
    string title;
    string description;
    string videoUrl;
    string imageUrl;
    uint256 balance;
    bool active;
}

contract DonatCrypto {

    uint256 public fee = 100; // wei
    uint256 public nextId = 0;
    
    mapping(uint256 => Campaign) public campaigns;

    function addCampaign(uint256 goalAmount, string calldata title, string calldata description, string calldata videoUrl, string calldata imageUrl) public {
        Campaign memory newCampaign;
        newCampaign.goalAmount = goalAmount;
        newCampaign.title = title;
        newCampaign.description = description;
        newCampaign.videoUrl = videoUrl;
        newCampaign.imageUrl = imageUrl;
        newCampaign.active = true;
        newCampaign.creator = msg.sender;

        nextId++;
        campaigns[nextId] = newCampaign;
    }

    function donate(uint256 id) public payable {
        require (campaigns[id].active, "Campaign is not active");
        require (msg.value != 0, "Donation must be greater than zero");
        
        campaigns[id].balance += msg.value;
    }

    function withdraw(uint256 id) public {
        Campaign storage campaign = campaigns[id];
        require (campaign.creator == msg.sender, "Only the owner can withdraw");
        require (campaign.active == true, "Campaign is closed");
        require (campaign.balance > fee, "Insufficient balance");

        address payable recipient = payable(campaign.creator);
        (bool success, ) = recipient.call{value: campaign.balance - fee}("");
        require (success, "Transaction failed");

        campaign.active = false;
    }
}