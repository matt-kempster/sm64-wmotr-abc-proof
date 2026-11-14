# Live large-box floor, conditional clone and retained geometry

14 November2026. A clone can temporarily coexist with its old floor. A native
conditional fake pickup retains the live box's12 collision triangles during
the grab update; the next ordinary update removes them. Supplied time stop
preserves the already loaded triangles for longer, including through a native
throw that moves the actor high. Those triangles stay at their old coordinates.
These observations rule out an unconditional claim that a cloned box can never
have a floor, but do not demonstrate transporting a floor with the clone.

The bounded JP Wafel menu reproduces133 update boundaries exactly from two
independent fresh roots. It uses no new ROM replay and proves no theorem.
Source-derived and formal results are reported separately. Every cut is in
`instrumentation/ink-box-floor-lifecycle/results.json.gz`; no surface, floor
pointer/cache, interaction type, scale, velocity of the box or object-pool
allocator field is supplied.

## High live mesh and stopped-script controls

From the accepted four-pillar prefix, wait normally until the stored top timer
is129. Supply large box13 at(-1849,24800,-939), Mario M=C=G at
(-1849,25080,-939), FREEFALL/state0/timer0/velocity0/forward0/face0. A neutral
update loads the native12-triangle mesh, and Mario's floor query returns its
top25000, owner13. These are supplied diagnostic positions, not a history
delivering either actor high.

Then move the box's raw XYZ to(-1449,24900,-939), and supply Mario at
(-1449,25180,-939) for the next query. The following table records three
updates per control. Query branches restore each case's saved endpoint and
place Mario separately above the old and new footprints.

| Control | Loaded box geometry | Actual floor/cache observation |
| --- | --- | --- |
| Live box, ordinary renderer | Every vertex translates by(400,100,0);12 triangles reload | New top25100, owner13. |
| Live box, supplied nonnull `gfx.throwMatrix` pointing to its own transform | First update reloads the old cached transform; renderer resets the pointer; second update rebuilds the moved mesh | First new-location cache1194, static owner; second and third25100, owner13. |
| Supplied carry3 script/parent/stack reset, ordinary updates | First following clear removes all12; no reload | New-location static floor1194. |
| Same stopped script plus supplied `gTimeStopState=66` | Exactly the old12 triangles and partition links persist | Old-location floor25000 owner13; new-location floor1194, static owner. Clearing time stop removes all12 next update. |
| Carry3 and time stop before loading the high mesh | No box mesh is created | Zero box surfaces for all three checked updates. |

The cached-transform control is deliberately additional instrumentation. It
does not claim that ordinary gameplay preserves that nonnull pointer across
normal rendering. The loader always uses the object's own transform matrix;
the pointer's nonnull state controls whether that matrix is rebuilt first.
The end-of-update snapshots otherwise show the normal renderer clearing it.

## Native conditional pickup and release

Start from the same prefix/phase. Supply Mario in IDLE at(5900,51,3380),60
units behind native small box23, and the live large box13 at(6100,51,3380).
Press B on the first update, then neutral. After update4, Mario is naturally
PICKING_UP, `usedObj=23`, `heldObj=NULL`. Supply only `usedObj=13` at this
boundary. At update6 the game's actual grab assigns `heldObj=13` and installs
carry3; all12 already loaded box triangles still exist. At update7 there are
zero, and they remain absent through native HOLD_IDLE at update17.

The retarget is a granted fake-object predecessor, not a reproduced slot-reuse
or controller-reachable clone. No pickup action, animation endpoint, heldObj,
carry-script pointer or surface is directly supplied for this native chain.
Two independent24-update continuations use Z to drop or B to throw. Both
execute native release and change raw box position; neither reloads its mesh.
The box remains at carry4 or carry5's stopped command thereafter.

Restore the just-grabbed update6 boundary instead. Supply time-stop flags66
(ENABLED2 plus ACTIVE64, without freezing Mario), then12 neutral updates.
The clone reaches HOLD_IDLE and all12 old triangles remain. B starts native
THROWING. Immediately before its seventh update, supply high HOLP
(-1849,24800,-971). The real throw puts the actor at(-1849,24800,-939),
installs carry5 and clears heldObj. This supplies HOLP rather than reaching it.
The24-update throw continuation keeps exactly the original low triangles and
partition links; the box's raw high location does not move its old floor.

Independent actual-Mario query continuations demonstrate the difference:

- Above old footprint(6100,331,3380), the returned floor is251, owner13.
- Above high actor(-1849,25080,-939), the returned floor is1840.88232421875,
  owner61: an already loaded top surface retained by time stop, not box13.
- Returning `gTimeStopState` to0 clears the box's mesh on the next update.

The probes are complete native updates after supplied Mario pose/action cuts.
The observation is the resulting real floor cache and owner, backed by the
surface-pool and spatial-list records. They are not arbitrary isolated
`find_floor` calls or evidence of a reachable time-stop/throw history.
No useful Ink handoff is tested or claimed by these lifecycle experiments.

## Provenance and limits

Proof start`97d870c2d208f8adeb5bae88993d84ee4a9f9f6a`; decompile checkout
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`; stock source pin
`9921382a68bb0c865e5e45eb594d9c64db59b1af`. Runtime JP Wafel0.8.5,
Python3.9.13; DLL SHA256
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
The pinned prefix comes from `ink-high-item-nudge/prefix.jsonl.gz`, with
uncompressed SHA256`9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72`.
All pads have A released. No emulator/runtime binary or ROM is distributed.

These are finite supplied-state results, not a global impossibility theorem.
They leave fake-object acquisition, time-stop reachability with usable Mario
control, live high-mesh delivery, other object substitutions and any valid
script-restoration history open. Ordinary raw-XYZ cloning alone does not
supply the live high floor used by the existing Ink predecessor. M/C/G means
movement, raw collision and Stored Graphics; G is not a render-matrix pose.
