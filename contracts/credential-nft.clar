;; Credential NFT Contract

(define-non-fungible-token credential uint)

(define-constant contract-owner tx-sender)
(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_ALREADY_EXISTS (err u409))

(define-data-var credential-id-nonce uint u0)

(define-map credentials
  uint
  {
    owner: principal,
    issuer: principal,
    credential-type: (string-ascii 20),
    metadata: (string-utf8 500),
    issue-date: uint,
    expiration-date: (optional uint)
  }
)

(define-read-only (get-last-token-id)
  (ok (var-get credential-id-nonce))
)

(define-public (issue-credential
    (recipient principal)
    (credential-type (string-ascii 20))
    (metadata (string-utf8 500))
    (expiration-date (optional uint)))
  (let
    ((credential-id (+ (var-get credential-id-nonce) u1)))
    (asserts! (is-eq tx-sender contract-owner) ERR_UNAUTHORIZED)
    (try! (nft-mint? credential credential-id recipient))
    (map-set credentials
      credential-id
      {
        owner: recipient,
        issuer: tx-sender,
        credential-type: credential-type,
        metadata: metadata,
        issue-date: block-height,
        expiration-date: expiration-date
      }
    )
    (var-set credential-id-nonce credential-id)
    (ok credential-id)
  )
)

(define-public (transfer-credential (credential-id uint) (recipient principal))
  (let
    ((credential-owner (unwrap! (nft-get-owner? credential credential-id) ERR_NOT_FOUND)))
    (asserts! (is-eq tx-sender credential-owner) ERR_UNAUTHORIZED)
    (try! (nft-transfer? credential credential-id tx-sender recipient))
    (ok (map-set credentials
      credential-id
      (merge (unwrap! (map-get? credentials credential-id) ERR_NOT_FOUND)
             { owner: recipient })
    ))
  )
)

(define-read-only (get-credential (credential-id uint))
  (ok (unwrap! (map-get? credentials credential-id) ERR_NOT_FOUND))
)

(define-read-only (verify-credential (credential-id uint))
  (let
    ((cred-data (unwrap! (map-get? credentials credential-id) ERR_NOT_FOUND)))
    (ok {
      is-valid: (and
        (is-some (nft-get-owner? credential credential-id))
        (match (get expiration-date cred-data)
          expiry (> expiry block-height)
          true
        )
      ),
      issuer: (get issuer cred-data),
      credential-type: (get credential-type cred-data),
      issue-date: (get issue-date cred-data)
    })
  )
)

