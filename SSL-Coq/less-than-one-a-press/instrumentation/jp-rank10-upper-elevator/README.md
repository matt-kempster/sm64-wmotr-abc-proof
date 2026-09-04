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

Modes `2` through `5` hold A beginning at the accepted Area-1 disappearance
boundary and choose east, west, north, and south launch poses respectively.
Because A is already down before Area 2 starts, these runs contain no Area-2 A
edge. The probe creates that held state on the final Area-1 disappearance
frame, so this is a controlled held-state experiment rather than an end-to-end
zero-edge witness. One B press enters a real jump kick. The pinned four-face summary shows
that every pose hits the matching live elevator wall, remains over the
elevator floor and inside the cage, and peaks at relative Y `128`.

With `RANK10_QUERY_TRACE=1`, JP execute breakpoints record the entry and common
return of every `perform_air_quarter_step`, all four real collision-query
callees, and the four post-call stores. Each receipt line therefore contains
the intended Float32 position, upper and lower wall results and owners, floor
and owner/height, ceiling and owner/height, and the quarter-step result. The
held-A execution accounts for 64 complete `wall, wall, floor, ceiling`
sequences; the B rollout accounts for 84. The run fails if even one sequence,
Mario receiver, step argument, or result count differs from the pinned totals.
It also reconstructs the proof's relative-Y recurrence at every return and
fails on any mismatch, any floor not owned by the elevator, any non-null wall
not owned by the elevator, or any non-static ceiling. The live query maxima are
exactly `135` and `227.5`, matching the Coq envelopes.

Run the neutral observation with:

```sh
bash run.sh /path/to/baserom.jp.z64 3900 0
bash run.sh /path/to/baserom.jp.z64 3500 1
```

The pure interpreter is intentionally used for execute breakpoints. For a
fast full-prefix replay without breakpoints, set
`RANK10_USE_DEBUG=0 RANK10_NO_DEBUG=1 RANK10_EMUMODE=2`; its mode-1 summary is
checked byte-for-byte against the same pure-interpreter receipt. Repeated short
query runs can derive a checkpoint from the accepted prefix and then replay it:

```sh
bash make-checkpoint.sh /path/to/baserom.jp.z64 /tmp/rank10.st
bash run-held-face-sweep.sh /path/to/baserom.jp.z64 /tmp/rank10.st
bash run-query-traces.sh /path/to/baserom.jp.z64 /tmp/rank10.st
```

The checkpoint is emulator state, not a game-memory patch. It is created at
timer 2808 after the exact controller prefix reaches `ACT_DISAPPEARED`; loading
it begins at timer 2809 and derives the same timer-2831 Area-2 object, slot,
elevator, and descent facts. It is a runtime convenience and is not committed.

The summaries are finite machine receipts, not proofs about every controller
history and not an IDO-to-Clight simulation. Internal JP queries are now fully
exposed for the two tested actions, and selected US/JP Clight bodies are
resolved separately in `UpperElevatorQueryResolution.v`. Four cardinal poses
do not exhaust every continuous X/Z/yaw launch; a universal route result still
has to prove that no other clean pose changes the surface choice, clips a wall,
switches support, or changes action/object identity.
