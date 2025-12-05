"""
Inference entry points for model predictions and scoring
"""
from .models.model_loader import ModelLoader

class InferenceEngine:
    def __init__(self):
        self.loader = ModelLoader()

    def predict_price(self, input_data):
        model = self.loader.get_model('lstm')
        return model.predict(input_data)

    def detect_arbitrage_paths(self, graph_data):
        model = self.loader.get_model('gnn')
        return model.predict(graph_data)

if __name__ == '__main__':
    print('Inference module loaded')
