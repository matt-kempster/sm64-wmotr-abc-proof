(**
  Static SSL Area-1 linkage for the pre-player pole/tree push, plus a bounded
  audit of the related cylinder wrapper.

  The SSL exterior terrain's seven-special-object suffix contains palm preset
  125, whose generated special-preset record selects [bhvTree].  The packed-
  script audit attributes the two explicit [bhvPoleGrabbing] objects to a later
  subscript, rather than to the checked Area-1 local-1--3 regular-object
  inventory.  Proving that attribution through the LevelScript interpreter's
  area selection remains outside this static audit.

  [bhvTree] lives in POLELIKE list 10 and contains [bhv_pole_base_loop].
  [Area1PolePushSchedule] proves that list 10 precedes the PLAYER list and
  that a completed player copy resynchronizes X/Z.

  A manually derived list of behavior families associated with the cylinder
  wrapper is absent from the Area-1 regular-object and macro-object
  initializer data.  This module does not itself prove the callback census or
  callback-to-behavior mapping.  Its negative result therefore remains a
  bounded static-data check: it does not prove closed-world linked
  reachability, rule out behavior pointer corruption or spawned clones, or
  interpret every behavior command.
*)

From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Ctypes Integers.
From LessThanOneAPress.Generated Require Import
  us_behavior_data us_macro_special_objects us_ssl_area1_macro
  us_ssl_collision us_ssl_script
  jp_behavior_data jp_macro_special_objects jp_ssl_area1_macro
  jp_ssl_collision jp_ssl_script.
From LessThanOneAPress.Proofs Require Import
  ASTFacts Area1EntryDepthClosure Area1PolePushSchedule.

Import ListNotations.
Local Open Scope Z_scope.

Module A1PPL_USBD := us_behavior_data.
Module A1PPL_USMS := us_macro_special_objects.
Module A1PPL_USMacro := us_ssl_area1_macro.
Module A1PPL_USCollision := us_ssl_collision.
Module A1PPL_USScript := us_ssl_script.
Module A1PPL_JPBD := jp_behavior_data.
Module A1PPL_JPMS := jp_macro_special_objects.
Module A1PPL_JPMacro := jp_ssl_area1_macro.
Module A1PPL_JPCollision := jp_ssl_collision.
Module A1PPL_JPScript := jp_ssl_script.

(** The 36 halfwords beginning at index 4889 of the 4,945-halfword Area-1
    terrain initializer are the special-object section.  It declares seven
    objects; the final one is the no-yaw palm-tree preset 125 at
    (-5989, 0, -4850), followed by special-object end marker 68.  Later words
    encode the water-box section and the final terrain terminator. *)
Definition area1_palm_special_suffix : list Z :=
  [7;
   0; 653; 38; 6566; 64;
   101; 5760; 0; 5751; 0;
   101; -3583; 0; 2935; 0;
   101; -511; 0; 2935; 0;
   101; 1024; 0; 3822; 0;
   101; 3072; 0; 375; 0;
   125; -5989; 0; -4850;
   68].

Definition area1_palm_special_source_claim : Prop :=
  length (gvar_init A1PPL_USCollision.v_ssl_seg7_area_1_collision) =
    4945%nat /\
  firstn 36
    (skipn 4889
      (init_int16_values
        (gvar_init A1PPL_USCollision.v_ssl_seg7_area_1_collision))) =
      area1_palm_special_suffix /\
  length (gvar_init A1PPL_JPCollision.v_ssl_seg7_area_1_collision) =
    4945%nat /\
  firstn 36
    (skipn 4889
      (init_int16_values
        (gvar_init A1PPL_JPCollision.v_ssl_seg7_area_1_collision))) =
      area1_palm_special_suffix.

Theorem area1_palm_special_source_checked :
  area1_palm_special_source_claim.
Proof.
  unfold area1_palm_special_source_claim, area1_palm_special_suffix.
  vm_compute. repeat split; reflexivity.
Qed.

(** Special preset records contain five generated initializer fields.  The
    record beginning at initializer index 325 is preset 125 and names
    [bhvTree] in both retail versions. *)
Definition area1_palm_preset_us : list init_data :=
  [Init_int8 (Int.repr 125);
   Init_int8 (Int.repr 0);
   Init_int8 (Int.repr 0);
   Init_int8 (Int.repr 27);
   Init_addrof A1PPL_USMS._bhvTree (Ptrofs.repr 0)].

Definition area1_palm_preset_jp : list init_data :=
  [Init_int8 (Int.repr 125);
   Init_int8 (Int.repr 0);
   Init_int8 (Int.repr 0);
   Init_int8 (Int.repr 27);
   Init_addrof A1PPL_JPMS._bhvTree (Ptrofs.repr 0)].

Definition area1_palm_tree_behavior_source_claim : Prop :=
  firstn 5 (skipn 325
    (gvar_init A1PPL_USMS.v_sSpecialObjectPresets)) =
      area1_palm_preset_us /\
  firstn 5 (skipn 325
    (gvar_init A1PPL_JPMS.v_sSpecialObjectPresets)) =
      area1_palm_preset_jp /\
  hd_error (gvar_init A1PPL_USBD.v_bhvTree) =
    Some (Init_int32 (Int.repr 655360)) /\
  hd_error (gvar_init A1PPL_JPBD.v_bhvTree) =
    Some (Init_int32 (Int.repr 655360)) /\
  initializer_list_mentions_addrof A1PPL_USBD._bhv_pole_base_loop
    (gvar_init A1PPL_USBD.v_bhvTree) = true /\
  initializer_list_mentions_addrof A1PPL_JPBD._bhv_pole_base_loop
    (gvar_init A1PPL_JPBD.v_bhvTree) = true.

Theorem area1_palm_tree_behavior_source_checked :
  area1_palm_tree_behavior_source_claim.
Proof.
  unfold area1_palm_tree_behavior_source_claim,
    area1_palm_preset_us, area1_palm_preset_jp.
  vm_compute. repeat split; reflexivity.
Qed.

(** This packed-script partition evidence places local-script links 1--3
    immediately before the Area-1 terrain command.  [local_4] occurs later in
    the overall level script.  These offsets match the source partition, but
    this theorem alone does not interpret BEGIN_AREA/END_AREA or prove that
    local_4 cannot execute while Area 1 is active. *)
Definition area1_level_script_partition_source_claim : Prop :=
  firstn 8 (skipn 94
    (gvar_init A1PPL_USScript.v_level_ssl_entry)) =
    [Init_int32 (Int.repr 101187584);
     Init_addrof A1PPL_USScript._script_func_local_1 (Ptrofs.repr 0);
     Init_int32 (Int.repr 101187584);
     Init_addrof A1PPL_USScript._script_func_local_2 (Ptrofs.repr 0);
     Init_int32 (Int.repr 101187584);
     Init_addrof A1PPL_USScript._script_func_local_3 (Ptrofs.repr 0);
     Init_int32 (Int.repr 772276224);
     Init_addrof A1PPL_USScript._ssl_seg7_area_1_collision
       (Ptrofs.repr 0)] /\
  firstn 8 (skipn 94
    (gvar_init A1PPL_JPScript.v_level_ssl_entry)) =
    [Init_int32 (Int.repr 101187584);
     Init_addrof A1PPL_JPScript._script_func_local_1 (Ptrofs.repr 0);
     Init_int32 (Int.repr 101187584);
     Init_addrof A1PPL_JPScript._script_func_local_2 (Ptrofs.repr 0);
     Init_int32 (Int.repr 101187584);
     Init_addrof A1PPL_JPScript._script_func_local_3 (Ptrofs.repr 0);
     Init_int32 (Int.repr 772276224);
     Init_addrof A1PPL_JPScript._ssl_seg7_area_1_collision
       (Ptrofs.repr 0)] /\
  initializer_list_mentions_addrof A1PPL_USScript._script_func_local_4
    (gvar_init A1PPL_USScript.v_level_ssl_entry) = true /\
  initializer_list_mentions_addrof A1PPL_JPScript._script_func_local_4
    (gvar_init A1PPL_JPScript.v_level_ssl_entry) = true.

Theorem area1_level_script_partition_source_checked :
  area1_level_script_partition_source_claim.
Proof.
  unfold area1_level_script_partition_source_claim.
  vm_compute. repeat split; reflexivity.
Qed.

(** The loaded Area-1 regular-object arrays contain only the displayed
    behaviors.  The object-list link for [bhvPoleGrabbing] is retained as an
    additional source receipt; these poles are not selected by the Area-1
    local-script prefix above. *)
Definition area1_regular_behavior_addrofs_us : list ident :=
  initializer_addrof_idents
    (gvar_init A1PPL_USScript.v_script_func_local_1 ++
     gvar_init A1PPL_USScript.v_script_func_local_2 ++
     gvar_init A1PPL_USScript.v_script_func_local_3).

Definition area1_regular_behavior_addrofs_jp : list ident :=
  initializer_addrof_idents
    (gvar_init A1PPL_JPScript.v_script_func_local_1 ++
     gvar_init A1PPL_JPScript.v_script_func_local_2 ++
     gvar_init A1PPL_JPScript.v_script_func_local_3).

Definition area1_regular_behavior_inventory_us : list ident :=
  [A1PPL_USScript._bhvPyramidTop;
   A1PPL_USScript._bhvToxBox; A1PPL_USScript._bhvToxBox;
   A1PPL_USScript._bhvToxBox;
   A1PPL_USScript._bhvTweester; A1PPL_USScript._bhvTweester;
   A1PPL_USScript._bhvTweester;
   A1PPL_USScript._bhvKlepto; A1PPL_USScript._bhvKlepto;
   A1PPL_USScript._bhvStar; A1PPL_USScript._bhvHiddenRedCoinStar].

Definition area1_regular_behavior_inventory_jp : list ident :=
  [A1PPL_JPScript._bhvPyramidTop;
   A1PPL_JPScript._bhvToxBox; A1PPL_JPScript._bhvToxBox;
   A1PPL_JPScript._bhvToxBox;
   A1PPL_JPScript._bhvTweester; A1PPL_JPScript._bhvTweester;
   A1PPL_JPScript._bhvTweester;
   A1PPL_JPScript._bhvKlepto; A1PPL_JPScript._bhvKlepto;
   A1PPL_JPScript._bhvStar; A1PPL_JPScript._bhvHiddenRedCoinStar].

Theorem area1_regular_behavior_inventory_checked :
  area1_regular_behavior_addrofs_us = area1_regular_behavior_inventory_us /\
  area1_regular_behavior_addrofs_jp = area1_regular_behavior_inventory_jp.
Proof.
  unfold area1_regular_behavior_addrofs_us,
    area1_regular_behavior_addrofs_jp,
    area1_regular_behavior_inventory_us,
    area1_regular_behavior_inventory_jp.
  vm_compute. split; reflexivity.
Qed.

(** This behavior-family list is manually derived from an external scan of
    generated callback roots that call
    [cur_obj_push_mario_away_from_cylinder].  This module checks only that the
    named families are absent from Area-1 initializer data; it does not prove
    caller exhaustiveness, the individual call occurrences, or the
    callback-to-behavior mapping. *)
Definition cylinder_push_behavior_families_us : list ident :=
  [A1PPL_USBD._bhvBetaChestBottom;
   A1PPL_USBD._bhvSnowmansBottom; A1PPL_USBD._bhvSnowmansHead;
   A1PPL_USBD._bhvTreasureChestBottom;
   A1PPL_USBD._bhvKoopa;
   A1PPL_USBD._bhvWaterBombCannon;
   A1PPL_USBD._bhvHauntedChair; A1PPL_USBD._bhvMadPiano;
   A1PPL_USBD._bhvBookSwitch;
   A1PPL_USBD._bhvRacingPenguin].

Definition cylinder_push_behavior_families_jp : list ident :=
  [A1PPL_JPBD._bhvBetaChestBottom;
   A1PPL_JPBD._bhvSnowmansBottom; A1PPL_JPBD._bhvSnowmansHead;
   A1PPL_JPBD._bhvTreasureChestBottom;
   A1PPL_JPBD._bhvKoopa;
   A1PPL_JPBD._bhvWaterBombCannon;
   A1PPL_JPBD._bhvHauntedChair; A1PPL_JPBD._bhvMadPiano;
   A1PPL_JPBD._bhvBookSwitch;
   A1PPL_JPBD._bhvRacingPenguin].

Definition area1_regular_data_excludes_cylinder_families_us : Prop :=
  forallb
    (fun behavior =>
       negb (existsb (Pos.eqb behavior) area1_regular_behavior_addrofs_us))
    cylinder_push_behavior_families_us = true.

Definition area1_regular_data_excludes_cylinder_families_jp : Prop :=
  forallb
    (fun behavior =>
       negb (existsb (Pos.eqb behavior) area1_regular_behavior_addrofs_jp))
    cylinder_push_behavior_families_jp = true.

Definition area1_macro_data_excludes_cylinder_families_us : Prop :=
  forallb
    (fun behavior => negb (us_area1_macro_mentions_behavior behavior))
    cylinder_push_behavior_families_us = true.

Definition area1_macro_data_excludes_cylinder_families_jp : Prop :=
  forallb
    (fun behavior => negb (jp_area1_macro_mentions_behavior behavior))
    cylinder_push_behavior_families_jp = true.

Theorem area1_static_data_excludes_cylinder_push_families :
  area1_regular_data_excludes_cylinder_families_us /\
  area1_regular_data_excludes_cylinder_families_jp /\
  area1_macro_data_excludes_cylinder_families_us /\
  area1_macro_data_excludes_cylinder_families_jp.
Proof.
  unfold area1_regular_data_excludes_cylinder_families_us,
    area1_regular_data_excludes_cylinder_families_jp,
    area1_macro_data_excludes_cylinder_families_us,
    area1_macro_data_excludes_cylinder_families_jp,
    cylinder_push_behavior_families_us,
    cylinder_push_behavior_families_jp,
    area1_regular_behavior_addrofs_us,
    area1_regular_behavior_addrofs_jp,
    us_area1_macro_mentions_behavior, jp_area1_macro_mentions_behavior,
    macro_list_mentions_behavior.
  vm_compute. repeat split; reflexivity.
Qed.

(** This capstone composes only proved source/data facts and the generic copy
    lemma.  It intentionally does not claim linked reachability of a palm or
    pole collision, normal return of Mario's update, or global caller
    exhaustiveness for arbitrary corrupted programs. *)
Theorem area1_stock_pole_tree_push_is_preplayer_and_copy_resynchronized :
  area1_palm_special_source_claim /\
  area1_palm_tree_behavior_source_claim /\
  area1_level_script_partition_source_claim /\
  area1_pole_push_list_order_source_claim /\
  pole_push_state_only_xz_source_claim /\
  pole_base_exact_radius_source_claim /\
  player_copy_after_action_source_claim /\
  (forall (coordinate : Type) (next_x next_z : coordinate)
          (before : StateObjectXZ coordinate),
      state_object_xz_synchronized
        (copy_state_xz_to_object
          (state_only_set_xz next_x next_z before))).
Proof.
  repeat split;
    try exact area1_palm_special_source_checked;
    try exact area1_palm_tree_behavior_source_checked;
    try exact area1_level_script_partition_source_checked;
    try exact area1_pole_push_list_order_source_checked;
    try exact pole_push_state_only_xz_source_checked;
    try exact pole_base_exact_radius_source_checked;
    try exact player_copy_after_action_source_checked;
    try exact player_copy_resynchronizes_any_state_only_xz_write.
Qed.
