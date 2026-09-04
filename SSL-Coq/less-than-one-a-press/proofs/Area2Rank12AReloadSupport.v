(** Rank 12A: warp destination, reload, and support-refresh boundary.

    This file separates four facts which had previously been bundled into one
    open atlas sentence.

    - The Area-1 upper entrance names SSL Area 2, node 0x14, and the Area-2
      level script contains that exact airborne-warp object.
    - The two Area-2/Area-3 instant-warp descriptors have zero X/Z
      displacement.
    - In each generated level-update translation unit, [sWarpDest] is a
      private eight-byte object.  [initiate_warp] is its only direct writer for
      level, area, node, and argument.  The type byte is additionally cleared
      after Mario initialization, on the credits path, and by
      [lvl_init_from_save_file].  This is a root-sensitive census, unlike a
      scan for every struct field with the same name.
    - A ROM-hash-gated original-JP machine receipt supplies an exact
      same-position support-refresh witness: the Area-3 floor address
      0x80192630 is replaced by Area 2's 0x8019DAF0 while both owners and
      [gMarioPlatform] are null.  The receipt's platform-injection switch is
      off, but its harness staged Mario's position/action and earlier wrote a
      warp destination, so it is evidence for the engine mechanism rather
      than a clean controller route.

    The direct-writer census does not rule out a type-punned in-bounds alias,
    and the source call graph is not itself a Clight execution or a complete
    frame theorem for [load_area].  Those universal linked-execution duties
    remain open.  The exact changed-support alternative requested by Rank 12A,
    however, is now inhabited and is visibly harmless in this receipt: it
    adds no logged displacement and selects no object-owned support. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Ctypes Integers.
From LessThanOneAPress.Generated Require Import
  us_level_update jp_level_update us_ssl_script jp_ssl_script
  us_area jp_area us_surface_load jp_surface_load.
From LessThanOneAPress.Proofs Require Import
  ASTFacts ClightFacts Area1PlatformExhaustiveness
  UpperElevatorWingCapTransitionClosure JPSlotLifetime.

Import ListNotations.
Local Open Scope Z_scope.

Module R12A_ULevel := us_level_update.
Module R12A_JLevel := jp_level_update.
Module R12A_USSL := us_ssl_script.
Module R12A_JSSL := jp_ssl_script.
Module R12A_UArea := us_area.
Module R12A_JArea := jp_area.
Module R12A_USurfaceLoad := us_surface_load.
Module R12A_JSurfaceLoad := jp_surface_load.

(** * Root-sensitive destination-writer census *)

Definition rank12a_lhs_is_global_field
    (root field : ident) (lhs : expr) : bool :=
  match lhs with
  | Efield (Evar found_root _) found_field _ =>
      Pos.eqb found_root root && Pos.eqb found_field field
  | _ => false
  end.

Fixpoint rank12a_assigns_global_field_s
    (root field : ident) (body : statement) : bool :=
  match body with
  | Sassign lhs _ => rank12a_lhs_is_global_field root field lhs
  | Ssequence first second | Sloop first second =>
      rank12a_assigns_global_field_s root field first ||
      rank12a_assigns_global_field_s root field second
  | Sifthenelse _ yes_branch no_branch =>
      rank12a_assigns_global_field_s root field yes_branch ||
      rank12a_assigns_global_field_s root field no_branch
  | Sswitch _ cases => rank12a_assigns_global_field_ls root field cases
  | Slabel _ nested => rank12a_assigns_global_field_s root field nested
  | _ => false
  end
with rank12a_assigns_global_field_ls
    (root field : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      rank12a_assigns_global_field_s root field body ||
      rank12a_assigns_global_field_ls root field rest
  end.

Fixpoint rank12a_internal_global_field_writer_sites
    (root field : ident)
    (definitions : list (ident * globdef (fundef function) type)) :
    list ident :=
  match definitions with
  | [] => []
  | (id, Gfun (Internal body)) :: rest =>
      if rank12a_assigns_global_field_s root field (fn_body body)
      then id :: rank12a_internal_global_field_writer_sites root field rest
      else rank12a_internal_global_field_writer_sites root field rest
  | _ :: rest => rank12a_internal_global_field_writer_sites root field rest
  end.

Definition rank12a_us_destination_writer_sites (field : ident) : list ident :=
  rank12a_internal_global_field_writer_sites
    R12A_ULevel._sWarpDest field (prog_defs R12A_ULevel.prog).

Definition rank12a_jp_destination_writer_sites (field : ident) : list ident :=
  rank12a_internal_global_field_writer_sites
    R12A_JLevel._sWarpDest field (prog_defs R12A_JLevel.prog).

Definition Rank12AWarpDestinationDirectWriterCensus : Prop :=
  gvar_init R12A_ULevel.v_sWarpDest = [Init_space 8] /\
  gvar_readonly R12A_ULevel.v_sWarpDest = false /\
  gvar_init R12A_JLevel.v_sWarpDest = [Init_space 8] /\
  gvar_readonly R12A_JLevel.v_sWarpDest = false /\
  rank12a_us_destination_writer_sites R12A_ULevel._type =
    [R12A_ULevel._init_mario_after_warp; R12A_ULevel._warp_credits;
     R12A_ULevel._initiate_warp; R12A_ULevel._lvl_init_from_save_file] /\
  rank12a_jp_destination_writer_sites R12A_JLevel._type =
    [R12A_JLevel._init_mario_after_warp; R12A_JLevel._warp_credits;
     R12A_JLevel._initiate_warp; R12A_JLevel._lvl_init_from_save_file] /\
  rank12a_us_destination_writer_sites R12A_ULevel._levelNum =
    [R12A_ULevel._initiate_warp] /\
  rank12a_jp_destination_writer_sites R12A_JLevel._levelNum =
    [R12A_JLevel._initiate_warp] /\
  rank12a_us_destination_writer_sites R12A_ULevel._areaIdx =
    [R12A_ULevel._initiate_warp] /\
  rank12a_jp_destination_writer_sites R12A_JLevel._areaIdx =
    [R12A_JLevel._initiate_warp] /\
  rank12a_us_destination_writer_sites R12A_ULevel._nodeId =
    [R12A_ULevel._initiate_warp] /\
  rank12a_jp_destination_writer_sites R12A_JLevel._nodeId =
    [R12A_JLevel._initiate_warp] /\
  rank12a_us_destination_writer_sites R12A_ULevel._arg =
    [R12A_ULevel._initiate_warp] /\
  rank12a_jp_destination_writer_sites R12A_JLevel._arg =
    [R12A_JLevel._initiate_warp].

Theorem rank12a_warp_destination_direct_writer_census_checked :
  Rank12AWarpDestinationDirectWriterCensus.
Proof.
  unfold Rank12AWarpDestinationDirectWriterCensus,
    rank12a_us_destination_writer_sites,
    rank12a_jp_destination_writer_sites.
  vm_compute. repeat split; reflexivity.
Qed.

(** * Exact route, entry, and zero-displacement script records *)

Definition rank12a_upper_entry_record_us : list init_data :=
  firstn 6 (skipn 116 (gvar_init R12A_USSL.v_level_ssl_entry)).

Definition rank12a_upper_entry_record_jp : list init_data :=
  firstn 6 (skipn 116 (gvar_init R12A_JSSL.v_level_ssl_entry)).

Definition rank12a_expected_upper_entry_record_us : list init_data :=
  [ Init_int32 (Int.repr 605560576);
    Init_int32 (Int.repr 5500);
    Init_int32 (Int.repr 16777216);
    Init_int32 (Int.repr 11796480);
    Init_int32 (Int.repr 1310720);
    Init_addrof R12A_USSL._bhvAirborneWarp (Ptrofs.repr 0) ].

Definition rank12a_expected_upper_entry_record_jp : list init_data :=
  [ Init_int32 (Int.repr 605560576);
    Init_int32 (Int.repr 5500);
    Init_int32 (Int.repr 16777216);
    Init_int32 (Int.repr 11796480);
    Init_int32 (Int.repr 1310720);
    Init_addrof R12A_JSSL._bhvAirborneWarp (Ptrofs.repr 0) ].

Definition rank12a_area2_instant_warp_us : list init_data :=
  firstn 3 (skipn 150 (gvar_init R12A_USSL.v_level_ssl_entry)).

Definition rank12a_area2_instant_warp_jp : list init_data :=
  firstn 3 (skipn 150 (gvar_init R12A_JSSL.v_level_ssl_entry)).

Definition rank12a_area3_instant_warp_us : list init_data :=
  firstn 3 (skipn 173 (gvar_init R12A_USSL.v_level_ssl_entry)).

Definition rank12a_area3_instant_warp_jp : list init_data :=
  firstn 3 (skipn 173 (gvar_init R12A_JSSL.v_level_ssl_entry)).

Definition rank12a_expected_area2_instant_warp : list init_data :=
  [Init_int32 (Int.repr 671875843); (* 0x280c0303: index 3 -> area 3 *)
   Init_int32 Int.zero; Init_int32 Int.zero].

Definition rank12a_expected_area3_instant_warp : list init_data :=
  [Init_int32 (Int.repr 671875586); (* 0x280c0202: index 2 -> area 2 *)
   Init_int32 Int.zero; Init_int32 Int.zero].

Definition Rank12AScriptDestinationAndEntry : Prop :=
  area1_stock_warp_route_words =
    [ Init_int32 (Int.repr 638061064);
      Init_int32 (Int.repr 17432576);
      Init_int32 (Int.repr 638063624);
      Init_int32 (Int.repr 34242560);
      Init_int32 (Int.repr 638066184);
      Init_int32 (Int.repr 34897920);
      Init_int32 (Int.repr 638066440);
      Init_int32 (Int.repr 18874368);
      Init_int32 (Int.repr 638066696);
      Init_int32 (Int.repr 18808832) ] /\
  rank12a_upper_entry_record_us = rank12a_expected_upper_entry_record_us /\
  rank12a_upper_entry_record_jp = rank12a_expected_upper_entry_record_jp /\
  rank12a_area2_instant_warp_us = rank12a_expected_area2_instant_warp /\
  rank12a_area2_instant_warp_jp = rank12a_expected_area2_instant_warp /\
  rank12a_area3_instant_warp_us = rank12a_expected_area3_instant_warp /\
  rank12a_area3_instant_warp_jp = rank12a_expected_area3_instant_warp /\
  671875843 = 40 * 16777216 + 12 * 65536 + 3 * 256 + 3 /\
  671875586 = 40 * 16777216 + 12 * 65536 + 2 * 256 + 2 /\
  1310720 = 20 * 65536 /\
  11796480 = 180 * 65536 /\
  16777216 = 256 * 65536.

Theorem rank12a_script_destination_and_entry_checked :
  Rank12AScriptDestinationAndEntry.
Proof.
  unfold Rank12AScriptDestinationAndEntry,
    rank12a_upper_entry_record_us, rank12a_upper_entry_record_jp,
    rank12a_expected_upper_entry_record_us,
    rank12a_expected_upper_entry_record_jp,
    rank12a_area2_instant_warp_us, rank12a_area2_instant_warp_jp,
    rank12a_area3_instant_warp_us, rank12a_area3_instant_warp_jp,
    rank12a_expected_area2_instant_warp,
    rank12a_expected_area3_instant_warp.
  vm_compute. repeat split; reflexivity.
Qed.

(** [warp_area] handles a normal area transition; [check_instant_warp]
    handles the zero-offset Area-2/Area-3 pair.  In both versions the area
    loader rebuilds terrain before spawning area objects and reconstructing
    warp-node links.  These are exact source-call anchors, not an effect
    theorem for arbitrary Clight memories. *)
Definition Rank12AAreaLoadSourceShape : Prop :=
  upper_entry_transition_source_claim /\
  ident_subsequenceb
    [R12A_UArea._load_area_terrain; R12A_UArea._spawn_objects_from_info;
     R12A_UArea._load_obj_warp_nodes;
     R12A_UArea._geo_call_global_function_nodes]
    (direct_callees_s (fn_body R12A_UArea.f_load_area)) = true /\
  ident_subsequenceb
    [R12A_JArea._load_area_terrain; R12A_JArea._spawn_objects_from_info;
     R12A_JArea._load_obj_warp_nodes;
     R12A_JArea._geo_call_global_function_nodes]
    (direct_callees_s (fn_body R12A_JArea.f_load_area)) = true /\
  calls_ident_s R12A_USurfaceLoad._clear_static_surfaces
    (fn_body R12A_USurfaceLoad.f_load_area_terrain) = true /\
  calls_ident_s R12A_JSurfaceLoad._clear_static_surfaces
    (fn_body R12A_JSurfaceLoad.f_load_area_terrain) = true /\
  calls_ident_s R12A_USurfaceLoad._load_static_surfaces
    (fn_body R12A_USurfaceLoad.f_load_area_terrain) = true /\
  calls_ident_s R12A_JSurfaceLoad._load_static_surfaces
    (fn_body R12A_JSurfaceLoad.f_load_area_terrain) = true /\
  calls_ident_s R12A_USurfaceLoad._spawn_special_objects
    (fn_body R12A_USurfaceLoad.f_load_area_terrain) = true /\
  calls_ident_s R12A_JSurfaceLoad._spawn_special_objects
    (fn_body R12A_JSurfaceLoad.f_load_area_terrain) = true /\
  calls_ident_s R12A_USurfaceLoad._spawn_macro_objects_hardcoded
    (fn_body R12A_USurfaceLoad.f_load_area_terrain) = true /\
  calls_ident_s R12A_JSurfaceLoad._spawn_macro_objects_hardcoded
    (fn_body R12A_JSurfaceLoad.f_load_area_terrain) = true /\
  calls_ident_s R12A_USurfaceLoad._spawn_macro_objects
    (fn_body R12A_USurfaceLoad.f_load_area_terrain) = true /\
  calls_ident_s R12A_JSurfaceLoad._spawn_macro_objects
    (fn_body R12A_JSurfaceLoad.f_load_area_terrain) = true /\
  calls_ident_s R12A_ULevel._change_area
    (fn_body R12A_ULevel.f_check_instant_warp) = true /\
  calls_ident_s R12A_UArea._unload_area
    (fn_body R12A_UArea.f_change_area) = true /\
  calls_ident_s R12A_UArea._load_area
    (fn_body R12A_UArea.f_change_area) = true /\
  calls_ident_s R12A_JLevel._change_area
    (fn_body R12A_JLevel.f_check_instant_warp) = true /\
  calls_ident_s R12A_JArea._unload_area
    (fn_body R12A_JArea.f_change_area) = true /\
  calls_ident_s R12A_JArea._load_area
    (fn_body R12A_JArea.f_change_area) = true /\
  mario_entry_coordinate_sync_source_shape_us_claim /\
  mario_entry_coordinate_sync_source_shape_jp_claim.

Theorem rank12a_area_load_source_shape_checked :
  Rank12AAreaLoadSourceShape.
Proof.
  unfold Rank12AAreaLoadSourceShape.
  split; [exact upper_entry_transition_source_checked |].
  vm_compute. repeat split; reflexivity.
Qed.

(** * Exact observed changed-support witness *)

(** The natural case is lines 1--5 of
    [old-proofs/eyerok-manipulation/instrumentation/results/
     jp_platform_trace.txt].  Addresses are recorded as unsigned 32-bit
    integers; positions below are the receipt's three-decimal display units. *)
Definition rank12a_receipt_before_timer : Z := 365.
Definition rank12a_receipt_after_timer : Z := 366.
Definition rank12a_receipt_before_area : Z := 3.
Definition rank12a_receipt_after_area : Z := 2.
Definition rank12a_receipt_before_floor : Z := 2149131824. (* 0x80192630 *)
Definition rank12a_receipt_after_floor : Z := 2149178096.  (* 0x8019daf0 *)
Definition rank12a_receipt_before_floor_type : Z := 29.
Definition rank12a_receipt_after_floor_type : Z := 29.
Definition rank12a_receipt_before_floor_owner : Z := 0.
Definition rank12a_receipt_after_floor_owner : Z := 0.
Definition rank12a_receipt_before_platform : Z := 0.
Definition rank12a_receipt_after_platform : Z := 0.
Definition rank12a_receipt_position_milli : list Z := [0; 346080; -1100000].
Definition rank12a_receipt_logged_delta_milli : list Z := [0; 0; 0].
Definition rank12a_receipt_platform_injection_enabled : bool := false.
(** The harness stages position/action and earlier writes a warp destination. *)
Definition rank12a_receipt_is_clean_controller_run : bool := false.

Definition Rank12AChangedSupportReceipt : Prop :=
  rank12a_receipt_before_timer = 365 /\
  rank12a_receipt_after_timer = 366 /\
  rank12a_receipt_before_area = 3 /\
  rank12a_receipt_after_area = 2 /\
  rank12a_receipt_before_floor = 2149131824 /\
  rank12a_receipt_after_floor = 2149178096 /\
  rank12a_receipt_before_floor <> rank12a_receipt_after_floor /\
  rank12a_receipt_before_floor_type = 29 /\
  rank12a_receipt_after_floor_type = 29 /\
  rank12a_receipt_before_floor_owner = 0 /\
  rank12a_receipt_after_floor_owner = 0 /\
  rank12a_receipt_before_platform = 0 /\
  rank12a_receipt_after_platform = 0 /\
  rank12a_receipt_position_milli = [0; 346080; -1100000] /\
  rank12a_receipt_logged_delta_milli = [0; 0; 0] /\
  rank12a_receipt_platform_injection_enabled = false /\
  rank12a_receipt_is_clean_controller_run = false.

Theorem rank12a_changed_support_receipt_checked :
  Rank12AChangedSupportReceipt.
Proof.
  unfold Rank12AChangedSupportReceipt,
    rank12a_receipt_before_timer, rank12a_receipt_after_timer,
    rank12a_receipt_before_area, rank12a_receipt_after_area,
    rank12a_receipt_before_floor, rank12a_receipt_after_floor,
    rank12a_receipt_before_floor_type, rank12a_receipt_after_floor_type,
    rank12a_receipt_before_floor_owner, rank12a_receipt_after_floor_owner,
    rank12a_receipt_before_platform, rank12a_receipt_after_platform,
    rank12a_receipt_position_milli, rank12a_receipt_logged_delta_milli,
    rank12a_receipt_platform_injection_enabled,
    rank12a_receipt_is_clean_controller_run.
  repeat split; try reflexivity; lia.
Qed.

(** This existential is the exact alternative requested by the atlas: a
    support identity changes across the reload even though the receipt reports
    zero movement.  The null-owner/null-platform conjuncts also record why this
    particular witness supplies no moving-support displacement. *)
Theorem rank12a_exact_changed_support_witness_exists :
  exists before_floor after_floor,
    before_floor = 2149131824 /\
    after_floor = 2149178096 /\
    before_floor <> after_floor /\
    rank12a_receipt_logged_delta_milli = [0; 0; 0] /\
    rank12a_receipt_before_floor_owner = 0 /\
    rank12a_receipt_after_floor_owner = 0 /\
    rank12a_receipt_before_platform = 0 /\
    rank12a_receipt_after_platform = 0.
Proof.
  exists rank12a_receipt_before_floor, rank12a_receipt_after_floor.
  pose proof rank12a_changed_support_receipt_checked as H.
  unfold Rank12AChangedSupportReceipt in H.
  tauto.
Qed.

Definition Rank12ACheckedBoundary : Prop :=
  Rank12AWarpDestinationDirectWriterCensus /\
  Rank12AScriptDestinationAndEntry /\
  Rank12AAreaLoadSourceShape /\
  Rank12AChangedSupportReceipt /\
  (exists before_floor after_floor,
    before_floor = 2149131824 /\
    after_floor = 2149178096 /\
    before_floor <> after_floor /\
    rank12a_receipt_logged_delta_milli = [0; 0; 0] /\
    rank12a_receipt_before_floor_owner = 0 /\
    rank12a_receipt_after_floor_owner = 0 /\
    rank12a_receipt_before_platform = 0 /\
    rank12a_receipt_after_platform = 0).

Theorem rank12a_checked_boundary_holds : Rank12ACheckedBoundary.
Proof.
  unfold Rank12ACheckedBoundary.
  exact
    (conj rank12a_warp_destination_direct_writer_census_checked
      (conj rank12a_script_destination_and_entry_checked
        (conj rank12a_area_load_source_shape_checked
          (conj rank12a_changed_support_receipt_checked
            rank12a_exact_changed_support_witness_exists)))).
Qed.
