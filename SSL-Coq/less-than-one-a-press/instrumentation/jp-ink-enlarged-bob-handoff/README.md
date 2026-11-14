# Original-JP enlarged Bob-omb handoff

Both cases replay the conditional enlarged-Bob setup with the actual Japanese
ROM: the positive gives useful displacement; omitting only the final Crazy Box
placement gives the ordinary spawn despite fresh floor768. The remaining live
Bob is retained in the omission control. All setup writes and native queries
are logged; no code, floor-cache, behavior or fuse-freeze patches are used.

From the SSL project in Ubuntu-24.04, using fresh output directories:

```sh
bash instrumentation/jp-ink-enlarged-bob-handoff/run.sh ../../../reference-sm64-decomp/baserom.jp.z64 build/enlarged-positive positive
bash instrumentation/jp-ink-enlarged-bob-handoff/run.sh ../../../reference-sm64-decomp/baserom.jp.z64 build/enlarged-no-final-box no-final-box
python3 instrumentation/jp-ink-enlarged-bob-handoff/check.py build/enlarged-positive
python3 instrumentation/jp-ink-enlarged-bob-handoff/check.py build/enlarged-no-final-box
```

`positive.json` and `no-final-box.json` preserve the exact selected Wafel
recipes, profile/initial writes, later actor cuts, controls and expected
boundaries. `generate.py CASE.json OUTPUT.c` deterministically builds the
probe using authenticated object-field offsets and the preceding floor-query
probe. The shell preparation still grants the fake-pickup reference, high HOLP
and initial airborne Mario. The Bob profile is a disclosed transplant of a
separately controller-produced native donor; its delivery is not established.

Each run matches25 selected Wafel physical-state boundaries, including Bob
action, hitbox and movement fields. The25 global-clock differences per run
(`native+2 = Wafel`) and unavailable camera boundaries25/26 remain explicit.
This is not full-memory equality. The positive records682 floor returns and
the omission control665. Producer initial query768 and actual stopped
quarter return2 are checked. The positive captures/retains the top and reaches
`(365.5927734375,5500,-1096.8026123046875)`; the omission reaches `(0,5500,256)`.

Original ROM SHA-256:
`9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317`.
Source pin: `9921382a68bb0c865e5e45eb594d9c64db59b1af`.
Probe start revision: `32f5eb4d5911b2e0a7972b748065c71ebe016717`.
The existing Mupen64Plus2.5.9 interpreter/debugger, Rice2.5.9, RSP HLE2.5.9,
dummy audio and Xvfb run under Ubuntu-24.04. `FD_TOP_LOAD.distance=19000` is
the stored distance sentinel, and its `yaw` field is move yaw; neither is the
actual distance or spinning face yaw. Loading itself is hooked separately.

Archived checks:

```sh
python3 instrumentation/jp-ink-enlarged-bob-handoff/check.py instrumentation/jp-ink-enlarged-bob-handoff/records/positive --archived
python3 instrumentation/jp-ink-enlarged-bob-handoff/check.py instrumentation/jp-ink-enlarged-bob-handoff/records/no-final-box --archived
```

Only logs, recipes, sources and hashes are published. No ROM or emulator binary.
No new Coq theorem or continuous no-new-A route is claimed.
