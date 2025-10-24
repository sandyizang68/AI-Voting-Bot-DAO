
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_NOT_FOUND (err u101))
(define-constant ERR_ALREADY_EXISTS (err u102))
(define-constant ERR_INVALID_PROPOSAL (err u103))
(define-constant ERR_VOTING_CLOSED (err u104))
(define-constant ERR_ALREADY_VOTED (err u105))
(define-constant ERR_INSUFFICIENT_REPUTATION (err u106))
(define-constant ERR_NOT_DELEGATED (err u107))
(define-constant ERR_PROPOSAL_CANCELLED (err u108))

(define-constant MIN_REPUTATION u10)
(define-constant VOTING_PERIOD u144)
(define-constant MIN_QUORUM u50)

(define-data-var next-proposal-id uint u0)
(define-data-var total-members uint u0)
(define-data-var total-bots uint u0)

(define-map members 
  principal 
  {
    reputation: uint,
    join-height: uint,
    delegated-to: (optional principal),
    is-active: bool
  }
)

(define-map ai-bots 
  principal 
  {
    reputation: uint,
    creation-height: uint,
    total-votes: uint,
    accuracy-score: uint,
    is-active: bool
  }
)

(define-map proposals 
  uint 
  {
    title: (string-ascii 100),
    description: (string-ascii 500),
    proposer: principal,
    start-height: uint,
    end-height: uint,
    yes-votes: uint,
    no-votes: uint,
    total-votes: uint,
    executed: bool,
    cancelled: bool,
    min-threshold: uint
  }
)

(define-map votes 
  {proposal-id: uint, voter: principal} 
  {
    vote: bool,
    voting-power: uint,
    vote-height: uint
  }
)

(define-map delegations 
  {delegator: principal, delegate: principal} 
  {
    start-height: uint,
    is-active: bool
  }
)

(define-public (register-member)
  (let (
    (caller tx-sender)
    (current-height stacks-block-height)
  )
    (if (is-some (map-get? members caller))
      ERR_ALREADY_EXISTS
      (begin
        (map-set members caller {
          reputation: u1,
          join-height: current-height,
          delegated-to: none,
          is-active: true
        })
        (var-set total-members (+ (var-get total-members) u1))
        (ok true)
      )
    )
  )
)

(define-public (register-ai-bot (bot-address principal))
  (let (
    (caller tx-sender)
  )
    (asserts! (is-eq caller CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (if (is-some (map-get? ai-bots bot-address))
      ERR_ALREADY_EXISTS
      (begin
        (map-set ai-bots bot-address {
          reputation: MIN_REPUTATION,
          creation-height: stacks-block-height,
          total-votes: u0,
          accuracy-score: u50,
          is-active: true
        })
        (var-set total-bots (+ (var-get total-bots) u1))
        (ok true)
      )
    )
  )
)

(define-public (delegate-votes (delegate principal))
  (let (
    (caller tx-sender)
    (member-info (unwrap! (map-get? members caller) ERR_NOT_FOUND))
    (delegate-info (map-get? ai-bots delegate))
  )
    (asserts! (is-some delegate-info) ERR_NOT_FOUND)
    (map-set members caller 
      (merge member-info {delegated-to: (some delegate)})
    )
    (map-set delegations {delegator: caller, delegate: delegate} {
      start-height: stacks-block-height,
      is-active: true
    })
    (ok true)
  )
)

(define-public (revoke-delegation)
  (let (
    (caller tx-sender)
    (member-info (unwrap! (map-get? members caller) ERR_NOT_FOUND))
  )
    (match (get delegated-to member-info)
      delegate-address 
        (begin
          (map-set members caller 
            (merge member-info {delegated-to: none})
          )
          (map-set delegations {delegator: caller, delegate: delegate-address} {
            start-height: stacks-block-height,
            is-active: false
          })
          (ok true)
        )
      ERR_NOT_DELEGATED
    )
  )
)

(define-public (create-proposal (title (string-ascii 100)) (description (string-ascii 500)) (threshold uint))
  (let (
    (caller tx-sender)
    (proposal-id (var-get next-proposal-id))
    (member-info (map-get? members caller))
  )
    (asserts! (is-some member-info) ERR_NOT_AUTHORIZED)
    (asserts! (>= (get reputation (unwrap-panic member-info)) MIN_REPUTATION) ERR_INSUFFICIENT_REPUTATION)
    
    (map-set proposals proposal-id {
      title: title,
      description: description,
      proposer: caller,
      start-height: stacks-block-height,
      end-height: (+ stacks-block-height VOTING_PERIOD),
      yes-votes: u0,
      no-votes: u0,
      total-votes: u0,
      executed: false,
      cancelled: false,
      min-threshold: threshold
    })
    
    (var-set next-proposal-id (+ proposal-id u1))
    (ok proposal-id)
  )
)

(define-public (vote-on-proposal (proposal-id uint) (vote bool))
  (let (
    (caller tx-sender)
    (proposal-info (unwrap! (map-get? proposals proposal-id) ERR_NOT_FOUND))
    (member-info (map-get? members caller))
    (bot-info (map-get? ai-bots caller))
    (vote-key {proposal-id: proposal-id, voter: caller})
  )
    (asserts! (not (get cancelled proposal-info)) ERR_PROPOSAL_CANCELLED)
    (asserts! (< stacks-block-height (get end-height proposal-info)) ERR_VOTING_CLOSED)
    (asserts! (is-none (map-get? votes vote-key)) ERR_ALREADY_VOTED)
    
    (let (
      (voting-power 
        (if (is-some member-info)
          (calculate-member-voting-power (unwrap-panic member-info))
          (if (is-some bot-info)
            (calculate-bot-voting-power (unwrap-panic bot-info))
            u0
          )
        )
      )
    )
      (asserts! (> voting-power u0) ERR_NOT_AUTHORIZED)
      
      (map-set votes vote-key {
        vote: vote,
        voting-power: voting-power,
        vote-height: stacks-block-height
      })
      
      (if vote
        (map-set proposals proposal-id 
          (merge proposal-info {
            yes-votes: (+ (get yes-votes proposal-info) voting-power),
            total-votes: (+ (get total-votes proposal-info) voting-power)
          })
        )
        (map-set proposals proposal-id 
          (merge proposal-info {
            no-votes: (+ (get no-votes proposal-info) voting-power),
            total-votes: (+ (get total-votes proposal-info) voting-power)
          })
        )
      )
      
      (if (is-some bot-info)
        (update-bot-stats caller)
        (ok true)
      )
    )
  )
)

(define-public (cancel-proposal (proposal-id uint))
  (let (
    (caller tx-sender)
    (proposal-info (unwrap! (map-get? proposals proposal-id) ERR_NOT_FOUND))
  )
    (asserts! (or (is-eq caller (get proposer proposal-info)) (is-eq caller CONTRACT_OWNER)) ERR_NOT_AUTHORIZED)
    (asserts! (< stacks-block-height (get end-height proposal-info)) ERR_VOTING_CLOSED)
    (asserts! (not (get executed proposal-info)) ERR_INVALID_PROPOSAL)
    (asserts! (not (get cancelled proposal-info)) ERR_PROPOSAL_CANCELLED)
    
    (map-set proposals proposal-id 
      (merge proposal-info {cancelled: true})
    )
    (ok true)
  )
)

(define-public (execute-proposal (proposal-id uint))
  (let (
    (proposal-info (unwrap! (map-get? proposals proposal-id) ERR_NOT_FOUND))
  )
    (asserts! (not (get cancelled proposal-info)) ERR_PROPOSAL_CANCELLED)
    (asserts! (>= stacks-block-height (get end-height proposal-info)) ERR_VOTING_CLOSED)
    (asserts! (not (get executed proposal-info)) ERR_INVALID_PROPOSAL)
    
    (let (
      (total-votes (get total-votes proposal-info))
      (yes-votes (get yes-votes proposal-info))
      (threshold (get min-threshold proposal-info))
    )
      (asserts! (>= total-votes MIN_QUORUM) ERR_INVALID_PROPOSAL)
      
      (if (>= (* yes-votes u100) (* total-votes threshold))
        (begin
          (map-set proposals proposal-id 
            (merge proposal-info {executed: true})
          )
          (ok true)
        )
        (begin
          (map-set proposals proposal-id 
            (merge proposal-info {executed: false})
          )
          (ok false)
        )
      )
    )
  )
)

(define-public (update-member-reputation (member principal) (new-reputation uint))
  (let (
    (caller tx-sender)
    (member-info (unwrap! (map-get? members member) ERR_NOT_FOUND))
  )
    (asserts! (is-eq caller CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (map-set members member 
      (merge member-info {reputation: new-reputation})
    )
    (ok true)
  )
)

(define-private (calculate-member-voting-power (member-info {reputation: uint, join-height: uint, delegated-to: (optional principal), is-active: bool}))
  (let (
    (base-power (get reputation member-info))
    (tenure-bonus (/ (- stacks-block-height (get join-height member-info)) u144))
  )
    (if (get is-active member-info)
      (+ base-power tenure-bonus)
      u0
    )
  )
)

(define-private (calculate-bot-voting-power (bot-info {reputation: uint, creation-height: uint, total-votes: uint, accuracy-score: uint, is-active: bool}))
  (let (
    (base-power (get reputation bot-info))
    (accuracy-bonus (/ (get accuracy-score bot-info) u10))
    (experience-bonus (/ (get total-votes bot-info) u10))
  )
    (if (get is-active bot-info)
      (+ base-power accuracy-bonus experience-bonus)
      u0
    )
  )
)

(define-private (update-bot-stats (bot principal))
  (let (
    (bot-info (unwrap! (map-get? ai-bots bot) ERR_NOT_FOUND))
  )
    (map-set ai-bots bot 
      (merge bot-info {
        total-votes: (+ (get total-votes bot-info) u1)
      })
    )
    (ok true)
  )
)

(define-read-only (get-proposal (proposal-id uint))
  (map-get? proposals proposal-id)
)

(define-read-only (get-member (member principal))
  (map-get? members member)
)

(define-read-only (get-ai-bot (bot principal))
  (map-get? ai-bots bot)
)

(define-read-only (get-vote (proposal-id uint) (voter principal))
  (map-get? votes {proposal-id: proposal-id, voter: voter})
)

(define-read-only (get-delegation (delegator principal) (delegate principal))
  (map-get? delegations {delegator: delegator, delegate: delegate})
)

(define-read-only (get-dao-stats)
  {
    total-members: (var-get total-members),
    total-bots: (var-get total-bots),
    next-proposal-id: (var-get next-proposal-id)
  }
)

