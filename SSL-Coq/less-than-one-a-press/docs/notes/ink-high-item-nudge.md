# High item nudges and their timing

14 November 2026. **Crazy Boxes, small breakable boxes, ordinary black Bob-ombs and non-mounting shells can all move Mario sideways at high Y. The tested nudges do not supply the missing ground action from high freefall.** A conditional already-riding state does work: after a native low shell mount, explicitly relocating the rider to high Y lets one grabbable push before Z cancels riding into the floor-aligning slide. This completes useful spawning displacement with each of the three grabbables at Y25000 and67277. The high relocation is still supplied; this is not a continuous allowed route or a solution to high-state delivery.

The bounded menu contains **82 recipes /2950 suffix updates /3044 independently matched boundary observations**. It starts at proof revision `3772fb57701ad0074c9a2016c366bed7e7e3ea24`. Wafel JP results, inputs, every write, actor snapshots and action/step events are preserved in `instrumentation/ink-high-item-nudge/`. This component is Wafel evidence. The subsequent [supplied-state original-JP validation](ink-high-item-nudge-rom.md) confirms two selected useful handoffs, with its comparison limits recorded separately. No new Coq theorem is claimed.

## Actors and exact grants

All four actor types exist in stock SSL Area1. The actual initialized objects in this prefix are:

| Actor | Slot / native behavior | Live radius × height | Interaction |
|---|---|---|---|
| Western Crazy Box | 49 / `bhvJumpingBox` | 75 ×125 | GRABBABLE |
| Small breakable box | 23 / `bhvBreakableBoxSmall` | 60 ×100 | GRABBABLE |
| Ordinary black Bob-omb | 39 / `bhvBobomb` | 65 ×113 | GRABBABLE |
| Koopa shell | 69 / `bhvKoopaShell` | 50 ×50 | KOOPA_SHELL |

The shell is created by the native shell-box callback after the disclosed preparation write `gObjectPool[32].oAction:2→4` at stored top timer125 and two neutral updates. This is a shell-availability grant, not controller acquisition. The accepted A-off four-pillar prefix is reused and credited to `ink-buddy-movement/original-prefix.jsonl.gz`; its original debug level-selection startup grant remains.

Airborne recipes supply M=C=D=(-1950,H,-939), `FREEFALL`, action state/timer0, forward speed20, velocity(20,-16,0), and facing yaw16384. H=25000/67277; six later timing controls use90536=25000+65536 to avoid the low edge of the +65536 height window. D always means stored `gfx.pos`, not the rendered model.

Actor cuts supply XYZ only. A single sideways nudge places the actor at current M plus X offset -39 for Crazy, -24 for small, -29 for black Bob-omb, or -21 for shell. With the current native radii, each first contact moves pre-action X from -1950 to -1882. A mount cut instead puts the shell at current X/Z and Y-10. Paired shell/grabbable cuts put shell to the west and the grabbable to the south, using the same offset magnitudes. Multi-update cuts are computed from the actual current M and their exact values are saved; they are delivered-position grants, not a demonstration that actors can autonomously follow Mario.

After the initial airborne cut, no Mario writes occur in the 48 airborne/staged recipes. Only declared actor XYZ cuts and A-off controller inputs are allowed by the write guard. Native actions, actor callbacks, collision lists, hitboxes, timers, floor/cache, platform and warp requests are never edited. No cloning behavior is installed in this menu.

The separate supplied-slide controls additionally write `BUTT_SLIDE` and its slide velocity/yaw fields. The separate relocated-rider controls instead make a native mount at the real low floor: from the inherited prefix X/Z, supply Y1034 over floor1024 and the same FREEFALL parameters, position the shell underneath, then advance with neutral input. The resulting action and ridden-object pointer are native. A second cut supplies only high M/C/D=(-1950,H,-939), preserving the riding action and pointer. This explicitly grants the high ground-action predecessor even though its action ID is not directly written at the high cut. No pickup/ridden pointer is written.

## Finite outcomes

| Family | Recipes | Captures | Useful Area2 arrivals | Meaning |
|---|---:|---:|---:|---|
| Airborne single nudges; all six ordered grabbable pairs; two three-grabbable orders, at25000/67277 | 24 | 0 | 0 | Real sideways movement, but airborne action remains; M/C/D coalesce after ordinary air movement |
| Nudge then shell/Z; shell/Z then next-update low grabbable; shell fallback plus grabbable then mount, including six90536 controls | 24 | 0 | 0 | Earlier nudge refreshes the wrong floor on the mount update; later nudge loses to warp ordering |
| Native low mount then supplied high rider relocation, three grabbables/two heights/two timings | 12 | 9 | 6 | Correct timing works for all three; high riding history remains supplied |
| Supplied butt-slide, four single-item nudges and three shell/grabbable pairs, with calibrated single-item controls | 22 | 12 | 8 | All four single-item controls work at both heights at the intended phase; supplied ground action remains a prerequisite |

All **14 useful controls** reach the same measured Area2 position `(365.5927734375,5500,-1096.8026123046875)` after25 suffix updates. Seven additional early controls capture the top but reach ordinary `(0,5500,256)`, so capture alone is not counted as useful. Negative recipes run45 updates unless Area2 is reached first. Some are still in a later ordinary-warp countdown at45, and some VPU air recipes have a death request pending; their ultimate post-countdown arrivals are not claimed. The exact intended producer failure is already observed.

### The working conditional timing

The table uses the **stored top timer before and after each native update**. This avoids confusing the behavior's current timer with the end-of-update increment. Use any of Crazy/small/Bob-omb, H25000 or67277, the relocated-rider control with basePhase129, and a single Z press at the high producer. The grabbable sits at (-1989,H,-939), (-1974,H,-939), or (-1979,H,-939) respectively.

| Update / stored timer | M=C | D | Action/cache/platform result |
|---|---|---|---|
| Native low mount,129→130 | (-5862.31787109375,1024,819.5643920898438) | Same X/Z, Y1069 | RIDING_SHELL_GROUND; floor1024; native ridden/used shell69 |
| Explicit high XYZ cut, timer130 | (-1950,H,-939) | Same | Riding retained; inherited cache1024, not edited |
| Producer,130→131 | (-1882,768,-939) | (-1882,H,-939) | Fresh floor768; zero top surfaces; grabbable pushes, RIDING_SHELL_GROUND executes, Z selects CROUCH_SLIDE, its handler aligns despite ending in GROUND_BONK |
| Acceptance,131→132 | (-1882,1818.9613037109375,-939) | Same | Low raw collision contacts warp64; high stored-graphics retry selects top61; DISAPPEARED; floor owner/platform61 |
| Retention, next22 updates | Native top-carried coordinates | Same | Platform61 remains through suffix update24, including top deactivation |
| Area2, suffix update25 | (365.5927734375,5500,-1096.8026123046875) | Same | Useful displaced spawn |

The gap on the producer is24232 for H25000 or66509 for H67277. The identical high position/action/pusher one update earlier (producer129→130) is an important negative: H25000 can capture but subsequently reaches the ordinary spawn; H67277 does not capture. The initial62-case timing pilot and later78-case calibration are preserved as overlapping records, not added to the final82 distinct recipes.

### Why the staged airborne attempts fail

At H90536, the clean timing comparison avoids dropping below the selected VPU window merely by falling16 units:

| Sequence | Before/after stored timer | Observed M=C / D / cache | First failed condition |
|---|---|---|---|
| Grabbable nudge T−1 |129→130| M=C=D=(-1882,90520,-939), SOFT_BONK, cached768 | The sideways position changed, but no ground action was made |
| Shell mount +Z at T |130→131| M=C=(-1882,1280,-939), D.Y90520, fresh cache1280 | Geometry refreshes floor at the new X/Z before mounting; the earlier768 cache does not survive |
| Alternative: mount +Z at T without prior nudge |130→131| M=C=(-1950,768,-939), D.Y90536, GROUND_BONK | Mount ends interaction processing before GRABBABLE, so no sideways crossing on this update |
| Put grabbable at low Mario on T+1 |131→132| M=C=D=(-1995,768,-971), DISAPPEARED, platform absent | Warp64 and the actor both register, but warp handling comes first and stops the later nudge |

The last alternative actually reaches ordinary `(0,5500,256)`. The other earlier-nudge controls have the same fresh1280 obstruction, including at H25000. These are finite histories, not a proof excluding every horizontal location or timing.

### Multiple pushes are real, but are not an action constructor

A non-mounting shell and a grabbable have different interaction types. At H25000, placing the shell at(-1971,H,-939) and Crazy Box at(-1950,H,-978) gives pre-action M=(-1857.22607421875,H,-924.6896362304688), with both actors in the collision list. The corresponding shell-only first push ends at(-1882,H,-939). The ordered shell-then-GRABBABLE source branches explain the additional diagonal correction. Small/Bob pairs similarly reach pre-action X/Z=(-1863.2362060546875,-932.4050903320312) and(-1860.7874755859375,-929.9195556640625). The runtime records action-entry positions and collision membership; it does **not** have a per-`push_mario_out_of_object` instruction hook, so attribution of the two ordered calls combines those observations with the source guards. In the supplied-slide controls these combined pushes overshoot the tested warp overlap; they are not useful captures.

Two GRABBABLE actors still do not both run in one interaction pass. The limit resets on the next update, but an older overlapping actor can continue to win selection. In the selected Crazy→small→Bob sequence, cuts on updates1/2/3 give collisions [49], then[49,23], then[49,23,39]. X remains-1882 until update8, when the old box no longer overlaps and the small box supplies another real push to-1814; M.Y is then24760. This demonstrates a later push without removing the first actor or editing any action. It remains SOFT_BONK and never constructs a high ground slide. Three items and repeated contact therefore cannot be treated as three automatically additive pushes.

The reverse order **Bob-omb → small box → Crazy Box** does obtain three consecutive shoves. All three actors are supplied only at their named contact cuts, and earlier actors remain live. At starting H=25000, the actual sequence is:

| Suffix update / stored timer | Selected plain-contact actor | End-of-update M=C=D | Action / fresh cache |
|---|---|---|---|
| 1 /128→129 | Black Bob-omb39 | (-1882,24984,-939) | SOFT_BONK /768 |
| 2 /129→130 | Small box23 | (-1814,24964,-939) | SOFT_BONK /1280 |
| 3 /130→131 | Crazy Box49 | (-1746,24940,-939) | SOFT_BONK /1280 |

Thus consecutive-update pushes exist in this menu. Their ordering matters because the new actor can take priority in the next collision list. They still leave Mario airborne, synchronize stored graphics with movement, and refresh the floor at the new location. Three shoves alone do not perform the handoff.

## Reproduction and scope

Review found that 14 early supplied-slide trials originally saved an `initial` metadata snapshot before loading their actual phase129 starting state. Their edit ledgers, `before` snapshots and all ensuing execution records were correct. The script now takes that initial snapshot after loading the actual start; the corrected full menu was rerun and independently compared. The original 82-case archive is retained as `initial-snapshot-metadata-pilot-82.json.gz`; only those 14 `initial` fields changed, with no changed trial outcomes or coverage.

Run from `SSL-Coq/less-than-one-a-press`:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-high-item-nudge/test.py
```

Final output is `PASS 82 3044`. Two fresh prefix reconstructions compare all saved trial structures exactly. The checker preserves A-off pads, declared cuts and native event order. `verification.json` records hashes and counts. Applicable stock JP source is `9921382a68bb0c865e5e45eb594d9c64db59b1af`, sibling decompile checkout `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`; Wafel0.8.5 /Python3.9.13, DLL SHA256 `960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`. No ROM/runtime binary is redistributed.

The source constraints are reviewed separately in the accompanying high-nudge source report. Earlier [unloaded-top entry](ink-high-unloaded-entry-followup.md), [replacement controls](ink-buddy-replacement-handoff.md), and [high Fly Guy contact](ink-flyguy-high-contact.md) are credited rather than repeated as new discoveries. No floor cache, rendering matrix, controller-reachable high riding state or delivery history is inferred from a supplied cut. Mario entry, actor delivery and a continuous joined route remain open. The useful new conditional target is precise: reach an already-riding ground action at the required raw high position before the130→131 update, with an ordinary grabbable overlapping before Z. The present experiments do not provide that predecessor.
