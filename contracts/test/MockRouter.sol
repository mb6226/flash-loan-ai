// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MockRouter {
    // price is scaled by 1e18: price = tokenOut / tokenIn
    uint256 public priceScaled; // e.g., 2000 * 1e18 for 2000 USDC per ETH

    function setPriceScaled(uint256 p) public {
        priceScaled = p;
    }

    // swapExactTokensForTokens signature
    function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts) {
        // Determine tokenIn and tokenOut from the end of the path (allow path[0] workaround)
        address tokenIn = path[path.length - 2];
        address tokenOut = path[path.length - 1];

        // Pull tokens from caller (FlashLoan receiver)
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);

        // simplistic conversion: amountOut = amountIn * priceScaled / 1e18
        uint256 amountOut = (amountIn * priceScaled) / (1 ether);

        // Mint tokenOut to the destination (MockToken supports mint)
        // We assume tokenOut is MockToken which implements mint
        (bool ok, ) = tokenOut.call(abi.encodeWithSignature("mint(address,uint256)", to, amountOut));
        require(ok, "Mint failed");

        amounts = new uint256[](2);
        amounts[0] = amountIn;
        amounts[1] = amountOut;
        return amounts;
    }
}
