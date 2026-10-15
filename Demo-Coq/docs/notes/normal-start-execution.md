# Executing the normal-mode demo Start prefix

The full gameplay verdict remains **OPEN**. This result executes the
actual caller prefix selecting Demo Next. It does not prove a loaded-level
invariant, legal boot reachability, all intro-text rendering behavior, or
the remainder of the normal gameplay frame.

`DemoNormalStartExecution.v` proves
`generated_normal_demo_start_prefix_executes` for
`demo_normal_start_execution_claim`. A selector takes the exact first
statement of the generated `play_mode_normal`; the US and JP selected
caller prefixes are checked identical. Coq executes the real current-demo
load and nonnull test, the named intro-text call, controller reads, the
END_DEMO-clear test, the inactive-transition and no-pending-operation
tests, the Start-mask test, the Mario-state load, and the actual
`level_trigger_warp(mario,22)` call. That last call uses the complete
scheduler/transition/RGB execution proved earlier. Final operation and
timer loads are 22 and 20.

The only remaining execution premise in this caller theorem names the
actual version's `area.f_print_intro_text`, with its trace and returned
memory explicit. Post-UI controller, transition, pending-operation and
Mario reads, and the concrete scheduler memory/layout/separation premises,
refer to that returned memory. The theorem does not assume the Start
branch runs or that an entire frame preserves the desired result. It
checks all the branch decisions itself, for arbitrary button masks whose
END_DEMO bit is clear and whose Start bit is set.

The intro-text functions themselves are **not identical ASTs**: the
pipeline deliberately gives their three private string literals distinct
US and JP atoms. Coq checks that inequality, while separately checking the
public timer-load/guard/idle-subtree identity. The theorem selects the
actual US or JP intro callee and scheduling callee with the version
parameter; it does not identify the private text atoms or substitute the
US UI body into a JP environment.

The result also carries the scheduler's exact memory frame relative to
the post-UI memory: initial valid accesses are preserved, and every load
outside the eleven named scheduling/transition/RGB blocks is unchanged.
It deliberately supplies no such frame for the assumed intro-text
execution; the starting and returned UI memories are separate.

The remaining work is to establish the actual UI execution/postconditions
and reachable memory premises, and preserve the scheduled condition
through `warp_area`, instant-warp, object, HUD, camera, painting and delayed
warp processing before the pause decision. The zero-destination
`warp_area` call, [complete null-table/null-floor instant-warp call](instant-warp-execution.md),
[actual normal HUD timer block](normal-timer-execution.md),
and first pending-dispatch decrement already have local
execution theorems. Their initialization and connection to all intervening
calls are separate obligations. No whole-frame oracle is introduced.

The staged module passed the existing Ubuntu WSL targeted audit build
with Coq 8.16.1 and CompCert 3.15 in `sm64-item-proof`, retaining the
established memory limit. The promoted module's capstone checks and
assumptions are recorded by the main report.
