const MainSystem = artifacts.require("MainSystem");

module.exports = function (deployer) {
  deployer.deploy(MainSystem);
};
