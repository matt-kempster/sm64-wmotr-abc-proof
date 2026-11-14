# Buddy movement proof validation

Run from `SSL-Coq/less-than-one-a-press` in Ubuntu WSL. Toolchain:
`sm64-item-proof`, Coq 8.16.1, CompCert 3.15. The pipeline retains its existing
6,815,744 KiB virtual-memory cap.

```sh
bash pipeline/build.sh audit-build AUDIT_VO_TARGETS=proofs/InkBuddyMovement.vo
bash pipeline/discipline-check.sh --build-timeout 600 --assumption-timeout 240 \
  LessThanOneAPress.Proofs.MainTheorem current_ink_backward_execution_boundary \
  LessThanOneAPress.Proofs.InkRetryQuery irq_retry_connects_display_to_real_floor_call \
  LessThanOneAPress.Proofs.InkVerticalRetryGeometry ivr_vertical_retry_geometry_checked \
  LessThanOneAPress.Proofs.MainTheorem current_ink_buddy_movement_boundary
```

The baseline selected audit passed before proof edits at
`build/audit/20261114-070718-xqjptrll`. The final audit at
`build/audit/20261114-074322-qt2hydth` passed, with its full report, interface
index, build/hygiene logs and four assumption outputs copied here. It found
720 sources, a 554/640 Main import closure and zero integration problems.
The selected assumption counts were 9/7/4/7; the final count is the new Buddy
boundary. Initial development builds found tactic/name/import issues; slow
generic temporary-map rewriting was replaced with explicit lookup. One
import attempt exhausted memory while interrupted WSL wrappers briefly left
earlier compilers running; all stale compilers were verified gone before the
successful sole-compiler build and final audit. No new axiom or admission was
introduced and no memory cap was raised.

See [the proof scope](../../docs/notes/ink-buddy-movement-proof.md) for what the
statements establish and the remaining controller-reachability obligation.
