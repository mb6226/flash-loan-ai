"""
Data preprocessing utilities used by training notebooks and scripts
"""

import pandas as pd


def normalize_df(df: pd.DataFrame):
    return (df - df.mean()) / (df.std() + 1e-12)
