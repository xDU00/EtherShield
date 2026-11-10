// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AccessControlFixed {
    address public owner;
    uint256 public feeRate;

    error NotOwner();
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    constructor() payable {
        owner = msg.sender;
        feeRate = 1;
    }

    // fixed by adding onlyOwner 
    function setFeeRate(uint256 _rate) external onlyOwner {
        feeRate = _rate;
    }

    // fixed by adding onlyOwner added and zero address rejected
    function setOwner(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "zero address");
        emit OwnerChanged(owner, _newOwner);
        owner = _newOwner;
    }

    function withdraw() external onlyOwner {
        (bool ok, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(ok, "transfer failed");
    }
}