// SPDX-License-Identifier: SimPL-2.0
pragma solidity >=0.8.0;
/// @author Andrea Lisi, Samuel Fabrizi

library QALibrary {

    // Rating data bundle
    struct Questions {
        address Item;
        uint Time;
        string IPFS;
        // Other data to define
    }
    struct Answers {
        address Question;
        uint Time;
        string IPFS;
    }

    struct Rating {
        address Question;
        uint answerIndex;
        uint Time;
        uint8 Score;
    }
}
