# Editor-preplaced pushers work before the shell mount

**Compatibility result only: editor placement of both pushers before the
shell mount works on the original Japanese ROM. This does not answer whether
Mario can place them.** With that supplied initial state, no later item
or Mario edits are needed to produce useful spawning displacement. The exact
actor coordinates from the earlier staged witness work unchanged. Moving
the two placement cuts earlier is enough; no compensating XYZ, new actor,
radius adjustment, fuse freeze or extra controller input is needed.

This removes the two post-mount placement cuts from the local handoff. It
does not demonstrate delivery of the actors, acquisition of the frozen shell,
or Mario reaching the high airborne start through a joined no-new-A history.
The user clarified that placement means Mario's actual pickup, carry and
release. That separate investigation is recorded in
[Mario's pusher delivery](ink-mario-pusher-delivery.md); a real Crazy Box
release has a different behavior action from this supplied free box.

## The supplied starting cut

Everything below is in place **before top behavior update128**:

| Participant | Actual starting XYZ | Other supplied/inherited state |
| --- | --- | --- |
| Mario | (-1960,19900,-1230) | FREEFALL, horizontal speed0, velocity(0,-16,0), yaw0; M=C=G initially |
| Initialized frozen shell71 | (-1960,19890,-1230) | Same conditional native fake-pickup/release preparation as the prior witness |
| Bloated black Bob-omb39 | (-2080.06005859375,1809.2066650390625,-1230.322021484375) | Same copied native released91 donor profile: radius91, fuse170; native behavior remains active |
| Crazy Box49 | (-2102.720703125,1839.447265625,-1119.5618896484375) | Existing live actor, including its inherited velocity and FAR_AWAY flag; only XYZ is placed |

Press **Z for update128, then leave every input neutral**. A stays released.
There are no further setup writes after that initial cut. The shell mounts
Mario and Z cancels riding into BUTT_SLIDE within update128; a ground action
is not written into Mario. The original-ROM write ledger contains95 scalar
writes including the earlier shell preparation and donor transplant, all
completed before the mounting update. The exported case has `cuts: []`.

## The full handoff still works

M is Movement, C is the Mario object's Collision position, and G is Stored
Graphics (`gfx.pos`), not the visibly drawn model or render matrix.

| Completed top update | M=C | G.Y | Result |
| --- | --- | --- | --- |
| 128 | (-1960,1809.206665,-1230) | 19900 | Shell mount/Z creates BUTT_SLIDE; top is the platform |
| 129 | (-2117.026855,1839.447266,-1113.008545) | 1809.206665 | Bob supplies the first shove; BUTT_SLIDE persists; platform clears |
| 130 | (-2200.001709,768,-1075.003906) | 1839.447266 | Fresh initial floor cache768, then Crazy Box shove; gap1071.447266 |
| 131 | (-2200.001709,1914.854980,-1075.003906) | 1914.854980 | Real low warp accepted; high-G floor retry selects/captures top61 |
| First checked Area2 | (365.5927734375,5500,-1096.8026123046875) | 5500 | Useful spawning displacement after observed top retention |

The original-ROM hooks directly record update130's initial query saving768.
The Box shove's separate validation query finds top1916.109863, and the
ground quarter finds1280. The underside ceiling1523 stops that quarter
before cache replacement; floor alignment therefore uses the earlier768.
The correct result is not inferred from the final gap alone: the replay also
accepts warp64, captures top61, retains it at every later observed Area1
boundary, and reaches the exact displaced arrival.

## Why preplacement does not spoil the sequence

The Bob's 4000-unit activity gate uses **Stored Graphics G**. After128,
G.Y is still19900 even though M/C have snapped down to1809.206665. The Bob
therefore stays at its initial position with fuse170 and radius91 during
that update. It gives the useful contact on129 before its subsequent native
callback advances the fuse and begins its explosion sequence. It is not
manually frozen.

The Crazy Box also stays at its placed XYZ during128 because its inherited
FAR_AWAY flag skips the movement helper. The behavior wrapper clears that
flag later in the update. During129 it moves normally to Y1852.87353515625.
That still overlaps Mario for the next contact. After the useful130 shove,
its callback moves it to Y1923.4852294921875; that later motion does not undo
the already-produced split.

The Box is about180.46 horizontal units from old Collision on129, outside
the112-unit combined radii. It therefore does not steal the Bob's
GRABBABLE interaction. On130 it is only15.74 units away and registers. The
two pushes still occur on different updates with ordinary interaction order.
The [source review](../../instrumentation/ink-preplaced-pushers/source-review.md)
records the exact functions, comparisons, object order and evidence scope.

## Controls, earlier placement and evidence limits

Four Wafel timing controls all succeed: original staged placement, both
actors before128, Bob-only early, and Box-only early. Their27 selected
Mario/contact boundaries agree, although the Box's own movement history
differs. All four were independently rerun from fresh roots. A separate
implementation reconstructs the both-preplaced result and independently
checks the initial768 query on an isolated, fully restored diagnostic fork.
That fork is not part of any accepted gameplay continuation.

Placing the profile and all three actors **one or two updates earlier**,
before127 or126, also works in Wafel. The intervening controls are neutral;
Mario remains at the earlier distant preparation position until the one
Mario-only air cut128. No actor is edited at that later cut. These are finite
waiting tests, not original-ROM confirmations of earlier waiting, arbitrary
wait-time guarantees, or delivered actor histories.

The original-ROM negative control places the Bob before128 but leaves the
Crazy Box at its original world position. It uses no later edits either.
It still makes fresh768 and the same vertical gap, but fails to capture the
top and arrives at **ordinary (0,5500,256)**. The Box is not deleted from the
world, and the Bob's later native nudge remains active.

The two new ROM runs compare50 observed boundaries against Wafel. All
compared M/C/G, action, floor/cache, platform, collision-list, actor position,
velocity, radius and fuse values agree. The full comparison retains50 known
global-clock offsets (`native+2 = Wafel`) and27 Box-subtype differences
(native2 versus Wafel0: two in the positive,25 in the omission control).
Subtype2 is DELAY_INVINCIBILITY; the named neutral butt-slide GRABBABLE
push does not read this bit. Its origin is not established here, and no
whole-memory equivalence is claimed. Native camera boundaries25/26 are
unavailable in each run. The useful and ordinary arrivals themselves are
direct original-ROM observations. The hooks record690/667 floor returns.

Work starts at proof commit `0605d842cedb55151e70952d56064553c4970f60`,
verified equal to the pushed branch before testing. Applicable JP source:
`9921382a68bb0c865e5e45eb594d9c64db59b1af`; local decompile:
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`. Wafel0.8.5/Python3.9.13
uses JP runtime SHA-256
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
The Ubuntu-24.04 original-ROM run uses Mupen64Plus/Rice2.5.9 and JP ROM SHA-256
`9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317`.

Reproducible packets: `instrumentation/ink-preplaced-pushers-controls/`,
`ink-preplaced-pushers-search/`, and `jp-ink-preplaced-pushers/`, alongside
the source review. They preserve inputs, writes, results, native traces,
checker discrepancies and hashes. No ROM or emulator binary is distributed.
No Coq theorem or new height window is claimed. The remaining joint route
still needs shell acquisition/delivery, the bloated Bob state and delivery,
the Crazy Box placement, high Mario entry and the correct top phase. The
historical film shows the staged version; this follow-up removes its two
later item edits. All45 subjective estimates remain unchanged, including
Rank1 **1–2%** and Ink Rank2 **<1%**.
