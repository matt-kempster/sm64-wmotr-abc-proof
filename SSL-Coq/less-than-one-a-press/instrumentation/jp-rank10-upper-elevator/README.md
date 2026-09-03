# JP Rank-10 upper-elevator probe

This hash-gated original-JP probe extends the existing controller-only,
zero-A four-pillar route through the upper warp and into SSL Area 2.  It has
no game-memory write API.  Mode `0` leaves the controller neutral after the
warp and records Mario's uninterrupted descent, selected floor and owner,
platform pointer, cap state, action transitions, and the unique live elevator
object.

Mode `1` continues with controller input only.  It walks to a bounded runway,
builds speed on an inner orbit, performs a B speed-kick dive, lands the dive
on the moving elevator, and presses B again for a forward rollout.  The exact
3500-frame receipt is checked against `expected-mode1-summary.txt`.  It proves
for this execution that Mario and the elevator retain identity, every Area-2
floor owner is the elevator, the 17 descent samples match exactly, no Wing or
A input occurs, and the rollout hits the live elevator's east inner wall and
returns to its floor without leaving the legal center cell.

Run the neutral observation with:

```sh
bash run.sh /path/to/baserom.jp.z64 3900 0
bash run.sh /path/to/baserom.jp.z64 3500 1
```

The exact mode-1 summary is a finite machine receipt, not a proof about every
controller history and not an IDO-to-Clight simulation.  Per-frame MarioState
fields identify the selected wall and floor after each game update, but they
do not by themselves expose every intermediate wall, floor, and ceiling call
inside all four quarter steps.  The generated-source Float32 proof supplies a
separate conservative query envelope; connecting each live program point is
still a distinct universal obligation.
