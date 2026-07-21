From Coq Require Import List ZArith.
Import ListNotations.
From compcert Require Import AST Integers Memory Values.
From SSLPyramid.Proofs Require Import Spec UnloadStore.

Inductive deactivation_sequence (pool_block : block)
    : mem -> list Z -> mem -> Prop :=
| deactivate_none :
    forall memory,
      deactivation_sequence pool_block memory [] memory
| deactivate_one_more :
    forall memory memory1 memory2 slot rest,
      Mem.store Mint16signed memory pool_block
        (object_field_address slot object_active_flags_offset)
        (Vint Int.zero) = Some memory1 ->
      deactivation_sequence pool_block memory1 rest memory2 ->
      deactivation_sequence pool_block memory (slot :: rest) memory2.

Theorem deactivation_sequence_preserves_other_slot :
  forall pool_block before targets after kept_slot,
    deactivation_sequence pool_block before targets after ->
    ~ In kept_slot targets ->
    slot_deactivated before pool_block kept_slot ->
    slot_deactivated after pool_block kept_slot.
Proof.
  intros pool_block before targets after kept_slot Hsequence.
  induction Hsequence.
  - intros _ Hdeactivated.
    exact Hdeactivated.
  - intros Hnotin Hdeactivated.
    apply IHHsequence.
    + intros Hin.
      apply Hnotin.
      right.
      exact Hin.
    + eapply store_other_slot_preserves_deactivated.
      * intros Hequal.
        apply Hnotin.
        left.
        symmetry.
        exact Hequal.
      * exact H.
      * exact Hdeactivated.
Qed.

Theorem deactivation_sequence_clears_members :
  forall pool_block before targets after,
    deactivation_sequence pool_block before targets after ->
    NoDup targets ->
    forall target_slot,
      In target_slot targets ->
      slot_deactivated after pool_block target_slot.
Proof.
  intros pool_block before targets after Hsequence.
  induction Hsequence.
  - intros _ target_slot Hin.
    inversion Hin.
  - intros Hnodup target_slot Hin.
    inversion Hnodup as [| head tail Hhead_notin Htail_nodup].
    simpl in Hin.
    destruct Hin as [Hequal | Hin].
    + subst target_slot.
      eapply deactivation_sequence_preserves_other_slot.
      * exact Hsequence.
      * exact Hhead_notin.
      * eapply store_zero_deactivates_slot.
        exact H.
    + apply IHHsequence.
      * exact Htail_nodup.
      * exact Hin.
Qed.

Theorem covered_deactivation_sequence_clears_outside :
  forall pool_block before targets barrier,
    deactivation_sequence pool_block before targets barrier ->
    NoDup targets ->
    (forall slot,
      outside_live_slot before pool_block slot ->
      In slot targets) ->
    outside_slots_cleared_at_barrier before barrier pool_block.
Proof.
  intros pool_block before targets barrier
    Hsequence Hnodup Hcovers slot Houtside.
  eapply deactivation_sequence_clears_members.
  - exact Hsequence.
  - exact Hnodup.
  - apply Hcovers.
    exact Houtside.
Qed.

Theorem covered_deactivation_sequence_forbids_transfer :
  forall pool_block before targets barrier after,
    deactivation_sequence pool_block before targets barrier ->
    NoDup targets ->
    (forall slot,
      outside_live_slot before pool_block slot ->
      In slot targets) ->
    ~ continuous_item_transfer before barrier after pool_block.
Proof.
  intros pool_block before targets barrier after
    Hsequence Hnodup Hcovers.
  apply cleared_barrier_forbids_continuous_transfer.
  eapply covered_deactivation_sequence_clears_outside; eauto.
Qed.

Definition deactivation_step
    (pool_block : block) (slot : Z) (before after : mem) : Prop :=
  slot_deactivated after pool_block slot /\
  forall kept_slot,
    kept_slot <> slot ->
    slot_deactivated before pool_block kept_slot ->
    slot_deactivated after pool_block kept_slot.

Definition valid_deactivation_step
    (pool_block : block) (slot : Z) (before after : mem) : Prop :=
  slot_deactivated after pool_block slot /\
  forall kept_slot,
    valid_object_slot kept_slot ->
    kept_slot <> slot ->
    slot_deactivated before pool_block kept_slot ->
    slot_deactivated after pool_block kept_slot.

Theorem deactivation_step_is_valid_deactivation_step :
  forall pool_block slot before after,
    deactivation_step pool_block slot before after ->
    valid_deactivation_step pool_block slot before after.
Proof.
  intros pool_block slot before after (Hslot & Hpreserves).
  split; [exact Hslot |].
  intros kept_slot _ Hdifferent Hdeactivated.
  eapply Hpreserves; eauto.
Qed.

Inductive deactivation_trace (pool_block : block)
    : mem -> list Z -> mem -> Prop :=
| trace_none :
    forall memory,
      deactivation_trace pool_block memory [] memory
| trace_one_more :
    forall memory memory1 memory2 slot rest,
      deactivation_step pool_block slot memory memory1 ->
      deactivation_trace pool_block memory1 rest memory2 ->
      deactivation_trace pool_block memory (slot :: rest) memory2.

Inductive valid_deactivation_trace (pool_block : block)
    : mem -> list Z -> mem -> Prop :=
| valid_trace_none :
    forall memory,
      valid_deactivation_trace pool_block memory [] memory
| valid_trace_one_more :
    forall memory memory1 memory2 slot rest,
      valid_object_slot slot ->
      valid_deactivation_step pool_block slot memory memory1 ->
      valid_deactivation_trace pool_block memory1 rest memory2 ->
      valid_deactivation_trace pool_block memory (slot :: rest) memory2.

Theorem deactivation_trace_is_valid_deactivation_trace :
  forall pool_block before targets after,
    deactivation_trace pool_block before targets after ->
    Forall valid_object_slot targets ->
    valid_deactivation_trace pool_block before targets after.
Proof.
  intros pool_block before targets after Htrace Hvalid_targets.
  induction Htrace as
      [memory
      | memory memory1 memory2 slot rest Hstep Htrace IHHtrace].
  - constructor.
  - inversion Hvalid_targets as
      [| head tail Hvalid_slot Hvalid_rest]; subst.
    econstructor.
    + exact Hvalid_slot.
    + apply deactivation_step_is_valid_deactivation_step.
      exact Hstep.
    + apply IHHtrace.
      exact Hvalid_rest.
Qed.

Theorem raw_zero_store_is_deactivation_step :
  forall memory memory' pool_block slot,
    Mem.store Mint16signed memory pool_block
      (object_field_address slot object_active_flags_offset)
      (Vint Int.zero) = Some memory' ->
    deactivation_step pool_block slot memory memory'.
Proof.
  intros memory memory' pool_block slot Hstore.
  split.
  - eapply store_zero_deactivates_slot.
    exact Hstore.
  - intros kept_slot Hdifferent Hdeactivated.
    eapply store_other_slot_preserves_deactivated.
    + exact Hdifferent.
    + exact Hstore.
    + exact Hdeactivated.
Qed.

Theorem deactivation_trace_preserves_other_slot :
  forall pool_block before targets after kept_slot,
    deactivation_trace pool_block before targets after ->
    ~ In kept_slot targets ->
    slot_deactivated before pool_block kept_slot ->
    slot_deactivated after pool_block kept_slot.
Proof.
  intros pool_block before targets after kept_slot Htrace.
  induction Htrace.
  - intros _ Hdeactivated.
    exact Hdeactivated.
  - intros Hnotin Hdeactivated.
    apply IHHtrace.
    + intros Hin.
      apply Hnotin.
      right.
      exact Hin.
    + destruct H as [_ Hpreserves].
      apply Hpreserves.
      * intros Hequal.
        apply Hnotin.
        left.
        symmetry.
        exact Hequal.
      * exact Hdeactivated.
Qed.

Theorem valid_deactivation_trace_preserves_other_valid_slot :
  forall pool_block before targets after kept_slot,
    valid_deactivation_trace pool_block before targets after ->
    valid_object_slot kept_slot ->
    ~ In kept_slot targets ->
    slot_deactivated before pool_block kept_slot ->
    slot_deactivated after pool_block kept_slot.
Proof.
  intros pool_block before targets after kept_slot Htrace.
  induction Htrace as
      [memory
      | memory memory1 memory2 slot rest Hvalid_slot Hstep Htrace IHHtrace].
  - intros _ _ Hdeactivated.
    exact Hdeactivated.
  - intros Hvalid_kept Hnotin Hdeactivated.
    apply IHHtrace.
    + exact Hvalid_kept.
    + intros Hin.
      apply Hnotin.
      right.
      exact Hin.
    + destruct Hstep as [_ Hpreserves].
      apply Hpreserves.
      * exact Hvalid_kept.
      * intros Hequal.
        apply Hnotin.
        left.
        symmetry.
        exact Hequal.
      * exact Hdeactivated.
Qed.

Theorem deactivation_trace_clears_members :
  forall pool_block before targets after,
    deactivation_trace pool_block before targets after ->
    NoDup targets ->
    forall target_slot,
      In target_slot targets ->
      slot_deactivated after pool_block target_slot.
Proof.
  intros pool_block before targets after Htrace.
  induction Htrace.
  - intros _ target_slot Hin.
    inversion Hin.
  - intros Hnodup target_slot Hin.
    inversion Hnodup as [| head tail Hhead_notin Htail_nodup].
    simpl in Hin.
    destruct Hin as [Hequal | Hin].
    + subst target_slot.
      eapply deactivation_trace_preserves_other_slot.
      * exact Htrace.
      * exact Hhead_notin.
      * exact (proj1 H).
    + apply IHHtrace.
      * exact Htail_nodup.
      * exact Hin.
Qed.

Theorem valid_deactivation_trace_clears_members :
  forall pool_block before targets after,
    valid_deactivation_trace pool_block before targets after ->
    NoDup targets ->
    Forall valid_object_slot targets ->
    forall target_slot,
      In target_slot targets ->
      slot_deactivated after pool_block target_slot.
Proof.
  intros pool_block before targets after Htrace.
  induction Htrace as
      [memory
      | memory memory1 memory2 slot rest Hvalid_slot Hstep Htrace IHHtrace].
  - intros _ _ target_slot Hin.
    inversion Hin.
  - intros Hnodup Hvalid_targets target_slot Hin.
    inversion Hnodup as [| head tail Hhead_notin Htail_nodup]; subst.
    inversion Hvalid_targets as
      [| head' tail' Hvalid_head Hvalid_tail]; subst.
    simpl in Hin.
    destruct Hin as [Hequal | Hin].
    + subst target_slot.
      eapply valid_deactivation_trace_preserves_other_valid_slot.
      * exact Htrace.
      * exact Hvalid_slot.
      * exact Hhead_notin.
      * exact (proj1 Hstep).
    + apply IHHtrace.
      * exact Htail_nodup.
      * exact Hvalid_tail.
      * exact Hin.
Qed.

Theorem covered_deactivation_trace_forbids_transfer :
  forall pool_block before targets barrier after,
    deactivation_trace pool_block before targets barrier ->
    NoDup targets ->
    (forall slot,
      outside_live_slot before pool_block slot ->
      In slot targets) ->
    ~ continuous_item_transfer before barrier after pool_block.
Proof.
  intros pool_block before targets barrier after
    Htrace Hnodup Hcovers.
  apply cleared_barrier_forbids_continuous_transfer.
  intros slot Houtside.
  eapply deactivation_trace_clears_members.
  - exact Htrace.
  - exact Hnodup.
  - apply Hcovers.
    exact Houtside.
Qed.

Theorem covered_valid_deactivation_trace_clears_outside :
  forall pool_block before targets barrier,
    valid_deactivation_trace pool_block before targets barrier ->
    NoDup targets ->
    Forall valid_object_slot targets ->
    (forall slot,
      outside_live_slot before pool_block slot ->
      In slot targets) ->
    outside_slots_cleared_at_barrier before barrier pool_block.
Proof.
  intros pool_block before targets barrier
    Htrace Hnodup Hvalid_targets Hcovers slot Houtside.
  eapply valid_deactivation_trace_clears_members.
  - exact Htrace.
  - exact Hnodup.
  - exact Hvalid_targets.
  - apply Hcovers.
    exact Houtside.
Qed.

Theorem covered_valid_deactivation_trace_forbids_transfer :
  forall pool_block before targets barrier after,
    valid_deactivation_trace pool_block before targets barrier ->
    NoDup targets ->
    Forall valid_object_slot targets ->
    (forall slot,
      outside_live_slot before pool_block slot ->
      In slot targets) ->
    ~ continuous_item_transfer before barrier after pool_block.
Proof.
  intros pool_block before targets barrier after
    Htrace Hnodup Hvalid_targets Hcovers.
  apply cleared_barrier_forbids_continuous_transfer.
  eapply covered_valid_deactivation_trace_clears_outside; eauto.
Qed.
