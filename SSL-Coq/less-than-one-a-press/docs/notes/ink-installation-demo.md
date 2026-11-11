# Ink Installation with four controller-driven pillars

[Watch the staged demonstration](../media/ink-installation-demo.mp4) ·
[Read the emulator trace](../media/ink-installation-demo-trace.txt)

On the original Japanese ROM, the supplied vertical gap lets Mario use the
upper warp while remembering the spinning pyramid top. The game applies
the remembered movement in Area 2. Mario lands on the upper walkway outside
the elevator.

## What was staged

The [Mode 12 controller replay](../../instrumentation/jp-clean-gap-search/README.md)
starts at the project's accepted level-select entry and touches the four
pillars at game timers 848, 1065, 2390 and 2548. The top starts spinning at
2549. The controller goes neutral after pillar four so Mario comes to a stop
with empty hands. All three A-input counters are zero.

At global timer 2680 (top timer 131), Mario is idle, quicksand depth is zero
and the remembered platform is already null. The instrument writes only the
three XYZ position records, once:

| Record | Supplied position |
| --- | --- |
| Movement | `(-2200, 768, -1024)` |
| Raw collision | `(-2200, 768, -1024)` |
| Stored display | `(-2200, 1938.8648681640625, -1024)` |

## What the game did

| Global timer | Observation |
| --- | --- |
| 2681 | In Area 1 the upper warp is Mario's used object. Mario is in the disappeared action and both the floor owner and remembered platform are the live top. |
| 2701 | The top is inactive and its address is still Mario's remembered platform. |
| 2703 | The first Area-2 platform call uses the remembered top's address. It moves Mario from `(0, 5500, 256)` to `(365.5927734375, 5500, -1096.8026123046875)`. |
| 2704 | The first post-entry sample shows all three position records at the displaced point. |
| 2728 | Mario lands at `(337, 4429, -1075)` on the static upper walkway. |

The low collision position registers warp contact. The
[earlier call-level vertical receipt](ink-vertical-installation.md#what-the-game-did)
observes the low floor miss and the raised floor retry that selects the top.
Warp acceptance comes before the final platform update remembers the top.

The matched control changes only the staged display Y from
`1938.8648681640625` to `768`. The upper warp is still accepted at 2681.
The floor and platform pointers are null and the run returns to Select
Stage with the replay's debug level-select flag enabled. The final
screenshot confirms the menu. The [floorless warp tests](ink-floorless-warp.md)
also check the ordinary death destination with that flag off. The
[separate unedited controller replay](f02-warp-acceptance-target.md) uses
the upper warp from a supported position and has no remembered platform.
The sideways displacement on entry is the Ink payoff.

The video uses cuts between the first three pillar approaches and the final
approach. The fourth pillar, top spin, coordinate staging, warp and landing
are one continuous run, with the warp and descent slowed down. The capture
is silent. The ordinary camera briefly obscures the exact
Area-2 arrival. The before-and-after coordinates come from the trace.

This is a conditional emulator result. Controller-only production of the
required gap and a complete no-A counterexample remain open.

## Reproduce

From the workspace root in Ubuntu-24.04, run the
[capture script](../../instrumentation/jp-ink-installation-demo/run.sh) with
the original Japanese ROM and a fresh output directory.

```sh
bash reference-sm64-wmotr-abc-proof/SSL-Coq/less-than-one-a-press/instrumentation/jp-ink-installation-demo/run.sh \
  reference-sm64-decomp/baserom.jp.z64 build/ink-installation-replay staged
```

The script verifies the ROM hashes and saves the rendered frames and trace.
The apply-entry and return observations are read at emulator breakpoints.
Use the same command with a fresh output directory and `flat` as the
last argument for the matched control.
The [instrumentation guide](../../instrumentation/jp-ink-installation-demo/README.md)
includes the video encoding command.
