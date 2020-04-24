from PyQt5.QtCore import QObject, pyqtSignal


class Signals(QObject):

    createAccount = pyqtSignal()