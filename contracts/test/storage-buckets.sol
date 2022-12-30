// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

// Same as UnsafeProxy but using storage buckets.
contract SafeProxy {
    // Storage bucket type. Use _getStorage() to access these fields.
    struct ProxyStorage {
        // Who can upgrade the implementation.
        address owner;
        // The implementation contract.
        address impl;
    }
       mapping(address => ProxyStorage) public proxyStorage;

    // Explicit storage bucket slot. This will be a large number.
    bytes32 constant PROXY_STORAGE_SLOT = keccak256('SafeProxy.ProxyStorage');

    constructor(address impl_, address[] memory allowed) {
        // Call `initialize()` in the implementation immediately.
        (bool s, ) = impl_.delegatecall(abi.encodeCall(Impl.initialize, allowed));
        require(s, 'initialize failed');
        _getStorage().owner = msg.sender;
        _getStorage().impl = impl_;
    }

    function upgrade(address impl_) external {
        require(msg.sender == _getStorage().owner, 'only owner');
        _getStorage().impl = impl_;
    }

    // Forward all calls to the implementation.
    fallback() external payable {
        
        (bool s, bytes memory r) = _getStorage().impl.delegatecall(msg.data);
        if (!s) {
            assembly { revert(add(r, 32), mload(r)) }
        }
        assembly { return(add(r, 32), mload(r)) }
    }

    // Retrieve a storage reference to the storage bucket.
    function _getStorage() private pure returns (ProxyStorage storage stor) {
        bytes32 slot = PROXY_STORAGE_SLOT;
        assembly { stor.slot := slot }
    }
}

// Implementation contract for both SafeProxy and UnsafeProxy.
// Addresses in the isAllowed mapping can call withdraw() to transfer
// ETH out.
contract Impl {
    // If true, initialize() cannot be called.
    bool public isInitialized;
    // Whether an address can call withdraw().
    mapping(address => bool) public isAllowed;

    // Initialize isAllowed so long as isInitialized is false.
    function initialize(address[] calldata allowed) external {
        require(!isInitialized, 'already initialized');
        isInitialized = true;
        for (uint256 i = 0; i < allowed.length; ++i) {
            isAllowed[allowed[i]] = true;
        }
    }

    // Withdraw ETH to an address if the caller is in isAllowed.
    function withdraw(address payable to, uint256 amount) external {
        require(isAllowed[msg.sender], 'not allowed');
        // Transfer entire balance.
        to.transfer(amount);
    }

    receive() external payable {}
}
