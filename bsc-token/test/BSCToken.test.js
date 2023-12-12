const BSCToken = artifacts.require('BSCToken');
const { time, expectEvent } = require('@openzeppelin/test-helpers');

const {parseUnits} = require('ethers');

contract("BSCToken", (accounts) => {
    it("total supply is 1BILLION", async () => {
        const BSCTokenInstance = await BSCToken.deployed();
        const totalSupply = await BSCTokenInstance.totalSupply();
        

        assert.equal(totalSupply.toString(), "1000000000"+"000000000000000000", "Total supply is not 1BILLION");
    });
    it("28% ICO + 15% airdrop = 430Million (%43) supply in contract itself.", async () => {
        const BSCTokenInstance = await BSCToken.deployed();
        const contractAddress = BSCTokenInstance.address;

        const icoAndAirdropSupply = await BSCTokenInstance.balanceOf(contractAddress);

        assert.equal(icoAndAirdropSupply.toString(), "430000000"+"000000000000000000", "airdrop supply + ICO supply is not 430million");
        
    });
    it("Total supply of airdrop in AIRDROP CONTRACT is 100Million", async () => {
        const BSCTokenInstance = await BSCToken.deployed();
        const airdropLimit = await BSCTokenInstance.getAirdropLimit();

        assert.equal(airdropLimit, "150000000" + "000000000000000000", 'Airdrop limit is not as expected');
    });
    it("Check whether someone can request airdrop twice", async () => {
        const BSCTokenInstance = await BSCToken.deployed();
        await BSCTokenInstance.requestAirdrop(accounts[1]);
        try{
            await BSCTokenInstance.requestAirdrop(accounts[1]);
        }catch(e){
        }
        const accountBalance = await BSCTokenInstance.balanceOf(accounts[1]);
        assert.equal(accountBalance, "25" + "000000000000000000", "User has requested airdrop twice");
    });
    it("Try selling airdrop before release date!", async () => {
        const BSCTokenInstance = await BSCToken.deployed();
        await BSCTokenInstance.requestAirdrop(accounts[8]);
        await BSCTokenInstance.requestAirdrop(accounts[4]);


        try{
            await BSCTokenInstance.transfer(accounts[0], "1" + "250000000000000000", { from: accounts[8] });
        }catch(err){

        }
        const accountBalance = await BSCTokenInstance.balanceOf(accounts[8])
        assert.equal(await accountBalance.toString(), "25" + "000000000000000000", "User redeemed the airdrop before the release date");
        

    });
    it("Airdrop tokens to an account then fast forward the time 201 days, try selling under limit twice.", async () => {
        const BSCTokenInstance = await BSCToken.deployed();

        await time.increase(86400 * 201);

        await BSCTokenInstance.transfer(accounts[0], "1" + "250000000000000000", { from: accounts[1] });
        await BSCTokenInstance.transfer(accounts[0], "1" + "250000000000000000", { from: accounts[1] });

        const accountBalance = await BSCTokenInstance.balanceOf(accounts[1])
        assert.equal(await accountBalance.toString(), "22" + "500000000000000000", "User redeemed the airdrop before the release date");

        
    });
    it("Fast forwarded time 201 days, cannot sell over limit.", async () => {
        const BSCTokenInstance = await BSCToken.deployed();

        try{
            await BSCTokenInstance.transfer(accounts[0], "3" + "500000000000000000", { from: accounts[4] });
        }catch(e){
        }

        const accountBalance = await BSCTokenInstance.balanceOf(accounts[4])
        assert.equal(await accountBalance.toString(), "25" + "000000000000000000", "User redeemed the airdrop before the release date");

    });
    it("Airdrop tokens on an account, fast forward 30 days then try selling coins again under limit twice.", async () => {
        const BSCTokenInstance = await BSCToken.deployed();

        await time.increase(86400 * 31);

        await BSCTokenInstance.transfer(accounts[0], "1" + "250000000000000000", { from: accounts[1] });
        await BSCTokenInstance.transfer(accounts[0], "1" + "250000000000000000", { from: accounts[1] });

        const accountBalance = await BSCTokenInstance.balanceOf(accounts[1])
        assert.equal(await accountBalance.toString(), "20" + "000000000000000000", "User cannot withdraw more in future lock openings.");

    });
    it("Airdrop tokens on an account, fast forward 60 days then try selling coins again under limit twice.", async () => {
        const BSCTokenInstance = await BSCToken.deployed();

        await time.increase(86400 * 61);

        await BSCTokenInstance.transfer(accounts[0], "1" + "250000000000000000", { from: accounts[1] });
        await BSCTokenInstance.transfer(accounts[0], "1" + "250000000000000000", { from: accounts[1] });

        const accountBalance = await BSCTokenInstance.balanceOf(accounts[1])
        assert.equal(await accountBalance.toString(), "17" + "500000000000000000", "User cannot withdraw more in future lock openings.");

    });
    it("Try airdropping after token release date! Which should not get sent!", async () => {
        const BSCTokenInstance = await BSCToken.deployed();

        try{
            await BSCTokenInstance.requestAirdrop(accounts[9]);
        }catch(e){};

        const accountBalance = await BSCTokenInstance.balanceOf(accounts[9])

        assert.equal(await accountBalance.toString(), "0", "User did requested an airdrop after token release date.");


    });


})
