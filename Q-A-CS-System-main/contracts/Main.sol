// SPDX-License-Identifier: SimPL-2.0
pragma solidity >=0.8.0;

import "./Interfaces.sol";
import "./AssetStorage.sol";
import "./User.sol";
import "./FunctionRegistry.sol";

contract MainSystem is Ownable {

    // Data
    FunctionRegistry            public  functionRegistry;
    OwnableStoragePointer       private users;             // Structure to store users
    mapping(address => User)    private userAddresses;     // Ensure that a single account can instantiate only a single User contract

    // Events
    event UserCreated(User _userContract);

    constructor () Ownable(msg.sender) {
        // functionRegistry = new FunctionRegistry(msg.sender); 
        users = new OwnableStoragePointer(address(this));       // Because (this) interacts with the storage
    }

    function createUser(string memory _name) external {

        require(address(userAddresses[msg.sender]) == address(0x0), "This address has already a User registered");

        User user = new User(_name, msg.sender);   
        userAddresses[msg.sender] = user;
        users.insert(address(user));

        emit UserCreated(user);
    }

    // function deleteUser(User _user) external  {

    //     require(userAddresses[msg.sender] == _user, "You cannot remove other's user's contracts");

    //     delete userAddresses[msg.sender];
    //     users.remove(address(_user));
    // }

    function getMyUserContract() external view returns(User) {

        return userAddresses[msg.sender];
    }

    // function getUsers() external view returns(address[] memory) {

    //     return users.getAssets();
    // }

    function isIn(User _user) external view returns(bool) {

        return users.isIn(address(_user));
    }

    // function userCount() external view returns(uint) {

    //     return users.getCount();
    // }

}