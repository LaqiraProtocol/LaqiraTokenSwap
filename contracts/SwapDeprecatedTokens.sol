// SPDX-License-Identifier: MIT
// Swap paused deprecated tokens with new ones, Developed by Laqira Protocol team

pragma solidity ^0.8.0;

interface IBEP20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract SwapDeprecatedTokens {
    IBEP20 private immutable _deprecatedTokens;
    IBEP20 private immutable _newTokens;
    address public owner;
    
    mapping(address => bool) private userSwapped;
    mapping(address => bool) private excluded;
    
    constructor(IBEP20 deprecatedTokens_, IBEP20 newTokens_, address _owner) {
        _deprecatedTokens = deprecatedTokens_;
        _newTokens = newTokens_;
        owner = _owner;
    }
    
    function usersTokenSwap() external returns (bool) {
        address _holder = msg.sender; 
        require(!isSwapped(_holder), "User has swapped already");
        require(!isExcluded(_holder), "User has been excluded");
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

    function isExcluded(address _holder) public view returns (bool) {
        return excluded[_holder];
    }
    
    function excludeAddress(address _holder) external onlyOwner {
        excluded[_holder] = true;
    }
    
    function includeAddress(address _holder) external onlyOwner {
        excluded[_holder] = false;
    }
    
    function transferAnyBEP20(address _tokenAddress, address _to, uint256 _amount) external onlyOwner returns (bool) {
        IBEP20(_tokenAddress).transfer(_to, _amount);
        return true;
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not the owner");
        _;
    }
}
