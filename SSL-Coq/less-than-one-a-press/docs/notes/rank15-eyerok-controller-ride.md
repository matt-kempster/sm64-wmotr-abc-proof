# Rank 15: controller-authentic raised-hand ride

## Result

The injected jump-kick predecessor is no longer needed for the local Rank-15 hand ride.  On an authentic North-American ROM, Mario was first accepted only after the game itself reported the real closed Eyerok hand as both his floor owner and platform.  A had already been held continuously since Area 3 entry.  At hand timer 2 the probe made no Mario-state write and supplied one new B edge; the retail action loop performed `ACT_IDLE → ACT_PUNCHING → ACT_JUMP_KICK` in one frame, with internal input `0x20a0` (`A_DOWN` and `B_PRESSED`, but no `A_PRESSED`).  Mario rose from Y `-1228` to `-1208` with remaining vertical velocity `16`, reached `-1192` with velocity `12`, caught the hand's first `+85` step at the ordinary 49-unit floor gap, and stayed attached through `+70,+55,+40,+25,+10`, ending at Y `-943`.

## What this settles

This is a real controller predecessor from the accepted local contact boundary: the probe no longer writes Mario's action, action state, velocity, position, or facing on the release poll.  Generated US and JP Clight syntax also contains the matching chain: idle's B branch selects punching, punching state zero tests held A and selects jump-kick, and `execute_mario_action` loops across the stationary and object-action dispatchers in one frame.  The checked Coq receipt is in `proofs/EyerokRank15ControllerRide.v`; the exact concise trace is `../../old-proofs/eyerok-manipulation/instrumentation/results/contact_held_a_b_edge_trace.csv`.

## What remains staged

This does not reach the Eyerok fight or the initial hand contact from ordinary controller play.  The probe still shortens level travel, stages the boss scheduler, and repeatedly places Mario until retail collision reports the desired real hand ownership.  Those earlier writes remain the clean boss/contact reachability obligation.  The result also does not produce a complete lower-route entry: the six positive steps total `285`, putting the highest hand top at Y `-943`, while the lowest tunnel floor can first be queried at Y `-640`.  The hand is therefore `303` units short; even generously granting another copy of the observed 60-unit positive jump-kick envelope leaves a `243`-unit deficit.  A clean route still needs additional lift/support or a different departure, followed by the hand-to-warp trajectory and Act-3 collection.  Act 6 remains separate.

## Reproduction boundary

The wrapper accepts only the US ROM with MD5 `20B854B239203BAF6C961B850A4A51A2`, SHA-256 `17CE077343C6133F8C9F2D6D6D9A4AB62C8CD2AA57C40AEA1F490B4C8BB21D91`, and Mupen64Plus CRC `635A2BFF 8B022326`.  Run `old-proofs/eyerok-manipulation/instrumentation/mupen64plus/run_contact_probe.sh` in WSL Ubuntu 24.04; mode `held_a_b_edge` is compiled with `CONTACT_MODE=3`, and the analyzer rejects the run unless the write-free release marker, exact input/action result, same-hand floor/platform ownership, closed-top interior checks, all six hand steps, and final Y `-943` are present.
