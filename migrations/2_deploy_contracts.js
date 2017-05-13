var Verify = artifacts.require("./contracts/Verify.sol");

module.exports = function(deployer) {
  deployer.deploy(Verify);
};
