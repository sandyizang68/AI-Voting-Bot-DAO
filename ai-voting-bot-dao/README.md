# 🤖 AI Voting Bot DAO

An innovative Decentralized Autonomous Organization (DAO) that integrates AI bots to enhance voting participation and decision-making efficiency on the Stacks blockchain.

## 🌟 Features

- **🗳️ Smart Voting System**: Create and vote on proposals with weighted voting based on reputation
- **🤖 AI Bot Integration**: Register AI bots that can participate in voting with confidence scores
- **🔄 Vote Delegation**: Delegate your voting power to trusted AI bots
- **📊 Reputation System**: Dynamic reputation scoring for both users and AI bots
- **⏰ Time-based Proposals**: Proposals with configurable durations (default: 144 blocks)
- **🎯 Confidence-based Bot Voting**: AI bots vote with confidence levels affecting vote weight

## 🚀 Quick Start

### Prerequisites

- [Clarinet](https://docs.hiro.so/clarinet) installed
- Basic understanding of Clarity smart contracts
- Stacks wallet for interaction

### Installation

```bash
git clone <your-repo-url>
cd ai-voting-bot-dao
clarinet check
```

### Testing

```bash
npm install
npm test
```

## 🏗️ Contract Architecture

### Core Components

#### 📝 Proposals
- **Title & Description**: Human-readable proposal information
- **Time Bounds**: Start and end heights for voting periods
- **Vote Tracking**: Separate tallies for votes-for and votes-against
- **Execution Status**: Track whether proposals have been executed

#### 🤖 AI Bots
- **Owner Management**: Each bot has a designated owner
- **Reputation Scoring**: Dynamic reputation affects voting weight
- **Activity Tracking**: Monitor total votes and successful predictions
- **Status Control**: Bots can be activated/deactivated

#### 👥 Users & Delegation
- **Reputation System**: User reputation affects voting weight
- **Vote Delegation**: Delegate voting power to AI bots
- **Weight Calculation**: `base_weight + (reputation / 50)`

## 📋 Key Functions

### 🏗️ Setup Functions

#### `register-ai-bot`
Register a new AI bot in the DAO.
```clarity
(register-ai-bot "MyAIBot")
```

#### `delegate-votes`
Delegate your voting power to an AI bot.
```clarity
(delegate-votes bot-id weight)
```

### 🗳️ Voting Functions

#### `create-proposal`
Create a new proposal for voting.
```clarity
(create-proposal "Proposal Title" "Detailed description of the proposal")
```

#### `vote-on-proposal`
Cast your vote on a proposal.
```clarity
(vote-on-proposal proposal-id true)  ; true for FOR, false for AGAINST
```

#### `bot-vote-on-proposal`
AI bots vote with confidence levels.
```clarity
(bot-vote-on-proposal proposal-id bot-id true 85)  ; 85% confidence
```

#### `execute-proposal`
Execute a proposal after voting period ends (if it passed).
```clarity
(execute-proposal proposal-id)
```

### 📊 Query Functions

#### `get-proposal`
Get detailed proposal information.
```clarity
(get-proposal proposal-id)
```

#### `get-ai-bot`
Get AI bot details including reputation and activity.
```clarity
(get-ai-bot bot-id)
```

#### `get-user-reputation`
Check a user's current reputation score.
```clarity
(get-user-reputation user-principal)
```

## 🎯 Use Cases

### 1. 🏛️ DAO Governance
- Create proposals for protocol upgrades
- Vote on budget allocations
- Decide on strategic partnerships

### 2. 🤖 AI-Enhanced Decision Making
- AI bots analyze proposals objectively
- Confidence scoring provides transparency
- Reduces human bias in voting

### 3. 🔄 Delegation & Participation
- Busy stakeholders delegate to AI bots
- Increased participation rates
- 24/7 voting capability through bots

## ⚖️ Economic Model

### Reputation System
- **Proposal Creation**: +10 reputation
- **Voting Participation**: +5 reputation
- **Successful Proposal**: +25 reputation (for proposer)
- **Minimum for Bot Delegation**: 100 reputation

### Voting Weights
- **Base Weight**: 1 vote per user
- **Reputation Bonus**: reputation ÷ 50
- **AI Bot Weight**: (reputation ÷ 10) × confidence%

## 🔒 Security Features

- **Owner Authorization**: Only bot owners can make bots vote
- **Double-Vote Prevention**: Prevents duplicate voting
- **Proposal Expiry**: Time-bound voting periods
- **Reputation Requirements**: Minimum reputation for key actions
- **Contract Owner Privileges**: Admin functions for reputation management

## 📈 Future Enhancements

- **🎖️ Achievement System**: Badges for active participation
- **📊 Analytics Dashboard**: Voting pattern analysis
- **🔗 Cross-Chain Integration**: Multi-blockchain DAO functionality
- **🧠 ML Integration**: Advanced AI prediction models
- **🏆 Reward Distribution**: Token rewards for participation

## 🛠️ Development

### Project Structure
```
ai-voting-bot-dao/
├── contracts/
│   └── ai-voting-dao.clar    # Main contract
├── tests/
│   └── ai-voting-dao.test.ts # Test suite
├── settings/
│   ├── Devnet.toml
│   ├── Testnet.toml
│   └── Mainnet.toml
└── Clarinet.toml
```

### Constants
- **PROPOSAL_DURATION**: 144 blocks (~24 hours)
- **MIN_REPUTATION**: 100 (for bot delegation)
- **Voting Period**: Configurable per proposal

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## 📄 License

This project is open source and available under the MIT License.

## 🔗 Links

- [Stacks Documentation](https://docs.stacks.co/)
- [Clarity Language Reference](https://docs.stacks.co/clarity/)
- [Clarinet Documentation](https://docs.hiro.so/clarinet/)

---

Built with ❤️ for the future of decentralized governance
