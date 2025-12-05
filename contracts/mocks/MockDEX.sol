// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MockDEX {
    mapping(address => mapping(address => uint256)) public prices;
    
    function setPrice(address tokenA, address tokenB, uint256 price) external {
        prices[tokenA][tokenB] = price;
        prices[tokenB][tokenA] = (1e36) / price; // inverse price: keep 1e18 precision
    }
    
    function getAmountsOut(uint256 amountIn, address[] memory path) external view returns (uint256[] memory amounts) {
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        
        for (uint i = 1; i < path.length; i++) {
            uint256 price = prices[path[i-1]][path[i]];
            require(price > 0, "Price not set");
            // price is scaled by 1e18: amountOut = amountIn * price / 1e18
            amounts[i] = (amounts[i-1] * price) / 1e18;
        }
    }
}
