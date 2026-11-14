# Selected clone-floor proof audit

The archived audit covers the generated-code local preservation boundary,
not reachable cloning, collision scheduling or high-floor delivery.
See `../../docs/notes/ink-box-floor-proof.md` for the exact statements and
remaining obligations. `receipt.json` pins the checked source bytes after
CRLF-to-LF normalization; raw audit files have separate byte hashes.

Run within the SSL project in Ubuntu WSL, using the existing pipeline:

```sh
bash pipeline/discipline-check.sh --build-timeout 600 --assumption-timeout 240 \
  LessThanOneAPress.Proofs.MainTheorem current_ink_box_floor_boundary \
  LessThanOneAPress.Proofs.InkBoxFloor ibf_clone_floor_boundary_checked \
  LessThanOneAPress.Proofs.InkBoxFloorFrame ibff_clone_floor_frame_boundary_checked \
  LessThanOneAPress.Proofs.MainTheorem current_ink_backward_execution_boundary
```

The preserved logs report the project's allowed CompCert/Coq foundations;
the result is not advertised as axiom-free. No new axiom or `Admitted` was
introduced. Audit success is mechanical hygiene, not evidence that the
explicit premises or remaining gameplay reachability conditions hold.
