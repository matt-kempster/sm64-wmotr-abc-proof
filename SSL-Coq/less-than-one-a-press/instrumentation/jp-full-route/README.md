# Conditional JP route fixture

This search-only harness extends the hash-gated JP lifecycle fixture with
controller input after the first Area-2 poll.  Its default stick-only schedule
consumes all five Pyramid Puzzle triggers and causes the Act 6 star to spawn.
It never supplies an A-button edge.

The inherited lifecycle fixture injects an Area-1 Graphics position.  This is
therefore a **conditional continuation**, not a clean-retail counterexample.
It answers the narrower downstream question: if the timer-131 retained-
platform boundary can be installed, can ordinary no-A movement reach the
upper trigger and continue through the other four triggers?  The recorded
answer is yes.

The same trace also checks the authentic SSL save byte and the spawned star's
interaction status.  The default stick-only schedule does not collect the
star: Mario's floor-level interaction cylinder ends 11 units below its
initial position, so the save byte remains unchanged.  The optional pickup
schedule below supplies the missing lift without an A edge.

Run the stick-only schedule against the authentic Japanese ROM:

```sh
./instrumentation/jp-full-route/run.sh \
  /path/to/baserom.jp.z64 260.0f -600.0f 20 stick-only 1800 0
```

Set the final argument to `1` to enable the separately logged B-only dive and
rollout search.  This still supplies no A edge.  The B-only speed kick reaches
the remaining triggers sooner, but the tested schedule still does not collect
the star.

An eighth argument of `1` enables a normal-movement search that first tries to
walk onto the north ramp and then fall back toward the star.  This mode is
kept separate because reaching all five triggers does not depend on it.

A ninth argument of `1` selects the fixed B/Z/stick continuation that closes
the 11-unit vertical gap with a slide kick.  Unlike the default schedule, this
mode collects the spawned Act 6 star and observes the SSL save byte change
from `00` to `20`.  It is still conditional on the injected Area-1 boundary
and still supplies no A edge.  Use 1800 or more test frames so the trace can
observe the star-grab action and save-bit update.  The optional tenth argument
is the direct-steering X target and defaults to `900.0f`.
