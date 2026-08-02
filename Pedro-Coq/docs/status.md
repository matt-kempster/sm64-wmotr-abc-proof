# Status

The project currently establishes the source-level reduction, exact binary32
landing-speed witnesses, a concrete TTC spinner collision interval, and the
random-mode timer/direction model. It does not yet establish either ultimate
gameplay claim.

The most important factual correction to the motivating chatbot summary is
the timing: `AIR_STEP_LANDED` does not directly create dust. It selects a
landing action. On the landing action's frame, `common_landing_action` first
changes forward velocity, performs a ground step, and only then sets the dust
particle bit if the resulting forward velocity is strictly greater than 16.

The TTC geometry certificate uses spinner 7 triangle 12 as the floor, spinner 0
triangle 4 as the ceiling, and the common horizontal point `(1045, 1603)`. For
every pitch from 15,856 through 15,951, CompCert binary32 transformation and the
signed-16-bit terrain cast produce strict horizontal containment and a plane gap
in `(0, 160]`.

That interval is not a bounded-oscillation target. The schedule proof shows
that, after the five stopped timer values, the next frame moves by 200 in either
direction and exits the interval independently of all RNG observations. The
next TTC milestone is therefore a wider or multi-interval geometry witness,
followed by a reachable entry and linked dust/object-schedule proof.
