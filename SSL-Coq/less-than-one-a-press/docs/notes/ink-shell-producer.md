# Working backward on the shell component

This finite investigation starts from proof commit `db1ba9d` and the
[successful supplied 973-unit handoff](ink-timer130-crawl-replay.md). It uses
the pinned Wafel 0.8.5 JP runtime, after new gameplay experiments and state
searches were authorized. It adds no Coq theorem or clean route.

**The shell's velocity edits can be removed. Its delivery remains open.**
The real spawned shell still gives the exact handoff when its native
velocities are retained and only its XYZ is supplied near Mario. Removing
the shell's Y edit makes this fixture fail: the native shell is at 968, far
below Mario's 1741. The ordinary way to transport a shell—riding it—does not
leave a free shell after a grounded Z dismount. The actual source and a no-A local
runtime control both delete it.

## Three handoff controls

All three controls restore the same full state at the start of top timer 130.
As in the previous fixture, shell box slot 32 is first supplied action 4 at
timer 128; two ordinary updates create shell slot 126. Mario's high crawling
state remains supplied. The script records all setup writes with their
previous values. No cached floor, surface, RNG or allocator field is edited.

| Shell setup | First update | Next update and continuation |
| --- | --- | --- |
| Original XYZ and four zero-velocity edits | M=C`(-1882,768,-939)`, D`(-1882,1741,-939)` | Top captured; Area2 outside elevator |
| XYZ only; native velocities retained | Same exact 973-unit result | Same top capture and Area2 point |
| X/Z only; native Y=968 and velocities retained | M=C`(-1950,768,-939)`, D`(-1950,1741,-939)` | No top capture; ordinary Area2 `(0,5500,256)` |

The retained native velocity is
`(0.0596383661031723,12,2.9814679622650146)` and forward speed
`2.9820644855499268`. Both successful controls reach the sampled Area2
position`(365.5927734375,5500,-1096.8026123046875)`. These are after-update
observations, not a new first-apply breakpoint trace. Their allocation
history includes the supplied box release and is not assigned the older
timer 131 allocation counts.

This removes four unnecessary supplied shell fields. It does not derive the
remaining position edit from a gameplay predecessor. The collision's lower
vertical-overlap requirement also explains why the968-height control cannot
touch Mario at 1741: the shell's ordinary 50-unit hitbox does not reach him.

## What the freely moving shell does

Two 120-update neutral continuations restore the same released-shell state,
leave Mario at the ordinary west-pillar prefix position, and keep the native
shell velocities. One leaves the shell at its real release position; the
other supplies only the proposed high XYZ.

| Start | Highest observed shell Y | Largest horizontal displacement | End |
| --- | --- | --- | --- |
| Native `(5840.11962890625,968,2505.971923828125)` |980|305.42016231390187|`(5846.22509765625,614,2811.3310546875)`, free action 0 |
| Supplied `(-1971,1741,-939)` |1753|298.81826234558685|`(-1965.0262451171875,1280,-640.241455078125)`, free action 0 |

These are trajectory measurements for these two histories, not global shell
height or distance bounds. In particular, the high sample is initially
supplied, and the moving top can change floor geometry during its history.
The native release remains near the distant box in this tested window.

The source explains the ordinary movement: `bhvKoopaShell` initializes gravity
−4 and its movement parameters; action 0 calls floor/wall handling and
`cur_obj_move_standard(-20)`. Its collision handler pushes Mario, rather than
giving the shell a new transport velocity. Source references in the sibling
decompilation are `data/behavior_data.c:2400–2406`,
`src/game/behaviors/koopa_shell.inc.c:61–103`,
`src/game/object_helpers.c:1163–1172,1195–1253,1280–1369,1787–1825`, and
`src/game/interaction.c:1460–1485`. These source facts are not a proof that
all possible clone, collision, culling or lifetime histories are covered.

## Releasing the real box without A

One component trial restores the ordinary four-pillar prefix and supplies
Mario at`(5840,1250,2500)` in freefall, with synchronized positions and zero
velocity. It presses Z on the first update, then gives 99 neutral updates.
The game's real ground-pound interaction moves the box into its break
sequence. A shell is released after 31 updates, in slot 154. No box or actor
field is edited in this trial. Its highest observed shell Y is1020.

Thus the direct box-action write can be replaced locally by an ordinary no-A
ground pound from this **supplied elevated approach**. The approach itself
has not been produced with controller inputs. This is not a clean shell
release proof, nor a continuation to the pyramid. The stock shell box is at
`(5840,940,2500)` (`levels/ssl/areas/1/macro.inc.c:29`). Its actual break and
contents-launch rules appear in `src/game/behaviors/exclamation_box.inc.c`
at78–175. The conditional custom-build hack in the local decompilation is
not used by the pinned retail-compatible Wafel DLL.

## Why riding then parking is not this producer

A local control starts from the same released shell, waits 35 ordinary
updates for it to settle, and supplies Mario nearby in walking action. The
actual interaction mounts the shell; no `riddenObj` field is patched.
The next update presses Z once. At global 2716 Mario is riding shell126;
at 2717 he is in crouch-slide action, `riddenObj` is null, and shell126 is
inactive. At 2718 that slot has been reused and no longer contains a shell.

This matches the source sequence: walking/falling-on-top mounts a shell
(`interaction.c:1460–1477`); ground-riding Z calls
`mario_stop_riding_object` (`mario_actions_moving.c:1200–1213`), which writes
`INT_STATUS_STOP_RIDING` and clears the ridden pointer
(`interaction.c:280–286`). Shell action 1 copies Mario's position and deletes
itself when that bit is set (`koopa_shell.inc.c:81–102`). It does not return
a freely pushing shell at the dismount coordinate.

The fixture requires an eligible actor while Mario is already crawling.
Ordinary transport by riding followed by grounded Z dismount therefore has a specific missing transition:
how to obtain the separate, free shell at the required position without the
normal dismount destroying it. A clone/ownership/lifetime alternative would
need its own concrete history. Other actors that can be carried and released
may be more direct candidates; this note does not exclude them.

## Controller-only approach screen

Eight small searches start after the first 650 inputs of the existing
controller replay. Every saved state in this screen is controller-reached;
there are **no gameplay setup edits**. Each branch gives 600 inputs, using
direct steering or one of seven waypoints toward the shell box, with B
every 20 updates once within 200 horizontal units. The input policy is
deliberately limited: it does not explore tornado, enemy-bounce, carried-box
or other elevation strategies.

All 4800 tested updates use no A. All eight branches leave the box in action 2
and produce no shell. Their final poses remain around the box's footprint
at Y=51, below the elevated box. This finite screen does not show the box is
unreachable without A. It identifies the missing height acquisition in these
simple approaches and justifies stopping this particular policy family.

## Commands and evidence

From `SSL-Coq/less-than-one-a-press` in PowerShell:

```powershell
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_shell_producer.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-shell-producer-20261111.json --receipt docs/notes/ink-shell-producer-receipt.json
```

Exit 0. All assertions for the three handoff controls, natural ground-pound
release, actual mount/dismount and eight approach branches pass. The
[receipt](ink-shell-producer-receipt.json) preserves every component setup
write, selected trajectory observations, all branch policy definitions and
input hashes, plus raw-report/script/baseline/runtime hashes. Full inputs and
samples remain in the ignored raw report. A separate read-only reconstruction
checks the compact receipt against that report without repeating gameplay.

The coverage counts above describe the final reproducible script. Preliminary
probes used to choose these controls are not counted as additional coverage.

No clean producer for the high crawl or shell placement is claimed. No
all-history shell exclusion, new Coq result, original-ROM replication of
these new trials, or universal allocator count follows.
