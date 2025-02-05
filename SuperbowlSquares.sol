// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract SuperBowlSquares {
    address public owner;
    uint256 public constant SQUARE_PRICE = 361000000000000; // 0.00361 ETH in wei. Change this entry amount to whatever you wish IN WEI.
    uint256 public constant OWNER_FEE = 10; // 10% - Percentage of the entry amount gos to contract owner as a service fee.
    uint256 public constant PAYOUT_PERCENTAGE = 25; // 25% payour per winner. Superbowl has 4 quarters so each quarter the winner is paid 25% of the prize pool.

    struct Square {
        address player;
        bool occupied;
    }

    // Grid representation: [Chiefs][Eagles]
    mapping(uint8 => mapping(uint8 => Square)) public grid;
    
    uint8 public payoutCount;
    uint256 public contractBalance;
    bool public gameEnded;

    event SquarePurchased(address indexed player, uint8 chiefsNumber, uint8 eaglesNumber);
    event WinnerPaid(address indexed winner, uint8 chiefsNumber, uint8 eaglesNumber, uint256 amount);
    event GameEnded();

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier gameActive() {
        require(!gameEnded, "Game has ended");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function purchaseSquare(uint8 chiefsNumber, uint8 eaglesNumber) external payable gameActive {
        require(chiefsNumber < 10 && eaglesNumber < 10, "Numbers must be 0-9");
        require(msg.value == SQUARE_PRICE, "Incorrect payment amount");
        require(!grid[chiefsNumber][eaglesNumber].occupied, "Square already occupied");

        uint256 ownerFeeAmount = (msg.value * OWNER_FEE) / 100;
        uint256 contractAmount = msg.value - ownerFeeAmount;

        payable(owner).transfer(ownerFeeAmount);
        contractBalance += contractAmount;

        grid[chiefsNumber][eaglesNumber] = Square(msg.sender, true);
        emit SquarePurchased(msg.sender, chiefsNumber, eaglesNumber);
    }

    function isSquareAvailable(uint8 chiefsNumber, uint8 eaglesNumber) external view returns (bool) {
        require(chiefsNumber < 10 && eaglesNumber < 10, "Numbers must be 0-9");
        return !grid[chiefsNumber][eaglesNumber].occupied;
    }

    function declareWinner(uint8 chiefsNumber, uint8 eaglesNumber) external onlyOwner gameActive {
        require(chiefsNumber < 10 && eaglesNumber < 10, "Numbers must be 0-9");
        require(grid[chiefsNumber][eaglesNumber].occupied, "Winning square not purchased");
        require(payoutCount < 4, "All payouts completed");

        address winner = grid[chiefsNumber][eaglesNumber].player;
        uint256 payoutAmount = (contractBalance * PAYOUT_PERCENTAGE) / 100;
        
        payoutCount++;
        contractBalance -= payoutAmount;
        payable(winner).transfer(payoutAmount);

        emit WinnerPaid(winner, chiefsNumber, eaglesNumber, payoutAmount);

        if (payoutCount == 4) {
            gameEnded = true;
            emit GameEnded();
        }
    }

    function getSquareOwner(uint8 chiefsNumber, uint8 eaglesNumber) external view returns (address) {
        require(chiefsNumber < 10 && eaglesNumber < 10, "Numbers must be 0-9");
        return grid[chiefsNumber][eaglesNumber].player;
    }
}
