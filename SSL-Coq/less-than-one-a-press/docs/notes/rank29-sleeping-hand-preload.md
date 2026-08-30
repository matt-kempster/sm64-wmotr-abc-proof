# Rank 29: sleeping-hand Pedro preload audit

## Result

No independent stock no-A speed source has been found.  More importantly, the direct-source search is now finite and checked: normal entry clears Mario's speed, the Area 2/Area 3 instant warp merely carries forward whatever speed already exists, the complete Area-2 and Area-3 object roster contains none of the usual large-speed actors, and a sleeping Eyerok hand cannot bounce Mario.  Under a deliberately generous ordinary-episode model, Mario reaches at most speed `170`, giving a `42.5`-unit air quarter-step; the Pedro entry needs directional speed over `400`, giving a quarter-step over `100`.

This does not yet close Rank 29 for every clean controller history.  It reduces the route to one concrete residual: a repeatable moving-platform, landing, or `OFF_FLOOR` transition would have to preserve accumulated air speed across separate airborne episodes without passing through an ordinary speed cap or damping step.  Finding that cycle would be a genuine new speed source.  Proving that every live episode boundary carries Mario with its floor owner or performs the normal cap/damping operation would close the remaining in-model route.

## Why speed 424 was not a source

The archived US retail fixture remains useful, but it starts by injecting a long-jump state with forward speed `424`.  The following retail update leaves speed `422.650`, crosses the greater-than-`100` wall band in one intended quarter-step, selects the sleeping-hand floor beneath the nearby ceiling, and takes the Pedro landing branch.  That authenticates the collision payoff.  It does not explain how a no-A run obtains the starting action or speed, so it cannot bootstrap itself.

## What the generated source now authenticates

| Boundary | Checked result | Consequence for Rank 29 |
|---|---|---|
| Normal Mario initialization | Both selected US and JP bodies assign `forwardVel = 0` | Speed made outside the pyramid does not survive the normal SSL entry path |
| Area 2/Area 3 instant warp | The body does not read or write `forwardVel`; the existing abstract warp theorem preserves the kinematic core | The warp can transport a preload but cannot create or amplify one |
| Area-2 scripted objects | Exactly two poles, three Grindels, one Spindel, four moving walls, one elevator, three sound loops, and the two star objects | No cannon, shell, Hoot, Tweester, Heave-Ho, Chuckya, Fly Guy, or jumping box is hidden in the scripted list |
| Area-2 macro objects | All 50 records decode to coins, signs, Goombas, Amps, a heart, 1-ups, switches, or star triggers | The macro list adds none of the missing large-speed actors |
| Area 3 | The only scripted actor is the Eyerok boss and the macro list is empty | The boss and its hands are the only local actor family that could add a source |
| Sleeping hand | The action-zero branch calls the sleep handler and skips the unique `obj_check_attacks` call, while collision loading still occurs afterward | The hand supplies the Pedro floor geometry but not its ordinary attack/bounce interaction while asleep |
| Spindel | Its checked behavior is a moving collision owner, not an attack or twirl-bounce interaction | Riding it may move Mario's position, but it does not install the required forward speed |
| Long jump | The existing provenance kernel puts both stock long-jump constructors behind an A edge unless an action transition is forged | The injected long-jump fixture is not a clean no-A predecessor |

The roster result is deliberately about the selected level initializers.  A claim involving a forged behavior, a corrupted spawn table, an out-of-bounds write, or another post-undefined-behavior machine continuation is outside the successful in-bounds CompCert execution model rather than an unfinished stock source.

## Direct movement bounds

The ordinary walking update caps forward speed at `48`; even granting the largest checked downhill slope addition afterward gives `53.3`.  Sliding has the familiar one-frame-late cap: the slide vector is normalized to `100`, and one following maximum downhill addition can expose a scalar speed no larger than `110` before the next normalization.  Fixed interactions in the Area-2 roster are smaller.  The proof therefore begins an ordinary airborne episode with the deliberately favorable cap `110`, rather than the lower values expected on the actual route.

At positive speed above the ordinary drag threshold, each regular air update first moves speed `0.35` toward zero, can add at most `1.5` from perfectly aligned full analog, and then subtracts `1`.  The largest net gain is consequently `0.15` per frame.  Starting from `110`, the first `1,933` such updates reach at most `399.95`; update `1,934` is the first arithmetic opportunity to exceed `400`.

That many uninterrupted airborne updates do not fit in the selected areas.  The checked static meshes fit inside the deliberately widened vertical envelope `[-5000,7000]`.  Grant an initial vertical speed of `100`, gravity of only `1` per frame, and terminal velocity `-75`; these are all more favorable than the ordinary actions of interest.  The first 400 vertical updates have total displacement at most `-14600`, which is greater in magnitude than the envelope's entire `12000`-unit height.  Thus even a 400-frame ordinary episode cannot keep both endpoints in the envelope.  Granting all 400 horizontal gains anyway yields only speed `170`, or `42.5` units per quarter-step.

This is an episode bound, not permission to concatenate episodes for free.  A normal landing, walking frame, slide normalization, or reinitialization brings the next episode back under the checked starting cap.  A counterexample must therefore identify a boundary that avoids all of those events.

## Exact remaining counterexample

A clean Rank-29 counterexample now needs one continuous controller-authentic trace with all of the following:

1. Mario begins an airborne episode at or below the checked stock cap.
2. A live moving floor, disappearing support, landing cancellation, or `OFF_FLOOR` transition ends the episode without damping or replacing the accumulated forward speed.
3. The transition creates enough new vertical room for another episode while retaining that speed.
4. The cycle repeats until directional speed exceeds `400`.
5. The Area-2-to-Area-3 instant warp preserves the resulting pose, action, and speed.
6. The first Area-3 quarter-step crosses the hand's wall band and reaches the already authenticated Pedro branch.

The decisive negative proof is correspondingly narrow: classify the live ownership and collision-loading behavior of the Area-2 elevator, Grindels, moving walls, and Spindel, then show that each possible transition either carries Mario with the same floor, lands normally, or passes through a checked speed reset/cap.  Area 3 adds the boss-hand lifecycle, but the sleeping state itself is already excluded as an interaction source.  Any first boundary that fails this classification is not merely a proof hole; it is the exact cycle to test in retail execution.

## Formal artifact

[`EyerokRank29Preload.v`](../../proofs/EyerokRank29Preload.v) contains the bilateral generated-source receipts, exact roster and macro-preset census, sleeping-branch control-flow check, selected static-mesh envelope computation, air-growth threshold, conservative vertical sum, ordinary-episode theorem, and the public escape reduction exposed by `MainTheorem.v`.
