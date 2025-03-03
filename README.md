# PulseForge
A decentralized workflow management system for project timelines and team communication built on Stacks.

## Features
- Create and manage project workflows
- Add team members and assign roles
- Create and track project milestones
- Post and retrieve team communications
- Track project status and completion

## Setup and Installation
1. Clone the repository
2. Install Clarinet
3. Run `clarinet check` to verify contracts
4. Run `clarinet test` to execute test suite

## Usage Examples
```clarity
;; Create a new project
(contract-call? .pulseforge create-project "My Project" 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

;; Add team member
(contract-call? .pulseforge add-team-member u1 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG "developer")

;; Create milestone
(contract-call? .pulseforge create-milestone u1 "MVP Release" u1671148800)
```

## Dependencies
- Clarity language
- Clarinet for testing and deployment
