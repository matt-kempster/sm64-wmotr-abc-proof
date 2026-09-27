# Rank 1: all inputs before retention — five or thirty seconds

27 September 2026. B was an example, not the intended search restriction.
The requested horizon ends at the final Area-1 check that **retains the checked
top**. The original proposal extends 30 seconds backward; the user also asks
whether five seconds would be feasible. Both end at the same retention check,
not at warp acceptance or an earlier save. This clarification and size estimate
add no gameplay witness, exclusion or Coq theorem. Rank 1 remains at 1–2%.

The [first local grouping implementation](rank1-input-grouping.md) now checks
exact input sets in the generated controller code. It has not yet measured
the cost of a complete frame or either multi-update horizon below.

## One trajectory versus all trajectories

At the nominal US/JP rate of 30 game updates per second, the requested horizon
is **900 updates**. One trajectory has 900 controller records. If each update
has K available records, unpruned enumeration has **K^900 input sequences**,
not 900 times K. Shared prefixes can save repeated simulation, but do not remove
the exponential number of leaves. The count of transitions in the complete
unmerged K-ary tree through depth 900 is `(K^901-K)/(K-1)` for K greater than one.

| Input alphabet used for counting | Choices per update | Five seconds: 150 updates | Thirty seconds: 900 updates |
| --- | ---: | ---: | ---: |
| Just two choices, for illustration | 2 | about `1.42725 × 10^45` | about `8.45271 × 10^270` |
| Nine sampled stick poses (neutral and eight directions), with B/Z combinations | 36 | about `2.78853 × 10^233` | about `4.70165 × 10^1400` |
| Full encoded stick pairs, with B/Z combinations only | 262,144 | about `6.03932 × 10^812` | about `4.85210 × 10^4876` |
| Full encoded stick pairs and all 13 declared non-A button bits | 536,870,912 | about `3.02330 × 10^1309` | about `7.63637 × 10^7856` |

The last row is a **conservative encoding envelope**, not a claim that every
record is physically realizable or behaviorally distinct. Each stick axis is a
signed byte: 256 possible encodings give 65,536 pairs. The source declares 14
button bits; fixing A off leaves 13, hence `65,536 × 2^13 = 2^29` records and
`2^4350` or `2^26100` sequences for 150 or 900 updates. The two reserved button
bits are excluded. Other controller
ports, connection status and error flags are fixed in this calculation.
The header documents a normal stick range around -80 to 80, and hardware gates
and simultaneous-button restrictions can shrink the physical set. We have not
proved the exact physical or effective alphabet here. The smaller table rows
are illustrations or subsets, not exhaustive coverage of gameplay.

For scale, even a hypothetical trillion **complete sequences** per second
would take about `2.68 × 10^251` years to enumerate the 900-update two-choice example.
That is an arithmetic illustration, not a measured Wafel speed or an estimate
of the cost of a symbolic solver.

## Would five seconds be feasible?

**Much smaller, but still infeasible for exhaustive sequence-by-sequence
enumeration.** Five seconds is 150 nominal updates, so the unpruned count is
K^150. Even the two-choice example would take about `4.52 × 10^25` years at
the same hypothetical trillion complete sequences per second. Shortening the
horizon helps enormously, but does not make that enumeration practical.

Five seconds is a more reasonable target for a search that eliminates whole
sets, represents inputs symbolically, or merges states with proved equivalent
future behavior. Its actual cost remains unknown: the unpruned counts do not
predict how many predecessors of top retention survive. Selected finite trials
can be useful, but cannot establish coverage of all 150-update histories.
The current tool still covers local installation-frame cuts, not a complete
150-update transition. No five-second search was launched by this comparison.

## The project rules still matter

The table fixes A released throughout. Under the project's broader no-new-A
rule, an already-held A may remain held and then be released once. For a fixed
held-A initial boundary, 900 steps allow 901 A patterns, while 150 steps allow
151 (including never releasing); releasing and pressing again is forbidden. This is an additional
history condition, not another freely chosen A bit every frame. The earlier
history must justify an allowed held-A boundary where one is used. Newly pressed
bits for every button are derived from previous and current held bits; they are
not independent input choices.

“30 seconds” here means 900 nominal update steps. Lag or pause can make this
differ from 30 wall-clock seconds of running gameplay. If the desired wall-clock
or pause convention changes, use the corresponding number of controller polls.
There is one latched controller record per update; the several instruction
checkpoints inside the installation frame do not create extra input choices.

## What changes when we search backward

At each step we want every earlier state for which **some allowed controller
record** reaches the current target set. Repeating that operation 900 times
would cover the requested bounded horizon if the transition and predecessor
calculation were complete. The controller records can remain symbolic instead
of enumerating each encoding separately.

The table counts input sequences before any endpoint constraints or pruning.
It does not count predecessors of the checked top: a given sequence can have
no predecessor or many because the game overwrites information. We cannot yet
say how many predecessor states survive, or how much compute covers them.
There is no known number of sampled sequences that guarantees finding a witness.

The useful strategy is to eliminate whole sets with checked conditions, retain
inputs symbolically, and merge states only when their future behavior for the
claim is established equivalent. Matching Mario's coordinates alone is not
enough: previous buttons, action, camera, RNG, objects, floors and timers can
matter. Holding inputs for several frames or sampling eight directions can
make a useful search, but would not exhaust every per-update controller history.

The current [predecessor prototype](rank1-backward-search.md) analyzes selected
installation-frame cuts; it does not yet cover this 900-update transition.
Even complete exclusion of a specified 900-update predecessor domain would
need its start-state boundary made explicit before becoming a route exclusion.
A candidate still needs a controller-reachable prefix and a joined forward
check through the first useful Area-2 apply. No automatic 30-second search has
been launched by this size estimate.

## Sources and reproducible calculation

The pinned revision is `9921382a68bb0c865e5e45eb594d9c64db59b1af`.
`include/PR/os_cont.h` defines the two signed stick bytes and the 14 button masks.
`src/game/game_init.c:display_and_vsync` waits for two VI intervals;
`read_controller_inputs` reads the raw pair and derives pressed buttons from
the previous held mask; `adjust_analog_stick` applies dead zones and magnitude
clamping. The actual generated `us_game_init.v` and `jp_game_init.v` contain
these functions and the signed-byte pad fields. We have not assumed that raw
input distinctions can all be discarded after stick adjustment.

The displayed counts were computed with Python's standard decimal arithmetic:

```python
from decimal import Decimal, localcontext
with localcontext() as context:
    context.prec = 50
    for updates in (150, 900):
        for choices in (2, 36, 256**2 * 4, 256**2 * 2**13):
            print(updates, choices, format(Decimal(choices)**updates, '.5E'))
```
