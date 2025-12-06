require('dotenv').config();
// Pre-flight env check
const requiredEnv = ['INFURA_KEY', 'PRIVATE_KEY', 'WALLET_ADDRESS'];
const missing = requiredEnv.filter((k) => !process.env[k]);
if (missing.length > 0) {
  console.error('Missing required environment variables:', missing.join(', '));
  console.error('Please copy .env.example to .env and fill in the missing keys, then re-run.');
  process.exit(1);
}
const BlockchainListener = require('../blockchain/listeners');
const logger = require('../utils/logger');

async function startMVP() {
  console.log(`
  🚀 Flash Loan AI - MVP Mode Starting...
  ======================================
  📊 Monitoring: Uniswap <> Sushiswap
  💰 Min Profit: 0.05 ETH
  ⛽ Gas Limit: 50 gwei
  🕐 Interval: 5 seconds
  ======================================
  `);

  try {
    const listener = new BlockchainListener();

    // شروع مانیتورینگ
    listener.startPriceMonitoring();

    // مانیتور Mempool (اختیاری برای MVP)
    // listener.monitorMempool();

    // لاگ دوره‌ای
    setInterval(() => {
      logger.logSystemStatus();
    }, 60000); // هر 1 دقیقه

  } catch (error) {
    console.error("❌ Fatal error:", error);
    process.exit(1);
  }
}

// هندل کردن SIGINT (Ctrl+C)
process.on('SIGINT', () => {
  console.log("\n🛑 Shutting down gracefully...");
  logger.logFinalStats();
  process.exit(0);
});

startMVP();
