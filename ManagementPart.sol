pragma solidity ^0.6.6;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./UniPart.sol";


contract ManagementPart is  UniPart {
    using SafeMath for uint256;
    using Address for address;

    address public uniPair;
    mapping (address => bool) public _whiteList;
    mapping (address => bool) public _frozenAccount;

  
    event FrozenAccountEvent(address account, bool frozen);
    event ChangeWhiteListEvent(address account, bool isWhite);
   

    function addWhiteList(address _user) public onlyOwner {
        require(_user != address(0), "Ownable: new owner is the zero address");
        require(_frozenAccount[msg.sender] != true, "sender was frozen" );
        _whiteList[_user] = true;
        emit ChangeWhiteListEvent( _user, true);
    }

    function removeWhiteList(address _user) public onlyOwner {
        require(_user != address(0), "Ownable: new owner is the zero address");
        require(_frozenAccount[msg.sender] != true, "sender was frozen" );
        _whiteList[_user] = false;
         emit ChangeWhiteListEvent( _user, false);
    }

    function freezeAccount(address target, bool freeze) public onlyOwner {
        
        _frozenAccount[target] = freeze;
        emit FrozenAccountEvent( target, freeze);
    }



    function isWhiteList(address account) public view  returns (bool) {
        return _whiteList[account];
    }


    
   
}