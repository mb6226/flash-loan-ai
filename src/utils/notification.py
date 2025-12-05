"""
Notification utilities for Telegram and Discord
"""
import os

TELEGRAM_TOKEN = os.environ.get('TELEGRAM_BOT_TOKEN')
TELEGRAM_CHAT_ID = os.environ.get('TELEGRAM_CHAT_ID')


def send_telegram(message: str):
    # placeholder: use requests to call telegram API
    print(f"Telegram -> {message}")


def send_discord(message: str):
    print(f"Discord -> {message}")
