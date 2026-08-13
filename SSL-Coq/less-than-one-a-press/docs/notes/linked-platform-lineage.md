# Linked platform-lineage boundary

## Verdict

The linked-Clight tranche closes a source-to-official-program syntax gap and
proves individual platform-global store/load steps in CompCert's Clight
semantics.  The scoped start is **SSL Area 1 (the exterior)**, represented
formally by `DefaultArea1StartBoundary`.  `DefaultArea1StartChronology.v` decodes the
chronology seed from the supplied active run-start memory, requires a nonempty
`Smallstep.plus`, and proves that a supplied preapply projection whose seed is
equal to that decoder cannot finish as retained JP inbound lineage.  It does
not derive the projection's event list from those Clight steps.  Four
post-boundary lineage cases remain.

The strongest new conclusion is this:

- in the constructed official cleaned US and JP linked slices, there is no extra direct
  named internal writer, address-taking site, or direct caller that was absent
  from the earlier source-union census; and
- in JP, when placed at each checked data-bearing statement with its explicit
  evaluation, symbol, store/load, and frame premises, real Clight steps store
  the supplied owner pointer and load the preserved platform cell into the
  apply function's local `platform` temporary.

Reachability of those fragments, evaluation of `Surface.object` from a live
`find_floor` result, and preservation of the cell between the store and a later
apply remain premises. Therefore this is a dataflow and framing boundary, not
a clean installer or an impossibility theorem.

`Area1QueryScheduleClosure.v` now checks the bilateral generated-AST chain
from `gMarioObject.rawData.asF32[6..8]` through the three query temporaries to
the immediately following `find_floor` call.  `Area1SurfaceOwnerSyntax.v`
checks the bilateral loader order from `gCurrentObject` to a `Surface.object`
store and then to a later `add_surface(surface, 1)` call with the same syntactic
surface-temporary identifier; it also checks that the static loader uses flag
`0`.  It does not prove that the temporary is unreassigned before the call.
These are exact source-syntax and partition-flag facts, not proofs that the
relevant call executes or that the surface, list, or owner remains live and
canonical in linked memory.
The split platform-update receipt chain also resolves both selected Clight
targets' `update_mario_platform` symbols to these exact generated bodies, so
the remaining gap is execution and memory preservation rather than body
selection.

## Official-link syntax closure

`proofs/LinkedPlatformLineageSyntax.v` proves upper bounds about the
constructed official cleaned linked program definition lists:

- every direct assignment whose lvalue visibly names `gMarioPlatform` is in
  `update_mario_platform`, except that US also has `clear_mario_platform`;
- no retained internal body directly takes the address of the
  `gMarioPlatform` cell;
- any retained internal body that directly calls `update_mario_platform` must
  be named `update_objects`.

These are generated-AST and official-`prog_defs` facts. They do not detect a
store through an aliased pointer, constrain unresolved external calls, prove
that an indirect call cannot reach another effect, or execute a complete
retail frame.

The file retains the general five-field interface
`FiveLinkedLineageClosures`.  Under the null scoped seed,
`FourNullSeedLinkedLineageClosures` packages the four completed-query facts.
The implications

```text
FiveLinkedLineageClosures -> False
NULL seed + FourNullSeedLinkedLineageClosures -> False
```

check that each interface is sufficient.  Null-seed chronology is checked;
none of the four completed-query fields is yet derived from linked execution.

## JP platform-global store and load

`proofs/JPLinkedPlatformGlobal.v` checks the exact generated fragments:

```text
Surface.object -> temporary -> gMarioPlatform
gMarioPlatform -> apply_mario_platform_displacement's platform temporary
```

It proves exact generated-source receipts for the updater/store and apply/load
fragments. Concrete official-symbol/block resolution, declaration kind,
storage bounds, writability, and initial memory contents remain open.

At the semantic level, the file proves:

- a real `Clight.step2` for the `Surface.object` temporary assignment;
- a real `Clight.step2` for storing that pointer in the global cell;
- a real `Clight.step2` loading the global cell into the apply temporary;
- an immediate same-cell load after a successful `Mem.store`; and
- a generic CompCert frame lemma for reads from a block distinct from the
  platform-global block.

These semantic lemmas quantify over an abstract Clight global environment.
Specializing them to the constructed official cleaned JP global environment
and resolving its concrete symbol blocks remain open, as does composing the
individual sequence/skip steps into the complete fragment trace.

The later-apply theorem deliberately assumes equality of the platform-cell
load between the stored memory and the apply memory. That equality is the
unproved frame across all intervening linked steps. The temporary-assignment
theorem separately assumes that the `Surface.object` expression evaluates to
the supplied owner pointer. The selected-body receipt now closes the generated
body-resolution question; it does not execute the preceding floor query or
branch.

## Status of the lineage cases

| Lineage case | New checked evidence | Remaining retail obligation |
| --- | --- | --- |
| Different query and current collision samples | The official-slice direct-writer/address/caller upper bounds exclude an extra recognized named platform-cell writer; the exact selected updater body loads raw Object slots 6–8 into the immediately following `find_floor` arguments. | Execute the complete upper-warp frame and prove which intervening writers, callbacks, or external effects can change the Object identity/sample after that query. |
| Canonical owner outside modeled geometry | The exact bilateral loader syntax assigns `gCurrentObject` to `Surface.object` before a later dynamic insertion call using the same syntactic surface-temporary identifier, while static insertion uses flag `0`. | Prove the temporary is unreassigned, execute `find_floor` and the dynamic surface-list traversal, prove list integrity, and connect the returned `Surface.object`, transformed geometry, and query coordinates to the canonical finite owner model. |
| Recognized owner with noncanonical slot or allocation epoch | The exact stored pointer is exactly what an immediately following same-cell load returns. | Connect the resolved official JP symbols and initial `gObjectPool` block to current runtime memory; prove that the owner pointer is an in-bounds pool slot; bind its block/offset and ghost allocation epoch; and exclude stale or reused identities where required. |
| Unclassified dynamic owner | The official direct named writer census is closed. | Prove exhaustive live behavior/collision-owner provenance, including clones, relocated collision, aliased stores, runtime spawns, and external effects. |
| Retained JP inbound lineage transported to the upper warp | **Absent from the scoped abstract interface once seed agreement is supplied.** The SSL Area 1 (the exterior) boundary explicitly supplies a null JP seed; `default_area1_active_preapply_has_no_jp_inbound_final_lineage` requires the supplied preapply seed to decode from the same nonempty run-start memory and covers arbitrary finite modeled query/clear/skip chronology. | Derive the preapply events, collision sample, loaded owner, and endpoint from the linked run; proving a castle prefix reaches the boundary is separately optional. |

Thus seed agreement removes one general-entry case from the abstract interface,
reducing that interface to four; the live run-to-projection bridge is still
open.  The first and fourth lose one possible explanation—an
undiscovered direct named internal writer—but still have alias, external,
control-flow, and live-receiver obligations.  A post-boundary query may still
install a pointer, so null entry does not settle the counterexample search.

## Next decisive linked work

The shortest route to a decision is:

1. execute the complete `update_mario_platform` call from the real
   `update_objects` schedule and prove the branch that reaches the checked
   store;
2. execute `find_floor` over live static and dynamic surface lists and identify
   the returned `Surface.object` block, offset, behavior, collision mesh, and
   allocation epoch;
3. prove a writable-memory frame for `gMarioPlatform` across every intervening
   internal and external step, including skipped queries and the delayed warp;
4. prove the current collision sample at each relevant store/apply boundary;
   and
5. either map the resulting state into the canonical stock relation or record
   the exact failing lineage case as a candidate installer.

Only after those steps can the four-case null-seed interface be inhabited or
refuted from scoped linked execution.  The optional castle-to-SSL Area 1 route
is an independent reachability investigation.
