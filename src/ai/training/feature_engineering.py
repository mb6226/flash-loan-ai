"""
Feature engineering helpers
"""

import numpy as np


def rolling_features(price_series, window=10):
    return {
        'mean': price_series.rolling(window).mean(),
        'std': price_series.rolling(window).std(),
    }
