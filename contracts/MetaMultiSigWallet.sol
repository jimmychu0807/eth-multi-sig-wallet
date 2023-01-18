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

contract MetaMultiSigWallet {
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
    address to,
    uint value,
    bytes memory data
  ) private returns (bytes32) {
    return keccak256(abi.encodePacked(chainId, address(this), nonce++, to, value, data));
  }

  // A key here is that signatures need to be sorted when calling this functions
  function executeTransaction(address to, uint value, bytes memory data, bytes[] memory signatures)
    public
    returns (bytes memory)
  {
    require(isOwner[msg.sender], "Only the contract owner can execute transactions");
    bytes32 hash = getTransactionHash(to, value, data);

    console.log("tx hash");
    console.logBytes32(hash);

    uint validSignatures = 0;
    address duplicateGuard = address(0);

    for (uint i = 0; i < signatures.length; i++) {
      bytes32 signedMsgHash = ECDSA.toEthSignedMessageHash(hash);
      console.log("eth signed message");
      console.logBytes32(signedMsgHash);

      address recoveredAddr = ECDSA.recover(signedMsgHash, signatures[i]);
      console.log("recovered addr: %s", recoveredAddr);

      if (duplicateGuard >= recoveredAddr) {
        console.log("duplicated addr: %s", recoveredAddr);
      } else if (isOwner[recoveredAddr]) {
        validSignatures++;
        duplicateGuard = recoveredAddr;
      }
    }

    require(validSignatures >= signaturesRequired, "executeTransaction: not enough valid signatures");

    // TODO: need to actually call the function with arguments here
    //

    bytes memory result = "result";

    emit ExecuteTransaction(msg.sender, to, value, data, nonce - 1, hash, result);

    return result;
  }

  receive() external payable {
    emit Deposit(msg.sender, msg.value, address(this).balance);
  }
}
