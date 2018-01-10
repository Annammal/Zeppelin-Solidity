pragma solidity ^0.4.15;

import './base/math/SafeMath.sol';
import './base/ownership/Ownable.sol';

import './ABC.sol';

contract TeamAllocation is Ownable {

  using SafeMath for uint;

  uint public unlockedAt;
  ABC abc;
  mapping (address => uint) allocations;
  uint tokensCreated = 0;
  uint constant public lockedTeamAllocationTokens = 34000000e18;

  //address of the founder storage vault
  address public teamStorageVault = 0x34b2413ac3508987f37Ea323907d30b9fdF6E44E;

  function TeamAllocation() {
    abc = ABC(msg.sender);
    // Locked time of approximately 9 months before team members are able to redeeem tokens.
    uint nineMonths = 3 * 30 days;
    unlockedAt = now.add(nineMonths);
    //34m tokens from the Marketing bucket which are locked for 3 months
    allocations[teamStorageVault] = lockedTeamAllocationTokens;
  }

  function getTotalAllocation() returns (uint){
      return lockedTeamAllocationTokens;
  }

  function unlock() external payable {
    require (now > unlockedAt);

    if (tokensCreated == 0) {
      tokensCreated = abc.balanceOf(this);
    }

    //transfer the locked tokens to the teamStorageAddress
    abc.transfer(teamStorageVault, tokensCreated);
  }
}
