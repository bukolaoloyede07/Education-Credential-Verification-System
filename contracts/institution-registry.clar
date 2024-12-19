;; Institution Registry Contract

(define-constant contract-owner tx-sender)
(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_ALREADY_EXISTS (err u409))

(define-map institutions
  principal
  {
    name: (string-utf8 100),
    website: (string-utf8 100),
    verified: bool
  }
)

(define-public (register-institution (name (string-utf8 100)) (website (string-utf8 100)))
  (let
    ((institution-data { name: name, website: website, verified: false }))
    (asserts! (is-none (map-get? institutions tx-sender)) ERR_ALREADY_EXISTS)
    (ok (map-set institutions tx-sender institution-data))
  )
)

(define-public (verify-institution (institution principal))
  (let
    ((institution-data (unwrap! (map-get? institutions institution) ERR_NOT_FOUND)))
    (asserts! (is-eq tx-sender contract-owner) ERR_UNAUTHORIZED)
    (ok (map-set institutions
      institution
      (merge institution-data { verified: true })
    ))
  )
)

(define-read-only (get-institution (institution principal))
  (ok (unwrap! (map-get? institutions institution) ERR_NOT_FOUND))
)

(define-read-only (is-verified-institution (institution principal))
  (ok (default-to false (get verified (map-get? institutions institution))))
)

