# Flash Loan AI

این پروژه یک ساختار نمونه برای یک سیستم تحلیل و اجرای سفارشات فلش لون در زنجیره‌‌هاست و به زبان فارسی مستند شده است. این مخزن شامل بخش‌های زیر است:

- LAYER 1: Data Ingestion (WebSocket listeners, mempool monitoring)
- LAYER 2: AI Processing Engine (models, training scripts)
- LAYER 3: Decision Making (strategies: arbitrage and liquidation)
- LAYER 4: Execution and Automation (executors, scripts)

نکته‌ها:
- این پروژه صرفا یک اسکلت است و برای محیط تولید بایستی بررسی و تکمیل‌های بیشتری انجام شود.
- قبل از اجرای هر قطعه کد که با قراردادهای هوشمند تعامل دارد از شبکه تست استفاده کنید.

## Quick start

- Install dependencies:

```powershell
pip install -r requirements.txt
npm install
```

- For development, place env variables in `.env` from `.env.example`.

## Requirements
- Node.js (LTS recommended, v18+ required for Hardhat)
- Python 3.11 (recommended for compatibility with TensorFlow, scikit-learn, and scikit dependencies)

If you are using Python 3.13 or newer, some packages like TensorFlow and scikit-learn may not have prebuilt wheels and will fail during installation; use Python 3.11 for best compatibility.

### Installing Node on Windows
If you do not have Node installed, download it from https://nodejs.org/ (LTS recommended). Alternatively, install via Chocolatey (if available) with admin rights:

```powershell
choco install nodejs-lts -y
```

Verify Node & npm are installed:

```powershell
node --version
npm --version
```

Once Node is installed, install Node packages and compile the contracts:

```powershell
npm install
npx hardhat compile
```

### Environment variables
Create a local `.env` file from `.env.example` and fill in your keys:

```
INFURA_KEY=your_infura_free_key
ETHERSCAN_KEY=your_etherscan_key
PRIVATE_KEY=your_testnet_private_key  # use testnet key only
WALLET_ADDRESS=your_wallet_address
TELEGRAM_BOT_TOKEN=your_bot_token
TELEGRAM_CHAT_ID=your_chat_id
FLASHBOTS_SIGNING_KEY=your_flashbots_key (optional)
CONTRACT_ADDRESS=deployed_contract_address (optional)
MIN_PROFIT=0.05
```

Note: Do not commit `.env`. The repo `.gitignore` includes `.env` by default.

### Parameters file (`config/parameters.yaml`)
Adjust values for system parameters like `min_profit_eth`, `max_loan_eth`, `gas_price_limit` and add additional DEX routers or testnet config. Example: to use Goerli for safe testing, validate `goerli` settings in `networks`.

### Dev-only (lighter) dependencies
If you want to install a lighter set of dependencies (e.g., for CI or development without heavy ML packages), use `requirements-lite.txt` which excludes TensorFlow and Keras and may be more compatible with modern Python versions.

- Run tests:

```powershell
npm install
npx hardhat test
pytest tests/test_risk_model.py # Python tests
```
## 🚀 راه‌اندازی سریع (2 دقیقه)

```bash
# 1. Clone
git clone https://github.com/yourusername/flash-loan-ai.git
cd flash-loan-ai

# 2. نصب
npm install
pip install -r requirements.txt

# 3. تنظیمات
cp .env.example .env
# ویرایش .env با کلیدهای API

# 4. تست
npm run test:mvp

# 5. اجرا
npm run start:mvp
```

Or use the provided cross-platform helper script:

```bash
chmod +x startup-scripts/run_mvp.sh
./startup-scripts/run_mvp.sh
```

The `run_mvp.sh` script will:
- Ensure a `data/logs` directory exists and write component logs there.
- Load environment variables from `.env`.
- Check for Node, npm and Python and fail with instructions if missing.
- Start `src/ai/inference.py` (Python) and `src/blockchain/listeners.js` and `src/blockchain/mempool_monitor.js` (Node) in background and trap SIGINT to stop them.

### Quick pre-run check
Before running the MVP, check that Node, npm, and Python are installed and `.env` has required keys.

Windows (PowerShell):
```powershell
.\scripts\check_prereqs.ps1
```

Linux / macOS:
```bash
./scripts/check_prereqs.sh
```

If everything checks out, run: `npm run start:mvp`.

## Automated setup (Windows)
For Windows users, you can run the included PowerShell helper to set up a Python venv and install dependencies. By default it installs a lighter set of dependencies to avoid heavy ML packages:

```powershell
.\scripts\setup_env.ps1 -Lite
# for full install (may take long / require specific Python version & build tools)
.\scripts\setup_env.ps1 -Full
```

### اجرای مولفه‌های NodeJS (مثال برای blockchain listener)

```bash
# نصب وابستگی‌های Node
npm install

# اجرای listener و mempool (NodeJS)
npm run start:blockchain
```


## Windows - Start scripts

On Windows you can use the PowerShell helpers in `startup-scripts/windows` or use the cross-platform Python CLI in `scripts/cli.py`:

```powershell
# Start a single component in new windows (in venv)
./startup-scripts/windows/run_mvp.ps1

# Or use the Python CLI to start all components in new windows
python scripts/cli.py start --component all --new-window --venv .\venv\
```

## Publish repository to GitHub (Create repo from workspace)

You can create a GitHub repo directly from this workspace and push the current branch using the included helper scripts. These scripts work with the GitHub CLI `gh` (recommended) or with a Personal Access Token (via `GITHUB_TOKEN`).

Prerequisites:
- `git` must be installed and available in PATH.
- Either `gh` (GitHub CLI) is installed and logged in, or set `GITHUB_TOKEN` environment variable with `repo` scope.
- Ensure you *do not* commit any credentials (the `.env` file is already in `.gitignore`).

Linux / macOS example (Bash):
```bash
# make script executable if needed
chmod +x scripts/create_github_repo.sh
# create a public repo named 'flash-loan-ai' (or omit -n to use the directory name)
scripts/create_github_repo.sh -n flash-loan-ai -d "Flash Loan AI workspace"
```

Windows (PowerShell) example:
```powershell
# Run with -Private switch to create a private repo
.\scripts\create_github_repo.ps1 -Name flash-loan-ai -Description 'Flash Loan AI workspace'
```

Create a repo inside an organization (if you have permission):
```bash
scripts/create_github_repo.sh -n flash-loan-ai -o my-org -p -d "Private repo inside my-org"
```
```powershell
.\scripts\create_github_repo.ps1 -Name flash-loan-ai -Org my-org -Private -Description 'Private repo inside my-org'
```

If you do not have `gh` installed, the scripts will try to create the repo via the GitHub REST API using `GITHUB_TOKEN`. To create a token:
1. Visit https://github.com/settings/tokens
2. Click "Generate new token" and grant at least the `repo` scope.
3. Export the token as environment variable (Linux/macOS):
```bash
export GITHUB_TOKEN="ghp_YourGeneratedToken"
```
or on Windows (PowerShell):
```powershell
setx GITHUB_TOKEN "ghp_YourGeneratedToken"
```

After creating the repo, the script will set `origin` remote and push the `main` branch.

Warning: Please verify `.gitignore` excludes `.env` and other secret files before pushing to a remote repository.

For detailed step-by-step instructions (including how to generate a PAT, install `gh` and `git`, and set the `GITHUB_TOKEN` environment variable), see `docs/github-account-setup.md`.
For a complete development roadmap, security checklist, and step-by-step instructions for building the project from skeleton to production, see `docs/development-roadmap.md`.

## فایل‌ها

برای لیست کامل ساختار به فایل پروژه نگاه کنید.
