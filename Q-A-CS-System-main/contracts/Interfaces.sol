// SPDX-License-Identifier: SimPL-2.0
pragma solidity >=0.8.0;


/// @author Andrea Lisi
/// @title Ownable
/// @notice This contract keeps the information of its owner, passed as parameter to the constructor. It provides a modifier to let only the owner to pass its guard
contract Ownable {

    address public owner;

    constructor (address _owner) {

        owner = _owner;
    }

    modifier isOwner() {

        require(msg.sender == owner, "Not the owner");
        _;
    }

    /// @notice This function provides the possibility to change the owner
    /// @param _to The new owner of this contract 
    function changeOwner(address _to) external isOwner {

        owner = _to;
    }
}


/// @title Permissioned
/// @notice This contract defines a permission policy and provides the functions to grant/revoke permissions to certain users/contracts. A Permissioned contract should be a contract with the purpouse to be accessed only by authorized entities
contract Permissioned is Ownable {

    // The policies defined for this contract
    struct PermissionPolicy {
        
        bool granted;
        uint periodStart;
    }

    // For each address we have a PermissionPolicy defined
    mapping(address => PermissionPolicy) public permissionMap;
    uint constant interval = 100000; // 100K blocks, if 14 sec per block, then more or less 16 days

    // Events
    event NewPermission(address _to);
    event PermissionRevoked(address _to);

    constructor (address _owner) Ownable(_owner) {}

    /// @notice Grant the permission to access to this contract to a certain address (contract or EOA)
    /// @param _to The address meant to have permission
    /// @dev The owner of this contract cannot grant permission to itself 
    function grantPermission(address _to) internal virtual {

        require(_to != owner, "The owner cannot grant permission to himself");

        permissionMap[_to] = PermissionPolicy({granted: true, periodStart: block.timestamp});

        emit NewPermission(_to);
    }

    /// @notice Revoke the permission to access to this contract to a certain address (contract or EOA)
    /// @param _to The address to revoke permission
    /// @dev Only the owner of this contract or the receiver itself can revoke the permission to the receiver
    function revokePermission(address _to) public {

        require(msg.sender == _to || msg.sender == owner, "You cannot revoke permission to other users");

        permissionMap[_to] = PermissionPolicy({granted: false, periodStart: 0});

        emit PermissionRevoked(_to);
    }
    
    function checkForPermission(address _of) public view returns (bool) {

        PermissionPolicy memory policy = permissionMap[_of];

        return policy.granted;
    }
}