# Super Bowl Squares Smart Contract

Decentralized Super Bowl squares game on Ethereum with dynamic payout mechanics and automated winner distribution.

## Game Overview

- 10x10 grid: Chiefs (horizontal) vs Eagles (vertical)
- Entry cost: 0.03605 ETH per square
- Prize pool: 90% of entries (10% to contract owner)
- Four payouts (one per quarter)
- Winners determined by score digits

## Game Flow

### Pre-Game Phase
- Players purchase squares (0-9 coordinates)
- Each square can only be purchased once
- Contract owner calls `startGame()` to begin

### Active Game Phase
- Owner declares winners after each quarter
- Payouts processed automatically
- Unclaimed quarters roll over
- Final quarter handles remaining balance

### End Game Phase
- Automatic end after 4th quarter
- Manual end via `endGame()` if needed
- Refunds available if specified conditions met

## Payout Mechanics

### Standard Quarter Wins
- First Quarter: 25% of pool
- Each quarter: 25% + any previous rollovers
- Unoccupied winning square: Amount rolls to next quarter

### Special Cases
1. **Multiple Rollovers to Winner**
   - Winner receives accumulated percentage
   - Example: Winner after 2 rollovers gets 75%

2. **Final Quarter Scenarios**
   - Winner gets entire remaining balance
   - No winner: Distributes to previous winners
   - No previous winners: Enables refund system

3. **Refund System**
   - Available if enabled by owner
   - Players recover 90% of entry fee
   - Must be square owner to claim

## Function Reference

### Player Functions
```solidity
purchaseSquare(uint8 chiefsNumber, uint8 eaglesNumber) payable
isSquareAvailable(uint8 chiefsNumber, uint8 eaglesNumber) view
claimRefund(uint8 chiefsNumber, uint8 eaglesNumber)
getSquareOwner(uint8 chiefsNumber, uint8 eaglesNumber) view
```

### Admin Functions
```solidity
startGame()
endGame(bool enableRefunds)
declareWinner(uint8 chiefsNumber, uint8 eaglesNumber)
```

## Events
```solidity
SquarePurchased(address indexed player, uint8 chiefsNumber, uint8 eaglesNumber)
WinnerPaid(address indexed winner, uint8 chiefsNumber, uint8 eaglesNumber, uint256 amount)
UnoccupiedSquareRollover(uint8 chiefsNumber, uint8 eaglesNumber, uint256 amount)
GameStarted(uint256 timestamp)
GameEnded(bool refundsEnabled)
RefundClaimed(address indexed player, uint256 amount)
```

## Technical Requirements
- Web3 compatible wallet
- Entry fee: 0.03605 ETH + gas
- Ethereum mainnet interaction

## Security Features
- Ownership controls
- State management
- Automated payouts
- Duplicate winner protection
- Safe refund mechanism

## License
MIT
