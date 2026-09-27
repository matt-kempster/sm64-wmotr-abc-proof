# Wafel JP replay pilot

The [27 September full-loop review](../../docs/notes/rank1-hybrid-call-review.md)
adds benchmark_loop.py and loop-benchmark-report.json. The benchmark restores
a controller-reached state and measures repeated known-replay windows of
30/90/150 advances, with exact sampled-field comparisons. Run it with the same
Python below, the captured inputs.jsonl as its positional argument, and
--output pointing to a new build report. This does not implement call-level
runtime delegation or search for predecessors; the report keeps that boundary
explicit.

Checked 25 September 2026. **The adapter passed one known JP replay and one
controller-only branch.** This is a finite runtime check, not a Coq theorem
or an all-input Ink exclusion. Nothing moves to Already proved on its strength.

## What matched

The baseline recaptures the existing clean mode-12 four-pillar replay. Its
Rank-5, Rank-13 and exact upper-warp acceptance receipts all pass unchanged.
There are 2,852 input polls and 2,483 comparable Area-1 snapshots, with zero
A-down frames. All nine binary32 position words, action, action timer, input
flags, floor height/nullness/owner, Mario/platform slots and the original
top slot's timer/action/pillar count/active flags match Wafel.

At these paired observation boundaries, Wafel's global timer is consistently
**emulator timer + 1**. The comparison checks this fixed mapping separately;
it does not silently change either timer. This is agreement for the sampled
replay under that mapping, not raw equality of the global timers or a proof
that every timer-dependent branch will match. The emulator samples when
polling the next input; Wafel is sampled between advances. A complete
instruction-level correspondence between these boundaries is not proved.

Object pointers are compared as pool-slot identities, not unrelated process
addresses. The original top is identified by behavior and slot at entry;
later slot contents alone are not a live-top census. The inherited observer
still supplies that census at the exact accepted warp: no live top, null
final platform, and movement/collision/display all equal at
`(-2033.87939453125,768,-1037.05859375)`. Thus the known baseline still fails Ink.

## The three-second branch

Replay through poll 2699, save that reached Wafel state, and vary only the
next 90 controller inputs (polls 2700–2789). The initial actual position is
`(-4999.7919921875,275,1540.950927734375)`, in the Crazy Box bounce action;
the original top slot has action 1, timer 150. This is a late approach pilot,
not a search starting before the supplied timer-131 installation window.

Five choices are checked: original inputs; neutral for 30 updates then the
original 60; hold Z with the original stick; reverse stick X; or press B on
the first update. Each restores the same reached state. All 450 after-update
samples have equal movement, collision and display, and non-null stored floor.
These floor readings do not certify every lookup made inside the update.
No A is used. Some choices have the same resulting trajectory; this is five
input choices, not five distinct routes.

The neutral-30 branch changes the final actual position to
`(-2683.69873046875,1156.0001220703125,-681.4011840820312)`.
Its **entire 2,790-poll input sequence** was replayed in the original emulator:
2,442 comparable Area-1 snapshots match under the same +1 timer mapping.
The 90 outputs obtained by restoring the Wafel state also match those
emulator checkpoints. This interval stops before warp acceptance; the warp
observer reports zero accepted warps and zero observer failures. No useful
candidate was found to carry into a new installation test.

The observed Wafel event types expose actions, velocities, movement steps
and wall pushes. They did not expose the collision/display vectors or exact
accepted-warp return in these runs. Keep the existing debugger observer for
temporary splits and that precise endpoint.

## Reproduce

Use the released **Wafel 0.8.5 Windows x64** archive and **Python 3.9.13
Windows embeddable amd64** package, independently downloaded from:

- [Wafel release](https://github.com/branpk/wafel/releases/tag/v0.8.5), asset `wafel_0_8_5_win_x64.zip`.
- [Python 3.9.13](https://www.python.org/downloads/release/python-3913/), asset `python-3.9.13-embed-amd64.zip`.

Put them in ignored `build/wafel-pilot/`. `setup_runtime.py` checks their
SHA256 hashes and unpacks only the isolated interpreter, cp39 wheel and JP
locked library. It does not change global Python. Run it with Python 3.10+
(the local bundled interpreter was used), then use the isolated interpreter:

```powershell
python instrumentation/wafel-jp-pilot/setup_runtime.py
& './build/wafel-pilot/python/python.exe' instrumentation/wafel-jp-pilot/unlock_runtime.py /path/to/baserom.jp.z64
```

The official unlock API uses the independently supplied authentic JP ROM.
`replay.py` also checks the resulting DLL hash. The released API predates the
main branch's `set_input` convenience function, so the adapter writes the
three controller-pad fields. The only other write is the **pre-entry**
level-select flag, matching the project's accepted startup and emulator's
existing level-select option. It never sets a gameplay pose, action, depth,
support, enemy or RNG value. Saved states come only from the played prefix.

In the existing Ubuntu-24.04 emulator environment, from this Coq project:

```sh
bash instrumentation/wafel-jp-pilot/capture.sh /path/to/baserom.jp.z64
```

The runner authenticates the ROM/instruction windows, builds with warnings
as errors and checks the inherited exact receipts before producing its
baseline `inputs.jsonl`. Substitute its printed output path below:

```powershell
& './build/wafel-pilot/python/python.exe' instrumentation/wafel-jp-pilot/replay.py build/wafel-pilot/capture.BASELINE/inputs.jsonl
& './build/wafel-pilot/python/python.exe' instrumentation/wafel-jp-pilot/branch.py build/wafel-pilot/capture.BASELINE/inputs.jsonl
```

Then replay the generated controller schedule in Ubuntu-24.04:

```sh
bash instrumentation/wafel-jp-pilot/capture.sh /path/to/baserom.jp.z64 build/wafel-pilot/neutral-30.inputs
```

This branch run checks every emitted controller sample against that schedule.
It does not require the original trajectory's warp receipts to remain equal.
Compare it and connect the saved-state outputs, using the new output path:

```powershell
& './build/wafel-pilot/python/python.exe' instrumentation/wafel-jp-pilot/replay.py build/wafel-pilot/capture.BRANCH/inputs.jsonl --output build/wafel-pilot/branch-comparison.json
& './build/wafel-pilot/python/python.exe' instrumentation/wafel-jp-pilot/check_receipts.py build/wafel-pilot/capture.BASELINE/inputs.jsonl build/wafel-pilot/capture.BRANCH/inputs.jsonl
```

The checker also rejects a one-bit position mismatch and a shifted timer.
The emulator's pinned `testshots N` run supplies N+2 input polls; both the
expected poll sequence and its length are checked instead of trimming a
failed replay until it agrees. The final poll observes the last tested output.

The checked local captures are `build/wafel-pilot/capture.bKv95w` (baseline)
and `build/wafel-pilot/capture.aWS5zh` (branch). Compact expectations and
hashes are in `expected-pilot.json`; full logs, screenshots, controller
sequences, ROM and libraries stay out of Git and site assets. This pilot
does not test US, a different Wafel version, exhaustive input histories,
or formal equivalence to the generated US/JP Clight code.
