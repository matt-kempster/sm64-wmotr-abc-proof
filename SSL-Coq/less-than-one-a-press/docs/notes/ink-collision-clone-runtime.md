# Does a collision-only item improve the native landing fragment?

14 November 2026. **No useful Ink handoff was found.** Replacing the moving
Crazy Box with the explicit stationary-collider diagnostic below makes the
known early-box fragment fail even earlier: the low box never rises into
the required contact. Raising that fixed box instead shoves Mario during
the landing update. Neither gives top capture or a useful Area 2 arrival.
The normal moving-box control still makes the large gap and takes the
ordinary warp; that is a failed Ink installation, not a route success.

## What “collision-only” means in this test

This is **not a demonstrated genuine Crazy Box clone**. As the
[source review](ink-collision-clone-source.md) explains, Crazy Box has
`OBJ_FLAG_HOLDABLE`: ordinary grab/drop/throw selects its held-state branch
and does not replace its native callback with a carry script. A real
fake-pickup lineage for a different non-holdable actor is a separate task.

To test the user's proposed collision-only behavior explicitly, the setup
redirects the existing box's `curBhvCommand` to the actual
`bhvCarrySomething5` script and sets `bhvStackIndex=0`. The real behavior
interpreter executes BEGIN then BREAK. This suspends the jumping-box native
callback, while ordinary object updates, collision registration and Mario's
interaction handling continue. No repeated position freeze is applied.
The original behavior identity, GENACTOR list membership, hitbox, interaction
type, held state, velocities, tangibility and object flags are retained.

The observed box flags are the native HOLDABLE, COMPUTE_DIST_TO_MARIO and
UPDATE_GFX_POS_AND_ANGLE combination. They contain neither automatic X/Z
movement nor automatic Y movement. The inherited upward velocity therefore
remains stored but does not move this redirected actor. Every frozen trial
asserts that its XYZ is still exactly the supplied XYZ after the tested
continuation. In addition, all198 retained frozen-actor samples have unchanged
XYZ, checked against their initial recipe. Full traces record the command at the real BREAK, flags,
velocity, interaction status, timers and live hitbox dimensions. The box
retains radius75, height125 and down offset10; no arbitrary size is granted.

This diagnostic is more limited than a controller-reachable clone, but it
does directly test a fixed object retaining the usual box collision and
shove response. It is not implemented by replacing the whole game with a
simplified collision model.

## Same early Mario seed, no later writes

The investigation starts from the established four-pillar prefix, before
top behavior128. It supplies Mario in FREEFALL at
`(-1930,1837.8726806640625,-880)`, speed20, velocity `(0,-16,20)`, facing
`(0,0,0)`, action state/timer zero, with synchronized M/C/D.
All subsequent input is neutral; both A-held and A-pressed remain clear.
The write guard rejects non-controller edits after this initial setup.
There is no supplied floor/cache, platform, top phase, RNG, surface or
post-landing Mario adjustment.

Both the initial airborne Mario and actor position are supplied. The frozen
cases additionally supply the two interpreter-control fields above. The
native control makes14 Wafel writes (11 Mario plus3 box XYZ); frozen cases
make16. These count vector writes as one API write; the receipt lists each.

The same-X/Z cases keep the box at
`X=-1857.8465576171875, Z=-940.83349609375`.

| Actor case, supplied before128 | First failure/result | Behavior130 endpoint | Continuation |
| --- | --- | --- | --- |
| Normal moving box, initial Y1716.883544921875 | Rises into129 contact after native128 landing | M=C Y768, D Y1874.9208984375; gap1106.9208984375 | Ordinary warp; Area2 `(0,5500,256)`, no top capture |
| Fixed collider, same initial Y1716.883544921875 | Does not contact at129; required shove is missing | M=C=D `(-1829.7608642578125,1834.326904296875,-1039.095458984375)`; cached floor/platform remain top | No warp or large gap in33 updates |
| Fixed collider, Y1725.337646484375 | Contacts during128 and changes the landing | M=C=D `(-1826.0372314453125,1837.3345947265625,-1027.03271484375)`; top cache/platform | No warp or large gap in33 updates |
| Fixed collider, Y1729.791748046875 | Same premature128 contact; overlaps again at129 | M=C=D `(-1826.3155517578125,1844.4573974609375,-926.9195556640625)`; top cache/platform | No warp or large gap in33 updates |

At fixed low Y, Mario's128 native landing is unchanged:
`(-1930,1839.883544921875,-875.0875244140625)`, FREEFALL_LAND, platform61.
At129 he enters butt slide but remains supported at
`(-1856.980224609375,1869.673828125,-929.067138671875)` instead of receiving
the useful outward shove. Thus this failure precedes the low-cache and gap
conditions. At fixed Y1725.337646484375, the128 landing is instead
`(-1939.719482421875,1841.7647705078125,-867.0310668945312)` with box49
already in the collision list. These are observed native fields, not
inferences from a visible animation.

## Finite coverage and validation

The script tests1,030 recipes over4,120 initial update steps:

- Six normal moving-box controls at Y1716.883544921875,
  1721.883544921875,1723,1725.337646484375,1729.791748046875 and
  1839.883544921875.
- The same six placements as fixed colliders.
- 1,018 fixed-collider placements near the initial/post-landing horizontal
  contact boundary. Angles range0..65535 in steps256; candidate radii are
  108,110,111,111.5,111.9 around the unaltered landing X/Z, at two fixed Y
  values. Recipes are retained only when the initial horizontal distance
  is at least112 and the landing distance is below112. Exact rounded
  binary32 coordinates and distances are recorded.

Only two normal controls produce the known low-cache gap; all1,024 fixed
collider cases fail that producer screen. **Zero cases capture the top at
the acceptance update.** The horizontal-contact menu is a small targeted
screen, not a global search over clone positions or histories. Four-update
negative screens do not exclude a different later installation. In particular,
the screen's capture flag checks behavior131 only, not every possible later
capture or useful displacement.

The12 same-X/Z cases are continued up to33 updates, or the first Area2
arrival. Each is reconstructed from a second independent fresh Wafel boot
and prefix:384 recorded boundaries and event lists match exactly. The two
normal positive gap controls reach ordinary Area2 after27 updates; all six
fixed controls remain in Area1 after33, with no large movement/graphics gap
or top/warp capture. There is no new original-ROM replay in this study.
The earlier normal moving-box fragment already has its separate
[original-JP mode5 validation](../../instrumentation/jp-ink-mario-entry/README.md).

The proof base is `a1df2746333da67c3d4034eba71ad092fbd4103b`; the inspected
decompile revision is `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461` with its
existing local changes. Wafel0.8.5 JP DLL SHA256 is
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
The accepted prefix has SHA256
`9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72`,
including the disclosed pre-game debug level selection. The
[receipt](ink-collision-clone-runtime-receipt.json) pins the script, support
script and six applicable source files and preserves all screen recipes,
samples, inputs, full-case setup ledgers and actor state. Commands are in
[the reproduction README](../../instrumentation/ink-collision-clone/README.md).

## Route assessment

There is no new useful displacement result here. The ordinary moving box's
bounce helped time its contact; replacing it with a fixed collider does not
remove the hard timing problem in these tests. A genuine clone's acquisition,
species, live dimensions, actual delivery and joined Mario approach remain
open, as does any position/input history outside this finite menu. No new
Coq theorem or global impossibility claim is made; the route assessment and
subjective estimates are unchanged.
