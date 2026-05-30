# Plan: whole-program enumeration of MarioState.action writers (closing leak #3 for the action field)

> Plan doc (2026-05-29), written to survive a compaction. Motivation: our verified
> `mario_action_writers` / `flying_setters` results (`Flying.v`) are **per-TU**. They say nothing
> about the ~100 other standalone `.c` files. A writer in `mario_actions_submerged.c`,
> `mario_step.c`, `camera.c`, etc. is currently *invisible* to what we've proved. This is leak #3.
> See [ROADMAP.md](ROADMAP.md), [must-press-a-to-fly.md](must-press-a-to-fly.md),
> [whole-program-and-the-interpreters.md](whole-program-and-the-interpreters.md).

## Why grep is not enough (the proof we already have)

A whole-tree `grep "->action ="` **misses `mario.c:1840`** (a multi-line `gMarioState->action =`
in `init_mario`). Our clightgen'd analysis *caught* it — that's why `mario_action_writers
mario.prog` has count **3**, not 2. So the verified Clight analysis is strictly stronger than
grep, and grep demonstrably leaks. Hence: a `.v` per relevant `.c`, analyzed.

## Scope decision (agreed)

- **IN: `src/game` (49 standalone .c) + `src/engine` (9).** Gameplay state lives here.
- **OUT (trusted boundary, stub as needed): `src/audio` (15), `src/goddard` (28), `src/menu`,
  `src/buffers`, libultra/OS.** Argue "cannot hold a `MarioState*` / reach `gMarioState`" as a
  named assumption. Audio's `adsr->action` is a *different* struct (already excluded by the
  type-aware analysis).
- Engine relevance (checked): only **3 of 9** engine files even mention Mario state —
  `behavior_script.c`, `surface_collision.c`, `surface_load.c`. The other 6 (`math_util`,
  `graph_node*`, `geo_layout`, `level_script`, `stub`) are Mario-state-free (still worth
  clightgen'ing for completeness, but low-risk).

Net: ~58 TUs IN; the *action-relevant* subset (those referencing `MarioState`/`gMarioState`) is
much smaller and is the real audit target.

## Steps

1. **Pipeline: a `clightgen-all`-style target.** Generalize the Makefile recipe (the `SM64_CG`
   flags already work) to generate `generated/<name>.v` for each IN `.c`. Do it **incrementally,
   verifying each with `coqc`** — some TUs may hit clightgen rejections (inline `asm`, level-data
   macros like the ones that blocked R4). Record rejects as stubs.
   - Known-good already: mario, mario_actions_airborne/moving/automatic, level_update,
     interaction, behavior_actions, shadow.
   - First batch to add: the other Mario-action TUs — `mario_actions_submerged.c`,
     `mario_actions_stationary.c`, `mario_actions_cutscene.c`, `mario_actions_object.c`,
     `mario_step.c`, `mario_misc.c` — these are the highest-probability action writers.

2. **A whole-program scan file (`proofs/ActionWriters.v` or extend `Flying.v`).** `Require` all
   generated game/engine modules. For each, compute `mario_action_writers _MarioState _action prog`
   and `flying_action_writers … prog`. Assert (reflexivity): the union of writers is exactly the
   enumerated list, and **every** `flying_action_writers = []`.
   - Caveat: `_MarioState` / `_action` idents are per-module; pass each module's own.
   - Use the **count + per-name** style (robust vs ident positive-printing; learned in R1b).
   - GOTCHA: `Flying.v` has `Open Scope Z_scope` → list counts need `%nat`.

3. **State the consolidated theorem.** "Across all IN TUs, the complete set of functions that
   directly write `MarioState.action` is {…}, and none writes a flying constant." Keep it readable
   (the audit surface).

## The three residual gaps this does NOT close (name them, don't hide them)

1. **Indirect / aliased writes (leak #1).** A field-write analysis misses `memcpy`/`memset` of the
   struct, `rawData` union punning, pointer arithmetic into `gMarioState`. Separate obligation
   (escape/havoc machinery).
2. **Cross-TU calls (leak #3 proper).** Even with every TU scanned, "writers across the program"
   is a *conjunction* until CompCert `Linking` makes it one whole-program `prog`. The scan is the
   prerequisite; linking is the closer.
3. **Stubbed boundary.** Audio/goddard/libultra correctness rests on the "can't reach Mario state"
   assumption — trusted, listed, ideally spot-checked.

## Progress (2026-05-29)

**Batch 1 done** (`proofs/ActionWriters.v`, builds clean; all 12 lemmas are
"Closed under the global context" per `Print Assumptions`, same as Flying.v's
per-TU lemmas — verified via `bash pipeline/assumptions.sh`. We deliberately keep
the 12 individual lemmas and do NOT bundle them into one `/\` theorem: a bundled
conjunction reports CompCert's 4 standard float axioms (Flocq) no matter how it's
proved, because its *type* mentions the prog float constants and Print Assumptions
traverses the type — so the fully-closed artifact is the lemma list, not a headline
conjunction.) Added six TUs and re-ran the verified
`Flying.mario_action_writers` / `flying_action_writers` scans:

| TU | #action writers | flying writers |
|----|----|----|
| mario_actions_submerged | 0 | `[]` |
| mario_actions_stationary | 0 | `[]` |
| mario_actions_cutscene | 0 | `[]` |
| mario_actions_object | 0 | `[]` |
| mario_step | 0 | `[]` |
| mario_misc | 0 | `[]` |

All six have **zero** direct `MarioState.action` field writers: these TUs change
Mario's action *only* by calling `set_mario_action`, never by raw-poking the
field. (Non-vacuity: the same `mario_action_writers` returns the non-empty Flying.v
sets — mario=3, interaction=2, etc. — so empty here is a real "no writer".)
Stated as 12 individual closed lemmas (six `*_action_writers_empty` + six
`no_raw_flying_action_write_*`). Combined with Flying.v's six TUs, the only route
to a flying action remains `set_mario_action` called with a flying argument (the
five R1 sites). Still a conjunction of per-TU facts (leak #3 proper
= Linking) and syntactic-field-write only (leak #1).

Next batch: the broader MARIO-flagged `src/game` set (camera, area, obj_behaviors,
object_helpers, platform_displacement, paintings, ...) then `src/engine`'s 3
Mario-touching files (behavior_script, surface_collision, surface_load).

## Definition of done (for this slice)

Every `src/game` + `src/engine` `.c` either (a) has a `generated/*.v` with its
`mario_action_writers` enumerated and `flying_action_writers = []` proved, or (b) is on an
explicit stub/reject list with a one-line reason. The consolidated writer set is one readable,
reflexivity-checked statement. Leaks #1 and the Linking step remain explicitly open.
