(** Selector exclusion for the one post-copy direct designated
    Mario-Object coordinate writer.

    [Area1PostCopyObjectWriterClosure] computes that, after excluding entry
    initialization and the pre-object-update instant warp, the only generated
    function which directly obtains Mario's Object through [gMarioObject] or
    [MarioState.marioObj] and assigns raw XYZ is
    [butterfly_calculate_angle].  This file checks the corresponding stock
    Area-1 selector subcase.

    SSL Area 1 selects neither the butterfly macro preset nor special preset
    32; its special-object section selects only IDs 0, 101, and 125.  A live
    butterfly therefore cannot come from any of these three stock selector
    families, but a complete static-origin census and its runtime provenance
    bridge deliberately remain outside this reduced module.

    This is deliberately not a linked-execution theorem.  In particular,
    source initializers do not prove that the linked retail memory preserves
    their values, and the normalized source corpus is not a successful
    CompCert link.  The final theorems therefore expose the exact runtime
    provenance bridge instead of silently assuming it.

    A source-only dependency closure also cannot by itself exclude every
    MarioState writer: the clean Area-1 palm tree really reaches
    [cur_obj_push_mario_away].  Its safety is chronological (POLELIKE list 10
    runs before PLAYER list 0 and Mario's copy), not graph-theoretic.  That
    checked obstruction is retained at the bottom of the file. *)

From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Ctypes Integers.
From LessThanOneAPress.Generated Require Import
  us_behavior_data us_macro_special_objects us_ssl_script
  jp_behavior_data jp_macro_special_objects jp_ssl_script.
From LessThanOneAPress.Proofs Require Import
  ASTFacts Area1EntryDepthClosure Area1PolePushSchedule Area1PolePushLinkage
  Area1PostCopyObjectWriterClosure.

Import ListNotations.
Local Open Scope Z_scope.

Module A1BSO_USBD := us_behavior_data.
Module A1BSO_USMS := us_macro_special_objects.
Module A1BSO_JPBD := jp_behavior_data.
Module A1BSO_JPMS := jp_macro_special_objects.

(** The generated [SpecialPreset] representation is five initializer items:
    ID, type, unused byte, model, behavior pointer.  Preset zero deliberately
    has an integer-null fifth field, so the recognizer treats it as selecting
    no behavior. *)
Definition special_preset_record_selects_behavior
    (target : ident) (preset : Z) (record : list init_data) : bool :=
  match record with
  | [Init_int8 found_preset; _; _; _; Init_addrof found_behavior _] =>
      Z.eqb (Int.signed found_preset) preset &&
      Pos.eqb found_behavior target
  | _ => false
  end.

Fixpoint special_preset_table_selects_behavior
    (target : ident) (preset : Z) (values : list init_data) : bool :=
  match values with
  | a :: b :: c :: d :: e :: rest =>
      special_preset_record_selects_behavior
        target preset [a; b; c; d; e] ||
      special_preset_table_selects_behavior target preset rest
  | _ => false
  end.

(** The collision-data receipt in [Area1PolePushLinkage] checks the complete
    Area-1 special-object suffix.  Removing duplicates, its selected preset
    IDs are exactly 0, 101, and 125. *)
Definition area1_selected_special_preset_ids : list Z := [0; 101; 125].

Definition selected_area1_special_source
    (target : ident) (preset_data : list init_data) : bool :=
  existsb
    (fun preset =>
      special_preset_table_selects_behavior target preset preset_data)
    area1_selected_special_preset_ids.

(** Executable selector boundary. *)
Definition butterfly_area1_selector_exclusion_claim : Prop :=
  us_area1_macro_mentions_behavior A1BSO_USBD._bhvButterfly = false /\
  jp_area1_macro_mentions_behavior A1BSO_JPBD._bhvButterfly = false /\
  program_initializers_mention_addrof
    A1BSO_USBD._bhvButterfly us_ssl_script.prog = false /\
  program_initializers_mention_addrof
    A1BSO_JPBD._bhvButterfly jp_ssl_script.prog = false /\
  selected_area1_special_source A1BSO_USBD._bhvButterfly
    (gvar_init A1BSO_USMS.v_sSpecialObjectPresets) = false /\
  selected_area1_special_source A1BSO_JPBD._bhvButterfly
    (gvar_init A1BSO_JPMS.v_sSpecialObjectPresets) = false.

Theorem butterfly_area1_selector_exclusion_checked :
  butterfly_area1_selector_exclusion_claim.
Proof.
  unfold butterfly_area1_selector_exclusion_claim,
    selected_area1_special_source, area1_selected_special_preset_ids,
    special_preset_table_selects_behavior,
    special_preset_record_selects_behavior,
    us_area1_macro_mentions_behavior, jp_area1_macro_mentions_behavior,
    macro_list_mentions_behavior, program_initializers_mention_addrof.
  vm_compute. repeat split; reflexivity.
Qed.

(** Why the same source-only graph cannot close all MarioState writers.
    Area 1 genuinely contains a palm-tree dependency path to a State-only X/Z
    writer.  Its rejection needs the already checked list chronology and copy,
    so a conservative dependency graph which simply deletes every writer path
    would be unsound. *)
Definition state_writer_source_graph_obstruction : Prop :=
  area1_palm_special_source_claim /\
  area1_palm_tree_behavior_source_claim /\
  area1_pole_push_list_order_source_claim /\
  pole_push_state_only_xz_source_claim /\
  pole_base_exact_radius_source_claim /\
  player_copy_after_action_source_claim.

Theorem state_writer_source_graph_obstruction_checked :
  state_writer_source_graph_obstruction.
Proof.
  unfold state_writer_source_graph_obstruction.
  repeat split;
    try exact area1_palm_special_source_checked;
    try exact area1_palm_tree_behavior_source_checked;
    try exact area1_pole_push_list_order_source_checked;
    try exact pole_push_state_only_xz_source_checked;
    try exact pole_base_exact_radius_source_checked;
    try exact player_copy_after_action_source_checked.
Qed.

(** Audit boundary.  What is closed is the stock selector subcase plus the
    proof that a graph-only State closure is insufficient.
    A full retail closure still needs linked live-behavior provenance,
    receiver non-aliasing, external-frame preservation, and phase-sensitive
    dispatch/lifecycle refinement. *)
Definition Area1ButterflyStaticOriginCheckedBoundary : Prop :=
  butterfly_area1_selector_exclusion_claim /\
  area1_palm_special_source_claim /\
  state_writer_source_graph_obstruction.

Theorem area1_butterfly_static_origin_checked_boundary_holds :
  Area1ButterflyStaticOriginCheckedBoundary.
Proof.
  unfold Area1ButterflyStaticOriginCheckedBoundary.
  split; [exact butterfly_area1_selector_exclusion_checked |].
  split; [exact area1_palm_special_source_checked |].
  exact state_writer_source_graph_obstruction_checked.
Qed.
