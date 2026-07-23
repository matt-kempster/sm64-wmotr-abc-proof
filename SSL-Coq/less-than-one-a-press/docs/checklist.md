# Verification checklist

- [x] Exact decomp commit pinned.
- [x] US and JP macros generated separately.
- [x] Generate 25 translation units per version (50 Clight modules), including
  the Mario action units, movement code, `mario_step`, `obj_behaviors_2`, and
  `surface_collision`.
- [x] Input edge and held state distinguished.
- [x] Act 3, Act 6, and 100-coin indices checked from source.
- [x] Static Act 3 object and five hidden triggers checked from initializers.
- [x] Event vocabulary names spawn, deletion, reuse, macro respawn,
  unload/reload, instant warp, and collision timing.
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
- [x] Add a software-engineer-oriented
  [`human-readable-proof.md`](../human-readable-proof.md).
- [x] No-hole source scan and assumption reports are part of `make check`.
- [ ] Construct an iterated link of the imported translation units and prove
  the `TargetLinkedProgram` link-order certificate.
- [ ] Define concrete state, input, event, and complete collision-observation
  projections for actual initial-to-final Clight runs.
- [ ] Prove both `WholeProgramClightRefinementObligation` and
  `CleanEntryProjectionCoverageObligation` for that projection.
- [ ] Derive constructor origin, collision, spawn, trigger, lifecycle, and
  preservation premises from Clight instead of assuming them in steps.
- [ ] Connect any archive-derived kernel component needed on the capstone spine
  through a checked execution/refinement theorem; the current kernel by itself
  discharges no Layer A or Layer B residual.
- [ ] Prove complete current-program writer coverage before using the
  parallel-universe alias-gap subcase globally.
- [ ] Replace the legacy integer pole subcase with current Float32,
  collision-phase reasoning plus a complete lower-route case split.
- [ ] Prove which JP raw-platform cases are reachable and bound every reachable
  spawning displacement.
- [ ] Project chronological Mario/action/surface observations from Clight and
  prove the transcript route contract complete for both entrances.
- [ ] Define the elevator and second-pole cuts over exact collision surfaces,
  prove both no-A gate closures, and validate separate downstream continuations
  to the Act 3 region and all five Act 6 triggers.
- [ ] Prove `LowerEntranceReachabilityObligation`.
- [ ] Prove `UpperUSReachabilityObligation`.
- [ ] Prove `UpperJPReachabilityObligation`.
- [ ] Remove the conditional premises and prove the ultimate result.
