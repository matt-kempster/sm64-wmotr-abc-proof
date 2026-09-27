# CLAUDE.md — working in this repo

A Rocq (Coq) + CompCert proof aimed at an SM64 **A-Button-Challenge impossibility**
result. Two rules dominate everything you do here.

## 1. Progress = the capstone says more about the real program

Before committing proof changes, run the audit (build, holes, axioms, firewall):

```bash
bash .claude/skills/proof-discipline/discipline_check.sh
```

A green audit is the floor, not progress. Progress means a goal **capstone** that
is more tethered to the real SM64 code: a row discharged or sharpened, a placeholder
replaced by a generated-AST object, or a false claim found. New work must be
**hooked into the spine** (not left in `Unwired/`). Watch for rows that quantify
over states the game never produces (phantom ∀). The `proof-discipline` skill has
the checklist and the current open surface; keep it current.

## 2. PIPELINE, not bespoke

Every fact about SM64 comes from the mechanically `clightgen`'d Clight AST under
`generated/` — **never** a hand-written model. Hand-written math lives in
`proofs/`; `generated/` is regenerated, never edited. (`README.md`,
`proofs/README.md`.)

## 3. The trust ledger: `docs/TRUST.md`

Everything a reader must believe for the final theorem to be about the real game
(foundations, ROM→C gaps like the `AVOID_UB` preprocessing, C-vs-N64 semantics,
out-of-scope code, tethers). Any change that adds, removes or moves trust updates
the ledger in the same commit.

## Build & verify — always via `pipeline/*.sh`, never bare `coqc`

```bash
bash pipeline/build.sh proofs                       # build the proofs (committed generated/)
bash pipeline/assumptions.sh <Module.Path> <thm>    # Print Assumptions (the lie detector)
python3 pipeline/check_unwired.py                    # structure: unused => unwired (CI-enforced)
bash .claude/skills/proof-discipline/discipline_check.sh   # the full discipline audit
```

The active **spine** is the transitive closure of the goal capstone
(`NoAImpliesNoFly/NoAImpliesNoFly.v` for GOAL 1 — no-A ⇒ no-fly;
`WMotRRequiresA/` is GOAL 2, not started). Everything else lives under an
`Unwired/` dir: compiled, but **not load-bearing**. CI's firewall forbids the
spine from importing `Unwired/`, so the only way to "use" Unwired work is to
promote it. See `proofs/README.md` and `docs/RENAMING.md`.
