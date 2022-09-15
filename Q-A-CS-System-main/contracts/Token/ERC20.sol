// SPDX-License-Identifier: SimPL-2.0
pragma solidity >= 0.8.0;

import "./IERC20.sol";

/// @author Samuel Fabrizi
/// @title ERC20
/// @notice This contract represents an ERC20 token  
contract ERC20 is IERC20 {

    address                                         public miner;
	string                                          public name;                    // token name              
    uint256                                         public _totalSupply;            // total supply
    mapping(address => uint256)                     public _balances;               // map of balances
    mapping(address => mapping(address => uint256)) public _allowance;              // map of allowance 
    
    modifier canOperate () {
        require(msg.sender == miner);
        _;
    }

    
    constructor (string memory _name, address _miner) {
        name = _name;
        miner = _miner;
    }

    
    function totalSupply() external view override returns (uint256){
        
        return _totalSupply;
    }

    
    function balanceOf(address account) external view override returns (uint256){

        return _balances[account];
    }


    function allowance(address owner, address spender) external override view returns (uint256){

        return _allowance[owner][spender];
    }


    function transfer(address _to, uint256 _value) public override returns (bool) {
        require(_balances[msg.sender] >= _value);
        
        _balances[msg.sender] = _balances[msg.sender] -= _value;
        _balances[_to] = _balances[_to] += _value;
        
        emit Transfer(msg.sender, _to, _value);
        
        return true;
    }
    

    function approve(address _spender, uint256 _value) public override returns (bool){
        _allowance[msg.sender][_spender] = _value;
        
        emit Approval(msg.sender, _spender, _value);
        
        return true;
    }
    

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool){
        require(_balances[_from] >= _value);
        require(_allowance[_from][msg.sender] >= _value);
        require(msg.sender == _from);

        _balances[_from] = _balances[_from] -= _value;
        _balances[_to] = _balances[_to] += _value;
        
        _allowance[_from][msg.sender] = _allowance[_from][msg.sender] -= _value;
        
        emit Transfer(_from, _to, _value);
        
        return true;
    }

    function Mint(address _to, uint256 _number) external canOperate {
        
        _balances[_to] += _number; 
        
        emit Transfer(address(0x0), _to, _number);
    }


}