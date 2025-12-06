const fs = require('fs');
const path = require('path');

class Logger {
  constructor() {
    this.logsDir = path.join(__dirname, '../../data/logs');
    this.ensureLogsDir();
  }

  ensureLogsDir() {
    if (!fs.existsSync(this.logsDir)) {
      fs.mkdirSync(this.logsDir, { recursive: true });
    }
  }

  log(level, message, data = {}) {
    const timestamp = new Date().toISOString();
    const logEntry = {
      timestamp,
      level,
      message,
      data
    };

    // لاگ به کنسول
    console.log(`[${timestamp}] ${level.toUpperCase()}: ${message}`, data);

    // لاگ به فایل
    const logFile = path.join(this.logsDir, `${new Date().toISOString().split('T')[0]}.jsonl`);
    fs.appendFileSync(logFile, JSON.stringify(logEntry) + '\n');
  }

  info(message, data) {
    this.log('info', message, data);
  }

  warn(message, data) {
    this.log('warn', message, data);
  }

  error(message, data) {
    this.log('error', message, data);
  }

  profit(amount, type) {
    this.log('profit', `💰 Profit of ${amount} ETH from ${type}`);
  }

  logSystemStatus() {
    // اینجا می‌توانید آمار سیستم را لاگ کنید
    this.info("System status check", {
      uptime: process.uptime(),
      memory: process.memoryUsage()
    });
  }

  logFinalStats() {
    this.info("Final statistics", {
      totalUptime: process.uptime(),
      terminationTime: new Date().toISOString()
    });
  }
}

module.exports = new Logger();
