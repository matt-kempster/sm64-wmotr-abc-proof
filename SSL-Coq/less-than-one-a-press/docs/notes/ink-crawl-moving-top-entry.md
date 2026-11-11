# Can the spinning top sweep over an established crawler?

Follow-up: the [direct edge and upper-face tests](ink-crawl-edge-entry.md)
now start beside/on the actual moving top with explicitly supplied poses.
They reproduce deep entry while airborne, including after a crawler loses
support, but do not preserve crawl through that entry. Those direct tests
supersede the remote approach trials as evidence about the local sweep.

The existing evidence and this new bounded study provide no controller-only
entry into the high crawling state used by the Crazy Box handoff. The simple
roof-sweep proposal has a geometric obstacle. The static roof under the
moving cap stays below its underside, so a crawler standing on that roof
does not acquire feet inside the cap merely because its footprint crosses
him. A source-derived sample of supported top motion also retains the
upper face within the floor query's 78-unit allowance.

This is a local explanation and finite investigation. It leaves other
approaches, action changes, dynamic supports, unusual collisions and
controller histories open. The useful handoff state remains supplied.

## What counts as the required entry

The relevant position is Mario's movement position at his feet. At the
timer130 setup point `(-1950,1741,-939)`, the cap underside is Y1523 and its
upper face is about Y1914.34. The desired feet position is therefore about
173.34 units below that upper surface while still above the underside.
The previously established crawl action must survive into the gap-producing
update, whose initial floor query remembers the low pad at Y768.

A head or body overlapping the underside while feet remain on roof1280
does not meet this condition. A brief feet position a few units below a
moving upper face also leaves the top eligible as the current floor.

## Four-pillar geometry, observed without gameplay edits

The native JP runtime replays the accepted 2548-input four-pillar prefix,
then advances 153 neutral inputs. The read-only observer records 152
available top meshes, including the transition into the spin and the
last loaded mesh at the change to explosion. Every gameplay write goes
through a wrapper which permits only the three controller-pad fields.
The startup retains the accepted pre-entry debug level-select flag.

For each native mesh, the study projects the cap base into X/Z and clips
every loaded upward static triangle against that footprint. It evaluates
the maximum static supporting plane height at the resulting polygon
vertices. This is a double-precision geometric calculation from native
integer vertices and binary32 planes, with all inputs retained in the
receipt. It is independent of Mario's supplied-state handoff.

| Observation | Result |
| --- | --- |
| Largest static plane height within the observed cap footprints | About Y1280.000172 |
| Lowest cap underside in the sequence | Y1281 |
| Smallest underside-minus-static-support clearance | About 0.999956 units |
| Underside during behavior130 | Y1523 |
| Static support under that phase's footprint | At most about Y1280.000172 |

Thus the floor beneath a roof crawler stays below the cap. By behavior130
it is roughly243 units below the underside, and461 units below the
reference Mario feet height1741. Horizontal passage of the cap over that
floor does not supply the required altitude.

These calculations concern static terrain within the native footprints.
They do not exclude a crawler arriving from a different dynamic support,
an airborne/action transition, or a collision path outside this calculation.

## A crawler already supported on the top

The actual update order prepares the new dynamic collision surfaces, applies
the previous platform reference's displacement, detects object overlaps,
and then runs Mario's inputs/actions. The top moves horizontally by a
40-unit oscillation and eventually rises five units per update. Platform
displacement applies X/Z velocity and rotation. For this yaw-only cap it
does not directly add vertical velocity to Mario.

This can leave the old foot height below the new upper surface temporarily.
The floor query, however, accepts a floor up to78 units above the queried
integer Y. A modest surface rise can therefore keep the cap selected as
Mario's floor. That is the relevant difference from the supplied deep
interior setup, where the upper face is beyond the allowance.

The study samples153 barycentric points per native upper triangle for
successive poses. It applies the source-derived yaw formula using the
native sine-table values and binary32 arithmetic, then evaluates the next
native plane at integer X/Z. It retains83,667 old/new overlaps, with5,527
other valid old points leaving the new upper-face footprint. Among the
overlaps,41,514 have a positive rise and none exceeds78 units. The largest
observed rise is46.921875. At behavior130 the sampled maximum is45.627563.

This is a finite geometric sampler. It does not execute the native platform
function with a live Mario at every sampled point, and its algebraic
rotation can round differently from the game's matrix operations. It
supports the ordinary surface-following explanation without proving an
all-input bound or excluding edge/corner and off-support histories.
The next native floor lookup and action continuation still matter.

## New controller-only four-pillar attempts

All195 new policies begin after the actual fourth pillar, at completed
input2548. They vary an initial B timing, five approach offsets to the
existing western Crazy Box, and three pyramid targets. The stock box may
provide approach height. Actor preservation for a later shove is outside
this study's objective. After the bounce releases the box, the policies
attempt Z plus steering toward the selected roof target.

These trials have no Mario pose/action, actor, floor, surface, platform,
timer, RNG or allocator writes. Complete native states are restored only
at the controller-reached four-pillar checkpoint.

| Recorded result | Value |
| --- | --- |
| Policies and suffix updates | 195 policies,29,640 updates |
| Policies that acquire the stock box | 51 |
| Earliest observed pickup | After31 suffix inputs |
| Closest observed X/Z distance to pyramid center while the top spins | About3909.533 units |
| Crawling samples | 0 |
| Samples within1400 X/Z units of the pyramid center | 0 |
| Successful interior crawling entries | 0 |

The early pickup takes a poor transport heading in its selected continuation.
It is a quicker acquisition component, with no timely top approach.
All195 result records reproduce in an independent full run. Three selected
complete histories replay from fresh games and match459 stored boundaries.

The important coverage limitation is that these policies never bring a
crawler near the spinning cap. They cannot serve as a direct negative test
of the cap sweeping over an already-present crawler. The moving-cap
conclusions above come from source order and the native geometry study.

## Scope correction during the investigation

An initial360-policy continuation study used24 near-top checkpoints from
eight existing clean box/Fly-Guy approaches. These were three-pillar
approaches to a stationary cap. They produced no crawling samples and are
excluded from the moving-top evidence. The user's clarification redirected
the gameplay tests to the four-pillar checkpoint. The preliminary raw
report is hashed for transparency, and its negative results make no claim
about the spinning-top entry.

## Reproduce and verify

From `SSL-Coq/less-than-one-a-press`, use a fresh output filename with each
command.

```powershell
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_crawl_top_entry.py build/wafel-pilot/entry-geometry-NEW.json --mode geometry
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_crawl_top_entry.py build/wafel-pilot/entry-four-pillar-NEW.json --mode four-pillar
```

The [receipt](ink-crawl-moving-top-entry-receipt.json) retains native meshes,
static-footprint results, per-phase sampler maxima, all195 policy summaries,
selected full suffixes, fresh-replay counts and the pinned source/runtime/
capture hashes. The main [script](../../instrumentation/wafel-jp-pilot/ink_crawl_top_entry.py)
guards every post-startup write and every input against A.

The selected JP runtime hash is
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
The accepted capture hash is
`9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72`.
The two final raw reports are
`build/wafel-pilot/ink-crawl-top-entry-geometry-final.json` and
`build/wafel-pilot/ink-crawl-top-entry-four-pillar-final.json`.

Source anchors in the sibling decompilation are
`src/game/object_list_processor.c:639–671`,
`src/game/platform_displacement.c:91–160`,
`src/game/behaviors/pyramid_top.inc.c:32–64`,
`src/engine/surface_collision.c` (`find_floor_from_list`),
and `src/game/mario_step.c:258–346`.
The [earlier inverse-predecessor study](ink-crawl-predecessors.md#why-the-direct-inverse-is-not-an-ordinary-supported-predecessor)
and [timer130 geometry](ink-timer130-handoff.md#timer-130-geometry-with-the-rounding-kept)
supply additional context.

No new Coq theorem or authenticated original-ROM replay is added. The
gameplay runs use the pinned native JP test runtime after the accepted
level-select startup. A complete clean high-crawl entry and the no-A route
remain open.
