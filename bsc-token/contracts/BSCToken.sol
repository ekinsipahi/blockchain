// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./Airdrop.sol";
import "./TokenLock.sol";


/**
 * @title BSCToken
 * @dev ERC-20 token with Airdrop and ICO functionalities.
 */
contract BSCToken is ERC20, Ownable, Airdrop, TokenLock {

    /**
     * @dev Constructor to initialize the BSCToken contract.
     * @param initialOwner The initial owner's address.
     */

    constructor(address initialOwner) 
    ERC20("BSCToken", "BSCT") 
    Ownable(initialOwner) 
    // Airdrop tokens are 15% of total supply.
    Airdrop((1000000000 * (10**18) * 0.15))
    // In 200 days the tokens will be unlocked 10% every month.
    TokenLock((block.timestamp + 200 days)){

      // Initial supply 1 billion tokens (100%).
      uint _totalSupply = 1000000000 * (10**18);

      // Mint 150 million (15%) tokens for airdrop distribution.
      uint256 airdropSupply = (_totalSupply * 15 ) / 100;
      _mint(address(this), airdropSupply);

      // Mint 280 million (28%) tokens for ICO across four phases (70 million each).
      uint256 icoSupply = (_totalSupply * 7) / 100;
      _mint(address(this), icoSupply);
      _mint(address(this), icoSupply);
      _mint(address(this), icoSupply);
      _mint(address(this), icoSupply);

      // Mint the remaining 570 million (57%) tokens for the initial owner.
      uint256 supplyLeft = (_totalSupply * 57) / 100;
      _mint(initialOwner, supplyLeft);
    }

    /**
     * @dev Allow users to request airdrop tokens.
     * @param _to The address to which airdrop tokens will be transferred.
     */
    function requestAirdrop(address _to) public {
        // Check if coins are still locked, if not we wont distribute anymore tokens!
        require(isLocked(), "Too late to request and airdrop!");

        // Check if the user is eligible to claim the airdrop.
        require(claimAirdrop(_to), "Airdrop distribution has concluded; you cannot claim more tokens.");

        // If eligible, transfer 25 tokens to the recipient.
        _transfer(address(this), _to, getAirdropDistributionAmount());
    }


    function getTokenBalance(address account) public view returns(uint){
        return balanceOf(account);
    }

    function transferableAmount(address sender, uint256 amount) internal returns(uint){
        uint totalWithdrawable = 0;
        if(hasReceivedAirdrop(sender) && !isLockTimeEnded()){

          // Get how much the airdrop reciepient recieved in total.
          uint alreadyWithdrawnAmount = getTotalAirdropTransfer(sender);
          
          // Get how much is distributed to all patients base amount.
          uint airdropDistributionAmount = getAirdropDistributionAmount();

          // Get how much is allowed to withdraw monthly.
          uint monthlyLimitAmount = calculateMonthlyWithdrawal(airdropDistributionAmount);
          
          // Get how much is user currently allowed to withdraw. (WHERE IS THE NORMAL COINS HE HAS?? ALLOWED TO SELL!!!)
          uint totalWithdrawableNow = canWithdrawNow(amount, alreadyWithdrawnAmount, monthlyLimitAmount);
          totalWithdrawable += totalWithdrawableNow;

          // Update the balance for the airdrop recieve so user can be tracked. about how much he recieved this month.
          updateTotalTransfers(sender, amount);

        }
        return totalWithdrawable;
    }

    function transfer(address recipient, uint256 amount) public override returns(bool){
        // Call the standard ERC-20 transfer function using super
        // we need a lock mechanisim here that disables tranfer method.
        require(transferableAmount(msg.sender, amount) > 0, "Cannot transfer this!");
        return super.transfer(recipient, amount);
    }

}
