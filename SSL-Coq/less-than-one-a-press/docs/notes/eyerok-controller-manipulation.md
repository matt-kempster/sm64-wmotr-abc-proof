# Manipulating Eyerok's hands with controller movement

## Result

Mario can meaningfully manipulate Eyerok's hands without writing game memory.  His position can start and hold an alternating double-pound loop, deterministically request the tracking-hand attack, steer that tracking hand, choose whether and which way a grounded hand sweeps, place the two-hand formation along a 1,200-unit Z band, and prolong the other hand's exposed-eye window.  A paired authenticated US retail suffix now confirms the most useful deterministic recipe in live play after an ordinary Area-3 entry: Mario wakes Eyerok, returns to the target strip, releases the chase, and requests both sweep signs with zero A polls and no post-boundary memory writes.  Movement cannot directly choose the left or right hand, cannot force fist-push independently of RNG, and cannot control the positive double-pound formation's left/right random bit.

This is not a complete route.  The live receipt starts only after disclosed fixture-assisted Area-1/Area-2 travel has delivered an ordinary Area-3 entry, and its two sweeps are finite samples rather than an exhaustive analog-input search.  The state-machine companion is [`EyerokControllerManipulation.v`](../../proofs/EyerokControllerManipulation.v); the live suffix, geometry bounds, and non-boarding result are checked in [`EyerokControllerReachability.v`](../../proofs/EyerokControllerReachability.v), with the reproducible probe under [`instrumentation/eyerok-controller-gates`](../../instrumentation/eyerok-controller-gates/).

## Live deterministic chase and sweep receipt

The paired probe accepts only the hash-authenticated North-American ROM.  Before Area 3, its inherited harness discloses the shortened travel writes; after the live boss and both hands exist in Area 3, the input plugin performs no memory write and supplies only analog-stick input plus thirteen B polls needed to advance Eyerok's mandatory intro dialog.  It never polls A.  Both runs share one chronology: Area-3 boundary at timer `363`, boss wake at `560`, target-strip arrival at `603`, retail `TARGET_MARIO` selection at `903`, `SMASH` at `952`, and `FIST_SWEEP` at `981`.  Selection occurs at Mario Z=`-2998.542969` with the hand at Z=`-3393`, so it is inside the RNG-independent strip, and the released chase reaches hand-pivot Z=`-1970.731445`.

The two sweep placements answer different questions.  A front-biased positive-X sweep starts with Mario grounded at `(921,-1534,-1889.765137)`, the closest observed grounded sample to the tunnel, but X=`921` is already at the arena edge and Mario is falling by timer `1020`.  The mirrored negative-X sweep starts at `(602.704895,-1534,-1897.535522)`, stays on the ordinary arena floor, and moves Mario more than `1,232` units in X after his stored forward speed reaches zero; its Z effect is the wrong sign, ending `133.265625` units farther from the warp.  Across both complete receipts the hand is Mario's floor owner on zero frames and his cached platform on zero frames.  The large lateral change is therefore a bounded moving-hitbox/collision displacement, not a hand ride or conserved-speed source.

The source geometry explains why the favorable frames do not become a route.  `TARGET_MARIO` stops after the hand crosses boss Z plus `1700`; allowing one final full `50`-unit movement gives the conservative pivot cap Z=`-1943`.  Even the already-proved loose `459`-unit transformed-mesh allowance ends at Z=`-1484`, behind the tunnel's nearest Z=`-1222`.  Vertically, the closed tracking top is Y=`-928`: it is `606` above the flat arena floor, so a Mario standing there cannot acquire it through the ordinary `78`-unit upward floor-query allowance, yet it is still `288` below the minimum Y=`-640` from which the tunnel floor can be queried.  Once the hand grounds for a sweep, its top falls to Y=`-1228`, `306` above the arena floor, and remains equally unboardable from that flat support.

This closes the tested deterministic target-to-smash-to-sweep suffix as a direct hand route.  It does not prove that every legal analog schedule has the same endpoint, derive the fixture-assisted pre-Area-3 travel from controller input, or exclude a separately constructed airborne/raised Mario predecessor, a dynamic intermediate support, RNG/timing control of `FIST_PUSH`, or the already-isolated vertical-speed seed of at least `32`.  Any renewed counterexample needs one of those additional mechanisms; the Z gates and sweep sign alone supply neither the height nor a forward speed transfer.

## Coordinate map

The Area-3 boss is at `(0,-1534,-3693)`.  Each hand is spawned with home Z `-3393`; the right hand (side `+1`) has home X `-500`, and the left hand (side `-1`) has home X `+500`.  The source uses the same helper—“is Mario less than 400 units in front of this object's home Z?”—from two different current objects, creating two different world-space gates:

| Current object | Source test | World-space result |
| --- | --- | --- |
| Boss | `Mario Z - boss home Z < 400` | `Mario Z < -3293` |
| Hand | `Mario Z - hand home Z < 400` | `Mario Z < -2993` |

That 300-unit discrepancy is the most useful controller lever.  In particular, `-3293 <= Mario Z < -2993` is far enough forward to avoid the boss's near-field double-pound choice but still “near” for the selected hand, which forces its `TARGET_MARIO` branch regardless of the random bit.

## Practical control recipes

### Force a tracking hand, then release it into a chase

Wait for an ordinary single-hand selection with Mario in `-3293 <= Z < -2993`.  The chosen hand must enter `TARGET_MARIO`; RNG cannot turn that selection into `FIST_PUSH`.  Do not remain behind the hand-relative gate, because `TARGET_MARIO` uses the same hand test as an immediate stop condition.  The clean handoff is to stand near `Z=-2994` for selection and move to at least `Z=-2993` before the hand next evaluates its target handler.  The formal witness uses only two units, from `-2994` to `-2992`.  From there the hand accelerates toward speed `50`, turns toward Mario by up to `4000` angle units each update, and raises toward home Y plus `300`, so live X/Z movement can kite it.

The chase stops if Mario goes behind the hand, the hand gets more than `1700` Z units ahead of the boss, its X separation from the boss exceeds `900`, it hits a wall, or Mario returns below `Z=-2993`.  A central initial witness—Mario `(Z=-2992)`, hand `(X,Z)=(-500,-3393)`, boss `(0,-3693)`—violates none of those stop conditions.  Because surface objects update before Mario in the standard schedule, a real input movie must put the threshold crossing on the correct player update; standing forever in the deterministic strip merely selects target and then makes it stop.

### Start, hold, and release alternating double pounds

When the boss is free to schedule a new attack, put Mario below `Z=-3293`.  This makes the boss start its negative double-pound counter at `-8`.  Remaining below that gate prevents the counter from advancing, so the boss continues alternating selected hands instead of counting out the attack.  Moving to `Z>=-3293` releases it; eight eligible boss updates advance `-8` through the negative values and then to the retreat marker `1`.  This gives controller control over the loop's duration, although actual launch, landing, boarding, and boss-lock timing still come from the hand state machine.

### Choose a tracking-smash sweep

Kite a tracking hand to a useful place and let one of its stop conditions send it to `SMASH`.  After the hand has landed, Mario can request a sideways sweep by standing within `300` units and between 45 and 135 degrees from the hand's facing direction.  Standing on one side makes the stored sweep yaw `+0x4000`; standing on the other makes it `-0x4000`.  If Mario is outside that distance/angle window, the hand retreats instead.  Once `FIST_SWEEP` begins, it no longer tracks Mario: the chosen direction and existing position determine the motion, and it retreats when it gets within `1000` Z units of the boss or reaches an edge.

### Choose a fist-push sweep direction and length

Outside the hand-near region (`Z>=-2993`), a selected hand chooses `TARGET_MARIO` when the random bit is odd and `FIST_PUSH` when it is even.  No Mario position can force fist-push for both random outcomes, because an odd random bit always selects target.  If fist-push occurs, Mario's X position first gives the push an `+/-0x800` yaw bias.  After timer `5`, the hand converts to a sweep when it passes Mario in Z or hits an edge.  Mario can therefore affect how long it pushes by staying ahead in Z and can choose the sweep sign by being to the right or left of the hand at that transition.

### Place the positive two-hand formation in Z

With both hands alive and Mario at `Z>=-3293`, every sixth new boss cycle can start the positive two-hand formation.  The boss snapshots Mario's Z and clamps it to `[-3293,-2093]`; any Mario Z already in that band becomes the hands' exact target Z.  This is direct 1,200-unit longitudinal placement by movement.  The lateral formation is not fully controller-controlled: RNG chooses a sign, after which the two hand targets are `boss X + 400*sign - 180*side`.

### Control which ordinary hand is active—but only by cycle timing

Ordinary single-hand attacks use the boss cycle-counter parity.  Odd counter values select side `+1`, the right hand at X `-500`; even values select side `-1`, the left hand at X `+500`.  Mario movement does not directly overwrite this choice.  Movement can instead delay an ongoing attack, release a negative loop, or wait through cycles so that the desired parity is current.  A positive sixth-cycle formation rewrites the counter from RNG, so parity after that event is no longer predictable from movement alone.

### Prolong the exposed eye and influence one-hand travel

During an ordinary two-hand attack, the nonselected hand opens its eye and keeps the boss eye lock while the active hand works.  Kiting the active hand therefore prolongs the other hand's exposure.  A hit is accepted only when an attack has been registered and Mario lies within 67.5 degrees of the hand's front (`abs(angleToMario-faceYaw) < 0x3000`).  The first two accepted hits take the nonlethal rise; the third takes the death rise.

With only one hand left, finishing `OPEN` captures the hand's angle to Mario, clamps it to `[-0x3000,+0x3000]`, and starts forward speed `50`.  Mario's location at that exact transition therefore chooses its initial trajectory.  After timer `10`, moving behind the hand in Z makes it stop; staying ahead prolongs the pass until an edge.  Later movement does not continually retarget this one-hand `SHOW_EYE` travel—the yaw was captured at open completion—although Mario still controls attack eligibility and the pass/stop relation.

## Frame-order constraint

The active hand loop first updates floor and walls, runs the current action handler, records `obj_check_attacks`, moves with `cur_obj_move_standard(-78)`, and finally reloads the collision model.  Consequently a collision registered this update is consumed by `eyerok_hand_check_attacked` on the next `SHOW_EYE` handler update.  Controller timing must target that delayed consumption, not assume the eye reacts in the same handler invocation.  The source-order receipt is checked for both selected US and JP generated Clight units.

## What is and is not promising

The strongest deterministic movement-only primitive remains the narrow `Z=-2994` selection followed by a small forward crossing: it removes RNG from choosing `TARGET_MARIO` while still permitting the chase on the next handler update.  The paired receipt now shows that a no-A controller suffix reaches that sample and both sweep signs, but its best observed forward placement falls from the arena edge and its grounded mirror pushes backward in Z without boarding or retained speed.  The best duration primitive remains the `Z=-3293` boss gate, which holds or releases an alternating double-pound schedule.  The remaining promising questions now require an added mechanism—a raised predecessor, dynamic support, stronger departure seed, or separately controlled fist-push—not merely another use of the deterministic gate.  None of these state-machine controls by itself creates unbounded height, arbitrary speed, arbitrary hand selection, or a target-star collection.
