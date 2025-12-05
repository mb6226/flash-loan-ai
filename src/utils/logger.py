"""
Centralized logging util. For now, a thin wrapper over Python logging module.
"""
import logging

logger = logging.getLogger('flashloan')
handler = logging.StreamHandler()
formatter = logging.Formatter("[%(asctime)s] %(levelname)s %(message)s")
handler.setFormatter(formatter)
logger.addHandler(handler)
logger.setLevel(logging.INFO)


def get_logger():
    return logger
