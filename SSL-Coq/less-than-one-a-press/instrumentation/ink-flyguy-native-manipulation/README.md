# Native Fly Guy bounce, high landing and stationary-top push controls

The new controller continuation reaches **BUTT_SLIDE at Y1768** after a real
western Fire Fly Guy bounce. It lands on the still-stationary pyramid top with
three pillars credited. The ground action and height are real, but this is not
a useful Ink producer: the live floor cache remains the top height, and the
tested single-box placements never produce a movement/stored-graphics split.

The existing `docs/notes/ink-box-delivery.md` is credited for the earlier
pre-fourth pickup/bounce prefix and Y2099.5149 airborne height. The new result
is the controller braking/landing/ground-action continuation, plus the actor-only
tests from that reached state. A separate post-explosion history reaches a
Fly Guy twirl, lands at Y1280 and enters crawl; aiming it at the warp instead
gives only the ordinary Area 2 arrival.

All primary histories use A released, no held-A assumption, and no gameplay
state writes. The inherited debug level-selection startup is the only grant.
`search.Guard` restricts writes to the controller and checks native A input bits.
The small-box component tests separately disclose one native box23 XYZ placement
per trial; they edit no Mario, floor/cache, top phase, action, RNG or references.
They are not actor delivery histories.

From `SSL-Coq/less-than-one-a-press`:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-flyguy-native-manipulation/verify.py
```

This fresh replay passes **1,120 stored history executions / 93,085 observations**.
Counts include overlapping prefix/selected histories; they are not independent
discoveries. The observer checks exact M/C/stored graphics, action, floor/cache,
platform, top fields, RNG and western Fly Guy state. `topNative` and `topActive`
were added before the pre-fourth and component studies. The earlier post-top
records retain the original fields; `native-roof-identity.json.gz` independently
records actor/top identity on the same 3,097-input stream. Raw slot61 values
after its old top is removed must not be read as a new top phase.

| Preserved batch | Histories | Suffix updates | Scope |
| --- | ---: | ---: | --- |
| `flyguy-approaches-v1` | 80 | 9,822 | Real prefix diversions toward Fly Guy/roof; two button-equivalent policies find the post-top bounce. |
| `flyguy-twirl-land-v1` | 40 | 6,926 | Post-top twirl landing/warp continuations. |
| `flyguy-buddy-approach-v1` | 28 | 3,337 | Alternative real three-pillar box pickup; all tested continuations fail before Fly Guy contact. |
| `flyguy-pre-fourth-land-v1` | 90 | 17,492 | Intact-top direct steering and delay menu after the credited native bounce. |
| `flyguy-pre-fourth-brake-v1` | 100 | 14,020 | Aerial braking menu; best observed ground-slide height1768. |
| `flyguy-stationary-box-v2` | 780 | 35,100 | One actor-only XYZ cut at each of four reached high states; 520 initial registrations, zero gaps or warp contacts. |

The initial 195-case stationary-box menu is contained in the expanded 780-case
menu and is not counted twice. Search recipes and complete inputs/samples are
inside each archive. The exact full selected histories are
`native-high-slide-inputs.jsonl` (2,869 inputs) and `native-roof-inputs.jsonl`
(3,097 inputs), with matching Wafel traces and receipts. The root task records
any original-ROM comparison in its separate native instrumentation package;
these Wafel receipts alone make no new original-ROM claim.

`search.py` can rerun the named search modes into a new output file. The mode
`pre_fourth_land` uses the archived exact prefix after preservation, rather than
requiring the large ignored 2026-11-11 exploratory file. `preserve.py` and
`preserve_high.py` reconstruct the selected histories. Their local Wafel loader
uses the established authenticated JP DLL, which is not redistributed here.
`stationary_box_probe.py` recreates the expanded actor-only menu and refuses to
overwrite its original ignored output. No ROM, DLL, saved state or compiled
emulator plugin is included.

Read [the runtime report](../../docs/notes/ink-flyguy-native-manipulation-runtime.md)
for exact milestones, the first failed handoff condition and remaining scope.
