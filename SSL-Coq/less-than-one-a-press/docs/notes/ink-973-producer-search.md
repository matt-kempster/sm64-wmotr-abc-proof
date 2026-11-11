# Working backward from the 973-unit Ink handoff

**No clean no-A producer has been found. There are now controller-produced
local pieces, and the pushing actor need not be a shell.** From a supplied
roof position, ordinary Z and stick inputs establish crawling and briefly
carry Mario onto the spinning top. The highest observed crawl in the
tested continuations is Y=1330.632, below the required high crawl at
Y=1741. Separately, either an
existing jumping box or an existing Bob-omb gives the successful 973-unit
handoff when its position and Mario's high crawling state are supplied.
Those results leave two connected tasks: reach the high crawl at the right
time, and deliver a suitable actor to it through gameplay.

This follow-up starts from `codex/ssl-pyramid-item-proof` at
`db1ba9d459967884b43c8fff92cd3be87cc333af`, a descendant of the requested
`ee8ba92b509179699b15860538c69f66b7eb674a`. It uses the now-authorized gameplay
experiments and finite state searches. It does not add a Coq theorem,
original-ROM replication of these new trials, or an all-history exclusion.
The earlier [checked timer 130 handoff](ink-timer130-handoff.md) remains the
formal result under its stated entry, cache, geometry and execution-cut
hypotheses; the new experiments do not discharge its gameplay reachability
premises. Reported height maxima and proximity screens concern sampled
update boundaries, not every internal movement point.

## What the successful continuation actually needs

The original supplied fixture starts before the update executing top
behavior timer 130 with Mario's movement, collision and display positions
all at `(-1950,1741,-939)`, already crawling. Geometry obtains a fresh
Y=768 floor cache there. An eligible actor pushes him 68 units east before
the crawl step. The update ends with movement and collision at
`(-1882,768,-939)`, while display remains at `(-1882,1741,-939)`. The next
update, timer 131, captures the top; the continuation arrives in Area2
outside the elevator. This is a successful supplied-state continuation,
not an input history reaching its starting state.

The new tests remove several unnecessary parts of that setup. The shell's
four velocity edits can be omitted. Better still, an already-existing
jumping box or Bob-omb can substitute without spawning a shell. In two
minimal variants Mario also retains native speed zero, velocity zero,
facing, action state and action timer. Only his synchronized positions and
`ACT_CRAWLING`, plus the actor's XYZ, are supplied. Each still produces the
exact split and useful continuation. Neither the earlier speed-five setup
nor its chosen facing is necessary for these fixtures.

These endpoint measurements do not instrument every internal query or
prove a whole-update execution in Coq. They do retain the full native
object pool, RNG and timing state and run the actual updates continuously.
No floor cache, surface, allocator or ownership field is supplied in these
actor substitution controls.

## Getting into crawl, then keeping enough height

The [crawl predecessor study](ink-crawl-predecessors.md) distinguishes
starting crawl from preserving an existing crawl. At the high pad,
IDLE/CROUCHING/START_CRAWLING controls leave the floor and do not become
the required high crawler. On the slippery top, those starting actions
also have a slide cancellation that an established crawl handles
differently. See sibling decompilation
`src/game/mario_actions_stationary.c:528–546,693–710,743–765` and
`src/game/mario_actions_moving.c:467–477,1247–1298`.

A finite sweep supplied **position only**, leaving the prefix action,
speed, cache and platform unchanged. It tried nine phases, 52 roof X/Z
points at Y=1280, and two steering targets: 936 trials, 64,344 updates.
Holding Z and then steering established crawl in 130 trials. Ten briefly
had top-supported crawl. None had crawling Y at least 1741.

The best grid witness starts at stored timer 48 with
`M=C=D=(-2559,1280,-1535)` and inherited IDLE. No action or floor pointer
is patched. It enters crawl at stored 64, obtains top support at 79, reaches
Y=1330.204346 at 80, and returns to the static roof at 82. Its complete
84-update suffix was replayed from a fresh instance, with only the initial
roof-position patch; all 41 retained checkpoints and the final snapshot
matched. This is a real local action producer, with an unproduced approach
to its roof seed.

A continuation beam starts at that same controller-created top-crawl
checkpoint. It tests 17 Z/stick choices per retained state, width 16 and
horizon 52, retaining only crawling results. Across 13,889 one-update
branches, maximum observed crawling Y is 1330.6318359375. Top support disappears
after stored 81 among the tested crawling candidates. Two selected full
83-update trails independently replay from the original roof seed, with
all 52 retained branch snapshots matching and no intermediate patch. The
comparison concerns these sampled fields, not every hidden state field.
The search reaches its horizon with
low crawling survivors; it does not exhaust all controls or histories.
Paths leaving crawl and later re-entering, discarded beam states, other
seeds and different actor interactions are outside this coverage.

Here **stored timer** means `oTimer` between updates: stored 79 follows
execution of behavior 78. The high handoff must be ready before executing
behavior 130. A brief early crawl is not automatically a correctly timed
late crawl. The source's slope acceleration selects its sign by the
uphill/downhill half-plane of relative heading, not a cosine attenuation,
so roughly contour-parallel steering
does not eliminate it (`mario_actions_moving.c:283–330`).

The direct inverse-rotation proposal also has a concrete problem. The
approximate prior X/Z that rotates into the high pad is
`(-2013.015347,-899.266240)`. The loaded prior top plane there gives
calculated binary32 support Y=1905.116455, not 1741. This is a calculation
from native loaded plane data, not a hooked floor-query return. In 32
full-update diagnostics, all 16 supplied Y=1741 variants obtain the desired
low cache, but all 16 support-height variants retain a high top-owned
floor. The latter do not yield the Y=768 cache. This rejects the tested
supported inverse family, not every possible top predecessor.

## Delivering a pushing actor

The [shell study](ink-shell-producer.md) establishes a useful local release:
from a supplied elevated freefall above the stock box, Z causes a real
ground pound, which releases a shell after 31 updates with no box-action
edit. The missing part is reaching that elevated approach and moving the
free shell to the pyramid. Two neutral 120-update shell trajectories remain
local; their observed height and travel are not global bounds.

Ordinary grounded riding followed by Z does not park a free shell. A local
control supplies nearby walking Mario, mounts through real interaction,
dismounts with Z, and observes the shell
become inactive and its slot be reused. Source agrees: dismount sets
`INT_STATUS_STOP_RIDING`, and the shell deletes itself on that bit
(`interaction.c:280–286`, `mario_actions_moving.c:1200–1213`,
`behaviors/koopa_shell.inc.c:81–102`). A different lifetime or clone history
would need its own concrete continuation.

The alternative-actor experiment avoids that shell-specific difficulty:

| Existing actor | Supplied actor XYZ before timer 130 | Result |
| --- | --- | --- |
| Western jumping box, slot 49 | `(-1989,1741,-939)` | Exact 973 split, timer 131 top capture, useful Area2 arrival |
| Bob-omb, slot 39 | `(-1979,1741,-939)` | Same |
| Same two actors, minimal Mario setup | Same respective XYZ | Same, retaining native Mario speed/facing/action-state fields |
| Jumping box, X/Z only | `(-1989,25.362259,-939)` | No high contact, no top capture, ordinary elevator arrival |

All four successful cases arrive at the sampled Area2 position
`(365.5927734375,5500,-1096.8026123046875)`. These are after-update
observations, not new first-apply breakpoint traces. The actors retain
their native actions, velocities, hitboxes and object-pool histories.
The native jumping box began at `(-5200,25.362259,1700)` and the Bob-omb
near `(3475.331,0,6041.801)`; moving either beside Mario at 1741 is still a
large supplied displacement. Carry/release histories for them have not
been constructed. Their success establishes actor substitution, not
controller delivery. Old timer 131 free/allocation counts are not imported
into these changed histories.

## Searches with no gameplay setup edits

Two limited policy families start from accepted controller prefixes:

| Screen | Scope | Observed result |
| --- | --- | --- |
| Pyramid approach | 90 combinations of three steering biases, six B timings and five Z timings after the fourth pillar; up to 133 updates each | 11,902 updates; 86 reach stored 130; no top support or high-crawl prerequisite; no sampled position within 1000 X/Z units of the pyramid center |
| Shell-box approach | Eight direct/waypoint steering policies after input 650; 600 updates each, occasional B near the box | 4800 updates; no box break or shell; final Y=51 below the box |

These are small ground/dive steering menus. They do not cover tornado,
enemy bounce, carried-box elevation, arbitrary earlier prefixes or all
controller inputs. The pyramid screen's best-by-distance phase130 sample
is already dying far away; its fresh-boot replay is a reproducibility
check, not a near-solution. Failures here provide no general no-A exclusion.

## Commands, checks and remaining gap

All five commands below completed with exit 0, from
`SSL-Coq/less-than-one-a-press` in PowerShell. Output files are exclusive;
choose fresh names when rerunning. The native DLL and accepted capture
hashes are recorded in every study. The runtime SHA-256 is
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`;
the capture SHA-256 is
`9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72`.

```powershell
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_crawl_predecessors.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-crawl-predecessors-20261111-expanded.json
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_crawl_continuation_beam.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-crawl-predecessors-20261111-expanded.json build/wafel-pilot/ink-crawl-continuation-beam-20261111.json
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_shell_producer.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-shell-producer-20261111.json --receipt docs/notes/ink-shell-producer-receipt.json
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_clean_approach_search.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-clean-approach-20261111.json
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_alternate_push.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-alternate-push-minimal-20261111.json
```

The committed receipts preserve patch ledgers, selected continuous input
histories, native observations, source hashes and replay results:
[crawl and beam](ink-crawl-predecessors-receipt.json),
[shell components](ink-shell-producer-receipt.json),
[clean approach](ink-clean-approach-receipt.json), and
[alternative actors](ink-alternate-push-receipt.json).
Script syntax, receipt/source hashes, counts and selected raw-to-compact
correspondence are checked separately without repeating gameplay.

```powershell
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/verify_ink_producer_receipts.py
```

This read-only audit exited 0. It matched all five script hashes, the DLL
and capture hashes, the named raw reports and compact projections, the
936 grid rows, the 13,889 beam count and the other trial counts. It found
no A bits in 17,148 retained button records, 1,172 sampled Mario-input
fields or the 2,548-row prefix, and checked the recorded setup-write
scopes. These counts concern retained records; the runtime scripts also
assert no-A input during the experiment updates. The audit does not run
gameplay again. The clean approach's independent replay checks the
phase 130 snapshot; shell and alternative-actor component trials do not
claim an independent fresh-boot replay. The shell raw report has no
embedded script hash, while its compact receipt records the matching
current source hash. The audit resolves its paths from the script's
location and expects the named raw reports above to exist.

No Coq source, generated target or theorem premise changes in this
follow-up. The preceding selected audit
`build/audit/20261111-101337-jsfng940` passed; it is historical validation
of the timer 130 geometry and bounded stop proofs, not certification of
these new runtime searches. The accepted prefix uses the established
pre-entry level-select setup. After the stated prefixes, the clean screens
write controller inputs only; local component tests additionally make
their explicitly listed setup writes. The new experiments use the pinned
native JP Wafel build, not a new original-ROM emulator replication.

The strongest next target is a continuous history connecting the
controller-created low roof crawl to a high established crawl, together
with an eligible actor's arrival before timer 130 interaction processing.
Current work establishes neither that joined history nor its
impossibility. The atlas's gameplay verdict stays open and its subjective
estimates remain Rank1 **1–2%**, Ink Rank2 **<1%**.
