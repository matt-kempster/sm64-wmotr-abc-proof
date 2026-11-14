# Native enlarged Bob-omb profiles for conditional Ink tests

14 November 2026. **A real enlarged Bob-omb can supply a larger contact hitbox,
but its released size is temporary.** This package reconstructs the established
clean regrab donor, observes its actual release and native growth, and tests
those exact donor fields in the current frozen-shell fixture. The donor is
controller-reached. Copying its fields into the later fixture is an explicit
diagnostic grant, not a continuous transport or Ink route.

The earlier [clean transport study](ink-bobomb-regrab-transport.md) deserves
credit for the 616-input enlarged-held boundary. Its canonical witness is
replayed unchanged, with no A inputs. The only non-controller initialization
is the established pre-entry `gDebugLevelSelect=1`. At input616, Mario holds
real eastern Bob-omb39 at fuse158, scale1.399999976158142, radius91 and
height158.1999969482422. No pickup reference, size, fuse or gameplay position
is supplied in that donor replay.

## What release actually leaves

Continuing with neutral inputs lets the pickup animation finish and the native
expired-fuse drop occur. No Z/drop-state edit is needed.

| Completed donor input | Held by Mario | Bob action / timer | Fuse | Radius / height | Meaning |
|---|---|---|---|---|---|
| 616 | Yes | Explode / 4 | 158 | 91 / 158.1999969482422 | Established transported held size; held callback delays explosion |
| 628 | No | Patrol / 0 | 170 | 91 / 158.1999969482422 | Native forced release, free and tangible |
| 629 | No | Explode / 0 | 171 | 91 / 158.1999969482422 | Expired free callback selects explosion |
| 630 | No | Explode / 1 | 172 | 65 / 113 | First growth update resets scale to1 |
| 631 | No | Explode / 2 | 173 | 78 / 135.60000610351562 | Native growth |
| 632 | No | Explode / 3 | 174 | 91 / 158.1999969482422 | Native growth |
| 633 | No | Explode / 4 | 175 | 104 / 180.8000030517578 | Native growth |
| 634 | No | Explode / 5 | 176 | 117 / 203.39999389648438 | Terminal size; still live at this boundary |
| 635 | No | Explode / 6 | 177 | Last stored size117 | Original actor is inactive; explosion is spawned |

These are observed states from this donor continuation, not universal fuse
bounds. In particular, terminal radius117 must not be described as the
radius of the transported held actor.

## What the common-fixture test supplies

[`profile.py`](../../instrumentation/ink-enlarged-bob-profile/profile.py)
exports `native_profiles()` and `install_profile(...)`. The first obtains the
two actual free donor boundaries at inputs628 and634. The second supplies
**32 scalar/vector fields** to the already initialized native Bob-omb39 in the
later frozen-shell fixture. These include native donor action/previous-action,
timer, held state, fuse/lit flag, blink timer, flags, interaction status,
tangibility, movement flags/velocities/angles, gravity/friction/buoyancy,
animation state, graphics scale/flags and hitbox/hurtbox dimensions. Every
write records its prior and copied value in the result artifact.

The recipient's existing interaction type2 and subtype256 are checked against
the donor and are not written. Its native `bhvBobomb` behavior and command
index11 are retained, as are allocation/list membership, parent, actual XYZ,
home and other world-specific fields. Cached floor pointers are not copied.
This is a selected native-field transplant, not an entire-object copy or a
claim that these two world histories have been joined. The existing shell's
conditional pickup/HOLP preparation and supplied initial airborne Mario remain
separate grants.

All profile writes occur before the initial high FREEFALL cut. There are no
later action, size, fuse, status or callback writes. The Bob-omb starts at its
existing distant coordinates. Its real 4000-unit distance guard pauses the
native callback while Mario is high and far away, although the ordinary
object action timer still advances. The test then makes one explicit Bob-omb
XYZ placement for contact on the next update. Native movement, explosion,
deletion and all spawned actors remain active afterward.

Six bounded histories compare stock65, released91 and terminal117, each after
shell/Z entry at top phase126 or127. Initial Mario is supplied FREEFALL at
`(-1920,19900,-1170)`, speed20, velocity `(0,-16,20)`, yaw0, and the frozen
shell ten units below; Z is used only on that entry update. The next update
places Bob39 at the prior collision position minus60 in X, with the same Y/Z.
All remaining controls are neutral. Each case registers actual collision with
Bob39 while Mario remains in `BUTT_SLIDE`. This small contact/lifetime test
does not itself add Box placements or claim an Ink handoff.

For entry at phase127, the **collision on phase128 sees radius91**. After its
native callback, the released donor remains radius91, changes to explode
timer0 and increments fuse170 to171. Subsequent completed phase129 and130
updates have radii65 and78; phase131 has91, phase132 has104, phase133 has117,
and phase134 deletes the actor. Terminal117 instead registers the first
phase128 collision and deletes during that same update's Bob callback.
Therefore search code must retain the native lifetime and cannot treat either
enlarged profile as a permanent pusher.

## Validation and remaining boundary

[`check.py`](../../instrumentation/ink-enlarged-bob-profile/check.py) recreates
the donor and all six receiving histories from independent fresh roots. The
full recorded projections match, including40 receiving-history boundary
snapshots, action events, M/C/G, collision lists, cache/platform fields and
native Bob dynamics. The script checks first contact, far/near fuse behavior
and eventual deletion for both expired profiles.

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-enlarged-bob-profile/check.py --verify instrumentation/ink-enlarged-bob-profile/results.json.gz
```

The fixture uses original-JP Wafel0.8.5 with Python3.9.13 and runtime SHA-256
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
The proof checkout for this follow-up is
`32f5eb4d5911b2e0a7972b748065c71ebe016717`; the applicable stock source pin is
`9921382a68bb0c865e5e45eb594d9c64db59b1af`, local decompile
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`. Donor controls retain SHA-256
`5fbabbad20efe0353072ac401279b81cc696415dd87621d905755b8dcf3e641b`.

This package adds neither original-ROM playback nor a Coq theorem. The useful
handoff search is a separate consumer of these profiles. The unresolved
delivery obligation is to bring the enlarged actor, Mario's usable shell/slide
entry, the other pusher and the top phase together in one allowed history.
