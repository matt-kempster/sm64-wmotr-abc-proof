# R3 action plan: from "did anything write the action?" to "what VALUE, and was A pressed?"

Status date: 2026-05-30. Supersedes the optimistic framing of the FlyingFrame.v
bridge (which is sound but, by itself, inapplicable to real frames -- see below).

## 0. Where we actually are

Proved and solid:
- **The memory engine** (`ActionFrame.v`, rungs a/b/c): running game code -- through
  calls and loops -- preserves any memory region nothing reachable writes to.
- **The honest top statement** (`FlyingStatement.v`): "a no-A run never reaches a
  flying action," grounded in real loads (gMarioState pointer -> action field;
  INPUT_A_PRESSED bit), with the hard part quarantined as named hypotheses.
- **The bridge** (`FlyingFrame.v`): preserving the two cells that decide
  `flying_mem` preserves it; rung (c) supplies that preservation.
- **Syntactic corpus** (`Flying.v`, `ActionWriters.v`, `Reach.v`): the 5 flying
  *introduction* sites; every Mario TU has zero *raw* action writers (all action
  changes go through `set_mario_action`); a static call graph over one TU.

The catch the bridge exposed: its premise is "**no** reached function writes the
action field." But `set_mario_action` writes `m->action` every frame. So that
premise is globally false for the real program; the bridge cannot fire on a real
frame. It is scaffolding that *localizes* the obstruction, not a discharge.

## 1. The reframing that makes R3 tractable

Two facts found by reading the real code:

1. **Dispatch is a direct switch on the action value.** `execute_mario_action`
   masks the action group, calls `mario_execute_<group>_action`, which does
   `switch (m->action) { case ACT_X: cancel = act_X(m); ... }`. No
   function-pointer table in the hot path. The action constant *names* the handler.

2. **`set_mario_action` writes a non-fabricating transform of its argument.** It
   routes through `set_mario_action_<group>`, which only ever remaps to *non*-flying
   actions (e.g. squished `ACT_DOUBLE_JUMP` -> `ACT_JUMP`) or passes the action
   through unchanged. (Flying.v already proved these helpers `fabricates_flying =
   false`.) Hence: **`m->action` becomes flying  ==>  the *argument* to
   set_mario_action was flying.**

Together these convert the problem from a memory trace into a **finite graph over
the action constants**:

- **Nodes** = action constants (a finite enum, ~150 values).
- **Edges** `X -> Y` = "the handler `act_X` (reached when `m->action == X`) can call
  `set_mario_action(m, Y, _)`." Extracted syntactically from each `act_*` body.
- **A-labels**: an edge is *A-gated* if the call is control-dependent on
  INPUT_A_PRESSED (directly, or on state only reachable via an A-gated edge).
- **Flying edges**: edges into a flying value -- exactly the 5 R1 sites.

The claim "no flying without A" becomes: **in this graph, every path from a
reachable start node to a flying node traverses an A-gated edge.** That is a
*finite, decidable* property -- computable by reflexivity, like Reach.v's
fuel-bounded closure.

This is the two-axes split (docs/two-axes-syntactic-vs-semantic.md) applied to R3:
- **Axis 1 (syntactic / decidable):** build the graph + A-labels from the AST;
  compute flying-unreachable-without-A by `vm_compute`/reflexivity.
- **Axis 2 (semantic / the hard soundness):** prove the graph *over-approximates*
  real execution -- every real frame's action change is an edge, and every flying
  edge really is A-gated in the semantics. This is where rung (c), refined to track
  the *value*, and the per-guard input lemmas live.

## 2. What we have vs. what we need (files)

Already clightgen'd and in the build (sufficient for the Mario-action core):
mario.c, mario_step, mario_misc, all 7 `mario_actions_*` groups, interaction,
level_update, behavior_actions.

Likely **no new game files needed for the core argument.** The input rising edge
INPUT_A_PRESSED is computed in `update_mario_inputs` (in mario.c, already have it);
we stop the "press A" notion there (the rising edge IS "pressed A this frame" --
defensible; going below it to raw controller bits buys nothing).

New files needed only for the *edges* of the theorem, both already known leaks:
- **R4 / warp spawn**: levels/wmotr level-script data -- clightgen rejects it
  ("initializer not compile-time constant"); needs a separate level-data pipeline.
  Deferred; class-3 (warp) flight is established textually only.
- **Cross-TU linking** (leak #3): no CompCert `Linking` step yet; "every reached
  function" currently means per-TU. Needed to make the whole-game claim airtight.

## 3. Phased action plan

Each phase is a file/extension with a concrete, checkable deliverable. Axis-1
phases are reflexivity-style (tractable); Axis-2 phases carry the real risk.

### P1 (Axis 1) -- Action transition graph, extracted. `ActionGraph.v`
Scan every `act_*` handler body: collect the set of `set_mario_action`-family
calls and their (possibly symbolic) action argument. Emit, per action constant X,
the list of out-edge targets. Reuse Flying.v's `expr_has_flying` / arg-walking and
Reach.v's per-function scan. Deliverable: `action_edges : ident -> list action`
plus the flying out-edges = exactly the 5 R1 sites, by reflexivity.
Risk: low. Non-constant arguments land in a `computed` bucket to be sized (hope:
the flying ones are all literal `ACT_FLYING*`).

### P2 (Axis 1) -- A-gate labelling. extend `ActionGraph.v`
For each flying edge, record whether the call is control-dependent on a read of
INPUT_A_PRESSED. R2 already found these are NOT locally A-gated -- the gate is
*upstream*, via the jump chain. So P2's real output is the **chain structure**:
ACT_FLYING <- ACT_FLYING_TRIPLE_JUMP <- double-jump-land <- ACT_DOUBLE_JUMP <-
ACT_JUMP, plus which edges in THAT chain read INPUT_A_PRESSED (the jump-entry
edges, in moving/stationary). Deliverable: an `a_gated_edge` predicate + the
reflexivity fact that every flying node's only in-edges come from the chain.

### P3 (Axis 1) -- Finite reachability closure. `ActionReach.v`
Define `reaches_without_A : action -> action -> Prop` as the fuel-bounded closure
over non-A-gated edges (à la Reach.v `reaches`). Compute, by reflexivity:
`~ reaches_without_A start ACT_FLYING` and `~ reaches_without_A start
ACT_FLYING_TRIPLE_JUMP` for every non-flying start. Deliverable: the decidable
heart of the theorem -- "flying is graph-unreachable without an A-gated edge."
Risk: low-medium (depends on P1/P2 graph being acyclic enough; fuel sizing).

### P4 (Axis 2, the crux) -- Value-tracking refinement of rung (c). `ActionValue.v`
The semantic bridge from a real frame to one graph edge. Strengthen
FlyingFrame.frame_* from "action unchanged" to:

  after a frame from action X, `m->action in {X} U action_edges(X)`

i.e. the action field's new value is the old one or one of X's enumerated
out-edge targets. Proof: refine `exec_funcall_reach_unchanged_on` so the ONE
permitted writer (`set_mario_action`) is handled by value -- the written value is
its argument, and the argument at each reached call site is an enumerated edge
target (P1). Uses the non-fabrication facts (Flying.fabricates_flying=false) to
push the group-helper transform through. **This is the genuinely hard, genuinely
new work** -- the all-or-nothing avoidance of rung (c) becomes a may-write-this-set
analysis. Risk: high. This is the real R3 core.

### P5 (Axis 2) -- Per-edge A-gate soundness. `ActionGuards.v`
For each A-gated edge in P2, prove semantically that taking it requires
INPUT_A_PRESSED set this frame: the handler's path to that `set_mario_action` call
is control-dependent on `(m->input & INPUT_A_PRESSED) != 0`. This is per-site,
finite, and reuses ShadowSpec-style input/guard reasoning. Includes resolving the
one function-pointer hop (`set_triple_jump_action` into `common_landing_cancels`)
by its statically-known symbol (leak #2, mild here). Risk: medium, but bounded
(small number of edges).

### P6 -- Assemble: discharge Phi_preserved_noA. wire into `FlyingStatement.v`
Instantiate the abstract `Phi` with the concrete graph invariant:
`Phi m := mario_wf m /\ m->action in SafeActions`, where `SafeActions` = nodes that
don't `reaches_without_A` a flying node (P3). Discharge the three obligations:
- `Phi_excludes_flying`: SafeActions excludes flying nodes (P3, reflexivity).
- `Phi_preserved_noA`: a no-A frame moves action along a non-A edge (P4 value +
  P5 guards: a flying edge would need A, excluded by `a_pressed_int i = false`),
  staying in SafeActions; well-formedness preserved (FlyingFrame.frame_preserves_wf).
- base case: Mario's initial action is in SafeActions (the spawn action; R4/level).
Then `real_frames_need_A` becomes UNCONDITIONAL (modulo the named leaks). Risk:
integration; the content is in P3-P5.

## 4. Dependency order and risk map

P1 -> P2 -> P3   (Axis 1; low risk; do first, gives the decidable skeleton)
P1 -> P4         (Axis 2 core; highest risk; the value-tracking semantics)
P2 -> P5         (Axis 2; medium; per-edge input guards)
P3,P4,P5 -> P6   (assembly; makes the top theorem unconditional)

Suggested immediate next step: **P1** -- extract the action graph. It is low-risk,
reflexivity-style, reuses existing machinery, and its output immediately tells us
how big P4/P5 really are (how many `computed` arguments, how many A-gated edges).
It de-risks the crux before we invest in the hard semantics.

## 5. Standing leaks (unchanged, tracked)
- #1 aliasing: handled where it arises by the explicit avoid side-conditions.
- #2 indirect calls: only `set_triple_jump_action` on the flying path; statically
  known symbol, resolved in P5.
- #3 whole-program: no CompCert Linking step; "every reached function" is per-TU.
  Needed for the final airtight whole-game claim.
- R4 warp class-3: levels/wmotr data not mechanized (clightgen rejects level
  scripts); established textually.
