import json
import logging
import time
from threading import Thread

from PyQt5 import QtCore
from PyQt5.QtCore import QObject, pyqtSignal
from web3 import Web3

from signals import Signals


class Web3Client:
    c_address = "0xc808669C9011CA56b0D6C0B2C32BEf8FF277b192"
    #connection = pyqtSignal()

    def __init__(self, signal, address="0x53e7ad199f2ec67A7Ad94FB90234ebe055db1459", password="papa"):
        self.signal = signal
        self.address = address
        self.password = password
        self.private_key = "1b1cb7bf7ffe8d8a1352632b86306d221ccbf1823e05d064aa176faa902c4b9c"
        #self.url = "https://core.bloxberg.org"
        self.url = "http://localhost:7545"

        self.gas = 700000

        with open("digital_euro_abi.txt", "r") as f:
            abi = json.load(f)
        self.c_abi = abi['abi']

        self.web3 = Web3(Web3.HTTPProvider(self.url))
        self.contract = self.web3.eth.contract(address=self.c_address, abi=self.c_abi)

        self.chainId = self.web3.eth.chainId


        self.event_filter = self.web3.eth.filter({'fromBlock': 'latest', 'address': self.c_address})
        #worker = Thread(target=self.filter_loop, daemon=True)
        #worker.start()
        print(self.is_connected())

    def is_connected(self):
        return self.web3.isConnected()

        """while self.web3.isConnected():
            self.connection.emit()
        self.connection.emit()"""

    def filter_loop(self):
        while True:
            for event in self.event_filter.get_new_entries():
                self.handle_event(event)
                time.sleep(5)

    def waitForTransaction(self, txHash, modus):
        self.web3.eth.waitForTransactionReceipt(txHash)
        self.signal.createAccount.emit()
        print(modus)

    def handle_event(self, event):
        print("Event:", event)

    def createAccount(self, iban="DE18420500017022470697"):
        transaction = self.contract.functions.createAccount(iban).buildTransaction({
            'chainId': self.chainId,
            'gas': self.gas,
            'nonce': self.web3.eth.getTransactionCount(self.address)})
        signedTransaction = self.web3.eth.account.signTransaction(transaction, self.private_key)
        txHash = self.web3.eth.sendRawTransaction(signedTransaction.rawTransaction)
        #txHash = self.contract.functions.createAccount(iban).transact({'from': self.address})
        worker = Thread(target=self.waitForTransaction, args=(txHash, "Create"), daemon=True)
        worker.start()
        print("TxHash: ", txHash)

    def get_balance(self):
        return self.contract.functions.balanceOf(self.address).call()

    def issue_coins(self, value):
        transaction = self.contract.functions.issueCoins(value).buildTransaction({
            'chainId': self.chainId,
            'gas': self.gas,
            'nonce': self.web3.eth.getTransactionCount(self.address)})
        signedTransaction = self.web3.eth.account.signTransaction(transaction, self.private_key)
        txHash = self.web3.eth.sendRawTransaction(signedTransaction.rawTransaction)
        #txHash = self.contract.functions.issueCoins(value).transact({'from': self.address})
        worker = Thread(target=self.waitForTransaction, args=(txHash, "Issue"), daemon=True)
        worker.start()

    def redeem_coins(self, value):
        transaction = self.contract.functions.redeemCoins(value).buildTransaction({
            'chainId': self.chainId,
            'gas': self.gas,
            'nonce': self.web3.eth.getTransactionCount(self.address)})
        signedTransaction = self.web3.eth.account.signTransaction(transaction, self.private_key)
        txHash = self.web3.eth.sendRawTransaction(signedTransaction.rawTransaction)
        #txHash = self.contract.functions.redeemCoins(value).transact({'from': self.address})
        worker = Thread(target=self.waitForTransaction, args=(txHash, "Redeem"), daemon=True)
        worker.start()

    def transfer_coins(self, receiver, value):
        transaction = self.contract.functions.transfer(receiver, value).buildTransaction({
            'chainId': self.chainId,
            'gas': self.gas,
            'nonce': self.web3.eth.getTransactionCount(self.address)})
        signedTransaction = self.web3.eth.account.signTransaction(transaction, self.private_key)
        txHash = self.web3.eth.sendRawTransaction(signedTransaction.rawTransaction)
        worker = Thread(target=self.waitForTransaction, args=(txHash, "Redeem"), daemon=True)
        worker.start()

        #self.contract.functions.transfer(receiver, value).transact({'from': self.address})

    def transfer_coins_from(self, receiver, value):
        transaction = self.contract.functions.transferFrom(receiver, self.address, value).buildTransaction({
            'chainId': self.chainId,
            'gas': self.gas,
            'nonce': self.web3.eth.getTransactionCount(self.address)})
        signedTransaction = self.web3.eth.account.signTransaction(transaction, self.private_key)
        txHash = self.web3.eth.sendRawTransaction(signedTransaction.rawTransaction)
        worker = Thread(target=self.waitForTransaction, args=(txHash, "Redeem"), daemon=True)
        worker.start()

        #self.contract.functions.transferFrom(receiver, self.address, value).transact({'from': self.address})

    def approve_coins(self, receiver, value):
        transaction = self.contract.functions.approve(receiver, value).buildTransaction({
            'chainId': self.chainId,
            'gas': self.gas,
            'nonce': self.web3.eth.getTransactionCount(self.address)})
        signedTransaction = self.web3.eth.account.signTransaction(transaction, self.private_key)
        txHash = self.web3.eth.sendRawTransaction(signedTransaction.rawTransaction)
        worker = Thread(target=self.waitForTransaction, args=(txHash, "Redeem"), daemon=True)
        worker.start()
        #self.contract.functions.approve(receiver, value).transact({'from': self.address})

    def allowance_coins(self, delegate):
        return self.contract.functions.allowance(delegate, self.address).call()

    def purchase(self, receiver, value, reason):
        address = "0xEfaA117b852f7B7Cf58649147eA10D8845eB5402"
        with open("trade_chain_abi.txt", "r") as f:
            abi = json.load(f)['abi']
        con = self.web3.eth.contract(address=address, abi=abi)
        transaction = con.functions.purchase(receiver, value, reason).buildTransaction({
            'chainId': self.chainId,
            'gas': self.gas,
            'nonce': self.web3.eth.getTransactionCount(self.address)})
        signedTransaction = self.web3.eth.account.signTransaction(transaction, self.private_key)
        txHash = self.web3.eth.sendRawTransaction(signedTransaction.rawTransaction)
        worker = Thread(target=self.waitForTransaction, args=(txHash, "Redeem"), daemon=True)
        worker.start()

        #txHash = con.functions.purchase(receiver, value, reason).transact({'from': self.address})
        #self.web3.eth.waitForTransactionReceipt(txHash)

#client = Web3Client()