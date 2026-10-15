# Executing the pause decision and its dialog query

The full gameplay no-desync claim remains **OPEN**. A normally reachable
demo frame has not yet been proved to satisfy all the invariants needed
below, and these theorems do not exhibit a reachable counterexample.

`proofs/DemoPauseExclusion.v` now proves
`generated_demo_complete_pause_exclusion_us_jp`: complete CompCert
`eval_funcall` executions of the actual US and JP `f_pressed_pause` return
false and preserve the entire memory when the real transition-active byte
is true or the real delayed-warp operation is nonzero. The transition byte
is explicitly required to hold its boolean runtime value 0 or 1. The
dialog value and Mario action are arbitrary readable values; the theorem
does not assume a dialog open, Mario intangible, Start released, or any
controller-button value.

The proof executes the actual `f_get_dialog_id` from the newly generated
`ingame_menu` unit. It proves function entry, the real signed global load,
the temporary assignment, signed return conversion and cleanup. It does
not assume an already completed dialog-query call or external preservation
property. The signed-load normalization used for that return is obtained
from CompCert's `Mem.load_cast`.

The remaining `pressed_pause` body loads Mario's real action field at
offset 12, calculates the actual dialog/intangible flags, and follows the
generated short-circuit tests. Both values of those two calculated flags
are covered. An active transition rejects the decision before the delayed
operation is needed; otherwise a nonzero delayed operation rejects it
before reading the controller pointer or buttons. The entire function
then returns false. No memory stores occur on these executions.

The explicit premises resolve the actual query/global symbols and query
function, require the real composite field offsets and readable
dialog/Mario/action/transition/operation cells, and state the named
transition-or-pending-operation condition. They do not say that pausing is
unreachable or that gameplay cannot desync. They are obligations that a
normal demo-frame proof can instantiate.

The source ordering that could establish this condition still needs
composition. At the start of `play_mode_normal`, an active demo's Start
press schedules `WARP_OP_DEMO_NEXT` when the transition is inactive and no
operation is pending. The actual `level_trigger_warp` branch also calls
`play_transition`. Executing that branch and preserving its result through
the intervening frame callees is still required; reading this ordering in
the source does not establish it for a reachable frame. The later
`pressed_pause` call is now a proved consumer of the resulting condition.

The zero-`sWarpDest.type` invariant discussed in
[the gameplay-boundary note](gameplay-boundary.md) is independent of this
pause result and remains necessary for the negative demo control code to
win over an ordinary level destination during transition completion.

Validation uses Ubuntu WSL, the `sm64-item-proof` switch, Coq 8.16.1 and
CompCert 3.15 through
`bash pipeline/build.sh audit-build AUDIT_VO_TARGETS=proofs/DemoPauseExclusion.vo`.
The targeted assumptions check reports only the standard CompCert/classical
axioms. Project-wide checks and the final capstone wiring are recorded in
the main report.
