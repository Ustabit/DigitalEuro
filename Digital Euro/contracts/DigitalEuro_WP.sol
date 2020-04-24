/*
Implements EIP20 token standard: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
.*/


pragma solidity >=0.4.22 <0.7.0;

import "contracts/EIP20Interface.sol";


contract DigitalEuro_WP is EIP20Interface {
    // Transfer Types
    enum transfer_type {
        ISSUE,
        REDEEM,
        SENDING,
        RECEIVING
    }
    
    enum commands_type {
        CREATE_ACCOUNT,
        ISSUE_COINS,
        REDEEM_COINS,
        TRANSFER_COINS
    }
    
    // Address from initiator
    address central_bank_address;
    
    // Transfer used in an account
    struct transfer_obj {
        address from;
        address to;
        uint256 value;
        transfer_type t_type;
        string reason;
    }
    
    // Account from customer of a Bank that is part of Central Bank
    struct account_obj {
        //string name;
        //commands_type command;
        string iban;
        mapping(uint256 => transfer_obj) transfer_list;
        uint256 transfer_counter;
    }
    // List of all customer accounts
    mapping(address => account_obj) public accounts;

    // Constructor
    function DigitalEuro (
        string memory iban
    ) public {
        balances[msg.sender] = 0;
        totalSupply = 0;
        name = "DigitalEuro";
        decimals = 2;
        symbol = "D-Euro";
        central_bank_address = msg.sender;
        accounts[central_bank_address].iban = iban;
    }
    
    /*function finishAccountCreation(address _user_address, string iban) internal {
        balances[_user_address] = 0;
        accounts[_user_address].iban = iban;
    }
    
    function finishIssueCoins(address _user_address, uint256 _value) internal {
        balances[_user_address] += _value;
        totalSupply += _value;
        addTransferToAccount(central_bank_address, _user_address, _value, transfer_type.ISSUE, "");
    }
    
    function finishRedeemCoins(address _user_address, uint256 _value) internal {
        balances[_user_address] -= _value;
        totalSupply -= _value;
        addTransferToAccount(_user_address, central_bank_address, _value, transfer_type.ISSUE, "");
    }
    
    struct commands_obj {
        commands_type command;
        address from;
        address to;
        uint256 value;
        string reason;
    }
    mapping(bytes32=>commands_obj) commands;*/
	
	event AccountCreated();
    
    // DigitalEuro SmartContract Functions
    function createAccount(string memory iban) public returns (bool) {
        balances[msg.sender] = 0;
        accounts[msg.sender].iban = iban;
		emit AccountCreated();
		return true;
    }
    
    // Issues Coins in return for real money from an user real world account
    function issueCoins(uint256 _value) public {
        // Check the real bank account (API) and the fund of real bank account
        balances[msg.sender] += _value;
        totalSupply += _value;
        addTransferToAccount(central_bank_address, msg.sender, _value, transfer_type.ISSUE, "");
    }
    
    // Redeem Coins in return for real money to an user real world account
    function redeemCoins(uint256 _value) public {
        require(_value < balances[msg.sender], "Not enough coins");
        // Check the real bank account (API) and the fund of real bank account
        balances[msg.sender] -= _value;
        totalSupply -= _value;
        addTransferToAccount(msg.sender, central_bank_address, _value, transfer_type.REDEEM, "");
    }
    
    function addTransferToAccount(address _sender, address _receiver, uint256 _value, transfer_type _t_type, string memory _reason) internal {
        uint256 sender_count = accounts[_sender].transfer_counter++;
        uint256 receiver_count = accounts[_receiver].transfer_counter++;
        transfer_obj memory t = transfer_obj(_sender, _receiver, _value, _t_type, _reason);
        accounts[_sender].transfer_list[sender_count] = t;
        accounts[_receiver].transfer_list[receiver_count] = t;
    }
    
	function purchase(address _receiver, uint256 _value, string memory _reason) public {
		transfer(_receiver, _value);
		addTransferToAccount(msg.sender, _receiver, _value, transfer_type.SENDING, _reason);
	}
    
    
    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    //uint256 public totalSupply;
    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show.
    string public symbol;                 //An identifier: eg SBX
    
    // EIP20 Interface Implementations
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        emit Transfer(_from, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
	
	/*function getTransactionCounter(address _user_address) public view returns(uint256) {
		return accounts[_user_address].transfer_counter;
	}
	
	function getTransactionFromUser(address _user_address, uint256 _counter) public view returns (transfer_obj) {
		return accounts[_user_address].transfer_list[_counter];
	}*/
    
}