pragma solidity ^0.4.15;

import './StandardCrowdsale.sol';

import './base/ownership/Ownable.sol';
import './base/crowdsale/RefundableCrowdsale.sol';
import './base/crowdsale/CappedCrowdsale.sol';

import './ABC.sol';
import './TeamAllocation.sol';
import './base/lifecycle/Pausable.sol';


contract ABCCrowdsale is StandardCrowdsale, CappedCrowdsale , Ownable ,RefundableCrowdsale, Pausable {
enum Stage {PRESALE, PUBLICSALE, SUCCESS, FAILURE}
  //stage ICO
  Stage public stage;
  uint256 public _presaleCap = 10000000e18; //10m
  uint public _crowdsaleCap = 56000000e18; //56m
  uint256 public _soldTokensalecap;
    uint256 public _soldPresalecap;
  uint constant public lockedTeamAllocationTokens = 34000000e18;
  TeamAllocation public teamAllocation;
   uint public softCap = 12500 ether;
   uint public hardCap = 160000000 ether;
   bool public isGoalReached = false;
   // How much ETH each address has invested to this crowdsale
    mapping (address => uint256) public investedAmountOf;
    // How many distinct addresses have invested
    uint public investorCount;
    uint public minContribAmount = 0.1 ether; // 0.1 ether
    uint public maxContribAmount = 50 ether; // 50 ether
    event MinimumGoalReached();
    function ABCCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, uint256 _goal, uint256 _cap)
      StandardCrowdsale (_startTime, _endTime, _rate, _wallet) RefundableCrowdsale(_goal) CappedCrowdsale(_cap)
    {
        totalSupply = 100000000e18;
        balances[wallet]= totalSupply;
        stage = Stage.PRESALE;
        token = createTokenContract();
    }
    function createTokenContract() internal returns (StandardToken) {
      return new ABC();
    }
    function buyTokens(address beneficiary) public payable {
      require(beneficiary != address(0));
      require(validPurchase());
      uint256 weiAmount = msg.value;
      uint256 tokens;
      if (stage == Stage.PRESALE){
       // calculate token amount to be created
      tokens = weiAmount.mul(rate);
       assert (tokens <= _presaleCap && _soldPresalecap < _presaleCap);
       _presaleCap = _presaleCap.sub(tokens);
       _soldPresalecap = _soldPresalecap.add(tokens);
      }else {
           tokens = weiAmount.mul(getTimebasedTokenRate());
           assert (tokens <= _crowdsaleCap && _soldTokensalecap < _crowdsaleCap);

           _crowdsaleCap = _crowdsaleCap.sub(tokens);
           _soldTokensalecap = _soldTokensalecap.add(tokens);
      }
      if(investedAmountOf[beneficiary] == 0) {
          // A new investor
          investorCount++;
       }
       // Update investor
       investedAmountOf[beneficiary] = investedAmountOf[beneficiary].add(weiAmount);
      forwardFunds();
      weiRaised = weiRaised.add(weiAmount);
      balances[wallet] = balances[wallet].sub(tokens);
      balances[beneficiary] = balances[beneficiary].add(tokens);
      //token.mint(beneficiary, tokens);
      TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
      if (!isGoalReached && weiRaised >= softCap) {
            isGoalReached = true;
            MinimumGoalReached();
        }
    }
    function PUBLICSALEToOtherCoinUser(address beneficiary, uint256 weiAmount) public onlyOwner {
        require(beneficiary != address(0) && weiAmount > 0);
       // calculate token amount to be created
        uint256 tokens;
      if (stage == Stage.PRESALE){
           // calculate token amount to be created
      tokens = weiAmount.mul(rate);
      }else {
           tokens = weiAmount.mul(getTimebasedTokenRate());
      }
        weiRaised = weiRaised.add(weiAmount);
        balances[wallet] = balances[wallet].sub(tokens);
        balances[beneficiary] = balances[beneficiary].add(tokens);
        //token.mint(beneficiary, tokens);
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
      }
  // @return true if the transaction can buy tokens
    function validPurchase() internal constant returns (bool) {
        bool minContribution = minContribAmount <= msg.value;
        bool maxContribution = maxContribAmount >= msg.value;
        bool withinPeriod = now >= startTime && now <= endTime;
        bool nonZeroPurchase = msg.value != 0;
        return maxContribution && minContribution && withinPeriod && nonZeroPurchase;
    }
   // @return  current time
    function getNow() public constant returns (uint) {
        return (now);
    }
  // Get the time-based token rate
   function getTimebasedTokenRate() internal constant returns (uint256) {
        uint256 tokenRate = 0;
        if (stage == Stage.PUBLICSALE) {
         uint256 nowTime = now;
         uint256 firstTwodays = startTime + (48 hours);
         uint256 firstWeek = firstTwodays + (7 days);
         uint256 secondWeek = firstWeek + (7 days);
         uint256 thirdWeek = secondWeek + (7 days);
         uint256 lastWeek = thirdWeek + (7 days);
            if (nowTime <= firstTwodays) {
                tokenRate = 3375;
            } else if (nowTime <= firstWeek) {
                tokenRate = 3125;
            } else if (nowTime <= secondWeek) {
                tokenRate = 2875;
            } else if (nowTime <= thirdWeek) {
                tokenRate = 2625;
            } else if (nowTime <= lastWeek) {
                tokenRate = 2500;
            }
        return tokenRate;
    }
   }
     // Start Crowdsale After presale end
     //New starttime and end time should be given
     function startCrowdsale(uint256 _startTime, uint256 _endTime) public onlyOwner {
         require(hasEnded());
         //require(_startTime >= now);
         require(_endTime >= _startTime);
         stage = Stage.PUBLICSALE;
          _crowdsaleCap = _crowdsaleCap.add(_presaleCap);
         //Start Time endTime and price for CrowdSale
         startTime = _startTime;
         endTime = _endTime;
     }
     // @return true if the crowdsale has raised enough money to be successful.
     function isMinimumGoalReached() public constant returns (bool reached) {
         return weiRaised >= softCap;
     }
     function updateICOStatus() public onlyOwner {
         if (hasEnded() && weiRaised >= softCap) {
             stage = Stage.SUCCESS;
         } else if (hasEnded()) {
             stage = Stage.FAILURE;
         }
     }
        // Change Endtime for Testing Purpose
       function changeEndTime(uint256 _startTime,uint256 _endTime) public onlyOwner {
       require(stage == Stage.PRESALE);
           endTime = _endTime;
           startTime = _startTime;
       }
       function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
         return super.transfer(_to, _value);
       }
       function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
         return super.transferFrom(_from, _to, _value);
       }
       function finalization() internal {
         //Allot team tokens to a smart contract which will frozen for 3 months
         teamAllocation = new TeamAllocation();
         balances[wallet] = balances[wallet].sub(lockedTeamAllocationTokens);
         balances[teamAllocation] = balances[teamAllocation].add(lockedTeamAllocationTokens);
         //token.mint(address(teamAllocation), lockedTeamAllocationTokens);
         super.finalization();
       }

}
