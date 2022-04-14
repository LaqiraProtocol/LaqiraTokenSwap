// SPDX-License-Identifier: MIT
// Swap paused deprecated tokens with new ones, Developed by Laqira Protocol team

pragma solidity ^0.8.0;

interface IBEP20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface ISwapDeprecatedTokens {
    function isSwapped(address _holder) external view returns (bool); 
} 

contract SwapDeprecatedTokensV2 {
    IBEP20 private immutable _deprecatedTokens;
    
    IBEP20 private immutable _newTokens;

    ISwapDeprecatedTokens private immutable _oldContract;
    
    mapping(address => bool) private userSwapped;
    
    address public owner;
    
    constructor(IBEP20 deprecatedTokens_, IBEP20 newTokens_, ISwapDeprecatedTokens oldContract_) {
        _deprecatedTokens = deprecatedTokens_;
        _newTokens = newTokens_;
        _oldContract = oldContract_;
        owner = msg.sender;
    }
    
    function usersTokenSwap() public returns (bool) {
        address _holder = msg.sender; 
        require(!isSwapped(_holder), "User has swapped deprecated tokens already or is not allowed");
        bool _oldContract_isSwapped = oldContract().isSwapped(_holder);
        require(!_oldContract_isSwapped, "User has swapped deprecated tokens already in old contract");
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

    function oldContract() public view returns (ISwapDeprecatedTokens) {
        return _oldContract;
    }
    
    function isSwapped(address _holder) public view returns (bool) {
        return userSwapped[_holder] || oldContract().isSwapped(_holder);
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

    function transferOwnership(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not the owner");
        _;
    }
}