From Coq Require Import List ZArith Lia.
From compcert Require Import AST Events Globalenvs Memory Values.

Import ListNotations.
Local Open Scope Z_scope.

Definition memory_region : Type := block -> Z -> Prop.

Definition region_uses_block (protected : memory_region) (b : block) : Prop :=
  exists ofs, protected b ofs.

Definition value_avoids_region (protected : memory_region) (v : val) : Prop :=
  match v with
  | Vptr b _ => ~ region_uses_block protected b
  | _ => True
  end.

Definition arguments_avoid_region
    (protected : memory_region) (args : list val) : Prop :=
  Forall (value_avoids_region protected) args.

(* Normal N64/libultra locality boundary.  An external operation may mutate
   RDRAM reached by a pointer argument, but it cannot spontaneously target an
   unrelated protected block.  PI DMA into the demo buffer is handled by the
   concrete destination-range relation below, not by this disjoint-argument
   case. *)
Definition normal_n64_external_locality
    (protected : memory_region) (ge : Senv.t) : Prop :=
  forall ef args before trace result after,
    external_call ef ge args before trace result after ->
    arguments_avoid_region protected args ->
    Mem.unchanged_on protected before after.

Definition byte_region (b : block) (lo len : Z) : memory_region :=
  fun found ofs => found = b /\ lo <= ofs < lo + len.

Definition si_controller_dma
    (pif_block : block) (pif_offset : Z)
    (bytes : list memval) (before after : mem) : Prop :=
  length bytes = 64%nat /\
  Mem.storebytes before pif_block pif_offset bytes = Some after.

Definition pi_dma_write
    (destination_block : block) (destination_offset : Z)
    (bytes : list memval) (before after : mem) : Prop :=
  Mem.storebytes before destination_block destination_offset bytes = Some after.

Lemma dma_storebytes_preserves_other_block :
  forall protected before after destination_block destination_offset bytes,
    (forall ofs, ~ protected destination_block ofs) ->
    Mem.storebytes before destination_block destination_offset bytes = Some after ->
    Mem.unchanged_on protected before after.
Proof.
  intros protected before after destination_block destination_offset bytes
    Hseparate Hstore.
  eapply Mem.storebytes_unchanged_on; [exact Hstore |].
  intros i _.
  apply Hseparate.
Qed.

Theorem normal_si_controller_dma_preserves_distinct_region :
  forall protected pif_block pif_offset bytes before after,
    (forall ofs, ~ protected pif_block ofs) ->
    si_controller_dma pif_block pif_offset bytes before after ->
    Mem.unchanged_on protected before after.
Proof.
  intros protected pif_block pif_offset bytes before after Hseparate [_ Hstore].
  eapply dma_storebytes_preserves_other_block; eauto.
Qed.

Theorem normal_pi_dma_preserves_distinct_region :
  forall protected destination_block destination_offset bytes before after,
    (forall ofs, ~ protected destination_block ofs) ->
    pi_dma_write destination_block destination_offset bytes before after ->
    Mem.unchanged_on protected before after.
Proof.
  intros protected destination_block destination_offset bytes before after
    Hseparate Hwrite.
  unfold pi_dma_write in Hwrite.
  eapply dma_storebytes_preserves_other_block; eauto.
Qed.

Theorem normal_pi_dma_preserves_disjoint_range :
  forall watched_block watched_offset watched_length
      destination_offset bytes before after,
    destination_offset + Z.of_nat (length bytes) <= watched_offset \/
    watched_offset + watched_length <= destination_offset ->
    pi_dma_write watched_block destination_offset bytes before after ->
    Mem.unchanged_on
      (byte_region watched_block watched_offset watched_length) before after.
Proof.
  intros watched_block watched_offset watched_length destination_offset bytes
    before after Hdisjoint Hwrite.
  unfold pi_dma_write in Hwrite.
  eapply Mem.storebytes_unchanged_on; [exact Hwrite |].
  intros i Hi [Heq Hwatched].
  subst.
  destruct Hdisjoint; lia.
Qed.

Theorem normal_external_call_preserves_unpassed_region :
  forall protected ge ef args before trace result after,
    normal_n64_external_locality protected ge ->
    external_call ef ge args before trace result after ->
    arguments_avoid_region protected args ->
    Mem.unchanged_on protected before after.
Proof.
  intros protected ge ef args before trace result after
    Hlocal Hcall Hargs.
  exact (Hlocal ef args before trace result after Hcall Hargs).
Qed.

(* The contract is satisfiable: a memory-preserving external world is one
   concrete witness.  This does not assert that the N64 world is identity; SI
   and PI effects above provide the intended non-identity hardware writes. *)
Theorem memory_preserving_externals_satisfy_normal_locality :
  forall protected ge,
    (forall ef args before trace result after,
      external_call ef ge args before trace result after -> after = before) ->
    normal_n64_external_locality protected ge.
Proof.
  intros protected ge Hidentity ef args before trace result after Hcall _.
  rewrite (Hidentity ef args before trace result after Hcall).
  apply Mem.unchanged_on_refl.
Qed.

Definition normal_n64_hardware_frame_claim : Prop :=
  (forall protected pif_block pif_offset bytes before after,
    (forall ofs, ~ protected pif_block ofs) ->
    si_controller_dma pif_block pif_offset bytes before after ->
    Mem.unchanged_on protected before after) /\
  (forall protected destination_block destination_offset bytes before after,
    (forall ofs, ~ protected destination_block ofs) ->
    pi_dma_write destination_block destination_offset bytes before after ->
    Mem.unchanged_on protected before after).

Theorem normal_n64_hardware_frame_certificate :
  normal_n64_hardware_frame_claim.
Proof.
  split.
  - apply normal_si_controller_dma_preserves_distinct_region.
  - apply normal_pi_dma_preserves_distinct_region.
Qed.
