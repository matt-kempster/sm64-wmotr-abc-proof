(**
  Admission-free facts toward the destination-scoped JP allocation and
  first-apply certificate.

  This file deliberately separates facts computable from the official linked
  Clight program and finite LIFO arithmetic from the still-missing extraction
  of one concrete retail small-step execution.
*)

From Coq Require Import Lia List ZArith.
From compcert Require Import
  AST Clight Ctypes Floats Globalenvs Integers Memory Values.
From LessThanOneAPress.Proofs Require Import
  LinkedClightPrograms NormalizedClightPrograms CleanedClightPrograms
  CompositeOfficialLinkBridge ClightFacts
  JPSlotLifetime JPFirstApply JPLifecycleTrace.

Import ListNotations.
Local Open Scope Z_scope.

(** The object layout used by the destination proof is the layout of the
    actual official cleaned JP link, not merely that of one generated unit. *)
Theorem jp_official_linked_object_size_is_608 :
  Ctypes.sizeof
    (prog_comp_env jp_official_cleaned_slice)
    (Tstruct jp_spawn_object._Object noattr) = 608.
Proof.
  rewrite <- jp_official_cleaned_composite_env_exact.
  vm_compute.
  reflexivity.
Qed.

(** Slot 61 is the slot in the authenticated fixture.  Its pointer is an
    offset in the [gObjectPool] block, not a separately allocated block. *)
Definition jp_authenticated_top_slot : nat := 61.
Definition jp_linked_object_size : Z := 608.
Definition jp_authenticated_top_object_offset : Z :=
  Z.of_nat jp_authenticated_top_slot * jp_linked_object_size.

Theorem jp_authenticated_top_object_offset_is_37088 :
  jp_authenticated_top_object_offset = 37088.
Proof. reflexivity. Qed.

(** These twelve fixture-designated payload witness ranges lie inside the same
    608-byte object.  The pairs are byte offset and access width.  Extracting
    the complete generated [apply_platform_displacement] access set and proving
    equality with this list remains a separate obligation. *)
Definition jp_platform_payload_field_ranges : list (Z * Z) :=
  [(160, 4); (164, 4); (168, 4);
   (172, 4); (176, 4); (180, 4);
   (208, 4); (212, 4); (216, 4);
   (276, 4); (280, 4); (284, 4)].

Definition range_inside_object (range : Z * Z) : Prop :=
  let '(offset, width) := range in
  0 <= offset /\ offset + width <= jp_linked_object_size.

Theorem jp_platform_payload_fields_are_inside_one_object :
  Forall range_inside_object jp_platform_payload_field_ranges.
Proof.
  unfold jp_platform_payload_field_ranges.
  repeat constructor; cbv [range_inside_object jp_linked_object_size]; lia.
Qed.

Theorem jp_authenticated_top_payload_absolute_range :
  jp_authenticated_top_object_offset + 160 = 37248 /\
  jp_authenticated_top_object_offset + 288 = 37376 /\
  jp_authenticated_top_object_offset + 288 <=
    jp_authenticated_top_object_offset + jp_linked_object_size.
Proof.
  cbv [jp_authenticated_top_object_offset jp_authenticated_top_slot
    jp_linked_object_size].
  repeat split; lia.
Qed.

(** Checking the complete cleaned declaration set is cheaper and more robust
    than reducing the whole linked AST.  The cleaner has discarded the weak
    incomplete-array declaration, so every retained definition of the
    object-pool atom must be a writable, non-volatile 145920-byte tentative
    global. *)
Definition jp_object_pool_global_shape
    (definition : globdef Clight.fundef type) : bool :=
  match definition with
  | Gvar variable =>
      match gvar_init variable with
      | [Init_space bytes] =>
          Z.eqb bytes 145920 &&
          negb (gvar_readonly variable) &&
          negb (gvar_volatile variable)
      | _ => false
      end
  | _ => false
  end.

Definition jp_object_pool_source_entry_ok
    (entry : ident * globdef Clight.fundef type) : bool :=
  if Pos.eqb (fst entry) JPSLObjects._gObjectPool
  then jp_object_pool_global_shape (snd entry)
  else true.

Definition jp_is_object_pool_source_entry
    (entry : ident * globdef Clight.fundef type) : bool :=
  Pos.eqb (fst entry) JPSLObjects._gObjectPool.

Theorem jp_cleaned_object_pool_definition_count_is_one :
  length
    (filter jp_is_object_pool_source_entry
      (unit_global_definitions jp_cleaned_units)) = 1%nat.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_cleaned_object_pool_declarations_checked :
  forallb jp_object_pool_source_entry_ok
    (unit_global_definitions jp_cleaned_units) = true.
Proof. vm_compute. reflexivity. Qed.

Definition jp_authenticated_top_pointer (pool_block : block) : val :=
  Vptr pool_block (Ptrofs.repr jp_authenticated_top_object_offset).

Theorem jp_authenticated_top_pointer_is_pool_block_plus_37088 :
  forall pool_block,
    jp_authenticated_top_pointer pool_block =
      Vptr pool_block (Ptrofs.repr 37088).
Proof. reflexivity. Qed.

(** The remaining concrete-memory step must establish the official linked
    symbol/variable lookup before [Genv.init_mem_characterization] can turn
    the checked 145920-byte declaration into writable range permissions. *)
Definition JPLinkedObjectPoolInitialMemoryObligation : Prop :=
  exists memory pool_block pool_variable,
    Genv.init_mem jp_official_cleaned_slice = Some memory /\
    Genv.find_symbol (Clight.globalenv jp_official_cleaned_slice)
      JPSLObjects._gObjectPool = Some pool_block /\
    Genv.find_var_info (Clight.globalenv jp_official_cleaned_slice)
      pool_block = Some pool_variable /\
    gvar_init pool_variable = [Init_space 145920] /\
    Mem.range_perm memory pool_block 37088 37696 Cur Writable.

(** The authenticated no-cap destination consumes 84 free-list heads.  A top
    pushed before 131 teardown slots is therefore not allocated or zeroed:
    it remains exactly 47 positions into the surviving suffix. *)
Theorem jp_authenticated_top_is_not_a_destination_allocation :
  forall (Slot : Type) (tail bulk : list Slot) (top : Slot),
    NoDup (free_list_after_early_release tail bulk top) ->
    length bulk = 131%nat ->
    (forall depth, (depth < 84)%nat ->
      nth_error (free_list_after_early_release tail bulk top) depth <>
        Some top) /\
    nth_error
      (skipn 84 (free_list_after_early_release tail bulk top)) 47 =
      Some top.
Proof.
  intros Slot tail bulk top Hnodup Hbulk.
  split.
  - intros depth Hdepth.
    eapply jp_preapply_allocations_do_not_reuse_watched_under_nodup;
      [exact Hnodup |].
    lia.
  - apply jp_top_survives_true_first_apply_allocations_at_depth_47.
    exact Hbulk.
Qed.

(** Thus allocator clearing cannot explain the fixture payload at the true
    first apply when the linked execution realizes this exact free-list
    chronology.  This is a finite alias fact: the premise [writes_only_slot]
    is the concrete memory-frame condition still to extract from Clight. *)
Theorem writes_to_first_84_allocations_preserve_watched_slot :
  forall (Slot Cell : Type) (tail bulk : list Slot) (top : Slot)
      (before after : Slot -> Cell),
    NoDup (free_list_after_early_release tail bulk top) ->
    length bulk = 131%nat ->
    (forall slot,
      ~ In slot
          (firstn 84 (free_list_after_early_release tail bulk top)) ->
      after slot = before slot) ->
    after top = before top.
Proof.
  intros Slot Cell tail bulk top before after Hnodup Hbulk Hframe.
  apply Hframe.
  intro Hin.
  apply In_nth_error in Hin.
  destruct Hin as [depth Hlookup].
  assert (Hdepth : (depth < 84)%nat).
  {
    assert
      (Hwithin :
        (depth <
          length
            (firstn 84
              (free_list_after_early_release tail bulk top)))%nat).
    {
      apply nth_error_Some.
      rewrite Hlookup. discriminate.
    }
    rewrite firstn_length in Hwithin. lia.
  }
  pose proof
    (jp_authenticated_top_is_not_a_destination_allocation
      Slot tail bulk top Hnodup Hbulk) as [Hnot _].
  apply (Hnot depth Hdepth).
  rewrite <- (nth_error_firstn_before
    Slot (free_list_after_early_release tail bulk top) 84 depth Hdepth).
  exact Hlookup.
Qed.
