# Native western Fire Fly Guy luring and flame-assisted roof entry

14 November 2026. **Mario can use the native western Fire Fly Guy's flame to
reach the roof, finish burning, enter crawl, and keep the enemy alive while
luring it upward. This tested chain occurs after the pyramid top has already
exploded, so it does not produce a usable Ink handoff.** A finite attempt to
transfer the route before the fourth pillar did not reproduce the living-enemy
roof setup.

This is Wafel 0.8.5 JP evidence starting from proof revision
`4813e95d33286a30882caf0759dd838c95ee48f2`, decompile checkout
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461` and stock source pin
`9921382a68bb0c865e5e45eb594d9c64db59b1af`. The inherited runtime DLL is
SHA-256 `960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
All controls keep A released. Only the existing debug level-selection startup
is supplied; the guard permits no later writes except controller buttons and
stick. No Mario pose, action, velocity, enemy position/home, floor cache, RNG,
HOLP, object pointer or top timer is supplied. Full-state restores branch only
from states reached by the recorded inputs.

## An actual living-enemy predecessor

The existing baseline's first 2,740 inputs, followed by 70 updates steering
toward `(-3400,-1120)` with no buttons, reach a west roof ledge. At completed
input 2810 Mario is at `(-2870.190185546875,1024,-963.3748168945312)` in
STOMACH_SLIDE_STOP, with movement, collision and stored graphics equal and
cached static floor1024/type48. The western Fire Fly Guy is still its native
slot45, alive at `(-3400,1160,-1120)`, beginning its approach action. It has
not been consumed by a twirl bounce. The prior top is already gone.

From this reached state, 32 fixed/wait/roof steering policies perform 7,789
updates. They really move the native enemy: the largest sampled Fly Guy Y is
1585.856201171875, and another policy brings it to
`(-2263.615478515625,1353.955322265625,-910.7750244140625)`, about498.954 units
from the local target `(-1950,1741,-939)`. These are different histories and
neither is an Ink installation. All 32 uncontinued fixed-target policies
eventually fall into quicksand. Several receive native fire and enter burning
actions before that failure.

## Flame, roof, natural burn expiry and crawl

One policy waits60 updates at the ledge, then steers toward `(-2100,-1700)`
with Z held. After277 suffix updates, at completed input3087, Mario reaches
`(-2548.43896484375,1280,-1343.7554931640625)` in BURNING_GROUND. His floor
is the real static roof at1280. The Fly Guy remains alive at approximately
`(-2910.1821,1304.1334,-937.2231)`.

Steering straight onward loses the roof. A new circular steering policy keeps
Mario on actual support until the burn expires. The selected policy targets
a point on a radius350 circle centered at `(-2048,-1024)`, 0.4 radians ahead
of Mario's current polar angle in the positive direction. The stick magnitude
is64; buttons are zero while burning and Z afterward. The exact controller
stream, rather than this geometric description, is authoritative.

| Completed input | Actual Mario state | Native Fly Guy result |
| --- | --- | --- |
| 2810 | STOMACH_SLIDE_STOP at Y1024, static cache1024 | Alive at original home |
| 3087 | BURNING_GROUND at Y1280, static cache1280 | Alive; real flame supplied the earlier burn |
| 3138 | Burn expires naturally to WALKING at `(-1732.2095,1280,-958.3782)` | Alive; no enemy edit or respawn |
| 3174 | CRAWLING at `(-1723.0835,1280,-1318.9307)` | Alive at approximately `(-2896.8491,1331.7687,-941.4921)` |
| 3310 | CRAWLING at `(-2074.6646,1280,-1364.8579)` | Actor reaches `(-2182.48291015625,1735.033447265625,-1086.2354736328125)` during spiral recovery |
| 3487 | CRAWLING at `(-2379.4497,1280,-1048.8916)`, health1446 | Alive at `(-2516.9023,1604.6527,-1748.4000)` |

Mario's Y remains1280 at the useful stable roof milestones; **the1735.0334
height belongs to the enemy**, not Mario or his stored graphics. The sampled
movement/collision/graphics records agree at these milestones. No fresh768
cache, top capture, retained platform or displaced Area2 arrival is established.
Once the original top is deactivated, its pool slot can be reused: the
observer's `topNative=false` flag prevents interpreting later raw slot61 timer
or pillar fields as the original top's phase.

The circle sweep tests18 radius/lead/direction policies over6,928 updates.
Several survive the400-update horizon; others take damage or fall. The selected
3,487-input history is preserved separately for original-ROM comparison by the
parent investigation. This note itself claims the fresh Wafel reconstruction;
the separate ROM comparison must state its actual field matches and differences.

This is ordinary near-enemy luring and spiral recovery. In the selected circle
suffix, actual Mario/enemy distance stays at most1251.6721 and enemy distance
from home at most1670.8149. It therefore does **not** demonstrate the video's
4000-unit activation-boundary stop/start method or arbitrary lateral/vertical
transport. The video's technique remains a different potential extension.

## Attempted transfer before the fourth pillar

The stronger earlier Box-to-Fly history is credited to
[the existing box-delivery study](ink-box-delivery.md) and the concurrent
[native manipulation investigation](ink-flyguy-native-manipulation-runtime.md).
Its accepted original prefix2500, real Box pickup via waypoint `(-5500,2300)`
and A-off travel leave three pillars touched and the top untriggered. It
normally bounces on Fly Guy at completed input2804, consuming that enemy.

To preserve Fly Guy for the flame route, the new finite menu changes only
controller steering at eight actual prefixes:2700,2720,2740,2760 and
2780,2790,2795,2800. Each cut has six named target directions and two landing
wait policies. The96 nominal recipes contain repeated histories when they
never reach the wait condition; they are not96 independent successes or
exhaustive input coverage.

The48 later recipes perform722 updates:46 consume the enemy in a twirl bounce
and two die in quicksand while the enemy remains alive. The48 earlier recipes
perform5,742 updates: eight consume the enemy; the remaining40 fall into
quicksand. Four nominal early recipes receive fire, but none establishes the
living-enemy roof support needed by the circular continuation. The first
specific failure is either the body bounce consuming the actor or missing
safe support before the flame-assisted ascent can be established. Neither
failure proves that all earlier steering, pickup headings, burn contacts or
activation histories fail.

## Reproduction and verdict

The [instrumentation package](../../instrumentation/ink-flyguy-native-lure/README.md)
preserves all four batches, the complete selected input stream, observations,
scripts and SHA-256 receipts. Fresh guarded reconstruction matches **21,181
suffix observations across146 stored history executions**. Their shared
prefixes and repeated policies are explicit. No Coq theorem is added here.

The actor movement and flame-to-ground-action components are real A-off
gameplay results. Their first decisive limitation for Ink is timing: the
demonstrated stable route has no live top, and Mario's roof cache is1280.
The tested pre-fourth transfer has not supplied its living-enemy predecessor.
The best next experiment is an earlier Box pickup/launch heading that reaches
the west ledge with Fly Guy alive before triggering the last pillar, followed
by the preserved flame/circle policy and a separately reached final-pillar
timing. This study establishes no complete Ink handoff, universal height bound
or impossibility result.
