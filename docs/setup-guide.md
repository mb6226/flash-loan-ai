# راهنمای نصب

راهنمای گام‌به‌گام برای راه‌اندازی محیط توسعه این پروژه:

1. Clone مخزن
2. نصب وابستگی‌های Python و Node

```powershell
python -m venv venv; .\venv\Scripts\Activate.ps1; pip install -r requirements.txt
npm ci
```

3. تنظیم متغیرهای محیطی: یک فایل `.env` از `.env.example` بسازید و کلیدها را قرار دهید.

4. اجرای تست‌ها (نمونه):

```powershell
pytest -q
npm test
```

5. برای کار با قراردادها: نصب Hardhat/Foundry/Truffle (بسته به pipeline). این repo از کنترلرهای Node برای deploy استفاده می‌کند.

## تنظیم ابزارهای امنیتی (pre-commit, detect-secrets)

برای جلوگیری از اضافه کردن فایل‌های حساس یا کلیدها، ابزارهای `pre-commit` و `detect-secrets` به مخزن اضافه شده‌اند. برای راه‌اندازی محلی، از PowerShell اجرا کنید:

```powershell
.\scripts\setup-security.ps1
```

این اسکریپت:
- نصب `pre-commit`, `detect-secrets` و `truffleHog` (در صورت وجود Python/Internet)
- تولید `.secrets.baseline` و نصب hookهای pre-commit

بعد از راه‌اندازی، `pre-commit` به صورت خودکار روی commitهای شما اجرا می‌شود و CI نیز روی PRها این اسکن‌ها را تضمین می‌کند.

اگر بخواهید سوابق مخزن را برای حذف دایرکتوری‌هایی مثل `.venv` پاک‌سازی کنید، به `docs/history-cleanup.md` مراجعه کنید که دستورالعمل‌های `git filter-repo` و `BFG` را دارد.

