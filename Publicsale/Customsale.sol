
pragma solidity ^0.4.18;

import './SafeMath.sol';

interface token { 
    function transfer(address receiver, uint amount) external ;
    
}

contract Crowdsale {
    using SafeMath for uint256;
    address public beneficiary; 
    uint public fundingGoal;
    uint durationInMinutes;
    uint public amountRaised;
    uint public deadline;
    uint public price;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool fundingGoalReached = false;
    bool crowdsaleClosed = false;

    event GoalReached(address recipient, uint totalAmountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);

    /**
     * Constrctor function
     *
     * Setup the owner
     */
     
    function Crowdsale() public {
        beneficiary = ; //place desired address eligible to withdraw eth from this contract.
        fundingGoal = 1 ether;
        durationInMinutes = 43200;
        deadline = now.add(durationInMinutes.mul(1 minutes));
        price = 500000000000000 wei;
        tokenReward = token(0x03B2DC629520693e69339BAF84fD74CDcCCB275C); // place token contract address of the desired token to be issued. 
    }

    /**
     * Fallback function
     * The function without name is the default function that is called whenever anyone sends funds to a contract.
     */
    function () internal payable {        
        require(!crowdsaleClosed);      // Crowdsale must still be open.
        uint amount = msg.value;
        balanceOf[msg.sender] = balanceOf[msg.sender].add(amount);
        amountRaised = amountRaised.add(amount);
        tokenReward.transfer(msg.sender, (amount.div(price)) * 1 ether); // Transfer Reward tokens to purchaser.
        FundTransfer(msg.sender, amount, true);     // Trigger and publicly log event 
    }

    modifier afterDeadline() { if (now >= deadline) _; } // Checks if the time limit has been reached.
    
    function checkGoalReached() internal afterDeadline {  // After the deadline.
        if (amountRaised >= fundingGoal){               // Check if goal was reached.
            fundingGoalReached = true;                  // If goal was reached.
            GoalReached(beneficiary, amountRaised);     // Trigger and publicly log event.
        }
        crowdsaleClosed = true;                         // End this crowdsale. 
    }


    /**
     * Withdraw the funds
     *
     * Checks to see if goal or time limit has been reached, and if so, and the funding goal was reached,
     * sends the entire amount to the beneficiary. If goal was not reached beneficiary can withdraw available funds.
     */
    function safeWithdrawal() public afterDeadline {            // After the deadline.
        checkGoalReached();                                     // Checks is the funding goal was reached.
        if (!fundingGoalReached && beneficiary == msg.sender) { // If funding goal was not reached and Beneficiary is the caller.
            withdraw();                                         // Beneficiary is allowed withdraw funds raised to beneficiary's account.
            FundTransfer(beneficiary, amountRaised, false);     // Trigger and publicly log event. 
            } else {
                fundingGoalReached = true;                      // Funding goal was reached.
            }

        if (fundingGoalReached && beneficiary == msg.sender) {  // If funding goal was reached and Beneficiary is the caller.
            withdraw();                                         // Beneficiary is allowed withdraw funds raised to beneficiary's account.
            FundTransfer(beneficiary, amountRaised, false);     // Trigger and publicly log event.
            } else {
                fundingGoalReached = false;                     // Fund goal was not reached.
            }
    }
    
    function withdraw() internal {
        uint cash = amountRaised;
        amountRaised = 0;
        beneficiary.transfer(cash); // transfer all ether to beneficiary address.
    }

}


