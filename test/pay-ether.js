const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Test Quickzap", function () {
  const deadline = () => Math.ceil(Date.now() / 1000 + 60 * 5);
  let quickzap;
  let sender, receiver;

  beforeEach(async () => {
    const Quickzap = await ethers.getContractFactory("Quickzap");
    quickzap = await Quickzap.deploy();

    await quickzap.deployed();

    [sender, receiver] = await ethers.getSigners();

    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: ["0x0681d8db095565fe8a346fa0277bffde9c0edbbf"],
    });
  });

  it("should pay directly with Ether", async () => {
    const senderInitialBalance = await sender.getBalance();
    const receiverInitialBalance = await receiver.getBalance();
    const quickzapInitialBalance = await ethers.provider.getBalance(
      quickzap.address
    );

    console.log("Starting payment");
    await quickzap.pay(
      ["0x0000000000000000000000000000000000000000"],
      ethers.utils.parseEther("10"),
      ethers.utils.parseEther("9"),
      await receiver.getAddress(),
      deadline(),
      { value: ethers.utils.parseEther("10") }
    );
    console.log("Finished payment");
    expect(await sender.getBalance()).to.be.below(senderInitialBalance);
    expect(await receiver.getBalance()).to.be.equal(
      receiverInitialBalance.add(ethers.utils.parseEther("9"))
    );
    expect(await ethers.provider.getBalance(quickzap.address)).to.be.above(
      quickzapInitialBalance
    );
  });

  it("should emit Pay event", async () => {
    await expect(
      quickzap.pay(
        ["0x0000000000000000000000000000000000000000"],
        ethers.utils.parseEther("10"),
        ethers.utils.parseEther("9"),
        await receiver.getAddress(),
        deadline(),
        { value: ethers.utils.parseEther("10") }
      )
    )
      .to.emit(quickzap, "Payment")
      .withArgs(await sender.getAddress(), await receiver.getAddress());
  });

  it("should pay directly with token", async () => {
    sender = await ethers.provider.getSigner(
      "0x0681d8db095565fe8a346fa0277bffde9c0edbbf"
    );
    quickzap = quickzap.connect(sender);

    const ERC20 = await ethers.getContractFactory("ERC20");
    let DAI = await ERC20.attach("0x6b175474e89094c44da98b954eedeac495271d0f");
    DAI = DAI.connect(sender);
    const daiDecimals = await DAI.decimals();
    DAI.approve(await quickzap.address, ethers.constants.MaxUint256);

    const senderInitialBalance = await DAI.balanceOf(await sender.getAddress());
    const receiverInitialBalance = await DAI.balanceOf(
      await receiver.getAddress()
    );
    const quickzapInitialBalance = await DAI.balanceOf(quickzap.address);

    quickzap.pay(
      ["0x6b175474e89094c44da98b954eedeac495271d0f"],
      ethers.utils.parseUnits("100", daiDecimals),
      ethers.utils.parseUnits("90", daiDecimals),
      await receiver.getAddress(),
      deadline()
    );

    expect(await DAI.balanceOf(await sender.getAddress())).to.be.below(
      senderInitialBalance
    );
    expect(await DAI.balanceOf(await receiver.getAddress())).to.be.equal(
      receiverInitialBalance.add(ethers.utils.parseUnits("90", daiDecimals))
    );
  });

  xit("it should swap ether to token and pay", async () => {});

  xit("it should swap ether to pay", async () => {});

  xit("it should swap ether to pay", async () => {});
});
