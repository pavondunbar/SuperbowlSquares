# SuperBowl Squares Smart Contract

A decentralized implementation of the classic Super Bowl squares game, where players can purchase squares on a 10x10 grid for a chance to win ETH based on the game's quarterly scores.

## Game Overview

SuperBowl Squares is a game where participants purchase squares on a 10x10 grid. Each row and column represents possible end digits (0-9) of the teams' scores. Winners are determined by matching the last digits of both teams' scores at the end of each quarter.

### Game Rules

1. Each square costs exactly 0.03605 ETH
2. Players can purchase multiple squares
3. 10% of each square purchase goes to the contract owner as a fee
4. The remaining 90% goes into the prize pool
5. Winners are determined at the end of each quarter
6. Each quarter's winner receives 25% of the contract balance
7. If there's no winner for a quarter, those funds remain in the contract
8. After the game ends, remaining funds can be withdrawn by the contract owner

## Game Flow

1. Initial State: Game is created and squares are available for purchase
2. Purchase Phase: Players can buy squares until the game starts
3. Game Phase: 
   - Game is started by the owner
   - Winners are declared for each quarter
   - 25% of the pool is paid to each winner
4. End Game: Owner ends the game after all quarters are completed
5. Withdrawal: Owner can withdraw any remaining funds

## Contract Functions

### For Players

`purchaseSquare(uint8 chiefsNumber, uint8 eaglesNumber)`
- Purchase a specific square on the grid
- Requires exact payment of 0.03605 ETH
- Must be called before the game starts
- Numbers must be between 0-9

`isSquareAvailable(uint8 chiefsNumber, uint8 eaglesNumber)`
- Check if a specific square is available for purchase
- Returns true if the square is available

`getSquareOwner(uint8 chiefsNumber, uint8 eaglesNumber)`
- Check who owns a specific square
- Returns the address of the square owner

### For Contract Owner

`startGame()`
- Begins the game
- Prevents further square purchases

`declareWinner(uint8 chiefsNumber, uint8 eaglesNumber)`
- Declare winning numbers for a quarter
- Pays out 25% of the contract balance to the winner
- Can be called up to 4 times (once per quarter)

`endGame()`
- Ends the game after all quarters are complete
- Must be called before funds can be withdrawn

`withdrawFunds()`
- Withdraws any remaining funds to the contract owner
- Can only be called after the game is ended

## Events

The contract emits the following events:

- `SquarePurchased`: When a player buys a square
- `WinnerPaid`: When a winner receives their payout
- `GameStarted`: When the game begins
- `GameEnded`: When the game is ended
- `FundsWithdrawn`: When remaining funds are withdrawn by the owner

## Benefits for Players

1. **Fair and Transparent**: 
   - All rules are enforced by smart contract code
   - Payouts are automatic and guaranteed
   - No possibility of manipulation or delayed payments

2. **Prize Structure**:
   - Each quarter offers a chance to win 25% of the pool
   - Multiple opportunities to win throughout the game
   - Winners receive payouts immediately after being declared

3. **Security**:
   - Funds are held securely in the smart contract
   - No need to trust a third party
   - All transactions are verifiable on the blockchain

4. **Simplicity**:
   - Easy to participate
   - Clear rules and payouts
   - No complex registration process

## Technical Details

- Built on BASE blockchain
- Solidity version: 0.8.26
- Fixed square price: 0.03605 ETH
- Owner fee: 10%
- Quarterly payout: 25% of contract balance

## Getting Started

1. Connect your Web3 wallet (e.g., MetaMask)
2. Select your desired square(s) using the row (Chiefs) and column (Eagles) numbers
3. Send exactly 0.03605 ETH per square
4. Wait for the game to start
5. If your numbers match the quarter scores, you win automatically!
