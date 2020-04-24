import sys
from PyQt5.QtWidgets import QApplication, QLabel, QMainWindow, QWidget, QHBoxLayout, QLineEdit, QPushButton, QDialog, \
    QVBoxLayout, QTabWidget
from PyQt5.QtCore import Qt

from signals import Signals
from web3_api import Web3Client


class MainWindow(QMainWindow):

    def __init__(self, *args, **kwargs):
        super(MainWindow, self).__init__(*args, **kwargs)

        self.setWindowTitle("Digital Euro Standalone Client")
        balanceBox = self.getBalanceBox()
        creationBox = self.getCreationBox()
        transferBox = self.getTransferBox()
        purchaseBox = self.getPurchaseBox()
        mainVLayout = QVBoxLayout()

        test_button = QPushButton("Create Account")
        test_button.clicked.connect(self.test_me)

        self.status = QLabel("Not Connected")

        mainVLayout.addWidget(self.status)
        mainVLayout.addWidget(test_button)
        mainVLayout.addWidget(balanceBox)
        mainVLayout.addWidget(creationBox)
        mainVLayout.addWidget(transferBox)
        mainVLayout.addWidget(purchaseBox)
        mainWidget = QWidget()
        mainWidget.setLayout(mainVLayout)

        self.tabs = QTabWidget()

        self.tabs.addTab(mainWidget, "Funktionen")

        # Set the central widget of the Window. Widget will expand
        # to take up all the space in the window by default.
        self.setCentralWidget(self.tabs)

        self.dialog = self.getDialog()
        self.dialog.show()

    def test_me(self):
        try:
            self.web3.createAccount()
        except Exception as e:
            pass

    def test_signal(self):
        print("Signal getted")

    def getDialog(self):
        dialog = QDialog(self)
        dialog.setWindowTitle("Credentials")
        self.address = QLineEdit()
        self.password = QLineEdit("Password")
        self.dialog_button = QPushButton("OK")
        self.dialog_button.clicked.connect(self.saveCredentials)
        vBox = QVBoxLayout()
        vBox.addWidget(self.address)
        vBox.addWidget(self.password)
        vBox.addWidget(self.dialog_button)
        dialog.setLayout(vBox)
        return dialog

    def saveCredentials(self):
        self.dialog.close()
        self.signal = Signals()
        self.signal.createAccount.connect(self.test_signal)
        #self.web3 = Web3Client(self.address.text(), self.password.text())
        self.web3 = Web3Client(self.signal, "0x53e7ad199f2ec67A7Ad94FB90234ebe055db1459", self.password.text())
        #self.web3.connection.connect(self.is_connected)

    def is_connected(self):
        self.status.setText("status")

    def getCreationBox(self):
        widget = QWidget()
        hBox = QHBoxLayout()
        self.creation_amount = QLineEdit()
        issue = QPushButton("Issue")
        issue.clicked.connect(self.issueCoins)
        redeem = QPushButton("Redeem")
        redeem.clicked.connect(self.redeemCoins)
        hBox.addWidget(self.creation_amount)
        hBox.addWidget(issue)
        hBox.addWidget(redeem)
        widget.setLayout(hBox)
        return widget

    def getTransferBox(self):
        widget = QWidget()
        hBox = QHBoxLayout()
        self.transfer_receiver_address = QLineEdit("Address")
        self.transfer_amount = QLineEdit("Amount")
        self.transfer = QPushButton("Transfer")
        self.transfer.clicked.connect(self.transferCoins)
        self.transferFrom = QPushButton("Transfer From")
        self.transferFrom.clicked.connect(self.transferFromCoins)
        self.allowance = QPushButton("Allowance")
        self.allowance.clicked.connect(self.allowanceCoins)
        self.approve = QPushButton("Approve")
        self.approve.clicked.connect(self.approveCoins)
        hBox.addWidget(self.transfer_receiver_address)
        hBox.addWidget(self.transfer_amount)
        hBox.addWidget(self.transfer)
        hBox.addWidget(self.transferFrom)
        hBox.addWidget(self.allowance)
        hBox.addWidget(self.approve)
        widget.setLayout(hBox)
        return widget

    def getBalanceBox(self):
        widget = QWidget()
        hBox = QHBoxLayout()
        self.balance = QLineEdit()
        get_balance_button = QPushButton("Get Balance")
        get_balance_button.clicked.connect(self.getBalance)
        hBox.addWidget(self.balance)
        hBox.addWidget(get_balance_button)
        widget.setLayout(hBox)
        return widget

    def getPurchaseBox(self):
        widget = QWidget()
        hBox = QHBoxLayout()
        self.purchase_receiver_address = QLineEdit("Address")
        self.purchase_value = QLineEdit("Value")
        self.purchase_reason = QLineEdit("Reason")
        purchase_button = QPushButton("Purchase")
        hBox.addWidget(self.purchase_receiver_address)
        hBox.addWidget(self.purchase_value)
        hBox.addWidget(self.purchase_reason)
        hBox.addWidget(purchase_button)
        widget.setLayout(hBox)
        return widget

    def getBalance(self):
        try:
            self.balance.setText(str(self.web3.get_balance()))
        except Exception as e:
            pass

    def issueCoins(self):
        try:
            self.web3.issue_coins(int(self.creation_amount.text()))
            self.creation_amount.setText("0")
        except Exception as e:
            pass

    def redeemCoins(self):
        try:
            self.web3.redeem_coins(int(self.creation_amount.text()))
            self.creation_amount.setText("0")
        except Exception as e:
            pass

    def transferCoins(self):
        try:
            self.web3.transfer_coins(self.transfer_receiver_address.text(), int(self.transfer_amount.text()))
            self.transfer_receiver_address.setText("")
            self.transfer_amount.setText("0")
        except Exception as e:
            pass

    def transferFromCoins(self):
        try:
            self.web3.transfer_coins_from(self.transfer_receiver_address.text(), int(self.transfer_amount.text()))
            self.transfer_receiver_address.setText("")
            self.transfer_amount.setText("0")
        except Exception as e:
            pass

    def allowanceCoins(self):
        try:
            self.transfer_amount.setText(str(self.web3.allowance_coins(self.transfer_receiver_address.text())))
        except Exception as e:
            pass

    def approveCoins(self):
        try:
            self.web3.approve_coins(self.transfer_receiver_address.text(), int(self.transfer_amount.text()))
            self.transfer_receiver_address.setText("")
            self.transfer_amount.setText("0")
        except Exception as e:
            pass

app = QApplication(sys.argv)

window = MainWindow()
window.show()

app.exec_()