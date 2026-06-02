# CLAUDE.md — working in this repo

A Rocq (Coq) + CompCert proof aimed at an SM64 **A-Button-Challenge impossibility**
result. Two rules dominate everything you do here.

## 1. Before ANY proof work, read the `proof-discipline` skill

Before you continue, extend, "finish", or discharge a proof — or add a
`Definition`/`Lemma`/`Axiom` — invoke **`/proof-discipline`**
(`.claude/skills/proof-discipline/SKILL.md`) and run its audit:

```bash
bash .claude/skills/proof-discipline/discipline_check.sh
```

A green build is **not** progress, and proving a true-looking lemma is **not**
progress if it is disconnected, vacuous, or self-invented. Progress = a goal
**capstone** resting on *fewer* assumptions, with new work **hooked into the
spine** (not left in `Unwired/`). The failure mode to avoid is la-la-land:
inventing definitions and proving a tower on top of them while drifting from the
real theorem. (See <https://leanprover-community.github.io/did_you_prove_it.html>.)

## 2. PIPELINE, not bespoke

Every fact about SM64 comes from the mechanically `clightgen`'d Clight AST under
`generated/` — **never** a hand-written model. Hand-written math lives in
`proofs/`; `generated/` is regenerated, never edited. (`README.md`,
`proofs/README.md`.)

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
