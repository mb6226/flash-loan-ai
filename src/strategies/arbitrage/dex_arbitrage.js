const { ethers } = require('ethers');
const axios = require('axios');

class DEXArbitrageStrategy {
  constructor() {
    this.provider = new ethers.providers.JsonRpcProvider(
      `https://mainnet.infura.io/v3/${process.env.INFURA_KEY}`
    );

    this.wallet = new ethers.Wallet(process.env.PRIVATE_KEY, this.provider);

    // قرارداد فلش لون (Aave V3)
    this.pool = new ethers.Contract(
      "0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2",
      [
        "function flashLoanSimple(address receiver, address asset, uint256 amount, bytes calldata params, uint16 referralCode) external"
      ],
      this.wallet
    );

    // روترهای DEX
    this.uniswap = new ethers.Contract(
      "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D",
      [
        "function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts)"
      ],
      this.wallet
    );

    this.sushiswap = new ethers.Contract(
      "0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F",
      [
        "function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts)"
      ],
      this.wallet
    );
  }

  // اجرای آربیتراژ با فلش لون
  async execute(opportunity, wallet) {
    try {
      console.log("🚀 Executing arbitrage:", opportunity);

      // محاسبه سود خالص
      const gasEstimate = await this.estimateGas();
      const profitAfterGas = this.calculateNetProfit(
        opportunity.profit,
        gasEstimate
      );

      if (profitAfterGas < parseFloat(process.env.MIN_PROFIT || "0.05")) {
        console.log("⚠️ Profit too low after gas:", profitAfterGas);
        return false;
      }

      // پارامترهای فلش لون
      // Use a reversed copy so we don't mutate original opportunity.path
      const reversePath = Array.from(opportunity.path).slice().reverse();
      const expectedOutBN = ethers.BigNumber.from(opportunity.expectedOut.toString());

      const params = ethers.utils.defaultAbiCoder.encode(
        ["address[]", "address[]", "uint256"],
        [opportunity.path, reversePath, expectedOutBN]
      );

      // اجرای فلش لون
      const tx = await this.pool.flashLoanSimple(
        process.env.CONTRACT_ADDRESS, // آدرس قرارداد اجراگر
        opportunity.path[0], // asset (مثلاً WETH)
        ethers.BigNumber.from(opportunity.amountIn.toString()),
        params,
        0,
        {
          gasLimit: 500000,
          gasPrice: await this.provider.getGasPrice()
        }
      );

      console.log("📤 Flash loan submitted:", tx.hash);

      // منتظر تأیید
      const receipt = await tx.wait();
      console.log("✅ Transaction confirmed:", receipt.status);

      if (receipt && receipt.status === 1) {
        // لاگ سود
        this.logProfit(opportunity, receipt);
        return true;
      }

      return false;
    } catch (error) {
      console.error("❌ Execution failed:", error && error.message ? error.message : error);
      return false;
    }
  }

  // محاسبه سود خالص
  calculateNetProfit(grossProfit, gasCost) {
    const grossProfitETH = parseFloat(grossProfit) * 0.01; // فرض کن 1% = 0.01 ETH
    const gasCostETH = parseFloat(ethers.utils.formatEther(gasCost));
    return grossProfitETH - gasCostETH;
  }

  // تخمین کارمزد گس
  async estimateGas() {
    const gasPrice = await this.provider.getGasPrice();
    const gasLimit = 500000; // تخمین برای فلش لون + 2 سواپ
    return gasPrice.mul(gasLimit);
  }

  // لاگ سود برای تحلیل
  logProfit(opportunity, receipt) {
    const profitData = {
      timestamp: Date.now(),
      type: opportunity.type,
      profit_percent: opportunity.profit,
      tx_hash: receipt.transactionHash,
      gas_used: receipt.gasUsed ? receipt.gasUsed.toString() : '0',
      block_number: receipt.blockNumber
    };

    // ارسال به Telegram
    this.sendNotification(profitData).catch((err) => {
      console.error('⚠️ Notification failed:', err && err.message ? err.message : err);
    });

    // ذخیره لوکال
    const fs = require('fs');
    const path = './data/profit_logs.json';
    try {
      fs.appendFileSync(path, JSON.stringify(profitData) + '\n');
    } catch (err) {
      console.error('⚠️ Failed to write profit log:', err && err.message ? err.message : err);
    }
  }

  async sendNotification(data) {
    if (!process.env.TELEGRAM_BOT_TOKEN || !process.env.TELEGRAM_CHAT_ID) {
      console.warn('⚠️ Telegram config not provided; skipping notification');
      return;
    }

    const message = `\n    💰 Flash Loan Profit Executed!\n    Profit: ${data.profit_percent}%\n    Tx Hash: ${data.tx_hash}\n    Gas Used: ${data.gas_used}\n    `;

    await axios.post(
      `https://api.telegram.org/bot${process.env.TELEGRAM_BOT_TOKEN}/sendMessage`,
      {
        chat_id: process.env.TELEGRAM_CHAT_ID,
        text: message
      }
    );
  }
}

module.exports = new DEXArbitrageStrategy();

// Optionally: auto-run if executed directly
if (require.main === module) {
  (async () => {
    const strat = new DEXArbitrageStrategy();
    console.log('DEX Arbitrage strategy loaded - manual run');
  })();
}
// Simple NodeJS placeholder for arbitrage execution
module.exports = {
  async execute(opportunity, wallet) {
    console.log('Executing arbitrage (placeholder)', opportunity);
    // In a real implementation, build and send transactions using wallet
    return { success: true };
  }
};
