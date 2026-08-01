(** Ordinary stock entry into SSL Area 1.

    This module separates three claims which are easy to conflate:

    - checked facts about the generated US/JP Clight syntax and global data;
    - a concrete postcondition over live CompCert memory; and
    - the still-open execution/refinement proposition connecting the former to
      the latter.

    In particular, the stock Area-1 entry uses [bhvSpinAirborneWarp] and action
    0x1924.  The 0x1932 action recorded by [EntryMemory] is the distinct
    no-spin airborne entry used by the two Area-2 pyramid entrances.

    The version split for [gMarioPlatform] is also explicit: US spawning calls
    [clear_mario_platform], while JP spawning retains the global raw pointer.
    Nothing here assumes that the retained JP pointer is null or safe. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import
  AST Clight Ctypes Floats Globalenvs Integers Linking Memory Smallstep Values.
From LessThanOneAPress.Generated Require Import
  us_area us_game_init us_level_script us_level_update us_mario
  us_object_list_processor us_platform_displacement us_spawn_object
  us_ssl_script
  jp_area jp_game_init jp_level_script jp_level_update jp_mario
  jp_object_list_processor jp_platform_displacement jp_spawn_object
  jp_ssl_script.
From LessThanOneAPress.Proofs Require Import
  ASTFacts ClightFacts EntryMemory GameTypes InputSemantics.

Import ListNotations.
Local Open Scope Z_scope.

Module UA := us_area.
Module UGI := us_game_init.
Module ULS := us_level_script.
Module ULU := us_level_update.
Module UM := us_mario.
Module UOL := us_object_list_processor.
Module UPD := us_platform_displacement.
Module USO := us_spawn_object.
Module USS := us_ssl_script.

Module JA := jp_area.
Module JGI := jp_game_init.
Module JLS := jp_level_script.
Module JLU := jp_level_update.
Module JM := jp_mario.
Module JOL := jp_object_list_processor.
Module JPD := jp_platform_displacement.
Module JSO := jp_spawn_object.
Module JSS := jp_ssl_script.

(** * Exact generated source/data receipts *)

Definition area1_spin_entry_action_bits : Z := 6436. (* 0x00001924 *)
Definition area1_spin_entry_spawn_type : Z := 22.   (* 0x16 *)
Definition area1_entry_warp_node : Z := 10.         (* 0x0A *)

(** The first object command in SSL Area 1 is the ordinary level-entry warp:
    node 0x0A, position (653,1038,6566), yaw 90 degrees, and
    [bhvSpinAirborneWarp].  These are packed LevelScript words, not a
    handwritten reconstruction. *)
Definition ssl_area1_spin_entry_object_us : list init_data :=
  [ Init_int32 (Int.repr 605560576);
    Init_int32 (Int.repr 42796046);
    Init_int32 (Int.repr 430309376);
    Init_int32 (Int.repr 5898240);
    Init_int32 (Int.repr 655360);
    Init_addrof USS._bhvSpinAirborneWarp (Ptrofs.repr 0) ].

Definition ssl_area1_spin_entry_object_jp : list init_data :=
  [ Init_int32 (Int.repr 605560576);
    Init_int32 (Int.repr 42796046);
    Init_int32 (Int.repr 430309376);
    Init_int32 (Int.repr 5898240);
    Init_int32 (Int.repr 655360);
    Init_addrof JSS._bhvSpinAirborneWarp (Ptrofs.repr 0) ].

Definition ssl_area1_spin_entry_object_receipt_us : Prop :=
  firstn 6 (skipn 50 (gvar_init USS.v_level_ssl_entry)) =
    ssl_area1_spin_entry_object_us.

Theorem ssl_area1_spin_entry_object_exact_us :
  ssl_area1_spin_entry_object_receipt_us.
Proof. vm_compute. reflexivity. Qed.

Definition ssl_area1_spin_entry_object_receipt_jp : Prop :=
  firstn 6 (skipn 50 (gvar_init JSS.v_level_ssl_entry)) =
    ssl_area1_spin_entry_object_jp.

Theorem ssl_area1_spin_entry_object_exact_jp :
  ssl_area1_spin_entry_object_receipt_jp.
Proof. vm_compute. reflexivity. Qed.

(** The stock fallback [MARIO_POS] command is Area 1, yaw 88 degrees, at
    (653,38,6566).  On an ordinary inter-level warp, [init_mario_after_warp]
    instead refreshes the SpawnInfo from the live node-0x0A warp object. *)
Definition ssl_area1_default_mario_pos_words : list init_data :=
  [ Init_int32 (Int.repr 722206976);
    Init_int32 (Int.repr 5767821);
    Init_int32 (Int.repr 2496934) ].

Definition ssl_area1_default_mario_pos_receipt_us : Prop :=
  firstn 3 (skipn 181 (gvar_init USS.v_level_ssl_entry)) =
    ssl_area1_default_mario_pos_words.

Theorem ssl_area1_default_mario_pos_exact_us :
  ssl_area1_default_mario_pos_receipt_us.
Proof. vm_compute. reflexivity. Qed.

Definition ssl_area1_default_mario_pos_receipt_jp : Prop :=
  firstn 3 (skipn 181 (gvar_init JSS.v_level_ssl_entry)) =
    ssl_area1_default_mario_pos_words.

Theorem ssl_area1_default_mario_pos_exact_jp :
  ssl_area1_default_mario_pos_receipt_jp.
Proof. vm_compute. reflexivity. Qed.

(** Index 11 of the behavior table maps [bhvSpinAirborneWarp] to spawn type
    0x16.  The function body scans exactly these tables.  A linked-memory proof
    must still connect the live object's behavior pointer through
    [virtual_to_segmented] to this table entry. *)
Definition area1_spin_spawn_table_receipt_us : Prop :=
  nth_error (gvar_init UA.v_sWarpBhvSpawnTable) 11 =
    Some (Init_addrof UA._bhvSpinAirborneWarp (Ptrofs.repr 0)) /\
  nth_error (gvar_init UA.v_sSpawnTypeFromWarpBhv) 11 =
    Some (Init_int8 (Int.repr area1_spin_entry_spawn_type)) /\
  statement_mentions_ident_s UA._sWarpBhvSpawnTable
    (fn_body UA.f_get_mario_spawn_type) = true /\
  statement_mentions_ident_s UA._sSpawnTypeFromWarpBhv
    (fn_body UA.f_get_mario_spawn_type) = true /\
  statement_mentions_int_s 20 (fn_body UA.f_get_mario_spawn_type) = true.

Theorem area1_spin_spawn_table_checked_us :
  area1_spin_spawn_table_receipt_us.
Proof.
  unfold area1_spin_spawn_table_receipt_us,
    area1_spin_entry_spawn_type.
  vm_compute. repeat split.
Qed.

Definition area1_spin_spawn_table_receipt_jp : Prop :=
  nth_error (gvar_init JA.v_sWarpBhvSpawnTable) 11 =
    Some (Init_addrof JA._bhvSpinAirborneWarp (Ptrofs.repr 0)) /\
  nth_error (gvar_init JA.v_sSpawnTypeFromWarpBhv) 11 =
    Some (Init_int8 (Int.repr area1_spin_entry_spawn_type)) /\
  statement_mentions_ident_s JA._sWarpBhvSpawnTable
    (fn_body JA.f_get_mario_spawn_type) = true /\
  statement_mentions_ident_s JA._sSpawnTypeFromWarpBhv
    (fn_body JA.f_get_mario_spawn_type) = true /\
  statement_mentions_int_s 20 (fn_body JA.f_get_mario_spawn_type) = true.

Theorem area1_spin_spawn_table_checked_jp :
  area1_spin_spawn_table_receipt_jp.
Proof.
  unfold area1_spin_spawn_table_receipt_jp,
    area1_spin_entry_spawn_type.
  vm_compute. repeat split.
Qed.

Definition area1_spin_action_and_entry_call_receipt_us : Prop :=
  switch_case_calls_ident_with_two_int_literals_s
    area1_spin_entry_spawn_type ULU._set_mario_action
    area1_spin_entry_action_bits 0
    (fn_body ULU.f_set_mario_initial_action) = true /\
  ident_subsequenceb [ULU._load_area; ULU._init_mario_after_warp]
    (direct_callees_s (fn_body ULU.f_warp_level)) = true /\
  ident_subsequenceb
    [ULU._area_get_warp_node; ULU._get_mario_spawn_type;
     ULU._load_mario_area; ULU._init_mario; ULU._set_mario_initial_action]
    (direct_callees_s (fn_body ULU.f_init_mario_after_warp)) = true /\
  assigns_through_field_s ULU._startPos
    (fn_body ULU.f_init_mario_after_warp) = true /\
  assigns_field_int_constant_s ULU._type 0
    (fn_body ULU.f_init_mario_after_warp) = true /\
  assigns_global_ident_s ULU._sDelayedWarpOp
    (fn_body ULU.f_init_mario_after_warp) = true.

Theorem area1_spin_action_and_entry_call_checked_us :
  area1_spin_action_and_entry_call_receipt_us.
Proof.
  unfold area1_spin_action_and_entry_call_receipt_us,
    area1_spin_entry_spawn_type, area1_spin_entry_action_bits.
  vm_compute. repeat split.
Qed.

Definition area1_spin_action_and_entry_call_receipt_jp : Prop :=
  switch_case_calls_ident_with_two_int_literals_s
    area1_spin_entry_spawn_type JLU._set_mario_action
    area1_spin_entry_action_bits 0
    (fn_body JLU.f_set_mario_initial_action) = true /\
  ident_subsequenceb [JLU._load_area; JLU._init_mario_after_warp]
    (direct_callees_s (fn_body JLU.f_warp_level)) = true /\
  ident_subsequenceb
    [JLU._area_get_warp_node; JLU._get_mario_spawn_type;
     JLU._load_mario_area; JLU._init_mario; JLU._set_mario_initial_action]
    (direct_callees_s (fn_body JLU.f_init_mario_after_warp)) = true /\
  assigns_through_field_s JLU._startPos
    (fn_body JLU.f_init_mario_after_warp) = true /\
  assigns_field_int_constant_s JLU._type 0
    (fn_body JLU.f_init_mario_after_warp) = true /\
  assigns_global_ident_s JLU._sDelayedWarpOp
    (fn_body JLU.f_init_mario_after_warp) = true.

Theorem area1_spin_action_and_entry_call_checked_jp :
  area1_spin_action_and_entry_call_receipt_jp.
Proof.
  unfold area1_spin_action_and_entry_call_receipt_jp,
    area1_spin_entry_spawn_type, area1_spin_entry_action_bits.
  vm_compute. repeat split.
Qed.

(** Object-pool dimensions and the initialization/spawn writer chain.  This is
    a syntax/data receipt, not yet a proof of the resulting linked-list graph. *)
Definition area1_object_pool_source_receipt_us : Prop :=
  gvar_info UOL.v_gObjectPool =
    Tarray (Tstruct UOL._Object noattr) 240 noattr /\
  gvar_init UOL.v_gObjectPool = [Init_space 145920] /\
  gvar_info UOL.v_gObjectListArray =
    Tarray (Tstruct UOL._ObjectNode noattr) 16 noattr /\
  gvar_init UOL.v_gObjectListArray = [Init_space 1664] /\
  ident_subsequenceb
    [UOL._init_free_object_list; UOL._clear_object_lists;
     UOL._clear_dynamic_surfaces]
    (direct_callees_s (fn_body UOL.f_clear_objects)) = true /\
  assigns_field_int_constant_s UOL._activeFlags 0
    (fn_body UOL.f_clear_objects) = true /\
  calls_ident_s UOL._create_object
    (fn_body UOL.f_spawn_objects_from_info) = true /\
  assigns_through_field_s UOL._platform
    (fn_body USO.f_allocate_object) = true /\
  assigns_field_null_pointer_s USO._platform
    (fn_body USO.f_allocate_object) = true /\
  assigns_field_int_constant_s USO._collidedObjInteractTypes 0
    (fn_body USO.f_allocate_object) = true /\
  assigns_field_int_constant_s USO._numCollidedObjs 0
    (fn_body USO.f_allocate_object) = true.

Theorem area1_object_pool_source_checked_us :
  area1_object_pool_source_receipt_us.
Proof.
  unfold area1_object_pool_source_receipt_us.
  vm_compute. repeat split.
Qed.

Definition area1_object_pool_source_receipt_jp : Prop :=
  gvar_info JOL.v_gObjectPool =
    Tarray (Tstruct JOL._Object noattr) 240 noattr /\
  gvar_init JOL.v_gObjectPool = [Init_space 145920] /\
  gvar_info JOL.v_gObjectListArray =
    Tarray (Tstruct JOL._ObjectNode noattr) 16 noattr /\
  gvar_init JOL.v_gObjectListArray = [Init_space 1664] /\
  ident_subsequenceb
    [JOL._init_free_object_list; JOL._clear_object_lists;
     JOL._clear_dynamic_surfaces]
    (direct_callees_s (fn_body JOL.f_clear_objects)) = true /\
  assigns_field_int_constant_s JOL._activeFlags 0
    (fn_body JOL.f_clear_objects) = true /\
  calls_ident_s JOL._create_object
    (fn_body JOL.f_spawn_objects_from_info) = true /\
  assigns_through_field_s JOL._platform
    (fn_body JSO.f_allocate_object) = true /\
  assigns_field_null_pointer_s JSO._platform
    (fn_body JSO.f_allocate_object) = true /\
  assigns_field_int_constant_s JSO._collidedObjInteractTypes 0
    (fn_body JSO.f_allocate_object) = true /\
  assigns_field_int_constant_s JSO._numCollidedObjs 0
    (fn_body JSO.f_allocate_object) = true.

Theorem area1_object_pool_source_checked_jp :
  area1_object_pool_source_receipt_jp.
Proof.
  unfold area1_object_pool_source_receipt_jp.
  vm_compute. repeat split.
Qed.

Definition area1_platform_version_split_receipt : Prop :=
  gvar_init UPD.v_gMarioPlatform = [Init_int32 Int.zero] /\
  gvar_init JPD.v_gMarioPlatform = [Init_int32 Int.zero] /\
  calls_ident_s UOL._clear_mario_platform
    (fn_body UOL.f_spawn_objects_from_info) = true /\
  calls_ident_s UOL._clear_mario_platform
    (fn_body JOL.f_spawn_objects_from_info) = false.

Theorem area1_platform_version_split_checked :
  area1_platform_version_split_receipt.
Proof. vm_compute. repeat split. Qed.

Definition OrdinaryArea1EntrySourceKernel : Prop :=
  ssl_area1_spin_entry_object_receipt_us /\
  ssl_area1_spin_entry_object_receipt_jp /\
  ssl_area1_default_mario_pos_receipt_us /\
  ssl_area1_default_mario_pos_receipt_jp /\
  area1_spin_spawn_table_receipt_us /\
  area1_spin_spawn_table_receipt_jp /\
  area1_spin_action_and_entry_call_receipt_us /\
  area1_spin_action_and_entry_call_receipt_jp /\
  mario_entry_coordinate_sync_source_shape_us_claim /\
  mario_entry_coordinate_sync_source_shape_jp_claim /\
  area1_object_pool_source_receipt_us /\
  area1_object_pool_source_receipt_jp /\
  assigns_pressed_operator_shape_s UGI._buttonPressed
    (fn_body UGI.f_read_controller_inputs) = true /\
  assigns_pressed_operator_shape_s JGI._buttonPressed
    (fn_body JGI.f_read_controller_inputs) = true /\
  area1_platform_version_split_receipt.

Theorem ordinary_area1_entry_source_kernel_checked :
  OrdinaryArea1EntrySourceKernel.
Proof.
  unfold OrdinaryArea1EntrySourceKernel.
  split; [exact ssl_area1_spin_entry_object_exact_us |].
  split; [exact ssl_area1_spin_entry_object_exact_jp |].
  split; [exact ssl_area1_default_mario_pos_exact_us |].
  split; [exact ssl_area1_default_mario_pos_exact_jp |].
  split; [exact area1_spin_spawn_table_checked_us |].
  split; [exact area1_spin_spawn_table_checked_jp |].
  split; [exact area1_spin_action_and_entry_call_checked_us |].
  split; [exact area1_spin_action_and_entry_call_checked_jp |].
  split; [exact mario_entry_coordinate_sync_source_shape_us |].
  split; [exact mario_entry_coordinate_sync_source_shape_jp |].
  split; [exact area1_object_pool_source_checked_us |].
  split; [exact area1_object_pool_source_checked_jp |].
  split; [exact generated_controller_has_pressed_operator_shape_us |].
  split; [exact generated_controller_has_pressed_operator_shape_jp |].
  exact area1_platform_version_split_checked.
Qed.

(** * Entry controller history *)

Definition entry_sample_from_history
    (previous_down current_down : int) : EntryControllerSample :=
  {| entry_controller_button_down := current_down;
     entry_controller_button_pressed := edge_pressed current_down previous_down |}.

Definition entry_sample_has_no_a_edge
    (sample : EntryControllerSample) : Prop :=
  Int.testbit (entry_controller_button_pressed sample) 15 = false.

Theorem no_a_frame_yields_no_a_entry_sample :
  forall previous_down current_down,
    frame_has_no_a_press
      {| frame_previous_down := previous_down;
         frame_current_down := current_down |} ->
    entry_sample_has_no_a_edge
      (entry_sample_from_history previous_down current_down).
Proof. intros previous_down current_down H; exact H. Qed.

Theorem ordinary_entry_contract_permits_held_a :
  entry_sample_has_no_a_edge
    (entry_sample_from_history a_button_mask a_button_mask) /\
  a_button_down
    (entry_controller_button_down
      (entry_sample_from_history a_button_mask a_button_mask)) = true.
Proof. vm_compute. split; reflexivity. Qed.

(** * Concrete live-memory postcondition *)

Definition object_pool_capacity : nat := 240.
Definition object_size : Z := 608.
Definition object_list_count : nat := 16.
Definition object_list_node_size : Z := 104.

Definition mario_state_interact_object_offset : Z := 120.
Definition mario_state_held_object_offset : Z := 124.
Definition mario_state_used_object_offset : Z := 128.
Definition mario_state_ridden_object_offset : Z := 132.

Definition object_next_offset : Z := 96.
Definition object_previous_offset : Z := 100.
Definition object_collided_types_offset : Z := 112.
Definition object_active_flags_offset : Z := 116.
Definition object_num_collided_offset : Z := 118.
Definition object_behavior_offset : Z := 524.
Definition object_platform_offset : Z := 532.

Definition active_object_flags : int := Int.repr 257.
Definition spin_airborne_entry_action : int :=
  Int.repr area1_spin_entry_action_bits.

Record Area1EntryAddresses := {
  area1_state_storage_block : block;
  area1_state_pointer_cell_block : block;
  area1_controller_storage_block : block;
  area1_object_pool_block : block;
  area1_object_lists_storage_block : block;
  area1_free_list_block : block;
  area1_object_lists_pointer_cell_block : block;
  area1_mario_object_pointer_cell_block : block;
  area1_platform_pointer_cell_block : block;
  area1_warp_dest_block : block;
  area1_delayed_warp_block : block;
  area1_spin_behavior_block : block;
  area1_mario_slot : nat;
  area1_entry_warp_slot : nat
}.

Definition object_slot_offset (slot : nat) : Z :=
  object_size * Z.of_nat slot.

Definition object_slot_pointer
    (addresses : Area1EntryAddresses) (slot : nat) : val :=
  Vptr (area1_object_pool_block addresses)
    (Ptrofs.repr (object_slot_offset slot)).

Definition mario_object_base (addresses : Area1EntryAddresses) : Z :=
  object_slot_offset (area1_mario_slot addresses).

Definition entry_warp_object_base (addresses : Area1EntryAddresses) : Z :=
  object_slot_offset (area1_entry_warp_slot addresses).

Definition area1_entry_slots_valid (addresses : Area1EntryAddresses) : Prop :=
  (area1_mario_slot addresses < object_pool_capacity)%nat /\
  (area1_entry_warp_slot addresses < object_pool_capacity)%nat /\
  area1_mario_slot addresses <> area1_entry_warp_slot addresses.

Theorem distinct_object_slot_intervals_are_disjoint :
  forall first second,
    first <> second ->
    object_slot_offset first + object_size <= object_slot_offset second \/
    object_slot_offset second + object_size <= object_slot_offset first.
Proof.
  intros first second Hdistinct.
  destruct (Nat.lt_trichotomy first second) as [Hlt | [Heq | Hgt]].
  - left.
    apply Nat2Z.inj_lt in Hlt.
    unfold object_slot_offset, object_size.
    nia.
  - contradiction.
  - right.
    apply Nat2Z.inj_lt in Hgt.
    unfold object_slot_offset, object_size.
    nia.
Qed.

Theorem distinct_object_slot_in_bounds_offsets_are_distinct :
  forall first second first_offset second_offset,
    first <> second ->
    0 <= first_offset < object_size ->
    0 <= second_offset < object_size ->
    object_slot_offset first + first_offset <>
      object_slot_offset second + second_offset.
Proof.
  intros first second first_offset second_offset
    Hdistinct Hfirst Hsecond Hequal.
  pose proof
    (distinct_object_slot_intervals_are_disjoint first second Hdistinct)
    as Hintervals.
  destruct Hintervals; nia.
Qed.

(** The preceding integer-offset fact is lifted through CompCert's finite
    pointer offset representation only for real pool slots and in-object
    byte offsets.  The largest possible address is 145919, so [Ptrofs.repr]
    cannot wrap on either target. *)
Theorem distinct_valid_object_slot_ptrofs_do_not_alias :
  forall first second first_offset second_offset,
    (first < object_pool_capacity)%nat ->
    (second < object_pool_capacity)%nat ->
    first <> second ->
    0 <= first_offset < object_size ->
    0 <= second_offset < object_size ->
    Ptrofs.repr (object_slot_offset first + first_offset) <>
      Ptrofs.repr (object_slot_offset second + second_offset).
Proof.
  intros first second first_offset second_offset
    Hfirst_slot Hsecond_slot Hdistinct Hfirst_offset Hsecond_offset Hequal.
  pose proof
    (distinct_object_slot_in_bounds_offsets_are_distinct
      first second first_offset second_offset
      Hdistinct Hfirst_offset Hsecond_offset) as Hoffsets_distinct.
  apply (f_equal Ptrofs.unsigned) in Hequal.
  assert (Hfirst_slot_z : Z.of_nat first < 240).
  { apply Nat2Z.inj_lt in Hfirst_slot.
    unfold object_pool_capacity in Hfirst_slot.
    exact Hfirst_slot. }
  assert (Hsecond_slot_z : Z.of_nat second < 240).
  { apply Nat2Z.inj_lt in Hsecond_slot.
    unfold object_pool_capacity in Hsecond_slot.
    exact Hsecond_slot. }
  assert (Hmax : 145919 <= Ptrofs.max_unsigned).
  { destruct Archi.ptr64 eqn:Hptr.
    - unfold Ptrofs.max_unsigned.
      rewrite (Ptrofs.modulus_eq64 Hptr).
      change (145919 <= 18446744073709551615).
      lia.
    - unfold Ptrofs.max_unsigned.
      rewrite (Ptrofs.modulus_eq32 Hptr).
      change (145919 <= 4294967295).
      lia. }
  rewrite !Ptrofs.unsigned_repr in Hequal;
    unfold object_slot_offset, object_size in *; nia.
Qed.

Theorem distinct_valid_object_slot_vptrs_do_not_alias :
  forall pool_block first second first_offset second_offset,
    (first < object_pool_capacity)%nat ->
    (second < object_pool_capacity)%nat ->
    first <> second ->
    0 <= first_offset < object_size ->
    0 <= second_offset < object_size ->
    Vptr pool_block
      (Ptrofs.repr (object_slot_offset first + first_offset)) <>
    Vptr pool_block
      (Ptrofs.repr (object_slot_offset second + second_offset)).
Proof.
  intros pool_block first second first_offset second_offset
    Hfirst_slot Hsecond_slot Hdistinct Hfirst_offset Hsecond_offset Hequal.
  pose proof (distinct_valid_object_slot_ptrofs_do_not_alias
    first second first_offset second_offset
    Hfirst_slot Hsecond_slot Hdistinct Hfirst_offset Hsecond_offset)
    as Hoffsets_distinct.
  apply Hoffsets_distinct.
  congruence.
Qed.

Theorem ordinary_area1_mario_and_entry_warp_slot_intervals_are_disjoint :
  forall addresses,
    area1_entry_slots_valid addresses ->
    object_slot_offset (area1_mario_slot addresses) + object_size <=
      object_slot_offset (area1_entry_warp_slot addresses) \/
    object_slot_offset (area1_entry_warp_slot addresses) + object_size <=
      object_slot_offset (area1_mario_slot addresses).
Proof.
  intros addresses (_ & _ & Hdistinct).
  now apply distinct_object_slot_intervals_are_disjoint.
Qed.

(** The interval result applies only to accesses proved to remain within one
    608-byte [Object].  An out-of-bounds pointer computation could escape its
    slot and therefore remains an explicit refinement obligation. *)
Definition OrdinaryArea1ObjectAccessInBoundsObligation
    (reachable_object_access :
      Clight.state -> nat -> Z -> Z -> Prop) : Prop :=
  forall state slot offset width,
    reachable_object_access state slot offset width ->
    (slot < object_pool_capacity)%nat /\
    0 <= offset /\
    0 < width /\
    offset + width <= object_size.

(** These symbol records prevent the memory blocks below from being arbitrary
    existential witnesses disconnected from the linked Clight program. *)
Record USArea1EntrySymbolBindings
    (ge : Clight.genv) (addresses : Area1EntryAddresses) : Prop := {
  us_area1_state_storage_symbol :
    Genv.find_symbol ge ULU._gMarioStates =
      Some (area1_state_storage_block addresses);
  us_area1_state_pointer_symbol :
    Genv.find_symbol ge ULU._gMarioState =
      Some (area1_state_pointer_cell_block addresses);
  us_area1_controller_storage_symbol :
    Genv.find_symbol ge UM._gControllers =
      Some (area1_controller_storage_block addresses);
  us_area1_object_pool_symbol :
    Genv.find_symbol ge UOL._gObjectPool =
      Some (area1_object_pool_block addresses);
  us_area1_object_lists_storage_symbol :
    Genv.find_symbol ge UOL._gObjectListArray =
      Some (area1_object_lists_storage_block addresses);
  us_area1_free_list_symbol :
    Genv.find_symbol ge UOL._gFreeObjectList =
      Some (area1_free_list_block addresses);
  us_area1_object_lists_pointer_symbol :
    Genv.find_symbol ge UOL._gObjectLists =
      Some (area1_object_lists_pointer_cell_block addresses);
  us_area1_mario_object_pointer_symbol :
    Genv.find_symbol ge UOL._gMarioObject =
      Some (area1_mario_object_pointer_cell_block addresses);
  us_area1_platform_pointer_symbol :
    Genv.find_symbol ge UPD._gMarioPlatform =
      Some (area1_platform_pointer_cell_block addresses);
  us_area1_warp_dest_symbol :
    Genv.find_symbol ge ULU._sWarpDest =
      Some (area1_warp_dest_block addresses);
  us_area1_delayed_warp_symbol :
    Genv.find_symbol ge ULU._sDelayedWarpOp =
      Some (area1_delayed_warp_block addresses);
  us_area1_spin_behavior_symbol :
    Genv.find_symbol ge USS._bhvSpinAirborneWarp =
      Some (area1_spin_behavior_block addresses)
}.

Record JPArea1EntrySymbolBindings
    (ge : Clight.genv) (addresses : Area1EntryAddresses) : Prop := {
  jp_area1_state_storage_symbol :
    Genv.find_symbol ge JLU._gMarioStates =
      Some (area1_state_storage_block addresses);
  jp_area1_state_pointer_symbol :
    Genv.find_symbol ge JLU._gMarioState =
      Some (area1_state_pointer_cell_block addresses);
  jp_area1_controller_storage_symbol :
    Genv.find_symbol ge JM._gControllers =
      Some (area1_controller_storage_block addresses);
  jp_area1_object_pool_symbol :
    Genv.find_symbol ge JOL._gObjectPool =
      Some (area1_object_pool_block addresses);
  jp_area1_object_lists_storage_symbol :
    Genv.find_symbol ge JOL._gObjectListArray =
      Some (area1_object_lists_storage_block addresses);
  jp_area1_free_list_symbol :
    Genv.find_symbol ge JOL._gFreeObjectList =
      Some (area1_free_list_block addresses);
  jp_area1_object_lists_pointer_symbol :
    Genv.find_symbol ge JOL._gObjectLists =
      Some (area1_object_lists_pointer_cell_block addresses);
  jp_area1_mario_object_pointer_symbol :
    Genv.find_symbol ge JOL._gMarioObject =
      Some (area1_mario_object_pointer_cell_block addresses);
  jp_area1_platform_pointer_symbol :
    Genv.find_symbol ge JPD._gMarioPlatform =
      Some (area1_platform_pointer_cell_block addresses);
  jp_area1_warp_dest_symbol :
    Genv.find_symbol ge JLU._sWarpDest =
      Some (area1_warp_dest_block addresses);
  jp_area1_delayed_warp_symbol :
    Genv.find_symbol ge JLU._sDelayedWarpOp =
      Some (area1_delayed_warp_block addresses);
  jp_area1_spin_behavior_symbol :
    Genv.find_symbol ge JSS._bhvSpinAirborneWarp =
      Some (area1_spin_behavior_block addresses)
}.

(** CompCert allocates distinct global identifiers in distinct blocks.  These
    are genuine non-alias results from the linked global environment, not
    fields added to the clean-entry predicate. *)
Theorem us_area1_entry_storage_blocks_pairwise_distinct :
  forall ge addresses,
    USArea1EntrySymbolBindings ge addresses ->
    area1_state_storage_block addresses <>
      area1_controller_storage_block addresses /\
    area1_state_storage_block addresses <>
      area1_object_pool_block addresses /\
    area1_controller_storage_block addresses <>
      area1_object_pool_block addresses.
Proof.
  intros ge addresses Hbindings.
  repeat split.
  - eapply (Genv.global_addresses_distinct ge
      (id1 := ULU._gMarioStates) (id2 := UM._gControllers)).
    + vm_compute. discriminate.
    + exact (us_area1_state_storage_symbol _ _ Hbindings).
    + exact (us_area1_controller_storage_symbol _ _ Hbindings).
  - eapply (Genv.global_addresses_distinct ge
      (id1 := ULU._gMarioStates) (id2 := UOL._gObjectPool)).
    + vm_compute. discriminate.
    + exact (us_area1_state_storage_symbol _ _ Hbindings).
    + exact (us_area1_object_pool_symbol _ _ Hbindings).
  - eapply (Genv.global_addresses_distinct ge
      (id1 := UM._gControllers) (id2 := UOL._gObjectPool)).
    + vm_compute. discriminate.
    + exact (us_area1_controller_storage_symbol _ _ Hbindings).
    + exact (us_area1_object_pool_symbol _ _ Hbindings).
Qed.

Theorem jp_area1_entry_storage_blocks_pairwise_distinct :
  forall ge addresses,
    JPArea1EntrySymbolBindings ge addresses ->
    area1_state_storage_block addresses <>
      area1_controller_storage_block addresses /\
    area1_state_storage_block addresses <>
      area1_object_pool_block addresses /\
    area1_controller_storage_block addresses <>
      area1_object_pool_block addresses.
Proof.
  intros ge addresses Hbindings.
  repeat split.
  - eapply (Genv.global_addresses_distinct ge
      (id1 := JLU._gMarioStates) (id2 := JM._gControllers)).
    + vm_compute. discriminate.
    + exact (jp_area1_state_storage_symbol _ _ Hbindings).
    + exact (jp_area1_controller_storage_symbol _ _ Hbindings).
  - eapply (Genv.global_addresses_distinct ge
      (id1 := JLU._gMarioStates) (id2 := JOL._gObjectPool)).
    + vm_compute. discriminate.
    + exact (jp_area1_state_storage_symbol _ _ Hbindings).
    + exact (jp_area1_object_pool_symbol _ _ Hbindings).
  - eapply (Genv.global_addresses_distinct ge
      (id1 := JM._gControllers) (id2 := JOL._gObjectPool)).
    + vm_compute. discriminate.
    + exact (jp_area1_controller_storage_symbol _ _ Hbindings).
    + exact (jp_area1_object_pool_symbol _ _ Hbindings).
Qed.

Definition area1_pointer_cells_separate_from_core_storage
    (addresses : Area1EntryAddresses) : Prop :=
  area1_state_pointer_cell_block addresses <>
    area1_state_storage_block addresses /\
  area1_state_pointer_cell_block addresses <>
    area1_controller_storage_block addresses /\
  area1_state_pointer_cell_block addresses <>
    area1_object_pool_block addresses /\
  area1_mario_object_pointer_cell_block addresses <>
    area1_state_storage_block addresses /\
  area1_mario_object_pointer_cell_block addresses <>
    area1_controller_storage_block addresses /\
  area1_mario_object_pointer_cell_block addresses <>
    area1_object_pool_block addresses /\
  area1_object_lists_pointer_cell_block addresses <>
    area1_state_storage_block addresses /\
  area1_object_lists_pointer_cell_block addresses <>
    area1_controller_storage_block addresses /\
  area1_object_lists_pointer_cell_block addresses <>
    area1_object_pool_block addresses /\
  area1_platform_pointer_cell_block addresses <>
    area1_state_storage_block addresses /\
  area1_platform_pointer_cell_block addresses <>
    area1_controller_storage_block addresses /\
  area1_platform_pointer_cell_block addresses <>
    area1_object_pool_block addresses.

(** Keep computation away from [Genv.find_symbol] goals.  Expanding a whole
    generated global environment merely to solve one inequality between two
    concrete identifier atoms consumes several gigabytes. *)
Ltac solve_generated_ident_inequality :=
  match goal with
  | |- ?left <> ?right => vm_compute; discriminate
  end.

Theorem us_area1_pointer_cells_are_separate_from_core_storage :
  forall ge addresses,
    USArea1EntrySymbolBindings ge addresses ->
    area1_pointer_cells_separate_from_core_storage addresses.
Proof.
  intros ge addresses Hbindings.
  unfold area1_pointer_cells_separate_from_core_storage.
  repeat split.
  - eapply (Genv.global_addresses_distinct ge
      (id1 := ULU._gMarioState) (id2 := ULU._gMarioStates));
      try solve_generated_ident_inequality.
    + exact (us_area1_state_pointer_symbol _ _ Hbindings).
    + exact (us_area1_state_storage_symbol _ _ Hbindings).
  - eapply (Genv.global_addresses_distinct ge
      (id1 := ULU._gMarioState) (id2 := UM._gControllers));
      try solve_generated_ident_inequality.
    + exact (us_area1_state_pointer_symbol _ _ Hbindings).
    + exact (us_area1_controller_storage_symbol _ _ Hbindings).
  - eapply (Genv.global_addresses_distinct ge
      (id1 := ULU._gMarioState) (id2 := UOL._gObjectPool));
      try solve_generated_ident_inequality.
    + exact (us_area1_state_pointer_symbol _ _ Hbindings).
    + exact (us_area1_object_pool_symbol _ _ Hbindings).
  - eapply (Genv.global_addresses_distinct ge
      (id1 := UOL._gMarioObject) (id2 := ULU._gMarioStates));
      try solve_generated_ident_inequality.
    + exact (us_area1_mario_object_pointer_symbol _ _ Hbindings).
    + exact (us_area1_state_storage_symbol _ _ Hbindings).
  - eapply (Genv.global_addresses_distinct ge
      (id1 := UOL._gMarioObject) (id2 := UM._gControllers));
      try solve_generated_ident_inequality.
    + exact (us_area1_mario_object_pointer_symbol _ _ Hbindings).
    + exact (us_area1_controller_storage_symbol _ _ Hbindings).
  - eapply (Genv.global_addresses_distinct ge
      (id1 := UOL._gMarioObject) (id2 := UOL._gObjectPool));
      try solve_generated_ident_inequality.
    + exact (us_area1_mario_object_pointer_symbol _ _ Hbindings).
    + exact (us_area1_object_pool_symbol _ _ Hbindings).
  - eapply (Genv.global_addresses_distinct ge
      (id1 := UOL._gObjectLists) (id2 := ULU._gMarioStates));
      try solve_generated_ident_inequality.
    + exact (us_area1_object_lists_pointer_symbol _ _ Hbindings).
    + exact (us_area1_state_storage_symbol _ _ Hbindings).
  - eapply (Genv.global_addresses_distinct ge
      (id1 := UOL._gObjectLists) (id2 := UM._gControllers));
      try solve_generated_ident_inequality.
    + exact (us_area1_object_lists_pointer_symbol _ _ Hbindings).
    + exact (us_area1_controller_storage_symbol _ _ Hbindings).
  - eapply (Genv.global_addresses_distinct ge
      (id1 := UOL._gObjectLists) (id2 := UOL._gObjectPool));
      try solve_generated_ident_inequality.
    + exact (us_area1_object_lists_pointer_symbol _ _ Hbindings).
    + exact (us_area1_object_pool_symbol _ _ Hbindings).
  - eapply (Genv.global_addresses_distinct ge
      (id1 := UPD._gMarioPlatform) (id2 := ULU._gMarioStates));
      try solve_generated_ident_inequality.
    + exact (us_area1_platform_pointer_symbol _ _ Hbindings).
    + exact (us_area1_state_storage_symbol _ _ Hbindings).
  - eapply (Genv.global_addresses_distinct ge
      (id1 := UPD._gMarioPlatform) (id2 := UM._gControllers));
      try solve_generated_ident_inequality.
    + exact (us_area1_platform_pointer_symbol _ _ Hbindings).
    + exact (us_area1_controller_storage_symbol _ _ Hbindings).
  - eapply (Genv.global_addresses_distinct ge
      (id1 := UPD._gMarioPlatform) (id2 := UOL._gObjectPool));
      try solve_generated_ident_inequality.
    + exact (us_area1_platform_pointer_symbol _ _ Hbindings).
    + exact (us_area1_object_pool_symbol _ _ Hbindings).
Qed.

Theorem jp_area1_pointer_cells_are_separate_from_core_storage :
  forall ge addresses,
    JPArea1EntrySymbolBindings ge addresses ->
    area1_pointer_cells_separate_from_core_storage addresses.
Proof.
  intros ge addresses Hbindings.
  unfold area1_pointer_cells_separate_from_core_storage.
  repeat split.
  - eapply (Genv.global_addresses_distinct ge
      (id1 := JLU._gMarioState) (id2 := JLU._gMarioStates));
      try solve_generated_ident_inequality.
    + exact (jp_area1_state_pointer_symbol _ _ Hbindings).
    + exact (jp_area1_state_storage_symbol _ _ Hbindings).
  - eapply (Genv.global_addresses_distinct ge
      (id1 := JLU._gMarioState) (id2 := JM._gControllers));
      try solve_generated_ident_inequality.
    + exact (jp_area1_state_pointer_symbol _ _ Hbindings).
    + exact (jp_area1_controller_storage_symbol _ _ Hbindings).
  - eapply (Genv.global_addresses_distinct ge
      (id1 := JLU._gMarioState) (id2 := JOL._gObjectPool));
      try solve_generated_ident_inequality.
    + exact (jp_area1_state_pointer_symbol _ _ Hbindings).
    + exact (jp_area1_object_pool_symbol _ _ Hbindings).
  - eapply (Genv.global_addresses_distinct ge
      (id1 := JOL._gMarioObject) (id2 := JLU._gMarioStates));
      try solve_generated_ident_inequality.
    + exact (jp_area1_mario_object_pointer_symbol _ _ Hbindings).
    + exact (jp_area1_state_storage_symbol _ _ Hbindings).
  - eapply (Genv.global_addresses_distinct ge
      (id1 := JOL._gMarioObject) (id2 := JM._gControllers));
      try solve_generated_ident_inequality.
    + exact (jp_area1_mario_object_pointer_symbol _ _ Hbindings).
    + exact (jp_area1_controller_storage_symbol _ _ Hbindings).
  - eapply (Genv.global_addresses_distinct ge
      (id1 := JOL._gMarioObject) (id2 := JOL._gObjectPool));
      try solve_generated_ident_inequality.
    + exact (jp_area1_mario_object_pointer_symbol _ _ Hbindings).
    + exact (jp_area1_object_pool_symbol _ _ Hbindings).
  - eapply (Genv.global_addresses_distinct ge
      (id1 := JOL._gObjectLists) (id2 := JLU._gMarioStates));
      try solve_generated_ident_inequality.
    + exact (jp_area1_object_lists_pointer_symbol _ _ Hbindings).
    + exact (jp_area1_state_storage_symbol _ _ Hbindings).
  - eapply (Genv.global_addresses_distinct ge
      (id1 := JOL._gObjectLists) (id2 := JM._gControllers));
      try solve_generated_ident_inequality.
    + exact (jp_area1_object_lists_pointer_symbol _ _ Hbindings).
    + exact (jp_area1_controller_storage_symbol _ _ Hbindings).
  - eapply (Genv.global_addresses_distinct ge
      (id1 := JOL._gObjectLists) (id2 := JOL._gObjectPool));
      try solve_generated_ident_inequality.
    + exact (jp_area1_object_lists_pointer_symbol _ _ Hbindings).
    + exact (jp_area1_object_pool_symbol _ _ Hbindings).
  - eapply (Genv.global_addresses_distinct ge
      (id1 := JPD._gMarioPlatform) (id2 := JLU._gMarioStates));
      try solve_generated_ident_inequality.
    + exact (jp_area1_platform_pointer_symbol _ _ Hbindings).
    + exact (jp_area1_state_storage_symbol _ _ Hbindings).
  - eapply (Genv.global_addresses_distinct ge
      (id1 := JPD._gMarioPlatform) (id2 := JM._gControllers));
      try solve_generated_ident_inequality.
    + exact (jp_area1_platform_pointer_symbol _ _ Hbindings).
    + exact (jp_area1_controller_storage_symbol _ _ Hbindings).
  - eapply (Genv.global_addresses_distinct ge
      (id1 := JPD._gMarioPlatform) (id2 := JOL._gObjectPool));
      try solve_generated_ident_inequality.
    + exact (jp_area1_platform_pointer_symbol _ _ Hbindings).
    + exact (jp_area1_object_pool_symbol _ _ Hbindings).
Qed.

(** The request observed immediately before [warp_level].  [arg] is not fixed:
    the spin-airborne case passes literal zero to [set_mario_action] regardless
    of the request argument. *)
Record OrdinaryArea1WarpRequestMemory
    (memory : mem) (addresses : Area1EntryAddresses) : Prop := {
  ordinary_area1_request_type :
    load_at Mint8unsigned memory (area1_warp_dest_block addresses) 0 0 =
      Some (Vint (Int.repr 1));
  ordinary_area1_request_level :
    load_at Mint8unsigned memory (area1_warp_dest_block addresses) 0 1 =
      Some (Vint ssl_level_id);
  ordinary_area1_request_area :
    load_at Mint8unsigned memory (area1_warp_dest_block addresses) 0 2 =
      Some (Vint (Int.repr 1));
  ordinary_area1_request_node :
    load_at Mint8unsigned memory (area1_warp_dest_block addresses) 0 3 =
      Some (Vint (Int.repr area1_entry_warp_node));
  ordinary_area1_prior_action_initialized :
    exists action,
      load_at Mint32 memory (area1_state_storage_block addresses) 0
        mario_state_action_offset = Some (Vint action) /\
      action <> Int.zero
}.

(** [warp_level] does not poll the controller.  The input sample therefore
    belongs to the predecessor state and must be carried through the entry
    execution, rather than universally choosing an unrelated postcondition
    sample. *)
Record OrdinaryArea1ControllerHistoryMemory
    (memory : mem) (addresses : Area1EntryAddresses)
    (previous_down current_down : int) : Prop := {
  ordinary_area1_preentry_controller_down :
    load_at Mint16unsigned memory
      (area1_controller_storage_block addresses) 0
      controller_button_down_offset = Some (Vint current_down);
  ordinary_area1_preentry_controller_pressed :
    load_at Mint16unsigned memory
      (area1_controller_storage_block addresses) 0
      controller_button_pressed_offset =
      Some (Vint (edge_pressed current_down previous_down))
}.

Record OrdinaryArea1EntryMemoryPostcondition
    (memory : mem) (addresses : Area1EntryAddresses)
    (x y z : float32) (sample : EntryControllerSample) : Prop := {
  ordinary_area1_slots_valid : area1_entry_slots_valid addresses;

  ordinary_area1_state_global_pointer :
    load_at Mptr memory (area1_state_pointer_cell_block addresses) 0 0 =
      Some (Vptr (area1_state_storage_block addresses) Ptrofs.zero);
  ordinary_area1_object_global_pointer :
    load_at Mptr memory (area1_mario_object_pointer_cell_block addresses) 0 0 =
      Some (object_slot_pointer addresses (area1_mario_slot addresses));
  ordinary_area1_lists_global_pointer :
    load_at Mptr memory (area1_object_lists_pointer_cell_block addresses) 0 0 =
      Some (Vptr (area1_object_lists_storage_block addresses) Ptrofs.zero);

  ordinary_area1_state_object_pointer :
    load_at Mptr memory (area1_state_storage_block addresses) 0
      mario_state_object_pointer_offset =
      Some (object_slot_pointer addresses (area1_mario_slot addresses));
  ordinary_area1_state_controller_pointer :
    load_at Mptr memory (area1_state_storage_block addresses) 0
      mario_state_controller_pointer_offset =
      Some (Vptr (area1_controller_storage_block addresses) Ptrofs.zero);

  ordinary_area1_state_x :
    load_at Mfloat32 memory (area1_state_storage_block addresses) 0
      mario_state_position_offset = Some (Vsingle x);
  ordinary_area1_state_y :
    load_at Mfloat32 memory (area1_state_storage_block addresses) 0
      (mario_state_position_offset + 4) = Some (Vsingle y);
  ordinary_area1_state_z :
    load_at Mfloat32 memory (area1_state_storage_block addresses) 0
      (mario_state_position_offset + 8) = Some (Vsingle z);

  ordinary_area1_object_raw_x :
    load_at Mfloat32 memory (area1_object_pool_block addresses)
      (mario_object_base addresses) mario_object_raw_position_offset =
      Some (Vsingle x);
  ordinary_area1_object_raw_y :
    load_at Mfloat32 memory (area1_object_pool_block addresses)
      (mario_object_base addresses) (mario_object_raw_position_offset + 4) =
      Some (Vsingle y);
  ordinary_area1_object_raw_z :
    load_at Mfloat32 memory (area1_object_pool_block addresses)
      (mario_object_base addresses) (mario_object_raw_position_offset + 8) =
      Some (Vsingle z);

  ordinary_area1_object_graphics_x :
    load_at Mfloat32 memory (area1_object_pool_block addresses)
      (mario_object_base addresses) mario_object_graphics_position_offset =
      Some (Vsingle x);
  ordinary_area1_object_graphics_y :
    load_at Mfloat32 memory (area1_object_pool_block addresses)
      (mario_object_base addresses) (mario_object_graphics_position_offset + 4) =
      Some (Vsingle y);
  ordinary_area1_object_graphics_z :
    load_at Mfloat32 memory (area1_object_pool_block addresses)
      (mario_object_base addresses) (mario_object_graphics_position_offset + 8) =
      Some (Vsingle z);

  ordinary_area1_velocity_x_zero :
    load_at Mfloat32 memory (area1_state_storage_block addresses) 0
      mario_state_velocity_offset = Some (Vsingle positive_f32_zero);
  ordinary_area1_velocity_y_zero :
    load_at Mfloat32 memory (area1_state_storage_block addresses) 0
      (mario_state_velocity_offset + 4) = Some (Vsingle positive_f32_zero);
  ordinary_area1_velocity_z_zero :
    load_at Mfloat32 memory (area1_state_storage_block addresses) 0
      (mario_state_velocity_offset + 8) = Some (Vsingle positive_f32_zero);
  ordinary_area1_forward_velocity_zero :
    load_at Mfloat32 memory (area1_state_storage_block addresses) 0
      mario_state_forward_velocity_offset = Some (Vsingle positive_f32_zero);

  ordinary_area1_action :
    load_at Mint32 memory (area1_state_storage_block addresses) 0
      mario_state_action_offset = Some (Vint spin_airborne_entry_action);
  ordinary_area1_action_state_zero :
    load_at Mint16unsigned memory (area1_state_storage_block addresses) 0
      mario_state_action_state_offset = Some (Vint Int.zero);
  ordinary_area1_action_timer_zero :
    load_at Mint16unsigned memory (area1_state_storage_block addresses) 0
      mario_state_action_timer_offset = Some (Vint Int.zero);
  ordinary_area1_action_arg_zero :
    load_at Mint32 memory (area1_state_storage_block addresses) 0
      mario_state_action_arg_offset = Some (Vint Int.zero);
  ordinary_area1_frames_since_a_255 :
    load_at Mint8unsigned memory (area1_state_storage_block addresses) 0
      mario_state_frames_since_a_offset = Some (Vint (Int.repr 255));
  ordinary_area1_frames_since_b_255 :
    load_at Mint8unsigned memory (area1_state_storage_block addresses) 0
      mario_state_frames_since_b_offset = Some (Vint (Int.repr 255));
  ordinary_area1_quicksand_depth_zero :
    load_at Mfloat32 memory (area1_state_storage_block addresses) 0
      mario_state_quicksand_depth_offset = Some (Vsingle positive_f32_zero);

  ordinary_area1_interact_object_is_entry_warp :
    load_at Mptr memory (area1_state_storage_block addresses) 0
      mario_state_interact_object_offset =
      Some (object_slot_pointer addresses (area1_entry_warp_slot addresses));
  ordinary_area1_held_object_null :
    load_at Mptr memory (area1_state_storage_block addresses) 0
      mario_state_held_object_offset = Some (Vint Int.zero);
  ordinary_area1_used_object_is_entry_warp :
    load_at Mptr memory (area1_state_storage_block addresses) 0
      mario_state_used_object_offset =
      Some (object_slot_pointer addresses (area1_entry_warp_slot addresses));
  ordinary_area1_ridden_object_null :
    load_at Mptr memory (area1_state_storage_block addresses) 0
      mario_state_ridden_object_offset = Some (Vint Int.zero);

  ordinary_area1_mario_active :
    load_at Mint16signed memory (area1_object_pool_block addresses)
      (mario_object_base addresses) object_active_flags_offset =
      Some (Vint active_object_flags);
  ordinary_area1_mario_collided_types_zero :
    load_at Mint32 memory (area1_object_pool_block addresses)
      (mario_object_base addresses) object_collided_types_offset =
      Some (Vint Int.zero);
  ordinary_area1_mario_num_collided_zero :
    load_at Mint16signed memory (area1_object_pool_block addresses)
      (mario_object_base addresses) object_num_collided_offset =
      Some (Vint Int.zero);
  ordinary_area1_mario_platform_field_null :
    load_at Mptr memory (area1_object_pool_block addresses)
      (mario_object_base addresses) object_platform_offset =
      Some (Vint Int.zero);
  ordinary_area1_mario_throw_matrix_null :
    load_at Mptr memory (area1_object_pool_block addresses)
      (mario_object_base addresses) mario_object_throw_matrix_offset =
      Some (Vint Int.zero);

  ordinary_area1_warp_object_behavior :
    load_at Mptr memory (area1_object_pool_block addresses)
      (entry_warp_object_base addresses) object_behavior_offset =
      Some (Vptr (area1_spin_behavior_block addresses) Ptrofs.zero);
  ordinary_area1_warp_object_raw_x :
    load_at Mfloat32 memory (area1_object_pool_block addresses)
      (entry_warp_object_base addresses) mario_object_raw_position_offset =
      Some (Vsingle x);
  ordinary_area1_warp_object_raw_y :
    load_at Mfloat32 memory (area1_object_pool_block addresses)
      (entry_warp_object_base addresses) (mario_object_raw_position_offset + 4) =
      Some (Vsingle y);
  ordinary_area1_warp_object_raw_z :
    load_at Mfloat32 memory (area1_object_pool_block addresses)
      (entry_warp_object_base addresses) (mario_object_raw_position_offset + 8) =
      Some (Vsingle z);

  ordinary_area1_warp_type_cleared :
    load_at Mint8unsigned memory (area1_warp_dest_block addresses) 0 0 =
      Some (Vint Int.zero);
  ordinary_area1_delayed_warp_cleared :
    load_at Mint16signed memory (area1_delayed_warp_block addresses) 0 0 =
      Some (Vint Int.zero);

  ordinary_area1_controller_down :
    load_at Mint16unsigned memory (area1_controller_storage_block addresses) 0
      controller_button_down_offset =
      Some (Vint (entry_controller_button_down sample));
  ordinary_area1_controller_pressed :
    load_at Mint16unsigned memory (area1_controller_storage_block addresses) 0
      controller_button_pressed_offset =
      Some (Vint (entry_controller_button_pressed sample))
}.

Definition USArea1EntryMemoryPostcondition
    (memory : mem) (addresses : Area1EntryAddresses)
    (x y z : float32) (sample : EntryControllerSample) : Prop :=
  OrdinaryArea1EntryMemoryPostcondition memory addresses x y z sample /\
  load_at Mptr memory (area1_platform_pointer_cell_block addresses) 0 0 =
    Some (Vint Int.zero).

(** JP deliberately states retention, not nullness.  The live predecessor may
    contain a stale object-pool pointer. *)
Definition JPArea1EntryMemoryPostcondition
    (memory_before memory_after : mem) (addresses : Area1EntryAddresses)
    (x y z : float32) (sample : EntryControllerSample) : Prop :=
  OrdinaryArea1EntryMemoryPostcondition memory_after addresses x y z sample /\
  load_at Mptr memory_after (area1_platform_pointer_cell_block addresses) 0 0 =
  load_at Mptr memory_before (area1_platform_pointer_cell_block addresses) 0 0.

Theorem ordinary_area1_entry_memory_synchronizes_raw_and_graphics_y :
  forall memory addresses x y z sample,
    OrdinaryArea1EntryMemoryPostcondition memory addresses x y z sample ->
    load_at Mfloat32 memory (area1_object_pool_block addresses)
      (mario_object_base addresses) (mario_object_raw_position_offset + 4) =
    load_at Mfloat32 memory (area1_object_pool_block addresses)
      (mario_object_base addresses) (mario_object_graphics_position_offset + 4).
Proof.
  intros memory addresses x y z sample H.
  rewrite (ordinary_area1_object_raw_y _ _ _ _ _ _ H).
  rewrite (ordinary_area1_object_graphics_y _ _ _ _ _ _ H).
  reflexivity.
Qed.

Theorem ordinary_area1_entry_memory_has_spin_action_and_zero_depth :
  forall memory addresses x y z sample,
    OrdinaryArea1EntryMemoryPostcondition memory addresses x y z sample ->
    load_at Mint32 memory (area1_state_storage_block addresses) 0
      mario_state_action_offset = Some (Vint spin_airborne_entry_action) /\
    load_at Mfloat32 memory (area1_state_storage_block addresses) 0
      mario_state_quicksand_depth_offset = Some (Vsingle positive_f32_zero).
Proof.
  intros memory addresses x y z sample H.
  split.
  - exact (ordinary_area1_action _ _ _ _ _ _ H).
  - exact (ordinary_area1_quicksand_depth_zero _ _ _ _ _ _ H).
Qed.

Theorem ordinary_area1_no_edge_memory_allows_a_down :
  forall memory addresses x y z,
    OrdinaryArea1EntryMemoryPostcondition memory addresses x y z
      (entry_sample_from_history a_button_mask a_button_mask) ->
    entry_sample_has_no_a_edge
      (entry_sample_from_history a_button_mask a_button_mask) /\
    load_at Mint16unsigned memory (area1_controller_storage_block addresses) 0
      controller_button_down_offset = Some (Vint a_button_mask).
Proof.
  intros memory addresses x y z H.
  split.
  - exact (proj1 ordinary_entry_contract_permits_held_a).
  - exact (ordinary_area1_controller_down _ _ _ _ _ _ H).
Qed.

(** * Concrete object-pool pointer closure target *)

Definition valid_area1_node_pointer
    (addresses : Area1EntryAddresses) (pointer : val) : Prop :=
  pointer = Vint Int.zero \/
  (exists slot,
    (slot < object_pool_capacity)%nat /\
    pointer = object_slot_pointer addresses slot) \/
  (exists list_index,
    (list_index < object_list_count)%nat /\
    pointer = Vptr (area1_object_lists_storage_block addresses)
      (Ptrofs.repr (object_list_node_size * Z.of_nat list_index))) \/
  pointer = Vptr (area1_free_list_block addresses) Ptrofs.zero.

Definition Area1ObjectPoolPointerClosure
    (memory : mem) (addresses : Area1EntryAddresses) : Prop :=
  (forall slot,
    (slot < object_pool_capacity)%nat ->
    exists next previous active,
      load_at Mptr memory (area1_object_pool_block addresses)
        (object_slot_offset slot) object_next_offset = Some next /\
      load_at Mptr memory (area1_object_pool_block addresses)
        (object_slot_offset slot) object_previous_offset = Some previous /\
      load_at Mint16signed memory (area1_object_pool_block addresses)
        (object_slot_offset slot) object_active_flags_offset = Some (Vint active) /\
      valid_area1_node_pointer addresses next /\
      (active <> Int.zero -> valid_area1_node_pointer addresses previous)) /\
  (forall list_index,
    (list_index < object_list_count)%nat ->
    exists next previous,
      load_at Mptr memory (area1_object_lists_storage_block addresses)
        (object_list_node_size * Z.of_nat list_index) object_next_offset = Some next /\
      load_at Mptr memory (area1_object_lists_storage_block addresses)
        (object_list_node_size * Z.of_nat list_index) object_previous_offset = Some previous /\
      valid_area1_node_pointer addresses next /\
      valid_area1_node_pointer addresses previous) /\
  exists free_next,
    load_at Mptr memory (area1_free_list_block addresses) 0
      object_next_offset = Some free_next /\
    valid_area1_node_pointer addresses free_next.

(** Pointer closure is intentionally weaker than full list ownership,
    reciprocal-link, uniqueness, and free/active partitioning.  This named
    proposition records the next concrete pool milestone without pretending
    the syntax census proves it. *)
Definition OrdinaryArea1ObjectPoolPointerClosureObligation
    (reachable_entry_memory : mem -> Area1EntryAddresses -> Prop) : Prop :=
  forall memory addresses,
    reachable_entry_memory memory addresses ->
    Area1ObjectPoolPointerClosure memory addresses.

(** * Still-open linked execution/refinement boundary *)

Definition USOrdinaryArea1EntryLiveMemoryRefinementObligation
    (linked_program : Clight.program) (continuation : Clight.cont)
    (memory_before memory_after : mem) (addresses : Area1EntryAddresses)
    (x y z : float32) (previous_down current_down : int) : Prop :=
  linkorder ULU.prog linked_program /\
  linkorder UM.prog linked_program /\
  linkorder UOL.prog linked_program /\
  linkorder UPD.prog linked_program /\
  linkorder USS.prog linked_program /\
  USArea1EntrySymbolBindings (Clight.globalenv linked_program) addresses /\
  OrdinaryArea1WarpRequestMemory memory_before addresses /\
  OrdinaryArea1ControllerHistoryMemory
    memory_before addresses previous_down current_down /\
  frame_has_no_a_press
    {| frame_previous_down := previous_down;
       frame_current_down := current_down |} /\
  exists trace,
    @Smallstep.star _ _ Clight.step2
      (Clight.globalenv linked_program)
      (Clight.Callstate
        (Ctypes.Internal ULU.f_warp_level) [] continuation memory_before)
      trace
      (Clight.Returnstate Vundef continuation memory_after) /\
    USArea1EntryMemoryPostcondition memory_after addresses x y z
      (entry_sample_from_history previous_down current_down).

Definition JPOrdinaryArea1EntryLiveMemoryRefinementObligation
    (linked_program : Clight.program) (continuation : Clight.cont)
    (memory_before memory_after : mem) (addresses : Area1EntryAddresses)
    (x y z : float32) (previous_down current_down : int) : Prop :=
  linkorder JLU.prog linked_program /\
  linkorder JM.prog linked_program /\
  linkorder JOL.prog linked_program /\
  linkorder JPD.prog linked_program /\
  linkorder JSS.prog linked_program /\
  JPArea1EntrySymbolBindings (Clight.globalenv linked_program) addresses /\
  OrdinaryArea1WarpRequestMemory memory_before addresses /\
  OrdinaryArea1ControllerHistoryMemory
    memory_before addresses previous_down current_down /\
  frame_has_no_a_press
    {| frame_previous_down := previous_down;
       frame_current_down := current_down |} /\
  exists trace,
    @Smallstep.star _ _ Clight.step2
      (Clight.globalenv linked_program)
      (Clight.Callstate
        (Ctypes.Internal JLU.f_warp_level) [] continuation memory_before)
      trace
      (Clight.Returnstate Vundef continuation memory_after) /\
    JPArea1EntryMemoryPostcondition
      memory_before memory_after addresses x y z
      (entry_sample_from_history previous_down current_down).

(** The first proposition connects the castle painting/level-script execution
    to the [warp_level] precondition above.  The second discharges frame facts
    for any still-external camera, audio, surface, save, graph, and allocation
    calls that occur before the observed return state.  Neither proposition is
    assumed by a theorem in this file. *)
Definition CastlePaintingToSSLArea1RoutingObligation
    (castle_to_ssl_entry : mem -> Area1EntryAddresses -> Prop) : Prop :=
  forall memory addresses,
    castle_to_ssl_entry memory addresses ->
    OrdinaryArea1WarpRequestMemory memory addresses.

Definition OrdinaryArea1EntryExternalFrameObligation
    (relevant_entry_location : block -> Z -> Prop)
    (external_step : mem -> mem -> Prop) : Prop :=
  forall memory_before memory_after block offset chunk value,
    external_step memory_before memory_after ->
    relevant_entry_location block offset ->
    Mem.load chunk memory_before block offset = Some value ->
    Mem.load chunk memory_after block offset = Some value.

(** This is the exact proved boundary: generated source/data plus consequences
    of the explicit memory postcondition.  It does not assert that a retail
    execution reaches that postcondition. *)
Definition OrdinaryArea1EntryCheckedBoundary : Prop :=
  OrdinaryArea1EntrySourceKernel /\
  (forall memory addresses x y z sample,
    OrdinaryArea1EntryMemoryPostcondition memory addresses x y z sample ->
    load_at Mfloat32 memory (area1_object_pool_block addresses)
      (mario_object_base addresses) (mario_object_raw_position_offset + 4) =
    load_at Mfloat32 memory (area1_object_pool_block addresses)
      (mario_object_base addresses)
      (mario_object_graphics_position_offset + 4)) /\
  entry_sample_has_no_a_edge
    (entry_sample_from_history a_button_mask a_button_mask).

Theorem ordinary_area1_entry_checked_boundary_holds :
  OrdinaryArea1EntryCheckedBoundary.
Proof.
  unfold OrdinaryArea1EntryCheckedBoundary.
  split; [exact ordinary_area1_entry_source_kernel_checked |].
  split; [exact ordinary_area1_entry_memory_synchronizes_raw_and_graphics_y |].
  exact (proj1 ordinary_entry_contract_permits_held_a).
Qed.
