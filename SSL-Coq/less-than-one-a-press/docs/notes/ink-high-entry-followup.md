# Usable high-window entry search — 14 November 2026

**No new usable Ink entry has been demonstrated.** The supplied ground-slide
controls still produce spawning displacement. The new airborne and actor
predecessors do not yet reproduce that payoff. In particular, a native slide
and a large graphics/movement gap can still end in the ordinary warp.

This follow-up starts from proof branch `codex/ssl-pyramid-item-proof` at
`651c180e594e45c6825f9c4800da11f4afef0773`, also the fetched fork head before
the work. It credits the existing native-landing, shell, height-map and
collision-only studies instead of repeating their conclusions as new results.
The individual reports below preserve all inputs, setup writes, runtime and
source hashes, finite menus and retained traces. The decompile checkout is
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`, with earlier local changes preserved.

## Why entering a ground action is still not enough

The default second window begins at integer **21778**, not 21777. Its
previously measured binary32 threshold is **21777.658203125**. An already
established ground slide there, or at Y67277, can refresh the low floor768
and retain high stored graphics while movement snaps down. But Mario must
also cross the pad boundary after that cache is set. Otherwise the next low
query finds the pad without retrying from the stored graphics coordinates.

Success in this investigation means: accepted real warp, actual top capture,
retention through deactivation, and the useful Area 2 arrival
`(365.5927734375,5500,-1096.8026123046875)`. Ordinary Area 2 `(0,5500,256)`
does not qualify. M is movement, C is the Mario object's collision position,
and D is stored `gfx.pos`, not the position of the drawn model.

## What the new experiments settle

| Branch | Native result | First failed requirement / evidence scope |
| --- | --- | --- |
| High FREEFALL, neutral/B/Z; 60 recipes at six heights | Fifty refresh floor768; none enters the required crawl or ground slide in its six-update screen | The air step compares raw Y with the low returned floor. Query aliasing and the ceiling sentinel do not make Mario land high. Eight retained air histories remain negative through 33 updates. |
| High shell contact followed by Z; 14,592 grid + 26,400 boundary recipes | Real shell mount/cancel executes crouch-slide. The respective 4,998 and 7,434 fresh-pad cases make the low snap and high D | They stay over the pad after the next wall resolution and take the ordinary warp. Mounting skips the later box handler. Other starts have the wrong floor cache. |
| Earlier shell conversion on the loaded top; 7,500 seeds and 3,873 later box placements | Native ground action; a separate export finds 892 supported butt slides at local Y1740–1801 | The later shove starts with a high top cache, not fresh768. Initial air and shell are still supplied. |
| Horizontal-PU native landing; eight supplied high-speed cases | The real game installs the top platform without a pointer edit | Pure-yaw carry does not turn horizontal distance into vertical height. The next tested update unloads the top and loses support. |
| Native thrown-box comparison;160 recipes | Real throw initialization and later native callbacks | No low-cache130 gap or capture. Ten full histories remain in Area1;147 boxes are inactive after129. Release can clamp upward, delay movement through a stale FAR_AWAY flag, then break on landing. |
| Two different actor types before129;100 box-only,2,673 shell-only and2,673 paired trials | Both shell and box actually change M in295 paired cases, with the native ground action retained | No ground-action endpoint inside the target pad at any Y. The gate for a second box cut before130 is never reached. These deliberately supplied actor placements test Mario-side feasibility, not delivery. |
| Supplied butt-slide controls at Y25000 and67277 | Top capture, retention and useful displaced arrival | Positive controls only: action and actor setup are supplied. |

The shell menus independently replay 532 boundaries plus 12 exported seed
states. The high-air/support/control study independently replays710
boundaries. The moving-box study independently replays340 boundaries.
Short-screen coverage is not described as a full continuation for every
negative. No new original-ROM replay was run; these new runtime results are
JP Wafel 0.8.5 evidence.

## Closest components and concrete obstructions

One new action initializer supplies air at `(-1880,21700,-870)`, speed20,
yaw0, downward velocity16, and a shell ten units below, before behavior128.
Z natively produces BUTT_SLIDE/top support at
`(-1880,1798.105712890625,-870)`. No ground-action ID or later Mario field
is written. This solves a conditional local action conversion, not acquisition
of the initial air pose, shell delivery or the useful handoff.

The native throw study also includes ordinary-air landings. Its nearest
selected ordinary-air predecessor has old C
`(-1924.912476,1800.403931,-820)` and carried M
`(-1825.965942,1800.403931,-899.817078)` before129's action. The northeast
pad target `(-1946,-922)` is about122.066609 units from that M, beyond the
107-unit Crazy Box shove. The corresponding shell predecessor is about
125.186652 units away. A proposed106-unit partial shove also puts the box
outside old C's112-unit collision radius. These are finite-menu measurements,
not a global minimum distance or an exclusion of multiple interactions.

This distinction between C and M matters: platform carry runs before
collision detection but updates M, while collision registration still sees
old C. Mario's new floor query runs afterward. Carry cannot be reused as a
post-cache shove. The actual source and throw timing are explained in
[the source report](ink-high-entry-source.md); the exact moving-box failure
has an update-by-update table in [the native throw report](ink-moving-box-entry.md).

The [two-actor feasibility relaxation](ink-high-action-entry-actor-cuts.md)
confirms that distinct interaction types can both shove the native butt slide.
In its closest confirmed two-push case, supplied air before128 is
`(-1920,21700,-1210)`. After the native slide initializer, only shell/box XYZ
are edited. Their129 interactions move M to
`(-2102.875,1799.2869873046875,-1191.162353515625)` while still in BUTT_SLIDE.
The ground step ends at `(-2100.150390625,1879.9844970703125,-1182.180908203125)`,
still on the top: **58.180908203125 units short** of the pad's Z edge. Its
first failure is horizontal departure, followed by alignment to a higher top
floor. A different two-push case retains Y1792.605957 but remains99.393799
units left of the pad. Twelve complete histories independently match432
boundaries. No before130 second-box cut was executed: the first gate failed.

A final speed refinement checked two near-miss positions, six initial air
speeds24/40/64/100/160/256 and four headings. The first48 recipes showed why
editing `forwardVel` alone was misleading: the shell cancel can retain old
slide velocities. A corrected48-recipe batch starts the airborne cut one
update earlier, runs a native neutral air update to initialize those
velocities, then supplies only shell XYZ for the128 mount/Z cancellation
and the previously tested actor XYZ at129. No later Mario field is edited.
All48 enter native butt slide; none ends129 grounded inside the target pad,
so again no second box cut or useful handoff occurs. Eight full corrected
histories match296 boundaries; eight diagnostic histories match288.

In the corrected initial-speed256 example, after128 the stored slideVel
vector has magnitude100, but actual horizontal `vel` still has magnitude
240.299831: the helper writes `vel` before normalizing slideVel. The stopped
quarter commits no X/Z. Update129 then computes an actual horizontal step
speed of about90.609185; that step also stops at the pushed position and
aligns to top floor1830.177979 rather than fresh768. Thus this really tests
a fast native slide. Stored slideVel, forward speed and the velocity used
by a particular ground step must be distinguished. It still does not
exclude other incoming positions, headings, support phases or histories.
The closest corrected endpoint is
`(-2192.284423828125,1847.39208984375,-999.306396484375)`, still supported
by the top and **44.284423828125 units left** of the target pad. This is
the closest reported position from that corrected menu, not a useful entry.

The next discriminating experiment is an earlier landing/support history
that puts carried M close enough to the pad while old C still admits actors
on the useful push side. Check those two positions and the fresh floor first,
then test the stopped ground quarter and full displaced arrival. Increasing
the supplied speed alone at the two checked positions does not repair them.

## What is proved, and what remains open

[`InkIdleOffFloorGuard.v`](../../proofs/InkIdleOffFloorGuard.v) reasons about
the actual generated US/JP idle handler. At a reached cut with a live
OFF_FLOOR flag, every completed execution takes the real FREEFALL request
and returns before later walking/sliding/Z controls. The actual preceding
prefix can be attached without assuming its calls preserve memory. This
closes the idle-tail part of the delayed shell-knockback recovery proposal;
it does not prove the earlier knockback history, flag production, final
action field or global entry impossibility.

The module is registered and exported through MainTheorem's
`current_ink_idle_off_floor_guard_boundary`. The targeted pipeline build
and selected five-boundary audit pass with Coq 8.16.1, CompCert 3.15 and the
unchanged memory limit. The audit checks 719 sources, reports foundations
9/7/4/7/7, and finds no integration problems. The new boundary uses seven
existing allowed foundations. [Exact commands and receipts](../../instrumentation/ink-high-entry-proof/README.md)
distinguish this selected audit from an all-module build.

The three gameplay obligations remain separate: reaching Mario's usable
pose/action/cache, delivering usable actors at their actual coordinates,
and joining them at the useful top phase. Every new runtime history keeps A
released, but its initial air, shell preparation and actor cuts remain
grants. None is a continuous allowed route from the accepted start. The
route verdicts and all 45 subjective estimates remain unchanged, including
Rank 1 **1–2%** and Ink Rank 2 **<1%**; they are not measured probabilities.

Detailed records: [high shell entry](ink-high-action-entry.md),
[high air and support](ink-high-support-entry.md),
[native moving box](ink-moving-box-entry.md), and
[two-actor feasibility](ink-high-action-entry-actor-cuts.md), alongside
[source/proof boundaries](ink-high-entry-source.md). The third film remains
cancelled; no video was made for an ordinary-warp or gap-only result.
