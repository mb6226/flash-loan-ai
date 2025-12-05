# راهنمای تنظیم حساب GitHub و آماده‌سازی محیط برای اجرای اسکریپت‌های انتشار

در این راهنما گام‌به‌گام نحوه‌ی آماده‌سازی حساب GitHub و محیط محلی شما را برای اجرای اسکریپت‌های `create_github_repo` توضیح می‌دهم.

نکتهٔ مهم: هرگز توکن یا رمز عبور خود را در این چت قرار ندهید. این راهنما راهنمایی می‌کند تا توکن را در محیط خودتان تنظیم کنید و سپس می‌توانید از اسکریپت‌ها در همین مخزن استفاده کنید.

1) ساخت حساب GitHub
- اگر حساب GitHub ندارید: به https://github.com/join رفته و ثبت‌نام کنید.

2) نصب Git (Windows)
- راه پیشنهادی: از winget یا نصبگر رسمی استفاده کنید.
  - با winget:
  ```powershell
  winget install --id Git.Git -e --source winget
  ```
  - یا از https://git-scm.com/downloads دانلود و نصب کنید.

3) نصب GitHub CLI (gh)
- gh کار را ساده می‌کند و به‌خاطر این اسکریپت توصیه می‌شود. نصب با winget:
```powershell
winget install --id GitHub.cli -e --source winget
```
یا با Chocolatey:
```powershell
choco install gh -y
```

4) پیکربندی Git (نام و ایمیل)
```powershell
git config --global user.name "نام شما"
git config --global user.email "you@example.com"
```

5) لاگین با gh (توصیه‌شده):
```powershell
gh auth login
```
این دستور مرورگر را باز می‌کند و از شما می‌پرسد که می‌خواهید با SSH یا HTTPS وارد شوید. اگر می‌خواهید از HTTPS و توکن استفاده کنید، آن را انتخاب کنید. بعد از اتمام، `gh` شما را به حساب GitHub متصل می‌کند.

6) (اختیاری) ساخت SSH key و نصب در GitHub
- اگر می‌خواهید با SSH کار کنید:
```powershell
ssh-keygen -t ed25519 -C "you@example.com"
Get-Content ~/.ssh/id_ed25519.pub | clip
# سپس محتوی public key را در GitHub Settings -> SSH and GPG keys -> Add new
```

7) ساخت Personal Access Token (اگر از gh استفاده نمی‌کنید یا می‌خواهید از REST API داخل اسکریپت استفاده کنید)
- در مرورگر به https://github.com/settings/tokens بروید.
- روی "Generate new token" یا "Generate new token (classic)" کلیک کنید (برای REST باید "repo" را انتخاب کنید).
- اسکوپ `repo` را اضافه کنید (برای ساخت repo و push کردن لازم است).
- توکن را ذخیره کنید. توجه: فقط یک بار نشان داده می‌شود.

8) تنظیم متغیر محیطی `GITHUB_TOKEN` (ویندوز)
- موقت (فقط جلسهٔ جاری PowerShell):
```powershell
$env:GITHUB_TOKEN = "ghp_..."
```
- دائمی (با استفاده از setx):
```powershell
setx GITHUB_TOKEN "ghp_..."
# بعد از setx، یک پنجرهٔ جدید PowerShell باز کنید تا مقدار در محیط در دسترس قرار گیرد
```

9) اعتبارسنجی و بررسی
- بررسی نصب‌ها:
```powershell
git --version
gh --version
$env:GITHUB_TOKEN # فقط برای بررسی در همان جلسه
```
اگر خروجی‌ای دیدید که با نسخه‌ها مرتبط است، به مرحلهٔ بعد بروید.

10) اجرای اسکریپت `create_github_repo` (PowerShell)
- مثال اجرای اسکریپت با نام repo:
```powershell
.\scripts\create_github_repo.ps1 -Name flash-loan-ai -Description 'Flash Loan AI workspace' -Private
```
- اگر می‌خواهید در داخل یک سازمان (Organization) بسازید:
```powershell
.\scripts\create_github_repo.ps1 -Name flash-loan-ai -Org my-org -Private -Description 'Repo in my-org'
```

11) با استفاده از `gh` (اختیاری)
- اگر `gh` نصب و لاگین دارید، می‌توانید مستقیماً دستور `gh` را اجرا کنید:
```powershell
gh repo create my-org/flash-loan-ai --private --source=. --remote=origin --push --confirm
```

12) نکات امنیتی
- توکن (GITHUB_TOKEN) را هرگز در چت یا سیستم‌های عمومی قرار ندهید.
- حتما قبل از push بررسی کنید که `.env` و فایل‌هایی که اسرار دارند در `.gitignore` گنجانده شده‌اند.

13) پس از ساخت repo
- اسکریپت `create_github_repo` به طور خودکار remote origin را تنظیم و روی شاخهٔ `main` push می‌کند.
  - اگر می‌خواهید یک branch نام دیگر داشته باشد، بعد از push می‌توانید در repo تغییر دهید یا قبل push نام شاخه را عوض کنید:
  ```powershell
  git branch -M main
  git push -u origin main
  ```

نکته: اگر خواستید من فوراً اسکریپت را اجرا کنم، پس از این‌که `GITHUB_TOKEN` را در محیط ست کردید یا با `gh` لاگین کردید، فقط بگویید تا من اجرا کنم. من هرگز از شما توکن را در چت نخواهم خواست و هیچ اطلاعات محرمانه‌ای ذخیره نمی‌کنم.

پایان راهنما
