# State-first installer and downstream route search

## Result

The proposed **stock State-first installer is excluded at the current formal
boundary**.  If MarioObject is already overlapping the SSL Area-1 upper warp,
every modeled stock source of the platform pointer is `NULL`; therefore
`apply_mario_platform_displacement` cannot run its body.  A wall push before
the first State floor query also cannot rescue this installer: it preserves
State Y, while the upper-warp sample is at least 463 units below the lowest
stock pyramid-top floor and `find_floor` allows only 78 units above the query.

This is not yet a whole-ROM exclusion.  The remaining connection is the named
`Area1StockPreapplyProjectionSound`/`StateFirstStockProjectionObligation`:
linked US and JP Clight memory at every relevant pre-apply control point must
project into the already-proved finite origin relation.  The result also does
not exclude Ink's graphical-retry installer, which intentionally uses a
different Graphics sample after the first State query returns `NULL`.

The downstream half of the JP candidate is much stronger.  An authentic-JP
boundary fixture reaches the true first Area-2 post-apply position

```text
(365.5927734375, 5500.0, -1096.8026123046875)
```

and a zero-A stick continuation consumes the upper Pyramid Puzzle trigger.
The fixture still injects the post-installer Area-1 boundary, so it is not a
clean-retail counterexample.

## Why the stock State-first schedule fails

The candidate schedule would be:

1. the preceding frame's final `update_mario_platform` stores a non-null
   `gMarioPlatform`;
2. the next terrain update runs;
3. `apply_mario_platform_displacement` writes MarioState through that pointer;
4. `detect_object_collisions` still reads the preceding MarioObject position,
   which overlaps Area-1 warp node `0x1E`;
5. Mario's first geometry query reads the displaced State and selects the top,
   avoiding the Graphics fallback;
6. the cached warp interaction and later final platform query retain the
   desired pointer.

The source-bounded contradiction occurs at steps 1 and 4.  The only normal
retail recomputation writer is the preceding final `update_mario_platform`.
At the same raw MarioObject sample used by the next collision pass:

- the pyramid top's lowest possible floor is Y `1281`;
- upper-warp overlap constrains MarioObject Y to `608..818`;
- final platform capture requires strict distance below `4`; and
- every other modeled Area-1 dynamic owner has a horizontal envelope disjoint
  from the upper-warp box.

Consequently the preceding final query records `NULL`.  The finite origin
relation also includes:

- the US area-spawn clear;
- all three stock inbound Area-1 warp-node positions in US and JP; and
- arbitrarily many frozen frames that preserve the same position and pointer.

`no_source_bounded_stock_state_first_installer` packages the contradiction.
`upper_warp_nonnull_preapply_escapes_stock_origin` gives the useful converse:
any real non-null witness at the upper warp must demonstrate that the linked
run escaped the bounded relation rather than silently assuming it did.

## Wall and ordinary/PU State movement

`update_mario_geometry_inputs` calls the wall routine twice before its first
floor query.  The wall list updates X and Z but not Y.  Thus even an unusually
large horizontal wall push or signed-coordinate/PU horizontal alias cannot
make a warp-height State query return a stock top floor.  The formal theorem
`y_preserving_prequery_writer_cannot_select_live_top` uses the actual 78-unit
floor-search allowance, not the tighter 4-unit final-platform tolerance.

Ordinary action movement occurs after this initial geometry query, so it
cannot make the *first* query select the top.  It may still matter to the
separate post-commit-transport family.  A PU or stale-platform operation that
changes State X/Y/Z before the query is not dismissed by the wall theorem;
it must still explain how a non-null platform pointer was present.  Under the
finite stock origin relation, that pointer premise is the contradiction.

## Raw MarioObject writer audit

A direct source search for writes to `gMarioObject->oPos*` found two special
cases outside the normal State-to-Object copy:

1. the project-local spawning-displacement diagnostic hook in
   `src/game/level_update.c`; it is not retail code; and
2. `butterfly_calculate_angle` in
   `src/game/behaviors/butterfly.inc.c`, which temporarily offsets
   MarioObject while computing angles and restores each coordinate before
   returning.

There is no `bhvButterfly` object in SSL's level scripts, and the routine's
temporary writes occur only when that behavior runs.  It therefore does not
supply an SSL Area-1 upper-warp scheduling escape.  The ordinary
`copy_mario_state_to_object` runs in Mario's behavior after collision
detection, so it is too late to alter that frame's cached warp sample.

This is a direct-writer audit, not a proved whole-program alias analysis.
Pointer aliases and imported/external effects are part of the linked writer
closure still required by `StateFirstStockProjectionObligation`.

## Exact downstream JP observation

The current lifecycle probe records this successful continuation:

| Control point | Observation |
|---|---|
| first Area-2 poll, timer 516 | Mario `(365.5927734375, 5500, -1096.8026123046875)` |
| timers 516--575 | stick `(-127,-96)`, A down false |
| after timer 575 | neutral stick, A down false |
| timer 594 sample | Mario `(390.4210205078125, 4009, -593.7681884765625)` |
| timer 595 observation | upper trigger inactive; hidden counter `0 -> 1` |
| complete trace | `aPressedFrames=0`, `aDownFrames=0`, `controllerAFrames=0` |

The trigger is the macro object at `(260,3913,-600)` with hitbox radius and
height `100`.  `jp_observed_upper_trigger_sample_overlaps_binary32_model`
computes the timer-594 overlap using CompCert binary32 operations and Mario's
standard radius `37`, height `160` hitbox.  The timer-595 transition is an
emulator trace observation; its linked Clight/event refinement is still open.

This settles an important downstream question: **if a suitable stale-platform
payload can be installed and survives to the true first Area-2 apply, normal
zero-A movement can consume the upper trigger.**  Ink's Graphics gap is one
possible way to install that payload, not a separate final route.

## Act 3 and the remaining Act 6 route

The same first-apply landing begins above the Act 3 star, but not close enough
horizontally for the observed spawn-spin fall to collect it.  The star is at
`(500,5050,-500)`.  Across the tested initial stick directions, the spawn-spin
action reaches Y `5080` at `(365.592773,-1075)` in X/Z coordinates, about
`590.5` horizontal units from the star; the combined Mario/star radius is only
`117`.  The source action sets forward speed to `2` and does not use the stick
to steer that fall.  This rules out direct collection for the observed
payload and tested collision path, not every possible stale payload or later
route back to Act 3.

For Act 6, the four unconsumed trigger centers below the successful upper
sample are:

```text
(-260, 2940, -600)
( 260, 1967, -600)
(-1940, 1229, -600)
(-1940, 1229, 2320)
```

A feedback/piecewise zero-A controller search is the next executable step.
The observation above already places Mario on the target side of the
second-pole cut; the search must still record each collision, counter
transition, and eventual Act-6 star spawn/collection rather than relying on
the informal statement that the rest of Area 2 is traversable.

## Surviving installer families, ranked

1. **Ink Graphics retry plus JP stale slot.**  Still the best clean-installer
   candidate because the destination continuation is now observed.  It needs
   a reachable timer-131 Object/Graphics separation and live top-owned retry.
2. **Physical co-location or collision-preserving clone.**  Move/clone the
   warp or top collision so the final query can record an owner at the warp.
   No stock route is known; clone collision breakage remains relevant.
3. **Post-commit transport.**  Cache the warp first, then move Mario onto a
   dynamic owner before the final query.  The ordinary disappeared action
   snaps to its selected floor, so a concrete later writer is required.
4. **Other dynamic owner / slot payload.**  The stock final-query geometry
   excludes all fifteen modeled owners at the unchanged warp sample, but a
   moved collision sample or linked-projection escape could reopen this.
5. **Skipped-query frozen carry.**  Needs an actual scheduler path that skips
   the final recomputation while preserving a non-null pointer and the warp
   collision sample.
6. **Stock State-first or wall-only State-first.**  Excluded by the theorems in
   `proofs/StateFirstInstaller.v`, conditional only on the named linked
   projection for the stock-origin result.

No clean-retail US or JP counterexample has yet been found.  The ultimate
less-than-one-A theorem remains incomplete.

## Verification

The focused proof builds with:

```sh
opam exec --switch=sm64-item-proof -- \
  coqc -Q generated LessThanOneAPress.Generated \
       -Q proofs LessThanOneAPress.Proofs \
       proofs/StateFirstInstaller.v
```

The authenticated lifecycle probe and ROM hash checks live under
`instrumentation/jp-lifecycle/`; generated traces remain ignored build
artifacts.
