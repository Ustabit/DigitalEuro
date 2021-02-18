<?php

class DAO {
	private $servername = "localhost";
	private $username = "root";
	private $password = "";
	private $db = "sparkasse";
	
	private $conn;

	function __construct() {
		$this->conn = new PDO('mysql:host='.$this->servername.';dbname='.$this->db, $this->username, $this->password);;
		$this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
	}
	
	function createAccount($lastName, $firstName, $iban) {
		$query = "INSERT INTO account (last_name, first_name, iban, balance) VALUES (?,?,?,1000)";
		$stmt = $this->conn->prepare($query);
		$stmt->execute(array($lastName, $firstName, $iban));
	}
	
	function getAccount($iban) {
		$query = "SELECT * FROM account WHERE iban=?";
		$stmt = $this->conn->prepare($query);
		$stmt->execute(array($iban));
		return $stmt->fetch();
	}
	
	function isAccount($iban) {
		$query = "SELECT last_name FROM account WHERE iban=?";
		$stmt = $this->conn->prepare($query);
		$stmt->execute(array($iban));
		return $stmt->fetch();
	}
	
	function getBalance($iban) {
		$query = "SELECT balance FROM account WHERE iban=?";
		$stmt = $this->conn->prepare($query);
		$result = $stmt->execute(array($iban));
		return $result->fetch();
	}
	
	function addTransfer($from, $to, $value, $reason) {
		$query = "UPDATE account SET balance=balance-? WHERE iban=?";
		$stmt = $this->conn->prepare($query);
		$stmt->execute(array($value, $from));
		
		$query = "UPDATE account SET balance=balance+? WHERE iban=?";
		$stmt = $this->conn->prepare($query);
		$stmt->execute(array($value, $to));
		
		$query = "INSERT INTO transfer (from_iban, to_iban, value, reason) VALUES (?,?,?,?)";
		$stmt = $this->conn->prepare($query);
		$stmt->execute(array($from, $to, $value, $reason));
		return true;
	}
	
	function getTransfer($id) {		
		$query = "SELECT * FROM transfer WHERE id=?";
		$stmt = $this->conn->prepare($query);
		$result = $stmt->execute(array($id));		
		return $result->fetch();
	}
	
	function getAllTransferFromIBAN($iban) {
		$query = "SELECT * FROM transfer WHERE iban=?";
		$stmt = $this->conn->prepare($query);
		$result = $stmt->execute(array($iban));
		return $result->fetchAll();
	}
}
?>