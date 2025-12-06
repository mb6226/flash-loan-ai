const BlockchainListener = require('./blockchain/listeners');
const logger = require('./utils/logger');

/**
 * روش پیشنهادی: شروع بدون AI
 * فقط قوانین ساده:
 * - اگر اختلاف > 1% → اجرا
 * - اگر گس < 50 gwei → اجرا
 * - اگر نقدینگی > 100k → اجرا
 */

class SimpleBot {
  constructor() {
    this.listener = new BlockchainListener();
    this.isRunning = false;
  }

  async start() {
    console.log(`
┌─────────────────────────────────────────────┐
│  Flash Loan AI - MVP (No AI Mode)          │
│  📊 Rule-Based Arbitrage Detection         │
│  💰 Min Profit: 1%                         │
│  ⛽ Max Gas: 50 gwei                       │
│  🔓 Press Ctrl+C to stop                   │
└─────────────────────────────────────────────┘
    `);

    this.isRunning = true;

    // مانیتورینگ هر 5 ثانیه
    setInterval(async () => {
      if (!this.isRunning) return;

      try {
        const opportunity = await this.listener.findArbitrageOpportunity();

        if (opportunity) {
          logger.info("🎯 Opportunity detected", opportunity);

          // تصمیم‌گیری ساده (بدون AI)
          const shouldExecute = this.simpleDecision(opportunity);

          if (shouldExecute) {
            logger.info("⚡ Executing based on rules");
            await this.listener.executeFlashLoan(opportunity);
          }
        }
      } catch (error) {
        logger.error("System error", { message: error.message });
      }
    }, 5000);
  }

  /**
   * تصمیم‌گیری ساده بدون AI
   */
  simpleDecision(opportunity) {
    const rules = {
      minProfit: 1.0,      // 1% minimum
      maxGas: 50,          // 50 gwei
      minLiquidity: 100000 // $100k
    };

    // Rule 1: Profit threshold
    if (opportunity.profit < rules.minProfit) {
      logger.warn("Rule failed: Profit too low", { profit: opportunity.profit });
      return false;
    }

    // Rule 2: Gas price check
    if (opportunity.gasPrice > rules.maxGas) {
      logger.warn("Rule failed: Gas too high", { gas: opportunity.gasPrice });
      return false;
    }

    // Rule 3: Liquidity check
    if (opportunity.liquidity < rules.minLiquidity) {
      logger.warn("Rule failed: Low liquidity", { liquidity: opportunity.liquidity });
      return false;
    }

    logger.info("✅ All rules passed");
    return true;
  }

  stop() {
    this.isRunning = false;
    logger.info("🛑 Bot stopped gracefully");
    process.exit(0);
  }
}

// اجرا
const bot = new SimpleBot();

process.on('SIGINT', () => {
  bot.stop();
});

bot.start().catch(err => {
  logger.error("Fatal error", { message: err.message });
  process.exit(1);
});
console.log('Flash Loan AI entry point - choose a script to run (see package.json)');
