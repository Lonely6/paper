// SPDX-License-Identifier: SimPL-2.0

pragma solidity >= 0.8.0;

//评分功能注册.
import {Ownable} from "./Interfaces.sol";
import {RatingFunction, SimpleAvarageFunction} from "./RatingFunction.sol";

/// @author Andrea Lisi
/// @title FunctionRegistry
/// @notice This contracts stores a list of RatingFunctions. An Item can pick from this registry the function it wants to use to compute its final score
contract FunctionRegistry is Ownable {

    RatingFunction[] private registry;  // Se metto public questo mi evito la funzione getFunction
    bytes32[] private ids;
    mapping(address => bool) haveReistry;

    constructor(address _owner) Ownable(_owner) {}

    /// @notice Add a new RatingFunction to the registry, only if the caller is the owner of this registry (avoid spam)
    /// @param _function The Function to add
    /// @param _name A name for the Function
    function pushFunction(RatingFunction _function, bytes32 _name) external isOwner {
        
        haveReistry[address(_function)] == true;
        registry.push(_function);
        ids.push(_name);
    }

    /// @notice Get the RatingFunction at a certain index
    /// @param _index The index of the Function to retrieve
    /// @return The RatingFunction address
    function getFunction(uint _index) external view returns(RatingFunction) {

        require(_index >= 0 && _index < registry.length, "Invalid Function index");

        return registry[_index];
    }

    function checkRegistry(RatingFunction _function) external view returns(bool) {
        return haveReistry[address(_function)];
    }

    /// @notice Get the list of the names of the stored RatingFunctionFunctions
    /// @return The list of RatingFunction
    function getIds() external view returns(bytes32[] memory) {

        return ids;
    }
}
