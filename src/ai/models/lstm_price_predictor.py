"""
Skeleton for LSTM price predictor model
"""

class LSTMPricePredictor:
    def __init__(self, config=None):
        self.config = config or {}

    def fit(self, X, y):
        # training placeholder
        pass

    def predict(self, X):
        return [0.0 for _ in range(len(X))]
