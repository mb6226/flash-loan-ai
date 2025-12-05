const { expect } = require('chai');
const { ethers } = require('hardhat');

describe("🧪 Flash Loan Arbitrage MVP Test", function () {
  let flashLoanAI;
  let owner;
  let addr1;
  let uniswapRouter;
  let sushiswapRouter;
  let weth;
  let usdc;
  let mockPool;

  before(async function () {
    // گرفتن حساب‌ها
    [owner, addr1] = await ethers.getSigners();

    // دیپلوی قراردادهای mock برای تست
    const MockToken = await ethers.getContractFactory("MockToken", owner);
    weth = await MockToken.deploy("Wrapped ETH", "WETH", 18);
    await weth.deployed();
    usdc = await MockToken.deploy("USD Coin", "USDC", 6);
    await usdc.deployed();

    const MockRouter = await ethers.getContractFactory("MockRouter", owner);
    uniswapRouter = await MockRouter.deploy();
    await uniswapRouter.deployed();
    sushiswapRouter = await MockRouter.deploy();
    await sushiswapRouter.deployed();

    // set prices: Uniswap 2000, Sushiswap 2020 (priceScaled uses 1e18)
    await uniswapRouter.setPriceScaled(ethers.BigNumber.from('2000').mul(ethers.BigNumber.from('1000000000000000000')));
    await sushiswapRouter.setPriceScaled(ethers.BigNumber.from('2020').mul(ethers.BigNumber.from('1000000000000000000')));

    // deploy mock Aave pool
    const MockAavePool = await ethers.getContractFactory("MockAavePool", owner);
    mockPool = await MockAavePool.deploy();
    await mockPool.deployed();

    // دیپلوی قرارداد فلش لون با pool mock
    const FlashLoanAI = await ethers.getContractFactory("FlashLoanAI", owner);
    flashLoanAI = await FlashLoanAI.deploy(mockPool.address);
    await flashLoanAI.deployed();

    console.log("✅ Contracts deployed to:", flashLoanAI.address);
  });

  it("Should detect arbitrage opportunity", async function () {
    // Minting to pool so it has assets to lend
    await weth.mint(mockPool.address, ethers.utils.parseEther("10"));
    await usdc.mint(mockPool.address, ethers.utils.parseUnits("100000", 6));

    // For this test the router returns computed amounts, so no token transfers required
    const opportunity = {
      path: [uniswapRouter.address, weth.address, usdc.address],
      reversalPath: [sushiswapRouter.address, usdc.address, weth.address],
      minProfit: ethers.utils.parseEther("0.01")
    };

    const tx = await flashLoanAI.executeAIFlashLoan(
      weth.address,
      ethers.utils.parseEther("1"),
      opportunity
    );

    const receipt = await tx.wait();
    expect(receipt.status).to.equal(1);

    console.log("🎯 Arbitrage executed successfully!");
  });

  it("Should handle no-profit scenario", async function () {
    const badOpportunity = {
      path: [uniswapRouter.address, weth.address, usdc.address],
      reversalPath: [sushiswapRouter.address, usdc.address, weth.address],
      minProfit: ethers.utils.parseEther("1000") // impossible
    };

    await expect(
      flashLoanAI.executeAIFlashLoan(
        weth.address,
        ethers.utils.parseEther("1"),
        badOpportunity
      )
    ).to.be.revertedWith("No profit generated");
  });

  it("Should allow emergency withdraw", async function () {
    // Mint to contract and verify withdraw
    await weth.mint(flashLoanAI.address, ethers.utils.parseEther("5"));

    const balanceBefore = await weth.balanceOf(owner.address);
    await flashLoanAI.emergencyWithdraw(weth.address);
    const balanceAfter = await weth.balanceOf(owner.address);

    expect(balanceAfter.sub(balanceBefore)).to.equal(ethers.utils.parseEther("5"));
  });
});
