# Eyerok manipulation proof

This project studies the proposed Shifting Sand Land route in which an Eyerok
hand is manipulated into rising without bound above the instant-warp floor
triangles between the Pyramid interior and the boss arena. It follows the
Rocq/Coq + CompCert Clight structure used by the sibling SSL-Cog projects.

The target is deliberately adversarial: player position, attacks, timing, and
the boss's random choices may select any authentic action transition. The
proof must still find a uniform upper bound on each hand's height, or the
project must replace the impossibility claim with a concrete counterexample.

See [Eyerok.md](Eyerok.md) for the source state machine,
`docs/claim.md` for the exact formal boundary, and `docs/checklist.md` for the
live proof status.

## Project route

```text
pinned US SM64 Eyerok, object-motion, SSL script, and collision source
  -> reproducible source audit + CompCert clightgen
  -> generated Clight AST shape certificates
  -> player-adversarial vertical transition system
  -> uniform height invariant
  -> no-unbounded-rise theorem
```

Generated Clight files are never hand-edited.

## Current status

The project structure and proof boundary are in place. Source ingestion,
Clight generation, and the machine-checked boundedness theorem are the next
commits; no gameplay conclusion is claimed by this scaffold.

## Build

The intended toolchain is Coq 8.16.1 and CompCert 3.15 in the
`sm64-item-proof` opam switch. From PowerShell, use the Ubuntu distribution
explicitly because the default WSL distribution is not usable:

```powershell
wsl.exe -d Ubuntu
```

The completed project will use:

```sh
opam exec --switch sm64-item-proof -- make generated
opam exec --switch sm64-item-proof -- bash pipeline/check.sh
```
