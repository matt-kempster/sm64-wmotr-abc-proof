#!/usr/bin/env bash
set -euo pipefail

make generated
make proofs

if grep -RInE '\b(Admitted|Axiom|admit|sorry)\b' proofs; then
  echo "proof hole or added axiom found" >&2
  exit 1
fi

bash pipeline/source-census.sh
bash pipeline/target-surface-census.sh
bash pipeline/assumptions.sh
bash pipeline/assumptions.sh \
  DemoWarp.Proofs.ReachabilityBoundary \
  separated_demo_pointer_cannot_change_mario_y
bash pipeline/assumptions.sh \
  DemoWarp.Proofs.NormalInitialization \
  normal_initialization_forbids_demo_pointer_mario_y_alias
bash pipeline/assumptions.sh \
  DemoWarp.Proofs.GameplayInputBoundary \
  generated_controller_boundary_and_normal_initialization
bash pipeline/assumptions.sh \
  DemoWarp.Proofs.TargetUseCensus \
  generated_target_use_surface_certificate
bash pipeline/assumptions.sh \
  DemoWarp.Proofs.ControllerInputSurface \
  generated_controller_input_surface_certificate
bash pipeline/assumptions.sh \
  DemoWarp.Proofs.HardwareContracts \
  normal_n64_hardware_frame_certificate
bash pipeline/assumptions.sh \
  DemoWarp.Proofs.PointerProvenanceKernel \
  generated_pointer_provenance_kernel_certificate
bash pipeline/assumptions.sh \
  DemoWarp.Proofs.TargetCapabilitySet \
  generated_target_capability_set_certificate
bash pipeline/assumptions.sh \
  DemoWarp.Proofs.TargetSymbolicLinking \
  linked_target_calls_resolve_to_internal_bodies
bash pipeline/assumptions.sh \
  DemoWarp.Proofs.TargetSymbolicLinking \
  linked_target_composite_layouts
bash pipeline/assumptions.sh \
  DemoWarp.Proofs.AuthorizedWriterExec \
  generated_writer_rhs_execution_preserves_demo_block
bash pipeline/assumptions.sh \
  DemoWarp.Proofs.AuthorizedWriterExec \
  generated_writer_statement_execution_preserves_demo_block
bash pipeline/assumptions.sh \
  DemoWarp.Proofs.AuthorizedWriterExec \
  exec_run_increment_source_load_sets_safe_temp
bash pipeline/assumptions.sh \
  DemoWarp.Proofs.AuthorizedWriterExec \
  exec_title_install_source_load_sets_safe_temp
bash pipeline/assumptions.sh \
  DemoWarp.Proofs.AuthorizedWriterExec \
  generated_authorized_update_pairs_preserve_demo_block
