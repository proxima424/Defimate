// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

contract random{
    uint public a;
    // uint public b;

    function curnum() public view returns(uint){
        return block.number;
    }
    function curhash() public view returns(bytes32){
        uint z=block.number;
        return blockhash(z);
    }

    function gen() public{
        a=block.number;
        // b=block.timestamp;
    }

    function give() public view returns(bytes32){
        require(block.number > a , "wait for max of 12 seconds");
        uint v=block.number;
        return bytes32(blockhash(v));
    }
} 
