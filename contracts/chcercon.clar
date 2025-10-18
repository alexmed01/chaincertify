;; chaincertify
;; Manages issuance and verification of educational certificates on-chain,
;; enabling tamper-proof credential storage with institutional authorization.

;; constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ALREADY-EXISTS (err u101))
(define-constant ERR-NOT-FOUND (err u102))
(define-constant ERR-INVALID-INSTITUTION (err u103))
(define-constant ERR-CERTIFICATE-REVOKED (err u104))
(define-constant ERR-INVALID-CERTIFICATE-ID (err u105))

;; data maps and vars
;; Map to store authorized educational institutions
(define-map authorized-institutions
principal
{
name: (string-ascii 100),
accreditation-id: (string-ascii 50),
is-active: bool,
registered-at: uint
}
)

;; Map to store certificates
(define-map certificates
uint ;; certificate-id
{
student-address: principal,
institution: principal,
certificate-hash: (buff 32),
degree-type: (string-ascii 50),
field-of-study: (string-ascii 100),
graduation-date: uint,
issued-at: uint,
is-revoked: bool,
metadata-uri: (optional (string-ascii 200))
}
)

;; Map to track certificates by student
(define-map student-certificates
principal
(list 50 uint)
)

;; Map to track certificates by institution
(define-map institution-certificates
principal
(list 1000 uint)
)

;; Counter for certificate IDs
(define-data-var certificate-counter uint u0)

;; Contract metadata
(define-data-var contract-version (string-ascii 10) "1.0.0")
;; private functions

;; public functions
(define-private (is-authorized-institution (institution principal))
(match (map-get? authorized-institutions institution)
institution-data (get is-active institution-data)
false
)
)
(define-private (get-next-certificate-id)
(let ((current-id (var-get certificate-counter)))
(var-set certificate-counter (+ current-id u1))
(+ current-id u1)
)
)
(define-private (add-certificate-to-student (student principal) (cert-id uint))
(let ((current-certs (default-to (list) (map-get? student-certificates student))))
(map-set student-certificates student (unwrap! (as-max-len? (append current-certs cert-id)
u50) false))
)
)
(define-private (add-certificate-to-institution (institution principal) (cert-id uint))
(let ((current-certs (default-to (list) (map-get? institution-certificates institution))))
(map-set institution-certificates institution (unwrap! (as-max-len? (append current-certs
cert-id) u1000) false))
)
)