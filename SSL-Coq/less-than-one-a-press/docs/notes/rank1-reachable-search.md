# Rank 1: an earlier controller search, through the real checks

Checked 27 September 2026. **No clean Ink installation was found.** This is
a finite search and a checked explanation of why selected continuations fail,
not a new Coq theorem or an exclusion of every allowed gameplay history.
Rank 1's subjective estimate remains 1–2%.

## What we actually tried

The old Wafel pilot began with the top already at timer 150. This batch starts
around the fourth-pillar trigger. Every checkpoint is reached by replaying the
existing clean JP controller prefix. No pose, action, timer, depth, support,
coin, enemy or RNG state is supplied. The only non-controller setup is the
previously accepted level-select entry.

There are 72 approaches from three nearby checkpoints, using four paths and
six B/Z choices, each followed for 240 updates. Another 60 variations try the
western Crazy Box, varying the earlier checkpoint, approach alignment, stick
strength and pickup distance, each followed for 420 updates. These are 132
controller choices, not 132 distinct routes. Some have identical outcomes.
There is no state merging or claim that the choices exhaust the controls.

Across 42,480 advances, 36,855 after-update samples are in SSL Area 1. None has
display above movement, negative quicksand depth, a null stored floor, or the
original top selected as platform. Ten box variations reach the disappearing
warp state, after the original top is gone. A stored-floor reading does not
certify earlier queries inside that update. All inputs keep A released; the
project's broader permission to hold A at entry is **not** covered by this batch.

## What the exact replay adds

The read-only emulator observer follows collision, the first geometry query
after both wall corrections, any retry, interaction, the ordinary copy, the
final platform query and its stores. It reads each query's actual arguments,
returned floor and returned binary32 height; it checks membership in the live
static/dynamic floor lists. It also observes the first Area-2 platform phase.

| Replay | First geometry queries | Retries | Accepted upper warp | Final outcome |
| --- | ---: | ---: | ---: | --- |
| Existing baseline | 329 | 0 | 1 | Static floor, no retained platform |
| Direct approach | 166 | 0 | 0 | Quicksand death before arrival |
| Northern approach | 190 | 0 | 0 | Quicksand death before arrival |
| Faster Crazy Box approach | 298 | 0 | 1 | Static floor, no retained platform |

All 983 first queries return a floor. All 983 final queries also return a
listed static, ownerless floor and finish with both platform references null.
These counts are across the four recorded intervals, including the baseline;
they are not counts of distinct global histories or an all-query census.
The direct and northern traces do contain a display split, but it points the
wrong way: the display is as much as 181.1000213623047 units **below** movement.
None has an upward gap at collision or the first-query checkpoint.

The new box arrival makes the distinction between acceptance and the final
query concrete. At timer 2825, immediately after the upper warp is accepted,
movement, collision and display all equal
`(-2035.295654296875,816,-1075)`. The returned floor is static, at Y=768, with
no Object owner. After the disappearing action and ordinary copy, all three
records equal `(-2035.295654296875,768,-1075)`. The final query selects that
ownerless floor. There are no active pyramid-top actors at acceptance.

At timer 2848, the first Area-2 platform phase enters and returns with a null
platform and all three positions unchanged at `(0,5500,256)`. That continuation
therefore supplies no Ink displacement. This does not contradict the supplied
JP Ink setup: the useful earlier split and remembered owner were never created.

## Where the backward search now stops

The missing transition is still **creating the useful gap before the first
geometry query, with low warp contact available and the top at a useful time**.
These walking and box approaches do not supply it. Getting to the warp, or
making a downward sinking offset, does not fill that missing step. Further work
needs a concrete earlier support/position change or another reachable action
history, rather than another assumption that the three records stay equal.

This batch does not cover all earlier pillar approaches, held-A entry histories,
other acts or starting star totals, reward/dialog predecessors, moving-support
histories or every possible writer. It does not impose the example coordinate
or 1170.8648681640625-unit gap as a universal Ink requirement. It neither closes
the whole route nor changes the accepted conditional negative-seed result.

## What was checked, and what was not

The [runner and compact receipt](../../instrumentation/rank1-reachable-search/README.md)
make the inputs and observations reproducible. The four complete Wafel replays
match 2,483, 2,367, 2,391 and 2,501 Area-1 emulator snapshots respectively,
under the previously established +1 global-timer mapping. All 900 outputs from
the three restored branch checkpoints also match. This is runtime agreement
at those boundaries, not a formal MIPS-to-Clight simulation.

The initial observer's list check used an uninitialized inherited node-pool
cache. Its receipts were rejected. The corrected observer reads the live pool;
all four captures were rerun and passed. Negative controls reject a missing
query, wrong height, missing list membership, wrong platform, A input and an
observer failure. A synthetic split is reported rather than filtered out; it
is a checker test, not a gameplay witness.

The existing generated-US/JP query-to-owner theorems are reused without changes.
No `.v` file is changed and no new formal closure is claimed. A fresh selected
Coq audit passed its build, proof-hole and link stages but did not complete:
WSL reported `Input/output error` while importing the main theorem for its
assumption check. Its incomplete runs remain in `build/audit/`; they are not
reported as passing. The last complete selected audit remains
`20260926-210704-9ushw0ao` for the unchanged proof sources.
