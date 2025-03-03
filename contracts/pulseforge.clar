;; PulseForge - Workflow Management Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-authorized (err u401))
(define-constant err-not-found (err u404))
(define-constant err-invalid-input (err u400))

;; Data Variables
(define-map projects 
  {project-id: uint}
  {
    name: (string-ascii 100),
    owner: principal,
    status: (string-ascii 20),
    created-at: uint
  }
)

(define-map team-members
  {project-id: uint, member: principal}
  {
    role: (string-ascii 50),
    joined-at: uint
  }
)

(define-map milestones
  {project-id: uint, milestone-id: uint}
  {
    title: (string-ascii 100),
    due-date: uint,
    status: (string-ascii 20)
  }
)

(define-map communications
  {project-id: uint, message-id: uint}
  {
    sender: principal,
    content: (string-ascii 500),
    timestamp: uint
  }
)

(define-data-var project-id-nonce uint u0)
(define-data-var milestone-id-nonce uint u0)
(define-data-var message-id-nonce uint u0)

;; Project Management Functions
(define-public (create-project (name (string-ascii 100)) (owner principal))
  (let
    (
      (new-id (+ (var-get project-id-nonce) u1))
    )
    (try! (is-contract-owner))
    (map-set projects
      {project-id: new-id}
      {
        name: name,
        owner: owner,
        status: "active",
        created-at: block-height
      }
    )
    (var-set project-id-nonce new-id)
    (ok new-id)
  )
)

(define-public (add-team-member (project-id uint) (member principal) (role (string-ascii 50)))
  (let
    (
      (project (unwrap! (map-get? projects {project-id: project-id}) err-not-found))
    )
    (try! (is-project-owner project-id))
    (map-set team-members
      {project-id: project-id, member: member}
      {
        role: role,
        joined-at: block-height
      }
    )
    (ok true)
  )
)

(define-public (create-milestone (project-id uint) (title (string-ascii 100)) (due-date uint))
  (let
    (
      (new-id (+ (var-get milestone-id-nonce) u1))
    )
    (try! (is-project-member project-id))
    (map-set milestones
      {project-id: project-id, milestone-id: new-id}
      {
        title: title,
        due-date: due-date,
        status: "pending"
      }
    )
    (var-set milestone-id-nonce new-id)
    (ok new-id)
  )
)

(define-public (post-message (project-id uint) (content (string-ascii 500)))
  (let
    (
      (new-id (+ (var-get message-id-nonce) u1))
    )
    (try! (is-project-member project-id))
    (map-set communications
      {project-id: project-id, message-id: new-id}
      {
        sender: tx-sender,
        content: content,
        timestamp: block-height
      }
    )
    (var-set message-id-nonce new-id)
    (ok new-id)
  )
)

;; Helper Functions
(define-private (is-contract-owner)
  (if (is-eq tx-sender contract-owner)
    (ok true)
    err-not-authorized
  )
)

(define-private (is-project-owner (project-id uint))
  (let
    (
      (project (unwrap! (map-get? projects {project-id: project-id}) err-not-found))
    )
    (if (is-eq tx-sender (get owner project))
      (ok true)
      err-not-authorized
    )
  )
)

(define-private (is-project-member (project-id uint))
  (match (map-get? team-members {project-id: project-id, member: tx-sender})
    member (ok true)
    err-not-authorized
  )
)

;; Read Functions
(define-read-only (get-project (project-id uint))
  (ok (map-get? projects {project-id: project-id}))
)

(define-read-only (get-milestone (project-id uint) (milestone-id uint))
  (ok (map-get? milestones {project-id: project-id, milestone-id: milestone-id}))
)

(define-read-only (get-team-member (project-id uint) (member principal))
  (ok (map-get? team-members {project-id: project-id, member: member}))
)
