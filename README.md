# Super Bowl Squares Smart Contract

A decentralized Super Bowl squares game running on the BASE blockchain. Players can purchase squares corresponding to potential final score digits, with winners determined by the actual game scores.

## Game Overview

The game creates a 10x10 grid (100 squares) where:
- Horizontal axis: Chiefs final score digit (0-9)
- Vertical axis: Eagles final score digit (0-9)
- Each square costs 0.03605 ETH ($100)
- 90% of entry fees go to prize pool, 10% to contract owner
- Four winning moments with 25% payout each
- Winners determined by last digit of each team's score at quarter/game end

## How to Play

1. Check square availability:
```solidity
isSquareAvailable(uint8 chiefsNumber, uint8 eaglesNumber)
```
Example: `isSquareAvailable(7, 3)` checks if Chiefs-7/Eagles-3 square is available

2. Purchase a square:
```solidity
purchaseSquare(uint8 chiefsNumber, uint8 eaglesNumber)
```
- Send exactly 0.03605 ETH with transaction
- Choose numbers 0-9 for each team
- Transaction reverts if square already taken

## Winning & Payouts

Winners determined by score digits at:
- End of 1st quarter (25% of pool)
- End of 2nd quarter (25% of pool)
- End of 3rd quarter (25% of pool)
- Final score (25% of pool)

Example: If Chiefs lead 17-13 at end of first quarter, square (7,3) wins first payout

## Key Functions

### For Players
- `grid(uint8, uint8)`: View square details (owner, teams, status)
- `isSquareAvailable(uint8, uint8)`: Check if square is available
- `getSquareOwner(uint8, uint8)`: Get address of square owner

### For Contract Owner
- `declareWinner(uint8, uint8)`: Declare winning square and trigger payout
- Only callable by owner
- Limited to 4 calls total

## Technical Details

### Events
- `SquarePurchased`: Emitted when square is purchased
- `WinnerPaid`: Emitted on payout
- `GameEnded`: Emitted after final payout

### State Variables
- `contractBalance`: Current prize pool
- `payoutCount`: Number of payouts completed
- `gameEnded`: True after all payouts complete

## Benefits

1. Transparency
- All transactions recorded on blockchain
- Automatic payouts
- Verifiable random square selection
- No middleman handling funds

2. Security
- Smart contract enforces rules
- Immutable once deployed
- Self-executing payouts

3. Accessibility
- Play from anywhere
- No account registration
- Direct ETH transactions

## Technical Requirements

- Web3 compatible wallet
- Sufficient ETH for entry + gas
- Ethereum mainnet interaction capability

## License
MIT
