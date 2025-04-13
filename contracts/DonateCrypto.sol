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

contract DonateCrypto {

    uint256 public fee = 100; // wei
    uint256 public nextId = 1;
    
    mapping(uint256 => Campaign) public campaigns;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    // Reentrancy guard
    bool private locked;

    modifier noReentrancy() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }

    modifier onlyCreator(uint256 id) {
        require(campaigns[id].creator == msg.sender, "You are not the creator of this campaign");
        _;
    }

    function addCampaign(
        uint256 goalAmount, 
        string calldata title, 
        string calldata description, 
        string calldata videoUrl, 
        string calldata imageUrl
    ) public {
        campaigns[nextId] = Campaign({
            creator: msg.sender,
            goalAmount: goalAmount,
            title: title,
            description: description,
            videoUrl: videoUrl,
            imageUrl: imageUrl,
            balance: 0,
            active: true
        });

        nextId++;
    }

    function donate(uint256 id) public payable {
        require(campaigns[id].active, "Campaign is not active");
        require(msg.value != 0, "Donation must be greater than zero");
        
        campaigns[id].balance += msg.value;
    }

    function withdraw(uint256 id) public noReentrancy onlyCreator(id) {
        Campaign storage campaign = campaigns[id];
        require(campaign.active, "Campaign is closed");
        require(campaign.balance > fee, "Insufficient balance");

        address payable recipient = payable(campaign.creator);
        (bool success, ) = recipient.call{value: campaign.balance - fee}("");
        require(success, "Transaction failed");

        campaign.active = false;
    }
}