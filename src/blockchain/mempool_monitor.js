require('dotenv').config();
// Basic Node.js placeholder for mempool monitoring (lightweight version)
const { ethers } = require('ethers');

class MempoolMonitor {
  constructor() {
    this.provider = new ethers.providers.WebSocketProvider(`wss://mainnet.infura.io/ws/v3/${process.env.INFURA_KEY}`);
  }

  start() {
    this.provider.on('pending', async (txHash) => {
      try {
        const tx = await this.provider.getTransaction(txHash);
        if (tx && tx.value && tx.value.gt(ethers.utils.parseEther('10'))) {
          console.log('🔍 Large transaction detected (node):', txHash, ethers.utils.formatEther(tx.value));
        }
      } catch (err) {
        // ignore
      }
    });
  }
}

module.exports = MempoolMonitor;

if (require.main === module) {
  const mm = new MempoolMonitor();
  mm.start();
}
