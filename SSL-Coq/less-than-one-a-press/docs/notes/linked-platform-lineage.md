# Linked platform-lineage boundary

## Verdict

The new linked-Clight tranche closes a source-to-official-program syntax gap
and proves the individual platform-global store/load steps in CompCert's
Clight semantics. It does **not** eliminate any of the five remaining
clean-retail lineage cases by itself.

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

The file also packages the five semantic facts that would close the remaining
lineage split in `FiveLinkedLineageClosures`. The implication

```text
FiveLinkedLineageClosures -> False
```

checks that the interface is sufficient. None of the record's five fields is
constructed from a clean linked execution.

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
the supplied owner pointer. It does not prove that the generated source fragment is the body
resolved by the official global environment, or execute the preceding floor
query or branch.

## Status of the five lineage cases

| Lineage case | New checked evidence | Remaining retail obligation |
| --- | --- | --- |
| Different query and current collision samples | The official-slice direct-writer/address/caller upper bounds exclude an extra recognized named platform-cell writer. | Execute the complete upper-warp frame and prove which intervening writers, callbacks, or external effects can change the collision sample after the query/store. |
| Canonical owner outside modeled geometry | No new live-geometry exclusion. | Execute `find_floor` and the dynamic surface-list traversal; connect the returned `Surface.object`, transformed geometry, and query coordinates to the canonical finite owner model. |
| Recognized owner with noncanonical slot or allocation epoch | The exact stored pointer is exactly what an immediately following same-cell load returns. | Resolve the official blocks; prove that the owner pointer is an in-bounds `gObjectPool` slot; bind its block/offset and ghost allocation epoch; and exclude stale or reused identities where required. |
| Unclassified dynamic owner | The official direct named writer census is closed. | Prove exhaustive live behavior/collision-owner provenance, including clones, relocated collision, aliased stores, runtime spawns, and external effects. |
| Retained JP inbound lineage transported to the upper warp | The JP store/load result shows that a previously stored owner is loaded into the apply function's local `platform` temporary if the platform cell is preserved. | Establish or exclude the clean inbound store, prove the complete preservation interval and position chronology, execute the later guard/displacement path, and connect any survivor to the true first destination-area displacement. |

Thus none of the five cases is marked eliminated. The first and fourth lose one
possible explanation—an undiscovered direct named internal writer—but still
have alias, external, control-flow, and live-receiver obligations. The fifth
case is especially asymmetric: the new dataflow result supports the
conditional stale-pointer route once a pointer exists; it does not prove that
clean Area-1 play creates that pointer or transports it to the needed sample.

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

Only after those steps can the five-case conditional interface be inhabited
or refuted from clean linked execution.
