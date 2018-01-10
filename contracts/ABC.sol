pragma solidity ^0.4.18;

import './BurnToken.sol';


contract ABC is BurnToken {
  string public constant name = "ABCCOIN";
  string public constant symbol = "ABC";
  uint8 public constant decimals = 18;

}
