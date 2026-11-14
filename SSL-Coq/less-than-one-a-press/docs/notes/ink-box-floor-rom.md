# Original Japanese ROM: a clone can retain an old floor during time stop

14 November 2026. The original JP ROM reproduces the useful distinction from
the Wafel study: **cloning can coexist with the already loaded floor, but
moving the clone does not move that floor.** A conditional native fake pickup
leaves the large box's 12 triangles in the current collision partition. Supplied
time stop preserves those triangles while a native throw moves the actor to
Y = 24800. A later native floor lookup still finds the box at its original low
coordinates. Resuming ordinary updates removes that floor. This supplies no
new route to the high Ink setup.

## Exact experiment and grants

Package: `instrumentation/jp-ink-box-floor-lifecycle`; checked-in record:
`records/native-clone-stopped-old-floor`. The original mode 12 no-A controller
prefix reaches the four-pillar sequence. The suffix begins when the top has
action 1 and stored timer 129. The standard startup level-select cheat remains
enabled. All later edits are the following 66 scalar writes:

| Before suffix update | Supplied writes | Purpose |
|---|---|---|
| 1 | 19 Mario fields: M/C/G=`(5900,51,3380)`, IDLE, zero velocity/forward speed/angles/action state/timer; 3 large-box raw XYZ fields=`(6100,51,3380)` | Prepare a native small-box pickup beside a live large box |
| 5 |`usedObj` points to large-box slot 13 instead of small-box slot 23 | Conditional fake-pickup prerequisite; not obtained through gameplay |
| 7 |`gTimeStopState=66` | Retain already populated collision geometry while Mario continues updating |
| 25 | HOLP=`(-1849,24800,-971)` | Native throw places the clone at `(-1849,24800,-939)` |
| 43 | 19 Mario pose/action fields: FREEFALL at `(6100,331,3380)` | Fresh native lookup above the old low box footprint |
| 44 | 19 Mario pose/action fields: FREEFALL at `(-1849,25080,-939)` | Fresh native lookup at the high actor footprint |
| 45 |`gTimeStopState=0` | Resume ordinary clearing and object execution |

Suffix inputs are B on updates 1 and 19, neutral otherwise. Mario enters
PICKING_UP through ordinary small-box contact. On update 6 the game's native
grab sets the held reference, parent and carry script. The harness never
writes those fields. The target has no `OBJ_FLAG_HOLDABLE`; its `oHeldState`
stays 0, which is consistent with the non-holdable fake-pickup mechanism.
These cuts isolate what the native setter/throw and collision system do;
they are not an allowed controller history to acquire or deliver the box.

No collision triangle, partition link, cached floor, platform, hitbox,
interaction subtype/type, behavior script or scale is supplied. The actor
is the existing live large breakable-box slot 13, not a new object allocation.
The low original box has raw XYZ `(6100,51,3380)` and a top surface at Y = 251.

## Observed update boundaries

| Completed update | Mario / box event | Collision observation |
|---|---|---|
| 4 | PICKING_UP; used=23, held=null | 12 native large-box triangles |
| 6 | Native fake pickup; held=13; carry3 starts | 12 triangles still loaded and linked in this update |
| 7–18 | Supplied time stop; Mario reaches HOLD_IDLE | The same 12 triangle records and 20 partition links survive |
| 19–24 |Native THROWING begins; actor still low |Old box geometry remains unchanged |
| 25 | Native throw uses supplied HOLP; actor becomes `(-1849,24800,-939)`; held=null; carry5 starts | Vertices remain in the old low footprint, with Y = 51 or 251 |
| 26–42 |Neutral continuation under time stop |The same old geometry and links remain |
| 43 | Native floor query above old footprint | `floorHeight=251`, owner slot 13 |
| 44 | Native floor query at high actor footprint | `floorHeight=1840.88232421875`, owner slot 61, the retained pyramid top; not the box |
| 45–48 |Ordinary execution resumes; carry5 reaches BREAK |Zero large-box triangles or links remain |

The source carry scripts are BEGIN/BREAK records. Native observed pointers
are carry3 `0x800eb764`, carry5 `0x800eb774`, and carry5's BREAK `0x800eb778`.
The unchanged original behavior pointer is `0x800e9800`; collision data is
`0x80168930`. These addresses are observations in this original ROM. The
current locally linked decompile orders the carry arrays differently, so its
map's pointer differences must not be treated as original-ROM addresses.

The post-grab same-update observation verifies surviving linked geometry;
it is not an additional floor query performed after pickup in update 6.
Updates 43 and 44 do perform fresh native floor lookups after the clone has
been thrown. They query while falling above the surfaces, not after landing.

## Agreement, differences and reproducibility

The checker compares 42 main update boundaries with the frozen Wafel record.
Mario M/C/G, action/state/timer, floor height and owner, platform, held/used
references, actor raw XYZ/flags/action/timer/parent, stored transform,
allocation counters, every box triangle and every partition link agree.
Float fields are compared as Float32 bits. The six later diagnostic and
resume boundaries have direct native assertions rather than a full Wafel
state comparison; the Wafel queries were independent save-state branches,
whereas this native replay executes both probes sequentially.

**Strict full-field agreement is false.** The receipt preserves 147 mismatches:

- 42 global timers are two lower in the original-ROM run.
- 42 interaction subtypes are 2 on original JP and 0 in Wafel.
- 57 HOLP components differ across updates 6–24: the native camera breakpoint
  precedes held-object render traversal, while Wafel's snapshot follows it.
  For updates 7–24, native HOLP exactly matches the preceding Wafel boundary.
- 6 throwMatrix observations are nonnull on the live-box updates 1–6 at the
  native pre-render breakpoint; Wafel reads null after render cleanup.

No mismatch is silently normalized. The high HOLP cut itself and resulting
native thrown raw XYZ match. Mesh ownership, exact vertices, partition links,
old-site floor and resumed clearing establish the conditional conclusion
independently of those differences.

The final checker passes 48 observed boundaries, 66 writes, 42 comparison
boundaries, zero A-down/A-pressed/controller-A frames, and every stated mesh
assertion. An initial probe build failed because a helper constant was gated
out in mode 12; it was replaced with the unchanged pool bound 7000. The first
checker run exposed the mistaken assumption that original-ROM carry arrays
followed the local linker map's reversed order. The trace showed the actual
addresses above; the checker was corrected and the existing recorded run
passed. No game code or recorded trace was changed to resolve either issue.

ROM: SHA256 `9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317`,
MD5 `85d61f5525af708c9f1e84dce6dc10e9`. Mupen64Plus console/core 2.5.9,
interpreter mode 0, Rice 2.5.9, HLE RSP 2.5.9, dummy audio, Ubuntu-24.04 WSL.
Proof checkout at start: `97d870c2d208f8adeb5bae88993d84ee4a9f9f6a`.
Decompile checkout: `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`;
stock source pin: `9921382a68bb0c865e5e45eb594d9c64db59b1af`.
Wafel expected artifact SHA256:
`29ebd367c33d365fcb4c923c152dbd8936ba0033929c7609ec6810de7c1fddc3`.

Re-run and archive commands are in the package README. The record preserves
the complete raw log, selected trace, every write/input, checker receipt,
source snapshots and hashes. No ROM, compiled plugin or media is published.
The Coq scope and overall assessment remain in `ink-box-floor-cloning.md`;
this replay is conditional evidence for retained old geometry, not a proof of
reachability or an Ink handoff with a transported high floor.
