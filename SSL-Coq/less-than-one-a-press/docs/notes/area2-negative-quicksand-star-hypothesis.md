# Area 2 negative-quicksand star hypothesis

## Verdict

SSL Area 2 does contain quicksand, including moving quicksand directly under
the Act-6 star's X/Z position.  That fact does **not** make negative quicksand
depth a direct star-collection method.  Quicksand sinking changes where Mario
is drawn, while the star check uses Mario's raw collision position.  The new
Coq model proves that every finite number of Graphics-only sinks leaves the
direct collision result unchanged.

There is nevertheless a precise hypothetical capability worth preserving for
a future retail-machine or ACE model.  If negative depth survives for several
frames and a later floor lookup first fails at MarioState, the game's Graphics
retry can copy the raised displayed position into MarioState.  A subsequent
State-to-Object copy can then move the raw collision position, allowing the
next collision pass to see the height.  The formal kernel proves the numerical
payoff of that bridge but does not assume that its floor-query miss, retry, or
negative seed is reachable.

The formal artifact is
[Area2NegativeQuicksandStarHypothesis.v](../../proofs/Area2NegativeQuicksandStarHypothesis.v).

## What quicksand Area 2 contains

The pinned source enumeration identifies four quicksand groups, and the
generated US and JP initializers agree on all four checked headers and counts:

| Surface | Type | Triangles |
|---|---:|---:|
| deep quicksand | `34` | 128 |
| deep moving quicksand | `36` | 36 |
| moving quicksand | `39` | 78 |
| instant moving quicksand | `45` | 18 |
| **total** |  | **260** |

The Act-6 star is centered at `(900,1400,2350)`.  Its X/Z point lies inside
moving-quicksand triangle 1376, whose vertices are
`(1178,1229,2150)`, `(-1740,1229,2150)`, and `(1178,1229,2560)`.
The Coq receipt recovers the group header, local triangle number, force word,
vertex indices, vertex coordinates, orientation, and point containment from
both generated initializers.  Mario standing at `(900,1229,2350)` has a raw
hitbox top of `1389`; the star begins at `1400`, so the raw standing sample is
exactly 11 units short.

The Act-3 star is different.  Its checked standing floor is an ordinary
camera-free-roam surface at Y `4815`, not quicksand, and Mario's raw hitbox is
75 units short of the star.  A negative value carried to that location could
still affect the common Graphics sink, but Area 2 does not supply quicksand at
the Act-3 standing point itself.

## What ordinary entry does

Both generated game versions show `init_mario_after_warp` calling
`init_mario`, and `init_mario` explicitly writes binary32 `+0.0` to
`quicksandDepth`.  Therefore a negative value installed before the Area-1 to
Area-2 transition does not simply carry through ordinary initialization.  A
future mutation would have to occur after that reset, prevent or replace the
reset in a machine-level model, or prove that the assumed transition did not
execute the ordinary initialization path.

The existing defined-producer audit also found no clean zero-A source writer
for a negative seed.  The one arithmetically negative stock case is the late
long-jump landing adjustment, whose ordinary provenance requires A; shorter
landings finish before reaching the dangerous timer.  Writable action-table
mutation is separately closed for successful in-bounds executions of the
selected CompCert programs.  This remains why the Area-2 finding is a
hypothetical future capability rather than a current route.

## Why negative depth alone cannot collect either star

The relevant game views must stay separate:

| View | Used for | Effect of the sink |
|---|---|---|
| MarioState position | movement and the first floor query | unchanged |
| raw Mario Object position | object/star collision | unchanged |
| Graphics position | drawing and the fallback floor query | Y decreases by `quicksandDepth` |

For a negative value, “decreases by depth” raises Graphics.  It still does not
raise MarioState or the raw Object.  Object collision runs before Mario's
behavior update in the frame, and its overlap calculation reads the raw Object
coordinates.  The later sink therefore cannot retroactively change that
frame's star check.  The Coq theorems quantify over every depth and every
finite sink count and prove that the raw Act-6 and Act-3 standing samples still
miss.  They also prove that any successful later overlap must use a raw
position different from the Graphics-only sink result.

This conclusion is scoped honestly: the hitbox calculation is the project's
checked binary32 collision model, while the final execution refinement from
the generated `detect_object_hitbox_overlap` body remains a separate project
obligation.  Out-of-bounds writes, ACE, DMA, and post-undefined-behavior retail
execution are outside the selected CompCert model.

## The exact hypothetical payoff

The proof reuses the exact negative binary32 payload
`-2.6500000953674316`, which is the value obtained in the already-checked
conditional late-landing arithmetic.  It repeatedly applies only the
Graphics sink and then, deliberately and visibly, applies a **forced**
Graphics-to-State-to-raw copy.

| Target | Raw standing gap | Last checked miss | First checked overlap | Raised raw Y after the successful forced copy |
|---|---:|---:|---:|---:|
| Act 6 | 11 | 4 sinks | 5 sinks | about `1242.2501` |
| Act 3 | 75 | 28 sinks | 29 sinks | about `4891.847` |

These are exact CompCert binary32 computations, not real-number estimates.
They answer the narrow hypothetical positively: **if** a negative payload is
retained, **if** the required number of sinks can run without reanchoring or
resetting it, **if** the first State floor query then misses, **if** the
Graphics retry succeeds, **if** the copied State reaches the raw Object, and
**if** the next collision uses that raw value, the added height is sufficient
for the target hitbox.

They do not show that negative depth naturally makes a floor query miss.  In
fact, the exact static support receipt under the ordinary Act-6 sample, and
the existing receipt under the Act-3 sample, make an unexplained miss
particularly implausible.  A live counterexample has to identify why the
query does not return those floors—for example a different State position,
a lifecycle/list failure, a signed-16 query alias, or a separately specified
machine-level mutation.

## Formal boundary for future work

`Area2NegativeDepthLiveBridgeObligation` is intentionally left uninhabited.
It requires one continuous execution containing all of the following facts:

1. accepted Area-2 entry has depth `+0.0`;
2. the exact negative payload is installed afterward;
3. Mario remains at the relevant raw standing sample while five Act-6 sinks
   or 29 Act-3 sinks accumulate the displayed gap;
4. the first State floor query returns null;
5. the Graphics retry returns a usable floor;
6. the retry copies Graphics into State;
7. the behavior tail copies State into the raw Object;
8. the next collision preserves that raw value, overlaps the target, and
   actually collects the star.

The generated-source receipts prove that the entry reset, guarded Graphics
retry, sink ordering, and State-to-raw copy exist in both versions.  They do
not prove that one live execution takes the required branches.  This split is
the main value of the hypothetical proof: a future ACE or machine-corruption
discovery can plug into a small, exact contract without reopening the already
settled geometry, while ordinary CompCert work can focus on disproving the
seed and query-miss fields.

## Practical conclusion

For current route search, Area-2 quicksand does not improve the rank of the
negative-depth approach.  It supplies nearby geometry and a small 11-unit
Act-6 gap, but ordinary entry erases a carried seed, Graphics-only sinking is
collision-inert, and the ordinary target has a floor rather than the required
first-query miss.  The route should be reopened only when there is a concrete
post-entry negative writer or a concrete reason the State query misses while
the raised Graphics query succeeds.
