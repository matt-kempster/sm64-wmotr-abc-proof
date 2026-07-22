# SSL Pyramid pole-bypass proof

This project studies whether Mario can get from the fifth floor to the sixth
floor of the Shifting Sand Land Pyramid without pressing A. It follows the
Rocq/Coq + CompCert Clight structure used by the sibling SSL-Cog projects.

The intended result has two deliberately separate parts:

1. prove that the ordinary pole route needs an A press and that one A press is
   sufficient; and
2. either close every pole-bypass route from an arbitrary reachable prepared
   state, or provide a concrete zero-A counterexample.

The first part has a source-and-geometry proof plan. The second is the global
completeness obligation and is not assumed away. See `docs/claim.md` for the
exact boundary and `docs/checklist.md` for live status.

## Project route

```text
pinned US SM64 source and SSL Area 2 collision literals
  -> CompCert clightgen
  -> generated Clight AST shape certificates
  -> exact pole-exit and sixth-floor-hole arithmetic
  -> pole-route minimum-A theorem
  -> global prepared-state bypass audit
```

Generated Clight files are never hand-edited.

## Current result

The ordinary normalized pole route has a machine-checked minimum of exactly
one A press in the project's closed-world transition model.

- `proofs/GeneratedFacts.v` pins the generated C model and authentic SM64
  source shapes: pole height, A/Z exits, velocity clearing, jump setup, air
  drag/gravity, and object-list order.
- `pipeline/audit_pole_transfer.py` checks the exact fifth-floor support and
  eight-triangle sixth-floor ring. The ring is at Y 3942 and has a rectangular
  hole whose nearest edge is 101 units from the pole center.
- `proofs/PoleArithmetic.v` proves that a conservative non-A soft-bonk exit is
  still at most 82 units from the pole before falling below the ring.
- `proofs/PoleRoute.v` proves every modeled sixth-floor trace contains an A
  edge and constructs a westward trace with exactly one.
- `proofs/PoleBypass.v` packages those facts as
  `pole_route_minimum_a_certificate`.

This is not yet the unqualified bottom-to-sixth gameplay proof. The hard open
obligation is to show that every authentic zero-A state prepared from the
Pyramid bottom, including pole bypasses and object/platform/warp mechanisms,
is simulated by the closed-world model. `proofs/GlobalBoundary.v` states and
machine-checks the exact lifting theorem with that completeness premise kept
explicit.

The result concerns minimum A count, not literal action uniqueness. Authentic
source has A-gated exits both while holding/climbing (`ACT_WALL_KICK_AIR`) and
at the top (`ACT_TOP_OF_POLE_JUMP`).

## Build

The toolchain is Coq 8.16.1 and CompCert 3.15 in the `sm64-item-proof` opam
switch. The normal commands are:

```sh
source pipeline/env.sh
make generated
bash pipeline/check.sh
```

From a supported POSIX shell, change to this directory and run the commands
above. Generated
Clight files and the source/collision audit receipt are committed and are
checked for reproducibility.
