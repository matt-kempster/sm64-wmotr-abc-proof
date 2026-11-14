# Original-JP Fly Guy predecessors: trajectory confirmation, strict flag mismatch

14 November 2026. **Three genuine A-off controller histories reproduce their
Mario/Fly Guy trajectories on the original Japanese ROM. None completes Ink.**
The expanded internal comparison also finds a specific interaction-flag
difference from Wafel, which is preserved as a failed strict check.

The work starts at proof revision `4813e95d33286a30882caf0759dd838c95ee48f2`,
branch `codex/ssl-pyramid-item-proof`. Source references use stock
`9921382a68bb0c865e5e45eb594d9c64db59b1af` in decompile checkout
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`. The Japanese ROM SHA-256 is
`9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317`, MD5
`85d61f5525af708c9f1e84dce6dc10e9`. Wafel 0.8.5 JP is compared with Mupen64Plus
2.5.9 interpreter, Rice 2.5.9, HLE RSP and dummy audio in Ubuntu-24.04 WSL.
The authenticated Wafel DLL hash is in every archived provenance record.

Only the inherited debug level-selection startup is supplied. The histories
then write controller inputs only, always with A released. No Mario position,
action, actor placement, floor, cache, timer, pickup reference or RNG is edited.
The read-only native observer imports no game-memory write API. This does not
construct a castle-to-SSL entry from a clean save.

| Actual history | Inputs / before-poll observations | Demonstrated milestone | Ink limitation |
| --- | ---: | --- | --- |
| Fly Guy bounce, then roof crawl | 3097 / 2749 | Mario peaks at Y1885.1969 and genuinely lands/crawls on static roof Y1280 | Original top already exploded; cache1280. Separate warp continuation uses ordinary spawn. |
| Flame-assisted roof and continued luring | 3487 / 3139 | Natural burn expiry, then CRAWLING at Mario Y1280; native living Fly Guy reaches raw Y1735.0334 at completed input3310 | Top already gone. Enemy height is not Mario height; no fresh768/high-graphics split. |
| Pre-fourth-pillar bounce and high slide | 2869 / 2521 | TWIRL_LAND at1772, IDLE, then BUTT_SLIDE at `(-2036.7165527,1768,-1047.598877)` after input2867 | Three pillars touched; intact stationary top supplies the high floor/cache. |

The third history builds on the earlier Box-delivery record and adds new
controller braking/landing. It is not a newly discovered earlier bounce.
The [runtime report](ink-flyguy-native-manipulation-runtime.md) credits that
record and preserves the source inputs. The [lure report](ink-flyguy-native-lure.md)
gives the flame/circle policy and its unsuccessful pre-fourth transfers.

All recorded Mario movement, collision, stored graphics, action/input, floor,
platform and object references match. The additional Fly Guy XYZ, velocity,
home, action/timer, activation, headings, size and other observed fields also
match **except the interaction subtype described below**. Observations are
before controller polls; Wafel's global timer is one larger at these matched
cuts. The final input's after-state is not implicitly an extra observation.

## The strict check fails on a real recorded difference

| History | Mismatch polls, inclusive | Number | Exact subtype values |
| --- | --- | ---: | --- |
| Roof crawl | 849–2851 | 2003 | ROM130, Wafel128 |
| Flame/lure | 849–2851 | 2003 | ROM130, Wafel128 |
| High slide | 849–2799 | 1951 | ROM130, Wafel128 |

The differing bit is `INT_SUBTYPE_DELAY_INVINCIBILITY`, value2. The twirl bit128
agrees. This bit affects damage eligibility in general, so it must not be masked
as universally irrelevant. The selected histories nevertheless have exact
trajectory agreement, including the eventual bounce, burn, landing and ground
actions. Strict equality of all the recorded fields is false.

`check.py` deliberately continues to fail on these records, with `passed=false`.
`diagnose.py` separately verifies that the difference is precisely the reported
subtype value and that the trajectory fields match. It does not silently turn
the strict failure into success. Every raw log, strict failure and diagnostic
is archived, together with the observer's exact field list and source hashes.

In source, `detect_object_hurtbox_overlap` sets bit2 before its distance test
and clears it on actual hurtbox overlap. The enclosing hitbox helper has a
missing-return path in unguarded source, whereas the AVOID_UB configuration
returns0 there. That is a possible explanation for differing far-away
bookkeeping, not a proved cause of this observation. Native call/return tracing
would be needed to establish the exact cause. No all-history source/retail
refinement theorem follows from these three matching trajectories.

## Reproduction

The [native package](../../instrumentation/jp-ink-flyguy-manipulation/README.md)
contains three `records/` directories with exact inputs, compressed Wafel/native
observations, failed strict receipts, successful scoped diagnostics and hashes.
Original runs are `capture.Kp9pbE` (roof), `capture.T0XKac` (flame-roof), and
`capture.lCtfIZ` (high-slide). No ROM, DLL, compiled plugin or source video is
redistributed. No new Coq theorem is claimed by this replay report.

**Conclusion:** high ground-action reachability is no longer merely supplied
in this particular intact-top predecessor. The usable low-cache/high-position
state and its useful warp/platform continuation remain unestablished. A high
ground action by itself is not an Ink handoff.
