# TTC cog Pedro proof plan — 2026-09-06

## Active target

For the pinned `VERSION_US` and `VERSION_JP` programs, exhibit an entry into a
Pedro spot formed by the TTC **cogs**, then controller-selectable RNG changes
while Mario stays in the spot and the relevant cog yaw angles stay fixed.
EU, Shindou, and iQue are outside this claim. The previous all-stock-spots
and spinner objectives are background work, not additional requirements.

The final result must distinguish a finite preservation trace from a strategy
that can continue for arbitrarily many frames. A finite example cannot justify
an indefinite freezing claim. Emulator observations discover witnesses;
generated and linked Clight execution remains the formal semantic target.

The user's explicit gameplay restriction applies to discovery as well as the
final witness: no ACE, out-of-bounds corruption, arbitrary game-memory/code
changes, cheats, forced seeds, or edited save states. The user later authorized
one narrow exception for discovery: spawn Mario near the cogs. Implement that
through a separate declared test initialization (TTC, RANDOM mode, initial
position/orientation), preserving all gameplay behavior functions and using
controller inputs plus observation afterward. Do not force cog states or RNG.
The final entry witness must still use normal game entry and legal inputs.
The repeated content notice was reviewed in
[content-notice-review.md](../content-notice-review.md); its exact trigger remains
unknown. Keep reads focused and retain the same gameplay restrictions.
Preserve provenance for ordinary saves and checkpoints. CompCert `Mem.store`
facts describe stock C assignments within a proof, not an instruction to edit
emulator RAM. Conditional memory-image lemmas need a separate legal-entry
proof before they can establish this gameplay target.

## What the current proof actually establishes

`MainTheorem.v` currently collects generated-AST receipts, executable binary32
calculations, source-derived object/RNG projections, and some genuine CompCert
big-steps. These evidence levels are different:

- `PedroCollision.v`, `LandingDust.v`, and `RNGAdvance.v` inspect generated
  syntax. `InputSemantics.v` computes flat-floor dust/no-dust speed witnesses.
- `DustRuntime.v`, `DustPool.v`, and `DustPRNG.v` reduce an accepted dust request
  to three allocations and four dust-owned RNG calls, with explicit runtime
  premises. `TTCRNGWindow.v` accounts for additional consumers.
- The linked WhitePuff2 path executes one `cur_obj_update` dispatch cycle and
  two actual PRNG calls. The accepted `spawn_particle` caller and the
  parent-bit-clear handler have separate conditional execution proofs.
- `SegmentedPointerBoundary.v` proves that the existing allocation path cannot
  simply execute under standard Clight from symbolic pointers: the N64
  pointer-to-integer/right-shift operation needs an explicit address refinement.
- The existing runtime receipts use debug level select and SLOW mode. They
  establish neither normal entry nor a Pedro/RANDOM-mode witness.
- The spinner geometry and timer results are about a different behavior. Their
  negative result for one fixed pitch interval does not apply to cogs.

No current capstone establishes entry, repeatable Mario control, or reachable
multi-frame cog stasis.
`Print Assumptions` alone cannot detect these missing theorem hypotheses.

The later user priority is to prove or exclude RNG-producing actions under
an in-spot premise, starting with the sliding phase of a slide kick. The
[slide-kick work](ttc-cog-slide-kick.md) adds an exact generated caller proof
with explicit helper residuals, a ground-gap suffix execution and a finite
direct-dust writer inventory. These are included in the active cog capstone.
The [all-RNG follow-up](ttc-cog-all-rng.md) closes generated-source inventory
coverage, including camera, environment, indirect callers, all particle field
writes and the complete Mario particle table. It also executes the real
NONE-mode environmental early return with both real callees. The
[helper execution follow-up](ttc-cog-helper-execution.md) executes the real
cached animation setter/end test and sound request, reducing the caller's
helper residuals from seven to four for that state family. The
[transition follow-up](ttc-cog-transition-execution.md) executes no-wall reflection
and the action transition, leaving sliding and the full ground step. It also
checks the dispatcher dust tail and active-bit rejection. The remaining
helpers, complete dispatcher/entry/following paths, particle acceptance, runtime indirect targets
and preserving control remain open. Controller discovery has found no preserving
sliding-phase event. Continue with those discharges and a specified in-spot
state; do not infer all-action impossibility from unsuccessful route searches.

## Source findings that determine the work

Pinned source: `9921382a68bb0c865e5e45eb594d9c64db59b1af`.

1. `bhv_ttc_cog_update` is already generated in `us_obj_behaviors_2.v` and
   `jp_obj_behaviors_2.v`. RANDOM mode approaches the target by `50.0f`; on
   reaching it, the new target is `200.0f * (random_u16() % 7) * random_sign()`.
   `random_sign` consumes another draw even when the first remainder is zero.
   The current frame's yaw uses speed, not the newly assigned target.
2. Consequently, zero speed/zero target is a potential fixed-yaw state.
   Repeated zero target choices require the magnitude draw to be divisible by
   seven at every relevant update. A nonzero target normally starts movement
   on the next update. Prove this ordering against the exact Clight body.
3. `bhvTTCCog` runs in SURFACE, before PLAYER and dust's DEFAULT/UNIMPORTANT
   phases. A dust request cannot change an earlier cog draw on the same frame.
4. There are six hexagonal and two triangular macro cogs. The lower staircase
   hexagons have height differences near their 153-unit thickness. Their
   thin overlap is a promising collision witness, but pairwise overlap alone
   does not prove the actual floor/ceiling queries or entry.
5. `AIR_STEP_LANDED` selects an action; dust is requested later. Flat-floor
   input arithmetic does not prove that both inputs preserve position, the
   referenced floor, speed availability, or a repeatable landing action.
6. `act_freefall_land` calls `common_landing_cancels` before the dust-producing
   `common_landing_action`. `INPUT_OFF_FLOOR` can cancel that path. The edge
   placement actually has this bit and a referenced floor at Y=-8191; inspect
   these conditions at a successful entry rather than assuming the landing
   action executes its dust code.
   [The floor/action analysis](ttc-cog-floor-actions.md) distinguishes the
   attempted-position floor query from the next frame's actual-position query
   and records other particle actions that still need preserving witnesses.

## Execution order and acceptance criteria

### 1. Establish the cog source and geometry boundary

- Extend the existing generator with wrappers for the stock hexagon and
  triangle collision arrays. Preserve the pin, preprocessing flags, and both
  version builds; do not edit generated files by hand.
- Decode the actual macro inventory, preset-to-behavior/shape association,
  collision layouts, and SURFACE update order.
- Search using generated initializers and exact binary32/trigonometric-table
  arithmetic. Certify a concrete pair of triangles, cog poses, horizontal
  query point, normal orientations, and gap in Coq. Check load distances and
  competing surfaces separately before calling it a gameplay witness.
- Wire the result into a clearly named cog capstone in `MainTheorem.v`.

### 2. Establish the exact freezing condition

- Pin the complete RANDOM branch and yaw-store order, not just occurrences of
  the numbers 7, 50, and 200.
- Execute the generated approach helper and cog update, starting with zero
  speed and target; expose memory, function binding, and RNG call premises.
- Account for signed binary32 zero and the integer yaw cast. Prove that a
  nonzero new target does not move this frame but defeats next-frame stasis.
- Search the finite PRNG state graph for candidate control schedules. Keep
  the count of other RNG consumers explicit; a dust/no-dust choice is not an
  arbitrary RNG draw. Reject schedules that assume the result they seek.

### 3. Find a real entry and repeatable controller witness

- Instrument US/JP in Ubuntu-24.04. Reuse ROM authentication and read-only
  object-pool/RNG tracing; add cog speed/target/yaw, Mario action, position,
  referenced and queried surfaces, controller input, and exact update order.
- Accepted entry replays must use legal controller inputs from a declared
  ordinary save or checkpoint with gameplay provenance. The user-authorized
  placement experiment can test local behavior but cannot satisfy this item.
  The former cheat-enabled `ttc-runtime-snapshot/run-probe.sh` is retired;
  its historical receipts are not eligible entry witnesses. Do not reuse its
  debug-menu input sequence. Any reused observer must leave guest memory,
  registers, and instructions unchanged.
- Find both a dust and no-dust continuation from the same in-spot state.
  Verify the requested versus accepted dust bit, sufficient pool reserve,
  action transitions, ground/air quarter steps, and all competing RNG calls.
- Repeat the experiment independently on US and JP. Hash any replay and state
  provenance; do not commit ROM data.

### 4. Close the formal execution gaps

- Execute the concrete Pedro air branch and the subsequent landing/ground
  branch against the generated AST and exact selected collision surfaces.
- Resolve the symbolic-pointer boundary with a sound N64 address refinement,
  then instantiate allocation/list topology and the complete dust chain.
- Compose the SURFACE → PLAYER → DEFAULT → UNIMPORTANT → next-SURFACE frame
  executions with the discovered finite controller schedule.
- State the finite entry/preservation theorem first. An indefinite theorem
  additionally needs a recurrent state or inductive controller invariant that
  includes Mario's speed/action, both cogs, RNG, pool, and other live objects.

## Verification and environment

- Actual repository: `reference-sm64-wmotr-abc-proof`; branch:
  `codex/ssl-pyramid-item-proof`. Preserve the existing untracked root `build/`.
- Ubuntu login shell provides Coq 8.16.1, CompCert/clightgen 3.15, and opam
  switch `sm64-item-proof`; use `Pedro-Coq/pipeline/*.sh`, never bare `coqc`.
- The root proof-discipline audit selects the absent `sm64-proof` switch by
  default. With `SM64_PROOF_SWITCH=sm64-item-proof`, the post-change audit
  passes (exit 0, `build/cog-root-discipline.log`). It audits the separate no-A
  project. Pedro's build, no-hole check, reproducibility check, and capstone
  assumption checks remain the project-specific evidence.
- If committing, use author/committer email `tariq.rafiq.ali@gmail.com`.

## Results and remaining work

The [successive-update check](ttc-cog-successive-updates.md) now tests complete
action boundaries, bracketing Mario/cog poses, off-floor geometry, nonzero
attempted motion and repeated close-gap returns. Thirty-five further route
trials and a 4296-event US/JP ordinary-air replay still provide no sustained
witness. The single new return is followed by supporting-floor geometry.
Keep entry and preserving input/RNG control open; the check is discovery
tooling and has no validated positive gameplay example yet.

The [controller-detour follow-up](ttc-cog-detour-followup.md) completes 48
bounded route/phase searches and adds complete action/surface observations.
A fixed ground-pound entry candidate executes the close-gap landing branch
in US and JP with particle requests. Its zero horizontal speed, existing
supporting floor and prior cog displacement prevent treating it as sustained
Pedro entry or preserving RNG control. Both replays and comparison receipts
are saved; the preserving-input comparison remains pending.

The generated cog arrays, inventory, preset mapping, behavior ordering, and
154-unit pairwise collision certificate are compiled in `TTCCogGeometry.v`.
`TTCCogApproachExecution.v`, `TTCCogRNGExecution.v`, and `TTCCogExecution.v`
execute the generated zero-speed RANDOM update, including its callees, from
seed 16 to 59500 to 54874 with unchanged yaw 57344. The combined
`MainTheorem.checked_ttc_cog_local_mechanism_us_jp` consumes this work. Its
symbol, layout and memory-image premises still need a reachable linked
instance; it does not assert entry or controller control.

`TTCCogRNG.v` certifies an exact four-draw arithmetic example. The discovery
search found no infinite continuation in its simplified consecutive-pair
model with a fixed 0 through 8 other calls. This is not a negative theorem
about the actual cog pair or all gameplay RNG controls.

The three placement setups ran in US and JP. The back-of-cog setup selects an
actual floor and ceiling separated by 154 units, but Mario follows the cog and
falls. The edge setup also falls. Neither yields a Pedro branch. A US controller
approach from the test ledge reaches the lower cog, and a standalone replay
reproduces its 2250 input/Mario/cog records. The independent JP replay agrees
with the US logical event sequence, including all RNG and air-step calls.
A traced replay of the back-of-cog jump attempt also falls with no Pedro
branch. Version comparisons and RNG recurrence checks pass.
See [the experiment report](ttc-cog-placement-results.md)
and [the video review](ttc-cog-video-review.md) for hashes and limitations.

The full Pedro proof build passes (`build/cog-full-proofs.log`), as do the
no-hole check and all named capstones' assumption checks. A trie-based
fresh-name check removed a severe computation bottleneck in the existing RNG
census uniqueness proof without changing that theorem's statement. The
separate root audit also passes. WSL commands repeatedly exited without a Coq
diagnostic; one subsequent launch reported `Wsl/Service/E_UNEXPECTED`. The
remaining assumption checks completed through individual pipeline invocations.
The unmodified two-pass regeneration pipeline then passed in a temporary Linux
copy with authenticated pipeline/input files: both runs agree, and all 56
outputs match the workspace byte for byte (`build/cog-repro-local.log`, exit 0).
The precise cause of the earlier interruptions is not established. Source
restoration now verifies the complete pin and preserves unchanged files, and
Clight generation preserves timestamps for identical output.

The next discovery milestone is a sustained close-gap state reached by the
controller detour at a natural cog phase. The observed ground-pound impact
does not discharge it. Then test paired preserving inputs against the recorded
complete cancellation, ground-step and particle paths. Normal-entry
provenance, whole-frame linking/address refinement, other RNG consumers, and
an explicit preservation duration remain open. Failed placement trials do
not settle whether the requested gameplay target is possible.

If the mounted-workspace regeneration is interrupted again, the successful
Linux-local check can be reproduced from the repository root in Ubuntu:

```sh
project="$(cd Pedro-Coq && pwd)"
scratch="$(mktemp -d /tmp/pedro-cog-check.XXXXXX)"
cp -a "$project/pipeline" "$project/inputs" "$scratch/"
SM64_SOURCE="$project/../../reference-sm64-decomp" \
  bash "$scratch/pipeline/check-reproducible.sh"
diff <(cd "$project/generated" && sha256sum *.v) \
     <(cd "$scratch/generated" && sha256sum *.v)
```
