# High shell bridge: scoped generated-Clight checkpoints

The proof explains one specific obstacle to keeping a newly mounted shell
through the next update. In the tested high coordinates, the ground query can
find a low floor while the ceiling query supplies the default ceiling height
20000. The quarter-step compares **next movement Y + 160** with that ceiling.
The cutoff is therefore 19840 for the checked integer samples, not 20000.
The shell handler treats stopped ground result 2 as a request to stop riding
and enter backward ground knockback. Common slides instead reach their real
floor-alignment call after their corresponding result-2 branch.

This is a proof about reached portions of the generated program. It is not a
proof that every shell entry encounters those queries, that shell delivery is
reachable, or that no shell-assisted handoff exists. A quarter-step Y is not
automatically the movement Y at the start of the complete update.

## Code and boundaries

New module: [`InkShellBridge.v`](../../proofs/InkShellBridge.v). The module is
registered in `_CoqProject`. Its integration proposition is
`InkShellBridgeBoundary`, proved by `isb_shell_bridge_boundary_checked`.
`MainTheorem.current_ink_shell_bridge_boundary` consumes that theorem.

- `isb_high_quarter_tail_executes` constructively executes the **actual**
  `ifh_post_water` cut of `perform_ground_quarter_step`. Ordinary temporary and
  next-position memory premises, plus the two exact Float32 comparisons,
  suffice. It returns 2 with an empty trace and identical entire memory. No
  execution premise or opaque external-call oracle is needed for this tail.
  The queried local floor height and Mario's cached floor height are different
  quantities: identity of the entire memory preserves whatever cached height
  was already present; the proof does not construct the earlier fresh query.
- `isb_sample_quarter_tails_execute` instantiates this construction for JP at
  next Y = 19840, 19900, 25000, 67277 and 90536, each with queried local floor
  768 or 1280 and ceiling 20000. These ten pairs are finite samples, not a
  continuous range or a set of successful handoffs. The separate lemma
  `isb_default_ceiling_integer_edge_checked` checks the Float32 ceiling guard
  at 19839 (false), 19840 (true) and 19900 (true).
- `isb_real_ground_return_drives_switch` connects the JP shell handler's real
  `perform_ground_step` call to its `_t'4` result variable and following switch.
  The callee is resolved in the selected linked Clight target; an arbitrary
  invented return value is not substituted for the call.
- `isb_stopped_branch_executes` constructs the actual JP shell result-2 switch
  execution from the executions of its stop-riding, sound, particle and
  action-request fragments. All helper/store effects and their order are
  retained. They are not assumed to preserve memory.
- `isb_stopped_shell_reaches_real_knockback_request` proves that every
  completed execution of that switch with result 2 has the real stop-riding
  statement, sound and particle updates, followed by a call to the selected
  native `set_mario_action` with action 132194 (`BACKWARD_GROUND_KB`) and argument
  zero, on the same Mario pointer. The theorem states a real action request;
  it does not claim that arbitrary later code preserves the requested action.
- The boundary also retains the existing
  `isl_stopped_slide_reaches_real_alignment` checkpoint. That theorem proves
  common-slide alignment and its real floor-height store after actual branch
  effects, with its own explicit selected-global and memory hypotheses.

The constructive quarter tail and handler-call checkpoints are separate
reached cuts. The theorem does not silently compose them into a complete
quarter loop, action update or original-ROM execution. In particular, one
still needs the query prefix, actual loop return, action-entry path, and the
full handler's later code to connect a runtime fixture to these cuts.

## Exact remaining obligations

To obtain a shell bridge, gameplay must first deliver an initialized mountable
shell and place Mario above it, with a usable pusher and compatible top phase.
The mount must survive the remainder of that update with the state required
by the next update's producer. This proof narrows the default-ceiling branch;
it does not rule out a different floor/ceiling, geometry, action path or later
multi-update mechanism. A false ceiling comparison alone does not establish
successful riding: the ordinary high-floor-gap path can instead return
`LEFT_GROUND`, and the shell's case 0 requests `RIDING_SHELL_FALL`.

No theorem here asserts item delivery, a new-A-free controller history, an
Ink split, top capture, retained platform or useful displaced spawn.

## Provenance and checks

Starting proof revision: `162617b708b2244beca85af58b76ad5794e598cd` on
`codex/ssl-pyramid-item-proof`. Source study uses the existing generated JP
Clight and the repository's selected-target infrastructure. The parallel
runtime study identifies its source build separately; runtime observations
are not substituted for Coq execution premises.

Build command (Ubuntu WSL, from the SSL proof directory):

```sh
bash pipeline/build.sh audit-build AUDIT_VO_TARGETS=proofs/InkShellBridge.vo
```

The checked toolchain is switch `sm64-item-proof`, Coq 8.16.1 and CompCert 3.15,
using the established 6815744 KiB virtual-memory cap. Small Float32 samples
are reduced; the whole generated program is never computed.

On 2026-11-14 the targeted pipeline build **passed** (exit 0). The existing
`pipeline/assumptions.sh` also **passed** for
`LessThanOneAPress.Proofs.InkShellBridge isb_shell_bridge_boundary_checked`,
under `pipeline/env.sh`, the same memory cap, and a 240-second timeout.
Logs are `build/ink-shell-bridge-build.log` and
`build/ink-shell-bridge-assumptions.log`.

The boundary has **seven standard Coq/CompCert assumptions**, with no
new project-local axioms: `ClassicalDedekindReals.sig_not_dec`,
`ClassicalDedekindReals.sig_forall_dec`, `Axioms.proof_irr`,
`Events.inline_assembly_sem`,
`FunctionalExtensionality.functional_extensionality_dep`,
`Events.external_functions_sem`, and `Classical_Prop.classic`. No axiom,
`Admitted`, or source replacement is introduced in this module. The parent
investigation separately records its final Main-boundary integration audit.

The final selected audit **passed** at `build/audit/20261114-143728-hx1mu6zs`: Main compilation, source inventory724, proof-hole/link checks, three assumption checks(7/7/9 allowed foundations), and integration558/644 Main-closure modules with zero problems. The seven-foundation checks are the new module and Main shell boundaries; nine belongs to the unchanged backward-execution boundary. Explicit theorem premises remain separate from this axiom report. The reproducible audit package is `instrumentation/ink-shell-bridge-proof/`; its saved checks do not establish a whole-game impossibility theorem.
