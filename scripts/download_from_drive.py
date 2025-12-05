"""
Download dataset from Google Drive. Use with 'gdown' or authenticated API.
"""

import os


def download(id: str, out: str):
    print(f"Downloading {id} to {out}")
