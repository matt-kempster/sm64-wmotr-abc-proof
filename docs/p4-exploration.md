# P4 exploration: the value-tracking refinement (how to make the hard step work)

P4 is the load-bearing wall: the semantic proof that a real game frame moves
Mario's action along an arrow of the abstract graph (P1-P3). This doc explores how
to actually build it, grounded in what the real code does.

## What P4 must deliver

In one line: **a no-A frame from a SafeAction ends in a SafeAction.**

Where `SafeActions` = action values from which flying is unreachable without an A
press (computed in P3 as graph reachability). Concretely the obligation feeding
`FlyingStatement.Phi_preserved_noA`:

    a_pressed_int i = false  ->  m->action in SafeActions  ->  mario_update i m m'
      ->  m'->action in SafeActions

## Grounding (what the real code makes true -- all checked against source)

These findings simplify P4 a lot:

1. **Every flying write is a LITERAL constant.** At all 5 flying-introduction sites
   the call is `set_mario_action(m, ACT_FLYING, 1)` or
   `set_mario_action(m, ACT_FLYING_TRIPLE_JUMP, 0)` -- never a computed variable. So
   the runtime value written equals the syntactic constant; **no data-flow analysis
   is needed for the flying cases.** (The general "computed argument" worry in the
   plan does NOT bite for flying.)

2. **The action field's writers are enumerated and finite.** Across all Mario TUs:
   `set_mario_action` (the routed writer) plus ~7 raw `m->action = CONST` writers
   (act_air_throw, act_ledge_climb_slow, bounce_back_from_attack,
   check_kick_or_punch_wall, init_mario, init_mario_from_save_file). Critically,
   **none of the raw writers writes a flying value** (ActionWriters/Flying:
   flying_action_writers = [] everywhere). The raw writers write non-flying literals.

3. **set_mario_action does not fabricate flying.** It routes through
   `set_mario_action_<group>`, which only remaps to non-flying actions or passes the
   argument through (Flying.fabricates_flying = false). So the value it writes is
   flying ONLY IF its argument is flying.

4. **The A-gate is at the JUMP-ENTRY arrows, and it is LOCAL.** Flying is reached
   only from the jump chain (`...JUMP -> DOUBLE_JUMP -> double-jump-land +wing-cap ->
   FLYING_TRIPLE_JUMP -> FLYING`). The flying arrows themselves are gated by
   wing-cap / jump-sequence state, NOT by a this-frame A press (R2's finding). But
   the arrows that ENTER the jump chain from a SafeAction (ground/idle/walk ->
   ACT_JUMP/DOUBLE_JUMP) DO locally test `m->input & INPUT_A_PRESSED`. So:
   **the only arrows leaving SafeActions are the jump-entry arrows, each a local
   A-check.** This is what makes P5 a handful of finite, local lemmas rather than a
   global temporal argument.

5. **A frame may shift action multiple times** (`execute_mario_action`'s
   `while (inLoop)` loop runs successive handlers in one tick). So a frame's net
   action change is a *path* of arrows, not one arrow. Handled by SafeActions being
   closed under arrows (transitive) + our existing loop handling (rung b).

## The shape of the proof

Two semantic pieces, then composition:

### Piece A -- the choke-point value frame ("action only changes via enumerated writes")

A refinement of rung (c). Rung (c) proved: if no reached function writes the watched
cell, it is unchanged. P4 needs the value version: across a frame, the action cell's
value stays inside a set `S` PROVIDED every action-write reached writes into `S`.

Stated as a strengthened mutual induction (exec_stmt / eval_funcall), motive:

    (load action m  in S)
      -> (every action-write reached in this execution writes a value in S)
      -> (load action m' in S)

Induction cases mirror rung (c):
- no write reached: action unchanged, stays in S (rung-c frame leaf).
- Sassign to a NON-action lvalue: action framed (ActionFrame field non-interference).
- Sassign to the action field (occurs only inside the ~7 raw writers and
  set_mario_action's body): the written value is in S by hypothesis -> stays in S.
- Scall: the callee's writes are part of "writes reached"; compose by the
  eval_funcall IH.
- Sequence / if / loop: compose (the loop case = multi-shift per frame).

This is genuinely new but is a controlled generalization of machinery we already
have (rung c + the action-field non-interference of ActionFrame). The hypothesis
"every action-write writes into S" is discharged by Piece B + the syntactic writer
enumeration.

### Piece B -- "under no-A, every reached action-write writes into SafeActions"

The writes are enumerated (finding 2). For each write site, its target value is a
syntactic constant (or, for set_mario_action calls, the transformed argument). Need:
every such target is in SafeActions UNLESS the site is control-dependent on an A
press this frame (in which case no-A means it isn't reached).

- Non-flying raw writers (finding 2): write a fixed non-flying constant -> in
  SafeActions by P3 (these are non-A arrows among SafeActions, or into the
  non-flying clusters that P3 still classifies safe). Pure reflexivity once P3 has
  the constants.
- set_mario_action calls with a SafeAction argument: write a SafeAction (finding 3,
  non-fabrication keeps it safe). Reflexivity given the argument constant.
- The jump-entry calls (argument ACT_JUMP/DOUBLE_JUMP = leaves SafeActions): these
  are LOCALLY guarded by `m->input & INPUT_A_PRESSED` (finding 4). Under
  `a_pressed_int i = false` the guard is false, so the call is NOT reached. This is
  P5: a per-site control-dependence lemma, finite and local (ShadowSpec-style guard
  reasoning on one handler at a time).

So Piece B = (reflexivity over the enumerated non-jump writes) + (a bounded set of
local A-guard lemmas for the jump-entry writes).

### Composition (P6)

Instantiate Piece A's `S := SafeActions`. Discharge its hypothesis with Piece B
(under no-A). Conclude `m'->action in SafeActions`. With P3
(`Phi_excludes_flying`) and the well-formedness invariant
(FlyingFrame.frame_preserves_wf), this is exactly `Phi_preserved_noA`.

## Strategy options for Piece A (the hard part) and recommendation

- **Option 1 -- full value-set induction (above).** Cleanest end state; most
  upfront work (a new mutual induction). Recommended target.
- **Option 2 -- segment at write sites.** Use rung (c) unchanged_on between writes
  + a per-write value step. Conceptually simple but big-step doesn't expose the
  linear write sequence, so segmentation is awkward. Not recommended.
- **Option 3 -- function specs + compositional table.** Prove a value-spec per
  action handler ("act_X leaves action in edges(X)") bottom-up. Modular and matches
  the graph, but multiplies into ~150 handler specs. Good as a fallback / for the
  leaf functions, heavy as the whole plan.

Recommend **Option 1** for the frame induction, using **Option 3 for the single
leaf that matters most first**: `set_mario_action` itself.

## Smallest de-risking experiment (do this first in P4)

Prove the **set_mario_action value spec** as a standalone lemma:

    eval_funcall set_mario_action ge m [Vptr bm 0; Vint a; Vint arg] t m' res
      ->  exists a', Mem.load Mint32 m' bm 12 = Some (Vint a')
                  /\ (is_flying_int a' = true -> is_flying_int a = true)

i.e. set_mario_action writes the action field, and the written value is flying only
if the argument was. This is self-contained, exercises value-level reasoning about a
REAL function (its switch + group-helper calls + the `m->action = action` Sassign),
and validates that we can do the non-fabrication step (finding 3) in Coq. It is the
leaf every other piece leans on. If this proves cleanly, Option 1's funcall case has
its hard sub-goal solved and we scale up; if it fights, we learn the real cost
before committing to the full induction.

A natural second experiment: extend FlyingFrame's `frame_unchanged_watched` from
"unchanged" to "value in S" for a frame whose ONLY action write is one
set_mario_action call with a SafeAction argument -- the two-piece composition in
miniature.

## Risk summary

- Piece A induction: HIGH but bounded -- it is rung (c) with a value set instead of
  a frozen cell; the per-case work parallels rung (b)/(c).
- set_mario_action spec leaf: MEDIUM -- a real function with internal calls, but the
  action-relevant slice is small and the non-fabrication facts exist syntactically.
- Piece B jump-guard lemmas: MEDIUM, finite -- per-site local control-dependence.
- The graph faithfulness for the ~7 raw writers: LOW -- fixed non-flying constants.
- Leaks unchanged: #2 only the set_triple_jump_action function-pointer (named
  symbol, resolvable); #3 cross-TU linking still open.

## Bottom line

The grounding turned P4 from "track arbitrary values through arbitrary memory" into
"(a) one value-frame induction generalizing rung (c), (b) a set_mario_action value
spec, (c) a handful of local jump-entry A-guard lemmas." The flying values being
literal constants and the A-gate being local are the two facts that make it
feasible. Start with the set_mario_action spec experiment.
