# Rank 12B: contact across pyramid barriers

## Result

Rank 12B remains open, but it now has concrete exclusions and a better contact
target. With the normal object sizes and target positions, Mario cannot touch
any of the five secrets or either settled target star while his X/Z stays
inside the stock elevator footprint or second-pole opening, **at any height**.
The binary32 proof covers all fractional X/Z values in those rectangles, not
just a grid of samples. A separate whole-mesh census narrows standing-floor
candidates. In particular, the highest secret has only its own platform;
the Act-3 star has six sloped-rim faces and a positive contact sample.

That sample is **not a clean route**. No new controller input sequence, live
contact event, target-star spawn, or save-bit transition was established in
this tranche. Ordinary glitches remain in scope. No arbitrary game-memory
changes, out-of-bounds behavior, or code execution are used or developed.

## What the game tests

The pinned `detect_object_hitbox_overlap` compares the raw Objects' horizontal
distance against the sum of their radii. It then checks vertical overlap and
the two four-entry collision lists. It has no wall/ceiling visibility query;
its sole direct callee is `sqrtf`. Horizontal equality at the radius is a miss;
vertical equality is accepted. The surrounding list pass, tangibility,
interaction handler, and secret controller must still execute normally.

The checked source descriptors give Mario radius 37 and standing height 160,
stars radius 80 and height 50, and secrets radius 100 and height 100. Thus the
combined radii are 117 for stars and 137 for secrets. This audit uses zero
down offsets and the usual target positions. Descriptor receipts establish
initialized source bytes, not every later object's live fields.

Evidence comes from the pinned revision
`9921382a68bb0c865e5e45eb594d9c64db59b1af`, including
`src/game/object_collision.c`, `src/game/behaviors/hidden_star.inc.c`,
`src/game/behaviors/spawn_star.inc.c`, `data/behavior_data.c`,
`levels/ssl/script.c`, and Area 2's macro/collision initializers. The Coq
proof reads the corresponding generated US/JP definitions.

## Direct contact from inside either gate

The two generous horizontal rectangles are:

| Location | X interval | Z interval |
|---|---:|---:|
| Stock elevator cage, at horizontal origin `(0,256)` | `[-460,461]` | `[-204,717]` |
| Second-pole aperture | `[-101,102]` | `[1229,1434]` |

These are the existing [elevator](area2-elevator-cut.md) and
[pole-opening](area2-lower-target-cut.md) geometry bounds. They are not a
claim that every pre-gate Mario position belongs to these two rectangles.
A moved/rotated cage or a changed target position needs different premises.

For every target and rectangle, at least one axis is separated by at least
256 units. The proof follows binary32 subtraction, squaring, addition,
square root, and comparison: the computed distance remains at least 256,
larger than either contact radius. The numerical bound is deliberately loose;
for example the nearest elevator-footprint point to the Act-3 star is about
298.56 units away. No change to Y alone can fix this horizontal miss.

`rank12b_gate_rejection_executes_in_selected_clight` executes the **actual
generated post-distance tail** in both selected programs. Given the checked
radius and distance in its temporary values, it returns zero with identical
memory: no contact is registered. The selected generated configurations
explicitly return zero on this branch. This is not yet execution of the
preceding raw-object reads or a specification of `sqrtf`; those still need
their actual memory values and an exact reached-call result/effect.

## Whole static-mesh census

Both generated versions contain the same 1,080 vertices and 1,558 triangles.
The parser follows every surface group, including the force-bearing record
widths, and checks that every triangle's vertex indices resolve. The filter
includes **every face with a positive upward cross product**, even faces too
steep to be ordinary walking floors.

The broad phase encloses each contact cylinder in a box and expands it by one
unit in all directions. It retains any upward face whose vertex bounds meet
that box. These are conservative candidates, not successful contacts:

| Target | Target centre | Mario's nominal contact-Y interval | Remaining source triangle ordinals |
|---|---|---|---|
| Act-3 star | `(500,5050,-500)` | `[4890,5100]` | `1092–1097` |
| Settled Act-6 star | `(900,1400,2350)` | `[1240,1450]` | none |
| Lower-west secret | `(-260,2940,-600)` | `[2780,3040]` | `647,659` |
| Lower-east secret | `(260,1967,-600)` | `[1807,2067]` | `636,640` |
| Middle-west secret | `(-1940,1229,-600)` | `[1069,1329]` | `1377,1378,1379` |
| Middle-north secret | `(-1940,1229,2320)` | `[1069,1329]` | `1375,1377,1378` |
| Highest secret | `(260,3913,-600)` | `[3753,4013]` | `668,669` |

`rank12b_no_omitted_geometric_floor` proves that any point shared by a
source face's vertex box and the padded contact box has a listed ordinal.
This is a geometric completeness result for the stated boxes. It is **not**
yet a proof that every rounded live `find_floor` result, raw Object position,
or successful overlap projects into those boxes. The one-unit padding is a
conservative diagnostic choice, not a proved universal collision-error bound.
Transformed moving floors, stale retained floors, airborne positions, and
same-frame position differences are not silently classified as static
standing points.

## Act 3: the flat-floor miss is not a neighborhood-wide height bound

Triangle 1093 is the very-slippery rim with vertices
`(387,4927,-716)`, `(387,4927,-409)`, `(427,4887,-450)`.
The point `(400,4914,-500)` lies within its projected triangle and on its plane
`X + Y = 5314`. The standard binary32 hitbox test accepts this point against
the Act-3 star: the horizontal distance is 100 and Mario's top is 5074.

This establishes an actual source-mesh/contact candidate absent from the old
flat-floor sample. That older `(500,4815,-500)` sample still misses by 75.
It does not follow that Mario can reach or remain at the rim point: live wall
responses, slippery motion, floor selection, collision ordering, and the
ordinary controller predecessor are unproved. It is also outside the
elevator footprint, so it does not evade the direct-contact exclusion above.

## Highest secret: the underside is a real obstacle

The secret's platform top is Y=3913. Its two underside faces, ordinals 664
and 665, are at Y=3785: the solid platform is 128 units thick. At the secret's
X/Z, an isolated standard-hitbox sample at Y=3753 touches the secret; one at
3752 misses. But the successful sample's head extends through that underside.
With 160-unit clearance, the underside instead limits Mario to Y=3625.

`rank12b_ceiling_respecting_underpass_cannot_touch_secret` proves the
stronger conditional fact: **any finite raw hitbox top at or below 3785**
misses this secret, regardless of X/Z. Applying it to live play requires
showing the relevant ceiling is actually selected and its clearance survives
through object contact. It does not exclude a side/edge approach, an airborne
approach already above the underside, or a legitimate collision-phase glitch
that breaks that premise.

## Remaining work and counterexample promise

The promise stays **low**, but is no longer an unexamined geometry question.
Do not search for height-only contact while Mario remains inside either
unchanged gate footprint. For Act 6, the useful next target is a clean
airborne/edge contact with the highest secret, including its side walls and
128-unit-thick platform. Its own two top triangles are the only static
standing candidates in the census. The lower four contacts and the genuine
five-secret accounting remain necessary, including any legitimate area
revisits. Contact with a supplied Puzzle star is not its installer.

For Act 3, test whether an ordinary no-A path reaches the checked rim contact
or another airborne contact without first performing an already-classified
gate crossing. Any survivor must connect the accepted Area-1 start, every
wall/floor/ceiling choice, action and moving-support effect, the correct
collision phase, and target collection/save. A negative result must cover
those alternatives; it may not simply assume that all contacts cross a gate.

## Proof and reproduction

- [Area2Rank12BContact.v](../../proofs/Area2Rank12BContact.v) contains the
  binary32 exclusion, generated-body resolution, real Clight rejection tail,
  whole-mesh census, rim witness, and underside-clearance theorem.
- [MainTheorem.v](../../proofs/MainTheorem.v) consumes the results through
  `current_rank12b_cross_barrier_contact_boundary`. The global impossibility
  theorem remains conditional on the existing linked-execution obligations.
- [Offline checker](../../instrumentation/rank12b-contact/check.js): run
  `node instrumentation/rank12b-contact/check.js`; add `--verbose` for source
  vertices and nearby solid faces. It only reads source and computes values.
- Run the focused Coq/assumption checks with `make check-rank12b` through the
  repository's bounded build wrapper and active `sm64-item-proof` switch.

The initial root discipline audit passed its no-hole, axiom-footprint, and
firewall/unwired checks, but its legacy build target still names the absent
`sm64-proof` switch. Active SSL checks use Coq 8.16.1 and CompCert 3.15 under
`sm64-item-proof`; the legacy build failure must not be reported as green.

Validation completed on 2026-09-05: the leaf compiled with a 4 GiB cap; the
integrated `MainTheorem.v` build passed with the repository's standard 6.5 GiB
cap; the active no-hole and link-hygiene checks passed; and all sixteen named
assumption audits in `check-rank12b` passed. The audits were completed in
shorter runs after intermittent WSL service failures interrupted the combined
command. They introduce no project-local axioms; the documented conditional
execution premises and standard Coq/CompCert foundations remain. The offline
checker, all 45 atlas anchors, backlinks, and the three single-paragraph
Rank-12B sections were also checked.
