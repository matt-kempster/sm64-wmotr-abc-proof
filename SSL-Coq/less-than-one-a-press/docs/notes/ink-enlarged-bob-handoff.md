# An enlarged black Bob-omb replaces the Buddy in a useful handoff

**A native-sized enlarged black Bob-omb can do the missing earlier shove.**
The new conditional JP runtime sequence, now also replayed on the original
Japanese ROM, uses a frozen initialized shell,
one black Bob-omb, then one Crazy Box on the next update. It reaches the
fresh 768 cache, accepts the warp, captures and retains the spinning top,
and reaches exact useful Area-2 position
`(365.5927734375,5500,-1096.8026123046875)`. No Buddy is involved.

This improves the local handoff witness, not the complete controller route.
The shell/high airborne Mario and actor positions are still supplied. The
Bob's enlarged state comes from an actual separately replayed no-A history,
but its scalar state is copied into this fixture as an explicit diagnostic
grant. Transporting that Bob into this same timed setup is not demonstrated.

## The actual sequence

The airborne cut is immediately before top behavior update 128. Mario starts
at `(-1960,19900,-1230)` in FREEFALL with speed 0 and velocity `(0,-16,0)`;
the frozen initialized shell is ten units below, at `(-1960,19890,-1230)`.
Z is held only for update 128; all following controls are neutral. A is off.

| Completed update | M = C | Stored G.Y | Action | Floor/cache and platform |
| --- | --- | --- | --- | --- |
| 128: native shell mount then Z cancellation | (-1960,1809.206665,-1230) | 19900 | butt slide | top 1809.206665; platform 61 |
| 129: enlarged Bob contact | (-2117.026855,1839.447266,-1113.008545) | 1809.206665 | butt slide | top 1839.447266; platform cleared |
| 130: fresh initial cache then Crazy Box shove | (-2200.001709,768,-1075.003906) | 1839.447266 | butt-slide stop | static 768; no platform |
| 131: low warp accepted, high-G retry selects top | (-2200.001709,1914.854980,-1075.003906) | 1914.854980 | disappeared | top and platform 61, used warp 64 |
| Later Area 2 | (365.592773,5500,-1096.802612) | same Y | arrival | useful displaced spawn |

M means movement, C the Mario object's collision position, and G stored
graphics `gfx.pos`, not the render matrix or visible model pose. Heights in
the table are update-boundary values, not a claimed working interval.

The two later actor XYZ cuts are exactly:

- Before update 129, native black Bob slot 39:
  `(-2080.06005859375,1809.2066650390625,-1230.322021484375)`.
- Before update 130, Crazy Box slot 49:
  `(-2102.720703125,1839.447265625,-1119.5618896484375)`.

No actor is deleted to clear the second collision pass. Both Box and Bob
are still in Mario's collision list on update 130; normal list/type handling
allows the Crazy Box's GRABBABLE interaction and suppresses another same-type
push in that pass. The useful pushes occur on **different updates**.

## Why this reaches the missing cache condition

After the Bob shove Mario is already over the 768 pad before update 130's
initial geometry lookup, at
`(-2117.02685546875,1839.447265625,-1113.008544921875)`, with no platform
displacement pending. The isolated cache diagnostic selects static 768.
The original-ROM hook directly confirms that initial query returns 768.
The real normal-action producer also finishes with cache 768 and the needed
stored-G/movement split; the following normal updates capture and retain the
top and produce the exact displaced spawn.

That directly addresses the failure diagnosed in
[the prior floor-cache report](ink-floor768-diagnosis.md): a final shove
cannot repair an earlier high cache when the ground quarter stops without
committing its local floor. Here the Bob changes the preceding update's
endpoint so the initial query is useful first; the Crazy Box then supplies
the final horizontal displacement needed for the retry/warp geometry.
In this new positive, the Box validation query returns top height
1916.10986328125, while the first ground-quarter query returns static 1280.
The native quarter stops with result 2 against the dynamic top underside
at 1523, preserving the earlier cache 768. These later local results are
distinct from both the initial cache and the previous Buddy control.

The isolated diagnostic temporarily uses DISAPPEARED on a fork, then restores
the entire original save state. It matches both previous original-JP hooked
controls and is independently checked here; it is not a substitute for the
normal-action history or a proof that all actions have identical queries.

## The enlarged Bob is a real native profile, with a live fuse

The existing no-A Bob regrab donor reaches a held radius-91 Bob after 616
controller updates. Twelve neutral updates later, native code releases it
with radius 91, height 158.1999969482422, scale approximately 1.4, fuse 170,
free held-state, action 0 and timer 0. This donor replay has no A input and
no supplied hitbox. See
[`ink-enlarged-bob-profile`](../../instrumentation/ink-enlarged-bob-profile/).

Before the receiving fixture's high airborne cut, the diagnostic copies 32
exact fields (34 scalar components, including the three-component scale
vector) from that native boundary into the existing SSL Bob39.
This includes its native scale, hitbox, fuse and action/timer; every copy is
logged. Behavior, script command, home/XYZ and allocated slot are retained;
interaction type/subtype are checked unchanged rather than overwritten.
This is a **conditional profile transplant**, not an already-joined delivery.

After the first high shell update Bob is still far away and retains radius
91. The update-129 collision uses that radius. Its actual callback then
selects exploding action, timer 0; after update 130 its native radius becomes
65, then 78 after update 131, and it later grows/deletes normally. The test
does not freeze the fuse, lifetime, behavior or scale to preserve the witness.

## Controls and limits

The target study tried four direct Bob proposals and 21 final-producer
placements before finding the positive. These are observed finite results,
not a universal minimum size, position or height claim. An independently
repeated eight-case control set uses the same positions unless stated:

| Control | First missing condition / observed outcome |
| --- | --- |
| Omit Bob129 | Producer initial cache remains on top; no warp/capture |
| Stock radius-65 Bob at the exact positive position | No Bob129 contact; no useful handoff |
| Stock Bob moved closer by three tested distances | Bob129 contact registers, but producer initial cache remains on top; no useful handoff |
| Omit the final Crazy Box | Fresh 768 and low movement occur, but ordinary warp gives `(0,5500,256)` without top capture |
| Native terminal radius-117 profile at the same positions | Fresh 768 occurs, but the changed shove geometry gives ordinary `(0,5500,256)` arrival without top capture |

The independent cache diagnostic gives 1882.8935546875 for the closer
stock-Bob 100-unit control, versus 768 for the positive. Thus the positive
is not merely a collision that the stock Bob could duplicate unchanged;
nor does every larger Bob or every fresh-768 split automatically succeed.
These controls do not exclude different stock-Bob or larger-Bob placements.

## Evidence, supplied state and remaining route work

The search and controls use Wafel 0.8.5 / Python 3.9.13 with authenticated
JP runtime SHA-256
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
Work began at proof commit `32f5eb4d5911b2e0a7972b748065c71ebe016717`;
the applicable JP source pin remains
`9921382a68bb0c865e5e45eb594d9c64db59b1af`, local decompile
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`.

The direct target packet independently verified the positive from fresh
roots. `ink-enlarged-bob-handoff/export_positive.py` reconstructs it twice
again, matching all selected prior states, events, inputs and edits exactly.
Its control diagnostic independently matches all eight control histories.
The wider earlier-frame search proposed before this discovery was **not run**.
No Coq theorem or global route impossibility is claimed by these experiments.

The receiving setup still grants shell-box activation, low shell-pickup
preparation, a fake-pickup `usedObj` retarget, high HOLP, the Bob profile
transplant, initial high FREEFALL M/C/G and velocity, shell XYZ and both
later actor XYZ placements. The frozen shell is initialized by its real
native behavior before fake pickup/release; it is not made mountable by
inventing its interaction type. No Mario edits follow the initial high
airborne cut. Full ledgers, seeds and controls are in the linked packets.

The next route question is joining these ingredients: retain/deliver the
enlarged Bob until the needed contact, deliver the initialized frozen shell,
reach the high airborne Mario approach, and have the Crazy Box in place at
the correct top phase. The positive demonstrates that the Buddy's local
job can be done by a black Bob; it does not yet supply those histories.

The [original-JP replay report](ink-enlarged-bob-handoff-rom.md) records two
completed ROM runs: the positive and the control omitting the final Crazy
Box. Each matches 25 selected Wafel boundaries in the physical fields,
retaining its 25 known raw global-clock differences (`native+2 = Wafel`).
Two camera observations per run are unavailable during the area transition;
this is not a full-memory comparison. The hooks record 682/665 native floor
returns respectively and confirm initial cache 768 in both producers.
The positive captures/retains the top and reaches the exact useful spawn;
the control reaches ordinary `(0,5500,256)` without capture. That control
still contains the live Bob and its native interactions; it omits the Crazy
Box placement, not every possible later push.
