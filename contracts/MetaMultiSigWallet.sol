// SPDX-License-Identifier: MIT

//  Off-chain signature gathering multisig that streams funds - @austingriffith
//
// solhint-disable-next-line
// started from 🏗 [scaffold-eth - meta-multi-sig-wallet example](https://github.com/austintgriffith/scaffold-eth/tree/meta-multi-sig)
//    (off-chain signature based multi-sig)
//  added a very simple streaming mechanism where `onlySelf` can open a withdraw-based stream

// solhint-disable-next-line compiler-version
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MetaMultiSigWallet {
  event Deposit(address indexed sender, uint amount, uint balance);
  event Owner(address indexed owner, bool added);

  // on-chain variables
  mapping(address => bool) public isOwner;
  uint public signaturesRequired;
  uint public nonce;
  uint public chainId;

  constructor (uint _chainId, address[] memory _owners, uint _signaturesRequired) public {
    // solhint-disable-next-line reason-string
    require(
      _owners.length >= _signaturesRequired,
      "Required signatures cannot be larger than the number of owners."
    );
    chainId = _chainId;
    signaturesRequired = _signaturesRequired;
    nonce = 0;
    for (uint idx = 0; idx < _owners.length; idx++) {
      address owner = _owners[idx];
      require (owner != address(0), "Owner address cannot be 0x0.");
      require (!isOwner[owner], "Duplicated owner.");
      isOwner[owner] = true;
    }
  }

  modifier onlySelf() {
    require(msg.sender == address(this), "Cannot be called by others");
    _;
  }

  function addSigner(address _newSigner) public onlySelf() {
    require (owner != address(0), "Owner address cannot be 0x0.");
    require(!isOwner[_newSigner], "Duplicated owner.");
    isOwner[_newSigner] = true;
    emit Owner(_newSigner, true);
  }

  receive() external payable {
    emit Deposit(msg.sender, msg.value, address(this).balance);
  }
}
