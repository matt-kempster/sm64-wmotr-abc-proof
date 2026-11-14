# Buddy acquisition guard: Coq validation

Run from `SSL-Coq/less-than-one-a-press` in Ubuntu WSL. The environment is
`sm64-item-proof`, Coq 8.16.1 / CompCert 3.15, with the established
6,815,744 KiB virtual-memory cap unchanged.

```sh
bash pipeline/build.sh audit-build AUDIT_VO_TARGETS=proofs/InkBuddyAcquisition.vo
bash pipeline/discipline-check.sh --build-timeout 600 --assumption-timeout 240 \
  LessThanOneAPress.Proofs.MainTheorem current_ink_backward_execution_boundary \
  LessThanOneAPress.Proofs.InkRetryQuery irq_retry_connects_display_to_real_floor_call \
  LessThanOneAPress.Proofs.InkVerticalRetryGeometry ivr_vertical_retry_geometry_checked \
  LessThanOneAPress.Proofs.MainTheorem current_ink_buddy_acquisition_boundary
```

Before edits, the same selected audit with the last pair replaced by
`LessThanOneAPress.Proofs.MainTheorem current_ink_buddy_movement_boundary`
passed at `build/audit/20261114-080800-wrqtqs8x`. Its report and summary are
archived as `baseline-report.json` and `baseline-summary.txt`. The baseline
started from proof revision `49807c387f90e29856e2ae34a656f9394137ec19`.

The new module compiled on its first targeted pipeline build. The final
selected audit passed at `build/audit/20261114-081312-j4brwaq_`, including the
MainTheorem rebuild, source inventory, hole/link scans, all four assumption
queries and integration. It found 721 sources; 555/641 proof modules in
MainTheorem's import closure; 86 standalone modules; zero integration
problems. The complete final report, interface index and logs are copied
here without line-ending conversion.

The four assumption counts are 9/7/4/7. The new boundary's seven existing
allowed foundations are classical excluded middle, the two standard real
decision principles, proof irrelevance, dependent functional extensionality,
and CompCert's external-function and inline-assembly semantic parameters.
No new project axiom or admission is introduced.

This audit validates the recorded local generated-code guard. It does not
discharge its live input/read/execution premises or prove a reachable-object
history invariant. Read [the exact proof scope](../../docs/notes/ink-buddy-acquisition-proof.md)
and [the gameplay verdict](../../docs/notes/ink-buddy-acquisition.md).
