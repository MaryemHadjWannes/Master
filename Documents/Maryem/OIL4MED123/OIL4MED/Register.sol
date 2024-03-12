// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "./FarmerRole.sol";
import "./MillManagerRole.sol";
import "./ConsumerRole.sol";

contract RegisterUser is FarmerRole, MillManagerRole, ConsumerRole {
    
    struct User {
        address userAddress;
        string role;
    }
    
    mapping(address => User) public users;
    address[] public userAddresses;
    
    function registerUser(address _userAddress, string memory _role) public {
        require(
            keccak256(abi.encodePacked(_role)) == keccak256(abi.encodePacked("farmer")) ||
            keccak256(abi.encodePacked(_role)) == keccak256(abi.encodePacked("millmanager")) ||
            keccak256(abi.encodePacked(_role)) == keccak256(abi.encodePacked("consumer")),
            "Invalid role"
        );
        
        if (keccak256(abi.encodePacked(_role)) == keccak256(abi.encodePacked("farmer"))) {
            require(isFarmer(msg.sender), "Only farmers can register as farmers");
            addFarmer(_userAddress);
        } else if (keccak256(abi.encodePacked(_role)) == keccak256(abi.encodePacked("millmanager"))) {
            require(isMillManager(msg.sender), "Only mill managers can register as mill managers");
            addMillManager(_userAddress);
        } else if (keccak256(abi.encodePacked(_role)) == keccak256(abi.encodePacked("consumer"))) {
            require(isConsumer(msg.sender), "Only consumers can register as consumers");
            addConsumer(_userAddress);
        }
        
        users[_userAddress] = User(_userAddress, _role);
        userAddresses.push(_userAddress);
    }
    
    function getUserRole(address _userAddress) public view returns (string memory) {
        return users[_userAddress].role;
    }
    
}
