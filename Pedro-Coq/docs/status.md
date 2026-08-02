# Status

The project currently establishes the source-level reduction, exact binary32
landing-speed witnesses, a concrete TTC spinner collision interval, the
random-mode timer/direction model, and a conditional dust-runtime projection.
It does not yet establish either ultimate gameplay claim.

For both supported versions, the new projection decodes the stock Mist and
white-puff behavior words, checks the normal object-list order and dynamic-next
walk, and computes the same-frame sequence Mist, WhitePuff1, WhitePuff2. Under
an initially clear active-dust bit and an isolated reserve of at least three,
the pool model accepts all three D/D/U allocations and the active-bit model is
set then cleared. The derived dust-only event list has four `random_u16` calls
on that frame: Puff1 X/Z in DEFAULT, then Puff2 X/Z in UNIMPORTANT.

This is not yet retail execution. The CompCert link theorem covers a
symbol-level structural slice, while the executable schedule is a separate
source-derived model. A reachable TTC tap must still establish a clear active
bit, enough reserve after competing allocations, and the absence or exact
effect of intervening RNG consumers. In particular, the global seed equals
four consecutive PRNG steps only under the explicit no-intervening-consumer
premise. The spinner's first opportunity to observe the post-tap seed is the
next frame because SURFACE precedes PLAYER, DEFAULT, and UNIMPORTANT.

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
next TTC milestones are therefore a wider or multi-interval geometry witness,
a reproducible reachable US/JP entry trace with pool/flag evidence, and a
complete linked-Clight execution/refinement for the dust chain.
