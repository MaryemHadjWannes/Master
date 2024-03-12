// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

// Import the library 'Roles'
import "./Roles.sol";

// Define a contract 'MillManagerRole' to manage this role - add, remove, check
contract MillManagerRole {
  using Roles for Roles.Role;

  // Define 2 events, one for Adding, and other for Removing
  event MillManagerAdded(address indexed account);
  event MillManagerRemoved(address indexed account);
  
  // Define a struct 'MillManagers' by inheriting from 'Roles' library, struct Role
  Roles.Role private MillManagers;
  // In the constructor make the address that deploys this contract the 1st MillManager
  constructor() {
    _addMillManager(msg.sender);
  }

  // Define a modifier that checks to see if msg.sender has the appropriate role
  modifier onlyMillManager() {
     require(isMillManager(msg.sender));
    _;
  }

  // Define a function 'isMillManager' to check this role
  function isMillManager(address account) public view returns (bool) {
    return MillManagers.has(account);
  }

  // Define a function 'addMillManager' that adds this role
  function addMillManager(address account) public onlyMillManager {
    _addMillManager(account);
  }

  // Define a function 'renounceMillManager' to renounce this role
  function renounceMillManager() public {
    _removeMillManager(msg.sender);
  }

  // Define an internal function '_addMillManager' to add this role, called by 'addMillManager'
  function _addMillManager(address account) internal {
    MillManagers.add(account);
    emit MillManagerAdded(account);
  }

  // Define an internal function '_removeMillManager' to remove this role, called by 'removeMillManager'
  function _removeMillManager(address account) internal {
    MillManagers.remove(account);
    emit MillManagerRemoved(account);
  }
}