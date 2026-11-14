# Original JP: high riding-state nudge controls

14 November 2026. **Both selected conditional controls reproduce useful spawning displacement on the original Japanese ROM:** a small breakable box at Mario Y25000 and an ordinary black Bob-omb at Y67277. Each starts with a native low shell mount, then explicitly supplies the high riding position and actor placement. These replays confirm compatibility after that grant; they do not produce a controller-reachable high rider or deliver the actor.

The experiment extends [the 82-case Wafel nudge study](ink-high-item-nudge.md), whose original starting revision was `3772fb57701ad0074c9a2016c366bed7e7e3ea24` and whose corrected package was subsequently committed as `421ba87`. The selected riding trials are unchanged by the supplied-slide metadata correction. Their exact expected records are frozen separately in `instrumentation/jp-ink-high-item-nudge/expected.json.gz` with the source archive hash.

The frozen source hash `fedffccfb1b48ade51b8617fde054dfd0969d0d830df48324418efc28146c1e1` identifies the corrected `ink-high-item-nudge/results.json.gz`. The freeze occurred after that metadata rewrite. `prepare_expected.py` also verifies that both selected riding records still equal the current results; no frozen expected values were changed to hide a discrepancy.

## Exact supplied cuts and native sequence

The existing mode12 A-off four-pillar prefix is reused, including its disclosed pre-game debug level-selection cheat6. The original game code and ROM are unmodified. Each run logs exactly **36 memory writes**, checked against address, width, field and timing allowlists:

- At stored top timer125: shell-box slot32 action2→4. The native callback spawns shell69. This is a shell-availability grant.
- At stored129: Mario M=C=D is supplied at the inherited prefix X/Z `(-5883.07373046875,819.5643920898438)`, Y1034, ten units above the real floor1024. Supply FREEFALL, state/timer0, forward20, velocity(20,-16,0), facing(0,16384,0), and shell69 at the same X/Z, Y1024. The helper temporarily writes velocity(20,0,0) before its logged Y=-16 write, with no game execution between them. Input is neutral. The game mounts the shell and retains RIDING_SHELL_GROUND, including a native ridden pointer.
- At stored130: supply only M/C/D=(-1950,H,-939), preserving that action and ridden pointer. Place small box23 at(-1974,25000,-939), or black Bob-omb39 at(-1979,67277,-939). Press Z with neutral stick. No ground action or object pointer is written at this cut.

There are no later memory edits. There are no floor/cache, platform, hitbox, status, collision-list, RNG, phase, actor-velocity or camera edits. All controller A counters, including held A, are zero.

| Native update: stored timer before→after | M=C | Stored gfx.pos D | Observed outcome |
|---|---|---|---|
| Low mount129→130 | (-5862.31787109375,1024,819.5643920898438) | Same X/Z, Y1069 | Native RIDING_SHELL_GROUND, ridden shell69 |
| High producer130→131 | (-1882,768,-939) | (-1882,H,-939) | Low cache768; Z cancellation reaches floor alignment; final action GROUND_BONK |
| Acceptance131→132 | (-1882,1818.9613037109375,-939) | Same | Warp64 accepted, floor owner/platform61, DISAPPEARED |
| Later observed Area1 updates | Native top-carried trajectory | Same | Top/platform61 remains in all observed samples, including top deactivation |
| First Area2, high-suffix update25 | (365.5927734375,5500,-1096.8026123046875) | Same | Useful displaced arrival, not ordinary(0,5500,256) |

The producer gaps are24232 and66509 respectively. Native end-update observations establish the shown positions, action IDs, cache, capture and arrival. The internal interaction/action-handler order comes from the companion Wafel event records and source; this ROM probe adds no interaction or quarter-step breakpoint.

## Comparison and its limits

Each run preserves **53 camera-hook observations**. The camera hook does not run at probe steps28/29 during the area transition; these correspond to high-suffix updates23/24. Therefore continuous platform retention over those two steps is checked in Wafel, while the ROM evidence provides sampled retention through deactivation and the demonstrated displaced arrival. The missing observations are recorded explicitly, not filled from expected values.

The comparison uses24 available boundaries per run: the native low mount and23 observed high-suffix boundaries through arrival. It compares37 scalar fields/components each, using exact Float32 bits for the decimal values recorded with nine significant digits: M/C/D, velocity/slide velocity, action/state/timer, floor/ceiling height, forward speed, area/top fields, used/held/ridden/platform/floor-owner slots, and selected actor position/type/subtype/status/radius/height. It is not a comparison of every byte of game state.

| Original-JP control | Compared boundaries / scalar comparisons | Differences | Outcome |
|---|---:|---|---|
| Small box23, H25000 |24 /888| One: at the low-mount boundary, before high relocation, small-box interaction subtype is2 on ROM versus0 in Wafel | Useful arrival passes; strict equality of all compared fields fails |
| Black Bob-omb39, H67277 |24 /888| Zero | Useful arrival and equality of the compared fields pass |

For the small-box case all compared producer-through-arrival fields agree. The precise cause and broader consequences of the earlier subtype difference are not proved; it is retained in the receipt rather than discarded. This result must not be relabeled as full-state equivalence or as a mismatch-free small-box replay.

The initial checker incorrectly expected camera observations on every update. It was corrected to enumerate the two actual missing steps, then both unchanged native traces were checked again. Archived outcome/write/input/retention checks pass for both controls; the strict small-box field comparison still reports its one real difference.

## Reproduction and preserved evidence

Runtime was rechecked: Ubuntu24.04 WSL, Mupen64Plus core/UI2.5.9 interpreter, Rice2.5.9, HLE RSP2.5.9, dummy audio and separate config/data directories. The runner authenticates original JP ROM SHA256 `9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317` and MD5 `85d61f5525af708c9f1e84dce6dc10e9`; it compiles the observer/input plugin with `-Wall -Wextra -Werror`. Applicable stock source pin remains `9921382a68bb0c865e5e45eb594d9c64db59b1af`, decompile checkout `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`. The existing Wafel0.8.5 JP DLL hash is `960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.

Run within the WSL `SSL-Coq/less-than-one-a-press` directory, using a fresh output path:

```sh
bash instrumentation/jp-ink-high-item-nudge/run.sh ../../../reference-sm64-decomp/baserom.jp.z64 build/NEW-high-small 1
bash instrumentation/jp-ink-high-item-nudge/run.sh ../../../reference-sm64-decomp/baserom.jp.z64 build/NEW-high-bobomb 2
```

The package's `records/small-25000/` and `records/bobomb-67277/` contain exact raw text logs compressed with gzip, selected traces, write/input ledgers, comparison receipts, source snapshots and hashes. They can be rechecked without ROM/emulator files using the README commands. Original build directories are `build/jp-high-item-small-20261114-a` and `build/jp-high-item-bobomb-20261114-a`; their plugins/configs/screenshots are not published. The legacy prefix's controller-only header describes only the inherited prefix, not the wrapper's disclosed36 writes.

No new Coq theorem, high-item manipulation/delivery history, or complete no-new-A route follows. The remaining condition is still to reach the already-riding high state and actor placement through gameplay before the producer update.
