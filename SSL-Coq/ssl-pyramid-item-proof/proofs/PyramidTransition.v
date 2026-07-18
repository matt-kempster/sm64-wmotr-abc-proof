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

(* Game words:
     no outside SSL object-pool item identity enters the Pyramid in a
     gameplay-usable way.

   Coq words:
     every live outside-area object allocation epoch from [before] is inactive
     at the unload barrier, so no such epoch can be continuously active both at
     the barrier and in any later [after] state.  A stale Mario reference during
     the load window is a separate technical phenomenon modeled in
     StalePointerModel/StaleWindowObservation; it is not this predicate unless
     the original allocation epoch remains active through the barrier.
 *)
Definition ssl_pyramid_no_gameplay_usable_outside_item_entry_statement : Prop :=
  forall before barrier after
         pool_block warp_dest_block current_area_block snapshot,
    pyramid_transition_certificate
      before barrier pool_block warp_dest_block current_area_block snapshot ->
    no_outside_pyramid_item_identity_enters_pyramid
      before barrier after pool_block.

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

Theorem certified_pyramid_transition_forbids_item_identity_entry :
  forall before barrier after
         pool_block warp_dest_block current_area_block snapshot,
    pyramid_transition_certificate
      before barrier pool_block warp_dest_block current_area_block snapshot ->
    no_outside_pyramid_item_identity_enters_pyramid
      before barrier after pool_block.
Proof.
  intros before barrier after pool_block warp_dest_block current_area_block
    snapshot Hcertificate.
  apply outside_slots_cleared_forbids_item_identity_entry.
  eapply certified_pyramid_transition_clears_outside.
  exact Hcertificate.
Qed.

Theorem ssl_pyramid_no_gameplay_usable_outside_item_entry :
  ssl_pyramid_no_gameplay_usable_outside_item_entry_statement.
Proof.
  unfold ssl_pyramid_no_gameplay_usable_outside_item_entry_statement.
  intros before barrier after pool_block warp_dest_block current_area_block
    snapshot Hcertificate.
  eapply certified_pyramid_transition_forbids_item_identity_entry.
  exact Hcertificate.
Qed.

Theorem certified_pyramid_transition_forbids_gameplay_usable_item_transfer :
  forall before barrier after
         pool_block warp_dest_block current_area_block snapshot,
    pyramid_transition_certificate
      before barrier pool_block warp_dest_block current_area_block snapshot ->
    ~ gameplay_usable_item_transfer before barrier after pool_block.
Proof.
  intros before barrier after pool_block warp_dest_block current_area_block
    snapshot Hcertificate.
  apply no_outside_item_identity_entry_forbids_gameplay_usable_transfer.
  eapply certified_pyramid_transition_forbids_item_identity_entry.
  exact Hcertificate.
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
