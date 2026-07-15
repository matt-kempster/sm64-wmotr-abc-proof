#!/usr/bin/env bash
set -euo pipefail

SM64="${SM64_SOURCE:-../../../reference-sm64-decomp}"
AUDIT_TMP="$(mktemp --tmpdir=. eyerok-auditXXXXXX.txt)"
ROUTE_AUDIT_TMP="$(mktemp --tmpdir=. eyerok-route-auditXXXXXX.txt)"
trap 'rm -f "$AUDIT_TMP" "$ROUTE_AUDIT_TMP"' EXIT

PYTHONDONTWRITEBYTECODE=1 python3 pipeline/audit_eyerok_source.py \
  "$SM64" > "$AUDIT_TMP"
diff -u generated/source_audit.txt "$AUDIT_TMP"

PYTHONDONTWRITEBYTECODE=1 python3 pipeline/audit_route_source.py \
  "$SM64" > "$ROUTE_AUDIT_TMP"
diff -u generated/route_audit.txt "$ROUTE_AUDIT_TMP"

make proofs

if grep -RInE '\b(Admitted|Axiom|admit|sorry)\b' proofs; then
  echo "proof hole or project-added axiom found" >&2
  exit 1
fi

bash pipeline/assumptions.sh \
  SSLEyerok.Proofs.EyerokManipulation \
  eyerok_no_unbounded_rise_certificate
bash pipeline/assumptions.sh \
  SSLEyerok.Proofs.SchedulerInvariant \
  reachable_scheduler_excludes_runaway_seed
bash pipeline/assumptions.sh \
  SSLEyerok.Proofs.VerticalBound \
  no_safe_vertical_run_rises_unboundedly
bash pipeline/assumptions.sh \
  SSLEyerok.Proofs.GlobalBoundary \
  authentic_no_unbounded_rise_from_refinement
bash pipeline/assumptions.sh \
  SSLEyerok.Proofs.RouteCertificate \
  eyerok_area2_route_certificate
bash pipeline/assumptions.sh \
  SSLEyerok.Proofs.AuthenticKernel \
  no_player_policy_reaches_gravity_zero_runaway_seed
bash pipeline/assumptions.sh \
  SSLEyerok.Proofs.FirstHandBarrier \
  first_hand_barrier_certificate_holds
bash pipeline/assumptions.sh \
  SSLEyerok.Proofs.TwoHandBarrier \
  two_hand_barrier_certificate_holds
bash pipeline/assumptions.sh \
  SSLEyerok.Proofs.MarioHandContact \
  mario_hand_contact_certificate_holds
bash pipeline/assumptions.sh \
  SSLEyerok.Proofs.LowerArea2Entry \
  lower_area2_entry_certificate_holds
bash pipeline/assumptions.sh \
  SSLEyerok.Proofs.AuthenticReachability \
  audited_coupled_reachability_certificate_holds
bash pipeline/assumptions.sh \
  SSLEyerok.Proofs.Binary32Boundary \
  finite_binary32_stream_not_unbounded
bash pipeline/assumptions.sh \
  SSLEyerok.Proofs.Binary32Boundary \
  binary32_boundary_certificate_holds

echo "Eyerok manipulation checks: OK"
