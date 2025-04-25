;; STXMint - A STX-collateralized stablecoin contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant min-ratio u150)
(define-constant liquidation-ratio u130)
(define-constant liquidation-bonus u10)

;; Error codes
(define-constant err-owner-only (err u100))
(define-constant err-insufficient-collateral (err u102))
(define-constant err-vault-healthy (err u103))

;; Data variables
(define-data-var stx-price uint u100)

;; Storage
(define-map vaults 
  { owner: principal }
  { stx-collateral: uint, xusd-debt: uint })

;; Read-only functions
(define-read-only (get-vault (owner principal))
  (map-get? vaults {owner: owner}))

;; Public functions
(define-public (mint-xusd (collateral uint) (mint-amount uint))
  (let ((user tx-sender)
        (price (var-get stx-price))
        (collateral-value (* collateral price))
        (required-collateral (/ (* mint-amount min-ratio) u100)))
    (if (< collateral-value required-collateral)
        err-insufficient-collateral
        (let ((vault (map-get? vaults {owner: user})))
          (if (is-some vault)
              (let ((existing-vault (unwrap-panic vault)))
                (try! (stx-transfer? collateral tx-sender (as-contract tx-sender)))
                (map-set vaults {owner: user}
                  {stx-collateral: (+ collateral (get stx-collateral existing-vault)), 
                   xusd-debt: (+ mint-amount (get xusd-debt existing-vault))})
                (try! (contract-call? .xusd-token mint user mint-amount))
                (ok {code: u200, amount: mint-amount, message: "xUSD minted"}))
              (begin
                (try! (stx-transfer? collateral tx-sender (as-contract tx-sender)))
                (map-set vaults {owner: user}
                  {stx-collateral: collateral, xusd-debt: mint-amount})
                (try! (contract-call? .xusd-token mint user mint-amount))
                (ok {code: u200, amount: mint-amount, message: "xUSD minted"})))))))

(define-public (liquidate-vault (target principal))
  (let ((price (var-get stx-price)))
    (match (map-get? vaults {owner: target})
      existing-vault
      (let ((collateral (get stx-collateral existing-vault))
            (debt (get xusd-debt existing-vault))
            (current-ratio (/ (* collateral price u100) debt)))
            (if (>= current-ratio liquidation-ratio)
            (ok {
                code: u403,
                message: "Vault healthy",
                liquidated-user: target,
                liquidator: tx-sender,
                collateral-paid: u0,
                xusd-burned: u0
            })
            (begin
              (try! (contract-call? .xusd-token burn tx-sender debt))
              (try! (stx-transfer? collateral (as-contract tx-sender) tx-sender))
              (map-delete vaults {owner: target})
              (ok {
                code: u200,
                message: "Vault liquidated",
                liquidated-user: target,
                liquidator: tx-sender,
                collateral-paid: collateral,
                xusd-burned: debt
              }))))
      (ok {
        code: u404,
        message: "No vault",
        liquidated-user: target,
        liquidator: tx-sender,
        collateral-paid: u0,
        xusd-burned: u0
      }))))
