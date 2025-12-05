// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./interfaces/IUniswapRouter.sol";

contract ArbitrageExecutor {
    IUniswapRouter public router;

    constructor(address routerAddress) {
        router = IUniswapRouter(routerAddress);
    }

    function execute(address[] calldata path, uint256 amountIn, uint256 minOut) external {
        // Placeholder: call router.swapExactTokensForTokens
    }
}
