# Actual release compatibility from supplied carrying states

**Both native releases can precede the handoff and still give useful displaced
spawning, including from a supplied airborne entry at Y1810.** A Y19900 entry
is no longer required by this controlled recipe. This is a compatibility
witness. The carrying states,
held references, remote HOLP values, enlarged Bob profile and subsequent high
Mario entry are supplied; Mario has not reached or delivered them through one
controller history. The strict no-write delivery attempts are separately
recorded in [the Bob transport package](../bob/README.md).

The joint test composes the native Crazy Box release from
[`controlled-box/check.py`](../controlled-box/check.py) with the enlarged Bob
release in `test.py`. It starts from the established conditional frozen-shell
root, before spinning-top update126. That root retains its prior shell spawn,
fake-pickup-reference and high-HOLP grants; the root is not a controller-reached
shell-delivery history.

## The successful joint sequence

1. **Before126, supplied carrying setup.** Mario is at `(5900,1920,3440)` in
   `HOLD_FREEFALL`, holding Crazy Box49. HOLP is supplied at
   `(-2102.720703125,1920,-1119.5618896484375)`. The frozen shell71 is supplied
   at `(-1960,19890,-1230)`. No Crazy Box XYZ is directly written here.
2. **Z126 actually drops the Box.** Its native release callback raises its
   origin to `(-2102.720703125,1933.43212890625,-1119.5618896484375)` using the
   actual floor query. The Box is far from Mario and retains the far-away flag.
3. **Before127, a second supplied carrying setup.** Mario is changed to
   `HOLD_IDLE` at `(5900,1809.2066650390625,3440)`, with held/used Bob39 and the
   expired-Bob drop-status bit. The Bob's scalar profile is copied from the
   actual native held91 donor after616 no-A inputs. Its initial carried XYZ is
   supplied near Mario. HOLP is supplied at
   `(-2080.06005859375,1809.2066650390625,-1230.322021484375)`.
4. **Neutral127 actually drops the Bob.** Mario's held reference clears and
   the actor's origin becomes the supplied HOLP X/Z with Mario's actual
   movement Y. At this remote position, Bob's distance-gated callback does not
   yet run: it remains `HELD_DROPPED=3`, radius91 and fuse158 through128. This
   is a pending native dropped state, not a completed free-actor callback and
   not a carry-script clone.
5. **Before128, Mario-only high entry grant.** Mario's M/C/G and freefall
   fields are supplied at `(-1960,19900,-1230)`, velocity `(0,-16,0)` and speed0.
   Z128 mounts/cancels the frozen shell and reaches `BUTT_SLIDE`. There are no
   more gameplay state edits after this cut.
6. **129–131, native shoves and handoff.** Bob nudges Mario on129 before its
   native drop callback completes. The Box nudges Mario on130 before its own
   native deletion. The low-collision warp and high stored-graphics retry
   accept the warp and capture/retain the top. Area2 arrival is exactly
   `(365.5927734375,5500,-1096.8026123046875)`.

No field of the Crazy Box is edited after its126 release. No Bob field is
edited after its127 release. The two separately supplied carrying setups are
not claimed to be successive player-reached states.

| Completed update | Mario M | Stored G.Y | Box state | Bob state |
|---|---|---|---|---|
|126|(5900,1940,3440)|1940|Y1933.432129, active259/far-away|Original world actor, not yet granted held91|
|127|(5900,1809.206665,3417)|1809.206665|Y1933.432129, active259/far-away|Y1809.206665, held-state3, fuse158|
|128|(-1960,1809.206665,-1230)|19900|Y1933.432129, active257|Y1809.206665, held-state3, fuse158|
|129|(-2117.026855,1839.447266,-1113.008545)|1809.206665|Y1929.432129, active257|Native drop completes: Y1830.302856, free0, fuse159|
|130|(-2200.001709,768,-1075.003906)|1839.447266|Nudge already processed, then native deletion|Free0, fuse160|
|131|(-2200.001709,1914.854980,-1075.003906)|1914.854980|Inactive|Free0, fuse161; top61 captured|

M is movement position, C is collision XYZ, and G is stored `gfx.pos`, not
where the visible model was drawn. Full M/C/G, actor, cache, action and collision
data are retained in `joint-results.json.gz`, including every setup edit.

## Two useful negative controls

Moving the **supplied Bob carrier** near the destination for127 changes
timing. At `(-2200,1809.206665,-1075)`, the carrier wakes the already dropped
Box earlier. It falls on128, then deletes on129 before the required130 shove.
The Bob still supplies its129 shove; Mario still reaches cache768 and a gap;
the warp goes to ordinary `(0,5500,256)` with no top capture. This is a concrete
reason a close carry/release schedule cannot simply replace the remote one.

The remote-carrier omission control retains the original Crazy Box at its
world position and performs the Bob release. It also reaches ordinary
`(0,5500,256)`. The actor is not deleted by a tool; its useful release is omitted.

The preliminary `test.py` has a separate positive: a nearby actual Bob drop127
with a once-preplaced Box before128. The Bob's native floor correction raises
it from intendedY1809.206665 to1823.038696; that still permits useful spawning.
Its two cases named `kind='throw'` are **requested throwing-state controls, not
successful throws**: native `INPUT_OFF_FLOOR` cancels `THROWING` into freefall
and drops the actor before the timer7 throw call. Their HOLP was offset for a
throw, so the actual drop goes to Z−1262.322021 and both fail. This finite result
does not prove all enlarged-Bob throws impossible.

## Lower entry: Y1810 also works

`lower-joint.py` changes only the initial shell placement and the supplied
Mario entry to the corrected lower coordinates:

- Mario before128: `(-1962.4404296875,1810,-1243.34130859375)`, FREEFALL,
  velocity `(0,-16,0)`, speed0, Z128.
- Frozen shell: the same X/Z atY1800.
- Both carrying setups and actual releases126/127: unchanged.
- The successful Bob HOLP: the original X/Z, with no compensation.

This lower entry also produces the exact useful spawn. On128, Mario's M/C/G
all become `(-1960,1809.2066650390625,-1230)` in BUTT_SLIDE. There is no need
for a large initial graphics gap at this update. The pending Bob drop callback
now runs on128 and raises the actor toY1867.130615234375; its unchanged X/Z
still gives the required129 shove. Mario's129–131 endpoints and the130 producer
gap match the high-entry positive: M/C.Y768, storedG.Y1839.447265625, gap
1071.447265625. Top capture and retention still follow.

A focused control substitutes Bob HOLP X/Z
`(-2079.9365234375,-1233.3045654296875)`, the compensation that works for the
parent's separately preplaced **free-patrol** lower fixture. It fails in this
**pending-drop** fixture: a drop callback does not make the earlier patrol
displacement being compensated. Mario reaches130 at
`(-2184.69921875,768,-1050.797607421875)` with the same vertical graphics gap,
but misses top capture and arrives at ordinary `(0,5500,256)`. Both lower
controls were reconstructed twice; this is a pair of tested points, not a
height interval or a universal X/Z restriction.

The lower input removes the need to connect these releases toY19900 in this
particular recipe. It does not establish that a player can reach the supplied
FREEFALL/shell arrangement at1810, the remote carrying states nearY1800–1920,
or their distant HOLP values in the required sequence.

## Reproduction and native-replay inputs

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-mario-pusher-delivery/controlled-bob/test.py --verify
& build/wafel-pilot/python/python.exe instrumentation/ink-mario-pusher-delivery/controlled-bob/joint.py --verify
& build/wafel-pilot/python/python.exe instrumentation/ink-mario-pusher-delivery/controlled-bob/lower-joint.py --verify
```

The three scripts reconstruct every case twice from fresh roots and compare exact
recorded data. All controls and interpreted Mario input flags are checked for
no A. Native actor type, behavior, callback, fuse, growth, floor correction and
deletion remain enabled after each disclosed setup. The held scalar profile
grant copies exact native donor values; it does not turn the receiving state
into a continuously transported actor.

The high joint replay exports are `joint-positive.json` and
`joint-no-box.json`; the lower positive is `lower-joint-positive.json`.
They contain phase126 `initialEdits`, phase127 carrying
cuts, phase128 Mario-only cuts, controls, and all expected rich boundaries.
Pointer-valued writes use explicit `gObjectPool[39]` / `gObjectPool[49]` names
rather than transplanting host memory addresses. Their original-ROM validation
is a separate parent-owned package; these files alone establish only Wafel
evidence. No Coq statement or proof is added.

This does not explain how Mario reaches the remote carrying Y values, retains
the remote HOLP, obtains the two holds in that order, delivers the frozen
shell, or reaches the lower supplied airborne approach. Those remain route
obligations. Actor release and Mario's airborne approach are different tasks.
