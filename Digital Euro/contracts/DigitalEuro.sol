/*
Implements EIP20 token standard: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
.*/


pragma solidity >=0.4.22 <0.7.0;

import "contracts/EIP20Interface.sol";
import "contracts/provable.sol";


contract DigitalEuro is EIP20Interface, usingProvable {
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
    constructor (
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
    
    function finishAccountCreation(address _user_address, string memory iban) internal {
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
        addTransferToAccount(_user_address, central_bank_address, _value, transfer_type.REDEEM, "");
    }
	
	function finishTransferCoins(address _sender_address, address _receiver_address, uint256 _value, string memory _reason) internal {
		balances[_sender_address] -= _value;
		balances[_receiver_address] += _value;
		addTransferToAccount(_sender_address, _receiver_address, _value, transfer_type.SENDING, _reason);
		addTransferToAccount(_sender_address, _receiver_address, _value, transfer_type.RECEIVING, _reason);
	}
    
    struct commands_obj {
        commands_type command;
        address from;
        address to;
        uint256 value;
        string reason;
    }
    mapping(bytes32=>commands_obj) commands;
	
	event AccountCreated();
	
	function __callback(bytes32 myid, string memory result) public {
        require(msg.sender == provable_cbAddress());
        if (commands[myid].command == commands_type.CREATE_ACCOUNT) {
            finishAccountCreation(commands[myid].to, commands[myid].reason);
        } else if (commands[myid].command == commands_type.ISSUE_COINS) {
            finishIssueCoins(commands[myid].to, commands[myid].value);
        } else if (commands[myid].command == commands_type.REDEEM_COINS) {
            finishRedeemCoins(commands[myid].from, commands[myid].value);
        } else if (commands[myid].command == commands_type.TRANSFER_COINS) {
            finishTransferCoins(commands[myid].from, commands[myid].to, commands[myid].value, commands[myid].reason);
        }
    }
    
    // DigitalEuro SmartContract Functions
    function createAccount(string memory iban) public {
		iban = strConcat(iban, ")");
		string memory url = strConcat("json(http://resa-group.com:8080/Sparkasse/controller.php?action=CheckAccount&iban=", iban);
		emit AccountCreated();
		bytes32 queryID = provable_query("URL", url);
		commands_obj memory c = commands_obj(commands_type.CREATE_ACCOUNT, central_bank_address, msg.sender, 0, iban);
        commands[queryID] = c;
    }
    
    // Issues Coins in return for real money from an user real world account
    function issueCoins(uint256 _value) public {
		string memory url = "json(http://resa-group.com:8080/Sparkasse/controller.php?action=IssueCoins";
		url = strConcat(url, "&value=");
		url = strConcat(url, int2str(_value));
		url = strConcat(url, "&sender_iban=");
		url = strConcat(url, accounts[msg.sender].iban);
		url = strConcat(url, "&receiver_iban=");
		url = strConcat(url, accounts[central_bank_address].iban);
		url = strConcat(url, ")");
		
		bytes32 queryID = provable_query("URL", url);
        commands_obj memory c = commands_obj(commands_type.ISSUE_COINS, central_bank_address, msg.sender, 0, "");
        commands[queryID] = c;		
    }
    
    // Redeem Coins in return for real money to an user real world account
    function redeemCoins(uint256 _value) public {
        require(_value < balances[msg.sender], "Not enough coins");
		string memory url = "json(http://resa-group.com:8080/Sparkasse/controller.php?action=RedeemCoins";
		url = strConcat(url, "&value=");
		url = strConcat(url, int2str(_value));
		url = strConcat(url, "&sender_iban=");
		url = strConcat(url, accounts[central_bank_address].iban);
		url = strConcat(url, "&receiver_iban=");
		url = strConcat(url, accounts[msg.sender].iban);
		url = strConcat(url, ")");
		
		bytes32 queryID = provable_query("URL", url);
        commands_obj memory c = commands_obj(commands_type.REDEEM_COINS, central_bank_address, msg.sender, 0, "");
        commands[queryID] = c;
    }
	
	function transferCoins(address _receiver_address, uint256 _value, string memory _reason) public {
		require(_value < balances[msg.sender], "Not enough coins");
		string memory url = "json(http://resa-group.com:8080/Sparkasse/controller.php?action=TransferCoins";
		url = strConcat(url, "&value=");
		url = strConcat(url, "&sender_iban=");
		url = strConcat(url, accounts[msg.sender].iban);
		url = strConcat(url, "&receiver_iban=");
		url = strConcat(url, accounts[_receiver_address].iban);
		url = strConcat(url, "&reason=");
		url = strConcat(url, _reason);
		url = strConcat(url, ")");
		
        bytes32 queryID = provable_query("URL", url);
        commands_obj memory c = commands_obj(commands_type.TRANSFER_COINS, msg.sender, _receiver_address, _value, _reason);
        commands[queryID] = c;
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
	
	function int2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
	
	function strConcat(string memory s1, string memory s2) internal pure returns (string memory){
        return string(abi.encodePacked(s1, s2));
    }
	
	function addressToString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            byte b = byte(uint8(uint(x) / (2**(8*(19 - i)))));
            byte hi = byte(uint8(b) / 16);
            byte lo = byte(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);            
        }
        return strConcat("0x", string(s));
    }
	
	function char(byte b) internal pure returns (byte c) {
        if (uint8(b) < 10) return byte(uint8(b) + 0x30);
        else return byte(uint8(b) + 0x57);
    }
    
}