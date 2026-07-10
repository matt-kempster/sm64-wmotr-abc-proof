From Coq Require Import List ZArith.
Import ListNotations.
From compcert Require Import AST Memory Values.
From SSLPyramid.Proofs Require Import Spec UnloadObjectSemantics
  UnloadSequence.

Local Open Scope Z_scope.

Definition object_list_count : nat := 13.

Record object_list_snapshot := {
  snapshot_lists : list (list Z);
  snapshot_area : Z -> Z
}.

Definition snapshot_slots (snapshot : object_list_snapshot) : list Z :=
  concat (snapshot_lists snapshot).

Definition unload_targets
    (area : Z) (snapshot : object_list_snapshot) : list Z :=
  filter
    (fun slot => Z.eqb (snapshot_area snapshot slot) area)
    (snapshot_slots snapshot).

Definition snapshot_well_formed
    (before : mem) (pool_block : block)
    (snapshot : object_list_snapshot) : Prop :=
  length (snapshot_lists snapshot) = object_list_count /\
  NoDup (snapshot_slots snapshot) /\
  (forall slot,
    In slot (snapshot_slots snapshot) ->
    valid_object_slot slot) /\
  (forall slot,
    valid_object_slot slot ->
    slot_active before pool_block slot ->
    In slot (snapshot_slots snapshot)) /\
  (forall slot area,
    valid_object_slot slot ->
    slot_belongs_to_area before pool_block slot area <->
    snapshot_area snapshot slot = area).

Record generated_object_list_traversal_certificate
    (before barrier : mem) (pool_block : block) (area : Z)
    (snapshot : object_list_snapshot) : Prop := {
  generated_traversal_snapshot_well_formed :
    snapshot_well_formed before pool_block snapshot;
  generated_traversal_unload_trace :
    generated_unload_execution_trace pool_block before
      (unload_targets area snapshot) barrier
}.

Theorem generated_object_list_traversal_derives_snapshot :
  forall before barrier pool_block area snapshot,
    generated_object_list_traversal_certificate
      before barrier pool_block area snapshot ->
    snapshot_well_formed before pool_block snapshot.
Proof.
  intros before barrier pool_block area snapshot Hcertificate.
  destruct Hcertificate as [Hsnapshot _].
  exact Hsnapshot.
Qed.

Theorem unload_targets_are_nodup :
  forall area snapshot,
    NoDup (snapshot_slots snapshot) ->
    NoDup (unload_targets area snapshot).
Proof.
  intros area snapshot Hnodup.
  unfold unload_targets.
  apply NoDup_filter.
  exact Hnodup.
Qed.

Theorem unload_targets_are_valid :
  forall before pool_block area snapshot,
    snapshot_well_formed before pool_block snapshot ->
    Forall valid_object_slot (unload_targets area snapshot).
Proof.
  intros before pool_block area snapshot Hsnapshot.
  destruct Hsnapshot as (_ & _ & Hvalid_slots & _ & _).
  unfold unload_targets.
  apply Forall_forall.
  intros slot Hin.
  apply filter_In in Hin.
  destruct Hin as (Hin_slots & _).
  apply Hvalid_slots.
  exact Hin_slots.
Qed.

Theorem outside_live_slots_are_unload_targets :
  forall before pool_block snapshot slot,
    snapshot_well_formed before pool_block snapshot ->
    outside_live_slot before pool_block slot ->
    In slot (unload_targets ssl_outside_area snapshot).
Proof.
  intros before pool_block snapshot slot Hsnapshot Houtside.
  destruct Hsnapshot as (_ & _ & _ & Hlisted & Harea).
  destruct Houtside as (Hvalid & Hactive & Hbelongs).
  unfold unload_targets.
  apply filter_In.
  split.
  - apply Hlisted; assumption.
  - apply Z.eqb_eq.
    apply (proj1 (Harea slot ssl_outside_area Hvalid)).
    exact Hbelongs.
Qed.

Theorem generated_object_list_traversal_lists_all_outside_live_slots :
  forall before barrier pool_block snapshot slot,
    generated_object_list_traversal_certificate
      before barrier pool_block ssl_outside_area snapshot ->
    outside_live_slot before pool_block slot ->
    In slot (unload_targets ssl_outside_area snapshot).
Proof.
  intros before barrier pool_block snapshot slot Hcertificate Houtside.
  eapply outside_live_slots_are_unload_targets.
  - eapply generated_object_list_traversal_derives_snapshot.
    exact Hcertificate.
  - exact Houtside.
Qed.

Theorem generated_object_list_traversal_executes_and_deactivates_listed_slot :
  unload_object_tail_empty_env_preserves_valid_pool_slot_active_flags ->
  forall before barrier pool_block area snapshot slot,
    generated_object_list_traversal_certificate
      before barrier pool_block area snapshot ->
    In slot (unload_targets area snapshot) ->
    generated_unload_object_execution_for_slot pool_block slot /\
    slot_deactivated barrier pool_block slot.
Proof.
  intros Htail_frame before barrier pool_block area snapshot slot
    Hcertificate Hin.
  destruct Hcertificate as [Hsnapshot Htrace].
  eapply
    generated_unload_execution_trace_executes_and_deactivates_member_from_empty_env_valid_pool_slot_tail_frame.
  - exact Htail_frame.
  - exact Htrace.
  - apply unload_targets_are_nodup.
    destruct Hsnapshot as (_ & Hnodup & _ & _ & _).
    exact Hnodup.
  - eapply unload_targets_are_valid.
    exact Hsnapshot.
  - exact Hin.
Qed.

Theorem generated_object_list_traversal_executes_and_deactivates_outside_live_slot :
  unload_object_tail_empty_env_preserves_valid_pool_slot_active_flags ->
  forall before barrier pool_block snapshot slot,
    generated_object_list_traversal_certificate
      before barrier pool_block ssl_outside_area snapshot ->
    outside_live_slot before pool_block slot ->
    generated_unload_object_execution_for_slot pool_block slot /\
    slot_deactivated barrier pool_block slot.
Proof.
  intros Htail_frame before barrier pool_block snapshot slot
    Hcertificate Houtside.
  eapply generated_object_list_traversal_executes_and_deactivates_listed_slot.
  - exact Htail_frame.
  - exact Hcertificate.
  - eapply generated_object_list_traversal_lists_all_outside_live_slots;
      eauto.
Qed.

Theorem traversal_trace_clears_outside :
  forall before barrier pool_block snapshot,
    snapshot_well_formed before pool_block snapshot ->
    deactivation_trace pool_block before
      (unload_targets ssl_outside_area snapshot) barrier ->
    outside_slots_cleared_at_barrier before barrier pool_block.
Proof.
  intros before barrier pool_block snapshot Hsnapshot Htrace.
  pose proof Hsnapshot as Hsnapshot_full.
  destruct Hsnapshot as (_ & Hnodup & _ & _ & _).
  intros slot Houtside.
  eapply deactivation_trace_clears_members.
  - exact Htrace.
  - apply unload_targets_are_nodup.
    exact Hnodup.
  - eapply outside_live_slots_are_unload_targets.
    + exact Hsnapshot_full.
    + exact Houtside.
Qed.

Theorem traversal_trace_forbids_transfer :
  forall before barrier after pool_block snapshot,
    snapshot_well_formed before pool_block snapshot ->
    deactivation_trace pool_block before
      (unload_targets ssl_outside_area snapshot) barrier ->
    ~ continuous_item_transfer before barrier after pool_block.
Proof.
  intros before barrier after pool_block snapshot Hsnapshot Htrace.
  apply cleared_barrier_forbids_continuous_transfer.
  eapply traversal_trace_clears_outside; eauto.
Qed.

Theorem valid_traversal_trace_clears_outside :
  forall before barrier pool_block snapshot,
    snapshot_well_formed before pool_block snapshot ->
    valid_deactivation_trace pool_block before
      (unload_targets ssl_outside_area snapshot) barrier ->
    outside_slots_cleared_at_barrier before barrier pool_block.
Proof.
  intros before barrier pool_block snapshot Hsnapshot Htrace.
  pose proof Hsnapshot as Hsnapshot_full.
  destruct Hsnapshot as (_ & Hnodup & _ & _ & _).
  intros slot Houtside.
  eapply valid_deactivation_trace_clears_members.
  - exact Htrace.
  - apply unload_targets_are_nodup.
    exact Hnodup.
  - eapply unload_targets_are_valid.
    exact Hsnapshot_full.
  - eapply outside_live_slots_are_unload_targets.
    + exact Hsnapshot_full.
    + exact Houtside.
Qed.

Theorem valid_traversal_trace_forbids_transfer :
  forall before barrier after pool_block snapshot,
    snapshot_well_formed before pool_block snapshot ->
    valid_deactivation_trace pool_block before
      (unload_targets ssl_outside_area snapshot) barrier ->
    ~ continuous_item_transfer before barrier after pool_block.
Proof.
  intros before barrier after pool_block snapshot Hsnapshot Htrace.
  apply cleared_barrier_forbids_continuous_transfer.
  eapply valid_traversal_trace_clears_outside; eauto.
Qed.

Theorem generated_unload_targets_trace_clears_outside :
  unload_object_tail_empty_env_preserves_valid_pool_slot_active_flags ->
  forall before barrier pool_block snapshot,
    snapshot_well_formed before pool_block snapshot ->
    generated_unload_execution_trace pool_block before
      (unload_targets ssl_outside_area snapshot) barrier ->
    outside_slots_cleared_at_barrier before barrier pool_block.
Proof.
  intros Htail_frame before barrier pool_block snapshot Hsnapshot Htrace.
  eapply valid_traversal_trace_clears_outside.
  - exact Hsnapshot.
  - eapply
      generated_unload_execution_trace_is_valid_deactivation_trace_from_empty_env_valid_pool_slot_tail_frame;
      eauto.
Qed.

Theorem generated_unload_targets_trace_forbids_transfer :
  unload_object_tail_empty_env_preserves_valid_pool_slot_active_flags ->
  forall before barrier after pool_block snapshot,
    snapshot_well_formed before pool_block snapshot ->
    generated_unload_execution_trace pool_block before
      (unload_targets ssl_outside_area snapshot) barrier ->
    ~ continuous_item_transfer before barrier after pool_block.
Proof.
  intros Htail_frame before barrier after pool_block snapshot Hsnapshot Htrace.
  apply cleared_barrier_forbids_continuous_transfer.
  eapply generated_unload_targets_trace_clears_outside; eauto.
Qed.
