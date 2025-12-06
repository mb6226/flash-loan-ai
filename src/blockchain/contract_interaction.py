"""
Utilities to interact with smart contracts via web3
"""

from web3 import Web3

class ContractInterface:
    def __init__(self, web3: Web3, address: str, abi: list):
        self.w3 = web3
        self.contract = web3.eth.contract(address=address, abi=abi)

    def call_view(self, fn_name, *args):
        return getattr(self.contract.functions, fn_name)(*args).call()

    def build_tx(self, fn_name, tx_params, *args):
        return getattr(self.contract.functions, fn_name)(*args).buildTransaction(tx_params)
