# Can another SSL Area 1 actor replace the pink Bob-omb?

The live Fly Guy did **not** replace the pink Bob-omb's extra sideways shove
in the tested native shell/Z/slide sequence. Of 4,200 placement/contact tests,
3,000 actually registered a collision with a Fly Guy or one of SSL's fire
variants. Slow contacts either knocked Mario back or left the box-only
trajectory unchanged; fast slide contacts killed the Fly Guy without the
needed extra shove. None captured the top on the acceptance update. All 66
selected full outcome-family histories agreed in a fresh reconstruction, and
none produced useful Area 2 displacement. This closes that finite substitution
test, not every way of using a Fly Guy. Its airborne twirl bounce remains a
separate possible predecessor, with no joined useful-handoff witness here.

The small box likewise fails as a direct replacement at the old Buddy placement.
It can push Mario when moved closer, but the two grabbable actors do not give
two additive same-update shoves in this fixture. The promising unanswered
variation is to start the native slide earlier and use the small box and Crazy
Box on different updates. That retimed three-actor search was **not run** in
this work. Nor was a FREEFALL/Fly Guy predecessor search run.

The earlier [native slide combination](ink-item-native-slide-combinations.md)
is credited as the starting fixture. The source review is in
[the replacement source note](ink-buddy-replacement-source.md); native pickup
and transport are separate work in
[the delivery note](ink-buddy-replacement-delivery.md).

## Scope, revisions and reproducibility

Tests used proof checkout `1222ab0ee82b870ba5efe1a8afd7f3ea7e78b1bf`, decompile
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`, the applicable JP code, Wafel 0.8.5,
Python 3.9.13, and the existing `build/wafel-pilot/sm64_jp.dll`. The underlying
stock-source reference used by the project is
`9921382a68bb0c865e5e45eb594d9c64db59b1af`. Runtime and source/helper hashes are
recorded in the [manifest](../../instrumentation/ink-buddy-replacement-handoff/manifest.json).
The runtime SHA-256 is
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
The durable 2,852-row controller prefix has SHA-256
`9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72`;
the shell fixture replays its first 2,548 rows to the four-pillar state and
then uses the existing neutral preparation. All input continuations keep A off.

These are **instrumented JP source-runtime tests**, not new original-ROM
replays. No proof or unconditional retail-game claim was added by this component
study. The exact write ledgers distinguish the initial supplied airborne state,
the actor-position cuts, and the deliberately supplied-ground controls.
There are no supplied `usedObj` or `heldObj` writes in these new scripts.

Run the verifier from `SSL-Coq/less-than-one-a-press`:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-buddy-replacement-handoff/verify.py
```

It passed: **196 full histories, 6,303 matched update boundaries**, plus the
separate seven five-update held-small-box probes and their preparation.
The [artifact README](../../instrumentation/ink-buddy-replacement-handoff/README.md)
lists archive contents and exact commands to rerun searches. All 4,200 Fly Guy
contact/producer/acceptance screens are preserved. The much larger shell/box
searches retain their menus, counts, selected screens, and independently matched
full histories, rather than claiming every screen had a long continuation.

## What the old Buddy was doing

The pink Bob-omb was useful because its NPC interaction supplied a second
horizontal correction while Mario continued the slide. It was not needed for
its color, animation, or ability to be held. This correction and the Crazy
Box's correction are processed as different interaction types. The difficult
question is finding a deliverable substitute that performs the needed correction
without canceling the ground action.

The positive control starts before top behavior update 128. Mario's supplied
M/C/stored-graphics position is
`(-1922.4404296875,1810,-1223.34130859375)`, action FREEFALL, forward speed 20,
velocity `(0,-16,20)`, yaw 0, action state/timer 0. The native shell is placed
ten units below. Z with a neutral stick makes the engine enter shell riding,
cancel it, and execute the grounded slide. No Mario fields are changed after
this initializer. The shell itself was spawned by the existing diagnostic
shell-box action-4 preparation at phase 125, not delivered by gameplay here.

Before 129, Crazy Box 49 is supplied at
`(-1990.710693359375,1799.2869873046875,-1280.710693359375)` and Buddy 15 at
`(-2054.455810546875,1799.2869873046875,-1208.867919921875)`.
Before 130, the same Crazy Box is relocated to
`(-2117.125244140625,1830.177978515625,-1128.1343994140625)`.
That later relocation is an additional grant, not a demonstrated item trajectory.

| Completed behavior update | M = C | Stored graphics Y | Action / floor / platform |
| --- | --- | ---: | --- |
| 128 | `(-1920,1799.2869873,-1210)` | 1799.2869873 | BUTT_SLIDE; top floor/platform |
| 129 | `(-2140.0319824,1830.1779785,-1115.0291748)` | 1799.2869873 | BUTT_SLIDE; top floor, platform cleared |
| 130 | `(-2210.0622559,768,-1075.1088867)` | 1830.1779785 | BUTT_SLIDE_STOP; fresh static floor 768 |
| 131 | `(-2210.0622559,1906.0351563,-1075.1088867)` | 1906.0351563 | DISAPPEARED; used warp 64, top floor/platform 61 |

The platform is retained through the warp and the control reaches Area 2 at
`(365.5927734375,5500,-1096.8026123046875)`, outside the ordinary arrival region.
Here and throughout, stored graphics means `gfx.pos`; it does not assert where
the render matrix drew Mario's model. A post-update snapshot's top timer is
one greater than the behavior update label in these tables.

## Direct replacements and retuned two-actor attempts

At the exact Buddy coordinates, small box 23, black Bob-ombs 39/40, shell 69,
Goomba 6, large breakable box 13, Fly Guy 38 and Klepto 54 all fail to reproduce
the handoff. The small box and black Bob-ombs do **not even register** at that
placement: their radii are smaller than the Buddy's. That is the first observed
failure there; the same-interaction-type limitation is a separate closer test.
Goomba, large box and Fly Guy do register in the exact-placement test but do
not supply the needed second sideways correction.

Closer controls place the candidate at `(-2000,1799.2869873046875,-1210)`.
Small box alone registers and changes the first result to
`(-2081.5534668,1823.4404297,-1237.9133301)`. With the Crazy Box also present,
both actors register, but Mario follows precisely the Crazy-Box-only result
`(-2059.1101074,1867.0308838,-1191.7894287)`. Black Bob-ombs behave similarly in
these controls. This agrees with one selected object per GRABBABLE interaction
type. The shell has a different interaction type and can change the combined
result, but its smaller push did not produce a capture in these cuts.

Two further finite inverse-placement searches retained the native airborne
shell/Z action constructor, removed the Buddy, and varied starting X/Z,
heading/speed, shell placement and box placements:

| Search | Air initializers | Native ground seeds | First actor cuts | Pad outcomes | Producer screens | Captures |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Coarse | 576 | 384 | 19,924 | 7,684 | 70,511 | 0 |
| Refined | 840 | 840 | 57,340 | 16,254 | 34,666 | 0 |

Their supplied initial Y is 21,700, but the native shell/Z/ground-step update
snaps Mario onto the real top near Y 1,800. These are not high-VPU ground-state
delivery demonstrations. The exact grids and eligible-action checks are in
`experiment.py` and the archived menus. They do not exhaust placements or
timings, and do not settle the untested two-grabbable retiming idea.

An illustrative near miss starts at `(-1900,21700,-1170)`, yaw 0, speed 20.
The supplied Box-129 position is
`(-1992.654052734375,1817.466796875,-1218.9549560546875)`; the shell remains
where native cancellation left it and there is no Box-130 relocation.
After 129 Mario is `(-2040.0279541,1848.2440186,-1123.0137939)`.
After 130 M/C are `(-2040.1751709,768,-1123.0865479)` and stored graphics
retains Y 1848.2440186. This **does create a gap and fresh floor 768**.
Nevertheless, on 131 the warp is accepted at
`(-2040.1751709,768,-1075)` with stored graphics Y 768 and no platform.
It reaches the ordinary Area 2 spawn `(0,5500,256)`. A gap and a warp are
therefore insufficient success criteria.

## Native Fly Guy tests

The tested actors are the actual initialized SSL Area 1 objects: Fly Guy 38
and the Fire Fly Guy variants 44/45. Only their XYZ positions are edited;
their behavior, parameters, interaction type, hurtbox, movement and attack
callbacks remain native. Their initialization/callback differences are preserved
in actor snapshots. The finite grid uses the old air seed with heading/speed
pairs `(0,0)`, `(0,20)`, `(0,64)`, `(0,120)`, `(16384,20)`, `(24576,20)`,
`(32768,20)` and `(57344,20)`. Fly positions are centered on the collision
position after 128, with radii 0/40/80/120, eight angles for nonzero radius,
and Y offsets -150/-100/-50/0/50/100/150. The old Crazy Box cuts are retained.

This is 4,200 tests. Every test runs native updates 129, 130 and 131. Of the
3,000 registered contacts, 675 change Mario's position through knockback;
1,125 fast contacts kill the Fly Guy and preserve the Box-only trajectory.
The remaining registered contacts also preserve that trajectory. The larger
supplied airborne speeds do not imply larger contact speeds: the native
initializer can bonk. The positive fast-contact controls instead use headings
16384/24576/32768, whose native slide speeds are approximately
26.8176785/28.4452801/27.4464054.

For an exact low-speed negative, use the old yaw-0/speed-20 initializer and
place Fly Guy 38 before 129 at `(-1920,1749.2869873046875,-1210)`:

| Update | M = C = stored graphics | Action | Floor/platform |
| --- | --- | --- | --- |
| 129 | `(-2053.3125,1829.6544189,-1228.9161377)` | BACKWARD_GROUND_KB | top 61 |
| 130 | `(-2181.3017578,1829.8710938,-1183.6658936)` | BACKWARD_GROUND_KB | top 61 |
| 131 | `(-2263.6262207,1852.6987305,-1089.0446777)` | BACKWARD_GROUND_KB | top 61 |

It never obtains the fresh low cache in this producer interval. The first exact
failure is that the contact selects knockback instead of preserving the slide.
The full 35-update continuation remains in Area 1.

For a fast negative, use initializer yaw 24576, speed 20, and place Fly Guy 38
at `(-1908.4697265625,1720.8570556640625,-1237.8359375)` before 129.
The native pre-contact slide speed is 28.4452801. The Fly Guy becomes inactive;
Mario stays BUTT_SLIDE, with M/C/stored graphics all
`(-2074.4077148,1805.8529053,-1254.3308105)` after 129. After 130 these are
`(-2186.8784180,1794.9055176,-1220.5258789)`, still on top 61. The missing
condition is the extra sideways correction into the pad setup; the trajectory
matches the no-Fly-Guy baseline exactly. It too stays in Area 1.

The source distinguishes this from an upstream bounce. In
`src/game/interaction.c`, `interact_bounce_top` at lines 1368–1403 handles an
attack, a hit from above, or damage/knockback; it has no Buddy-style fallback
push. A hit from above with the twirl subtype gives velocity 80 and ACT_TWIRLING.
That is an airborne action, not the ground action/alignment constructor we
need. A later landing followed by a usable slide remains a separate question.

## Diagnostic appendix: high actors can work after ground action is supplied

These controls answer downstream compatibility only. They deliberately grant
Mario M/C/stored graphics `(-1950,H,-939)`, a crawl or slide action, state/timer,
speed/velocity/facing and slide fields immediately before update 130. They
therefore cannot be presented as the requested action-entry solution.

For each `H` in `{1741,25000,67277,90536}`, crawl and butt-slide controls with
Crazy Box 49 at `(-1989,H,-939)`, small box 23 at `(-1974,H,-939)`, or black
Bob-omb 39 at `(-1979,H,-939)` all work: **24/24** captures and displaced Area 2
arrivals. Only actor XYZ is changed. After 130 M/C are `(-1882,768,-939)` and
stored graphics Y is H. The next update captures the top, retains it, and
reaches `(365.5927734375,5500,-1096.8026123046875)` in Area 2.

A separate 72-case menu uses the same four heights, crawl/butt-slide/dive-slide,
and native shell or supplied carry-script effects on shell, Goomba, large box,
Fly Guy and Klepto. The non-HOLDABLE carry-script controls preserve native
behavior and interaction type, but **supply** the clone-helper effects:
parent becomes Mario, the behavior command becomes `bhvCarrySomething5`, and
the behavior stack index is zero. Together with actor XYZ this is a collision-only
clone diagnostic, not a fake-pickup or cloning history.

Both native shell and supplied shell clone at `(-1971,H,-939)` work in all
12 action/height combinations each: **24 useful results**. Butt/dive slide can
end in GROUND_BONK while the common handler still reaches alignment and makes
the split. Goomba/Fly Guy/Klepto clones instead select damage/knockback here.
The large-box clone supplies no sideways push and does not capture the top.
No initialized Pokey body-part clone was fabricated for this menu.

These finite heights include positive VPUs but are not a formula valid for all
65,536 offsets. Native actor delivery, clone acquisition, Mario entry and timing
remain prerequisites. There is no route improvement just from granting them.

## A real pickup followed by conditional travel still fails earlier

The held-small-box probe replays the sibling delivery study's genuine 342-input
acquisition after its 500-input prefix; used/held slot 23 is produced by gameplay.
It then waits 20 neutral updates and supplies four Mario M/C/stored-graphics
XYZ travel cuts to pillar detector coordinates, allowing native callbacks to
start the top. A fifth travel cut places the still-holding Mario on a queried
top face. No action, velocity, floor/cache, HOLP, actor position or pickup pointer
is edited. Each travel cut nevertheless supplies nine positional scalars.

At phases 110/120/125/127/128/129/130, the five-update approach attempts all
enter HOLD_BUTT_SLIDE before the intended walking/Z drop. Z on the second
update does not release the object. It remains held, with raw world XYZ at
its spawn position while HOLP updates with Mario. This is a failure of the
tested HOLD_IDLE-on-slope predecessor, not an impossibility theorem for held
walking, pulsed uphill transport, or another release timing. The seven trials
and their preparation match fresh replay.

The alternative DIVE pickup shortcut also has a precise source obstacle.
`act_dive` runs an air step after an ordinary airborne grab; entering
DIVE_PICKING_UP requires AIR_STEP_LANDED. In `act_dive_picking_up`, the
INPUT_OFF_FLOOR check precedes INPUT_ABOVE_SLIDE and returns FREEFALL.
Consequently an unsupported dive grab alone does not establish the required
ground handler. A real supported landing or a different history still has to
be supplied by a route, not assumed. This is a source deduction; no new Coq
theorem for this branch was added in this component study.

The closest verified useful constructor remains the earlier conditional
shell/Buddy/Crazy-Box control. The best no-Buddy shell/box results reach an
ordinary warp after making a real gap. No newly tested replacement here joins
native action creation, actor delivery and useful displacement. The next most
direct experiment is the untested earlier shell/Z initializer with sequential
small-box and Crazy-Box pushes on distinct updates; the Fly Guy alternative
needs a separate native bounce-to-landing-to-slide predecessor.
