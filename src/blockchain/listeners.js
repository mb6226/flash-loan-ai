require('dotenv').config();
const { ethers } = require('ethers');
const axios = require('axios');

class BlockchainListener {
  constructor() {
    // اتصال به Infura Free Tier
    this.provider = new ethers.providers.WebSocketProvider(
      `wss://mainnet.infura.io/ws/v3/${process.env.INFURA_KEY}`
    );

    this.wallet = new ethers.Wallet(process.env.PRIVATE_KEY, this.provider);

    // قراردادهای DEX (Uniswap V2 روتر)
    this.uniswapRouter = new ethers.Contract(
      "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D",
      [
        "function getAmountsOut(uint amountIn, address[] path) view returns (uint[] amounts)",
        "function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] path, address to, uint deadline) returns (uint[] amounts)"
      ],
      this.provider
    );

    this.sushiswapRouter = new ethers.Contract(
      "0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F",
      [
        "function getAmountsOut(uint amountIn, address[] path) view returns (uint[] amounts)"
      ],
      this.provider
    );

    this.WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
    this.USDC = "0xA0b86a33E6441b7B5B5c0e3e9F6F9d1e4C5b5c5c";

    console.log("🎧 Blockchain listener started...");
  }

  // مانیتور قیمت‌ها هر 5 ثانیه
  startPriceMonitoring() {
    setInterval(async () => {
      try {
        const opportunity = await this.findArbitrageOpportunity();

        if (opportunity && opportunity.profit > 0.01) { // > 1% profit
          console.log("🎯 Opportunity found:", opportunity);

          // ارسال به استراتژی
          const arbitrage = require('../strategies/arbitrage/dex_arbitrage');
          await arbitrage.execute(opportunity, this.wallet);
        }
      } catch (error) {
        console.error("❌ Error in monitoring:", error.message);
      }
    }, 5000);
  }

  // شناسایی آربیتراژ بین Uniswap و Sushiswap
  async findArbitrageOpportunity() {
    const amountIn = ethers.utils.parseEther("1"); // 1 ETH

    try {
      // قیمت در Uniswap
      const uniAmounts = await this.uniswapRouter.getAmountsOut(
        amountIn,
        [this.WETH, this.USDC]
      );

      // قیمت در Sushiswap
      const sushiAmounts = await this.sushiswapRouter.getAmountsOut(
        amountIn,
        [this.WETH, this.USDC]
      );

      const uniPrice = parseFloat(ethers.utils.formatUnits(uniAmounts[1], 6));
      const sushiPrice = parseFloat(ethers.utils.formatUnits(sushiAmounts[1], 6));

      // محاسبه اختلاف
      const priceDiff = ((sushiPrice - uniPrice) / uniPrice) * 100;

      if (priceDiff > 1.0) { // بیش از 1% اختلاف
        return {
          type: "DEX_ARBITRAGE",
          direction: "uni->sushi",
          profit: priceDiff,
          path: [this.WETH, this.USDC],
          amountIn: amountIn.toString(),
          expectedOut: sushiAmounts[1].toString(),
          timestamp: Date.now()
        };
      }

      return null;
    } catch (error) {
      console.error("❌ Error fetching prices:", error.message);
      return null;
    }
  }

  // مانیتور Mempool برای فرصت‌های فرانت‌ران
  monitorMempool() {
    this.provider.on("pending", async (txHash) => {
      try {
        const tx = await this.provider.getTransaction(txHash);

        if (tx && tx.to && tx.value.gt(ethers.utils.parseEther("10"))) {
          console.log("🔍 Large transaction detected:", {
            hash: txHash,
            value: ethers.utils.formatEther(tx.value),
            to: tx.to
          });

          // تحلیل تأثیر احتمالی
          this.analyzeTxImpact(tx);
        }
      } catch (error) {
        // نادیده گرفتن تراکنش‌های خراب
      }
    });
  }

  async analyzeTxImpact(transaction) {
    // اینجا می‌توانید منطق پیشرفته AI اضافه کنید
    console.log("🤖 AI analyzing transaction impact...");
  }

  // Execute an arbitrage via the configured strategy
  async executeFlashLoan(opportunity, wallet = null) {
    try {
      const arbitrage = require('../strategies/arbitrage/dex_arbitrage');
      const execWallet = wallet || this.wallet;
      await arbitrage.execute(opportunity, execWallet);
    } catch (err) {
      console.error('❌ Error executing arbitrage:', err.message || err);
      throw err;
    }
  }
}

module.exports = BlockchainListener;

// If the file is run directly, start monitoring
if (require.main === module) {
  const listener = new BlockchainListener();
  listener.startPriceMonitoring();
  listener.monitorMempool();
}
