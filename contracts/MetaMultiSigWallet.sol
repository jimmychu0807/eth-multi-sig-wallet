// SPDX-License-Identifier: MIT

//  Off-chain signature gathering multisig that streams funds - @austingriffith
//
// started from 🏗 scaffold-eth - meta-multi-sig-wallet example https://github.com/austintgriffith/scaffold-eth/tree/meta-multi-sig
//    (off-chain signature based multi-sig)
//  added a very simple streaming mechanism where `onlySelf` can open a withdraw-based stream

pragma solidity >= 0.8.17 <0.9.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MetaMultiSigWallet {
  event Deposit(address indexed sender, uint amount, uint balance);
  event Owner(address indexed owner, bool added);

  // on-chain variables
  mapping(address => bool) public isOwner;
  uint public signaturesRequired;
  uint public nonce;
  uint public chainId;

  constructor (uint _chainId, address[] memory _owners, uint _signaturesRequired) {
    require(_owners.length >= _signaturesRequired, "Number of required signatures is greater than the number of owners.");
    chainId = _chainId;
    signaturesRequired = _signaturesRequired;
    nonce = 0;
    for (uint idx = 0; idx < _owners.length; idx++) {
      address owner = _owners[idx];
      require (owner != address(0), "Owner address cannot be 0x0.");
      isOwner[owner] = true;
    }
  }
}
