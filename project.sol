// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GameCommunityRewards {
    // Structures
    struct Reward {
        string name;
        string description;
        uint256 pointsRequired;
        bool isActive;
    }

    struct User {
        uint256 points;
        mapping(uint256 => bool) claimedRewards;
    }

    // State Variables
    address public owner;
    uint256 public rewardCount;
    mapping(address => User) private users;
    mapping(uint256 => Reward) private rewards;

    // Events
    event RewardAdded(uint256 rewardId, string name, uint256 pointsRequired);
    event PointsUpdated(address user, uint256 points);
    event RewardClaimed(address user, uint256 rewardId);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier validReward(uint256 rewardId) {
        require(rewardId < rewardCount, "Invalid reward ID");
        require(rewards[rewardId].isActive, "Reward is not active");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Owner Functions
    function addReward(
        string memory name,
        string memory description,
        uint256 pointsRequired
    ) public onlyOwner {
        rewards[rewardCount] = Reward({
            name: name,
            description: description,
            pointsRequired: pointsRequired,
            isActive: true
        });

        emit RewardAdded(rewardCount, name, pointsRequired);
        rewardCount++;
    }

    function deactivateReward(uint256 rewardId) public onlyOwner validReward(rewardId) {
        rewards[rewardId].isActive = false;
    }

    // User Functions
    function updatePoints(address user, uint256 points) public onlyOwner {
        users[user].points += points;
        emit PointsUpdated(user, users[user].points);
    }

    function claimReward(uint256 rewardId) public validReward(rewardId) {
        User storage user = users[msg.sender];
        Reward storage reward = rewards[rewardId];

        require(user.points >= reward.pointsRequired, "Insufficient points");
        require(!user.claimedRewards[rewardId], "Reward already claimed");

        user.points -= reward.pointsRequired;
        user.claimedRewards[rewardId] = true;

        emit RewardClaimed(msg.sender, rewardId);
    }

    // View Functions
    function getUserPoints(address user) public view returns (uint256) {
        return users[user].points;
    }

    function getReward(uint256 rewardId)
        public
        view
        validReward(rewardId)
        returns (
            string memory name,
            string memory description,
            uint256 pointsRequired,
            bool isActive
        )
    {
        Reward storage reward = rewards[rewardId];
        return (reward.name, reward.description, reward.pointsRequired, reward.isActive);
    }
}
