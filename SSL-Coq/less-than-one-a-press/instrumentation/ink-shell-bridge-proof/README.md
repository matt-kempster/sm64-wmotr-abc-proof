# Generated-Clight shell checkpoint audit

Run inside the SSL project, Ubuntu WSL, using the installed pipeline:

```sh
bash pipeline/discipline-check.sh --build-timeout 600 --assumption-timeout 240 LessThanOneAPress.Proofs.InkShellBridge isb_shell_bridge_boundary_checked LessThanOneAPress.Proofs.MainTheorem current_ink_shell_bridge_boundary LessThanOneAPress.Proofs.MainTheorem current_ink_backward_execution_boundary
```

The final selected audit passed on 14 November 2026: 724 sources, Main compilation,
all hole/link checks, three assumption checks (7/7/9 allowed foundations),
558/644 modules in Main import closure and no integration problems. Toolchain:
sm64-item-proof, Coq8.16.1, CompCert3.15, unchanged 6815744 KiB memory cap.
The baseline audit was build/audit/20261114-141753-ps611hbf, also passed.

The new module constructs a reached quarter tail from precise Float32 guards,
connects actual ground-call return to shell dispatch, and proves the real
knockback action request for stopped result2. Query-prefix execution, whole
loop/action composition, caller reachability, helper effects and high delivery
remain explicit obligations. It is neither a global shell impossibility theorem
nor a complete route. Main consumes the theorem through its named shell boundary.
The detailed statement is docs/notes/ink-shell-bridge-proof.md.

Source and audit hashes are preserved in verification.json. Source files use LF-normalized bytes so Git checkout line endings do not invalidate their identity; archived logs use exact bytes. No new axiom or
Admitted was introduced. A clean assumptions report does not discharge explicit
premises or prove every game's reachable history.
