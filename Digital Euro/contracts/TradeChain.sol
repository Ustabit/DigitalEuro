pragma solidity >=0.4.22 <0.7.0;

import "contracts/DigitalEuro_WP.sol";

/**
 * @title TradeChain
 */
contract TradeChain {
    address central_bank_address;
    
    event Transfer(uint32 userID);
    
    constructor (address _cb_address) public {
        central_bank_address = _cb_address;
    }
    
    function purchase(address _receiver, uint256 _value, string memory _reason) public {
        DigitalEuro_WP cb = DigitalEuro_WP(address(central_bank_address));
        cb.purchase(_receiver, _value, _reason);
    }
    
    
}