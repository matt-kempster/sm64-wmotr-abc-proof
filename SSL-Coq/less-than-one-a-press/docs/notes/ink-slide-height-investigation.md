# Sliding, crawling and working Ink heights

Investigated 13 November 2026. **Ground sliding can complete the supplied-state
JP Ink handoff. A continuous no-new-A route to the necessary state remains
open.** This expands the action choices: an established crawler is not the
only possible producer. It does not make arbitrary airborne Mario a grounded
slider, or demonstrate delivery of the required actor.

## Why sliding helps

Mario has three position records: **M**, his movement position; **C**, his
collision object's raw position; and **D**, the stored graphics position.
In the useful examples, all three start equal. An actor pushes M sideways
after the game has cached the low floor at Y768. A stopped ground step saves
the still-high position in D. Floor alignment then snaps M to the remembered
768, and the normal callback copies that low position into C.

The common ground-slide helper still performs this alignment after its
bonk branch. Consequently, changing action to ground bonk need not destroy
the gap. On the following update C overlaps the real low warp; the failed
low floor query retries using D, selects the top, and the disappearing action
snaps Mario to its local surface. The retained platform can then give useful
Area 2 displacement. These are different requirements, and the experiments
follow them separately.

The distinction between actions matters. Butt slide, stomach slide,
crouch-slide and their applicable holding variants succeed in supplied
fixtures with a Crazy Box. Dive-slide also uses the common helper, but its
grab eligibility suppresses the required Crazy Box/Bob-omb push. A separately
supplied native-shell fixture succeeds. Slide-kick-slide has no corresponding
floor-alignment call; the tested slide-kick and airborne-slide controls do
not produce this split.

See the [action experiments](ink-slide-handoff.md) for the exact setup writes,
action guards, positive and negative traces, speed/input controls and actor
differences. The [source and Coq record](ink-slide-source-proof.md) gives the
precise formal boundary; runtime evidence is not a whole-game Coq theorem.

## Working heights are separate bands

Here the **main universe** means actual binary32 Y in **[-32768,32768)**.
Its integer survey includes every integer from -32768 through 32767. The
quantity below is actual M.Y before the gap-producing update; successful
retained action-entry samples and the source's step sequence support its
remaining unchanged until the gap-producing ground step. This is a
source-connected inference: no new hook records the local floor-query
temporary or every internal quarter-step boundary. Initially
C.Y and D.Y equal it. The useful producer ends at M.Y=C.Y=768, while D.Y
retains the starting height, so its gap is **starting Y minus 768**.

The standard fixture starts at X/Z=(-1950,-939), with Crazy Box 49 at
(-1989,Y,-939), naturally reached top phase 130, and no cache, platform,
mesh, timer or RNG edits. Crawl uses its documented speed/input setup;
the butt-slide height survey supplies slide speed 20. Both use Z with stick
(0,64) for the first update, then neutral. This is a controlled comparison,
not a claim that these velocities or actions were reached by the prefix.

| Fixed setup | All successful integer starting heights in the main-universe survey | Gap in those integer bands |
| --- | --- | --- |
| Crawl | 1741–1803; 21778–32767 | 973–1035; 21010–31999 |
| Butt slide, speed 20 | 1741–1801; 21778–32767 | 973–1033; 21010–31999 |

Both ends of each integer interval are included. Every other tested integer
in that range fails the intended producer-at-130/retry-at-131 handoff test.
The scan stops negatives after those two updates; captured cases continue
to Area 2. It does not exclude a different later installation. This is exhaustive
over the stated integer menu and fixtures, not over all binary32 values,
actions, inputs, placements or histories. Adjacent-float tests refine the
outer boundaries: the first band starts at 1741, with the previous float
1740.9998779296875 failing. Crawl's last tested working float there is
1803.9998779296875, followed by failure at 1804; butt slide's is
1801.9998779296875, followed by failure at 1802.
Y21777.658203125 works and Y21777.65625 fails; the largest
binary32 value below 32768, **32767.998046875**, works, while 32768 fails.
The corresponding largest observed main-universe gap is **31999.998046875**.

The second band is real, not a monotonic extension of the first. Intermediate
heights can select the top as the initial cached floor and thus miss the low
warp. Near the 20,000-unit top-loading distance boundary, the top unloads;
the low pad can again supply the cache, and the default no-ceiling height
20000 can stop the high quarter. At the next low update the top loads again.
The number 19840 from Y+160 >= 20000 is therefore not, by itself, the lower
endpoint of a working handoff band.

Moving the fixture reduces the least demonstrated requirement. At supplied
X/Z approximately (-1946,-927.7394), with the box farther west, **Y1740**
works for both crawl and butt slide: a **972-unit gap**. Its immediately
preceding binary32 height fails. This is a lower witness, not a global
minimum. At that exact alternative fixture, a separate check of every
integer Y1600–2000 finds working bands **1740–1795 for crawl** and
**1740–1794 for butt slide at speed 20**, with both endpoints included.
The exact represented coordinates, neighboring failures, phase
tests and wider placement searches are in the [height map](ink-height-map.md).
Nor is the largest starting Y the same concept as a largest reachable gap:
none of these high action states is yet produced by a complete allowed route.

## Why vertical universes do not repeat wholesale

The terrain query narrows coordinates to signed 16-bit values, but Mario,
actors and the warp retain their actual floating coordinates. At suitable
finite represented integer inputs, adding 65536 preserves the floor-query
integer. It does not shift the returned floor plane upward by 65536.

This helps the known +65536 case: Y67277 queries as 1741, then snaps to the
ordinary floor 768. The gap is 66509. The actor must actually be nearby at
the high coordinates. Top loading uses actual distance, walls use actual
coordinates after partition selection, and ceilings can return the unshifted
20000 sentinel. These facts prevent a blanket periodic handoff theorem.

The complete +65536 integer survey covers actual Y32768–98303 for each of
crawl and butt slide. Both work at **every tested integer Y67277–98303**
and fail the same two-update installer test at the other integers. Their
gaps in that band are **66509–97535**. Unlike the main universe, the band
has no middle hole in this setup. Adjacent-float checks give a working upper
sample **98303.9921875**, followed by failure at 98304; the float immediately
below 67277 fails. The two full maps total **262144 trials and 2459922
native updates**, before the separate variation and fresh-replay batches.

Representative positive offsets also work: **Y132813 (+2 VPUs), Y526029
(+8) and Y8390349 (+128)** all query as 1741 and complete useful handoffs
for both actions. Conversely, **Y−63795 (−1) and Y−129331 (−2)** have the
same integer alias, but an earlier death-related action leaves their raw
height at −11100; neither produces the handoff. These are tested cases,
not a theorem for all positive or negative offsets. Precision supplies
another concrete failure: requested Y16778957, or 1741+256×65536, rounds
to binary32 **16778956**, queries as 1740 and selects the static roof on
retry. Representable **16778958** queries as 1742 and succeeds, with an
observed gap of **16778190**. That is the largest useful gap sampled here,
not a global maximum.

The exact arithmetic is signed-16 narrowing of truncation toward zero of
the represented binary32 query input, within the supported integer-conversion
domain. Rounding and sign changes matter: -0.5 truncates to 0, whereas
65535.5 truncates to 65535 and narrows to -1. Even adding an exact integer
period is not a universal equivalence for fractional inputs across zero.
See the [VPU coverage and limits](ink-height-map.md) for the actual tested
offsets, successful and failing endpoints, and finite-search coverage.

## What still needs an allowed history

The earlier [landing and slide study](ink-top-slide-to-crawl.md) is useful
positive evidence for action entry: from its supplied exterior freefall
pose, the game lands and starts sliding without A. The
[walking-to-Z controls](ink-top-slide-to-crawl.md#braking-and-a-walking-alternative)
also produce crouch-slide followed by butt slide. But those observed
slides remain supported on the top. They do not yet supply the interior
or high-VPU position, low cache, push and phase needed here.

A new joined walking-to-Z test makes this distinction sharper. It first
supplies walking on a normal roof and lets one native input initialize
walking speed. It then supplies only the synchronized high position and
nearby box at phase 130, preserving the native walking action and speeds.
Z produces crouch-slide, the stopped-step gap and the useful handoff, both
at ordinary Y1741 and at Y67277. Thus the final slide action need not itself
be injected. The second high relocation is still supplied, so this is a
two-cut conditional witness, not a continuous approach from the low roof.

Another supplied transition mounts a shell and cancels with Z in the same
update, natively entering crouch-slide. Unlike the older two-update
mount/dismount test, the shell remains free and active in Area 1. This
creates a gap but leaves Mario over the low pad, so it does not capture
the top. The [slide report](ink-slide-handoff.md) records the distinct
interaction-status history; neither shell lifetime result establishes
delivery or a continuous high approach.

Remote sliding is a source path through landing-action cancellation before
the off-floor check. It is not an action available from arbitrary freefall.
A moving support or a landing transition must first put Mario in the relevant
action with the required cache and geometry. The new finite continuations
from the old native landing do not establish that combination. High HOLP
throws remain conditional item-delivery components; the high HOLP and
holding/release history still need to be reached.

The next focused experiment is to preserve an actually entered common
ground slide while a moving support or landing transition puts its feet
above a freshly queried low pad at the useful top phase, with a naturally
delivered actor. Record the last supported update and every subsequent
controller input. This directly targets the missing state transition;
another supplied large-height success would not answer it.

## What was checked

The two complete integer maps cover 262144 trials. The independent height
verifier freshly matches 145 retained records across 2184 updates (144
unique histories). The slide verifier freshly matches 93 selected main
trials across 2570 updates and all 14 entry cuts across 420 updates.
These replay counts overlap the searches; they are validation, not additional
independent discoveries. The overview and receipt interval counts were also
cross-checked separately.

Ubuntu WSL rechecked `sm64-item-proof`, Coq 8.16.1 and CompCert 3.15 with
the existing memory cap. New `InkSlideHandoff.v` is registered and exported
through `MainTheorem.current_ink_slide_handoff_boundary`. The selected
pipeline audit `20261113-015828-ma9zuzz8` passes: 717-source inventory,
build, hole checks, link hygiene, five assumption queries and zero integration
problems. It checks the three requested existing boundaries and the two new
slide/cast boundaries. See the [audit summary](ink-slide-source-proof-audit-summary.txt)
and [precise formal statement](ink-slide-source-proof.md). This checks a real
generated-code checkpoint and finite conversions; complete gameplay reachability
and the global route remain open. No bare `coqc` or whole-program reduction
was used.

## Provenance and route assessment

The initial fetch confirmed proof branch `codex/ssl-pyramid-item-proof` at
`c862841fcd6ddf00356029b45d5693772b309603`. The existing local earlier-entry,
top-slide and walking-edge studies were inspected and credited, then preserved
and pushed separately in commit `5858649` at the user's request. New experiments
do not replace their bounded negative results. Unrelated dirty files and
build outputs were preserved.

The sibling decompile is `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`, with
the documented local changes; the relevant stock comparison is
`9921382a68bb0c865e5e45eb594d9c64db59b1af`. Runtime experiments use the
existing authenticated **Wafel 0.8.5 JP DLL**, SHA-256
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`,
and the recorded 2548-input four-pillar prefix with its documented pre-entry
level-select setup. They are supplied-state native execution, not new
original-ROM replays, whole-memory equivalence proofs, or completed routes.
A later [three-action video](ink-vpu-three-actions-video-evidence.md) independently replays selected +65536 crawl, butt-slide and walking-to-slide cases in the original Japanese ROM, with horizontal failure comparisons. That follow-up does not convert these height scans into original-ROM scans or remove the supplied-state prerequisites.
The detailed records preserve source/runtime/input/script hashes and setup
ledgers. Nothing in this investigation changes the Pedro or Demo projects.

**Assessment:** the conditional Ink mechanism is stronger and no longer
depends specifically on crawl. Reachability of the joined position/action,
actor and timing remains open. Retain Rank 1 **1–2%** and Ink Rank 2 **<1%**,
with low confidence in numerical precision. These are subjective research
judgments, not measured probabilities or independent chances to add.
