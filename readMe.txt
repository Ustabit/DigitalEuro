- Digital Euro SmartContracts
- DE_Standalone Standalone Python Client zur Kommunikation mit Node


Ganach starten

Truffle starten und auf Ganache deployen mit "truffle migrate --network ganache"
(Einstellungen für Ganache können bei Bedarf in Digital Euro/truffle-config.js angepasst werden)
Ansonsten DigitalEuro.sol mit der IBAN "DE18420500017022470697" deployen und anschliessend TradeChain.sol mit der gerade erstellten Adresse deployen


Python virtuelle Umgebung erstellen:

- In Ordner DE_Standalone wechseln
- Virtuelle Umgebung erstellen mit "python -m venv venv"
- Virtuelle Umgebung aktivieren mit ".\venv\Scripts\activate"
- Dependencies herunterladen mit "pip install requirements.txt"
- Client konfigurieren (siehe unten)
- Client starten mit "python ui.py" oder in der IDE

Client konfigurieren:
- web3_api.py Zeile 14: c_address = "Adresse des Digital Euro SmartContracts"
- web3_api.py Zeile 17: address = "Ethereum Wallet Adresse des Clients"
- web3_api.py Zeile 21: self.privatet_key = "Private Key der Ethereum Wallet Adresse"
- web3_api.py Zeile 23: URL des Ethereums Netzwerks
- web3_api.py Zeile 139: address = "Adresse des Trade Chain SmartContracts"
- Inhalte von digital_euro_abi.txt und trade_chain_abi.txt mit jeweiliger ABI ersetzen

Client nutzen:
Den Dialog am Anfang kann man wegklicken. Im Moment sind alle Adressen hard coded. Nur die Iban und die Beträge muss man eingeben. IBAN werden bisher nur in einigen Funktionen überprüft.


API-Request:
http://85.235.65.245:8080/Sparkasse/controller.php?action=CheckAccount&iban=DE18420500017022470697
http://85.235.65.245:8080/Sparkasse/controller.php?action=IssueCoins&value=100&sender_iban=DE18420500017022470697&receiver_iban=DE18420500012794013032
http://85.235.65.245:8080/Sparkasse/controller.php?action=RedeemCoins&value=100&sender_iban=DE18420500012794013032&receiver_iban=DE18420500017022470697
http://85.235.65.245:8080/Sparkasse/controller.php?action=TransferCoins&value=100&sender_iban=DE18420500012794013032&receiver_iban=DE18420500017022470697&reason=Verwendungszweck

