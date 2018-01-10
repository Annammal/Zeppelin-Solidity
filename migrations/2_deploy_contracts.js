var ABCCrowdsale = artifacts.require("./ABCCrowdsale.sol");
var ABC = artifacts.require("./ABC.sol");

function latestTime() {
  return web3.eth.getBlock('latest').timestamp;
}

const duration = {
  seconds: function(val) { return val},
  minutes: function(val) { return val * this.seconds(60) },
  hours:   function(val) { return val * this.minutes(60) },
  days:    function(val) { return val * this.hours(24) },
  weeks:   function(val) { return val * this.days(7) },
  years:   function(val) { return val * this.days(365)}
};

module.exports = function(deployer) {
  //uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet
  const startTime = latestTime() + duration.minutes(2);
  const endTime = startTime + duration.weeks(4);
  const rate = 1000;
  const wallet = "0x9fB0C7b98c7Db7C0543eE74209010b8A7ff303C6";
  const softCap = web3.toWei('10000', 'ether');
  const hardCap = web3.toWei('1000000', 'ether');

  console.log([startTime, endTime, rate, wallet, softCap, hardCap]);

  deployer.deploy(ABCCrowdsale, startTime, endTime, rate, wallet,softCap,hardCap);
  deployer.deploy(ABC);
};
