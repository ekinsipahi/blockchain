// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title TokenLock
 * @dev Simple contract to manage token locking functionality.
 */

contract TokenLock {
    // Timestamp when tokens will be unlocked
    uint256[] private unlockDates;

    // Monthly withdrawal percentage
    uint256 public monthlyWithdrawalPercentage = 10;

    /**
     * @dev Constructor to set the unlock date.
     * @param _unlockDate Timestamp when tokens should be unlocked.
     */
    constructor(uint256 _unlockDate) {
        unlockDates = new uint256[](10);
        for (uint i = 0; i < 10; i++) {
            unlockDates[i] = _unlockDate + (30 days * i);
        }
    }

    /**
     * @dev Function to calculate the monthly withdrawal amount based on the total tokens.
     * @param totalTokens Total tokens available for withdrawal.
     * @return Monthly withdrawal amount.
     */
    function calculateMonthlyWithdrawal(uint256 totalTokens) public view returns (uint256) {
        // Calculate monthly withdrawal amount (10% of total tokens)
        return (totalTokens * monthlyWithdrawalPercentage) / 100;
    }
    
    /**
    * @dev Funtion to return how much the user allowed to withdraw now.
    * @return Boolean indicating lockTime is ended or not.
    */
    function isLockTimeEnded() public view returns (bool) {
        return unlockDates[unlockDates.length - 1] < block.timestamp;
    }
    
    
    /**
    * @dev Function to return release date in timestamp
    * @return Boolean indicating the coins are unlocked
    */
    function isLocked() public view returns(bool){
        return block.timestamp < unlockDates[0];
    }



    /**
     * @dev Funtion to return how much the user allowed to withdraw now.
     * @param amountRequested Users withdrawal amount request.
     * @param alreadyWithdrawnAmount User already withdrawn.
     * @param monthlyLimitAmount Allowed to withdraw every month.
     * @return Total withdrawal allowed now.
     */ 
    function canWithdrawNow(uint amountRequested, uint alreadyWithdrawnAmount, uint monthlyLimitAmount) internal view returns(uint){
        // need current timestamp.
        if(block.timestamp > unlockDates[0]){
            uint i;
            // then on the array of unlockDates we need to check which one we are closer to.
            for(i = 0; i < unlockDates.length; i++){
                if(unlockDates[i] > block.timestamp){
                    // then the previous one was the one we are currently on +1
                    break;
                }
            }
            // index * monthly amount = total that can be redeemed in current month.
            uint withdrawAllowedAmount = i * monthlyLimitAmount;


            // how much can be withdrawn?
            uint withdrawable = withdrawAllowedAmount - alreadyWithdrawnAmount;

            require(amountRequested <= withdrawable, "You cannot withdraw more than the limit for this month!");

            return withdrawable;
        }
        return 0;

    }
}