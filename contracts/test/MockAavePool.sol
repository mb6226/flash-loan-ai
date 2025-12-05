// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IFlashLoanReceiver {
    function executeOperation(address asset, uint256 amount, uint256 premium, address initiator, bytes calldata params) external returns (bool);
}

contract MockAavePool {
    function flashLoanSimple(address receiver, address asset, uint256 amount, bytes calldata params, uint16 referralCode) external {
        // Send asset to receiver (assumes pool contract holds tokens)
        IERC20(asset).transfer(receiver, amount);
        // For testing we send zero premium
        IFlashLoanReceiver(receiver).executeOperation(asset, amount, 0, address(this), params);
    }
}
