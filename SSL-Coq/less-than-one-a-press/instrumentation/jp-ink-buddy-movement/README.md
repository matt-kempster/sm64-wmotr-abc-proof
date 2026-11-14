# Original JP: conditional Buddy relocation

14 November 2026. All three runs pass. The real drop/throw handlers move
the cannon Buddy after a supplied pickup-reference change. The comparison
without that change leaves him at spawn. **These are not legitimate clone
histories or Ink delivery replays.**

## Version and setup

Proof baseline `9229f9e2466782a142b595fda6d5cc64ee4c1016`; stock JP source
pin `9921382a68bb0c865e5e45eb594d9c64db59b1af`. Original JP ROM SHA-256
`9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317`, MD5
`85d61f5525af708c9f1e84dce6dc10e9`. Ubuntu-24.04, Mupen64Plus 2.5.9,
interpreter CPU, Rice 2.5.9, HLE RSP 2.5.9, dummy audio, fresh configuration
and data directories. The ROM is not included.

The established `jp-clean-gap-search` mode12 prefix uses the debug level
select cheat before gameplay and controller input thereafter. At top action1,
timer125, global2674, the diagnostic supplies **19 scalar Mario writes**:
M/C/stored-gfx XYZ `(5900,51,3380)`, IDLE, state/timer0, forward0,
velocity `(0,0,0)`, face angles `(0,0,0)`. No floor, ceiling, animation,
RNG, object or HOLP fields are assigned. B is pressed for the first update,
then inputs remain neutral until native HOLD_IDLE.

During native PICKING_UP, while `usedObj` names real small box23, modes1/2
make one additional four-byte write: `usedObj = Buddy15`. There are no
further state writes. Mode3 omits it. On the first observed HOLD_IDLE,
mode1/3 press Z once; mode2 presses B once; remaining inputs are neutral.
No A press or held A occurs. All Buddy coordinates, velocity, flags,
behavior, held state, parent and HOLP changes are native.

## Results

Each run checks **2,327 pre-cut native boundaries** at Buddy's exact
`(-5990,0,-3871)` and **148 post-cut observations**, including the setup
boundary. Those repeated prefixes are three comparisons of the same
history, not independent route coverage. Exact binary32 coordinates:

| Mode | First native release | Buddy XYZ at release-update end | Last observation |
| --- | --- | --- | --- |
| 1: retarget, Z-drop | step15 / global2689 | `(5884.97021484375,51,3394.096435546875)` | Same XYZ |
| 2: retarget, B-throw | step21 / global2695 | `(5888.63916015625,160.45884704589844,3362.268798828125)` | `(5888.63916015625,51,3362.268798828125)` |
| 3: no retarget, Z-drop | Small box released at step15 | Buddy stays `(-5990,0,-3871)` | Same original Buddy XYZ |

Buddy stays at spawn during the native held portion. His original behavior
and current-command pointers survive. Drop leaves held state3; throw leaves
state2. His native callback applies gravity after throw, bounces and
settles; forward speed remains zero. The raw XYZ displacement is distinct
from visible rendering. The Wafel note has a different native prefix/
animation history and slightly different frame counts and float values;
its measurements are not substituted for these ROM values.

The checker verifies the exact setup address/width/value allowlist, the
single conditional pointer retarget from box23, no Buddy-field writes,
native pickup and release, original behavior identity, unique consecutive
observation steps/timers, pre-cut stationarity, native A-input bits and
prefix controller-A counters. It does not prove all uninstrumented writes
or a continuous allowed acquisition history.

## Reproduce

From the SSL project directory in Ubuntu-24.04, using fresh output paths:

```sh
bash instrumentation/jp-ink-buddy-movement/run.sh ../../../reference-sm64-decomp/baserom.jp.z64 build/buddy-drop-new 1
bash instrumentation/jp-ink-buddy-movement/run.sh ../../../reference-sm64-decomp/baserom.jp.z64 build/buddy-throw-new 2
bash instrumentation/jp-ink-buddy-movement/run.sh ../../../reference-sm64-decomp/baserom.jp.z64 build/buddy-control-new 3
```

Each `records/` directory preserves full compressed emulator output,
selected readable trace, result JSON and exact runner/probe/checker/prefix
sources. `manifest.json` pins their bytes. To independently recheck an
archive, expand `raw.log.gz` into a fresh directory, extract its `BUDDY_`
lines to `trace.txt`, copy its `*-source` files, and run the archived
`checker-source.py <directory> <mode>`. The checker writes its result and
selected trace. No emulator or ROM is needed for that archive-only check.
`verify_archive.py` automates this process and passed all three archives;
it also verifies every manifest hash and matches the recorded results.

Pilot failures are not gameplay exclusions: the first timer130 attempt
continued steering into the ordinary warp before its setup ran. Three
timer130 variants with neutral inputs from125 instead reached an existing
pending pickup and failed the explicit empty-held-object guard. Their raw
logs remain under `build/jp-buddy-*-20261114*`; the three archived successes
start at125, before that pickup completes. No failed pilot is counted as a
Buddy-movement result.

See the [overall verdict](../../docs/notes/ink-buddy-movement.md),
[Wafel controls](../../docs/notes/ink-buddy-movement-runtime.md), and
[Coq scope](../../docs/notes/ink-buddy-movement-proof.md).
