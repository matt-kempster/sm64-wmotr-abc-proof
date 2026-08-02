# TTC spinner boundary

The TTC-specific target must distinguish three claims that are easy to blur.

1. **A spinner angle admits Pedro geometry.** This is a collision theorem over
   the transformed `ttc_seg7_collision_rotating_clock_platform2` mesh.
2. **Mario can enter that geometry.** This is a reachability theorem over the
   linked retail Clight program.
3. **RNG control preserves the usable angle regime.** This is a coupled theorem
   about Mario's dust taps, the global PRNG, and `bhv_ttc_spinner_update`.

The pinned random-mode behavior does the following:

- base pitch speed is 200;
- after a direction change, pitch speed is zero for five timer values;
- once `oTimer > 5`, the speed is multiplied by the selected direction;
- a new direction and timer are selected only after
  `oTimer > oTTCChangeDirTimer`;
- the change timer comes from `random_mod_offset(30, 30, 4)`, hence is 30, 60,
  90, or 120; and
- the direction-change frame itself retains the initial `+200` speed before
  resetting `oTimer`.

Consequently, "frozen" cannot mean that a random-mode spinner's pitch is
identical on every frame forever. The provable target should be a finite or
invariant interval of angles whose transformed collision continues to satisfy
the Pedro inequalities. A stopped-setting spinner can be exactly fixed, but
then spinner behavior does not itself provide the random-mode control problem
described by the historical strategy.

## Current exact result

`TTCSpinnerGeometry.v` proves a common strict X/Z witness at `(1045, 1603)` for
pitch values 15,856 through 15,951. The transformed floor is spinner 7 triangle
12 (source indices 5, 17, 16); the transformed ceiling is spinner 0 triangle 4
(source indices 12, 14, 15). Both placements use yaw 24,576. The certificate
computes with the generated collision, macro, and sine-table initializers,
CompCert binary32 operations, and the signed-16-bit terrain cast.

`TTCSpinnerSchedule.v` records a decisive limitation: this 96-unit interval is
narrower than one 200-unit random-mode movement. Starting just after a direction
change, timers 1 through 5 are stationary and timer 6 moves by
`200 * direction`; that frame exits the interval for either legal direction.
The theorem quantifies over every RNG observation, so adding dust-induced seed
advances cannot rescue this particular interval.

Community background describes the historical idea as keeping the upper red
coin spinner near a usable angle through the smallest possible random-mode
oscillation, not exact stasis:

- [TTC Pedro Spot RNG Manipulation](https://www.youtube.com/watch?v=qoc4i4S4N5Q)
- [Pedro Spot overview](https://ukikipedia.net/wiki/Pedro_Spot)

Those sources guide witness discovery only. The proof source of truth remains
the pinned decompilation and the generated Clight.
