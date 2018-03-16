pragma solidity ^0.4.19;

import './CustomToken.sol';


contract TokenFactory {

    function createContract(string Name, string Symbol,uint256 TotalSupply, uint8 Decimals, address WalletAddress) public returns(address created) 
    {
        return new CustomToken( Name, Symbol,TotalSupply, Decimals, WalletAddress);
    }
}