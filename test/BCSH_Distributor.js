const { Web3 } = require('web3');
require("dotenv").config();
const EthCrypto = require("eth-crypto");
const { expect } = require('chai');
const helpers = require("@nomicfoundation/hardhat-network-helpers");


describe("Blockchain_Superheroes", function () {
  const web3 = new Web3('https://sepolia.base.org')
  NFT_NAME = "BlockChainSuperHeros",
    NFT_SYMBOL = "BCSH",
    Min_GasToTransfer = 260000,
    LZ_ENDPOINT = "0x6EDCE65403992e310A62460808c4b910D972f10f",
    tokenPrice = '20000000000000000000'

  beforeEach(async function () {
    const [addr1, addr2] = await ethers.getSigners();
    this.addr1 = addr1;
    this.addr2 = addr2;

    const bcshContract = await ethers.getContractFactory("Blockchain_Superheroes");
    this.bcshContract = await bcshContract.connect(addr1).deploy(NFT_NAME, NFT_SYMBOL, Min_GasToTransfer, LZ_ENDPOINT);
    const BCSH_Distributor = await ethers.getContractFactory("BCSH_Distributor");
    this.BCSH_Distributor = await BCSH_Distributor.connect(addr1).deploy(this.bcshContract.target);
    const addModeratorTx = await this.bcshContract.connect(addr1).AddModerator(this.BCSH_Distributor.target);
  })

  it("Should mint token from distributor contract", async function () {
    const addr1Balance = await web3.eth.getBalance(this.addr1.address);
    const mintTx = await this.BCSH_Distributor.connect(this.addr1).mint({ value: tokenPrice });
    await mintTx.wait();
  });



  it("Should mint and deposit fund to bcshtoken contract", async function () {
    const mintTx = await this.BCSH_Distributor.connect(this.addr1).mint({ value: tokenPrice });
    await mintTx.wait();
    const balance = await this.bcshContract.connect(this.addr1).balanceOf(this.addr1.address);
    expect(balance).to.equal(1);
    // deposit fund to bcshtoken contract
    const depositTx = await this.bcshContract.connect(this.addr1).depositFund(1116000000001, { value: tokenPrice });
    await depositTx.wait();
  });

  // it should mint deposit and withdraw fund from bcshtoken contract

  it("Should mint, deposit and withdraw fund from bcshtoken contract", async function () {
    const mintTx = await this.BCSH_Distributor.connect(this.addr1).mint({ value: tokenPrice });
    await mintTx.wait();
    const balance = await this.bcshContract.connect(this.addr1).balanceOf(this.addr1.address);
    expect(balance).to.equal(1);
    // deposit fund to bcshtoken contract
    const depositTx = await this.bcshContract.connect(this.addr1).depositFund(1116000000001, { value: tokenPrice });
    await depositTx.wait();
    // withdraw fund from bcshtoken contract
    const withdrawTx = await this.bcshContract.connect(this.addr1).withdrawTokenDeposit(1116000000001, tokenPrice);
    await withdrawTx.wait();
  });

  // transfer token to another contract
  it("Should transfer, withdraw and fail fund from bcshtoken contract", async function () {
    const mintTx1 = await this.BCSH_Distributor.connect(this.addr1).mint({ value: tokenPrice });
    await mintTx1.wait();

    const deposite = await this.bcshContract.connect(this.addr1).depositFund(1116000000001, { value: "50000000000000" });
    await deposite.wait();

    const mintTx = await this.bcshContract.connect(this.addr1).transferFrom(this.addr1, this.addr2, 1116000000001);
    await mintTx.wait();
    const balance = await this.bcshContract.connect(this.addr1).balanceOf(this.addr1.address);
    expect(balance).to.equal(0);

    const balance2 = await this.bcshContract.connect(this.addr2).balanceOf(this.addr2.address);
    expect(balance2).to.equal(1);

    const balanceToken2 = await this.bcshContract.connect(this.addr2).tokenDeposits(1116000000001);
    expect(balanceToken2).to.equal("50000000000000");

    const withdrawTx1 = this.bcshContract.connect(this.addr1).withdrawTokenDeposit(1116000000001, tokenPrice);
    await expect(withdrawTx1).to.be.revertedWith("You are not the owner of this token");

    const withdrawTx2 = await this.bcshContract.connect(this.addr2).withdrawTokenDeposit(1116000000001, "50000000000000");
    await withdrawTx2.wait();

    const withdrawTx3 = this.bcshContract.connect(this.addr2).withdrawTokenDeposit(1116000000001, "50000000000000");
    await expect(withdrawTx3).to.be.revertedWith("Insufficient balance");
  });

  // it should mint and then like token

  it("Should mint and worship token", async function () {
    const mintTx = await this.BCSH_Distributor.connect(this.addr1).mint({ value: tokenPrice });
    await mintTx.wait();
    const balance = await this.bcshContract.connect(this.addr1).balanceOf(this.addr1.address);
    expect(balance).to.equal(1);
    const likeTx = await this.bcshContract.connect(this.addr1).highFiveToken(1116000000001);
    await likeTx.wait();
    const likeTx2 = await this.bcshContract.connect(this.addr1).highFiveToken(1116000000001);
    const likes = await this.bcshContract.connect(this.addr1).tokenHighFiversCount(1116000000001);
    expect(likes).to.equal(2);
  });
});
