"""
Model loader that returns model objects based on configuration. Placeholder implementation.
"""

class ModelLoader:
    def __init__(self):
        self._models = {}
        self._load_defaults()

    def _load_defaults(self):
        # Placeholder load sequence
        self._models['lstm'] = DummyLSTMModel()
        self._models['gnn'] = DummyGNNModel()

    def get_model(self, name):
        return self._models.get(name)

class DummyLSTMModel:
    def predict(self, data):
        # Basic placeholder
        return {'price': 0.0}

class DummyGNNModel:
    def predict(self, graph):
        return {'paths': []}
