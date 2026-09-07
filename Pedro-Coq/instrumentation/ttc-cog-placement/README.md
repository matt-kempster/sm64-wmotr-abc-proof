# Near-cog placement experiment

The user authorized a local placement experiment after providing the cog video.
This is a separate test build, not a controller-only entry witness. Its only
source changes configure TTC as the initial level, RANDOM clock mode, Mario's
chosen spawn, and ordinary idle initialization
instead of the castle-opening cutscene. `prepare.py` exports the exact pinned
source into an isolated build copy and checks that only those three files differ.
The complete patch and configuration are saved in `build/cog-placement/`.

The observer supplies ordinary controller input. State observation uses
`DebugMemRead32`, `DebugMemRead16`, and a const view of the CPU register bank.
Optional interpreter debugger stops observe function entries and returns;
the observer has no guest-memory, register, or instruction write operation.
The launcher uses fresh configuration/save directories and requires
the emulator to report that cheats are disabled. It resolves addresses from
the test build's ELF; those addresses must not be reused for a retail ROM.
Before installing stops, it checks the loaded RNG and air-step instruction
words against hashes derived from that ELF. The static RNG seed address and
air-step local-variable offsets are validated against its disassembly.

The named initializations are:

| Setup | Mario position | Yaw in degrees |
| --- | --- | --- |
| `ledge` (default) | `(1742,-2088,-125)` | 188 |
| `cog_back` | `(1428,-2088,-1084)` | 7 |
| `edge` | `(1456,-2088,-1178)` | 341 |
| `rim` | `(1456,-2088,-1139)` | 341 |
| `inner_rim` | `(1313,-2088,-1098)` | 90 |

They leave all cog initializers and subsequent rotations unchanged. The
first three positions are discovery candidates from the supplied video, with
rounded coordinates. The later `rim` and `inner_rim` points instead target
the unrotated lower cog's boundary; the latter is farther under the ceiling
cog. They do not reproduce the video's unknown clock phase or input history.

Run in Ubuntu-24.04 from the repository root:

```sh
python3 Pedro-Coq/instrumentation/ttc-cog-placement/prepare.py
make -C Pedro-Coq/build/cog-placement/source VERSION=us COMPARE=0 -j2
python3 Pedro-Coq/instrumentation/ttc-cog-placement/run.py us idle_us
```

`prepare.py` can also run with native Windows Python; this is substantially
faster for copying the cache on this OneDrive-backed workspace. It requires
the already authenticated US/JP matching-build cache at the path declared in
the script. For another setup, pass its name with `--setup` to
both Python scripts and build the corresponding `build/cog-placement/<setup>/source`.
Each setup has a separate source/build copy. WSL verification commands have
occasionally exited without diagnostics in this workspace, including when
run serially. Record command exit status; serial execution is not a proven fix.

Use `VERSION=jp` and the `jp` runner argument for the independent JP trial.
`COMPARE=0` acknowledges the explicitly modified initialization; the setup is
not expected to match the retail ROM hash. The starting matching-build cache
must authenticate as the original US/JP ROMs before preparation proceeds.
ROMs, extracted assets, generated binaries, screenshots and complete traces
stay in the ignored build directory.

Input files contain disjoint, ordered inclusive intervals:
`first_frame,last_frame,stick_x,stick_y,buttons`. Stick components are limited
to -80 through 80; buttons are combinations of `A`, `B`, `Z`, `L`, `R`, or `-`.
Frames are relative to the first observed initialized TTC state. The observer
logs the state at each input poll before returning that frame's controller
input; these rows are not internal quarter-step or RNG-call traces.

`--waypoints PATH` optionally chooses stick inputs toward world-space targets.
Its rows are `first,last,target_x,target_z,maximum_raw_stick_magnitude`; it
outputs ordinary stick values, recorded in `CINPUT`. Export those values with
`analyze.py TRIAL --replay NEW.csv` and replay without `--waypoints` to check
determinism independently of the steering routine.

An optional seven-column row appends `space,stop_distance`. `world` keeps
world coordinates; `cog` rotates the target with the observed lower cog, and
`cog_brake` adds a coasting heuristic. For example,
`130,310,-306,0,80,cog,0.5` steers toward a point near its moving tip. These
are controller policies, not collision models or verified game dynamics.
Only the resulting bounded integer stick inputs are supplied to the game.

`sweep-detour.py SEARCH_NAME --suite rim|phase|brake|tip|tip_brake|turn_fine|brake_early|edge_fine` runs a
bounded, declared set of fresh trials. `--first` and `--count` choose a
contiguous subset of the listed candidates. The phase suite waits neutrally
on the starting ledge; it does not set cog angles or RNG values. Every trial
keeps its input/waypoint files and hashes. Search results report observed
close-gap returns; they do not certify a preserving interval.

`inputs/ledge-around-mesh-us.csv` is the later verified detour around the mesh,
including a jump over the neighboring cog's side. Its complete logical trace
agrees in US and JP. It reaches the back of the lower cog but subsequently
falls; it is not a successful Pedro entry.

`--trace-calls` adds `CRNG` and `CAIR` observations. `CAIR` records the actual
wall-resolved query, selected floor/ceiling, result, and before/after Mario
position and floor reference at the air-step return. `pedroCandidate=1`
classifies its close-gap landing branch; it does not certify entry provenance
or a preserving controller continuation. Calls can continue during the ending
transition after the last initialized-TTC input snapshot, so the complete
collector output is not automatically a TTC-only frame census.

`--trace-path` includes call tracing and adds `CPATH` entry/return observations
for geometry refresh, action changes, landing cancellation/body, ground steps,
the complete Mario action update, and particle spawning. The reported cog
poses are observed at those boundaries, after the surface objects' updates.
`CSURFACE` records selected triangles, owners, normals and plane offsets before
their storage can be reused. `CAIR` also distinguishes the original intended
point (`ix/iy/iz`) from the wall-resolved query (`qx/qy/qz`). Every additional
observed routine is authenticated against the exact test ELF before a run.

`check-trace.py TRIAL` checks the complete observed RNG recurrence/chain and
Pedro branch effects, and requires one controller record and Mario snapshot
for every observed TTC frame. `--compare OTHER_TRIAL` compares observed logical fields
across trials, excluding raw addresses. Both scripts are discovery tools;
they are outside the Coq trusted base.

Path checking additionally requires balanced routine entries/returns and a
matching triangle description for every selected floor/ceiling observation.
`report-path.py TRIAL --first F --last L` exports a checked inclusive frame
window with its events in original order. A particle request alone is not
proof of a new allocation or of preserving RNG control.

`check-preservation.py TRIAL --minimum 2` applies the narrow successive-update
check described in the [follow-up report](../../docs/notes/ttc-cog-successive-updates.md).
It requires repeated off-floor close-gap rejections of nonzero intended motion,
complete action updates, fixed Mario position and both relevant cog poses.
It excludes supporting-floor impacts and ground-pound paths. Other actions
need their own complete preserving-path analysis. `--allow-upper-rotation`
produces a separately labeled weaker diagnostic. Neither mode has a validated
positive gameplay example yet; an empty witness list is not an impossibility
proof. Reports go to `preservation.json` or `preservation-lower-only.json`.

For video capture, pass `--capture-from 350 --video-frames 600` to save every
rendered frame in that inclusive range. This uses the emulator's screenshot
facility and disables screenshot notifications on screen. Encode the resulting
PNG sequence at 30 fps for normal playback or 15 fps for half speed; the
dummy audio plugin produces a silent recording. Compare the captured run's
trace with the original replay before presenting it as the same run.

The console can redirect stderr internally and append a complete controller
record to a partial screenshot notice. The launcher accepts only an intact
canonical `CINPUT` suffix in this specific case and counts these recoveries;
it does not synthesize missing fields. The frame completeness check rejects
incomplete controller logs. Raw process logs are retained.

Before making an in-spot RNG-control claim, establish the landing cancellation
and ground-step paths, accepted dust requests, and their ordered RNG calls.
No trial may force a cog pose/speed, RNG seed, or action after initialization.

See [the recorded results](../../docs/notes/ttc-cog-placement-results.md).

The [slide-kick follow-up](../../docs/notes/ttc-cog-slide-kick.md) records six US
timing trials and one JP comparison using this same controller/observer
workflow. `results/slide-kick-discovery.json` preserves the exact waypoint
and button recipes, hashes and checked outcomes. None observes a Pedro return
or sliding-phase dust witness. It is separate from the conditional Coq caller
proof added in that follow-up.
