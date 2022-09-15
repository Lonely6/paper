// SPDX-License-Identifier: SimPL-2.0
pragma solidity >=0.8.0;

//各种评分功能.

interface RatingFunction {

    function compute(uint[] calldata _scores) external pure returns(uint);
}


/// @title SimpleAverageFunction
/// @notice Compute the final score with simple average on the score values
abstract contract SimpleAvarageFunction is RatingFunction {
    
    function compute(uint[] calldata _scores) external override pure returns(uint) {

        uint len = _scores.length;

        if (len <= 0) 
            return 0;
 
        // Simple average
        uint total = 0;

        for (uint i=0; i<len; i++)
            total += _scores[i];

        return total / len;
    }
}
