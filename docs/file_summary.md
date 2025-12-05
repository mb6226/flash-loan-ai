# خلاصه محتوای کلیدی فایل‌ها (کوتاه)

این فایل خلاصه‌ی محتوای کلیدی هر فایل/ماژول مهم در مخزن را به صورت کوتاه و به زبان فارسی ارائه می‌کند.

---

- `config/parameters.yaml`
  - تنظیمات سیستم: `system.min_profit_eth`, `system.max_loan_eth`, `system.gas_price_limit`, `system.monitoring_interval`
  - لیست DEXها و `router` آدرس آن‌ها
  - تنظیمات AI: `ai.model_path`, `ai.confidence_threshold`, `ai.risk_max_score`
  - شبکه‌ها: RPC URL ها و آدرس `aave_pool` برای `mainnet` و `goerli`

- `README.md`
  - راهنمای سریع، دستورالعمل نصب و نحوه اجرای تست‌ها و نکات امنیتی

- `package.json`
  - وابستگی‌های Node و اسکریپت‌های npm برای اجرای بخش‌های مختلف

- `requirements.txt`
  - وابستگی‌های Python موردنیاز (web3, pandas, torch, scikit-learn و غیره)

- `.env.example`
  - متغیرهای محیطی پیشنهادی: RPC, Infura key, private key, Telegram token و غیره

- `src/ai/inference.py`
  - ورودی inference برای مدل‌ها و فانکشن‌های پیش‌بینی قیمت/مسیرها

- `src/ai/models/*`
  - مدل‌های نمونه (LSTM, GNN, RandomForest) و `model_loader.py` که لودر مدل‌ها را فراهم می‌کند

- `src/ai/training/*`
  - نوت‌بوک‌های آموزش مدل‌ها و ابزارهای preprocess / feature-engineering

- `src/blockchain/listeners.py`
  - WebSocket listeners برای eventها و داده‌های DEX

- `src/blockchain/mempool_monitor.py`
  - دنبال کردن تراکنش‌های در حال انتظار (pending / mempool)

- `src/blockchain/price_aggregator.py`
  - جمع‌آوری و یکپارچه‌سازی قیمت‌ها از منابع مختلف (DEX‌ها)

- `src/blockchain/executors.py`
  - ساخت و ارسال تراکنش‌ها، مدیریت nonce و برآورد gas

- `src/blockchain/contract_interaction.py`
  - wrapperهای تعامل با قراردادها (call/view و buildTransaction)

- `src/strategies/arbitrage/*`
  - الگوریتم‌های آربیتراژ (DEX cross, cross-chain, triangular)

- `src/strategies/liquidation/*`
  - مکانیزم‌های شناسایی فرصت‌های لیکوئیدیشن و برنامه‌ریزی اجرای flash liquidation

- `src/utils/logger.py`
  - تنظیمات اولیه logging و wrapper ساده

- `src/utils/risk.py`
  - متدهای پایه‌ای ریسک گذاری و محاسبه risk score

- `src/utils/profit_calculator.py`
  - محاسبه سود خالص با در نظر گرفتن هزینه تراکنش

- `src/utils/notification.py`
  - ارسال اعلان‌ها به Telegram/Discord (شبیه‌سازی شده)

- `contracts/*.sol`
  - قراردادهای هوشمند اولیه: `FlashLoanAI.sol`, `MEVProtector.sol`, `ArbitrageExecutor.sol`
  - `contracts/interfaces/*`: اینترفیس‌های Aave/Uniswap

- `scripts/*` و `startup-scripts/*`
  - ابزارهای automation: `trigger_colab.py`, upload/download helperها، و اسکریپت‌های شروعت سیستم (شامل PowerShell helpers برای ویندوز)

- `tests/*`، `tests/integration/*`
  - تست‌های واحد و یکپارچه ابتدایی برای ماژول‌ها و pipeline

- `deployments/*`
  - اسکریپت‌های deploy برای mainnet/testnet و `deployed.json` برای نگه‌داشت آدرس‌ها

---

> نکته: این خلاصه برای توسعه‌دهندگان ساخته شده تا سریع به محتوای اصلی هر فایل مسلط شوند. جزئیات پیاده‌سازی (متدها، پارامترها) داخل هر فایل وجود دارد و باید برای تولید تکمیل و بررسی شود.
