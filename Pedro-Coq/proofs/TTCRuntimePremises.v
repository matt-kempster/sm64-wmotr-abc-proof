From Coq Require Import Bool Lia List PeanoNat PArith.BinPos ZArith.
From compcert Require Import AST Clight Ctypes Clightdefs.
From Pedro.Generated Require Import
  us_area us_macro_special_objects us_object_helpers us_object_list_processor
  us_spawn_object us_surface_load us_ttc_area1_macro us_ttc_level_script
  jp_area jp_macro_special_objects jp_object_helpers jp_object_list_processor
  jp_spawn_object jp_surface_load jp_ttc_area1_macro jp_ttc_level_script.
From Pedro.Proofs Require Import ASTFacts DustPool GameTypes.

Import ListNotations.

Module UArea := us_area.
Module UMacroSpawner := us_macro_special_objects.
Module UObjectHelpers := us_object_helpers.
Module UObjectLists := us_object_list_processor.
Module USpawn := us_spawn_object.
Module USurfaceLoad := us_surface_load.
Module UTTCMacro := us_ttc_area1_macro.
Module UTTCLevel := us_ttc_level_script.

Module JArea := jp_area.
Module JMacroSpawner := jp_macro_special_objects.
Module JObjectHelpers := jp_object_helpers.
Module JObjectLists := jp_object_list_processor.
Module JSpawn := jp_spawn_object.
Module JSurfaceLoad := jp_surface_load.
Module JTTCMacro := jp_ttc_area1_macro.
Module JTTCLevel := jp_ttc_level_script.

Definition initializer_addrof_count
    (needle : ident) (values : list init_data) : nat :=
  count_occ Pos.eq_dec (initializer_addrof_idents values) needle.

(** A macro record is five signed halfwords.  [chunks5] deliberately ignores
    the final [-1] terminator rather than treating it as an object. *)
Definition ttc_macro_descriptor_count (version : GameVersion) : nat :=
  match version with
  | VersionUS =>
      length (chunks5
        (init_int16_values (gvar_init UTTCMacro.v_ttc_seg7_macro_objs)))
  | VersionJP =>
      length (chunks5
        (init_int16_values (gvar_init JTTCMacro.v_ttc_seg7_macro_objs)))
  end.

(** The area descriptor count includes the entry warp, pole, thwomp, five
    ordinary stars, and the hidden-red-coin-star controller.  Mario's distinct
    descriptor is counted separately below because [load_mario_area] submits
    it to [spawn_objects_from_info] after [load_area]. *)
Definition ttc_area_object_descriptor_count (version : GameVersion) : nat :=
  match version with
  | VersionUS =>
      initializer_addrof_count UTTCLevel._bhvSpinAirborneWarp
        (gvar_init UTTCLevel.v_level_ttc_entry) +
      initializer_addrof_count UTTCLevel._bhvPoleGrabbing
        (gvar_init UTTCLevel.v_script_func_local_1) +
      initializer_addrof_count UTTCLevel._bhvThwomp
        (gvar_init UTTCLevel.v_script_func_local_1) +
      initializer_addrof_count UTTCLevel._bhvStar
        (gvar_init UTTCLevel.v_script_func_local_2) +
      initializer_addrof_count UTTCLevel._bhvHiddenRedCoinStar
        (gvar_init UTTCLevel.v_script_func_local_2)
  | VersionJP =>
      initializer_addrof_count JTTCLevel._bhvSpinAirborneWarp
        (gvar_init JTTCLevel.v_level_ttc_entry) +
      initializer_addrof_count JTTCLevel._bhvPoleGrabbing
        (gvar_init JTTCLevel.v_script_func_local_1) +
      initializer_addrof_count JTTCLevel._bhvThwomp
        (gvar_init JTTCLevel.v_script_func_local_1) +
      initializer_addrof_count JTTCLevel._bhvStar
        (gvar_init JTTCLevel.v_script_func_local_2) +
      initializer_addrof_count JTTCLevel._bhvHiddenRedCoinStar
        (gvar_init JTTCLevel.v_script_func_local_2)
  end.

Definition ttc_mario_descriptor_count (version : GameVersion) : nat :=
  match version with
  | VersionUS =>
      initializer_addrof_count UTTCLevel._bhvMario
        (gvar_init UTTCLevel.v_level_ttc_entry)
  | VersionJP =>
      initializer_addrof_count JTTCLevel._bhvMario
        (gvar_init JTTCLevel.v_level_ttc_entry)
  end.

Definition ttc_fresh_load_descriptor_count (version : GameVersion) : nat :=
  (ttc_macro_descriptor_count version +
   ttc_area_object_descriptor_count version +
   ttc_mario_descriptor_count version)%nat.

(** This is capacity minus the source inventory, not a claim about a live
    object pool.  Act/respawn filtering can omit descriptors, while proving
    that no other loader path allocates an object requires interpreter
    execution which is not supplied here. *)
Definition ttc_fresh_inventory_headroom (version : GameVersion) : nat :=
  (240 - ttc_fresh_load_descriptor_count version)%nat.

(** This receipt ties the generated TTC data to the generated loader/allocation
    call chain.  It is a source-reduction theorem: it does not execute the
    level-script interpreter, convert all descriptors into simultaneous live
    allocations, or prove that an arbitrary later game state has this budget.
    The entry's two common scripts contain model-loading commands in the pinned
    source, but their interpreter execution is outside this receipt. *)
Definition ttc_fresh_load_source_receipt (version : GameVersion) : Prop :=
  match version with
  | VersionUS =>
      gvar_info UTTCMacro.v_ttc_seg7_macro_objs = tarray tshort 551 /\
      ttc_macro_descriptor_count VersionUS = 110%nat /\
      initializer_addrof_count UTTCLevel._bhvSpinAirborneWarp
        (gvar_init UTTCLevel.v_level_ttc_entry) = 1%nat /\
      initializer_addrof_count UTTCLevel._bhvPoleGrabbing
        (gvar_init UTTCLevel.v_script_func_local_1) = 1%nat /\
      initializer_addrof_count UTTCLevel._bhvThwomp
        (gvar_init UTTCLevel.v_script_func_local_1) = 1%nat /\
      initializer_addrof_count UTTCLevel._bhvStar
        (gvar_init UTTCLevel.v_script_func_local_2) = 5%nat /\
      initializer_addrof_count UTTCLevel._bhvHiddenRedCoinStar
        (gvar_init UTTCLevel.v_script_func_local_2) = 1%nat /\
      initializer_addrof_count UTTCLevel._bhvMario
        (gvar_init UTTCLevel.v_level_ttc_entry) = 1%nat /\
      calls_ident_s UArea._load_area_terrain
        (fn_body UArea.f_load_area) = true /\
      calls_ident_s UArea._spawn_objects_from_info
        (fn_body UArea.f_load_area) = true /\
      calls_ident_s UArea._load_area
        (fn_body UArea.f_load_mario_area) = true /\
      calls_ident_s UArea._spawn_objects_from_info
        (fn_body UArea.f_load_mario_area) = true /\
      calls_ident_s USurfaceLoad._spawn_macro_objects
        (fn_body USurfaceLoad.f_load_area_terrain) = true /\
      calls_ident_s UMacroSpawner._spawn_object_abs_with_rot
        (fn_body UMacroSpawner.f_spawn_macro_objects) = true /\
      calls_ident_s UObjectHelpers._spawn_object_at_origin
        (fn_body UObjectHelpers.f_spawn_object_abs_with_rot) = true /\
      calls_ident_s UObjectHelpers._create_object
        (fn_body UObjectHelpers.f_spawn_object_at_origin) = true /\
      calls_ident_s UObjectLists._create_object
        (fn_body UObjectLists.f_spawn_objects_from_info) = true /\
      calls_ident_s USpawn._allocate_object
        (fn_body USpawn.f_create_object) = true /\
      dust_pool_source_receipt VersionUS
  | VersionJP =>
      gvar_info JTTCMacro.v_ttc_seg7_macro_objs = tarray tshort 551 /\
      ttc_macro_descriptor_count VersionJP = 110%nat /\
      initializer_addrof_count JTTCLevel._bhvSpinAirborneWarp
        (gvar_init JTTCLevel.v_level_ttc_entry) = 1%nat /\
      initializer_addrof_count JTTCLevel._bhvPoleGrabbing
        (gvar_init JTTCLevel.v_script_func_local_1) = 1%nat /\
      initializer_addrof_count JTTCLevel._bhvThwomp
        (gvar_init JTTCLevel.v_script_func_local_1) = 1%nat /\
      initializer_addrof_count JTTCLevel._bhvStar
        (gvar_init JTTCLevel.v_script_func_local_2) = 5%nat /\
      initializer_addrof_count JTTCLevel._bhvHiddenRedCoinStar
        (gvar_init JTTCLevel.v_script_func_local_2) = 1%nat /\
      initializer_addrof_count JTTCLevel._bhvMario
        (gvar_init JTTCLevel.v_level_ttc_entry) = 1%nat /\
      calls_ident_s JArea._load_area_terrain
        (fn_body JArea.f_load_area) = true /\
      calls_ident_s JArea._spawn_objects_from_info
        (fn_body JArea.f_load_area) = true /\
      calls_ident_s JArea._load_area
        (fn_body JArea.f_load_mario_area) = true /\
      calls_ident_s JArea._spawn_objects_from_info
        (fn_body JArea.f_load_mario_area) = true /\
      calls_ident_s JSurfaceLoad._spawn_macro_objects
        (fn_body JSurfaceLoad.f_load_area_terrain) = true /\
      calls_ident_s JMacroSpawner._spawn_object_abs_with_rot
        (fn_body JMacroSpawner.f_spawn_macro_objects) = true /\
      calls_ident_s JObjectHelpers._spawn_object_at_origin
        (fn_body JObjectHelpers.f_spawn_object_abs_with_rot) = true /\
      calls_ident_s JObjectHelpers._create_object
        (fn_body JObjectHelpers.f_spawn_object_at_origin) = true /\
      calls_ident_s JObjectLists._create_object
        (fn_body JObjectLists.f_spawn_objects_from_info) = true /\
      calls_ident_s JSpawn._allocate_object
        (fn_body JSpawn.f_create_object) = true /\
      dust_pool_source_receipt VersionJP
  end.

Theorem ttc_fresh_load_source_receipt_us :
  ttc_fresh_load_source_receipt VersionUS.
Proof.
  unfold ttc_fresh_load_source_receipt.
  vm_compute.
  repeat split; reflexivity.
Qed.

Theorem ttc_fresh_load_source_receipt_jp :
  ttc_fresh_load_source_receipt VersionJP.
Proof.
  unfold ttc_fresh_load_source_receipt.
  vm_compute.
  repeat split; reflexivity.
Qed.

Theorem ttc_fresh_load_source_receipt_supported :
  forall version, ttc_fresh_load_source_receipt version.
Proof.
  intros []; [exact ttc_fresh_load_source_receipt_us |
              exact ttc_fresh_load_source_receipt_jp].
Qed.

Theorem ttc_fresh_load_descriptor_budget_supported :
  forall version,
    ttc_macro_descriptor_count version = 110%nat /\
    ttc_area_object_descriptor_count version = 9%nat /\
    ttc_mario_descriptor_count version = 1%nat /\
    ttc_fresh_load_descriptor_count version = 120%nat /\
    ttc_fresh_inventory_headroom version = 120%nat.
Proof.
  intros []; vm_compute; repeat split; reflexivity.
Qed.

Theorem ttc_fresh_inventory_has_nominal_dust_headroom :
  forall version,
    3 <= ttc_fresh_inventory_headroom version /\
    (ttc_fresh_inventory_headroom version - 3 = 117)%nat.
Proof.
  intros version.
  destruct (ttc_fresh_load_descriptor_budget_supported version)
    as [_ [_ [_ [_ Hfree]]]].
  rewrite Hfree.
  lia.
Qed.

(** A future loader execution can instantiate [actual_base_allocations].
    Descriptor filtering only decreases that number; this theorem deliberately
    leaves the no-additional-loader-allocation premise explicit. *)
Theorem ttc_fresh_inventory_bounds_runtime_base_allocations :
  forall version actual_base_allocations,
    actual_base_allocations <= ttc_fresh_load_descriptor_count version ->
    120 <= 240 - actual_base_allocations.
Proof.
  intros version actual_base_allocations Hbound.
  destruct (ttc_fresh_load_descriptor_budget_supported version)
    as [_ [_ [_ [Hcount _]]]].
  rewrite Hcount in Hbound.
  lia.
Qed.

(** Once a future loader-execution certificate instantiates the nominal
    120-slot inventory headroom, a later execution certificate that counts at
    most 117 competing live important-list objects leaves three slots.  This
    theorem does not assert either runtime premise for any route; it exposes
    the exact arithmetic residual a trace or Clight execution proof must
    discharge. *)
Theorem ttc_inventory_headroom_reduction_for_later_competitors :
  forall competing_important,
    competing_important <= 117 ->
    3 <= 120 - competing_important.
Proof. intros; lia. Qed.

(** A small boundary-state model for active dust bit zero.  The accepted path
    mirrors the checked PLAYER guard/OR-set followed by the checked DEFAULT
    parent-bit clear.  An already-set request is rejected and remains set.
    Refinement of a complete retail frame to this model remains separate. *)
Record ActiveDustFrameReduction : Type := {
  dust_bit_at_player_entry : bool;
  frame_dust_request_accepted : bool;
  dust_bit_after_player : bool;
  dust_bit_after_default : bool
}.

Definition reduce_normal_dust_frame
    (before requested : bool) : ActiveDustFrameReduction :=
  let accepted := requested && negb before in
  let after_player := before || accepted in
  {| dust_bit_at_player_entry := before;
     frame_dust_request_accepted := accepted;
     dust_bit_after_player := after_player;
     dust_bit_after_default := if accepted then false else after_player |}.

Theorem normal_frame_reduction_preserves_clear_dust_bit :
  forall requested,
    dust_bit_at_player_entry (reduce_normal_dust_frame false requested) = false /\
    dust_bit_after_default (reduce_normal_dust_frame false requested) = false.
Proof. intros []; vm_compute; split; reflexivity. Qed.

Fixpoint reduce_normal_dust_frames
    (requests : list bool) (bit : bool) : bool :=
  match requests with
  | [] => bit
  | requested :: rest =>
      reduce_normal_dust_frames rest
        (dust_bit_after_default (reduce_normal_dust_frame bit requested))
  end.

Theorem normal_frame_reduction_keeps_fresh_dust_bit_clear :
  forall requests,
    reduce_normal_dust_frames requests false = false.
Proof.
  induction requests as [|requested rest IH]; simpl; [reflexivity|].
  destruct requested; simpl; exact IH.
Qed.

(** The combined result is intentionally a reduction, not the missing
    reachable-tap theorem: source receipts justify the fresh boundary and
    normal-frame model, while a future route proof must establish normal-time
    refinement and bound all competing important allocations at the tap. *)
Definition ttc_fresh_runtime_premise_reduction_claim : Prop :=
  (forall version, ttc_fresh_load_source_receipt version) /\
  (forall version, ttc_fresh_load_descriptor_count version = 120%nat) /\
  (forall version, ttc_fresh_inventory_headroom version = 120%nat) /\
  (forall requests, reduce_normal_dust_frames requests false = false).

Theorem checked_ttc_fresh_runtime_premise_reduction_us_jp :
  ttc_fresh_runtime_premise_reduction_claim.
Proof.
  unfold ttc_fresh_runtime_premise_reduction_claim.
  repeat split.
  - exact ttc_fresh_load_source_receipt_supported.
  - intro version.
    destruct (ttc_fresh_load_descriptor_budget_supported version)
      as [_ [_ [_ [Hcount _]]]].
    exact Hcount.
  - intro version.
    destruct (ttc_fresh_load_descriptor_budget_supported version)
      as [_ [_ [_ [_ Hfree]]]].
    exact Hfree.
  - exact normal_frame_reduction_keeps_fresh_dust_bit_clear.
Qed.
