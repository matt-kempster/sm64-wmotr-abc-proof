# Counterfactual Later-Field Displacement

This note is deliberately hypothetical.  It does not say these fields are
available on the real first stale update after SSL Area 2 loads.  Instead it
records what would happen if a reused slot already contained motion fields that
some Area 2 objects normally acquire only later.

The formal statements live in `proofs/TargetPlatformEffects.v`.

## Top-Entry Setup

The modeled top-entry Area 2 spawn is:

```text
Mario = (0, 5500, 256)
elevator-shaft footprint: x in [-511, 512], z in [-255, 768]
```

`apply_platform_displacement()` can use:

```text
oVelX
oVelZ
oAngleVelPitch
oAngleVelYaw
oAngleVelRoll
```

It still ignores `oVelY`.

## Counterfactual Outcomes

| Hypothetical later field | Source behavior | Modeled result | Leaves shaft? |
|---|---|---:|---:|
| Direct X/Z speed up to 40 | Goomba/Amp/coin/1-up-style translation | within 40 units of spawn | no |
| Recovery heart `oAngleVelYaw = 1000` | low/default heart spin | `(238, 5500, 206)` | no |
| Recovery heart `oAngleVelYaw = 3000` | heart spin after Mario-speed input | `(695, 5500, 40)` | yes |
| Hidden 1-up `oAngleVelPitch = -0x1000` | airborne hidden-1up phase | `(0, 5694, -2003)` | yes |

The recovery heart is the most important caveat.  Its behavior can later set:

```c
o->oAngleVelYaw = (s32)(200.0f * gMarioStates[0].forwardVel) + 1000;
```

If that yaw were already present in the stale slot, yaw rotation about the
heart's Area 2 position could rotate top-entry Mario out of the elevator shaft.

The hidden 1-up is even stronger in this counterfactual model.  Its airborne
helper can later set:

```c
o->oAngleVelPitch = -0x1000;
```

If that pitch were already present, platform displacement sends top-entry Mario
far outside the shaft in Z.

## Checked Theorems

```text
counterfactual_direct_velocity_at_most_40_stays_in_elevator_shaft
counterfactual_recovery_heart_low_yaw_stays_in_elevator_shaft
counterfactual_recovery_heart_high_yaw_leaves_elevator_shaft
counterfactual_hidden_1up_pitch_leaves_elevator_shaft
counterfactual_later_initialized_fields_can_escape_elevator_shaft
```

So the current proof status is:

- Real first-update Area 2 spawning displacement remains bounded in the shaft.
- Counterfactually pre-populated later fields can escape the shaft for at least
  recovery heart yaw and hidden-1up pitch.
