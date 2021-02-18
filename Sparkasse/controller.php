<?php

include_once "DAO.php";

function generate_IBAN() {
	$kto_nr = "";
	for ($i=0; $i<10; $i++) {
		$kto_nr .= rand(0, 9);
	}
	return "DE1842050001". $kto_nr;
}

$dao = new DAO();
if ($_GET['action'] == "Account") {
	$dao->createAccount($_GET['last_name'], $_GET['first_name'], generate_IBAN());
	require("index.html");
} else if ($_GET['action'] == "Login") {
	if ($dao->isAccount($_GET['iban'])) {
		session_start();
		$_SESSION['iban'] = $_GET['iban'];
		require("showAccount.php");
	} else {
		require("index.html");
	}
} else if ($_GET['action'] == "Transfer") {
	$dao->addTransfer($_GET['iban_sender'], $_GET['iban_receiver'], $_GET['value'], $_GET['reason']);
} else if ($_GET['action'] == "CheckAccount") {
	if ($dao->isAccount($_GET['iban'])) {
		echo true;
	}
} else if ($_GET['action'] == "IssueCoins") {
	if ($dao->getBalance($_GET['sender_iban']) >= $_GET['value']) {
		echo $dao->addTransfer($_GET['sender_iban'], $_GET['receiver_iban'], $_GET['value'], "ISSUE");		
	}
} else if ($_GET['action'] == "RedeemCoins") {
	echo $dao->addTransfer($_GET['sender_iban'], $_GET['receiver_iban'], $_GET['value'], "REDEEM");
} else if ($_GET['action'] == "TransferCoins") {
	echo $dao->addTransfer($_GET['sender_iban'], $_GET['receiver_iban'], $_GET['value'], $_GET['reason']);
}

?>