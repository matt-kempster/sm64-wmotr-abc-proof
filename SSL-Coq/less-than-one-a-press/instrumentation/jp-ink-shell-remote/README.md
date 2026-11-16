# Original-JP throw directly into the shell handoff

The native Mario throw places initialized shell71 at
`(-1962.4404296875,1800,-1243.34130859375)`, from supplied HOLP
`(-1962.4404296875,1800,-1275.34130859375)` and yaw0. The shell remains at
that exact origin until the later mounting update. No shell XYZ is written
after the throw. The supplied MarioY1810 and Bob/Box recipe then captures
and retains top61 and reaches useful Area2
`(365.5927734375,5500,-1096.8026123046875)`.

The no-Box control keeps the original Box in the world but omits its placement;
it reaches ordinary `(0,5500,256)` without top capture. This is a conditional
remote-release handoff, not demonstrated held-shell/HOLP acquisition or a
continuous allowed route. The earlier native shell-box spawn, low pickup
pose, shell position and used-pointer retarget remain grants. The new remote
destination is supplied only through HOLP at the actual throw call.

`generate.py` reuses the authenticated prefix and query observer from the
existing native pusher-release pipeline. It replaces the preparation's one
throw-time HOLP value, requires no initial shell-field writes in the later128
cut, and adds read-only shell XYZ/type/tangibility/command observations.
The shell behavior/script/type is never patched to manufacture functionality.

| Accepted run | Handoff comparisons | Retained differences | Direct shell observations | Result |
|---|---|---|---|---|
|`low-positive`|25 boundaries,1900 components|25 clocks,2 Box subtypes|104 stationary post-throw observations|Top capture/retention; useful spawn|
|`no-box`|25 boundaries,1900 components|25 clocks,25 Box subtypes|104 stationary post-throw observations|No top capture; ordinary spawn|

The clock difference is native+2=Wafel. The Box subtype differs2 versus0;
the named neutral push does not read DELAY_INVINCIBILITY. Its origin is not
established. All other selected comparisons agree. Camera boundaries25/26
are absent in each transition; whole-memory equality is not claimed.
Floor-return counts are709/685. Setup ledgers contain92/89 scalar writes,
including the inherited preparation. No later shell XYZ write is accepted.
The checks preserve exact source, recipe and trace bytes.

Both throws happen at preparation step25, with the released shell observed
from step26 onward at native command `0x800eb778` (carry5 BREAK), type524288,
intangible0 and radius/height50/50. The throw-to-mount wait is native execution,
not a frozen emulator or per-frame XYZ reset. The later Mario/pusher cut remains
explicit. The high-positive export/probe is provided for reproduction but
was not run on the original ROM in this task; its evidence is the separately
repeated Wafel experiment.

## Reproduce

From the SSL proof directory:

```powershell
python instrumentation/jp-ink-shell-remote/generate.py instrumentation/jp-ink-shell-remote/low-positive.json instrumentation/jp-ink-shell-remote/low-positive.c
```

Then in Ubuntu-24.04 WSL, using a fresh output directory:

```sh
bash instrumentation/jp-ink-shell-remote/run.sh '../../../reference-sm64-decomp/baserom.jp.z64' 'build/FRESH-SHELL-REMOTE' low-positive
```

```powershell
python instrumentation/jp-ink-shell-remote/check.py build/FRESH-SHELL-REMOTE
python instrumentation/jp-ink-shell-remote/verify.py --check
```

Use `no-box` for the negative control. The archived base comparator receipt
and the additional remote-shell receipt are both checked, without dropping
differences. No ROM or emulator binaries are distributed.

Proof start `4adf8faf311d1d271c57f288f51b06bf357874d1`; stock JP source
`9921382a68bb0c865e5e45eb594d9c64db59b1af`; local decompile
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`. Native runtime is
Mupen64Plus/Rice/RSP-HLE2.5.9, interpreter mode0, Xvfb/software GL, dummy audio.
Original JP ROM SHA256:
`9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317`.
Wafel0.8.5/Python3.9.13 comparison DLL SHA256:
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
No new Coq theorem or audit is claimed by this runtime packet.
