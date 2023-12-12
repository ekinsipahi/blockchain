// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


/**
 * @title Airdrop Distribution Contract
 * @dev Contract for distributing airdrop tokens to eligible senders.
 */
abstract contract Airdrop {
    uint internal constant airdropDistributionIndividual = 25 * (10**18);


    // Mapping to track whether the sender has claimed the airdrop
    mapping(address => uint) private airdropClaimers;

    // Mapping to track total token transfers for each sender
    mapping(address => uint) private totalTransfers;

    // Maximum allowed tokens to be distributed as airdrop
    uint private _airdropLimit;

    // Total tokens withdrawn in the airdrop
    uint private _totalTokenWithdrawn;

    /**
     * @dev Constructor to initialize the airdrop contract with a maximum limit.
     * @param airdropLimit Maximum allowed tokens for airdrop.
     */
    constructor(uint airdropLimit){
        _airdropLimit = airdropLimit;
    }

    /**
     * @dev Get the maximum allowed tokens for airdrop.
     * @return Maximum allowed tokens for airdrop.
     */
    function getAirdropLimit() public view returns(uint){
        return _airdropLimit;
    }

    /**
     * @dev Function to check if a sender can claim the airdrop and perform the claim.
     * @param sender Address of the sender.
     * @return Whether the airdrop claim was successful.
     */
    function claimAirdrop(address sender) internal returns(bool){
        // Check if the airdrop limit has been reached
        require(_totalTokenWithdrawn < _airdropLimit, "Airdrop limit is over :(!");

        // Check if the sender has already claimed the airdrop
        require(airdropClaimers[sender] == 0, "Airdrop already claimed!");

        // Assign airdrop tokens to the sender
        airdropClaimers[sender] = airdropDistributionIndividual;

        return true;
    }

    function getAirdropDistributionAmount() internal pure returns(uint){
        return airdropDistributionIndividual;
    }

    /**
     * @dev Function to check if a sender has received the airdrop.
     * @param sender Address of the sender.
     * @return Whether the sender has received the airdrop.
     */
    function hasReceivedAirdrop(address sender) internal view returns(bool){
        return airdropClaimers[sender] > 0;
    }

    /**
     * @dev Function to get the total transfer amount for a sender.
     * @param sender Address of the sender.
     * @return Total transfer amount for the sender.
     */
    function getTotalAirdropTransfer(address sender) internal view returns(uint){
        return totalTransfers[sender];
    }

    /**
     * @dev Function to update the total Transfers for a account.
     * @param addr Address of the sender.
     */
    function updateTotalTransfers(address addr, uint amount) internal{
        totalTransfers[addr] += amount;
    }

}