# Can a cloned live box keep its floor?

14 November 2026. **Yes, temporarily at the old location; the tested clone
does not carry that floor to its new location.** An actual fake-pickup call,
reached after one disclosed pickup-target edit, leaves the box's already
loaded triangles intact for the rest of that update. The next ordinary
collision clear removes them from fresh collision queries; old pool bytes may
remain or be reused. Supplied time stop preserves them longer,
even through a native throw to high HOLP, but fresh floor queries still find
the box floor at the old location. This is not a delivered high support or a
complete no-new-A Ink route.

This corrects the overly broad interpretation that a stopped clone can
*never* have a floor. The earlier frozen-box negative control remains valid:
it stopped the script before the high mesh was loaded. No successful live-box
handoff replay is withdrawn.

## What the floor actually is

Think of the live box as submitting a new collision drawing each update.
Its asset contains eight local vertices and twelve triangles: two top floors,
two bottom ceilings and eight walls. The asset's local top is Y=200. In these
integer-position controls, unit scale, zero rotation and a refreshed,
non-wrapping transform give floor Y = raw actor Y + 200. The small grabbable box is a
different object and does not submit this mesh.

The loader transforms the asset into **copied world-space triangles** in
shared dynamic-surface pools, computes their planes and inserts their nodes
into spatial query lists. The owner pointer records which object submitted
them; it does not make the vertices follow that object's later movement.
Transformed vertices pass through signed-16 terrain coordinates, so VPU
actor Y is not automatically the resulting floor Y.

The native large box loads only while time stop is inactive, Mario is within
its strict 500-unit collision distance and it is not in a different room.
Its collision transform is rebuilt from raw XYZ and face angles when
`gfx.throwMatrix` is null. Otherwise the loader reuses the cached object
transform; it does not use the matrix pointed to by `throwMatrix`.
Normal same-area rendering clears that gate for the following update.

Fake pickup changes this non-HOLDABLE object's command to carry script 3;
drop and throw select scripts 4 and 5. All three stop at BREAK, without a
collision-loader callback. They keep the asset pointer but do not regenerate
the world mesh. Held-object drawing and HOLP are separate from collision
loading. The large box's own behavior has no ordinary carried/thrown
transport logic. See the [source audit](ink-box-floor-source.md) for exact
guards, object ordering, room/render limits and source links.

## What we tested

These JP Wafel experiments reproduce **133 update boundaries** from two
independent fresh roots. The complete setup edits, inputs, surface vertices,
owner pointers, spatial-list links and native floor-query results are in
[`ink-box-floor-lifecycle`](../../instrumentation/ink-box-floor-lifecycle/README.md).
M/C/G mean movement, raw collision and Stored Graphics; G is not the pose
visibly drawn on screen.

| Experiment | Floor result | Evidence and grants |
| --- | --- | --- |
| Live box at (-1849,24800,-939), then moved by (400,100,0) | Twelve triangles reload at the new position; the top changes from 25000 to 25100. | Supplied actor/Mario poses; real loader and subsequent Mario queries. |
| Same move with explicitly retained transform gate | First load uses old geometry; after rendering clears the gate, the next update loads the moved geometry. | Additional supplied `throwMatrix` pointer; diagnostic, not a gameplay predecessor. |
| High loaded box changed to carry 3 | Next ordinary update has zero box triangles. | Supplied command, parent and stack reset. |
| Same loaded high box, carry 3, time stop 66 | Twelve triangles remain at the old location even after raw XYZ moves; the old query returns its top, the new query does not. | Explicit time-stop and stopped-script grants. |
| Carry 3 and time stop before high loading | No high mesh appears. | Time stop preserves old geometry; it does not create missing geometry. |
| Native low fake pickup after one `usedObj` retarget | Grab update 6 retains twelve triangles; ordinary update 7 has zero. | B starts a real small-box pickup, then `usedObj` is retargeted to the large box. Mario and large-box starting poses are supplied. |
| Native drop or throw after normal clearing | Raw actor moves; its floor does not reappear. | No surface/mesh writes; same conditional pickup predecessor. |
| Native fake pickup, supplied time stop, then native high-HOLP throw | Actor reaches (-1849,24800,-939), but old low floor remains at Y=251. New-footprint query finds a different owner, not this box. | Time stop 66 and HOLP (-1849,24800,-971) are supplied. No floor or platform pointer is supplied. |

The last experiment is the most useful negative for the proposed delivery:
Mario's actual throw moves the object high, but a query over (6100,3380)
still finds its old Y=251 floor, whereas a query over the high actor finds
the retained spinning-top surface at Y=1840.88232421875, owner 61. The box is
owner 13. Resuming normal time removes all twelve box triangles on the next
update. That floor-owner check prevents mistaking some other floor or an old
cached pointer for the transported box's floor.

All experimental pads have A released. Nevertheless, these are supplied-state
tests: they do not establish actual fake-object acquisition, high HOLP,
usable time stop, or high Mario arrival. See the
[runtime report](ink-box-floor-runtime.md) for update counts and every grant.

## Original Japanese ROM check

The selected native-pickup/time-stop/high-throw sequence also succeeds on the
original JP ROM in the precise retention sense above. Grab update 6 keeps
twelve linked low triangles. Native throw update 25 moves the actor to
Y=24800 while preserving those triangles. Separate old/high footprint probes
return Y=251 owner 13 and Y=1840.88232421875 owner 61 respectively. Update 45,
after time stop is cleared, has no box mesh in the dynamic query lists.

This replay uses **66 disclosed scalar writes**, including two supplied Mario
query poses, and A-off inputs. It does not reproduce real clone acquisition
or high HOLP. Across 42 comparable boundaries, the selected movement,
collision, Stored Graphics, action, cache/platform, raw box, mesh and link
fields match Wafel. The strict raw comparison retains **147 differences**:
42 global-timer offsets of -2, 42 interaction-subtype differences (2 versus
0), 57 HOLP components observed at different render phases, and six
pre-render nonnull versus post-render null transform-gate pointers. These
are not silently discarded or claimed as full-state equality. See the
[ROM report](ink-box-floor-rom.md) for the raw comparison, phase checks,
exact writes, ROM hash and rerun commands.

## Formal result and its boundary

The new `proofs/InkBoxFloor.v` and `proofs/InkBoxFloorFrame.v` are registered in
`_CoqProject` and connected to `MainTheorem.current_ink_box_floor_boundary`.
Their positive result is deliberately local: the actual BREAK call executes
without changing memory, and the actual post-address-translation script
replacement can execute while preserving already loaded disjoint cells.
This includes a constructive theorem preserving a specified existing load,
with explicit writable-destination and nonoverlap premises. Script words and
the large-box loader reference are checked against generated JP data.

A separate whole-helper theorem says that **completed** `obj_set_held_state`
calls with the stated pointer arguments preserve cells in other allocation
blocks. It does not prove that native segmented-address translation has a
completed execution in this memory model. The constructive existence result
is the narrower suffix, not the complete pickup. The boundary also reuses
the existing actual clear-body theorem for active time stop. See the
[proof report](ink-box-floor-proof.md) for every named theorem, premise,
remaining obligation and the selected audit receipt.

Both modules and Main compile. The selected discipline audit passes all four
assumption checks, proof-hole/link checks and integration checks. It reports
seven allowed foundations for each new boundary and nine for the unchanged
backward-execution boundary; no new axiom or `Admitted` was introduced.

These are not proofs of an entire behavior-interpreter/scheduler run, an
actual reachable pickup target, or a full floor-query predicate. In
particular, the proof does not assume high-floor reachability and then
announce it as established. The runtime experiments separately demonstrate
temporary linked geometry and its failure to follow the high actor.

## What remains open, and the next useful test

Three separate requirements remain: acquire a real fake-pickup target;
deliver or create a **live, loaded** high floor; and join that floor with the
air-step landing and later nudge at the useful top phase. Neither ordinary
clone/HOLP transport nor time stop alone supplies the second requirement.
The stock SSL large boxes begin at low Y=51 and have no ordinary movement
handler. The source review found no high child-spawner for this behavior and
no normal carry-script return to its loader; those searches are not a proof
covering all object-slot histories, substitutions or script-restoration paths.

The next discriminating experiment would require a concrete gameplay
mechanism that restores the native loader after relocation, or loads a
suitable high solid through a different actor. First check whether that
mechanism really executes a loader at the new transform and yields a fresh
floor owned by that actor. Repeating a high-HOLP throw of an unchanged stopped
carry script does not address the failing condition.

The clean route remains open. All 45 subjective atlas estimates remain
unchanged, including Rank 1 **1–2%** and Ink Rank 2 **<1%**. These are judgments,
not measured probabilities.

## Revisions

The fetched proof branch began at
`97d870c2d208f8adeb5bae88993d84ee4a9f9f6a`. The decompile checkout is
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`, checked against stock source
`9921382a68bb0c865e5e45eb594d9c64db59b1af` with JP selected. Runtime is
Wafel 0.8.5; Coq uses the existing `sm64-item-proof` pipeline with Coq 8.16.1
and CompCert 3.15. Exact runtime and prefix hashes are in the finite-test
receipt. No ROM or emulator binary is redistributed.
