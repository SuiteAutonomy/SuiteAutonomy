pragma solidity ^0.4.18;

import './PausableToken.sol';


contract CustomToken is PausableToken {
    using SafeMath for uint256;

    string public name = "CustomToken";
    string public symbol = "CustomToken";
    uint256 public decimals = 18;
    uint256 public totalSupply = 20000000 * (10 ** decimals);
    address public beneficiary = ;

    mapping (address => uint256) public spawnWallet;

    function CustomToken() public {
        // initially assign all tokens to the fundsWallet
        spawnWallet[beneficiary] = totalSupply;
    
    }
    function totalSupply() public constant returns (uint256 totalsupply) {
        return totalSupply;
    }
    
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return spawnWallet[_owner];  
    }
}