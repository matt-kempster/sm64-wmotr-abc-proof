# Conditional JP timer-131 installer probe

This probe tests one narrow engine-semantic question on an authenticated
original Japanese ROM.  It is **not** a gameplay-reachability witness.

After entering SSL Area 1 through the retail level-select path, the probe arms
the spinning pyramid top and waits until its action timer is 131.  At that
poll it injects three deliberately different views of Mario:

- `MarioState.pos = (-2200, 768, -1024)`;
- `gMarioObject.oPos =` the upper-warp center;
- `gMarioObject.header.gfx.pos = (-1641, 1456, -783)`;
- `gMarioPlatform = NULL`.

The following retail frame must establish all of the following before the
runner succeeds:

- MarioState's X/Z equal the Graphics retry X/Z;
- `MarioState.floor->object` (surface offset `+0x2c`) is the live pyramid top;
- the object-warp interaction selected `ACT_DISAPPEARED` and retained the
  upper warp in `usedObj`;
- `update_mario_platform` captured the live top;
- neither `A_BUTTON_PRESSED`, `A_BUTTON_DOWN`, nor controller A was observed.

Run:

```sh
./instrumentation/timer131-installer/run.sh /path/to/baserom.jp.z64
```

The runner checks both standard authenticity hashes before loading the ROM.
It writes only ignored output below `build/instrumentation/timer131-installer/`.

Passing this probe shows that the injected State/Object/Graphics split makes
the real JP engine perform the miss/copy/retry/warp/capture chain for this
frame.  It does not show that clean gameplay can create the injected prestate.
It also does not show that this side-face capture survives until the delayed
warp: the composed lifecycle run loses the moving top at timer 138 and clears
`gMarioPlatform`.  Installer reachability and a capture-preserving continuation
therefore remain separate Layer-B obligations.

The checked run produced `expected-trace.txt`.  That file is specifically the
transient side-point trace for Graphics `(-1641,1456,-783)`; it is not the
later capture-preserving midpoint trace.  At the next poll, the live
state was `(-1641, 1533.34375, -783)`, with bits
`(c4cd2000,44bfab00,c443c000)`.  The returned floor at `8019bb10` named the
top at `803451f8` through `surface->object`; the action was `00001300`, the
argument was `00040001`, `usedObj` still named the upper warp, and
`gMarioPlatform` named the top.  The argument is one less than the
`00040002` written by `interact_warp`, because `act_disappeared` executes and
decrements it later in that same Mario update.

The injector writes only the three Mario coordinate views and
`gMarioPlatform`.  In particular, it does not write `throwMatrix`, any dynamic
surface or partition-list field, `MarioState.floor`, the action/action
argument, or `usedObj`.  Those observed post-frame values therefore come from
the retail engine.  This is runtime evidence, while the corresponding linked
Clight-memory proof remains open.

The one-frame capture must not be conflated with the stronger post-owner
lifecycle fixture.  In the composed run, the rotating face carries Mario for
several frames, but the final floor becomes static Y `1280` at global timer
498/top timer 138 and `gMarioPlatform` becomes null.  It stays null through
the explosion and Area-2 transition.  Thus this exact corrected Graphics
witness does not install the stale Area-2 spinning-top payload by itself.

A separate authenticated retry-lifetime run overrides Graphics with
`(-1862,1778,-902)`.  Rocq proves that point is strictly inside the same
timer-131 face and that it returns floor height bits `44defe16`.  In the
conditional JP run it remains top-owned through the explosion and supplies
the first Area-2 displacement.  Its trace belongs to
`instrumentation/jp-retry-lifetime/`; it must not be substituted into this
probe's `expected-trace.txt`.  The midpoint requires a Graphics-minus-Object
Y gap of at least `960` over any warp-overlapping Object (`1010` at the warp
centre), and no clean retail installer for that gap has been proved.
