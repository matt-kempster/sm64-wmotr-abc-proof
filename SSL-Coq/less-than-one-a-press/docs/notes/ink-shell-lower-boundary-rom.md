# Original JP: frozen-shell Y19,900 handoff and no-Buddy control

14 November 2026. **An initialized frozen shell can start the older immediate-Z / Crazy Box+Buddy / Crazy Box sequence from supplied FREEFALL at Y19,900 and produce useful spawning displacement on original JP.** Mario's action and position are not edited after that initial airborne cut. The later actor placements are supplied. Removing the Buddy placement fails this particular recipe. Neither replay establishes legal high Mario entry, shell delivery, actor delivery, or a complete no-new-A route.

This is a clone-compatibility reproduction of the previously recorded [native slide-entry combination](ink-item-native-slide-combinations.md), credited also in [the lower-height Wafel report](ink-shell-lower-boundary.md). It is not a newly discovered version of that older live-shell sequence. The [separate pending-pickup delivery study](ink-shell-delivery-rom.md) uses fewer acquisition grants, but has not been joined to this high setup.

## Versions and exact grants

The investigation began at proof revision `162617b708b2244beca85af58b76ad5794e598cd`. The decompile checkout is `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`, with applicable stock JP source pinned at `9921382a68bb0c865e5e45eb594d9c64db59b1af`. The authenticated original JP ROM has SHA-256 `9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317` and MD5 `85d61f5525af708c9f1e84dce6dc10e9`; the launcher checks both. Ubuntu-24.04 WSL ran Mupen64Plus core/UI 2.5.9, interpreter mode0, Rice2.5.9, RSP HLE2.5.9 and dummy audio. These are emulator replays, not physical-console recordings.

The expected traces use Wafel0.8.5, JP DLL SHA-256 `960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`. The independently verified lower Wafel artifact is `instrumentation/ink-shell-lower-boundary/results.json.gz`; the comparison selects `results.oldSequence[0]` and `[1]`.

The accepted no-A four-pillar prefix is inherited, including debug level-selection startup (`--cheats 6`). All controller inputs keep A released; the retail engine counters also report zero A-down and A-pressed frames. B begins pickup and later throw; Z is pressed only on the high mount update. Subsequent pads are neutral. There is no held-A dependency.

The following table accounts for **all 62 positive / 59 negative post-prefix writes**, including repeated scalar stores. Full addresses, widths, before/after values and field names are preserved in each receipt.

| Before local update index | Grant | Stores |
|---:|---|---:|
| 0 | Native SSL shell-box32 action2→4; its real contents shell initializes in slot71. | 1 |
| 2 | Mario M=C=G=(5900,51,3380), IDLE, state/timer0, velocity/speed0 and face angles0; shell71 XYZ=(6100,51,3380). | 22 |
| 6 | Retarget the pending real small-box pickup: `usedObj=slot71`. The later grab and carry-script freeze are native. | 1 |
| 25 | Stored HOLP=(-1950,19890,-971), just before native throw release. The native throw places the shell at(-1950,19890,-939). | 3 |
| 129, top128 | Initial high cut: Mario M=C=G=(-1920,19900,-1210), FREEFALL, state/timer0, speed20, final velocity(0,-16,20), yaw0; shell XYZ=(-1920,19890,-1210). The helper first writes velocity(20,-16,0), yaw16384, then overrides them; those repeated writes are audited too. | 26 |
| 130, top129 | Crazy Box49 XYZ=(-1990.710693359375,1799.2869873046875,-1280.710693359375). Positive only: Buddy15 XYZ=(-2054.455810546875,1799.2869873046875,-1208.867919921875). | 6 positive / 3 negative |
| 131, top130 | Same Crazy Box49 moved to(-2117.125244140625,1830.177978515625,-1128.1343994140625). | 3 |

No shell interaction type, dimensions, tangibility, status, ridden pointer or floor/platform pointer is assigned. The initialized shell is frozen by the actual non-HOLDABLE pickup/throw path, ending at `bhvCarrySomething5[1]` (`0x800eb778`, BREAK). Its original shell behavior identity remains `0x800ea25c`; type524288, intangible0, radius50 and height50 persist. No Mario or shell writes occur after the initial high FREEFALL cut. Only the two later actor-position cuts remain. All three actor kinds exist in SSL Area1; their availability does not establish delivery to these coordinates.

## Useful handoff, and the failing control

M is Movement, C is Collision, and G is **Stored Graphics** (`gfx.pos`), not a visibly drawn model location. Numbered boundaries below count completed updates after the high FREEFALL cut.

| Boundary | Positive result |
|---:|---|
| 1 | Native shell mount and immediate Z reach BUTT_SLIDE on the moving top. M=C=(-1920,1799.2869873046875,-1210), G=(-1920,19900,-1210); floor/platform owner61. |
| 2 | After the Box+Buddy cut, M=C=(-2140.031982421875,1830.177978515625,-1115.0291748046875); G.Y=1799.2869873046875. |
| 3 | After the second Box cut, the productive low floor cache is768. M=C=(-2210.062255859375,768,-1075.10888671875), G.Y=1830.177978515625; BUTT_SLIDE_STOP. |
| 4 | Warp object64 is selected, Mario is DISAPPEARED, and floor/platform owner61 is captured. |
| 4–24 | Every observed Area1 boundary retains top61 as floor owner and platform. |
| 27 | First observed Area2 position is exactly(365.5927734375,5500,-1096.8026123046875), the useful displaced spawn. |

The original high gap is not the final handoff gap: initial airborne Y=19900 leads onto the real top, and the final producer begins around Y=1830. This is why this success does not repair the separately tested delayed mount-now / next-update Bob-omb+Z bridge at high coordinates.

Omitting Buddy preserves the first mount/cancel/top landing, but the next boundary instead has M=C=G=(-2059.110107421875,1867.0308837890625,-1191.7894287109375). At boundary3 the floor remains1814.403076171875, rather than768. It stays in Area1 with no accepted warp through the observed35-update horizon. This closes only the selected no-Buddy control, not all possible substitutes or actor histories.

## What the checker actually establishes

The [native package](../../instrumentation/jp-ink-shell-lower-boundary/README.md) retains raw logs, controller records, setup-write records, native and inherited source, receipts, and hashes. Both archived receipts were independently reconstructed with `--archived`. The checker matches every setup address/width/value, including repeated writes; the native helper omits two redundant zero pitch/roll writes in the Wafel record, which is explicit in the checker.

The positive contains162 native observations and67 comparable expected boundaries. The negative contains164 native observations and77 comparable expected boundaries. All compared M/C/G binary32 values, velocities, action/state/timer, input, cache/ceiling, floor ownership, platform, used/held/ridden references, collision lists and shell fields agree **except the global timer**. There are67/77 raw timer differences, each exactly native+2=Wafel. Receipts report strict selected-field equality as false, preserve every difference, and separately report zero physical/action-field mismatches after that single clock normalization. This is not a full-memory equivalence claim.

The positive has no camera observation for local steps154/155, corresponding to transition boundaries25/26. The useful arrival is observed at boundary27; unobserved transition frames are not filled in from Wafel. The negative's expected final boundary36 (local step165) is also absent because this probe stops camera logging after boundary35. These three missing comparisons are recorded with separate reasons. The no-A counter checks cover the entire native run, including the startup/prefix.

No new Coq theorem is asserted by this ROM report. The meaningful improvement is confirmation that the existing conditional useful sequence tolerates a genuinely frozen initialized shell. Legal acquisition and high delivery remain separate obligations, and the Box/Buddy placements remain supplied.
