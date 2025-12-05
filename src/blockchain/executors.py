"""
Transaction executors: build and submit transactions, maintain nonce and gas estimation
"""

class Executor:
    def __init__(self, web3):
        self.web3 = web3

    def send_raw_tx(self, signed_tx):
        return self.web3.eth.send_raw_transaction(signed_tx)

    def estimate_fee(self, tx):
        return self.web3.eth.estimate_gas(tx)
