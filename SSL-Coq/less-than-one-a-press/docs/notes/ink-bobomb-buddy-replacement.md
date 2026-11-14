# Can a black Bob-omb replace Buddy in the frozen-shell handoff?

14 November 2026. **Not as a direct replacement in the successful recipe.**
A black Bob-omb can shove Mario, and it has a demonstrated no-new-A transport
mechanism. But the Crazy Box and Bob-omb both use the same GRABBABLE handler.
When both collide in this update, the Crazy Box is processed first and the
Bob-omb does not supply Buddy's second shove. Buddy uses a different handler,
TEXT, which runs afterward. This is an interaction-order problem, not a claim
that a black Bob-omb cannot move Mario or that every useful route needs Buddy.

The newly tested direct replacements, low frozen-shell alternative and small
retimed menu produce no new useful handoff. The original Buddy positive still
works. A larger transported Bob-omb or a differently arranged multi-update
route remains an open possibility, with its actual size/lifetime history
required. The current result does not close that route family.

## What was checked

The starting checkout and fetched branch were both
`c1f31bff1365055745d08fdd2728ac501378c4df`. The applicable source is stock JP
pin `9921382a68bb0c865e5e45eb594d9c64db59b1af`, in decompile checkout
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`. Tests reuse the initialized shell
and native conditional fake-pickup/throw preparation from the
[cloned-shell study](ink-cloned-shell-investigation.md), with Wafel0.8.5,
Python3.9.13 and the existing JP DLL. Package manifests preserve exact hashes,
all setup writes, controller inputs and native snapshots.

| New test | Coverage | Result |
| --- | --- | --- |
| Frozen-shell Y19900 recipe, Buddy positive/omitted, Bob39/40 and small23 exact/near replacements, with/without first Box; two shell substitutions | 16 complete histories,567 independently matched boundaries | Only the Buddy control captures/retains the top and reaches the displaced spawn. |
| Low frozen shell stays near Mario after cancellation; no later shell relocation | Nine initial shell X/Z offsets around the corrected Y1810 air seed,324 matched boundaries | All mount and enter butt slide. Shell registers on the next update in seven cases and changes the Box-only trajectory in two; none captures the top. |
| Start the native slide one/two updates earlier; Bob and Crazy Box pushes on different updates | Ten air seeds,170 first Bob placements,523 later Box placements,1863 producer/acceptance screens;12 selected40-update continuations with480 matched boundaries | No capture in the finite screen; no completed producer with cached floor768 or gap over900; no useful arrival in the full continuations. |

The original1095-screen pilot overlaps the final1863 screens and is not added to the total. The completed-producer check does not assert that no intermediate floor query ever returned768; this harness has no per-query hook. Ten native seed boundaries also match independently.

The first two batches are in
[the direct replacement report](ink-frozen-shell-buddy-replacement.md).
The timing menu, selected verification and exact limitations are in
[the retimed-shove report](ink-bobomb-retimed-shoves.md). These are new Wafel
checks of the current frozen-shell setup, not new original-ROM replays.
The successful Buddy recipe was already reproduced on original JP in
[the preceding study](ink-shell-lower-boundary-rom.md). No Coq code changes
or new formal impossibility theorem are claimed here.

All actor positions and the initial airborne Mario/shell setup remain supplied.
The shell preparation itself includes the disclosed shell-box activation,
pickup-target retarget, low pickup pose and high HOLP. The old accepted prefix
uses debug level selection. Every input has A released; no held-A dependency
is used. There are no later Mario edits after the initial airborne cut.
These experiments isolate the contact mechanism; they do not join actor
transport to the Ink setup.

## Why the exact swap fails

The Y19900 recipe first creates BUTT_SLIDE with shell contact plus Z at
top phase128. Mario reaches the moving top at
`(-1920,1799.2869873046875,-1210)` while G initially retains Y19900.
Before129, the original recipe places Crazy Box49 and Buddy15; before130,
it moves Box49 again. G always means Stored Graphics (`gfx.pos`), not the
visible model or render matrix.

At Buddy's original position, a stock Bob-omb does not even register a collision:
its radius65 is smaller than Buddy's100. Moving the Bob-omb closer makes both
actors register, but the collision list contains Box49 before Bob39/40.
Mario's action-entry position and end-of-update position match the Box-only
control exactly. Removing the Box allows a genuine Bob-omb shove, yet the
unchanged subsequent Box placement still fails to produce useful displacement.

The source explains why changing pool slots is insufficient. Collision
detection visits GENACTOR (Crazy Box) before DESTRUCTIVE (Bob-omb and small
box). `mario_get_collided_object` selects the first matching type;
`mario_process_interactions` clears that type and invokes its handler once.
It does not iterate over another GRABBABLE object afterward. Freezing a clone
does not change its initialized interaction type. Even an already-interacted
first object does not make this pass try the second same-type object.

Relevant stock code: `object_collision.c:125–145`,
`interaction.c:403,616,1636,1722,1786`, and the object-list declarations in
`data/behavior_data.c:1834,3732,4850`. The earlier
[replacement source audit](ink-buddy-replacement-source.md) and
[live-shell replacement searches](ink-buddy-replacement-handoff.md) already
identified the ordinary same-pass problem; the new controls confirm it in
the actual frozen-shell sequence rather than claiming that prior result anew.

## Which substitutions remain plausible?

The [original-JP floor-query diagnosis](ink-floor768-diagnosis.md) corrects
the earlier explanation of the completed-cache failure. In its selected
retimed near miss, the final ground quarter **does find floor Y=768**.
It does not save that result: Mario's earlier geometry query has cached the
top at Y=1933.4923095703125, and the quarter's ceiling stop returns before
the cache assignment. Alignment therefore snaps Movement to that old top
height. The selected retimed history has no first Bob placement; it is a
Box-only control retained by the broader Bob/Box search, not evidence that
every failed history has this identical internal cause.

The successful Buddy control has the reverse order of local results:
its pre-interaction geometry query saves 768, then its shove and quarter
queries find static floor 1280. That quarter also stops before assignment,
preserving 768. Both use a real ceiling at 1523. Thus a destination query
returning 768 is insufficient; the cache-writing query must select it before
the productive stopped step. The next geometry target is the previous
update's endpoint and the next update's geometry query, including any
platform movement and wall correction, rather than just the final shove's
destination. These two new original-ROM traces diagnose the mechanism;
they do not construct actor delivery or a new Buddy-free handoff.

The loaded-mesh comparison narrows the next target further. At the successful
incoming query `(-2140.031982421875,1830.177978515625,-1115.0291748046875)`,
the top is just too high for the signed-integer floor query: its eligibility
threshold is 1831.11376953125, versus query Y=1830. Static floor 768 wins.
At the failed incoming query
`(-2168.8564453125,1889.0369873046875,-1036.69287109375)`, the top is eligible;
moreover, the static floor underneath is 1280. Lowering Y at that same X/Z
enough to reject the top would therefore still not produce 768. Both the
earlier horizontal endpoint and the top's height eligibility matter.

- A Bob-omb can replace the **grabbable role**, provided new geometry/timing
  supplies the intermediate state. It cannot simply add Buddy's independent
  same-pass interaction while Crazy Box remains selected.
- Consecutive-update pushes are allowed. The new small retiming menu fails,
  but does not cover every placement, starting pose, speed, input or actor size.
- A nonmounting shell has a different interaction type and runs before
  GRABBABLE. It can change the combined movement. The tested exact/near and
  low frozen-shell alternatives fail the useful-handoff test; this is not
  a global exclusion of shell-plus-Bob-omb arrangements.
- Small boxes share the same restriction as Bob-ombs. Existing enemy tests
  give damage, bounce, attack or twirl behavior instead of Buddy's preserving
  shove; those are not interchangeable contact effects.

## The transported Bob-omb is a different size

The new runtime replacements use ordinary initialized radius65/height113
Bob-ombs. The [actual expired-Bob transport witness](ink-bobomb-regrab-transport.md)
instead carries scale about1.4, radius91 and height158.2. An older conditional
hands-free/teleport experiment natively regrabs scale1.8, radius117 and
height203.4, but has additional supplied teleporter and later position/action
cuts. It must not be relabeled as the size established by the clean transport
witness. Neither enlarged profile was tested in the new menus.

Size cannot change the one-GRABBABLE selection rule. It can change whether
contact registers and how far a single selected Bob-omb pushes, so the present
geometry failures are not a proof against enlarged-Bob recipes. An ordinary
Bob-omb is HOLDABLE: pickup/release leaves its native behavior active, unlike
the frozen non-HOLDABLE shell. Throwing it to stored HOLP therefore does not
make its subsequent movement and fuse stop. Regrabbing can postpone explosion;
there is no justified universal151-update transport limit.

The known clean transport reaches about `(6909.080,-49.756,-738.317)` before
quicksand, not the Ink position. This is still a concrete reason to investigate
Bob-ombs rather than assume Buddy transport. The next focused experiment is
to use the actual enlarged, released/regrabbed Bob-omb profile for a new
single-pusher or consecutive-update arrangement, then verify fresh floor768,
accepted warp, top capture/retention and useful Area2 displacement. That test
must preserve its changing collision dimensions and live release behavior.

The no-new-A route remains open. The latest conditional frozen-shell/Buddy
success is unchanged, but none of these new substitutions removes Buddy from
that successful recipe. All45 subjective estimates remain unchanged,
including Rank1 **1–2%** and Ink Rank2 **<1%**; these are not measured odds.
