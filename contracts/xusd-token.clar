;; XUSD Token - A fungible token implementation

;; Define fungible token trait
(define-trait ft-trait
  ((transfer (principal principal uint) (response bool uint))
   (mint (principal uint) (response bool uint))
   (burn (principal uint) (response bool uint))))

;; Storage
(define-map balances principal uint)
(define-data-var total-supply uint u0)

;; Error constants
(define-constant err-not-authorized (err u1))
(define-constant err-insufficient-balance (err u2))

;; Token configuration
(define-constant token-name "XUSD Stablecoin")
(define-constant token-symbol "XUSD")
(define-constant token-decimals u6)

;; Read-only functions
(define-read-only (get-name)
  (ok token-name))

(define-read-only (get-symbol)
  (ok token-symbol))

(define-read-only (get-decimals)
  (ok token-decimals))

(define-read-only (get-balance (account principal))
  (ok (default-to u0 (map-get? balances account))))

(define-read-only (get-total-supply)
  (ok (var-get total-supply)))

;; Public functions
(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (let ((sender-balance (default-to u0 (map-get? balances sender))))
    (asserts! (is-eq tx-sender sender) err-not-authorized)
    (asserts! (>= sender-balance amount) err-insufficient-balance)
    (map-set balances sender (- sender-balance amount))
    (map-set balances recipient (+ (default-to u0 (map-get? balances recipient)) amount))
    (ok true)))

(define-public (mint (recipient principal) (amount uint))
  (begin
    (asserts! (is-eq contract-caller .STXMint) err-not-authorized)
    (map-set balances recipient (+ (default-to u0 (map-get? balances recipient)) amount))
    (var-set total-supply (+ (var-get total-supply) amount))
    (ok true)))

(define-public (burn (account principal) (amount uint))
  (let ((balance (default-to u0 (map-get? balances account))))
    (asserts! (is-eq contract-caller .STXMint) err-not-authorized)
    (asserts! (>= balance amount) err-insufficient-balance)
    (map-set balances account (- balance amount))
    (var-set total-supply (- (var-get total-supply) amount))
    (ok true)))