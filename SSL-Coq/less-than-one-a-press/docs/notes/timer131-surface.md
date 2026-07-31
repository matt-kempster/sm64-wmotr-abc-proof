# Timer-131 pyramid-top surface

## Result

The timer-131 value-level surface calculation is now closed for both selected
versions.  It also invalidates the old home-pose Graphics witness.

The relevant interpretation of `oTimer == 131` is the value seen inside
`bhv_pyramid_top_spinning`.  The behavior body changes position and yaw, calls
the collision loader later in the same behavior script, and only afterwards
does `cur_obj_update` increment `oTimer`.  Therefore the collision generated on
that update uses the pose after all 72 spinning-branch executions for timer
values 60 through 131 inclusive.

The exact result is:

| Quantity | Exact value |
|---|---:|
| top X | `-2087.0f` (`0xc5027000`) |
| top Y | `1783.071044921875f` (`0x44dee246`) |
| top Z | `-1023.0f` (`0xc47fc000`) |
| yaw angular velocity | `0x1800` |
| raw 32-bit face yaw | `0x5ac00` |
| yaw supplied to the matrix helper | `0xac00` |
| `sin(0xac00)` | `-0.881921291f` (`0xbf61c598`) |
| `cos(0xac00)` | `-0.471396744f` (`0xbef15aea`) |

This replaces the earlier zero-yaw home transform.  In particular, the apex is
now at approximately Y `2039.071`, not Y `1792`.

## Exact transformed collision mesh

`transform_object_vertices` evaluates its binary32 matrix expression and then
narrows each component to signed 16-bit `TerrainData`.  The checked fresh
timer-131 transform produces:

| source vertex | transformed binary32 coordinates | stored signed-16 coordinates |
|---|---|---|
| `(-511,-255,512)` | `(-2297.660…,1528.071…,-1715.017…)` | `(-2297,1528,-1715)` |
| `(512,-255,-511)` | `(-1877.693…,1528.071…,-330.572…)` | `(-1877,1528,-330)` |
| `(512,-255,512)` | `(-2779.899…,1528.071…,-812.811…)` | `(-2779,1528,-812)` |
| `(0,256,0)` | `(-2087,2039.071…,-1023)` | `(-2087,2039,-1023)` |
| `(-511,-255,-511)` | `(-1395.454…,1528.071…,-1232.778…)` | `(-1395,1528,-1232)` |

The Rocq proof uses CompCert binary32 multiplication/addition and
`Cop.sem_cast`, not mathematical real arithmetic.

## State query

The proposed first State query remains:

```text
(-2200, 768, -1024)
```

At timer 131 it is horizontally inside transformed face `(0,2,3)`.  Its three
signed-32 edge values are:

```text
420653, 24535, 77986
```

The face-plane evaluation returns approximately `1938.865f`.  The source test
rejects a floor when:

```text
queryY - (height - 78) < 0
```

That expression is negative here, so the spinning top cannot rescue the first
query.  `Area1FirstNull.v` independently enumerates all 26 static floor
candidates in the generated US and JP Area-1 collision streams and rejects
each of them.  `InkFallback.v` rejects every non-top member of its finite stock
dynamic-owner inventory at this coordinate.  Together these give a much
stronger finite State-miss boundary, but not yet a live Clight list traversal.

## The old Graphics witness is false at timer 131

The previous conditional witness reused the home-pose point:

```text
(-2048, 1791, -1024)
```

At timer 131 that point lies horizontally inside face `(1,4,3)`, but the face
height is `2005.12890625f` (`0x44faa420`).  Its buffer difference is
`-136.12890625f`, so `find_floor_from_list` rejects the face.  Consequently,
this point cannot be used as the non-null Graphics retry in the timed
Ink/pyramid-top construction.

This is a refutation of that concrete sample, not a refutation of every Ink
installer.

## Corrected robust Graphics witness

A replacement strictly inside the same face is:

```text
Graphics = (-1641, 1456, -783)
face     = (1,4,3)
```

Its checked values are:

| Check | Result |
|---|---:|
| signed edge 1 | `5474` |
| signed edge 2 | `259294` |
| signed edge 3 | `258678` |
| floor height | `1533.34375f` (`0x44bfab00`) |
| `queryY - (height - 78)` | `+0.65625f` (`0x3f280000`) |
| dynamic partition cell | X `6`, Z `7` |

All edge values are strictly positive, so this does not depend on boundary
tie-breaking.  The query is 77.34375 units below the surface, but that is
deliberately within the engine's 78-unit upward floor-search buffer.  A
successful retry would cache the top-owned face and the later disappeared
action could snap Mario to the returned height.

The timer-131 stored mesh has minimum vertex Y `1528`.  Any signed-range query
for a top floor at least that high must have Graphics Y at least
`1528 - 78 = 1450`.  A warp-overlapping Mario Object has Y at most `818`, so
the general Graphics-minus-Object gap is at least `632`.  The concrete strict
interior witness is at Y `1456`, making its bound at least `638` over any
warp-overlapping Object and exactly `688` at the warp centre Y `768`.

The Rocq theorems
`timer131_warp_retry_requires_at_least_632_graphics_y_gap` and
`timer131_concrete_retry_requires_at_least_638_graphics_y_gap` prove these
bounds.  `timer131_bounded_writer_cannot_install_retry` then proves that both
the dry source-audit target `45` and the conservative modeled writer envelope
`208` are arithmetically insufficient.  Applying those bounds to every retail
execution still depends on the open writer/action-closure refinement.

## Conditional authentic-JP execution

The hash-gated probe in `instrumentation/timer131-installer/` was run against
the authentic original Japanese ROM.  It waits for the live top to reach
action timer 131, then injects only:

```text
State    = (-2200, 768, -1024)
Object   = upper-warp centre
Graphics = (-1641, 1456, -783)
platform = NULL
```

On the next poll, the retail engine reported:

| Field | Observed value |
|---|---|
| top timer and pose bits | `132`, `(c5027000,44dee246,c47fc000)` |
| Mario State/Object/Graphics | `(-1641,1533.34375,-783)` |
| Mario State bits | `(c4cd2000,44bfab00,c443c000)` |
| floor | `8019bb10`, owner at `+0x2c` = top `803451f8` |
| action | `00001300` (`ACT_DISAPPEARED`) |
| action argument | `00040001` |
| `usedObj` | upper warp `80345918` |
| `gMarioPlatform` | top `803451f8` |
| A-edge/A-down/controller-A observations | `0 / 0 / 0` |

The `00040001` argument is the expected post-action value: `interact_warp`
sets `00040002`, and `act_disappeared` decrements it later in the same update.
The probe does not write `throwMatrix`, surfaces, partition lists,
`MarioState.floor`, action, action argument, or `usedObj`.  Thus this authentic
execution confirms that, *given the injected prestate*, retail JP performs the
real Graphics copy, top-owned floor retry, upper-warp interaction, floor snap,
and top capture in one frame.

The exact trace is retained as
`instrumentation/timer131-installer/expected-trace.txt`.  The Rocq record
`timer131_jp_probe_observation_record_checked` checks its copied bit patterns,
pointers, action state, and zero-A counters against the timer-131 arithmetic.
That theorem checks the observation record; it does not turn an emulator run
into a Clight small-step theorem.

Most importantly, this is not yet a gameplay route.  The probe injects the
three-view split.  A clean no-A execution must still be shown to create the
same prestate through ordinary gameplay or a glitch before this becomes a
counterexample to the target claim.

There is also a second, now-observed obstruction.  Composing this exact
side-face result with the later lifecycle shows that the capture is transient:
the moving face carries Mario through global timer 497, but at global timer
498/top timer 138 the final floor is the static Y=`1280` floor and
`gMarioPlatform` becomes null.  It remains null through the top's explosion,
the delayed warp, and the first Area-2 update.  Consequently, even a reachable
installer for these exact coordinates would **not** reproduce the stronger
post-owner fixture whose pointer survives to Area 2.  A successful route needs
an additional recapture/containment mechanism, a different accepted top point
whose support persists, or a different payload installer.

## Capture-preserving mid-face witness

A different point on the same timer-131 face removes that lifecycle
obstruction in the conditional JP execution:

```text
Graphics = (-1862, 1778, -902)
face     = (1,4,3)
```

Rocq computes the exact transformed-mesh results:

| Check | Result |
|---|---:|
| signed edge 1 | `262174` |
| signed edge 2 | `130757` |
| signed edge 3 | `130515` |
| face plane bits | `(3f1f868b,3f352a49,3eaa7da0,43463410)` |
| returned floor height | `0x44defe16` (`1783.940186f` when printed) |
| `queryY - (height - 78)` | `0x42901ea0` (`72.0598145f`) |
| dynamic partition cell | X `6`, Z `7` |

All three edge values are large and positive.  This is a strict interior
sample, not a boundary/tie-breaking artifact.  Its Graphics Y is `1778`, so
any warp-overlapping Object at Y at most `818` needs a gap of at least `960`;
at the exact warp centre the gap is `1010`.  The theorems
`timer131_midface_retry_requires_at_least_960_graphics_y_gap` and
`timer131_midface_retry_center_gap_is_1010` prove those bounds.  The existing
conditional writer envelopes `45` and `208` are far too small.

The authenticated JP retry-lifetime probe changed only the Graphics override
from the transient point to this mid-face point.  It then observed:

| Poll | Result |
|---:|---|
| 493 | State/Object/Graphics snapped to `(-1862,1783.940186,-902)`; floor owner and `gMarioPlatform` are top slot `803451f8` |
| 498 | State bits `(c509a4f6,44e4b7ba,c4966e48)`; floor owner and platform still name the top |
| 513 | State bits `(c4fa6882,44f09f67,c445cbb7)`; top is inactive/free at depth 0, but the final floor owner and platform still name its slot |
| first Area-2 poll | displaced State bits `(43b6cbe0,45abe000,c48919af)`; stale slot survives at free depth 47 |

With the same default zero-A continuation, the upper hidden-star trigger was
consumed and its controller counter changed from `0` to `1`.  This establishes
a **capture-preserving conditional payload**: once the debugger-installed
three-view prestate is supplied, real JP behavior carries the top pointer
through explosion, applies its stale payload in Area 2, and can reach the
upper trigger without an A edge.

It is still not a retail counterexample.  No clean gameplay trace is known to
create Graphics `(-1862,1778,-902)` while State is the first-query miss and
Object overlaps the upper warp.  The result consumes only one of five puzzle
triggers and does not by itself collect Act 6.  The Rocq theorem
`timer131_jp_midface_capture_observation_record_checked` checks the recorded
bits, owners, free depths, action values, zero-A counters, and final hidden
counter; the lifecycle proof and probe document the conditional execution.

## Generated source coverage

The checked source-shape bundle covers both US and JP generated Clight:

- the spinning constants, written position/velocity/yaw slots, and explosion
  switch branch;
- the `bhvPyramidTop` callback order: behavior loop before collision loading;
- the frame order from dynamic-list clearing through terrain objects,
  displacement, object collision, Mario/non-terrain update, unloading, and
  final platform selection;
- the renderer's `throwMatrix = NULL` assignment;
- collision-loader order through distance checking, vertex transformation, and
  surface loading;
- the float-to-signed-16 vertex casts; and
- assignment of the current object to the constructed surface's owner field.

The authoritative C locations are:

- `src/game/behaviors/pyramid_top.inc.c`, lines 32--64;
- `data/behavior_data.c`, the `bhvPyramidTop` script;
- `src/engine/behavior_script.c`, `cur_obj_update`;
- `src/engine/surface_load.c`, `transform_object_vertices`,
  `load_object_surfaces`, and `load_object_collision_model`;
- `src/engine/surface_collision.c`, `find_floor_from_list` and `find_floor`;
- `src/game/object_list_processor.c`, `update_objects`; and
- `src/game/rendering_graph_node.c`, `geo_process_object`.

## What remains open

The theorem in `proofs/Timer131Surface.v` is intentionally not a live-memory
selection theorem.  The conditional JP probe gives direct runtime evidence
for items 2--5 below at the injected boundary, but a linked US/JP Clight proof
must still establish them and gameplay reachability must establish item 1:

1. A clean collision frame creates the mid-face State/Object/Graphics split
   while the top reaches spinning timer 131.  Conditional persistence is now
   observed; installation of the required `>=960` gap is not.
2. The top's `throwMatrix` is null before collision construction, or its stored
   matrix already equals the fresh timer-131 transform.  A generated assignment
   that clears it does not by itself prove that the renderer visited this
   object on the preceding frame.
3. The dynamic allocator builds the five transformed vertices and six surfaces
   in live memory, with the top's current allocation epoch in `surface->object`.
4. The cell `(6,7)` list contains the proved face and no earlier accepted
   dynamic floor.  Static geometry cannot override it if its returned height
   is lower, but that comparison must also be executed.
5. The first State query and corrected Graphics query occur in the same
   reachable clean no-A frame with the warp interaction already cached.

The mid-face observation adds a capture-preserving conditional payload, but
does not remove the installer-reachability or formal-refinement conditions.

Until those facts are connected by Clight small-step execution, the result is
an exact surface capability and a concrete rejection of the old sample—not a
retail counterexample and not a proof of the ultimate theorem.

## Rocq entry points

- `timer131_pose_checked`
- `timer131_fresh_transform_float_bits_checked`
- `timer131_fresh_transform_s16_checked`
- `timer131_state_face_is_too_high`
- `timer131_old_home_sample_is_rejected`
- `timer131_robust_interior_retry_is_accepted`
- `timer131_midface_retry_is_accepted`
- `timer131_top_retry_requires_graphics_y_at_least_1450`
- `timer131_warp_retry_requires_at_least_632_graphics_y_gap`
- `timer131_concrete_retry_requires_at_least_638_graphics_y_gap`
- `timer131_midface_retry_requires_at_least_960_graphics_y_gap`
- `timer131_midface_retry_center_gap_is_1010`
- `timer131_midface_current_writer_bounds_cannot_install`
- `timer131_bounded_writer_cannot_install_retry`
- `timer131_jp_probe_observation_record_checked`
- `timer131_jp_midface_capture_observation_record_checked`
- `timer131_state_miss_finite_boundary`
- `timer131_surface_source_shape_checked`
- `timer131_surface_checked_boundary`
