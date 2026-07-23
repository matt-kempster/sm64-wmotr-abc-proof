# Verification checklist

- [x] Exact decomp commit pinned.
- [x] US and JP macros generated separately.
- [x] Generate 27 translation units per version (54 Clight modules), including
  the Mario action units (with `mario_actions_cutscene`), movement code,
  `mario_step`, `obj_behaviors_2`, `surface_collision`, and a wrapper for the
  route-relevant SSL static and dynamic collision arrays.
- [x] Check generated no-spin-airborne entry call shape, collision initializer
  lengths, and exact US/JP equality for the imported route-relevant collision
  arrays.
- [x] Input edge and held state distinguished.
- [x] Act 3, Act 6, and 100-coin indices checked from source.
- [x] Static Act 3 object and five hidden triggers checked from initializers.
- [x] Strengthen clean entry with exact lower/upper warp snapshot, coherent
  active/backup target bits, exact static Act 3 position, and five distinct
  designated trigger identities/positions.
- [x] Prove the finite normal SSL star-index inventory, coherent-reload
  exclusion, and anomaly-free first-target writer classification in the
  executable source-inventory kernel.
- [x] Event vocabulary names spawn, deletion, reuse, macro respawn,
  unload/reload, save reload, explicit Mario motion, instant warp, and
  collision timing.
- [x] Constructor-inversion collection/provenance reduction builds without
  proof holes; full lifecycle effects and its Clight refinement remain open.
- [x] Recheck the six archive-derived evidence components against the current
  project where they make source claims, and prove
  `archived_proof_integration_kernel_holds` without importing archived ASTs.
- [x] Keep the held-A, parallel-universe, normalized-pole, and demo-memory
  `RouteEvidence` lemmas narrow and explicitly separate from authentic route
  completeness.
- [x] Model `gMarioPlatform` abstractly as a pool slot plus ghost capture epoch
  and prove the null/live/inactive/reused case split under explicit slot
  well-formedness; its C-memory projection remains open.
- [x] Document what each archived project supports and does not support in
  [`archived-proof-evidence.md`](archived-proof-evidence.md).
- [x] Encode the transcript's elevator/second-pole route contract and prove its
  gate, bypass-refutation, and conditional downstream-access lemmas without
  presenting the graph as a target-ROM refinement.
- [x] Select the exact first target observation/event prefix and prove
  entrance-specific “A gate or one of nine named bypass class tags” lemmas
  under the broad `FirstTargetCutClassificationObligation`; the tags are not
  yet state/event evidence.
- [x] Define `ClightFrameEvidence`, a total certified-event writer inventory,
  evidence-bearing bypass classes, and `CollisionSupportCut` crossing
  witnesses.  Prove the limited certified-semantics exclusions for direct
  zero-offset instant warp, invalid target provenance, invalid hidden-star
  lifecycle, coherent save reload, and projection mismatch.
- [x] Demonstrate that endpoint/event alignment alone cannot imply first-cut
  classification, and record the abstract arbitrary-motion/immediate-target
  counterexample for explicit clean US/JP entries.
- [x] Preserve the conditional JP upper-warp/pyramid-top stale-pointer path in
  a source-backed predecessor/unload/reuse evidence interface rather than
  assuming a null or harmless retained pointer.
- [x] Record the authentic-JP boundary-fixture constructor: the exact stale
  top raw transform payload, a zero-A input schedule, platform displacement out
  of the shaft, upper-trigger consumption with no Act 3 overlap or Act 6 star
  spawn, and the failed pre-transition-only preparation.  Save RAM was not
  directly read.  This closes the state-only bypass-unreachability alternative,
  not stock reachability or the newly-set-bit theorem.
- [x] Document the alternative-route coverage boundary in
  [`route-exhaustiveness.md`](route-exhaustiveness.md).
- [x] Add a software-engineer-oriented
  [`human-readable-proof.md`](../human-readable-proof.md).
- [x] No-hole source scan and assumption reports are part of `make check`.
- [ ] Construct an iterated link of the imported translation units and prove
  the `TargetLinkedProgram` link-order certificate.
- [ ] Define concrete state, input, event, and complete collision-observation
  projections for actual initial-to-final Clight runs.
- [ ] Prove both `WholeProgramClightRefinementObligation` and
  `CleanEntryProjectionNonvacuityObligation` for that projection.
- [ ] Derive constructor origin, collision, spawn, trigger, lifecycle, and
  preservation premises from Clight instead of assuming them in steps.
- [ ] Prove Clight-to-writer coverage for the finite normal-star/save
  inventory, excluding the explicit corruption/unmodeled writer for clean
  target executions.
- [ ] Connect any archive-derived kernel component needed on the capstone spine
  through a checked execution/refinement theorem; the current kernel by itself
  discharges no Layer A or Layer B residual.
- [ ] Prove complete current-program writer coverage before using the
  parallel-universe alias-gap subcase globally.
- [ ] Replace the legacy integer pole subcase with current Float32,
  collision-phase reasoning plus a complete lower-route case split.
- [ ] Prove which JP raw-platform cases are reachable and bound every reachable
  spawning displacement.  In particular, prove or refute the conditional
  upper-warp/spinning-top unload setup, including warp-to-top, top-to-warp, and
  collision-preserving clone possibilities.
- [ ] Project chronological Mario/action/surface observations from Clight and
  prove the transcript route contract complete for both entrances.
- [ ] Construct `EvidenceBearingFirstTargetCutClassification` from that
  projection and the parsed collision mesh; close every remaining writer class
  or record a reachable constructor as a counterexample.  Only then derive
  `FirstTargetCutClassificationObligation`.
- [ ] Define the elevator cut and the lower target-side support/open-cell cut
  over exact collision surfaces, prove both no-A gate closures, and validate
  separate downstream continuations to the Act 3 region and all five Act 6
  triggers.  Do not use “above the second pole” as the lower geometric cut.
- [ ] Prove `LowerEntranceReachabilityObligation`.
- [ ] Prove `UpperUSReachabilityObligation`.
- [ ] Prove `UpperJPReachabilityObligation`.
- [ ] Remove the conditional premises and prove the ultimate result.
