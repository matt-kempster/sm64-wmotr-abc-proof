# Can an earlier top capture wait for the explosion?

**The tested controller inputs cannot delay the already accepted warp.**
An artificial countdown extension can make a smaller supplied gap useful,
but no gameplay mechanism producing that extension was found. These are
different results: the timing repair works in some edited diagnostics;
ordinary inputs do not supply that repair.

## Controller-only continuations

The native JP experiment replays the existing no-A four-pillar prefix and
waits for the real top to reach phases 0, 60, 100, 120, 124, 126, 128, 129,
130 and 131. For each phase it uses the six low poses from the earlier phase
sweep. A single initial setup supplies Mario's nine movement, collision and
display coordinate words: movement/collision at the low pose, display at the
same X/Z and a raised Y. No action, floor cache, platform, timer, top, actor,
RNG or allocation state is changed in this setup.

For each of the 60 phase/pose recipes, the script measures the top floor
with a high query, then checks three nearby integer display heights. The
chosen height captures the top; one unit lower fails. These are local sampled
thresholds, not a global minimum gap. Every tested capture has disappeared
action, action argument `0x40001`, used object 64, floor owner 61 and platform 61.

After that first capture, **only controller pad writes are allowed** by a
wrapper. The 99 suffix policies include eight held-button combinations at
nine stick directions, 23 single Start pulses, three periodic Start patterns
and an alternating all-button pattern. A is absent, and native A-held and
A-pressed fields are checked on every advance. These yield:

| Result | Count |
| --- | ---: |
| Complete controller suffix trials | 5,940 |
| Native updates in those trials | 142,560 |
| Timing histories identical to the neutral twin | 5,940 |
| Trials that entered pause after capture | 0 |
| Useful arrivals from phases before 131 | 0 |
| Useful arrivals from phase 131 | 594 |

Every trial reaches its first Area 2 sample on update 24, counting the initial
capture as update 1. Matching timing means matching the recorded level/area,
play mode, delayed-warp operation/countdown, transition, Mario action/argument
and top active/action/timer fields. It does not mean every byte, camera field
or input flag is identical.

A second menu tests **all 8,192 subsets of the 13 recognized non-A buttons**
at nine stick positions, at two reached checkpoints of the phase-130 east
capture: after capture update 1 and after update 12. All 147,456 one-update
trials match the corresponding neutral timing projection. This enumerates
neither every analog value nor every multi-frame input history.

A pre-capture pause control starts from the unedited distant Mario context
at phase 128. Start allows one normal update, then pauses at top timer 129.
The top stays at 129 through all 32 paused observations. Start resumes normal
play, after which the top advances again. Pausing therefore does not give the
top extra updates relative to the warp. It is distinct from the rejected
postcapture Start presses.

## Why normal inputs do not buy another update

The source explains the observed fixed timing:

- `interaction.c:855–899` changes accepted upper-warp contact to
  `ACT_DISAPPEARED` with argument `(WARP_OP_WARP_OBJECT << 16) + 2`.
- `mario_actions_cutscene.c:430–441` decrements that argument and schedules
  the warp when its low half reaches zero. This action has no ordinary
  controller-dependent waiting branch.
- `level_update.c:229–239` rejects pause when Mario is intangible, a warp
  transition is active, or a delayed warp is pending. Disappeared is already
  intangible on the capture update, before the delayed warp is queued.
- `level_update.c:722–837` initializes a 20-update object-warp countdown
  only when no delayed operation is pending. Repeated requests do not reset it.
- Normal play updates objects and then decrements the countdown
  (`level_update.c:986–1037`). The ordinary change-area transition does not
  continue the top's object updates.

The normal-play hypothesis matters. The engine also has transitions using
`basic_update`, such as the painting-warp transition; these can update objects
without executing the ordinary countdown step. Stock SSL has no painting
nodes, and this experiment does not construct such a pre-existing transition
at the upper warp. That source exception must not be erased by a claim about
all possible engine states. Dialog/time-stop also does not provide a tested
way to keep this top moving while the normal warp clock waits.

## Explicit counterfactual: changing the countdown once

The following **102 diagnostic trials are not gameplay candidates**. They
use the same supplied capture recipes, but after update 2 they write
`sDelayedWarpTimer` once, from its observed 19 to `19 + extraDelay`.
Every later input is neutral. This is an extra mid-trial game-state edit,
recorded separately from the controller-only results.

For capture phases 120, 124, 126, 128, 129 and 130, the tested useful extension
is exactly `131 − capturePhase` updates. Every one of the six low poses works
at that extension: 36 useful arrivals. Where tested, one update less fails
because the top has not executed its explosion; one update more fails after
the top's collision geometry disappears and Mario remembers the static roof.

The smallest successful edited example in this menu is:

| Field | Value |
| --- | --- |
| Capture phase | 120 |
| Supplied movement/collision | `(-2152,818,-872)` |
| Supplied display | `(-2152,1723,-872)` |
| Supplied vertical gap | **905** |
| Extra edit after capture update 2 | Countdown **19 → 30**, adding 11 updates |
| Explosion and start of change-area mode | Update 32 |
| First completed Area 2 sample | Update 35 |
| Arrival | `(365.5927734375,5500,-1096.8026123046875)` |

Display 1722 fails the initial top capture at this fixed phase and X/Z.
The 905-unit gap is smaller than the earlier 923-unit vertical fixture, but
it is supplied, and its successful continuation additionally requires the
unproduced countdown edit. It is not a below-cap crawl producer or a clean
no-A route.

The one-update-too-late failure is directly visible. For phase 128 with four
extra updates, update 24 has an inactive top while floor/platform still name
slot 61. Update 25 is another normal object update before the transition;
Mario's floor becomes the ownerless roof at 1280 and the platform becomes
null. Area 2 then uses `(0,5500,256)`. With three extra updates, the transition
starts on the explosion update, retaining the useful reference. Merely
ensuring that the top has exploded at some earlier time is insufficient.

These are completed-update observations. They do not independently hook the
exact free-list operations or true first Area 2 apply. The old timer-131
allocation counts are not generalized to these edited continuations.

## Checks and reproduction

The [receipt](ink-warp-delay-receipt.json) includes all threshold probes,
twenty full controller histories, all 102 edited histories, exhaustive-menu
digests, the pause control and fresh replay checks. Twenty controller trials
and four edited controls match **593 updates** after a fresh boot and prefix
replay. The raw 5,940-row report is kept locally under `build/wafel-pilot`;
its hash and row digest are pinned in the compact receipt.

From the SSL directory in Windows PowerShell, using fresh output paths:

```powershell
& './build/wafel-pilot/python/python.exe' instrumentation/wafel-jp-pilot/ink_warp_delay_search.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-warp-delay-REPLAY.json --receipt build/wafel-pilot/ink-warp-delay-REPLAY-receipt.json
& './build/wafel-pilot/python/python.exe' instrumentation/wafel-jp-pilot/ink_warp_delay_verify.py docs/notes/ink-warp-delay-receipt.json --raw build/wafel-pilot/ink-warp-delay-20261112.json
```

The validator checks the stored threshold and edit ledgers, full retained
history digests, all raw-row aggregates and the two finite controller menus.
Six deliberate mutations must be rejected. It is a receipt consistency check,
not a proof of emulator correctness or an exhaustive gameplay proof.

The search stopped after this completed menu. No extended early-phase timer
edits or separate non-contact top-capture producer search was run. Capturing
the top before contacting the warp, waiting, and later re-entering the low
warp while preserving or recreating the reference remains a different open
producer problem. The Coq status is recorded below; this native experiment
does not itself prove a semantic timing theorem.

## Coq checks and unfinished obligation

The existing `InkFailedRetryGuard.ifg_pending_operation_blocks_actual_trigger_call`
is a checked full-call result: a live nonzero pending operation makes the actual
trigger call preserve memory rather than reset the countdown. It is reused here.
The source-level countdown and pause explanations are not new semantic theorems.

The baseline selected audit passed in Ubuntu WSL under `sm64-item-proof`, Coq
8.16.1 and CompCert 3.15, with the established memory limit:

```sh
bash pipeline/discipline-check.sh --build-timeout 600 --assumption-timeout 240 LessThanOneAPress.Proofs.MainTheorem current_ink_concrete_producer_boundary
```

Receipt `build/audit/20261112-062823-agx2bm0t`: 715 sources, zero issues,
seven allowed foundations, 549/635 modules in the main closure, 86 standalone,
zero integration problems.

The attempted new countdown module was built using:

```sh
bash pipeline/build.sh audit-build AUDIT_VO_TARGETS=proofs/InkWarpDelayCountdown.vo
```

That build **failed**, with `Not convertible` at the signed-short decrement
cast construction (line 120 of the saved attempt). The source-shape and bounded
word calculations preceding it were processed, but no completed new module or
semantic theorem was checked. The remaining cast evaluation and subsequent
statement/function-call constructors are unverified. Work stopped at the user's
wrap-up request; the project registration was removed and the boundary unchanged.
The [unfinished code](ink-warp-delay-countdown-unchecked.v.txt) is preserved as
text for continuation, not as a registered proof module. No axiom or `Admitted`
was introduced to bypass this obligation. Even a completed local tick theorem
would still require the normal scheduler path and intervening-state conditions
before giving a whole-history timing result.
