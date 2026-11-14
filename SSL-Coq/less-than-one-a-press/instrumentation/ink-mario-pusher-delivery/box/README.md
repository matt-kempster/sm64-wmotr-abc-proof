# Mario-produced Crazy Box pickup and release

**Mario can acquire and release the western Crazy Box through A-off gameplay,
but this study does not deliver it to the useful Ink setup.** The closest
living free box in this finite continuation menu remains 1125.238 X/Z units
from the tested target and 579.932 units below it. Its first landing destroys
it. Both the pickup and release are real native events; no actor position,
held pointer, HOLP or action is supplied.

This follows the user's correction that "placing" must mean Mario places
the actors, rather than an experiment writing their XYZ. The separately
preserved preplacement compatibility result does not answer that delivery
question.

## Existing histories credited

The prior [Crazy Box delivery record](../../../docs/notes/ink-box-delivery.md)
already found the following real branches. They are not new discoveries:

* The accepted full recording acquires western box49 after input2677. At
  stored spinning-top timer130 Mario is still picking it up on low western
  ground. His eventual roof landing at input2776 consumes the box, after the
  top has entered its exploding action.
* The accepted first2500 inputs followed by the saved western approach
  acquire box49 and bounce onto the native western Fire Fly Guy. At branch
  update304 the native twirl interaction drops the box alive at Y1259.514893.
  It dies on landing at branch322. Only three pillars are credited.
* Eastern hands-free pickups also exist, but the prior transport study did
  not carry them to the pyramid. The accepted later three-pillar history
  has already destroyed that eastern box; those branches cannot be joined
  simply by taking a state from each.

The newer [native Fly Guy study](../../../docs/notes/ink-flyguy-native-manipulation-runtime.md)
continues the same real twirl to a high slide on the stationary top, after
the dropped box has died. The [lure study](../../../docs/notes/ink-flyguy-native-lure.md)
keeps an enemy alive and raises it near the roof in a different history
after the top has already disappeared. Neither supplies a surviving box
at the needed phase.

## Fresh test and exact grants

`check.py` replays the accepted first2500 inputs, then the existing saved
branch's first280 inputs. At that reached checkpoint Mario truly holds
western box49 in the third CRAZY_BOX_BOUNCE. The script then tests:

* The original next100 inputs as a positive control for a real elevated
  release.
* Twelve100-input steering continuations: Cartesian targets
  X=`-3600,-3300,-3000,-2700`, Z=`-1400,-1100,-800`, no buttons.

The sole noncontroller initialization is the inherited pre-entry debug
level-select flag. A guard then accepts only controller-pad writes. It
rejects A, and each native update checks Mario's A-pressed/down bits. There
are no position, action, actor, pickup/held/used pointer, HOLP, timer, health,
RNG or allocator writes. Whole-state branching restores only the reached
checkpoint. This still assumes the accepted debug-level-select entry; it
does not construct a castle-to-SSL prefix.

Two independently created native-runtime roots reproduce every saved value
for all13 continuations, including all1313 suffix boundaries. The menu is
1300 advanced suffix updates per reconstruction, not exhaustive control
coverage. The original control reproduces the earlier release exactly.

## Results

| Continuation | First live free box XYZ | Mario action on release | Box lifetime in branch |
|---|---|---|---|
| Original recorded inputs | `(-3223.68017578125,1259.514892578125,-1226.9027099609375)` | TWIRLING | Released304, inactive322 |
| Closest sampled target, steer toward `(-2700,-800)` | `(-3225.492919921875,1259.514892578125,-1194.014404296875)` | TWIRLING | Released304, inactive322 |
| Other local steering | Seven further live free releases; four continuations show no living free release | Twirling or backward air knockback for actual releases | All boxes inactive by322 |

Nine of13 histories have living free-release observations. Across all
sampled free boxes, the highest Y is1259.514892578125. The closest sampled
box is1125.238031595291 units away in X/Z and579.932373046875 below the
reference target `(-2102.720703125,1839.447265625,-1119.5618896484375)`.
Its three-dimensional distance is1265.8918536179244. All these distances
describe this menu, not a universal height or transport bound.

The exact target is a successful supplied recipe, not a proof that every
usable actor placement must equal it. These trials do not produce a free
actor in that local contact region at all. They retain three credited
pillars and an untriggered top, rather than the required spinning phase.
No useful handoff or displaced spawn is established by these histories.

## A release changes more than XYZ

The preplacement compatibility positive uses the stock Crazy Box's free
**action0**. An actual native drop in this fresh test leaves **action1**.
`jumping_box.inc.c` assigns action1 for HELD_DROPPED, and the thrown helper
also selects action1. Its free callback deletes the box after landing,
wall impact or water contact. Native holding and release therefore cannot
be substituted for the old XYZ cut while assuming all other fields remain
the same.

Normal HOLD_IDLE and HOLD_WALKING recognize a jumping box before ordinary
B/Z release handling and request CRAZY_BOX_BOUNCE. The bounce's third
landing consumes it. A useful delivery needs an interrupting interaction
or the separately established hands-free exception, followed by a living
released trajectory that intersects Mario at the right time. The Fire Fly
Guy interaction provides such an interruption here, but at the wrong
location, height and top state. It is not a successful throw or a parked
action0 box.

The next useful targeted experiment is to find a controller-reached
pre-fourth-pillar history that keeps the Fly Guy alive near the intended
release region while Mario still holds the western box. The existing
post-explosion lure and pre-fourth-box branches must be joined by actual
inputs, not state transplantation. Altering only the late24 inputs before
the existing contact is insufficient in this finite menu; an earlier
approach or a different release mechanism remains open. A longer blind
repeat of the same supplied placement would not address this failure.

## Reproduction and evidence level

From `SSL-Coq/less-than-one-a-press`:

```powershell
& './build/wafel-pilot/python/python.exe' 'instrumentation/ink-mario-pusher-delivery/box/check.py' --verify
& './build/wafel-pilot/python/python.exe' 'instrumentation/ink-mario-pusher-delivery/box/archive.py' --verify
```

`results.json.gz` preserves the accepted prefix, recorded branch prefix,
all13 controller suffixes, M/C/G, actions, floor/platform, native actor
state and HOLP observations. G means stored graphics `gfx.pos`, not the
visible model pose. This package is Wafel0.8.5/Python3.9.13 JP evidence;
it adds no original-ROM replay and no Coq theorem or global impossibility
claim. The old original-ROM ascent and acquisition checks remain separately
scoped in their existing records.

Proof checkout at study start:
`0605d842cedb55151e70952d56064553c4970f60`.
Applicable JP source pin:
`9921382a68bb0c865e5e45eb594d9c64db59b1af`.
Local decompile checkout:
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`.
Runtime DLL SHA256:
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
The archive pins the scripts, input receipts, native sources and artifacts.
