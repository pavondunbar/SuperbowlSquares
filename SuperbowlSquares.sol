//SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract SuperBowlSquares {
    address public owner;
    uint256 public constant SQUARE_PRICE = 36050000000000000;
    uint256 public constant OWNER_FEE = 10;
    uint256 public constant PAYOUT_PERCENTAGE = 25;
    string public constant CHIEFS = "chiefs";
    string public constant EAGLES = "eagles";

    struct Square {
        address player;
        bool occupied;
        string horizontal;
        string vertical;
    }

    mapping(uint8 => mapping(uint8 => Square)) public grid;
    
    uint8 public payoutCount;
    uint256 public contractBalance;
    bool public gameEnded;
    bool public gameStarted;

    event SquarePurchased(address indexed player, uint8 chiefsNumber, uint8 eaglesNumber);
    event WinnerPaid(address indexed winner, uint8 chiefsNumber, uint8 eaglesNumber, uint256 amount);
    event GameStarted(uint256 timestamp);
    event GameEnded();
    event FundsWithdrawn(uint256 amount);

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
        for(uint8 i = 0; i < 10; i++) {
            for(uint8 j = 0; j < 10; j++) {
                grid[i][j].horizontal = CHIEFS;
                grid[i][j].vertical = EAGLES;
            }
        }
    }

    function startGame() external onlyOwner {
        require(!gameStarted, "Game already started");
        gameStarted = true;
        emit GameStarted(block.timestamp);
    }

    function endGame() external onlyOwner {
        require(gameStarted, "Game hasn't started");
        require(!gameEnded, "Game already ended");
        
        gameEnded = true;
        emit GameEnded();
    }

    function withdrawFunds() external onlyOwner {
        require(gameEnded, "Game must be ended before withdrawal");
        require(contractBalance > 0, "No funds to withdraw");
        
        uint256 amount = contractBalance;
        contractBalance = 0;
        payable(owner).transfer(amount);
        emit FundsWithdrawn(amount);
    }

    function purchaseSquare(uint8 chiefsNumber, uint8 eaglesNumber) external payable gameActive {
        require(!gameStarted, "Game has already started");
        require(chiefsNumber < 10 && eaglesNumber < 10, "Numbers must be 0-9");
        require(msg.value == SQUARE_PRICE, "Incorrect payment amount");
        require(!grid[chiefsNumber][eaglesNumber].occupied, "Square already occupied");

        uint256 ownerFeeAmount = (msg.value * OWNER_FEE) / 100;
        uint256 contractAmount = msg.value - ownerFeeAmount;

        payable(owner).transfer(ownerFeeAmount);
        contractBalance += contractAmount;

        grid[chiefsNumber][eaglesNumber].player = msg.sender;
        grid[chiefsNumber][eaglesNumber].occupied = true;
        emit SquarePurchased(msg.sender, chiefsNumber, eaglesNumber);
    }

    function isSquareAvailable(uint8 chiefsNumber, uint8 eaglesNumber) external view returns (bool) {
        require(chiefsNumber < 10 && eaglesNumber < 10, "Numbers must be 0-9");
        return !grid[chiefsNumber][eaglesNumber].occupied;
    }

    function declareWinner(uint8 chiefsNumber, uint8 eaglesNumber) external onlyOwner gameActive {
        require(gameStarted, "Game hasn't started");
        require(chiefsNumber < 10 && eaglesNumber < 10, "Numbers must be 0-9");
        require(payoutCount < 4, "All payouts completed");

        uint256 quarterShare = (contractBalance * PAYOUT_PERCENTAGE) / 100;
        payoutCount++;
        
        if (grid[chiefsNumber][eaglesNumber].occupied) {
            address winner = grid[chiefsNumber][eaglesNumber].player;
            contractBalance -= quarterShare;
            payable(winner).transfer(quarterShare);
            emit WinnerPaid(winner, chiefsNumber, eaglesNumber, quarterShare);
        }

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
