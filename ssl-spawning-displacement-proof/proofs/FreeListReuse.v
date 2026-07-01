From Coq Require Import List ZArith Lia.
From SSLSpawning.Proofs Require Import Spec.

Import ListNotations.
Local Open Scope Z_scope.

Definition free_list_slots : Type := list slot.

Definition unload_object_pushes
    (before : free_list_slots) (unloaded : slot)
    (after : free_list_slots) : Prop :=
  after = unloaded :: before.

Definition allocate_object_pops
    (before : free_list_slots) (allocated : slot)
    (after : free_list_slots) : Prop :=
  before = allocated :: after.

Theorem unload_object_pushes_slot_to_front_of_free_list :
  forall before unloaded,
    unload_object_pushes before unloaded (unloaded :: before).
Proof.
  intros before unloaded.
  unfold unload_object_pushes.
  reflexivity.
Qed.

Theorem allocate_object_pops_front_of_free_list :
  forall allocated after,
    allocate_object_pops (allocated :: after) allocated after.
Proof.
  intros allocated after.
  unfold allocate_object_pops.
  reflexivity.
Qed.

Theorem unload_then_allocate_reuses_same_slot :
  forall before after_unload after_alloc unloaded allocated,
    unload_object_pushes before unloaded after_unload ->
    allocate_object_pops after_unload allocated after_alloc ->
    allocated = unloaded.
Proof.
  intros before after_unload after_alloc unloaded allocated Hpush Hpop.
  unfold unload_object_pushes, allocate_object_pops in *.
  subst after_unload.
  inversion Hpop.
  reflexivity.
Qed.

Definition allocation_count_reaches_watched_slot
    (free_list : free_list_slots) (watched : slot)
    (allocation_count : nat) : Prop :=
  exists newer older,
    free_list = newer ++ watched :: older /\
    (length newer < allocation_count)%nat.

Definition nth_allocation_reuses_slot
    (free_list : free_list_slots) (allocation_index : nat)
    (watched : slot) : Prop :=
  nth_error free_list (allocation_index - 1) = Some watched.

Definition free_list_after_unloads
    (initial : free_list_slots) (unloaded_in_order : list slot)
    : free_list_slots :=
  rev unloaded_in_order ++ initial.

Theorem pushed_slot_reached_by_first_allocation :
  forall before after_push watched,
    unload_object_pushes before watched after_push ->
    allocation_count_reaches_watched_slot after_push watched 1%nat.
Proof.
  intros before after_push watched Hpush.
  unfold unload_object_pushes in Hpush.
  subst after_push.
  unfold allocation_count_reaches_watched_slot.
  exists [], before.
  split; simpl; lia || reflexivity.
Qed.

Theorem watched_slot_under_newer_free_slots_needs_enough_allocations :
  forall newer older watched allocation_count,
    (length newer < allocation_count)%nat ->
    allocation_count_reaches_watched_slot
      (newer ++ watched :: older) watched allocation_count.
Proof.
  intros newer older watched allocation_count Hcount.
  unfold allocation_count_reaches_watched_slot.
  exists newer, older.
  split; [reflexivity | exact Hcount].
Qed.

Theorem nth_allocation_exact_from_newer_slots :
  forall newer older watched,
    nth_allocation_reuses_slot
      (newer ++ watched :: older) (S (length newer)) watched.
Proof.
  intros newer older watched.
  unfold nth_allocation_reuses_slot.
  replace (S (length newer) - 1)%nat with (length newer) by lia.
  rewrite nth_error_app2.
  - replace (length newer - length newer)%nat with 0%nat by lia.
    reflexivity.
  - lia.
Qed.

Theorem nth_allocation_exact_implies_reached :
  forall free_list watched allocation_index,
    nth_allocation_reuses_slot free_list allocation_index watched ->
    (0 < allocation_index)%nat ->
    allocation_count_reaches_watched_slot
      free_list watched allocation_index.
Proof.
  intros free_list watched allocation_index Hnth Hpositive.
  unfold nth_allocation_reuses_slot in Hnth.
  apply nth_error_split in Hnth.
  destruct Hnth as (newer & older & Hfree & Hlen).
  unfold allocation_count_reaches_watched_slot.
  exists newer, older.
  split; [exact Hfree |].
  rewrite Hlen.
  lia.
Qed.

Theorem unload_suffix_depth_gives_reuse_allocation_count :
  forall initial prefix suffix watched allocation_count,
    (length suffix < allocation_count)%nat ->
    allocation_count_reaches_watched_slot
      (free_list_after_unloads initial (prefix ++ watched :: suffix))
      watched allocation_count.
Proof.
  intros initial prefix suffix watched allocation_count Hcount.
  unfold allocation_count_reaches_watched_slot, free_list_after_unloads.
  exists (rev suffix), (rev prefix ++ initial).
  split.
  - rewrite rev_app_distr.
    simpl.
    repeat rewrite <- app_assoc.
    reflexivity.
  - rewrite rev_length.
    exact Hcount.
Qed.

Theorem unload_suffix_depth_gives_exact_reuse_allocation :
  forall initial prefix suffix watched,
    nth_allocation_reuses_slot
      (free_list_after_unloads initial (prefix ++ watched :: suffix))
      (S (length suffix)) watched.
Proof.
  intros initial prefix suffix watched.
  unfold free_list_after_unloads.
  rewrite rev_app_distr.
  simpl.
  repeat rewrite <- app_assoc.
  rewrite <- (rev_length suffix).
  apply nth_allocation_exact_from_newer_slots.
Qed.
