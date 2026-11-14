# Original-JP native drops and lower shell entry

**Both native drops followed by a supplied Y1810 FREEFALL shell entry produce
useful spawning displacement on the original Japanese ROM.** This is release
compatibility from supplied carrying/HOLP states, not a controller-reached
delivery route. The full grants and frame table are in
[the main report](../../docs/notes/ink-mario-pusher-delivery.md).

The probe reuses the authenticated existing JP prefix, native initialized
shell preparation and query hooks. It adds only the declared setup writes and
read-only actor observations. No actor release endpoint is written: Mario's
native drop helper supplies it, followed by the actor's native callback when
active. There is no A press/down in the measured prefix or continuation.

| Case argument | Preparation | Compared boundaries/components | Differences | Outcome |
|---|---|---|---|---|
|`positive`|Box drop126, Bob drop127, supplied airY19900 at128|27 /2052|27 clocks,4 Box subtypes|Captured/retained top; useful spawn|
|`no-box`|Same, omit Box release and leave it in original world position|27 /2052|27 clocks,27 Box subtypes|No top capture; ordinary spawn|
|`low-entry`|Editor-preplaced free actors; corrected airY1810 and compensated Bob X/Z|25 /1875|25 clocks,2 Box subtypes|Captured/retained top; useful spawn|
|`low-joint`|Both native drops; corrected airY1810, unchanged pending-drop Bob HOLP X/Z|27 /2052|27 clocks,4 Box subtypes|Captured/retained top; useful spawn|

Useful is exactly `(365.5927734375,5500,-1096.8026123046875)`; ordinary is
`(0,5500,256)`. Native observations include the low warp, top61 capture and
retention at every later sampled Area1 boundary, plus the fresh768 floor query.
Floor-hook counts are694/695/709/713 in table order. Two camera observations
are missing in each transition: bridges27/28 for phase126 cases,25/26 for128.

The checks retain every discrepancy. Native clocks plus2 equal Wafel clocks;
Box subtype is2 instead of0 (DELAY_INVINCIBILITY). All other compared fields
agree, including Mario M/C/G, action/cache/platform/collision membership,
selected shell fields and Bob/Box position, radius, height, scale, movement
and held/status fields. This is selected-field agreement, not whole-memory
equivalence. G means stored graphics `gfx.pos`, not rendered pose.

The setup ledgers contain139/134/95/139 scalar writes, including inherited
shell spawning, pickup-reference and HOLP grants. In the joint cases, Box49
is not edited after126; Bob39 is not edited after127; the128 cut is Mario-only.
Nothing is edited after mounting. The supplied carrying states are separate
grants, not adjacent controller-reached states. The low-joint native recipe
retains the inherited metadata label `suppliedHighAirEntry128`; its actual
position writes are1810, not19900. The newer Wafel export renames that label
without changing any numeric edit, input or expected state.

## Reproduce

Generate each probe from its preserved recipe using ordinary Python:

```powershell
python instrumentation/jp-ink-mario-pusher-release/generate.py instrumentation/jp-ink-mario-pusher-release/low-joint.json instrumentation/jp-ink-mario-pusher-release/low-joint.c
```

Run in Ubuntu-24.04 WSL from the SSL project, with a fresh output directory:

```sh
bash instrumentation/jp-ink-mario-pusher-release/run.sh '../../../reference-sm64-decomp/baserom.jp.z64' 'build/FRESH-RELEASE' low-joint
```

Then check and, optionally, archive the completed run:

```powershell
python instrumentation/jp-ink-mario-pusher-release/check.py build/FRESH-RELEASE
python instrumentation/jp-ink-mario-pusher-release/archive.py build/FRESH-RELEASE NEW-RECORD
python instrumentation/jp-ink-mario-pusher-release/verify.py --check
```

The accepted records are the fresh positive/no-box/low-joint runs and a
clean low-entry rerun. An earlier low-entry emulator run completed but its
shell trace-export step failed because the runner was edited while active;
it is excluded from accepted records. The runner was finalized before the
successful repeat. Do not edit a runner during its execution.

Runtime: Mupen64Plus/Rice/RSP-HLE2.5.9, interpreter mode0, Xvfb/software GL,
dummy audio, original JP ROM SHA256
`9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317`.
Proof start `0605d842cedb55151e70952d56064553c4970f60`; applicable JP source
`9921382a68bb0c865e5e45eb594d9c64db59b1af`; local decompile
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`. Wafel comparison uses0.8.5,
Python3.9.13 and JP DLL SHA256
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
No ROM, emulator binary or conversation export is distributed. No new Coq
claim or controller-route theorem is made.
