// SPDX-License-Identifier: SimPL-2.0

pragma solidity >=0.8.0;



import "./User.sol";

import "./Item.sol";

import "./RatingFunction.sol";



contract Question {

    

    //Data

    address                 public  MS;

    Item                    public  item;

    string                  public  ipfs;

    User                    public  asker;

    uint256                 public  answerNumber;

    uint256                 public  time;

    // OwnableStoragePointer   private answers;



    event NewAnswer(string _ipfs, User _answer);

    event AnswerRated(uint256 answer_index, uint8 _score, User _rater);

    event AnswerConfirmed(address _question, uint256 _index);



    struct Answer {

        string   ipfs;

        User     answerer;

        uint256  time;

        //Score

        uint[]  scoreArray;

        User[]  raterArray; 

        // uint[]  public timeArray;

        mapping(User => bool) haveRated;

    }

    

    mapping(uint => Answer) public answers;

    

    constructor (address _ms, Item _item, string memory _ipfs) {

        MS = _ms;

        item = _item;

        ipfs = _ipfs;

        asker = User(msg.sender);

        time = block.timestamp;

        // answers = new OwnableStoragePointer(address(this));

    }

    

    function addAnswer(address _ms, string memory _ipfs) external {

        require(_ms == MS);

        User _user = User(msg.sender);

        require(_user != asker);

        require(item.checkForPermission(address(_user)) == true);

        answerNumber++;

        answers[answerNumber].ipfs = _ipfs;

        answers[answerNumber].answerer = _user;

        answers[answerNumber].time = block.timestamp;

        

        item.tokenContract().transfer(address(_user), 10);

        

        emit NewAnswer(_ipfs, _user);

    }

    

    function rateAnswer(uint256 _index, address _ms, uint8 _score) external {

        require(_ms == MS);

        User _user = User(msg.sender);

        require(answers[_index].haveRated[_user] == false);

        require(item.checkForPermission(msg.sender) == true);

     

        require(_score >= 1 && _score <= 10, "Score out of scale");



        if (_user == asker) {

            answers[_index].answerer.updateReputation();

            emit AnswerConfirmed(address(this), _index);

        }

        answers[_index].scoreArray.push(_score);

        answers[_index].raterArray.push(_user);



        assert(answers[_index].scoreArray.length == answers[_index].raterArray.length);  

        item.tokenContract().transfer(address(_user), 1);



        if (_score > 6 ) {

            item.tokenContract().transfer(address(answers[_index].answerer), 1);

        }      



        answers[_index].haveRated[_user] = true;



        emit AnswerRated(_index, _score, _user);

    }

    

    function computeScore(RatingFunction _function, uint256 _index) external view returns (uint) {

        return _function.compute(answers[_index].scoreArray);

    }

    

}
