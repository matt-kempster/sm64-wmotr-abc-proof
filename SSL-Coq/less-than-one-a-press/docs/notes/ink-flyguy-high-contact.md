# High Fire Fly Guy contact: supplied airborne entry diagnostic

The requested high-coordinate check fails to construct the missing ground action in the tested cases. At both Y=25,000 and Y=67,277, the game refreshes Mario's floor cache to **768** and registers contact with the native western Fire Fly Guy. Contact from above produces **TWIRLING**, while the tested side/below contacts produce **BACKWARD_AIR_KB**. Neither action reaches the ground-step/floor-alignment producer. Across 24 recipes through 45 updates, there is no stored-graphics split, warp contact, top capture, or useful Area 2 arrival. This isolates the action-construction problem after deliberately granting the high position; it is not a gameplay delivery result or a general impossibility theorem.

## Reproducible supplied setup

The package is `instrumentation/ink-flyguy-high-contact/`. It preserves the accepted A-off controller prefix, every setup write, all suffix inputs, update observations and event records. The prefix reaches four pillars, followed by neutral inputs until native top action 1/timer 129. No top phase is edited. Each recipe restores that boundary and supplies:

- Mario M=C=D=(-1950,H,-939), H either 25000 or 67277. D means stored `gfx.pos`, not the rendered model position.
- `ACT_FREEFALL`, action state/timer 0, facing yaw 16384, forward speed 0 or 20, and velocity (speed,-16,0). No ground action, floor pointer, cached height, platform or pickup pointer is supplied.
- Native western Fire Fly Guy slot 45 at (-1950,H+dy,-939), dy=-80,0,+80. Only its XYZ is changed: behavior, action, hitbox, scale, home and callbacks remain native.
- In half the cases, native Crazy Box slot 49 at (-1989,H,-939), again XYZ only. This actor placement has no controller delivery history.

The first suffix input is neutral stick with Z held; remaining inputs are neutral. A is released throughout the accepted prefix and suffix. A write guard permits controller fields only after the setup cut. The initial inherited floor cache is 1024; the first actual high-coordinate update replaces it with 768. The inherited used-object pointer is 55 and is not edited into a usable handoff pointer.

## Finite results

The Cartesian menu is 2 heights × 3 Fly Guy vertical offsets × 2 initial speeds × 2 box conditions = **24 recipes**. Every recipe runs 45 updates. All 24 register Fly Guy contact on the first update. All 1,080 resulting update observations have M=C=D; none contacts the upper warp actor 64.

| Fly Guy position relative to Mario | Recipes | First action | Action after 45 updates | Handoff |
|---|---:|---|---|---|
| 80 units below | 8 | TWIRLING | TWIRLING | None |
| Same Y or 80 units above | 16 | BACKWARD_AIR_KB | BACKWARD_AIR_KB | None |

For the zero-speed, box-present controls, the first update at native top timer 130 gives M=C=D Y=H+10 after the bounce, or H-16 after side contact. The floor cache is 768 in each case. The box can subsequently push X from -1950 to -1882, but this does not convert either airborne action into a productive ground action. Thus a fresh low floor cache and a sideways shove still do not suffice.

Four selected recipes were continued to their actual first non-airborne observation or Mario-object removal, rather than stopping at an arbitrary short fall:

| Initial H | Fly offset | Updates | Endpoint |
|---:|---:|---:|---|
| 25000 | -80 | 1899 | TWIRL_LAND at (-1882,1280,-939), long after the top's useful phase; no split/capture |
| 25000 | 0 | 340 | FEET_STUCK_IN_GROUND at (-1882,0,3293); no split/capture |
| 67277 | -80 | 94 | Mario object removed after floor sentinel -11000 and warpOp 18/sourceNode 241; last movement (-1882,66729.53125,-939), no useful Area 2 arrival |
| 67277 | 0 | 63 | Same terminal transition; last movement (-1882,66689,-939), no useful Area 2 arrival |

The final VPU rows contain stale MarioState values after `gMarioObject` becomes null; they must not be read as a physical landing or a retained live action. Immediately preceding observations record warp countdown reaching zero, playMode 4 and specialDestination -9. This diagnostic does not identify those transitions as the desired upper-warp handoff.

Two independently reconstructed Wafel roots reproduce all **28 trials and 3,504 boundary observations** exactly. The four long controls overlap the short menu and are not four new initial recipes. No complete handoff occurs. This is a supplied-state JP Wafel finite test, **not** an original-ROM replay and not an exhaustive contact/trajectory search.

## Meaning and remaining boundary

The higher coordinates remove the intact-top cached-floor obstruction seen in the native high-slide predecessor, but the tested Fly Guy body contacts produce airborne actions rather than crawl or a ground slide. This is the first failed requirement in this diagnostic; no actor-delivery issue needs to be invoked to explain these failures. Native body contact is not a ground support surface. The eventual Y=1280 twirl landing is real but too late and too low for this selected producer phase.

The result does not exclude a different multi-actor sequence, a genuine landing on a movable support, or a much earlier native flame/landing history. This menu does not force Fly Guy lunge/fire behavior and does not demonstrate a high flame contact. The next meaningful action-construction experiment would need a specified alternative transition into the ground-step handler; simply moving the same body-contact recipe higher does not resolve its first failure. No new Coq claim or global route exclusion is made.

## Versions and execution

Starting proof revision: `4813e95d33286a30882caf0759dd838c95ee48f2`, branch `codex/ssl-pyramid-item-proof`. Applicable stock JP source: `9921382a68bb0c865e5e45eb594d9c64db59b1af`; sibling decompile checkout: `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`. Wafel 0.8.5 / Python 3.9.13; JP DLL SHA256 `960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`. No ROM was modified or replayed for this diagnostic.

From `SSL-Coq/less-than-one-a-press` in PowerShell:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-flyguy-high-contact/test.py
```

Final output: `PASS 3504 matched boundaries`. The script compares an existing preserved result rather than silently overwriting it. The accepted prefix's uncompressed SHA256 is `9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72` and is asserted during reconstruction. Earlier native-manipulation files are separate and unchanged by this follow-up.
