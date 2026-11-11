# EtherShield
Ethereum smart contract security lab: vulnerable contracts, controlled exploits, fixes, and audit.
Local network only (Remix VM). No real keys or funds.

## Vulnerabilities
| Pair | Vulnerabilities |
|---|---|
| 1 | Reentrancy |
| 2 | tx.origin, Access Control |
| 3 | Signature Replay |
| 4 | Front-running / MEV, Denial of Service |

## Structure
- contracts/vulnerable – vulnerable contracts
- contracts/attackers – attack contracts
- contracts/fixed – corrected contracts
- tests – exploit and non-regression tests
- audit – static analysis results and findings
- docs – specs, notes, setup, final report

## Team and work division

| Member | Name |
|---|---|
| Member 1 | Hilmi Ouelhazi |
| Member 2 | Yasmine ben Turkia |
| Member 3 | Haithem Ben souissi |
| Member 4 | Oussema Belhadj Ali |

Each vulnerability pair goes through four roles. Roles rotate, so every member
works on building, attacking, fixing and reporting across different vulnerabilities.

| Pair | Build | Attack | Fix | Report + audit |
|---|---|---|---|---|
| 1. Reentrancy | Member 1 | Member 1 | Member 1 | Member 1 |
| 2. tx.origin  + Access Control | Member 2 | Member 2 | Member 2 | Member 2 |
| 3. Signature Replay | Member 3 | Member 3 | Member 3 | Member 3 |
| 4. Front-running + DoS | Member 4 | Member 4 | Member 4 | Member 4 |

### Roles
- **Build:** writes the vulnerable contracts for the pair (2 contracts).
- **Attack:** writes 2 attacks per vulnerability as Remix unit tests (4 attacks), proving each bug is exploitable.
- **Fix:** writes the corrected contracts and reruns the same tests to show the attacks now fail.
- **Report + audit:** runs static analysis / Slither, classifies findings (real vs false positive),
  and writes the report sections: description, severity, impact, proof, fix, validation, remaining limits.

### Support tasks (in each member's free phase)
| Phase | Member | Task |
|---|---|---|
| Build | Member 4 | Test template, static analysis and Slither setup |
| Attack | Member 1 | Fundamentals notes (EVM, gas, storage), setup and deployment docs |
| Fix | Member 2 | Live demo script for the defense |
| Report | Member 3 | Final report and slides assembly |

### Schedule
| Week | Phase | Deliverable |
|---|---|---|
| Nov 9–15 | Foundations | Repo, 6 contract specs, fundamentals notes |
| Nov 16–22 | Build | 6 vulnerable contracts |
| Nov 23–29 | Attack | 12 exploit tests passing |
| Nov 30–Dec 6 | Fix | 6 fixed contracts, attacks fail on them |
| Dec 7–13 | Report + audit | Audit findings and report sections |
| Dec 14–20 | Defense | Rehearsed live demo |

### Workflow rules
- Pull before starting work, commit and push when done.
- Each member edits only the files of their current role.
