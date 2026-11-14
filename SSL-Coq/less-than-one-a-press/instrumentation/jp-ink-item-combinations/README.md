# Original Japanese ROM: native slide entry and three stock actors

14 November 2026. The **Koopa shell + Crazy Box + pink Bob-omb Buddy**
combination completes the usable Ink handoff from a supplied low FREEFALL
state. Mario enters the slide natively; no Mario memory is edited afterward.
The actor placements remain supplied, including a second Crazy Box cut.
The comparison omitting the Buddy stays in Area 1 throughout its recorded
continuation. Both independent original-ROM runs passed their checks.

Run in Ubuntu-24.04 WSL from `SSL-Coq/less-than-one-a-press`, with a fresh
output directory:

```sh
bash instrumentation/jp-ink-item-combinations/run.sh \
  ../../../reference-sm64-decomp/baserom.jp.z64 build/NEW-combination \
  1 1810.0 -1922.4404296875 -1223.34130859375
```

Use mode 2 with the same coordinates to omit the phase-129 Buddy placement.
The runner authenticates the original JP ROM SHA256
`9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317`
and MD5 `85d61f5525af708c9f1e84dce6dc10e9`. It builds the input/observation
plugin with `-Wall -Wextra -Werror`, then uses the established Mupen64Plus
2.5.9 interpreter, Rice/HLE RSP 2.5.9, dummy audio and separate config/data
directories. The original game code and ROM are not patched. The existing
mode-12 four-pillar prefix retains its disclosed pre-game debug level-select
cheat 6. Every A counter is zero, including held A.

Before behavior125, stock shell-box slot32 action4 is supplied; its native
callback creates shell69. Before128, the sole Mario cut supplies M=C=D
`(-1922.4404296875,1810,-1223.34130859375)`, FREEFALL, action state/timer0,
speed20, velocity `(0,-16,20)` and facing `(0,0,0)`. Shell69 is placed at
the same X/Z, Y1800. Input128 is Z with neutral stick; every later input is
neutral. The helper briefly writes zero velocity and yaw16384, then the
listed final values, within the same logged cut and with no intervening
gameplay. There is no supplied ground-action ID.

Before129, Crazy Box49 is placed at
`(-1990.710693359375,1799.2869873046875,-1280.710693359375)` and Buddy15 at
`(-2054.455810546875,1799.2869873046875,-1208.867919921875)`.
Before130, only Box49 is moved again, to
`(-2117.125244140625,1830.177978515625,-1128.1343994140625)`.
No type, status, dimension, tangibility, velocity, floor, platform, top phase,
RNG or camera value is written at these actor cuts. They are not an item
delivery history or a demonstrated throw.

The positive run has 53 end-update observations. Native128 enters
BUTT_SLIDE;129 reaches movement Y1830.177978515625;130 has M=C Y768 and
stored graphics Y1830.177978515625. Native131 has the real warp reference
and top floor/platform. That platform persists through top deactivation,
and Area 2 arrival is `(365.5927734375,5500,-1096.8026123046875)`.
The no-Buddy run has 55 observations, stays on the top at the producer
phase, and does not reach Area 2 in that interval.

These ROM observations are end-update fields. The fresh pre-producer low
cache, interaction sequence and quarter-step interpretation come from the
companion Wafel instrumentation and source review; this probe installs no
new internal interaction/quarter breakpoints. D means `header.gfx.pos`,
not the drawn model or render matrix.

`records/{low-positive,low-no-buddy}/` preserve traces, receipts and exact
probe/prefix/runner/checker snapshots. The checker verifies chronological
unique observation keys, exact setup address/width allowlists, A-off inputs,
no later Mario writes, positive capture/retention/arrival and the bounded
negative result. Recheck archives without the ROM or ignored build output:

```sh
python3 instrumentation/jp-ink-item-combinations/check.py \
  instrumentation/jp-ink-item-combinations/records/low-positive \
  1 1810.0 -1922.4404296875 -1223.34130859375 --archived
python3 instrumentation/jp-ink-item-combinations/check.py \
  instrumentation/jp-ink-item-combinations/records/low-no-buddy \
  2 1810.0 -1922.4404296875 -1223.34130859375 --archived
```

The reused prefix's legacy `SEARCH` header says controller-only/no input
plugin writes. That describes the prefix, **not this wrapper**: the explicit
`ENTRY_WRITE` ledger and receipt disclose its supplied cuts. Do not use that
legacy line as a whole-run no-edit claim. Full raw logs, plugin binary,
configs and previous-framebuffer screenshots remain in ignored
`build/jp-ink-item-low-{positive,no-buddy}-20261114-a`; no ROM is published.
Inspection baseline is proof revision
`08b72af44fbb54aaef3ed7f8be399868ba75db98`.
