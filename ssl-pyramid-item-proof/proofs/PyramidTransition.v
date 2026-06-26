From compcert Require Import AST Memory Values.
From SSLPyramid.Proofs Require Import Spec TraversalModel UnloadSequence.

Record pyramid_transition_certificate
    (before barrier : mem)
    (pool_block warp_dest_block current_area_block : block)
    (snapshot : object_list_snapshot) : Prop := {
  certificate_warp_pending :
    pyramid_warp_pending before warp_dest_block current_area_block;
  certificate_snapshot_well_formed :
    snapshot_well_formed before pool_block snapshot;
  certificate_deactivation_trace :
    valid_deactivation_trace pool_block before
      (unload_targets ssl_outside_area snapshot) barrier
}.

Theorem certified_pyramid_transition_clears_outside :
  forall before barrier pool_block warp_dest_block current_area_block snapshot,
    pyramid_transition_certificate
      before barrier pool_block warp_dest_block current_area_block snapshot ->
    outside_slots_cleared_at_barrier before barrier pool_block.
Proof.
  intros before barrier pool_block warp_dest_block current_area_block
    snapshot Hcertificate.
  destruct Hcertificate as [_ Hsnapshot Htrace].
  eapply valid_traversal_trace_clears_outside; eauto.
Qed.

Theorem certified_pyramid_transition_forbids_continuous_item_transfer :
  forall before barrier after
         pool_block warp_dest_block current_area_block snapshot,
    pyramid_transition_certificate
      before barrier pool_block warp_dest_block current_area_block snapshot ->
    ~ continuous_item_transfer before barrier after pool_block.
Proof.
  intros before barrier after pool_block warp_dest_block current_area_block
    snapshot Hcertificate.
  apply cleared_barrier_forbids_continuous_transfer.
  eapply certified_pyramid_transition_clears_outside.
  exact Hcertificate.
Qed.
