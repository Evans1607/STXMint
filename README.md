# STXMint: STX-Collateralized Stablecoin Protocol

> A decentralized stablecoin protocol built on Stacks blockchain that allows users to mint xUSD using STX as collateral.

## 🌟 Features

- Mint xUSD tokens using STX as collateral
- Automated vault management system
- Dynamic liquidation engine
- Real-time price feed integration
- Secure collateral ratio management

## 📊 Technical Parameters

- Minimum Collateralization Ratio: 150%
- Liquidation Threshold: 130%
- Liquidation Bonus: 10%
- Price Oracle Integration

## 🛠️ Contract Functions

### Public Functions
```clarity
(define-public (mint-xusd (collateral uint) (mint-amount uint))
(define-public (liquidate-vault (target principal))
```

### Read-Only Functions
```clarity
(define-read-only (get-vault (owner principal))
```

## 📁 Project Structure

```
STXMint/
├── contracts/
│   ├── STXMint.clar      # Main protocol contract
│   └── xusd-token.clar   # Token interface
├── settings/
│   ├── Devnet.toml       # Development config
│   └── Testnet.toml      # Test network config
└── .gitignore            # Version control exclusions
```

## 🔒 Security Features

- Protected owner functions
- Automated health ratio monitoring
- Validated token transfers
- Secure vault state management
