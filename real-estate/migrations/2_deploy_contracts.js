var RealEstate = artifacts.require("./RealEstate.sol");

module.exports = function(deployer) {
  deployer.deploy(RealEstate);
};
