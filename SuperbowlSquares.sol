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
    bool public refundsEnabled;

    event SquarePurchased(address indexed player, uint8 chiefsNumber, uint8 eaglesNumber);
    event WinnerPaid(address indexed winner, uint8 chiefsNumber, uint8 eaglesNumber, uint256 amount);
    event UnoccupiedSquareRollover(uint8 chiefsNumber, uint8 eaglesNumber, uint256 amount);
    event GameStarted(uint256 timestamp);
    event GameEnded(bool refundsEnabled);
    event RefundClaimed(address indexed player, uint256 amount);

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

    function endGame(bool enableRefunds) external onlyOwner {
        require(gameStarted, "Game hasn't started");
        require(!gameEnded, "Game already ended");
        require(payoutCount == 0 || enableRefunds == false, "Cannot enable refunds after payouts");
        
        gameEnded = true;
        refundsEnabled = enableRefunds;
        emit GameEnded(enableRefunds);
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

    function claimRefund(uint8 chiefsNumber, uint8 eaglesNumber) external {
        require(refundsEnabled, "Refunds not enabled");
        require(grid[chiefsNumber][eaglesNumber].occupied, "No square purchased");
        require(grid[chiefsNumber][eaglesNumber].player == msg.sender, "Not square owner");
        
        uint256 refundAmount = (SQUARE_PRICE * 90) / 100;
        grid[chiefsNumber][eaglesNumber].occupied = false;
        grid[chiefsNumber][eaglesNumber].player = address(0);
        
        contractBalance -= refundAmount;
        payable(msg.sender).transfer(refundAmount);
        
        emit RefundClaimed(msg.sender, refundAmount);
    }

    function isSquareAvailable(uint8 chiefsNumber, uint8 eaglesNumber) external view returns (bool) {
        require(chiefsNumber < 10 && eaglesNumber < 10, "Numbers must be 0-9");
        return !grid[chiefsNumber][eaglesNumber].occupied;
    }

    function declareWinner(uint8 chiefsNumber, uint8 eaglesNumber) external onlyOwner gameActive {
        require(gameStarted, "Game hasn't started");
        require(chiefsNumber < 10 && eaglesNumber < 10, "Numbers must be 0-9");
        require(payoutCount < 4, "All payouts completed");

        uint256 remainingQuarters = 4 - payoutCount;
        uint256 quarterShare = (contractBalance * PAYOUT_PERCENTAGE) / 100;
        uint256 accumulatedShare = quarterShare * (payoutCount + 1);
        
        payoutCount++;
        
        if (grid[chiefsNumber][eaglesNumber].occupied) {
            address winner = grid[chiefsNumber][eaglesNumber].player;
            uint256 payoutAmount;
            
            if (payoutCount == 4) {
                payoutAmount = contractBalance;
            } else {
                payoutAmount = accumulatedShare;
            }
            
            contractBalance -= payoutAmount;
            payable(winner).transfer(payoutAmount);
            emit WinnerPaid(winner, chiefsNumber, eaglesNumber, payoutAmount);
        } else {
            // If it's the final quarter with no winner, distribute remaining balance to previous winners
            if (payoutCount == 4 && contractBalance > 0) {
                distributeRemainingBalance();
            } else {
                emit UnoccupiedSquareRollover(chiefsNumber, eaglesNumber, quarterShare);
            }
        }

        if (payoutCount == 4) {
            gameEnded = true;
            if(contractBalance > 0) {
                refundsEnabled = true;
            }
            emit GameEnded(refundsEnabled);
        }
    }

    function distributeRemainingBalance() internal {
        // Get all previous winners
        address[] memory winners = new address[](3);
        uint256 winnerCount = 0;
        
        for(uint8 i = 0; i < 10; i++) {
            for(uint8 j = 0; j < 10; j++) {
                if(grid[i][j].occupied && isWinnerFromPreviousQuarters(grid[i][j].player)) {
                    bool isDuplicate = false;
                    for(uint256 k = 0; k < winnerCount; k++) {
                        if(winners[k] == grid[i][j].player) {
                            isDuplicate = true;
                            break;
                        }
                    }
                    if(!isDuplicate && winnerCount < 3) {
                        winners[winnerCount] = grid[i][j].player;
                        winnerCount++;
                    }
                }
            }
        }

        if(winnerCount > 0) {
            uint256 distribution = contractBalance / winnerCount;
            for(uint256 i = 0; i < winnerCount; i++) {
                payable(winners[i]).transfer(distribution);
                emit WinnerPaid(winners[i], 99, 99, distribution);
            }
            contractBalance = 0;
        }
    }

    function isWinnerFromPreviousQuarters(address player) internal view returns (bool) {
        for(uint8 i = 0; i < 10; i++) {
            for(uint8 j = 0; j < 10; j++) {
                if(grid[i][j].player == player && grid[i][j].occupied) {
                    return true;
                }
            }
        }
        return false;
    }

    function getSquareOwner(uint8 chiefsNumber, uint8 eaglesNumber) external view returns (address) {
        require(chiefsNumber < 10 && eaglesNumber < 10, "Numbers must be 0-9");
        return grid[chiefsNumber][eaglesNumber].player;
    }
}
