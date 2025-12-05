import pytest

from src.utils.risk import risk_score


def test_risk_score_zero():
    assert risk_score({}) == 0.0
