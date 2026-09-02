# JP Rank-11 pole-release timing diagnostic

This is a **fixture-assisted suffix test**, not a clean TAS movie or a proof
of reaching the pole. It reuses `jp-full-route` / `jp-lifecycle` to load Area 2
through their explicitly injected Timer-131 boundary, then stages a holding
state on the real second pole with position `(0,4020,1331)` and zero speed.
The 23 additional staging writes are logged as `R11_FIXTURE_WRITE`.

After staging, this wrapper changes only controller input. It climbs into a
handstand, holds for 60 polls, returns, and uses one of two Z timings:

- Mode `0`: Z on return-animation frame zero, before holding resets position.
- Mode `1`: neutral on that frame, then Z at the next holding-pole poll.

Both modes neutralize the final return frame, so the comparison does not add
a holding-pole spin. Neither mode supplies A. A Z edge during the stable
handstand is also tested and does not release Mario.

## Run

Supply a legally obtained local JP ROM; no ROM is included or downloaded.
The script checks both MD5 and SHA-256 before loading it, builds the input
plugin with warnings as errors, and runs the existing interpreter-mode
Mupen64Plus fixture with isolated configuration/data directories.

```bash
bash SSL-Coq/less-than-one-a-press/instrumentation/jp-rank11-pole-release/run.sh /path/to/baserom.jp.z64 0 1000
bash SSL-Coq/less-than-one-a-press/instrumentation/jp-rank11-pole-release/run.sh /path/to/baserom.jp.z64 1 1000
```

Dependencies are the same as `jp-lower-one-a-route`: GCC, Mupen64Plus with
the debugger, Rice video, RSP HLE, Xvfb and software OpenGL. Output goes to
`SSL-Coq/less-than-one-a-press/build/instrumentation/jp-rank11-pole-release/mode-N/`.
`trace.txt` records the first 155 distinct-timer samples, staging writes and
summary; `raw.log` also retains the inherited fixture logs. The script fails
if it does not stage, request release, see soft bonk, and retain zero A
counters. Repeating a mode replaces that mode's generated logs.

## Result and scope

The timed release retains Y **4070**, 50 units higher than delayed release at
Y **4020**. Both tested continuations land back on the pole base. The sampled
handstand maximum is 4194, but this is not claimed as a universal bound.
The compact [verified receipt](verified-receipt.txt) records the distinguishing
samples. `R11_FRAME.input` is the already-stored game input at the poll;
the A/Z/stick columns are the controller input supplied for the next update.

The plugin samples memory at controller polls; it does not record every
instruction or collision quarter, certify all wall/floor owners, or connect
IDO machine execution to Clight. Its injected entry and speed must not be
presented as a controller-reachable prefix, and its staging writes must not
be reused as a writable-table producer. No table or code mutation is tested.

See the [proof and residual audit](../../docs/notes/rank11-pole-exit-live-audit.md).
