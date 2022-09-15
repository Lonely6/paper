// SPDX-License-Identifier: SimPL-2.0
pragma solidity >=0.8.0;

import {Ownable} from "./Interfaces.sol"; //causa problemi con User is Ownable

/// @author Andrea Lisi
/// @title AssetStorage
/// @notice This contract interface defines the methods needed by a storage data structure
interface AssetStorage {

    function insert(address _asset) external;

    function remove(address _asset) external;

    function isIn(address _asset) external view returns(bool);    

    function getCount() external view returns(uint);

    function getAssets() external view returns(address[] memory);
}

/// @title StoragePointer
/// @notice This contract manages a storage data structure that allows insertion/deletion without iterating the stored elements, iteration and random access, but removing the elements changes the ordering of the elements
//
// Create a CRUD pointer-based structure
// source: https://medium.com/@robhitchens/solidity-crud-part-1-824ffa69509a
// 
// Benefits:
//     - possbility to iterate
//     - insert/remove don't iterate over the data
//     - remove operation scales array of addresses
//
// Flaws:
//     - destroy original ordering of addresses after remove operation
contract StoragePointer is AssetStorage {

    // Map contractAddress => array_pointer
    mapping(address => uint) assetMap;
    address[] assetIndex;


    /// @notice Insert a new asset inside this storage structure
    /// @param _asset The asset to insert
    /// @dev The asset should not be already present
    function insert(address _asset) override virtual public {

        require(!isIn(_asset), "Address already stored");

        assetIndex.push(_asset);
        uint len = assetIndex.length;
        assetMap[_asset] = len-1;
    }


    /// @notice Remove an asset from this storage structure
    /// @param _asset The asset to remove
    /// @dev The asset should be already present; Retrieve the position of the asset inside the array; move last element inside that position and shrink array; update pointer in map
    //把最后一个元素替换到要删除的文件位置处.
    function remove(address _asset) override virtual public {

        require(isIn(_asset), "Address not stored");
        
        uint len = assetIndex.length;
        uint rowToDelete = assetMap[_asset];
        address keyToMove = assetIndex[len - 1];
        assetIndex[rowToDelete] = keyToMove;
        assetMap[keyToMove] = rowToDelete;
        delete (assetIndex[len - 1]);
    }


    /// @notice Check if an asset is already present
    /// @param _asset The asset to check the presence
    /// @return True if the asset is present; false otherwise
    function isIn(address _asset) public override view returns (bool) {
        
        if (assetIndex.length == 0) 
            return false;

        uint idx = assetMap[_asset];
        return assetIndex[idx] == _asset;
    }


    /// @notice Get the number of assets present
    /// @return The number of assets
    function getCount() external override view returns(uint) {

        return assetIndex.length;
    }


    /// @notice Get the array of assets present
    /// @return The array of assets
    function getAssets() external override view returns(address[] memory) {

        return assetIndex;
    }


    /// @notice Get the asset at a given position
    /// @param index The index of the asset
    /// @return The asset
    function getKeyAt(uint index) external view returns(address) {

        require(index >= 0 && index < assetIndex.length);
        return assetIndex[index];
    }
}



/// @title OwnableStoragePointer
/// @notice Extension of StoragePointer such that insert/remove operations are allowed only by the owner of the storage
contract OwnableStoragePointer is StoragePointer, Ownable {

    constructor(address _owner) Ownable(_owner) {}


    /// @notice Insert a new asset inside this storage structure
    /// @param _asset The asset to insert
    /// @dev The asset should not be already present; the caller should be the owner of the contract
    function insert(address _asset) public override isOwner {

        super.insert(_asset);
    }
    

    /// @notice Remove an asset from this storage structure
    /// @param _asset The asset to remove
    /// @dev The asset should be already present; Retrieve the position of the asset inside the array; move last element inside that position and shrink array; update pointer in map; the caller should be the owner of the contract
    function remove(address _asset) public override isOwner {

        super.remove(_asset);
    }
}