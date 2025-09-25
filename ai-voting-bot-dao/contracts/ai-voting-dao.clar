(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-PROPOSAL-NOT-FOUND (err u1001))
(define-constant ERR-PROPOSAL-EXPIRED (err u1002))
(define-constant ERR-ALREADY-VOTED (err u1003))
(define-constant ERR-BOT-NOT-FOUND (err u1004))
(define-constant ERR-INSUFFICIENT-REPUTATION (err u1005))
(define-constant ERR-DELEGATION-EXISTS (err u1006))
(define-constant ERR-NO-DELEGATION (err u1007))
(define-constant ERR-INVALID-VOTE (err u1008))
(define-constant ERR-PROPOSAL-ACTIVE (err u1009))

(define-constant PROPOSAL-DURATION u144)
(define-constant MIN-REPUTATION u100)
(define-constant VOTE-FOR true)
(define-constant VOTE-AGAINST false)

(define-data-var proposal-id-counter uint u0)
(define-data-var bot-id-counter uint u0)

(define-map proposals
  uint
  {
    title: (string-ascii 100),
    description: (string-ascii 500),
    proposer: principal,
    start-height: uint,
    end-height: uint,
    votes-for: uint,
    votes-against: uint,
    executed: bool
  }
)

(define-map votes
  { proposal-id: uint, voter: principal }
  { vote: bool, weight: uint }
)

(define-map ai-bots
  uint
  {
    owner: principal,
    name: (string-ascii 50),
    reputation-score: uint,
    total-votes: uint,
    successful-predictions: uint,
    active: bool
  }
)

(define-map user-delegations
  principal
  { bot-id: uint, delegated-weight: uint }
)

(define-map user-reputation
  principal
  uint
)

(define-map bot-votes
  { proposal-id: uint, bot-id: uint }
  { vote: bool, confidence: uint }
)

(define-read-only (get-proposal (proposal-id uint))
  (map-get? proposals proposal-id)
)

(define-read-only (get-ai-bot (bot-id uint))
  (map-get? ai-bots bot-id)
)

(define-read-only (get-user-delegation (user principal))
  (map-get? user-delegations user)
)

(define-read-only (get-user-reputation (user principal))
  (default-to u0 (map-get? user-reputation user))
)

(define-read-only (get-vote (proposal-id uint) (voter principal))
  (map-get? votes { proposal-id: proposal-id, voter: voter })
)

(define-read-only (get-bot-vote (proposal-id uint) (bot-id uint))
  (map-get? bot-votes { proposal-id: proposal-id, bot-id: bot-id })
)

(define-read-only (get-proposal-count)
  (var-get proposal-id-counter)
)

(define-read-only (get-bot-count)
  (var-get bot-id-counter)
)

(define-read-only (calculate-voting-weight (user principal))
  (let (
    (base-weight u1)
    (reputation (get-user-reputation user))
    (delegation (get-user-delegation user))
  )
    (+ base-weight (/ reputation u50))
  )
)

(define-public (register-ai-bot (name (string-ascii 50)))
  (let (
    (bot-id (+ (var-get bot-id-counter) u1))
  )
    (asserts! (> (len name) u0) ERR-NOT-AUTHORIZED)
    (map-set ai-bots bot-id {
      owner: tx-sender,
      name: name,
      reputation-score: u100,
      total-votes: u0,
      successful-predictions: u0,
      active: true
    })
    (var-set bot-id-counter bot-id)
    (ok bot-id)
  )
)

(define-public (update-bot-reputation (bot-id uint) (new-reputation uint))
  (let (
    (bot (unwrap! (get-ai-bot bot-id) ERR-BOT-NOT-FOUND))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set ai-bots bot-id (merge bot { reputation-score: new-reputation }))
    (ok true)
  )
)

(define-public (delegate-votes (bot-id uint) (weight uint))
  (let (
    (bot (unwrap! (get-ai-bot bot-id) ERR-BOT-NOT-FOUND))
    (user-rep (get-user-reputation tx-sender))
  )
    (asserts! (>= user-rep MIN-REPUTATION) ERR-INSUFFICIENT-REPUTATION)
    (asserts! (get active bot) ERR-BOT-NOT-FOUND)
    (asserts! (is-none (get-user-delegation tx-sender)) ERR-DELEGATION-EXISTS)
    (map-set user-delegations tx-sender {
      bot-id: bot-id,
      delegated-weight: weight
    })
    (ok true)
  )
)

(define-public (revoke-delegation)
  (begin
    (asserts! (is-some (get-user-delegation tx-sender)) ERR-NO-DELEGATION)
    (map-delete user-delegations tx-sender)
    (ok true)
  )
)

(define-public (create-proposal (title (string-ascii 100)) (description (string-ascii 500)))
  (let (
    (proposal-id (+ (var-get proposal-id-counter) u1))
    (start-height stacks-block-height)
    (end-height (+ start-height PROPOSAL-DURATION))
  )
    (asserts! (> (len title) u0) ERR-NOT-AUTHORIZED)
    (asserts! (> (len description) u0) ERR-NOT-AUTHORIZED)
    (map-set proposals proposal-id {
      title: title,
      description: description,
      proposer: tx-sender,
      start-height: start-height,
      end-height: end-height,
      votes-for: u0,
      votes-against: u0,
      executed: false
    })
    (var-set proposal-id-counter proposal-id)
    (map-set user-reputation tx-sender (+ (get-user-reputation tx-sender) u10))
    (ok proposal-id)
  )
)

(define-public (vote-on-proposal (proposal-id uint) (vote bool))
  (let (
    (proposal (unwrap! (get-proposal proposal-id) ERR-PROPOSAL-NOT-FOUND))
    (current-height stacks-block-height)
    (voting-weight (calculate-voting-weight tx-sender))
    (existing-vote (get-vote proposal-id tx-sender))
  )
    (asserts! (< current-height (get end-height proposal)) ERR-PROPOSAL-EXPIRED)
    (asserts! (is-none existing-vote) ERR-ALREADY-VOTED)
    
    (map-set votes { proposal-id: proposal-id, voter: tx-sender } {
      vote: vote,
      weight: voting-weight
    })
    
    (if vote
      (map-set proposals proposal-id (merge proposal {
        votes-for: (+ (get votes-for proposal) voting-weight)
      }))
      (map-set proposals proposal-id (merge proposal {
        votes-against: (+ (get votes-against proposal) voting-weight)
      }))
    )
    
    (map-set user-reputation tx-sender (+ (get-user-reputation tx-sender) u5))
    (ok true)
  )
)

(define-public (bot-vote-on-proposal (proposal-id uint) (bot-id uint) (vote bool) (confidence uint))
  (let (
    (proposal (unwrap! (get-proposal proposal-id) ERR-PROPOSAL-NOT-FOUND))
    (bot (unwrap! (get-ai-bot bot-id) ERR-BOT-NOT-FOUND))
    (current-height stacks-block-height)
    (bot-weight (/ (get reputation-score bot) u10))
    (existing-bot-vote (get-bot-vote proposal-id bot-id))
  )
    (asserts! (is-eq tx-sender (get owner bot)) ERR-NOT-AUTHORIZED)
    (asserts! (< current-height (get end-height proposal)) ERR-PROPOSAL-EXPIRED)
    (asserts! (get active bot) ERR-BOT-NOT-FOUND)
    (asserts! (is-none existing-bot-vote) ERR-ALREADY-VOTED)
    (asserts! (<= confidence u100) ERR-INVALID-VOTE)
    
    (map-set bot-votes { proposal-id: proposal-id, bot-id: bot-id } {
      vote: vote,
      confidence: confidence
    })
    
    (let (
      (weighted-vote (/ (* bot-weight confidence) u100))
    )
      (if vote
        (map-set proposals proposal-id (merge proposal {
          votes-for: (+ (get votes-for proposal) weighted-vote)
        }))
        (map-set proposals proposal-id (merge proposal {
          votes-against: (+ (get votes-against proposal) weighted-vote)
        }))
      )
    )
    
    (map-set ai-bots bot-id (merge bot {
      total-votes: (+ (get total-votes bot) u1)
    }))
    
    (ok true)
  )
)

(define-public (execute-proposal (proposal-id uint))
  (let (
    (proposal (unwrap! (get-proposal proposal-id) ERR-PROPOSAL-NOT-FOUND))
    (current-height stacks-block-height)
  )
    (asserts! (>= current-height (get end-height proposal)) ERR-PROPOSAL-ACTIVE)
    (asserts! (not (get executed proposal)) ERR-NOT-AUTHORIZED)
    (asserts! (> (get votes-for proposal) (get votes-against proposal)) ERR-INVALID-VOTE)
    
    (map-set proposals proposal-id (merge proposal { executed: true }))
    (map-set user-reputation (get proposer proposal) (+ (get-user-reputation (get proposer proposal)) u25))
    (ok true)
  )
)

(define-public (update-user-reputation (user principal) (amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set user-reputation user (+ (get-user-reputation user) amount))
    (ok true)
  )
)

(define-public (deactivate-bot (bot-id uint))
  (let (
    (bot (unwrap! (get-ai-bot bot-id) ERR-BOT-NOT-FOUND))
  )
    (asserts! (or (is-eq tx-sender (get owner bot)) (is-eq tx-sender CONTRACT-OWNER)) ERR-NOT-AUTHORIZED)
    (map-set ai-bots bot-id (merge bot { active: false }))
    (ok true)
  )
)

(define-public (reactivate-bot (bot-id uint))
  (let (
    (bot (unwrap! (get-ai-bot bot-id) ERR-BOT-NOT-FOUND))
  )
    (asserts! (is-eq tx-sender (get owner bot)) ERR-NOT-AUTHORIZED)
    (asserts! (>= (get reputation-score bot) MIN-REPUTATION) ERR-INSUFFICIENT-REPUTATION)
    (map-set ai-bots bot-id (merge bot { active: true }))
    (ok true)
  )
)

