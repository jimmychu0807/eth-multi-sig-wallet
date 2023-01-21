import hre from "hardhat";
import { expect } from "chai";
import { Contract } from "ethers";

const { ethers, getNamedAccounts, deployments } = hre;
const { BigNumber } = ethers;
const { keccak256, toUtf8Bytes } = ethers.utils;

const MAIN_CURRENCY = 0;
const DEFAULT_MINT_AMT = BigNumber.from("1000000000000000000");
const adminRole = keccak256(toUtf8Bytes("DEFAULT_ADMIN_ROLE"));

describe("Tokens contract", () => {
  let tokens: Contract;

  beforeEach(async () => {
    const [deployer] = await ethers.getSigners();
    let factory = await ethers.getContractFactory("Tokens");
    tokens = await factory.deploy();
  });

  it("deployment", async () => {
    const { deployer } = await getNamedAccounts();

    expect(
      await tokens.hasRole(adminRole, deployer)
    ).to.true;

    const amt = await tokens.balanceOf(deployer, MAIN_CURRENCY);
    expect(amt.eq(DEFAULT_MINT_AMT)).to.true;
  })
})
