// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract NumSum {
    address public owner;
    uint256 public minBet = 0.001 ether;  // Minimum bet (0.001 ETH)
    uint256 public winMultiplier = 2;     // Winner gets 2× their bet

    event Played(
        address indexed player,
        uint8 a,
        uint8 b,
        uint8 sum,
        uint8 guess,
        bool won,
        uint256 bet,
        uint256 payout
    );

    constructor() {
        owner = msg.sender; // deployer = owner
    }

    // --- PLAY FUNCTION ---
    function play(uint8 guess) external payable {
        require(msg.value >= minBet, "Bet too low");
        require(guess <= 18, "Guess must be 0-18");

        // generate pseudo-random numbers (not secure)
        uint256 random = uint256(
            keccak256(
                abi.encodePacked(block.timestamp, msg.sender, block.prevrandao)
            )
        );

        uint8 a = uint8(random % 10);
        uint8 b = uint8((random / 10) % 10);
        uint8 sum = a + b;

        bool won = (guess == sum);
        uint256 payout = 0;

        if (won) {
            payout = msg.value * winMultiplier;
            if (payout > address(this).balance) {
                payout = address(this).balance;
            }
            (bool sent, ) = payable(msg.sender).call{value: payout}("");
            require(sent, "Payout failed");
        }

        emit Played(msg.sender, a, b, sum, guess, won, msg.value, payout);
    }

    // --- OWNER FUNCTIONS ---
    receive() external payable {}

    function withdraw(uint256 amount) external {
        require(msg.sender == owner, "Only owner");
        require(amount <= address(this).balance, "Not enough balance");
        payable(owner).transfer(amount);
    }

    function contractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

