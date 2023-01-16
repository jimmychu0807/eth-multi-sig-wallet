import { expect } from "chai";
import hre from "hardhat";

const { ethers } = hre;

describe("MetaMultiSigWallet contract", () => {
  it ("should initialize the contract correctly", async () => {

    const signers = await ethers.getSigners();

    const MetaMultiSigWallet = await hre.ethers.getContractFactory("MetaMultiSigWallet");

    await expect(
      MetaMultiSigWallet.deploy(31337, [signers[0].address, signers[1].address], 3),
    ).to.be.reverted;

    const contract = await MetaMultiSigWallet.deploy(31337, [signers[0].address, signers[1].address], 2);

    // assert about chainId, signaturesRequired
    expect(await contract.nonce()).to.eq(0);
    expect(await contract.signaturesRequired()).to.eq(2);
  });
});
