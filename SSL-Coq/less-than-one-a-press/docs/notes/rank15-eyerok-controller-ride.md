# Rank 15: controller-authentic raised-hand ride

## Result

The injected jump-kick predecessor is no longer needed for the local Rank-15 hand ride.  On an authentic North-American ROM, Mario was first accepted only after the game itself reported the real closed Eyerok hand as both his floor owner and platform.  A had already been held continuously since Area 3 entry.  At hand timer 2 the probe made no Mario-state write and supplied one new B edge; the retail action loop performed `ACT_IDLE → ACT_PUNCHING → ACT_JUMP_KICK` in one frame, with internal input `0x20a0` (`A_DOWN` and `B_PRESSED`, but no `A_PRESSED`).  Mario rose from Y `-1228` to `-1208` with remaining vertical velocity `16`, reached `-1192` with velocity `12`, caught the hand's first `+85` step at the ordinary 49-unit floor gap, and stayed attached through `+70,+55,+40,+25,+10`, ending at Y `-943`.

## What this settles

This is a real controller predecessor from the accepted local contact boundary: the probe no longer writes Mario's action, action state, velocity, position, or facing on the release poll.  Generated US and JP Clight syntax also contains the matching chain: idle's B branch selects punching, punching state zero tests held A and selects jump-kick, and `execute_mario_action` loops across the stationary and object-action dispatchers in one frame.  The checked Coq receipt is in `proofs/EyerokRank15ControllerRide.v`; the exact concise trace is `../../old-proofs/eyerok-manipulation/instrumentation/results/contact_held_a_b_edge_trace.csv`.

## What remains staged

This does not reach the Eyerok fight or the initial hand contact from ordinary controller play.  The probe still shortens level travel, stages the boss scheduler, and repeatedly places Mario until retail collision reports the desired real hand ownership.  Those earlier writes remain the clean boss/contact reachability obligation.  Nor does the result produce a complete lower-route entry: the six positive steps put the highest hand top at Y `-943`, whereas the tunnel floor is Y `-562`.  A clean route still needs a stronger departure or another support, the correct wall and horizontal alignment, a hand-to-warp trajectory, and an Act-3 continuation.  Act 6 remains separate.

## Vertical-speed-conservation verdict

Vertical Speed Conservation does not supply the formerly quoted extra `243` units with any checked stock seed.  That `243` was only the difference between the ordinary floor-query threshold and the hand top after adding a second 60-unit jump-kick arc on paper; it was not a stackable gameplay operation.  The generated US and JP action setter writes jump-kick velocity `20` directly, so entering jump-kick replaces a conserved speed instead of adding another 60 units of ascent to it.

The formal bound is deliberately favorable to VSC.  It starts at the observed hand top Y `-943`, preserves the chosen seed perfectly, sums every positive frame under ordinary gravity `4`, and grants both the ledge check's `+160` floor-query offset and `find_floor`'s `78`-unit upward tolerance.  The tunnel floor can therefore be reached by this arithmetic only if Mario himself gets to at least Y `-800`:

| Conserved seed | Full positive ascent | Mario's best Y | Effective query ceiling | Result against floor Y `-562` |
|---:|---:|---:|---:|---:|
| `20` (jump-kick replacement) | `60` | `-883` | `-645` | misses by `83` |
| `26` (standard VSC26 candidate) | `98` | `-845` | `-607` | misses by `45` |
| `30` (full ordinary bounce seed) | `128` | `-815` | `-577` | misses by `15` |
| `31` | `136` | `-807` | `-569` | misses by `7` |
| `32` | `144` | `-799` | `-561` | clears the vertical arithmetic threshold by `1` |

The theorem proves that every integral seed at or below `31` misses, not just the rows sampled in the table.  Seed `32` is only the first arithmetic threshold: it does not prove that stock play can create and preserve that seed, that Mario encounters the required wall while descending, that the ledge floor is selected at the needed X/Z, or that the subsequent warp route works.  The complete generated Area-3 collision initializer supplies one more useful exclusion: across all `176` static triangles in both selected versions, no positively oriented face spans the open Y band from the arena's highest static support at `-1150` to the tunnel floor at `-562`.  Mario therefore cannot bank the jump-kick or VSC height on an intermediate *static* floor in that band; a second hand or another dynamic support remains a separate escape.

The checked Coq development is [`EyerokRank15VSC.v`](../../proofs/EyerokRank15VSC.v).  It uses generated game-source initializers and action bodies for its constants and geometry; [Ukikipedia's Vertical Speed Conservation page](https://ukikipedia.net/wiki/Vertical_Speed_Conservation) is useful background for the technique and the conventional “VSC26” name, but is not a proof premise.

## Reproduction boundary

The wrapper accepts only the US ROM with MD5 `20B854B239203BAF6C961B850A4A51A2`, SHA-256 `17CE077343C6133F8C9F2D6D6D9A4AB62C8CD2AA57C40AEA1F490B4C8BB21D91`, and Mupen64Plus CRC `635A2BFF 8B022326`.  Run `old-proofs/eyerok-manipulation/instrumentation/mupen64plus/run_contact_probe.sh` in WSL Ubuntu 24.04; mode `held_a_b_edge` is compiled with `CONTACT_MODE=3`, and the analyzer rejects the run unless the write-free release marker, exact input/action result, same-hand floor/platform ownership, closed-top interior checks, all six hand steps, and final Y `-943` are present.
