# 🤖 AI Voting Bot DAO

A revolutionary Stacks smart contract that enables AI-assisted governance in Decentralized Autonomous Organizations (DAOs). This contract addresses low participation rates and manipulation risks in DAO voting by allowing AI bots to participate in governance using reputation scores and on-chain activity metrics.

## 🎯 Problem & Solution

**Problem**: Traditional DAO voting suffers from:
- Low participation rates
- Susceptibility to manipulation
- Inefficient decision-making processes

**Solution**: AI Voting Bot DAO introduces:
- 🤖 On-chain AI bots that participate in voting
- 📊 Reputation-based voting power calculation  
- 🔄 Vote delegation to AI agents
- 📈 Objective proposal analysis through AI assistance

## ✨ Key Features

### 🧑‍🤝‍🧑 Member Management
- **Register Members**: Anyone can join the DAO as a member
- **AI Bot Registration**: Contract owner can register AI bots
- **Reputation System**: Dynamic reputation scoring affects voting power
- **Activity Tracking**: Member tenure and bot performance influence voting strength

### 🗳️ Voting & Delegation
- **Proposal Creation**: Members with sufficient reputation can create proposals
- **Flexible Voting**: Both humans and AI bots can vote on proposals  
- **Vote Delegation**: Members can delegate their voting power to AI bots
- **Time-Bounded Voting**: Each proposal has a defined voting period

### 🎛️ Governance Features
- **Quorum Requirements**: Minimum participation thresholds for valid proposals
- **Threshold-Based Execution**: Customizable approval thresholds per proposal
- **Reputation Updates**: Contract owner can adjust member reputation
- **Comprehensive Statistics**: Track DAO growth and participation metrics

## 🚀 Getting Started

### Prerequisites
- [Clarinet](https://docs.hiro.so/stacks/clarinet) installed
- Stacks wallet for interaction

### Installation
```bash
git clone <repository-url>
cd AI-Voting-Bot-DAO
clarinet check
```

## 📖 Usage Guide

### 1️⃣ Member Registration
```clarity
;; Register as a DAO member
(contract-call? .AI-Voting-Bot-DAO register-member)
```

### 2️⃣ AI Bot Registration (Owner Only)
```clarity
;; Register an AI bot (contract owner only)
(contract-call? .AI-Voting-Bot-DAO register-ai-bot 'SP1234567890ABCDEF...)
```

### 3️⃣ Vote Delegation
```clarity
;; Delegate votes to an AI bot
(contract-call? .AI-Voting-Bot-DAO delegate-votes 'SP1234567890ABCDEF...)

;; Revoke delegation
(contract-call? .AI-Voting-Bot-DAO revoke-delegation)
```

### 4️⃣ Proposal Management
```clarity
;; Create a proposal (requires minimum reputation)
(contract-call? .AI-Voting-Bot-DAO create-proposal 
  "Increase AI Bot Participation" 
  "This proposal aims to boost AI bot engagement in governance"
  u60) ;; 60% approval threshold

;; Vote on proposal
(contract-call? .AI-Voting-Bot-DAO vote-on-proposal u0 true) ;; Vote YES on proposal 0

;; Execute proposal after voting period
(contract-call? .AI-Voting-Bot-DAO execute-proposal u0)
```

### 5️⃣ Read DAO Information
```clarity
;; Get proposal details
(contract-call? .AI-Voting-Bot-DAO get-proposal u0)

;; Check member information
(contract-call? .AI-Voting-Bot-DAO get-member 'SP1234567890ABCDEF...)

;; View DAO statistics
(contract-call? .AI-Voting-Bot-DAO get-dao-stats)
```

## 🔧 Contract Functions

### Public Functions
| Function | Description | Parameters |
|----------|-------------|------------|
| `register-member` | Register as a DAO member | None |
| `register-ai-bot` | Register AI bot (owner only) | `bot-address: principal` |
| `delegate-votes` | Delegate voting power to AI bot | `delegate: principal` |
| `revoke-delegation` | Revoke vote delegation | None |
| `create-proposal` | Create new governance proposal | `title, description, threshold` |
| `vote-on-proposal` | Cast vote on proposal | `proposal-id, vote` |
| `execute-proposal` | Execute proposal after voting | `proposal-id` |
| `update-member-reputation` | Update member reputation (owner only) | `member, new-reputation` |

### Read-Only Functions
| Function | Description | Returns |
|----------|-------------|---------|----------|
| `get-proposal` | Get proposal details | Proposal info or none |
| `get-member` | Get member information | Member info or none |
| `get-ai-bot` | Get AI bot details | Bot info or none |
| `get-vote` | Get specific vote details | Vote info or none |
| `get-delegation` | Get delegation status | Delegation info or none |
| `get-dao-stats` | Get DAO statistics | Stats object |

## 🎮 Voting Power Calculation

### 👥 Member Voting Power
```
Base Power = Member Reputation
Tenure Bonus = (Current Block - Join Block) / 144 blocks
Total Power = Base Power + Tenure Bonus
```

### 🤖 AI Bot Voting Power
```
Base Power = Bot Reputation  
Accuracy Bonus = Accuracy Score / 10
Experience Bonus = Total Votes / 10
Total Power = Base Power + Accuracy Bonus + Experience Bonus
```

## ⚙️ Configuration

### Constants
- `MIN_REPUTATION`: u10 - Minimum reputation to create proposals
- `VOTING_PERIOD`: u144 - Voting period in blocks (~24 hours)
- `MIN_QUORUM`: u50 - Minimum votes required for proposal validity

## 🛡️ Error Codes
| Code | Name | Description |
|------|------|-------------|
| u100 | `ERR_NOT_AUTHORIZED` | Caller lacks permission |
| u101 | `ERR_NOT_FOUND` | Resource not found |
| u102 | `ERR_ALREADY_EXISTS` | Resource already exists |
| u103 | `ERR_INVALID_PROPOSAL` | Invalid proposal state |
| u104 | `ERR_VOTING_CLOSED` | Voting period ended |
| u105 | `ERR_ALREADY_VOTED` | User already voted |
| u106 | `ERR_INSUFFICIENT_REPUTATION` | Not enough reputation |
| u107 | `ERR_NOT_DELEGATED` | No active delegation |

## 🔮 Future Enhancements

- 🏆 Advanced reputation algorithms
- 🔗 Cross-DAO AI bot sharing
- 📱 Mobile app integration
- 🔒 Enhanced security features
- 📊 Advanced analytics dashboard

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Add tests for new functionality
4. Ensure `clarinet check` passes
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Stacks ecosystem for the robust blockchain infrastructure
- Clarity language for secure smart contract development
- The DAO community for continuous innovation in governance

---

*Built with ❤️ for the decentralized future*
