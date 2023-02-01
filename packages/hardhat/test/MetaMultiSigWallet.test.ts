import { expect } from "chai";
import hre from "hardhat";

const { ethers } = hre;
import { Contract } from "ethers";

const CHAIN_ID: number = 31337;
const MSGS = {
  EXEC_TX_NOT_ENOUGH_SIGNS: "executeTransaction: not enough valid signatures",
};

describe("MultiSigWallet contract", () => {

  let contract: Contract;

  beforeEach(async() => {
    const [owner1, owner2] = await ethers.getSigners();
    const factory = await hre.ethers.getContractFactory("MultiSigWallet");
    contract = await factory.deploy(CHAIN_ID, [owner1.address, owner2.address], 2);
    await contract.deployTransaction.wait();
  });

  it("should initialize the contract correctly", async () => {
    const [owner1, _, user1] = await ethers.getSigners();

    // assert about chainId, signaturesRequired
    expect(await contract.nonce()).to.eq(0);
    expect(await contract.signaturesRequired()).to.eq(2);
    expect(await contract.isOwner(owner1.address)).to.be.true;
    expect(await contract.isOwner(user1.address)).to.be.false;
  });

  it("can sign a transaction, get a signature back, and recover the signer", async () => {
    const [owner1, _, user1] = await ethers.getSigners();

    const callData = contract.interface.encodeFunctionData("addSigner", [user1.address]);
    const nonce = await contract.nonce();
    const value = 0;
    const txHash = await contract.getTransactionHash(nonce, contract.address, value, callData);

    const signature = await ethers.provider.send("personal_sign", [
      txHash,
      owner1.address
    ]);

    const res = await contract.tryRecover(txHash, signature);
    expect(res[0]).to.eq(owner1.address);
    expect(res[1]).to.eq(0);
  });

  it("one signature is not enough to execute the tx, duplicate signatures doesn't work, two distinct ones are good", async() => {
    const [owner1, owner2, user1] = await ethers.getSigners();

    const callData = contract.interface.encodeFunctionData("addSigner", [user1.address]);
    const nonce = await contract.nonce();
    const value = 0;
    const txHash = await contract.getTransactionHash(nonce, contract.address, value, callData);
    const signature1 = await ethers.provider.send("personal_sign", [txHash, owner1.address]);

    // test 1: one signature is not enough to have the tx go thru.
    await expect(
      contract.executeTransaction(contract.address, 0, callData, [signature1])
    ).to.be.revertedWith(MSGS.EXEC_TX_NOT_ENOUGH_SIGNS);

    // test 2: duplicate signatures doesn't let the tx go thru.
    await expect(
      contract.executeTransaction(contract.address, 0, callData, [signature1, signature1])
    ).to.be.revertedWith(MSGS.EXEC_TX_NOT_ENOUGH_SIGNS);

    // test 3: non-owner doesn't let the tx go thru.
    const signatureUser1 = await ethers.provider.send("personal_sign", [txHash, user1.address]);
    await expect(
      contract.executeTransaction(contract.address, 0, callData, [signature1, signatureUser1])
    ).to.be.revertedWith(MSGS.EXEC_TX_NOT_ENOUGH_SIGNS);

    // test 4: two signatures from owner should have the tx go thru
    const signature2 = await ethers.provider.send("personal_sign", [txHash, owner2.address]);
    const resp = await contract
      .executeTransaction(contract.address, 0, callData, [signature1, signature2])

    const receipt = await resp.wait();

    expect(receipt.events.some(x => x.event === "ExecuteTransaction")).to.be.true;
    expect(receipt.events.some(x => x.event === "Owner")).to.be.true;
  });
});
