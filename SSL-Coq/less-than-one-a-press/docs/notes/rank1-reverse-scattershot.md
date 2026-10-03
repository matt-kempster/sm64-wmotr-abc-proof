# Rank 1: what a Reverse Scattershot search could do

**3 October variant-only run:** the [low-display follow-up](rank1-low-display-backward.md) uses a thirty-update horizon from movement Y=1861 and collision/display Y=768. It checks 1,476 proposals in 9.95 seconds, retains one last-update pose and rejects all 1,260 sampled earlier proposals. A final-dialog near match has the wrong collision height. No thirty-update chain, new producer or full predecessor coverage is obtained; all atlas estimates and Coq verdicts stay unchanged.

**2 October Ink experiment:** the [new concrete backward run](rank1-concrete-ink-backward.md) starts from the supplied installation, tests 7,812 proposals in 51.0 seconds and keeps six last-update pose cases. No tested earlier move reproduces them, so the finite tree empties at depth two; the requested thirty-update chain remains absent. Three named setups pass the exact emulator checkpoint and first Area-2 apply, including movement Y=1861 with collision/display Y=768 and depth zero. That variant requires a 1,093-unit movement/collision split, not a raised display; its producer remains open. This is a finite menu in supplied contexts, not exhaustive one-second coverage or a no-A producer. All route estimates and Coq verdicts remain unchanged.

**2 October runtime follow-up:** the [tiny concrete backward pilot](rank1-concrete-backward-pilot.md)
passes the installed Wafel JP check: a target-derived vertical freefall
predecessor matches, a deliberately wrong height is rejected, and a two-edge
continuous replay matches without an intermediate patch or restore. Fifteen
code tests pass. Matching is explicitly limited to a named projection, with
the remaining state supplied by saved contexts. This is a checked small
backward-testing loop, not a new Ink witness, full-state inverse or route result.
The dated methodological review below is retained as historical context.

## 2 October clarification: find where the gap was first made

The point of working backward is to discover whether gameplay can make the
useful separation, not merely to find another position that works after a
large display gap has been supplied. The freefall pilot checks that its loop
works; its other fields come from recorded contexts, and its accepted mapped
values reproduce the known trace. It has not found an Ink producer.

For an Ink branch, the checkpoint is the successful nonfading `interact_warp`
return in Area 1, before the disappeared action executes. The existing exact
emulator observer records all three position vectors there and follows the
later ordinary copy and final platform query. The installation test must
also check the required top selection and retention; disagreement alone is
not sufficient. An end-of-update observation cannot substitute for the
within-update checkpoint.

Each backward edge should record whether it creates the useful gap or merely
inherits it. A candidate that inherits it stays unexplained and must be
followed further backward. It must not be rejected just because that one
edge did not create the gap. Conversely, restoring a high display from the
saved context and finding a successful low-position proposal does not show
how the display was raised. The first actual writer or support change that
creates the useful separation is the target of the producer search.

Keep multiple compatible candidates, state exactly which values each inverse
move proposes and which come from context, and replay every extended chain
continuously from its earliest patch. No intermediate patch may manufacture
the next checkpoint. Matching selected fields validates the tested suffix;
it does not establish equality of omitted state or controller reachability.
A final witness needs a controller-only replay from the accepted SSL start,
with no gameplay state patches and no new A press.

An unsuccessful randomized batch says only that its sampled moves found
nothing within the budget. It can still expose a shared obstruction. If the
actual source and checked proof show that every relevant predecessor in a
named mechanism violates a required condition, that mechanism can be ruled
out under the stated model conditions. A complete backward preimage that is
empty, or excludes the accepted starting states, can support the same kind of
conditional exclusion. Missing inverse moves, supplied-state validity and
uncompared state must not be converted into coverage by a failed sample.

Ruling out the exact timer-131, 1,170.864868-unit example does not by itself
exclude every Ink installation. Whole-installation impossibility needs
coverage of every useful accepted-warp/top-retention variant allowed by the
selected model, including a gap created earlier and preserved across more
than the initial one- or two-update window. The example gap is not a universal
minimum. A checked obstruction can close a narrower approach before this
broader coverage is established.

This is a clarified goal and reporting rule, not a new Ink experiment or
proof result. No new predecessor search has run in this review, no route
estimate changes, and nothing is promoted to Already proved.

**Follow-up:** the [conditional full-interval path checker](rank1-complete-update-path.md) now completes both US/JP controller-to-retention paths, including live callbacks. It uses a supplied scene and does not close exhaustive predecessor coverage or gameplay reachability. The earlier measurements and limitations below are retained as that earlier result.

27 September 2026. **Method review only.** No reverse randomized search was
implemented or run in this review. The requested complete one-update run is
still unfinished. There is no new gameplay witness, exclusion or probability
estimate; Rank 1 remains at its subjective 1–2%.

## Why the requested one-update run was not completed

The previous work stopped after a tested partial repair, before the user's
explicit completion criterion. That was a missed deliverable. The implementation
gaps explain the unfinished result; they do not justify treating it as complete
or show that the requested run is infeasible.

The [recorded application results](rank1-update-benchmark.md) separate two issues.
The broader US/JP calculation cannot yet follow the live script's native call in
`bhv_cmd_call_native` through its actual receiver and effects. The complete
controller/level scheduler and effects between retention checkpoints are also
unconnected. Separately, the unrestricted final-platform helper formula was
constructed, but its solver returned unknown after a 15-second limit. That
helper is not a complete update. Neither result supplies a complete predecessor
set, an empty set, or a measured cost for longer windows.

## What Scattershot contributes

In the creator's [2022 explanation](https://www.reddit.com/r/speedrun/comments/wrkcmc/i_made_a_bot_that_tied_a_tas_wr_in_sm64_from/),
random controller trials build an archive of attained states, grouped using
position, angle, speed and action. A faster route can replace an earlier route
to a similar state. This reuses useful discoveries rather than always restarting
one random input string. This review uses the public explanation, not an audit
of a current Scattershot implementation.

Random sampling trades exhaustive coverage for a controllable search budget. It
does not remove the size of the underlying input space or guarantee that a rare
useful history will be sampled. We have not measured its benefit for this Ink
question.

## A literal backward version

An update maps a previous state and controller input to a later state. A reverse
search must find previous-state/input pairs whose real forward update satisfies
the selected endpoint. Choosing B, or any other input, does not determine that
previous state. Copies, floor alignment, clamps and rounding can erase it.

A suitable proposed search would:

1. Start with the actual installation conditions and multiple possible endpoint
   states. A coordinate triple or large display gap alone is not installation.
2. Generate candidate predecessors using the real update relation, choose among
   them stochastically, and check each proposed edge by executing it forward.
   Save alternatives and restart from different frontier states when stuck.
3. Keep a compatible complete suffix. Adjacent local solutions must agree on
   their shared state; independent solver examples cannot simply be spliced.
4. Join a backward suffix to a controller-reached prefix from the accepted
   start, with an exact or justified suffix-preserving state match. Replay the
   complete joined inputs and check warp acceptance, final top retention and
   the first Area-2 platform displacement.

Random branch selection helps with exploration **after** predecessors can be
generated and checked. It does not implement the unresolved callbacks or
scheduler. An arbitrary sampled state may have locally valid predecessors yet
never be reachable from the accepted start. A supplied endpoint can also be
unreachable. Searching one such endpoint cannot rule out other installations.

## The practical hybrid for finding a case

Use the existing Wafel forward adapter to branch from saved states actually
reached by controller play, and use backward-derived requirements to guide which
branches to try. Wafel executes the game's callbacks concretely; this does not
require first finishing their symbolic translation. It is forward search guided
by backward conditions, not a claim that Wafel already provides inverse updates.
Restore only played checkpoints, preserve their input history, and validate a
promising complete replay with the original-game observer. The existing finite
Wafel comparisons do not prove general equivalence to the original game or Coq.

Keep full states for replay. Coarse buckets may choose what to explore next,
but must not be treated as proved equivalence classes. For Ink, useful search
features include all three position records, action and velocity, held-button
history, RNG, floor/support ownership and lifetime, the top's timer and phase,
and the precise contact/query checkpoint. This is a list of important features,
not a proof that this key captures every future-relevant difference.

Keep several representatives and timing phases. The fastest arrival at a
similar position need not be the useful arrival. A slower route may retain the
right top, display gap or contact timing. Score intermediate requirements
separately; proximity to the pyramid or gap size alone can favor a dead end.
Observe the relevant points within an update because a temporary split can
disappear before an after-update sample.

The creator's [2023 Pyramid report](https://www.reddit.com/r/speedrun/comments/12527np/a_new_tas_strat_for_shining_atop_the_pyramid_sm64/)
says those particular searches omitted objects. We cannot adopt that
simplification for Ink: live objects, surfaces, owners and their timing are
central to this question. This is a limitation of that reported configuration,
not a claim about every Scattershot version.

## What the results would mean

| Result | What it establishes |
| --- | --- |
| Complete allowed replay produces the installation | A gameplay witness in the checked version, start and controller scope; it refutes a matching impossibility claim. |
| Forward check rejects one proposed predecessor edge | That exact candidate edge fails. Other predecessors remain possible. |
| Compatible backward chain has no controller-reached prefix | A conditional candidate, not established gameplay reachability. |
| Random trials find nothing within the budget | No witness found by that search. No branch or route is thereby excluded. |
| Sound exhaustive predecessor analysis or a proved invariant excludes a named branch | A scoped obstruction, with its coverage and assumptions stated. Random sampling alone cannot provide this result. |

The recommendation is to use an archive, diverse representatives and repeated
short trials for **counterexample hunting**, with backward requirements guiding
the search. Specific failures can suggest the next bounded proof. This does not
replace the still-requested complete one-update implementation or promote a
random search failure to impossibility. No new work is reported as executed.
