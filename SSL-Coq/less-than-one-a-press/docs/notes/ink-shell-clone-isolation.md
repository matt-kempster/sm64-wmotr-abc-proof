# Initialized frozen shell: pickup, release and mounting

14 November 2026. **The mountability hypothesis works in this conditional
JP Wafel experiment.** A native initialized above-water shell survives a
native fake pickup, drop or throw with its shell interaction and 50-by-50
hitbox intact. A low dropped-clone control remains in RIDING_SHELL_GROUND
with a native ridden reference for all four checked updates. A high thrown
clone also accepts an above-contact mount, but the exact high controls bonk
or cancel during that same update. They do not supply the requested next-update
high riding bridge or a useful Ink arrival.

This package independently reproduces **228 update boundaries** from two
fresh roots. It includes one 17-update pickup, six 24-update releases, sixteen
four-update contact controls and three one-update predecessors for repeated
contact. These are finite supplied-state diagnostics, not a controller-reachable
clone or delivery route. No new Coq or original-ROM result is claimed here.
The later bridge and delivery studies are separate components.

## What is supplied, and what the game actually does

The inherited four-pillar A-off prefix ends at global timer 2549, with the
fourth pillar recorded but the top still in action 0/timer 2201. Supply shell
box slot 32's action as 4, then advance two neutral updates. The real shell-box
callback creates shell **slot 71**, and its real shell callback initializes
the hitbox. The resulting boundary is global timer 2551, top action 1/timer 1.
This earlier spawn differs from the older timer-125 shell preparation, whose
shell occupied slot 69. Slot numbers must not be transferred between them.
The shell-box action change is an availability grant, not a real box opening.

Supply Mario M/C/G=(5900,51,3380), IDLE, state/timer zero, zero velocity and
forward speed, and face angles zero; supply the live shell raw XYZ=(6100,51,3380).
Press B once, then neutral. Real contact with the native small box 23 enters
PICKING_UP. After update 4, supply only `usedObj=slot71` instead of slot 23.
Native update 6 performs the fake pickup, assigning the held reference,
parent and stopped carry script. Update 17 reaches HOLD_IDLE at global timer
2568/top timer 18. The pickup action, held pointer, parent and script are not
directly supplied.

Each release branch restores that held boundary. Z on its first update drops
immediately; B starts a throw and releases on its seventh update. All later
inputs in the 24-update release are neutral. For the high throw, immediately
before throw update 7/actionTimer 6, supply HOLP=(-1950,H-10,-971). The native
throw places the actor at (-1950,H-10,-939), installs carry 5 and clears the
held reference. Release occurs at global timer 2575/top timer 25; the final
release observation is global timer 2592/top timer 42. H is separately tested
at 25000, 67277 and 90536=25000+65536. No continuous height interval follows.

The high-HOLP drop control instead supplies HOLP before its first Z update.
It places the shell at (-1950,51,-971): drop uses HOLP X/Z but Mario's Y=51.
The high-HOLP throw genuinely uses the supplied high HOLP Y. Neither control
demonstrates reaching that HOLP or getting Mario above the released shell.

No interaction type, hitbox size, tangibility, interaction status, shell
velocity, object allocation/free list, floor cache, platform, ridden pointer,
shell action or behavior command is edited. Shell XYZ is edited only for
initial pickup preparation and the separate live comparison. All writes are
guarded and recorded. The original prefix's debug level-selection startup
grant remains; every controller A-down and engine A-input check is clear.

## Retained shell state

The released frozen shell retains flags 1073741825 (0x40000001), with no
HOLDABLE bit, held state 0, native behavior identity `bhvKoopaShell`, shell
action 0, intangible timer 0, interaction type 524288 (0x80000), and hitbox
radius/height 50/50. The release scripts settle at carry 4 BREAK or carry 5
BREAK. Nonzero inherited shell velocities remain in memory, but the stopped
script does not execute the shell's native movement callback; the high thrown
actor stays at the released raw position throughout the checked continuation.
These observations follow real initialization and native release rather than
manufacturing an object by writing a shell interaction type onto it.

## Above-contact outcomes

For a high contact, supply Mario M=C=G=(-1950,H,-939), FREEFALL, state/timer 0,
forward speed 20, velocity (20,-16,0) and face yaw 16384. The already-thrown
shell is ten units below. There are no subsequent Mario or actor writes
within each four-update contact control. A separate live-shell comparison
uses the same pose and places the still-native initialized shell underneath;
it starts from the earlier initialized boundary, not the later release phase.
Thus the controls test mount compatibility, not phase-identical whole-world
equivalence. The bridge study separately tests the useful top phase.

| Control | Observed first update | What it establishes |
| --- | --- | --- |
| Low native dropped clone; Mario placed ten units above it | RIDING_SHELL_GROUND, native ridden=71; riding persists four updates | The frozen initialized shell remains genuinely rideable on real low ground. |
| High native thrown clone, no Z; each of H=25000,67277,90536 | Collision list contains 71; native transition and execution of RIDING_SHELL_GROUND; native ground-step call followed by BACKWARD_GROUND_KB and ridden=null. M/C remain at H; G.Y=H+45. | Mount succeeds, but the required action does not survive to the next update in these placements. |
| Same high clone with a fresh Z press | Native mount then cancellation/slide; final GROUND_BONK, M/C.Y=768, G.Y=H | The immediate cancellation makes a split, but does not provide the sideways correction or the requested next-update bridge. |
| Live initialized high shell, with/without Z | Same first-update action classes as above | The failure is not caused simply by freezing the shell callback. |
| Second high contact after the first Z contact | A new supplied FREEFALL pose again mounts the frozen shell; held Z has no new edge, so the second mount bonks | The retained STOP_RIDING status does not make this shell permanently unmountable. This is a diagnostic pose cut, not a real repeated-jump history. |

The native low riding control leaves shell status **49155=0xC003** and shell
action 0 throughout its four updates: the stopped script does not process the
native shell callback's status transition/reset. The high bonk and cancellation
instead leave **4194304=0x00400000**, STOP_RIDING. That value lacks the
INTERACTED bit 0x8000 tested by the outer interaction loop. The second-contact
control confirms a fresh native mount without any status reset. Its two Z
pads are consecutive, so the second one is held Z rather than a new press.

The logs include shell collision membership, active/tangible state, status,
script and dimensions; Mario M/C/G, action, ridden/held/used references,
floor/cache owner, ceiling, top phase and warp state; and native action/ground
step events. G means Stored Graphics (`gfx.pos`), not the rendered model pose.
The event payload's `_placeholder` is not decoded as a ground-step return
value. Return 2 is a source-derived explanation of the high raw-Y/default
ceiling guard and subsequent shell bonk, not a separately decoded runtime
return in this package.
No useful displaced spawn is tested or claimed by these short isolation cuts.
No-Z exits riding immediately, and same-update Z begins the ordinary warp
path in these coordinates. Actor delivery and the delayed bridge remain open.

## Reproduction and provenance

Run from `SSL-Coq/less-than-one-a-press`:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-shell-clone-isolation/test.py --verify instrumentation/ink-shell-clone-isolation/results.json.gz
```

The script exports `roots`, `pickup`, `release`, `mount`, `snap` and `step`
for the follow-up bridge/original-ROM harnesses. `roots` returns game,
observer, slot, initialized save state and the preparation ledger. `pickup`
returns its record and held save state; `release` returns its record and
released save state. Serialized save states are not distributed: the prefix
and declared inputs/cuts reconstruct them.

Proof start is `162617b708b2244beca85af58b76ad5794e598cd`, after reading the
two requested high-nudge reports at `08df00c605127a172d3a28049e31d6f50f7bff98`
and the newer box-floor study. Decompile checkout is
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`, stock JP source pin
`9921382a68bb0c865e5e45eb594d9c64db59b1af`; Wafel 0.8.5/Python 3.9.13,
DLL SHA256 `960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
The uncompressed inherited prefix SHA256 is
`9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72`.
The package receipt pins source, result and note bytes. No ROM/runtime binary,
new gameplay route or new theorem is included in this isolation component.
