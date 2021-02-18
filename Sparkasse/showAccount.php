<?php
	include_once("DAO.php");
	$dao = new DAO();
	$account = $dao->getAccount($_SESSION['iban']);

?>

<!doctype html>
<html>
	<head>
		<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js"></script>
		<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js"></script>
		
		<link rel="stylesheet" href="css/bootstrap.min.css">
		<script src="js/bootstrap.min.js"></script>
	</head>
	<body>
		
		<div class="container">
			<div class="row">
				<div class="col">Firstname</div>
				<div class="col"><?php echo $account['first_name']; ?></div>
			</div>
			<div class="row">
				<div class="col">Lastname</div>
				<div class="col"><?php echo $account['last_name']; ?></div>
			</div>
			<div class="row">
				<div class="col">IBAN</div>
				<div class="col"><?php echo $account['iban']; ?></div>
			</div>
			<div class="row">
				<div class="col">Balance</div>
				<div class="col"><?php echo $account['balance']; ?></div>
			</div>
		
		</div>
	
		<button type="button" class="btn btn-primary" data-toggle="modal" data-target="#createModal">
		  Create Transfer
		</button>

		<!-- Modal -->
		<div class="modal fade" id="createModal" tabindex="-1" role="dialog" aria-labelledby="createModalLabel" aria-hidden="true">
			<div class="modal-dialog" role="document">
				<div class="modal-content">
					<div class="modal-header">
						<h5 class="modal-title" id="createModalLabel">Make Transfer</h5>
						<button type="button" class="close" data-dismiss="modal" aria-label="Close">
							<span aria-hidden="true">&times;</span>
						</button>
					</div>
					<form method="GET" action="controller.php">
						<div class="modal-body">
							<div class="container">
								<div class="col"><input type="hidden"name="iban_sender" value="<?php echo $account['iban']; ?>" /></div>
								<div class="row">
									<div class="col">IBAN</div>
									<div class="col"><input type="text" name="iban_receiver"/></div>
								</div>
								<div class="row">
									<div class="col">Value</div>
									<div class="col"><input type="decimal" name="value"/></div>
								</div>
								<div class="row">
									<div class="col">Reason</div>
									<div class="col"><input type="text" name="reason"/></div>
								</div>
							</div>
						</div>
						<div class="modal-footer">
								<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
								<button type="submit" name="action" value="Transfer" class="btn btn-primary">Create Transfer</button>
						</div>
					</form>
				</div>
			</div>
		</div>
	</body>
</html>