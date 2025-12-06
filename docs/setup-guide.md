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
