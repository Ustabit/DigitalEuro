const DigitalEuro = artifacts.require("DigitalEuro");
const TradeChain = artifacts.require("TradeChain");

module.exports = function(deployer) {
  deployer.deploy(DigitalEuro, 'DE18420500012794013032').then(function() {
	  return deployer.deploy(TradeChain, DigitalEuro.address);
  });
};
