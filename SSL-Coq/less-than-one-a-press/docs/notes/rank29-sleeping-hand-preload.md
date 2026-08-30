# Rank 29: sleeping-hand Pedro preload audit

## Result

No independent stock no-A speed source has been found.  More importantly, the direct-source search is now finite and checked: normal entry clears Mario's speed, the Area 2/Area 3 instant warp merely carries forward whatever speed already exists, the complete Area-2 and Area-3 object roster contains none of the usual large-speed actors, and a sleeping Eyerok hand cannot bounce Mario.  Under a deliberately generous ordinary-episode model, Mario reaches at most speed `170`, giving a `42.5`-unit air quarter-step; the Pedro entry needs directional speed over `400`, giving a quarter-step over `100`.

The repeatable-episode residual is now closed in the finite stock-owner model.  All five Area-2 moving-collision behaviors reload their mesh every loop; platform carry does not read or write Mario's forward speed; and the greatest possible stock one-frame Y change is `78`, below the strict `100`-unit gap required to set `OFF_FLOOR`.  The one genuine speed-preserving landing is the first flat butt-slide-air bounce, but it changes `actionState` from `0` to `1`, so it cannot repeat; re-arming it through ground butt-slide executes the checked speed-`100` normalization.  The collision-data census also proves that neither Area 2's static mesh nor any of those five moving meshes contains a burning surface that could substitute a repeatable lava bounce.  Rank 29 is therefore no longer open on an ordinary stock cycle.  A successful counterexample must now break a named premise—wrong or stale floor ownership, a missing collision reload, a forged action/state, altered object or surface data, an unmodeled outside effect, or execution beyond defined in-bounds CompCert behavior.

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
| Platform collision ownership | Grindel, horizontal Grindel, Spindel, moving-wall, and elevator behavior scripts all reload collision after their update | An intact live owner supplies a fresh floor and normal platform carry every frame |
| Platform Y motion | Conservative one-frame caps are elevator `20`, wall `6`, Spindel `23`, vertical Grindel `72`, and horizontal Grindel `78` | Even pretending Mario misses one carry, no stock floor can create the strict greater-than-`100` `OFF_FLOOR` gap |
| Normal landing or ground-step departure | Landing acceleration or slope deceleration executes before the ground step; steep-floor push replaces speed with magnitude `16` | An ordinary landing cannot preserve an arbitrarily accumulated preload into a fresh episode |
| Butt-slide-air landing | Its first eligible flat bounce preserves horizontal speed but consumes state `0`; the second landing exits, while re-entry through ground slide reaches the speed-`100` normalization | This is one preserving bounce, not a repeatable preserving cycle |
| Area-2 burning surfaces | The parsed static and moving collision streams contain no surface type `1` | There is no local lava bounce to replace the single-use butt-slide bounce |

The roster result is deliberately about the selected level initializers.  A claim involving a forged behavior, a corrupted spawn table, an out-of-bounds write, or another post-undefined-behavior machine continuation is outside the successful in-bounds CompCert execution model rather than an unfinished stock source.

## Direct movement bounds

The ordinary walking update caps forward speed at `48`; even granting the largest checked downhill slope addition afterward gives `53.3`.  Sliding has the familiar one-frame-late cap: the slide vector is normalized to `100`, and one following maximum downhill addition can expose a scalar speed no larger than `110` before the next normalization.  Fixed interactions in the Area-2 roster are smaller.  The proof therefore begins an ordinary airborne episode with the deliberately favorable cap `110`, rather than the lower values expected on the actual route.

At positive speed above the ordinary drag threshold, each regular air update first moves speed `0.35` toward zero, can add at most `1.5` from perfectly aligned full analog, and then subtracts `1`.  The largest net gain is consequently `0.15` per frame.  Starting from `110`, the first `1,933` such updates reach at most `399.95`; update `1,934` is the first arithmetic opportunity to exceed `400`.

That many uninterrupted airborne updates do not fit in the selected areas.  The checked static meshes fit inside the deliberately widened vertical envelope `[-5000,7000]`.  Grant an initial vertical speed of `100`, gravity of only `1` per frame, and terminal velocity `-75`; these are all more favorable than the ordinary actions of interest.  The first 400 vertical updates have total displacement at most `-14600`, which is greater in magnitude than the envelope's entire `12000`-unit height.  Thus even a 400-frame ordinary episode cannot keep both endpoints in the envelope.  Granting all 400 horizontal gains anyway yields only speed `170`, or `42.5` units per quarter-step.

This is an episode bound, not permission to concatenate episodes for free.  A normal landing, walking frame, slide normalization, or reinitialization brings the next episode back under the checked starting cap.  The new cycle theorem enumerates the only two superficially preserving stock cases: a platform-caused `OFF_FLOOR` transition and the first butt-slide-air bounce.  The former cannot satisfy the strict gap, and the latter cannot repeat without a capped reset.

## Exact remaining counterexample boundary

A clean Rank-29 counterexample can no longer consist only of repeating an intact stock transition.  It must first provide one exact failure of the finite boundary:

1. Mario's selected floor has a stale, wrong, or mutated owner, so ordinary platform carry does not apply.
2. A moving owner fails to run its checked behavior/collision reload, or a different moving surface enters the Area-2 list.
3. An action/state transition reaches a preserving landing that is neither the checked single-use butt-slide bounce nor a normal damped landing.
4. A valid alias or specified outside effect changes the action, state, surface, owner, or motion table while preserving defined execution.
5. A machine-level extension—such as an out-of-bounds write or post-undefined-behavior continuation—invalidates the CompCert source boundary.

After exhibiting one of those failures, the counterexample still has to repeat the preserving transition until directional speed exceeds `400`, survive the Area-2-to-Area-3 instant warp, and reach the already authenticated sleeping-hand Pedro landing.  Conversely, a live-trace proof that owner identity, collision reload, stock action state, and collision data remain valid discharges this premise and imports the finite closure directly.  Any first failing frame is not merely a proof hole; it names the exact owner, action, surface, alias, or outside effect to test in retail execution.

## Formal artifact

[`EyerokRank29Preload.v`](../../proofs/EyerokRank29Preload.v) contains the bilateral generated-source receipts, exact roster and macro-preset census, sleeping-branch control-flow check, selected static-mesh envelope computation, air-growth threshold, conservative vertical sum, and ordinary-episode theorem.  [`EyerokRank29CycleClosure.v`](../../proofs/EyerokRank29CycleClosure.v) adds the bilateral landing and platform source receipts, exact collision-surface parser, five-platform delta model, vertical-Grindel `72`-unit maximum-drop computation, single-use butt-slide bounce theorem, and the public proof that no repeatable preserving boundary exists in the stock-owner model.  Both are exposed by `MainTheorem.v`.
