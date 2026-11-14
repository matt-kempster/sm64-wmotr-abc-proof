# Mario entry proof validation receipt

This directory retains the final selected SSL proof audit for
`InkMarioEntryGuards.v`, together with exact source hashes and the targeted
build output. It contains no ROM, controller replay, or gameplay witness.
The result is local generated-Clight execution evidence, subject to the
explicit premises described in
[`ink-mario-entry-proof.md`](../../docs/notes/ink-mario-entry-proof.md).

Run within `SSL-Coq/less-than-one-a-press` in Ubuntu WSL:

```sh
bash pipeline/build.sh audit-build AUDIT_VO_TARGETS=proofs/InkMarioEntryGuards.vo
bash pipeline/discipline-check.sh --build-timeout 600 --assumption-timeout 240 \
  LessThanOneAPress.Proofs.MainTheorem current_ink_backward_execution_boundary \
  LessThanOneAPress.Proofs.InkRetryQuery irq_retry_connects_display_to_real_floor_call \
  LessThanOneAPress.Proofs.InkVerticalRetryGeometry ivr_vertical_retry_geometry_checked \
  LessThanOneAPress.Proofs.MainTheorem current_ink_mario_entry_guard_boundary
```

The pipeline selects `sm64-item-proof`, Coq 8.16.1 and CompCert 3.15 and
retains its default 6.5 GiB memory limit. The final audit builds MainTheorem
and the requested dependencies; it is not an all-module full build.
`audit-summary.txt` and `audit-report.json` preserve the pipeline verdict
and integration inventory. `assumptions-*.log` preserve its complete four
foundation reports. `receipt.json` pins the actual proof/generated source
bytes, original audit directory, and commands.
