# Can a different place or earlier phase make the below-cap gap useful?

**No useful setup was found in the new bounded search.** Moving the supplied
crawler around the low pad, changing push direction and actor, and trying
every spinning phase 0–149 produced many low/high disagreements but no top
capture. For this method, which preserves the initial crawling height in
display, a 100-unit body kept entirely below the cap leaves that display too
low for the next floor query to select the cap. The cap's early bobbing drops by at
most 10 units across the two-update window; that does not recover the height
lost by keeping the body below it.

The separate high-display controls clarify the timing issue. All 42 of those
supplied-gap controls initially remember the top. Their floor owner and
platform remain the top throughout the sampled Area 1 continuation. In the 36
earlier cases, the top's slot contains a Goomba by the first Area 2 sample and
Mario arrives normally. In the six timer 131 cases, the slot remains an
inactive top and the familiar useful sideways displacement occurs. Thus these
records show slot replacement during the transition, without an observed
early loss of the remembered floor in Area 1.

The [Y 1400 demonstration and commentary](ink-below-cap-video.md) shows the
632-unit conditional producer. It does not demonstrate a clean no-A route:
the initial high crawling state and nearby item placement remain supplied.

## The new position and phase search

The [search implementation](../../instrumentation/wafel-jp-pilot/ink_below_cap_phase_search.py)
first replays the authenticated no-A four-pillar inputs. It saves the naturally
reached contexts for stored spinning phases 0–149, with no timer, RNG, object
allocation, pillar or floor edits. Each candidate restores one such context,
supplies **equal movement, collision and display positions**, an established
crawl and a native actor placement, then runs the real JP update.

The initial writes are limited to those three Mario position records, crawl
action/state/timer, speed/velocity/yaw, the 100-unit crawl hitbox, and the chosen
actor's XYZ/velocity fields. Floor pointer/height, ceiling, platform, held-object
state and collision lists are not supplied. All candidates begin without a
display gap. The first input is held Z with stick `(0,64)`; the second is
neutral. Any captured-top case is continued with neutral input to first Area 2.
There are no intermediate game-data edits and no A inputs.

The finite matrix contains:

- Every stored spinning phase 0–149.
- Ten initial X/Z points: the nine combinations of X=`-2132,-2048,-1964`
  and Z=`-1108,-1024,-940`, plus `(-1950,-939)`.
- Eight push directions separated by 45 degrees.
- Native Crazy Box 49 and Bob-omb 39, with their different radii.
- Two intended push distances, 40 and 68. Actual outcomes include wall
  corrections and rejected pushes; these distances are proposals, not assumed
  committed motion.
- At every phase, initial Y is 101 below the lower of the old and newly
  prepared cap bases. At phases 0, 40, 59, 60, 80, 96, 112, 122, 130, 149, another height
  is 40 units lower. This keeps the supplied 100-unit body strictly below both
  meshes before any native result is accepted.

That is **51,200 trials and 102,400 native updates**. Every trial passed the
strict body-clearance screen; none was silently removed for a cap overlap.
The screen compares a radius 37/observed-height bounding box with the loaded
cap's bounding box at the supplied start, logged action entries and end of the
producer update. It is conservative and concerns the collision body, not the
rendered mesh. It does not trace every internal position write.

| Observed result | Count or value |
| --- | ---: |
| Positive display-minus-movement gaps |49,572 |
| Positive gaps with low position within the warp's horizontal radius |49,474 |
| Those low endpoints outside the authored pad rectangle |7,552 |
| Next update accepts the upper warp and reports ownerless roof 1280 |1,666 |
| Initial top captures, even under the broad pointer screen |0 |
| Useful below-cap Area 2 arrivals |0 |
| Largest gap among the near-warp low splits |744 |

All positive-gap endpoints have actual Y 768. Many remain on the low pad, so
the large gap count is **not** a count of successful first-query fallbacks.
Likewise, being outside the pad rectangle is a coordinate classification,
not a live floor-query hook. The 1,666 roof cases are actual next-update warp
and cached-floor observations. The broad capture screen asks only for used
object 64, floor owner 61 and platform 61; it deliberately lacks some additional
action checks. Zero matches under this weaker screen also means zero matches
under the stricter disappeared/action-argument test.

The closest measured top-query miss is the known east endpoint at phase 130:
the game creates M/C=`(-1882,768,-939)`, D=`(-1882,1417,-939)`, a 649-unit gap.
The next top plane is 1818.9613037109375. Subtracting 78 in binary32 gives
a comparison value 323.9613037109375 above the integer display query. Integer
display Y 1741 would be needed, 324 above 1417. The actual retry selects roof 1280.
Both actors reproduce that result. The plane height is calculated from the
loaded native plane; the next cached roof is an observed game result.

The maximum 744-unit gap belongs to a later phase with a higher cap. It is not
closer to useful capture merely because its absolute gap is larger. The
target surface rises too. A complete conditional success would need both top
capture and the useful Area 2 continuation in the same run.

## What the geometry and source explain

The receipt preserves all six loaded cap triangles at 152 consecutive poses,
from stored phase 0 through the pose produced by spinning timer 150. The final
pose has already changed to the explosion action, but its explosion body has
not yet deactivated it. These are observed native meshes, separate from the
source-derived Coq phase calculation.

The native base starts at 1281. During the early bobbing it takes values 1281,
1288 and 1291. It stays 1288 across stored phases 60–84, then increases by 5 per
update: stored phase 130 has base 1518, the producer update prepares 1523, and
the following retry update prepares 1528. The maximum adjacent fall is 7; the
maximum fall over any of the 150 two-update windows is 10. A computation from
the loaded base polygons places every corner of the authored low pad at least
336.33624 units inside the cap footprint's edge, more than the 37-unit Mario
radius. This finite polygon calculation is not a Coq theorem about every live
surface list.

The source in `src/game/behaviors/pyramid_top.inc.c:32–50` explains the early
non-monotonic motion: before timer 60, home Y is offset by the absolute value
of a sine wave of amplitude 10. The later stock branch eventually gives
vertical velocity 5. Treating the entire spin as monotonically rising would
be wrong; the bounded certificate includes the early downward changes.

For a retained display height equal to the initial crawling Y, a 100-unit
body below the cap gives a 100-unit separation from the base. The floor query
can look only 78 units upward. Even a 10-unit base drop across the two-update
window leaves 12 units before allowing for plane arithmetic. Requiring
clearance at both the old and prepared meshes, as the experiment does,
leaves a measured minimum 15-unit separation from the next base at the
100-unit body boundary. The search's extra one-unit clearance increases it.
The nearby sloping top faces are substantially higher than the base, which
explains the larger observed query shortfall.

This rules against the tested idea of making the **same preserved-height
crawl producer** useful merely by moving around this pad or choosing an
earlier ordinary phase. It does not exclude a different display writer,
different actual action/hitbox history, a different moving support or another
gap producer. The provided crawl and actor still need a controller history.

## Conditional Coq connections

[InkBelowCapPhaseGuard.v](../../proofs/InkBelowCapPhaseGuard.v) connects the
height comparison to the generated floor-query rejection fragment. Its
`ibcpg_below_body_buffer_is_negative` statement allows every signed 16-bit query Y
under explicit bounds: query Y+100 is no higher than the old base; the old base
is at most 10 above the retry base; both bases lie in 0–32768; the finite computed
plane height lies between retry base−10 and 32768. Under those assumptions,
the actual binary32 comparison still rejects, with a real-valued margin of
at least 2. The ten-unit lower allowance for plane height is explicit slack,
not an assumption that floating-point planes are exact.

`ibcpg_below_cap_query_rejects_this_surface` constructs execution of the
actual generated rejection fragment: it continues the surface loop without
changing memory. It is a local query result, not a complete floor lookup or
Mario update.

[InkBelowCapPhaseBounds.v](../../proofs/InkBelowCapPhaseBounds.v) extracts the
early sine indices, generated sine-table samples and relevant source
expressions. Its stock-pose calculation uses home Y 1536, initial vertical
velocity 0, zero yaw angular velocity at the timer-60 starting state, unit
scale, zero pitch/roll and a fresh transform. The
`ibcp_stock_phase_certificate_checked` theorem checks 152 poses and all 150
two-update windows, including the maximum 10-unit drop. The combined
`ibcp_every_bounded_stock_phase_rejects_this_surface` applies that certificate
to the actual query fragment, while retaining the plane-height and storage
hypotheses. The boundary is connected through `InkConcreteProducerBoundary`
to the selected main producer boundary.

The composed theorem assumes the converted integer query still satisfies
query Y+100 ≤ old base. It does not derive that relation from preserved display
storage through the complete conversion and update history, or cover every
candidate node in a live floor list.

These statements do **not** identify every arbitrary live `throwMatrix` or
floor list with the stock calculation, prove every selected plane's lower
bound, produce the high crawl/item/cache history, or establish an all-history
no-A exclusion. The completed pipeline checks are recorded below.

## Why earlier capture alone still fails the tested continuation

The [separate lifetime diagnostic](../../instrumentation/wafel-jp-pilot/ink_below_cap_capture_lifetime.py)
replays the old six low poses at stored phases 0, 60, 100, 128, 129, 130, 131, with
display Y 2300 supplied at the same X/Z. It supplies only the nine position
words. These 42 trials do not create a gap and do not pass as below-cap
producers. Their purpose is to observe where an initially successful capture
ceases to give a useful payoff.

All 42 satisfy the stricter first-update capture test: disappeared action,
action argument 0x40001, used object 64, floor owner 61 and platform 61. All
retain floor owner 61 and platform 61 in every sampled Area 1 update 1–23.

| Capture phase | First Area 2 sample, update 24 | Slot 61 at that sample |
| --- | --- | --- |
|0, 60, 100, 128, 129, 130; 36 trials|`(0,5500,256)`, ordinary elevator arrival|Active `bhvGoomba` |
|131; six trials|`(365.5927734375,5500,-1096.8026123046875)`, outside elevator|Inactive `bhvPyramidTop` |

The timer 130/131 comparison is particularly informative. Capturing at 130
reaches explosion action 2, timer 0 by continuation update 21, but the object is
still active. It remains in that state during the next two transition
samples; the explosion body has not run. At capture phase 131, the explosion
body has already run by update 21: the slot is inactive but still retains its
top behavior and movement fields. That difference precedes the observed
destination replacement in the earlier run.

The observations therefore support a slot-lifetime explanation, rather than
"the earlier capture simply forgot the top while still in Area 1." They do
not hook the precise free, allocation or first Area 2 platform-apply call.
Seeing a Goomba by the first completed Area 2 sample does not independently
prove which payload the exact earlier apply call read. The existing
[timer 131 call-level lifecycle trace](jp-lifecycle-trace.md) provides that
stronger timing evidence for its own successful fixture. Its allocation
counts are not generalized to these earlier continuations.

## Reproduction, checks and evidence limits

The compact [phase receipt](ink-below-cap-phase-receipt.json) contains the
geometry catalog, per-phase counts, two controls,13 retained near misses and
fresh-replay results. The inside-cap 973-unit control captures the top and arrives
outside the elevator; the below-cap 632-unit control creates a gap and selects the
roof. These controls verify that the harness distinguishes the two outcomes.
Fifteen selected cases, including those controls, match 375 complete suffix
updates after a fresh boot and replay of the prefix.

The [lifetime receipt](ink-below-cap-capture-lifetime-receipt.json) preserves
every update of all 42 trials: 1008 updates. Seven representative trials match
168 updates after a fresh boot. The comparisons cover the recorded state and
normalized events, not whole native memory.

The [validator](../../instrumentation/wafel-jp-pilot/ink_below_cap_phase_verify.py)
passes 152 meshes, all 42 lifetime cases and, with the local raw report supplied,
all 51,200 search rows. Eight mutation tests reject altered geometry, motion
bounds, supplied gap/floor data, cap clearance, replay counts, capture action
arguments and platform-loss records. Without `--raw`, it checks the compact
evidence but cannot reconstruct all aggregate search counts. The 53.86 MB raw
report remains local at `build/wafel-pilot/ink-below-cap-phase-20261111.json`;
the compact receipt pins its SHA-256 and row digest.

Run from the SSL project in Windows PowerShell, using fresh output paths:

```powershell
& './build/wafel-pilot/python/python.exe' instrumentation/wafel-jp-pilot/ink_below_cap_phase_search.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-below-cap-phase-REPLAY.json --receipt build/wafel-pilot/ink-below-cap-phase-REPLAY-receipt.json
& './build/wafel-pilot/python/python.exe' instrumentation/wafel-jp-pilot/ink_below_cap_capture_lifetime.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-below-cap-lifetime-REPLAY.json
& './build/wafel-pilot/python/python.exe' instrumentation/wafel-jp-pilot/ink_below_cap_phase_verify.py docs/notes/ink-below-cap-phase-receipt.json docs/notes/ink-below-cap-capture-lifetime-receipt.json --raw build/wafel-pilot/ink-below-cap-phase-20261111.json
```

The remaining gameplay question is open. No tested below-cap position or
earlier phase creates a split that both captures the top and preserves a
useful Area 2 payoff. The new local obstruction and finite search sharpen
that particular producer; neither covers every possible no-A history.

## Completed proof checks

The actual starting head was `e7f14b8e116b1e07a8cf8fdfd5561a261571dc9f`
on `codex/ssl-pyramid-item-proof`, a descendant of the requested starting
commit. The pipeline revalidated the `sm64-item-proof` switch, Coq 8.16.1 and
CompCert 3.15 in Ubuntu WSL. The established 6,815,744 KiB memory limit was
retained. No bare `coqc`, new axiom or `Admitted` was used.

Run inside the WSL SSL project directory:

```bash
bash pipeline/build.sh audit-build AUDIT_VO_TARGETS='proofs/InkBelowCapPhaseGuard.vo proofs/InkBelowCapPhaseBounds.vo'
bash pipeline/discipline-check.sh --build-timeout 600 --assumption-timeout 240 LessThanOneAPress.Proofs.MainTheorem current_ink_concrete_producer_boundary LessThanOneAPress.Proofs.InkBelowCapPhaseGuard ibcpg_below_cap_phase_guard_checked LessThanOneAPress.Proofs.InkBelowCapPhaseBounds ibcp_below_cap_phase_boundary_checked
```

Both targeted builds passed. Final selected audit
`build/audit/20261111-170038-19wwlcyz` passed the dependency build, source
inventory (715 sources, zero issues), proof-hole check, link hygiene and all
three assumption queries. The main boundary uses seven existing allowed
foundations; each new boundary uses six. Integration reports 549 of 635
modules in the main import closure, 86 standalone modules and zero problems.
The baseline audit `build/audit/20261111-164538-45an1e5t` also passed before
the new proof work. These audit results certify the stated local/conditional
claims, not the unconstructed gameplay history or source-to-ROM correspondence.
