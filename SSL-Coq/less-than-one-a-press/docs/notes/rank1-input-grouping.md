# Rank 1: keep input possibilities together without losing their differences

**Follow-up:** the [conditional full-interval path checker](rank1-complete-update-path.md) now completes both US/JP controller-to-retention paths, including live callbacks. It uses a supplied scene and does not close exhaustive predecessor coverage or gameplay reachability. The earlier measurements and limitations below are retained as that earlier result.

27 September 2026. The first grouping implementation is checked against
selected actual generated US/JP statements. It keeps sets of inputs as exact
conditions and formulas, instead of choosing one example to represent a set.
This is exploratory solver evidence, not a new Coq theorem, a complete game
frame, or a 150-update search. Rank 1 remains at its subjective 1–2% estimate.

## What grouping means here

Suppose the raw horizontal stick value is between 8 and 127. The selected
controller code produces `raw X - 6` throughout that range. We can retain one
formula and its range condition instead of making 120 separate branches.
We still know the exact raw value symbolically; we have not claimed that all
120 choices move Mario the same way. Later checks can divide this group.

The implementation reads the original generated branches and keeps both arms
as conditional expressions. Substituting those expressions into a desired
result gives its predecessor condition. For the selected output goals, the
solver checks agreement with the existing branch-expanding backward engine.
That comparison checks two implementations using the same arithmetic and
memory interpretation; it is not an independent proof of that interpretation.

## The two checked cuts

| Selected code | What can be represented together | What must remain distinct |
| --- | --- | --- |
| Stick adjustment before `sqrtf` | 65,536 encoded pairs fit nine symbolic regions. The 225 pairs in the central dead zone all give adjusted X=Y=0. | Exact raw axes remain available. There are still 58,564 distinct adjusted pairs, not nine stick directions. |
| Mario's button helper, with A released | Of 8,192 declared masks, there are four helper-output groups when B was previously up, two when B was held, or one while squished. | Held and newly pressed bits remain in the Controller record. Other code may read them. |
| The same helper, with A already held | Keeping or releasing A gives eight, four or two groups respectively, from 16,384 masks. | The next sample uses the actual previous mask. Re-pressing A after release would violate the no-new-A rule. |

For each stick axis, the actual regions are `[-128,-8]`, `[-7,7]` and
`[8,127]`. Their adjusted values are respectively `raw + 6`, zero and
`raw - 6`. Each axis therefore has 242 distinct adjusted outputs; together
they have `242 × 242 = 58,564`. These are signed-byte encoding counts, not a
claim that every encoding can be produced by a physical controller.

The button groups are derived from the actual helper's output flags. For the
same other starting state, equal group signatures give equal writes to all
three fields this helper changes: input flags and the counters since A and B.
The solver checks this with arbitrary incoming flags and counter values. It
also checks that only prior A/B/Z bits affect the signature, and that all
nonzero squish timer values give the same signature behavior. Enumerating the
small one-sample alphabet then counts the members; this is not an enumeration
of gameplay histories.

The real controller sampling cut supplies
`pressed = current & (current ^ previous)` and stores `current` as held.
The search therefore cannot select pressed buttons independently of history.
It rejects a newly pressed A, while allowing a boundary that already has A
held. A legitimate earlier history for such a boundary remains an obligation.
No unexplained held-A starting history is granted.

## Why one representative per group would be wrong

Start with B already held. Releasing it or continuing to hold it gives the
same result in Mario's button helper on this update. Now hold B on the next
update. The first history produces a new B press; the second does not.
The generated-code check finds exactly that difference. Discarding the old
held mask would lose a real future behavior.

Raw stick values also survive the adjustment. Other stock code reads them,
including menu scrolling and Hoot steering; camera and action code also read
adjusted values. Those readers' existence does not establish that they occur
in the SSL interval. Keeping the original values avoids needing to assume
that none can matter before the actual consumer is examined.

## How this helps the backward search

Carry formulas for whole input sets into the installation conditions, then
split only when a reached consumer needs a distinction. Keep the same sampled
input across its update and carry the held mask into the next sampling check.
Position, velocity, action, timers, RNG, live floor and owner identity must
likewise remain represented wherever later code reads them. A contradiction
can eliminate a set only after the necessary intervening effects are covered.

The next bounded connection is from these input cuts through an actual action
and its consumers to the existing position/retention predecessor conditions.
The current merger rejects unsupported calls, loops and nonlocal control
flow. In particular, it stops before the real stick `sqrtf` call rather than
assuming that call's result or memory effects. The full-frame connection and
its cost have not been measured. Nine stick regions or four button groups
must not be raised to the 150th power and advertised as all game histories.

## Reproduce and inspect

The subsequent [one-update feasibility attempt](rank1-update-benchmark.md)
now traverses the real floor loops, but stops at the live native behavior
callback before completing its required object-update prefix. The complete
platform-call formula can be built; its unrestricted solver query returns
unknown after 15 seconds. Two and four updates were not run. Neither these
partial timings nor the passing regression fixtures establish a practical
full-update speed, live floor lists or a five-second budget.

Use the existing isolated dependency described in the
[tool README](../../instrumentation/rank1-backward-search/README.md):

```sh
python instrumentation/rank1-backward-search/group_inputs.py \
  --output build/rank1-backward-search/grouping-all-no-new-a
```

Both US and JP pass the local grouping, retained-input and backward-preimage
checks. The actual unexpanded call is rejected as expected. The
[saved report](../../instrumentation/rank1-backward-search/grouping-report.json)
records group counts, the B-history counterexample, generated-function hashes
and implementation hashes. Individual solver queries remain in ignored build
output. No `.v` file, accepted premise, Section 01 verdict or route estimate
changes. The earlier selected Coq audit does not validate this Python tool.

The selected controller cuts reuse the definitions checked in
`InkControllerSource.v` and the edge arithmetic in `InkControllerEdge.v`.
This batch does not extend those Coq theorems to the new grouping code.
