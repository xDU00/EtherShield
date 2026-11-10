// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AccessControlVulnerable {
    address public owner;
    uint256 public feeRate;

    constructor() payable {
        owner = msg.sender; 
        feeRate = 1;
    }

    // setting fee rate is vulnerable no check on msg.sender
    function setFeeRate(uint256 _rate) external {
        feeRate = _rate;
    }

    // anyone can become owner
    function setOwner(address _newOwner) external {
        owner = _newOwner;
    }

    // withdraw seems safe (with checking msg sender) but actually not 
    function withdraw() external {
        require(msg.sender == owner, "not owner");
        (bool ok, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(ok, "transfer failed");
    }
}