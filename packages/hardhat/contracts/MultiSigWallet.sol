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
import "hardhat/console.sol";

contract MultiSigWallet {
  event Deposit(address indexed sender, uint amount, uint balance);
  event Owner(address indexed owner, bool added);
  event ExecuteTransaction(address indexed sender, address to, uint value, bytes data, uint nonce, bytes32 hash, bytes result);

  // on-chain states
  mapping(address => bool) public isOwner;
  uint public signaturesRequired;
  uint public totalOwners;
  uint public nonce;
  uint public chainId;

  constructor (uint _chainId, address[] memory _owners, uint _signaturesRequired) {
    // solhint-disable-next-line reason-string
    require(
      _owners.length >= _signaturesRequired,
      "Required signatures cannot be larger than the number of owners."
    );
    for (uint idx = 0; idx < _owners.length; idx++) {
      address owner = _owners[idx];
      require (owner != address(0), "Owner address cannot be 0x0.");
      require (!isOwner[owner], "Duplicated owner.");

      isOwner[owner] = true;

      emit Owner(owner, isOwner[owner]);
    }

    chainId = _chainId;
    signaturesRequired = _signaturesRequired;
    totalOwners = _owners.length;
    nonce = 0;
  }

  modifier onlySelf() {
    require(msg.sender == address(this), "Cannot be called by others");
    _;
  }

  function addSigner(address newSigner) public onlySelf {
    require (newSigner != address(0), "Owner address cannot be 0x0.");
    require (!isOwner[newSigner], "Duplicated owner.");

    isOwner[newSigner] = true;
    totalOwners += 1;

    emit Owner(newSigner, isOwner[newSigner]);
  }

  function getTransactionHash(
    uint _nonce,
    address to,
    uint value,
    bytes memory data
  ) public view returns (bytes32) {
    return keccak256(abi.encodePacked(chainId, address(this), _nonce, to, value, data));
  }

  function tryRecover(bytes32 _hash, bytes memory _signature) public pure returns(address, ECDSA.RecoverError) {
    return ECDSA.tryRecover(ECDSA.toEthSignedMessageHash(_hash), _signature);
  }

  // A key here is that signatures need to be sorted when calling this functions
  function executeTransaction(address to, uint value, bytes memory data, bytes[] memory signatures)
    public
    returns (bytes memory)
  {
    require(isOwner[msg.sender], "Only the contract owner can execute transactions");
    bytes32 hash = getTransactionHash(nonce, to, value, data);

    uint validSignatures = 0;

    address[] memory duplicateGuard = new address[](signatures.length - 1);
    address recoveredAddr;
    ECDSA.RecoverError errCode;

    for (uint sIdx = 0; sIdx < signatures.length; sIdx++) {
      (recoveredAddr, errCode) = ECDSA.tryRecover(ECDSA.toEthSignedMessageHash(hash), signatures[sIdx]);

      if (errCode != ECDSA.RecoverError.NoError) continue;

      // check duplicate
      bool bDup = false;
      for (uint dIdx = 0; dIdx < duplicateGuard.length; dIdx++) {
        if (duplicateGuard[dIdx] == recoveredAddr) {
          bDup = true;
          continue;
        }
      }

      if (bDup) continue;

      if (isOwner[recoveredAddr]) {
        validSignatures++;
        // save the signature if the signature is not the last one.
        if (sIdx != signatures.length - 1) duplicateGuard[duplicateGuard.length - 1] = recoveredAddr;
      }
    }

    require(validSignatures >= signaturesRequired, "executeTransaction: not enough valid signatures");

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory result) = to.call{value: value}(data);
    nonce++;

    require(success, "executeTransaction: tx failed");

    emit ExecuteTransaction(msg.sender, to, value, data, nonce - 1, hash, result);

    return result;
  }

  receive() external payable {
    emit Deposit(msg.sender, msg.value, address(this).balance);
  }
}
