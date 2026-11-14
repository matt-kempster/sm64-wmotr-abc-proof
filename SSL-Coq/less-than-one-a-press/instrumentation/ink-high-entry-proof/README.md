# Idle OFF_FLOOR guard validation

Proof base: `651c180e594e45c6825f9c4800da11f4afef0773`, branch
`codex/ssl-pyramid-item-proof`. Investigated 14 November 2026.

The new `proofs/InkIdleOffFloorGuard.v` is registered in `_CoqProject` and
consumed by `MainTheorem.current_ink_idle_off_floor_guard_boundary`.
It proves a reached-cut result for the actual US/JP generated idle
cancellation suffix, using the real input-field load and selected
`set_mario_action` call. It does not prove a global no-A route exclusion,
the earlier knockback predecessor, or production of its OFF_FLOOR premise.
The full gameplay and statement boundary is in
[`docs/notes/ink-high-entry-source.md`](../../docs/notes/ink-high-entry-source.md).

The installed pipeline rechecked `sm64-item-proof`, Coq 8.16.1 and
CompCert 3.15. The unchanged default memory limit is 6.5 GiB.
No standalone `coqc` command or full generated-program reduction was used.

From the SSL project directory under Ubuntu WSL:

```sh
bash pipeline/build.sh audit-build AUDIT_VO_TARGETS=proofs/InkIdleOffFloorGuard.vo
bash pipeline/discipline-check.sh --build-timeout 600 --assumption-timeout 240 \
  LessThanOneAPress.Proofs.MainTheorem current_ink_backward_execution_boundary \
  LessThanOneAPress.Proofs.InkRetryQuery irq_retry_connects_display_to_real_floor_call \
  LessThanOneAPress.Proofs.InkVerticalRetryGeometry ivr_vertical_retry_geometry_checked \
  LessThanOneAPress.Proofs.MainTheorem current_ink_mario_entry_guard_boundary \
  LessThanOneAPress.Proofs.MainTheorem current_ink_idle_off_floor_guard_boundary
```

The targeted build and selected audit **passed**. The five assumption checks
report respectively **9, 7, 4, 7 and 7 allowed existing foundations**. Source
inventory has 719 files and no problems. Integration finds 553 of 639 proof
modules in MainTheorem's import closure, 86 standalone-only and no problems.
The summary, JSON report, build/scan logs and all five assumption reports
are preserved beside this README. The selected audit is preserved from
`build/audit/20261114-010909-0dsq52we`; this is a MainTheorem/dependency build,
not an all-module `--full-build`. The earlier baseline audit
`build/audit/20261114-010525-7i8hefck` passed before the new module was added,
checking the existing entry boundary with seven allowed foundations.

Source hashes at the final selected audit:

| Source | SHA-256 |
| --- | --- |
| `proofs/InkIdleOffFloorGuard.v` | `a38e36aa97dd0fa11fd96a687c78fca8fac1eed080f78660d8ee646bd2999a19` |
| `proofs/MainTheorem.v` | `8515abb0a086c0188cfae72770068ec11ecac71e4d01e6be363912e78442f6d8` |
| `_CoqProject` | `48fdbcefadfb09f700e9c333886b245bb2cb095e0da460a22073bdf5675c3f02` |
| `generated/us_mario_actions_stationary.v` | `173c72e2f33aa964eefcd7c96dc03a4ec15e7157731c0c5f211e500fcd5e744c` |
| `generated/jp_mario_actions_stationary.v` | `1e017d6778ced8f92e9519540ab6b05805bf459debadd00337e280249d129ce7` |

Mechanical audit success does not settle the route. The actual improvement
is the local exclusion of later idle walking/sliding/Z guards after a live
OFF_FLOOR test succeeds, rather than an assumed rule about an abstract
action machine. Its real earlier prefix can be attached with all effects
preserved; reaching that prefix and supplying the live flag remain explicit.
