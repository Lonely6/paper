// SPDX-License-Identifier: SimPL-2.0

pragma solidity >=0.8.0;



import "./Interfaces.sol";

import "./AssetStorage.sol";

import "./Q&ALibrary.sol";

import "./Item.sol";

import "./Question.sol";

import "./Main.sol";



contract User is Ownable {

    

    // Data

    string                  public  name;           // Username

    address                 public  MS;

    uint256                 public  reputation;

    OwnableStoragePointer   private items;          // Structure to store Items published by this user

    QALibrary.Questions[]   public  questions;

    QALibrary.Answers[]     public  answers;

    QALibrary.Rating[]      public  ratings;    // Structure to keep track of the ratings performed by this user



    // Events

    event ItemCreated(Item _itemContract);

    event QuestionCreated(address _question);

    event AnswerAdded(QALibrary.Answers _answer);

    event AnswerRated(QALibrary.Rating _rating);

    event ItemPaid(User _user, Item _item, uint _amount, uint256 _totalTokenUsed);



    constructor (string memory _name, address _owner) Ownable(_owner) {



        MS = msg.sender;

        items = new OwnableStoragePointer(address(this));

        name = _name;

    }



    // function destroy() external isOwner {

    //     // We don't assume User contracts to store ether

    //     selfdestruct(payable(address(0x0))); // cast 0x0 to address payable

    // }

    

    function createQuestion(Item _item, string memory _ipfs) external isOwner {

        address _question;

        _question  = _item.createQuestion(MS, _ipfs);

        questions.push(QALibrary.Questions({

            Item: address(_item),

            Time: block.timestamp,

            IPFS: _ipfs

        }));



        emit QuestionCreated(_question);

        

    }



    function addAnswer(Question _question, string memory _ipfs) external isOwner {

        

        _question.addAnswer(MS, _ipfs);

        answers.push(QALibrary.Answers({

            Question: address(_question),

            Time: block.timestamp,

            IPFS: _ipfs

        }));

        uint len = answers.length;

        emit AnswerAdded(answers[len-1]);

    }



    function rateAnswer(Question _question, uint256 _index, uint8 _score) external isOwner {

        require(_score >0 && _score <= 10);

        _question.rateAnswer(_index, MS, _score);

        ratings.push(QALibrary.Rating({

            Question: address(_question),

            answerIndex: _index,

            Time: block.timestamp, 

            Score: _score

        }));

        uint len = ratings.length;

        emit AnswerRated(ratings[len-1]);

    }

    

    function createItem(string memory _name, string memory _nameToken, uint256 _tokenValue ) public isOwner {



        Item item = new Item(_name, owner, MS, _nameToken, _tokenValue);

        items.insert(address(item));



        emit ItemCreated(item);

    }



    function updateReputation() external {

        Question _question = Question(msg.sender);

        require(_question.MS() == MS);

        reputation++;

    }

    // function deleteItem(Item _item) external isOwner {



    //     items.remove(address(_item));

    // }



    // function getItems() external view returns(address[] memory) {



    //     return items.getAssets();

    // }



    // function iAmRegisteredUser() external view returns(bool) {



    //     MainSystem ms = MainSystem(MS);

    //     return ms.isIn(this);

    // }

    

    function isIn(address _item) external view returns(bool) {



        return items.isIn(_item);

    }

    

    // function itemCount() external view returns(uint) {



    //     return items.getCount();

    // }



    function payItem(Item _item) public payable isOwner {

        

        uint _amount = msg.value;

        require(_amount > 0, "The amount must be greater then 0");

        

        uint256 totalTokenAmount = _item.getTokenOwned();

        uint256 actualPayment = _item.getActualPaymentValue();

        // Boring inequalities to checks all possible cases

        if (actualPayment != 0 && _amount >= actualPayment) {

            _item.tokenContract().approve(address(_item), totalTokenAmount);    

            _item.successfulPayment{value: actualPayment}(_amount, totalTokenAmount);

        } else if (actualPayment == 0) {

            totalTokenAmount = _item.value() - _amount;

            _item.tokenContract().approve(address(_item), totalTokenAmount);

            _item.successfulPayment{value: _amount}(_amount, totalTokenAmount); 

        }

        

        emit ItemPaid(this, _item, _amount, totalTokenAmount);

    }



    function withdraw() external isOwner {

        payable(msg.sender).transfer(address(this).balance);

    }

}

