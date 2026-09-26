# ESBMC falsification harnesses (exploratory, not part of the proof)

Purpose: check candidate GOAL-2 invariants against the **unmodified decomp C**
(`vendor/sm64`) in seconds to minutes, *before* spending Coq effort. Counterexamples
come back as concrete traces. This is a falsifier and design oracle, not a trusted
proof: nothing here is imported by `proofs/`.

- Tool: ESBMC 8.5 (`~/tools/esbmc/release/bin/esbmc`), Bitwuzla/Z3 backends, IEEE
  `floatbv` semantics, `--32 --big-endian` (N64 layout), same `-I/-D` set as the
  clightgen pipeline (`run.sh`).
- Collision engine = **contract stubs** whose every clause cites the real engine
  (e.g. `find_floor` returns a floor ≤ `(s16)y + 78`, `surface_collision.c:459`).
  Level facts are explicit and labelled `WMOTR LEVEL CONTRACT`.
- `trace.py log` condenses a counterexample into a readable story.

## Findings so far (air step, `air_step.c` / `air_qstep.c`)

| # | Claim tried | Verdict | What it taught |
|---|---|---|---|
| 1 | gain ≤ max(v,0)+238 with arbitrary water level | **CE in 23 s** | riding shell on water snaps Mario up to the water surface (`mario_step.c:424`). Irrelevant for WMotR (no water, no shell) but must be an explicit level contract: `find_water_level ≡ -11000`. |
| 2 | same, water fixed | **CE** | ledge-grab window is 238 **+ <1**: `find_floor` casts y to `s16`, truncating toward zero, so for negative y the search starts up to 1 unit higher. The true window is 239. |
| 3 | referenced `floorHeight ≤ pos+79` inductive | **CE** | pedro-spot landing (ceil−floor ≤ 160) sets `pos[1]` but not `m->floorHeight`. Staleness is bounded by one quarter step (landing needs `nextPos ≤ floor`). Pedro spots are no-A traps, not lifts. |
| 4 | corrected claims, bit-precise floats | solver OOM / timeout | Bitwuzla hit 6.6 GB in 30 s and Z3 ran more than 11 min, even for one qstep. Proving (UNSAT) is much harder than finding CEs. |
| 5 | per-qstep gain ≤ max(v,0)/4, terminal snap ≤ 239 (`air_qstep.c`, `--ir-ieee`) | **PROVED, 0.9 s** | `--ir-ieee` = reals plus IEEE rounding enclosures (sound over-approximation). Controls: bound 238/200/100 and arbitrary-water all **FAIL**, so it keeps real CEs. |
| 6 | full `perform_air_step`: gain ≤ max(v,0)+239 (`air_step.c`, `--ir-ieee`) | **PROVED, ~13 min** | the Δ_pot airborne arm for one frame, on the real 4-qstep loop. |
| 7 | stale referenced floor grows ≤ one qstep (18.75) | **PROVED** (with +0.01) | the first attempt gave a spurious CE exactly at the tie 79+18.75, from enclosure slack. Near-equality bounds need an epsilon in `--ir-ieee` mode. |

Run: `bash experiments/esbmc/run.sh experiments/esbmc/air_qstep.c vendor/sm64/src/game/mario_step.c -- -DPROP_GAIN --ir-ieee`

**Trust caveats.** These results rest on ESBMC's `--ir-ieee` soundness and on the stub
contracts. Each contract (the `find_floor` +78 bound, walls pushing x/z only, WMotR having
no water) is an obligation to discharge against the real `surface_collision.c` and the level
data, ideally with ESBMC first and then Coq. Treat a PROVED here as "worth proving in Coq",
not as proved.
