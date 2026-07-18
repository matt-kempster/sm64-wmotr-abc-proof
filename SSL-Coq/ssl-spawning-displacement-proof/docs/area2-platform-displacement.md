# SSL Area 2 Platform Displacement Bound

This note records the modeled first stale-platform displacement from the SSL
top-entry Area 2 spawn.  The formal version is in
`proofs/TargetPlatformEffects.v`.

## Scope

The claim is about the first update after entering SSL Area 2 through the
top-entry warp.  Mario starts at:

```text
(x, y, z) = (0, 5500, 256)
```

On that frame, `update_terrain_objects()` updates `OBJ_LIST_SURFACE` objects,
then `apply_mario_platform_displacement()` reads the stale `gMarioPlatform`
slot, and only later does `update_mario_platform()` recompute the pointer.

So the relevant Area 2 targets are the surface/platform objects that can update
before displacement:

- Area 2 macro exclamation boxes, if the stale slot were reused by one.
- Pyramid elevator.
- Four moving pyramid walls.
- Spindel.
- Regular Grindel.
- Two horizontal Grindels.

Non-surface objects are not useful first-frame targets in this model because
they do not run before `apply_mario_platform_displacement()`.

## Geometry Bound

The proof uses a conservative elevator-shaft footprint based on the pyramid
elevator collision object:

```text
x in [-511, 512]
z in [-255, 768]
```

The moving elevator is at `(0, 4966, 256)`, and its top collision surface is at
world `y = 5222`.

The visible high cage/rim around the shaft is modeled from static Area 2
collision as a top ring at approximately:

```text
y = 5734
outer x/z: x in [-409, 410], z in [-153, 666]
inner hole: x in [-101, 102], z in [154, 358]
```

To count as reaching the top of the cage/rim, Mario must be on the outer ring,
not in the inner hole, and at or above `y = 5734`.

## First-Frame Results

| Target slot reuse | Fields read by `apply_platform_displacement()` | Mario displacement | Resulting Mario position | Outcome |
|---|---:|---:|---:|---|
| Area 2 macro exclamation box | all useful fields zero | `(0, 0, 0)` | `(0, 5500, 256)` | Stays in shaft; not on cage top |
| Pyramid elevator | first update writes no useful fields | `(0, 0, 0)` | `(0, 5500, 256)` | Stays in shaft; not on cage top |
| Moving pyramid walls | vertical-only motion; `oVelY` is ignored | `(0, 0, 0)` | `(0, 5500, 256)` | Stays in shaft; not on cage top |
| Regular Grindel | vertical thwomp motion only | `(0, 0, 0)` | `(0, 5500, 256)` | Stays in shaft; not on cage top |
| Horizontal Grindels | first update has no useful X/Z/angular fields | `(0, 0, 0)` | `(0, 5500, 256)` | Stays in shaft; not on cage top |
| Spindel | `oVelZ = 5`, `oAngleVelPitch = 0x100` | approx `(0, -42.4, +87.7)` | approx `(0, 5457.6, 343.7)` | Stays in shaft; not on cage top |

The formal proof records the Spindel displacement with rounded integer bounds:

```text
(0, 5500, 256) -> (0, 5458, 344)
delta          -> (0, -42, +88)
```

That result is still inside the elevator footprint.  It is also below the high
cage/rim top and remains in the inner shaft/hole region, so it does not put
Mario on top of the cage bars.

## Why Most Targets Do Nothing

`apply_platform_displacement()` reads:

```text
oVelX
oVelZ
oAngleVelPitch
oAngleVelYaw
oAngleVelRoll
```

It does not read `oVelY`.  Therefore vertical-only objects can visibly move
themselves while producing no stale-platform displacement for Mario.

This is the reason the pyramid elevator, moving pyramid walls, and Grindels do
not help on the first stale update.  Spindel is different because it sets both
`oVelZ` and `oAngleVelPitch`, but its first active divisor-4 motion is too small
to move Mario out of the elevator shaft.

## Hypothetical Later Spindel States

These states are not first-load reachable for the stale update, but they are
useful sanity checks.  Even if Spindel were somehow observed in a stronger
active phase, the modeled displacement still does not clear the elevator
footprint.

| Spindel phase | Resulting Mario position | Clears elevator footprint? | Reaches cage/rim top? |
|---|---:|---:|---:|
| divisor 4, forward | `(0.0, 5457.6, 343.7)` | no | no |
| divisor 4, backward | `(0.0, 5540.4, 167.3)` | no | no |
| divisor 2, forward | `(0.0, 5413.2, 430.1)` | no | no; below `y=5734` |
| divisor 2, backward | `(0.0, 5578.7, 77.8)` | no | no; below `y=5734` |
| divisor 1, forward | `(0.0, 5318.5, 599.4)` | no | no; below `y=5734` |
| divisor 1, backward | `(0.0, 5649.0, -103.6)` | no | no; below `y=5734` |

## Formal Theorems

The main checked statements are:

```text
ssl_area2_first_update_platform_displacement_classification
ssl_area2_top_entry_spindel_first_displacement_delta
ssl_area2_all_first_update_platform_displacements_stay_in_elevator_shaft
ssl_area2_all_first_update_platform_displacements_do_not_reach_cage_top
ssl_area2_useful_first_update_platform_displacements_stay_in_shaft
```

Together they show that every modeled first-update SSL Area 2 platform target
either causes no Mario displacement or, in Spindel's case, causes a real but
bounded displacement that remains inside the elevator shaft and does not put
Mario on top of the cage/rim bars.
