// SPDX-License-Identifier: SimPL-2.0

pragma solidity >=0.8.0;



import "./Interfaces.sol";

import "./User.sol";

import "./Main.sol";

import "./AssetStorage.sol";

import "./Token/ERC20.sol";

import "./Question.sol";



contract Item is Permissioned {



    // Data

    string                  public  name;                // Item nickname

    address                 public  MS;                  // The MainSystem the Item belongs to

    ERC20                   public  tokenContract;       // Item token contract address

    uint256                 public  value;  

    OwnableStoragePointer   private questions;

    // Events

    event SuccessfulPayment(Item _item, User _user, uint _amount, uint256 _numberOfToken);

    event NewQuestion(Question _question);

   

    constructor (string memory _name,             

                 address _owner,            

                 address _ms,

                 string memory _nameToken,

                 uint256 _value

                 )               

                 Permissioned(_owner) {



        require(_value > 0);

        MS = _ms;

        name = _name;

        questions = new OwnableStoragePointer(address(this));

        tokenContract = new ERC20(_nameToken, address(this));

        value = _value;

    }



    // function destroy() external isOwner {

    //     // We don't assume User contracts to store ether

    //     selfdestruct(payable(address(0x0))); // cast 0x0 to address payable

    // }



    // function grantPermission(address _to) public override isOwner {



    //     // Check if the User and this Item belong to the same RSF

    //     User u = User(_to);

    //         // Require sender is User of RSF

    //     require(u.iAmRegisteredUser());

    //         // Require User's RSF == my RSF

    //     require(u.MS() == MS);

    //     require(u.owner() != owner);



    //     // Call parent

    //     super.grantPermission(_to);

    // }



    function createQuestion(address _ms, string memory _ipfs) external returns(address) {

        require(_ms == MS);

        Item _item = Item(address(this));

        MainSystem ms = MainSystem(MS);

        require(ms.isIn(User(msg.sender)));

        Question question = new Question(MS, _item, _ipfs);

        questions.insert(address(question));

        issueToken(address(question), 300);

        

        emit NewQuestion(question);



        return address(question);

    }





    function successfulPayment(uint _amount, uint256 _totalTokenAmount) external payable{

        User _user = User(msg.sender);

        MainSystem ms = MainSystem(MS);

        require(ms.isIn(_user) == true);

        require(_amount + _totalTokenAmount == value);

        require(msg.value == _amount && _amount > 0);

              

        if (_amount > 0){

            address payable ownerItem = payable(owner);

            ownerItem.transfer(_amount);

        }

        if (_totalTokenAmount > 0) {

            tokenContract.transferFrom(address(_user), address(this), _totalTokenAmount);

        }

        

        grantPermission(address(_user));   

        emit SuccessfulPayment(this, _user, _amount, _totalTokenAmount);

    }

    

    



    function getActualPaymentValue() external view returns(uint256){

        uint _balance = tokenContract.balanceOf(msg.sender);

        if (_balance >= value) {

            return 0;

        } else {

            return value - _balance;

        } 

    }



    function getTokenOwned() external view returns(uint256){



        return tokenContract.balanceOf(msg.sender);

    }



    function issueToken(address _to, uint256 _numberOfToken) private {



        tokenContract.Mint(_to, _numberOfToken);

    }



    fallback() external {}





}

