const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('MockDEX', function () {
  it('should set price and return correct amounts', async function () {
    const MockToken = await ethers.getContractFactory('MockToken');
    const MockDEX = await ethers.getContractFactory('MockDEX');

    // deploy tokens
    const tokenA = await MockToken.deploy('TokenA', 'TKA', 18);
    await tokenA.deployed();
    const tokenB = await MockToken.deploy('TokenB', 'TKB', 6);
    await tokenB.deployed();

    // deploy dex
    const dex = await MockDEX.deploy();
    await dex.deployed();

    // set price: 1 tokenA = 1.5 tokenB (scaled by 1e18)
    const price = ethers.BigNumber.from('1500000000000000000'); // 1.5e18
    await dex.setPrice(tokenA.address, tokenB.address, price);

    // call getAmountsOut for 1e18 (1 tokenA), path A->B
    const amountIn = ethers.utils.parseEther('1');
    const path = [tokenA.address, tokenB.address];
    const amounts = await dex.getAmountsOut(amountIn, path);

    // amountOut should be 1*1.5 => 1.5 tokenB but tokenB decimals are 6, internal math assumes 18-scale
    // Since we deployed tokenB with 6 decimals, this test uses 1e18 scaling
    expect(amounts[1].toString()).to.equal('1500000000000000000');
  });
});
