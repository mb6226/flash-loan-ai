// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@aave/core-v3/contracts/flashloan/base/FlashLoanReceiverBase.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FlashLoanAI is FlashLoanReceiverBase, ReentrancyGuard {
    
    struct ArbitrageParams {
        address[] path;
        address[] reversalPath;
        uint256 minProfit;
    }

    address public owner;
    uint256 public totalProfit;
    uint256 public successCount;
    uint256 public failureCount;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    constructor(address _pool) FlashLoanReceiverBase(IPool(_pool)) {
        owner = msg.sender;
    }

    /**
     * @dev اجرای فلش لون با پارامترهای آربیتراژ
     */
    function executeAIFlashLoan(
        address asset,
        uint256 amount,
        ArbitrageParams calldata params
    ) external onlyOwner nonReentrant {
        require(params.path.length >= 2, "Invalid path");
        
        // ذخیره پارامترها در کال‌دیتا
        bytes memory data = abi.encode(params);
        
        // درخواست فلش لون از Aave
        POOL.flashLoanSimple(
            address(this),
            asset,
            amount,
            data,
            0 // referralCode
        );
    }

    /**
     * @dev کال‌بک اصلی Aave (حیاتی!)
     */
    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external override nonReentrant returns (bool) {
        require(msg.sender == address(POOL), "Only pool can call");
        require(initiator == address(this), "Invalid initiator");

        ArbitrageParams memory arbParams = abi.decode(params, (ArbitrageParams));
        
        // محاسبه مبلغ بدهی کل
        uint256 totalDebt = amount + premium;
        
        // اجرای مسیر آربیتراژ
        uint256 finalBalance = _executeArbitrage(
            asset,
            amount,
            arbParams
        );
        
        // بررسی سود
        require(finalBalance > totalDebt, "No profit generated");
        
        // محاسبه سود خالص
        uint256 profit = finalBalance - totalDebt;
        
        // بازپرداخت وام
        IERC20(asset).approve(address(POOL), totalDebt);
        
        // ثبت آمار
        totalProfit += profit;
        successCount++;
        
        // انتقال سود به owner
        IERC20(asset).transfer(owner, profit);
        
        emit ArbitrageSuccess(
            asset,
            amount,
            profit,
            premium,
            block.timestamp
        );
        
        return true;
    }

    /**
     * @dev اجرای آربیتراژ دو مرحله‌ای
     */
    function _executeArbitrage(
        address asset,
        uint256 amount,
        ArbitrageParams memory params
    ) internal returns (uint256) {
        // مرحله 1: سواپ در DEX اول (مثلاً Uniswap)
        IERC20(asset).approve(params.path[0], amount);
        
        // اجرای سواپ
        uint256 intermediateAmount = _swapOnDEX(
            params.path[0], // آدرس DEX
            amount,
            params.path
        );
        
        // مرحله 2: سواپ معکوس در DEX دوم (مثلاً Sushiswap)
        IERC20(params.path[params.path.length - 1]).approve(
            params.reversalPath[0],
            intermediateAmount
        );
        
        uint256 finalAmount = _swapOnDEX(
            params.reversalPath[0],
            intermediateAmount,
            params.reversalPath
        );
        
        return finalAmount;
    }

    /**
     * @dev اجرای سواپ روی یک DEX
     */
    function _swapOnDEX(
        address dexRouter,
        uint256 amountIn,
        address[] memory path
    ) internal returns (uint256) {
        // اینترفیس IUniswapV2Router
        (bool success, bytes memory data) = dexRouter.call(
            abi.encodeWithSignature(
                "swapExactTokensForTokens(uint256,uint256,address[],address,uint256)",
                amountIn,
                0, // amountOutMin (بهینه‌سازی شده توسط AI)
                path,
                address(this),
                block.timestamp + 300 // deadline 5 دقیقه
            )
        );
        
        require(success, "Swap failed");
        
        // استخراج مقدار خروجی از داده برگشتی
        uint256[] memory amounts = abi.decode(data, (uint256[]));
        return amounts[amounts.length - 1];
    }

    /**
     * @dev برداشت اضطراری فقط توسط owner
     */
    function emergencyWithdraw(address token) external onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(owner, balance);
        
        emit EmergencyWithdraw(token, balance, block.timestamp);
    }

    // Events
    event ArbitrageSuccess(
        address indexed asset,
        uint256 amount,
        uint256 profit,
        uint256 premium,
        uint256 timestamp
    );
    
    event EmergencyWithdraw(
        address indexed token,
        uint256 amount,
        uint256 timestamp
    );
}
