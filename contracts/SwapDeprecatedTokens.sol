// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IBEP20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract SwapDeprecatedTokens {
    IBEP20 private immutable _deprecatedTokens;
    
    IBEP20 private immutable _newTokens;
    
    mapping(address => bool) private userSwapped;
    
    address public owner;
    
    constructor(IBEP20 deprecatedTokens_, IBEP20 newTokens_) {
        _deprecatedTokens = deprecatedTokens_;
        _newTokens = newTokens_;
        owner = msg.sender;
    }
    
    function usersTokenSwap() public returns (bool) {
        address _holder = msg.sender; 
        require(!isSwapped(_holder), "User has swapped deprecated tokens or is not allowed");
        uint256 depTokenBalance = depToken().balanceOf(_holder);
        newToken().transfer(_holder, depTokenBalance);
        userSwapped[_holder] = true;
        return true;
    }
    
    function newToken() public view returns (IBEP20) {
        return _newTokens;
    }
    
    function depToken() public view returns (IBEP20) {
        return _deprecatedTokens;
    }
    
    function isSwapped(address _holder) public view returns (bool) {
        return userSwapped[_holder];
    }
    
    function excludeAddress(address _holder) public onlyOwner {
        userSwapped[_holder] = true;
    }
    
    function includeAddress(address _holder) public onlyOwner {
        userSwapped[_holder] = false;
    }
    
    function transferAnyBEP20(address _tokenAddress, address _to, uint256 _amount) public onlyOwner returns (bool) {
        IBEP20(_tokenAddress).transfer(_to, _amount);
        return true;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not the owner");
        _;
    }
}