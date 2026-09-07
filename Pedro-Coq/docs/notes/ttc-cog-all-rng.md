# All RNG sources: coverage proof and execution boundary

The full theorem classifying **preserving controller control in the cog Pedro
spot remains open**. This work closes the generated-source inventory gap and
proves one complete environmental exclusion path. It does not establish that
Mario can or cannot create dust there. The slide-kick caller still has its
four remaining helper-execution premises after the
[animation and sound execution follow-up](ttc-cog-helper-execution.md).

Scope is the gameplay `gRandomSeed16` generator used by TTC cogs, with the
pinned US/JP configurations only. Audio has a separate generator; an audible
effect is not by itself evidence that the cog RNG changed. Source revision is
`9921382a68bb0c865e5e45eb594d9c64db59b1af`.

## What is now checked

`MainTheorem.checked_ttc_cog_rng_source_frontier_us_jp` combines the new
results and is consumed by `checked_ttc_cog_local_mechanism_us_jp`.

The pipeline now generates **41 translation units per version**, including
all seven Mario action groups, interaction, camera, both environmental-effect
implementations, menu/dialog code, level geometry callbacks and TTC geometry.
The 26 new generated files are mechanical `clightgen` outputs. Existing outputs
are unchanged. The menu unit's text headers are reproduced with the pinned
upstream text converter and inputs.

`RNGEffectSyntax.v`, `RNGSourceCatalogue.v`, and `RNGSourceCoverage.v` prove:

- Every syntactically occurring direct call to `random_u16`, `random_float`,
  or `random_sign` in these generated function bodies appears in the exact
  checked caller/callee list. Switch cases, both loop bodies, labels and both
  conditional branches are traversed.
- There are **282 direct call sites per version**. These are syntax counts,
  including calls inside RNG wrappers, not draws per frame or a reachable
  TTC execution count.
- There are no references to those primitive names outside direct-call
  positions in the examined function bodies, and no primitive/seed addresses
  in their global initializers. Only `random_u16` syntactically refers to
  `gRandomSeed16`. This is not a general memory-alias theorem.
- Every computed call in the corpus has its caller among **16 checked
  functions**. They are retained as unresolved boundaries rather than silently
  treated as RNG-free.
- All direct `particleFlags` field assignments, including clears and arbitrary
  computed right-hand sides, occur in **53 checked functions** per version.
  Structural completeness is proved independently of the expected lists.
  This covers more than the previous 13 literal dust writers.

The inspected function-body totals are 3,068 for US and 3,057 for JP, counted
by translation unit. The primitive call sites are distributed as follows:

| Generated unit | US | JP |
| --- | ---: | ---: |
| `camera` (also includes intro/ending behaviors) | 10 | 10 |
| `envfx_snow` | 13 | 13 |
| `envfx_bubbles` | 12 | 12 |
| `behavior_script` (includes RNG wrappers) | 7 | 7 |
| `object_helpers` | 15 | 15 |
| `obj_behaviors` | 54 | 54 |
| `behavior_actions` | 133 | 133 |
| `obj_behaviors_2` | 38 | 38 |
| Other 33 generated units | 0 | 0 |

In particular, none of the seven Mario action translation units directly
calls an RNG primitive. Their helpers, particle requests and interactions
still matter. Absence of a direct call does not exclude a transitive effect.

The computed-call callers are `common_landing_cancels`,
`mario_process_interactions`, four camera dispatchers, `bhv_cmd_call_native`,
`cur_obj_update`, seven graph-node callback functions, and
`cur_obj_call_action_function`. These are the callers in this corpus, not a
claim that no other whole-game unit has a function pointer.

## Complete Mario particle table

`MarioParticleCatalogue.v` decodes every generated initializer row and the
terminal sentinel of `sParticleTypes`. Missing sentinels, trailing data,
malformed rows and nonzero behavior-pointer offsets fail the decoder.
Both versions have exactly these 18 request entries in the actual table order:

1. Dust/mist
2. Vertical stars
3. Horizontal stars
4. Sparkles
5. Bubbles
6. Water splash
7. Idle water wave
8. Plunge bubbles
9. Wave trail
10. Fire
11. Shallow water wave
12. Shallow water splash
13. Leaves
14. Snow
15. Breath
16. Dirt
17. Mist circle
18. Triangles

The exact request masks, active masks, model numbers and behavior identifiers
are Coq-checked. A coverage theorem handles **every 32-bit request mask**,
including computed combinations, and bounds selection by these entries.
This is a table-selection theorem. Runtime table preservation, dispatch,
allocation, native spawns, child behaviors, pool competition and ordering still
need execution proofs. A request is not yet an accepted particle or an RNG draw.

## A complete executed exclusion

`EnvironmentNoRNG.generated_environment_none_preserves_all_memory_us_jp`
executes the real generated `envfx_update_particles` with mode NONE, given
`gEnvFxMode = 0`, `gDialogID = -1`, and the stated symbol/function bindings.
It also executes the real `get_dialog_id` and `envfx_init_snow` bodies; no
callee execution is assumed. The function returns NULL with **identical
memory**, so the seed is unchanged on this path.

The proof separately reads TTC's actual geometry initializer and checks its
`geo_envfx_main` callback command has argument zero. It has not yet executed
the geometry interpreter/callback and established the environmental globals
across normal TTC entry. Thus this closes the specified NONE-mode execution,
not an unconditional theorem about every frame labelled TTC.

The silent CompCert trace `E0` alone is not used as evidence of no RNG:
internal RNG calls can also have silent traces. The proof supplies the actual
selected caller/callee execution and its identical-memory postcondition.

## Source provenance and trust boundary

`pipeline/check-rng-source-coverage.py` reads the pinned Git archive, independent
of modifications in the working decomp tree. It accounts for **81 C/header
files** containing primitive/seed identifier tokens, including behavior
includes, and checks their literal-include coverage by generated units. It
rejects uncovered files, additional seed-reference files and assembly
references. The checked receipt also hashes all 82 generated outputs.

This is a conservative source-token/include gate, including inactive branches.
It is not a formal proof of the C preprocessor, fully linked program or N64
semantics. Reproducible generation authenticates the generated ASTs; Coq checks
their exact inventories. In particular, primitive-name coverage does not
resolve runtime pointer targets, external functions or memory aliases.

## What still prevents the requested all-ways conclusion

A four-frame pause and the pairwise gap do not specify Mario's action, retained
floor, action timer, speed, nearby/held objects, pending particles, camera state,
or scheduler position. Those values distinguish the paths being classified.
The remaining work is to:

1. Establish a precise legal in-spot state or state family and preserving
   successive action updates. For the slide kick, execute the four remaining
   helpers, its dispatcher/entry path and the following knockback update.
   Establish the live animation-cache and sound-queue images used by the
   three now-executed helper calls.
2. Resolve the relevant indirect targets and native/scripted child spawning.
   Prove which of the 53 writer functions and other interaction paths are
   reachable while the spot invariant holds. Exclude the others by actual
   branch/state invariants, not by their names or unsuccessful route searches.
3. Connect accepted requests and existing objects to full scheduled execution,
   including SURFACE before PLAYER and the later particle lists. The existing
   `segmented_to_virtual` theorem identifies a concrete obstacle: standard
   Clight cannot perform its integer shift on a symbolic global pointer.
   Completing allocation requires a justified N64 address refinement, not a
   replacement allocator assumption.
4. Account for camera/environment paths and exact ordered draws over the
   preserving window. Compare two controller continuations from the same
   admissible state, or prove their impossibility for the specified state family.

This is not a negative gameplay result. None of the new theorems establishes
or refutes sustained in-spot dust, another preserving RNG choice, or indefinite
cog freezing. No new gameplay experiment, forced state, ROM modification or
emulator memory edit was performed in this source/proof work.

## Validation

- All 82 generated outputs agree across two successive generation passes in
  an authenticated Linux-local copy. Prior outputs remain byte-identical.
- The full Pedro Coq project, including the expanded active capstone, compiles
  through `pipeline/build.sh proofs` in `sm64-item-proof`.
- Source coverage and proof-hole checks pass. Deliberately omitting the camera,
  snow or bubbles unit in three in-memory test inventories is rejected.
- Both expanded cog capstone assumption audits contain only standard
  Coq/CompCert assumptions. The separate root proof-discipline audit passes.

Local generation/build logs are under `build/all-rng-*.log`. The durable
source coverage receipt is `inputs/rng-source-coverage.json` and the
[validation receipt](../../inputs/rng-frontier-validation.json) records successful
checks, file/log digests and the open obligations. The checked statements and
explicit entry premises are in the proof files themselves.
