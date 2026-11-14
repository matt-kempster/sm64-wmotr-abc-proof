# Original-JP Mario entry controls

14 November 2026. Five independent original-ROM runs compare the existing
local crawl control with airborne shell cancellation, alone and with the Crazy
Box. The latter two make the 973-unit vertical gap but remain at X=-1950; the
next update takes the ordinary warp. The combined shell/box fixture does not
supply the missing shove. This is a supplied-state diagnostic, not a continuous
controller route or proof that all shell histories fail.

Run in Ubuntu-24.04 WSL, from `SSL-Coq/less-than-one-a-press`, with a fresh
output directory:

```sh
bash instrumentation/jp-ink-mario-entry/run.sh \
  ../../../reference-sm64-decomp/baserom.jp.z64 build/NEW-entry-control 1
```

Modes: 1 = supplied crawl with box; 2 = supplied freefall with shell + Z;
3 = the same freefall/shell + Z with the box also placed;
4 = exterior freefall, native landing/slide and later actor-only placement;
5 = the same freefall with a lower moving box placed before landing.
The runner verifies
the original JP ROM SHA256 and MD5, compiles with warning checks, and uses
Mupen64Plus 2.5.9 interpreter, Rice/HLE RSP 2.5.9 and dummy audio. It retains
the existing mode-12 four-pillar prefix and pre-game debug level-select cheat6.

The wrapper logs every write. At top phase128, modes2/3 supply shell-box
slot32 action4; two native updates create the shell. At phase130 modes1–3
supply M=C=D=(-1950,1741,-939), action/state/timer, speed/velocity/facing.
Mode1 uses crawl, forward5 and velocity(4,0,0), box(-1989,1741,-939), and
Z+stick(0,64). Modes2/3 use freefall, forward20 and velocity(20,-16,0),
shell(-1950,1731,-939), and neutral-stick Z; only mode3 supplies the box.
No floor, ceiling, platform, top timer, RNG, hitbox or camera fields are
written. All continuation input is neutral; A remains released throughout.

Mode4 supplies M=C=D=(-1930,1837.8726806640625,-880), FREEFALL,
forward20, velocity(0,-16,20), facing(0,0,0) before behavior128.
The native update lands on the top. Before129 the only cut is box49 XYZ
(-1857.8465576171875,1839.883544921875,-940.83349609375).
No Mario fields are written after the initial air seed. Native129 enters
BUTT_SLIDE and clears the end-update platform;130 makes M=C Y768 and
D Y1874.9208984375, a1106.9208984375 gap. The next query still finds the
static pad and takes the ordinary warp. Input is neutral throughout this
suffix; the initial airborne approach and late actor placement are supplied.

Mode5 supplies that same Mario seed and box XYZ
(-1857.8465576171875,1716.883544921875,-940.83349609375) before128.
It preserves the box's native velocity/behavior and makes no later writes.
The box rises to Y1725.337646484375 after128, avoiding the premature shove;
native129 gives the same slide/push and130 the same1106.9208984375 gap.
The next low query still finds the pad; Area2 arrival remains ordinary.
This confirms advance actor placement for the fragment, not a HOLP throw
or the reachability of either initial setup.

All five checks passed. The positive control reaches
(365.592773,5500,-1096.80261) in Area2. Both shell controls reach ordinary
(0,5500,256), with no top/platform capture. Each preserves53 end-update
observations. Source interaction ordering explains the missing shove; no
new internal interaction or quarter-return breakpoint is claimed.

`records/{crawl,shell,shell-box,landing-slide,early-box}/` retain receipts, dedicated
traces and the exact probe/prefix/runner/checker source snapshots. Check
an archived case without the ignored build output:

```sh
python3 instrumentation/jp-ink-mario-entry/check.py \
  instrumentation/jp-ink-mario-entry/records/shell-box 3 --archived
```

Receipts pin the original probe/prefix/runner/binary/checker hashes. Full
raw logs, configuration and screenshots remain in the named ignored build
directories `build/jp-ink-mario-entry-{control,shell,shellbox,landing,earlybox}-20261114-a`.
Screenshots are previous framebuffers; these notes rely on native telemetry,
not image-number inference. No ROM is included in the archive or site.
