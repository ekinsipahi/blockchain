const BSCToken = artifacts.require('BSCToken');

module.exports = function(deployer, network, accounts){
    deployer.deploy(BSCToken, accounts[0]);
}