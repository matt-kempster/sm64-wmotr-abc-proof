(** Admission-free consequences of the ordinary SSL Area-1 entry model.

    This file closes three narrow pieces of the Graphics/Object-gap audit:

    - the ordinary-entry memory postcondition synchronizes all three Mario
      State, Object-raw, and Object-Graphics coordinates, not only Y;
    - that same postcondition fixes the entry action and the live binary32
      quicksand-depth cell to +0.0f; and
    - the generated US and JP SSL Area-1 level data contain no static ordinary
      door or warp-door object.  The macro-object result follows the actual
      retail decoder: [(word & 0x1ff) - 31] indexes the generated preset table.

    These are entry/static-data facts.  They do not prove the outstanding
    execution refinement that reaches the memory postcondition, nor do they
    exclude a later corrupting store, clone, or otherwise forged door object.
 *)

From Coq Require Import List ZArith.
From compcert Require Import AST Clight Ctypes Floats Integers Memory Values.
From LessThanOneAPress.Generated Require Import
  us_ssl_area1_macro us_ssl_script us_macro_special_objects
  jp_ssl_area1_macro jp_ssl_script jp_macro_special_objects
  us_obj_behaviors jp_obj_behaviors.
From LessThanOneAPress.Proofs Require Import
  ASTFacts EntryMemory OrdinaryArea1EntryMemory.

Import ListNotations.
Local Open Scope Z_scope.

Module A1_US_Macro := us_ssl_area1_macro.
Module A1_US_Script := us_ssl_script.
Module A1_US_Presets := us_macro_special_objects.
Module A1_JP_Macro := jp_ssl_area1_macro.
Module A1_JP_Script := jp_ssl_script.
Module A1_JP_Presets := jp_macro_special_objects.
Module A1_US_Objects := us_obj_behaviors.
Module A1_JP_Objects := jp_obj_behaviors.

(** * Complete coordinate synchronization at the stated entry boundary *)

Record OrdinaryArea1EntryCoordinateSynchronization
    (memory : mem) (addresses : Area1EntryAddresses) : Prop := {
  ordinary_entry_state_raw_x_synchronized :
    load_at Mfloat32 memory (area1_state_storage_block addresses) 0
      mario_state_position_offset =
    load_at Mfloat32 memory (area1_object_pool_block addresses)
      (mario_object_base addresses) mario_object_raw_position_offset;
  ordinary_entry_state_raw_y_synchronized :
    load_at Mfloat32 memory (area1_state_storage_block addresses) 0
      (mario_state_position_offset + 4) =
    load_at Mfloat32 memory (area1_object_pool_block addresses)
      (mario_object_base addresses) (mario_object_raw_position_offset + 4);
  ordinary_entry_state_raw_z_synchronized :
    load_at Mfloat32 memory (area1_state_storage_block addresses) 0
      (mario_state_position_offset + 8) =
    load_at Mfloat32 memory (area1_object_pool_block addresses)
      (mario_object_base addresses) (mario_object_raw_position_offset + 8);
  ordinary_entry_state_graphics_x_synchronized :
    load_at Mfloat32 memory (area1_state_storage_block addresses) 0
      mario_state_position_offset =
    load_at Mfloat32 memory (area1_object_pool_block addresses)
      (mario_object_base addresses) mario_object_graphics_position_offset;
  ordinary_entry_state_graphics_y_synchronized :
    load_at Mfloat32 memory (area1_state_storage_block addresses) 0
      (mario_state_position_offset + 4) =
    load_at Mfloat32 memory (area1_object_pool_block addresses)
      (mario_object_base addresses) (mario_object_graphics_position_offset + 4);
  ordinary_entry_state_graphics_z_synchronized :
    load_at Mfloat32 memory (area1_state_storage_block addresses) 0
      (mario_state_position_offset + 8) =
    load_at Mfloat32 memory (area1_object_pool_block addresses)
      (mario_object_base addresses) (mario_object_graphics_position_offset + 8)
}.

Theorem ordinary_area1_entry_memory_synchronizes_all_coordinates :
  forall memory addresses x y z sample,
    OrdinaryArea1EntryMemoryPostcondition memory addresses x y z sample ->
    OrdinaryArea1EntryCoordinateSynchronization memory addresses.
Proof.
  intros memory addresses x y z sample Hentry.
  constructor;
    repeat match goal with
    | H : OrdinaryArea1EntryMemoryPostcondition _ _ _ _ _ _ |- _ =>
        first
          [ rewrite (ordinary_area1_state_x _ _ _ _ _ _ H)
          | rewrite (ordinary_area1_state_y _ _ _ _ _ _ H)
          | rewrite (ordinary_area1_state_z _ _ _ _ _ _ H)
          | rewrite (ordinary_area1_object_raw_x _ _ _ _ _ _ H)
          | rewrite (ordinary_area1_object_raw_y _ _ _ _ _ _ H)
          | rewrite (ordinary_area1_object_raw_z _ _ _ _ _ _ H)
          | rewrite (ordinary_area1_object_graphics_x _ _ _ _ _ _ H)
          | rewrite (ordinary_area1_object_graphics_y _ _ _ _ _ _ H)
          | rewrite (ordinary_area1_object_graphics_z _ _ _ _ _ _ H) ]
    end;
    reflexivity.
Qed.

Record OrdinaryArea1EntryActionDepthSample
    (memory : mem) (addresses : Area1EntryAddresses) : Prop := {
  ordinary_entry_live_action_is_spin_airborne :
    load_at Mint32 memory (area1_state_storage_block addresses) 0
      mario_state_action_offset = Some (Vint spin_airborne_entry_action);
  ordinary_entry_live_depth_is_positive_binary32_zero :
    load_at Mfloat32 memory (area1_state_storage_block addresses) 0
      mario_state_quicksand_depth_offset =
    Some (Vsingle positive_f32_zero);
  ordinary_entry_positive_zero_bits_are_zero :
    Float32.to_bits positive_f32_zero = Int.zero
}.

Theorem ordinary_area1_entry_memory_fixes_action_and_binary32_depth :
  forall memory addresses x y z sample,
    OrdinaryArea1EntryMemoryPostcondition memory addresses x y z sample ->
    OrdinaryArea1EntryActionDepthSample memory addresses.
Proof.
  intros memory addresses x y z sample Hentry.
  constructor.
  - exact (ordinary_area1_action _ _ _ _ _ _ Hentry).
  - exact (ordinary_area1_quicksand_depth_zero _ _ _ _ _ _ Hentry).
  - vm_compute. reflexivity.
Qed.

(** * Generated stock Area-1 door-source exclusion *)

Definition initializer_addrof_ident (target : ident) (datum : init_data) : bool :=
  match datum with
  | Init_addrof found _ => Pos.eqb target found
  | _ => false
  end.

Definition global_variable_initializers
    (definitions : list (ident * globdef (fundef function) type)) :
    list init_data :=
  flat_map
    (fun definition =>
       match snd definition with
       | Gvar variable => gvar_init variable
       | _ => []
       end)
    definitions.

Definition program_initializers_mention_addrof
    (target : ident) (program : Clight.program) : bool :=
  existsb (initializer_addrof_ident target)
    (global_variable_initializers (prog_defs program)).

(** Macro entries are five signed halfwords.  Only their first word selects
    a preset.  Retail stops when the decoded preset is negative; the SSL data
    uses the one-halfword [30] terminator, which decodes to [-1]. *)
Fixpoint macro_object_first_words (data : list init_data) : list int :=
  match data with
  | Init_int16 first :: _ :: _ :: _ :: _ :: rest =>
      if Int.eq first (Int.repr (-1))
      then []
      else first :: macro_object_first_words rest
  | _ => []
  end.

Definition macro_preset_index (word : int) : nat :=
  Z.to_nat (Int.unsigned (Int.and word (Int.repr 511)) - 31).

Definition macro_word_has_nonnegative_preset (word : int) : bool :=
  Z.leb 31 (Int.unsigned (Int.and word (Int.repr 511))).

(** Each generated [MacroPreset] initializer is behavior/model/parameter:
    one relocation followed by two 16-bit constants. *)
Fixpoint macro_preset_behavior_initializers (data : list init_data) :
    list init_data :=
  match data with
  | behavior :: _ :: _ :: rest =>
      behavior :: macro_preset_behavior_initializers rest
  | _ => []
  end.

Definition macro_word_selects_behavior
    (target : ident) (preset_initializers : list init_data)
    (word : int) : bool :=
  match nth_error
      (macro_preset_behavior_initializers preset_initializers)
      (macro_preset_index word) with
  | Some behavior => initializer_addrof_ident target behavior
  | None => false
  end.

Definition macro_list_mentions_behavior
    (target : ident) (macro_data preset_data : list init_data) : bool :=
  existsb (macro_word_selects_behavior target preset_data)
    (macro_object_first_words macro_data).

Definition us_area1_macro_mentions_behavior (target : ident) : bool :=
  macro_list_mentions_behavior target
    (gvar_init A1_US_Macro.v_ssl_seg7_area_1_macro_objs)
    (gvar_init A1_US_Presets.v_sMacroObjectPresets).

Definition jp_area1_macro_mentions_behavior (target : ident) : bool :=
  macro_list_mentions_behavior target
    (gvar_init A1_JP_Macro.v_ssl_seg7_area_1_macro_objs)
    (gvar_init A1_JP_Presets.v_sMacroObjectPresets).

(** These receipts rule out a vacuous [false] caused by a malformed macro
    word, silent [Z.to_nat] clipping, or a failed preset lookup.  Both versions
    have exactly 46 complete five-halfword entries followed by the one-word
    terminator [30].  Every decoded entry is nonnegative and inside the
    complete 366-entry generated table. *)
Theorem us_stock_ssl_area1_macro_decoder_is_total :
  length (gvar_init A1_US_Macro.v_ssl_seg7_area_1_macro_objs) = 231%nat /\
  nth_error (gvar_init A1_US_Macro.v_ssl_seg7_area_1_macro_objs) 230 =
    Some (Init_int16 (Int.repr 30)) /\
  length
    (macro_object_first_words
      (gvar_init A1_US_Macro.v_ssl_seg7_area_1_macro_objs)) = 46%nat /\
  length
    (macro_preset_behavior_initializers
      (gvar_init A1_US_Presets.v_sMacroObjectPresets)) = 366%nat /\
  forallb macro_word_has_nonnegative_preset
    (macro_object_first_words
      (gvar_init A1_US_Macro.v_ssl_seg7_area_1_macro_objs)) = true /\
  forallb
    (fun word => Nat.ltb (macro_preset_index word) 366)
    (macro_object_first_words
      (gvar_init A1_US_Macro.v_ssl_seg7_area_1_macro_objs)) = true.
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem jp_stock_ssl_area1_macro_decoder_is_total :
  length (gvar_init A1_JP_Macro.v_ssl_seg7_area_1_macro_objs) = 231%nat /\
  nth_error (gvar_init A1_JP_Macro.v_ssl_seg7_area_1_macro_objs) 230 =
    Some (Init_int16 (Int.repr 30)) /\
  length
    (macro_object_first_words
      (gvar_init A1_JP_Macro.v_ssl_seg7_area_1_macro_objs)) = 46%nat /\
  length
    (macro_preset_behavior_initializers
      (gvar_init A1_JP_Presets.v_sMacroObjectPresets)) = 366%nat /\
  forallb macro_word_has_nonnegative_preset
    (macro_object_first_words
      (gvar_init A1_JP_Macro.v_ssl_seg7_area_1_macro_objs)) = true /\
  forallb
    (fun word => Nat.ltb (macro_preset_index word) 366)
    (macro_object_first_words
      (gvar_init A1_JP_Macro.v_ssl_seg7_area_1_macro_objs)) = true.
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem us_stock_ssl_area1_has_no_static_door_behavior :
  us_area1_macro_mentions_behavior A1_US_Presets._bhvDoor = false /\
  us_area1_macro_mentions_behavior A1_US_Presets._bhvDoorWarp = false /\
  program_initializers_mention_addrof
    A1_US_Presets._bhvDoor A1_US_Script.prog = false /\
  program_initializers_mention_addrof
    A1_US_Presets._bhvDoorWarp A1_US_Script.prog = false.
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem jp_stock_ssl_area1_has_no_static_door_behavior :
  jp_area1_macro_mentions_behavior A1_JP_Presets._bhvDoor = false /\
  jp_area1_macro_mentions_behavior A1_JP_Presets._bhvDoorWarp = false /\
  program_initializers_mention_addrof
    A1_JP_Presets._bhvDoor A1_JP_Script.prog = false /\
  program_initializers_mention_addrof
    A1_JP_Presets._bhvDoorWarp A1_JP_Script.prog = false.
Proof. vm_compute. repeat split; reflexivity. Qed.

Definition us_stock_area1_behavior_source (behavior : ident) : bool :=
  us_area1_macro_mentions_behavior behavior ||
  program_initializers_mention_addrof behavior A1_US_Script.prog.

Definition jp_stock_area1_behavior_source (behavior : ident) : bool :=
  jp_area1_macro_mentions_behavior behavior ||
  program_initializers_mention_addrof behavior A1_JP_Script.prog.

(** This deliberately over-strong direct-source premise is useful only as a
    conditional boundary.  Normal stock callbacks spawn behaviors not named
    by the macro stream or level script, so a retail proof needs the transitive
    spawn-closure relation defined below instead. *)
Definition StockArea1BehaviorProvenance
    (stock_source : ident -> bool) (live_behavior : ident -> Prop) : Prop :=
  forall behavior,
    live_behavior behavior -> stock_source behavior = true.

(** A source-rooted transitive spawn relation is the usable retail boundary.
    [spawn_reachable root child] should include zero or more generated spawn
    edges.  The generic lemma isolates the remaining door-specific graph
    reachability proof without requiring every child to be a direct source. *)
Definition StockArea1TransitiveBehaviorProvenance
    (stock_source : ident -> bool)
    (spawn_reachable : ident -> ident -> Prop)
    (live_behavior : ident -> Prop) : Prop :=
  forall behavior,
    live_behavior behavior ->
    exists root,
      stock_source root = true /\ spawn_reachable root behavior.

Definition StockArea1SpawnClosureExcludes
    (stock_source : ident -> bool)
    (spawn_reachable : ident -> ident -> Prop)
    (forbidden : ident) : Prop :=
  forall root,
    stock_source root = true -> ~ spawn_reachable root forbidden.

Theorem stock_area1_transitive_provenance_excludes_forbidden_behavior :
  forall stock_source spawn_reachable live_behavior forbidden,
    StockArea1TransitiveBehaviorProvenance
      stock_source spawn_reachable live_behavior ->
    StockArea1SpawnClosureExcludes
      stock_source spawn_reachable forbidden ->
    ~ live_behavior forbidden.
Proof.
  intros stock_source spawn_reachable live_behavior forbidden
    Hprovenance Hexcluded Hlive.
  destruct (Hprovenance forbidden Hlive) as
    (root & Hsource & Hreachable).
  exact (Hexcluded root Hsource Hreachable).
Qed.

(** The direct-source premise above is not a stock spawn-closure theorem.
    Both versions' generated top callbacks mention normal child behaviors
    which are absent from the direct macro/script source relation. *)
Theorem stock_area1_direct_source_omits_pyramid_top_children :
  us_stock_area1_behavior_source
    A1_US_Objects._bhvPyramidPillarTouchDetector = false /\
  us_stock_area1_behavior_source
    A1_US_Objects._bhvPyramidTopFragment = false /\
  statement_mentions_ident_s
    A1_US_Objects._bhvPyramidPillarTouchDetector
    (fn_body A1_US_Objects.f_bhv_pyramid_top_init) = true /\
  statement_mentions_ident_s
    A1_US_Objects._bhvPyramidTopFragment
    (fn_body A1_US_Objects.f_bhv_pyramid_top_spinning) = true /\
  jp_stock_area1_behavior_source
    A1_JP_Objects._bhvPyramidPillarTouchDetector = false /\
  jp_stock_area1_behavior_source
    A1_JP_Objects._bhvPyramidTopFragment = false /\
  statement_mentions_ident_s
    A1_JP_Objects._bhvPyramidPillarTouchDetector
    (fn_body A1_JP_Objects.f_bhv_pyramid_top_init) = true /\
  statement_mentions_ident_s
    A1_JP_Objects._bhvPyramidTopFragment
    (fn_body A1_JP_Objects.f_bhv_pyramid_top_spinning) = true.
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem us_stock_area1_provenance_excludes_live_dialog_doors :
  forall live_behavior,
    StockArea1BehaviorProvenance us_stock_area1_behavior_source live_behavior ->
    ~ live_behavior A1_US_Presets._bhvDoor /\
    ~ live_behavior A1_US_Presets._bhvDoorWarp.
Proof.
  intros live_behavior Hprovenance.
  pose proof us_stock_ssl_area1_has_no_static_door_behavior as
    (Hmacro_door & Hmacro_warp & Hscript_door & Hscript_warp).
  split; intro Hlive.
  - specialize
      (Hprovenance A1_US_Presets._bhvDoor Hlive).
    unfold us_stock_area1_behavior_source in Hprovenance.
    rewrite Hmacro_door, Hscript_door in Hprovenance.
    discriminate.
  - specialize
      (Hprovenance A1_US_Presets._bhvDoorWarp Hlive).
    unfold us_stock_area1_behavior_source in Hprovenance.
    rewrite Hmacro_warp, Hscript_warp in Hprovenance.
    discriminate.
Qed.

Theorem jp_stock_area1_provenance_excludes_live_dialog_doors :
  forall live_behavior,
    StockArea1BehaviorProvenance jp_stock_area1_behavior_source live_behavior ->
    ~ live_behavior A1_JP_Presets._bhvDoor /\
    ~ live_behavior A1_JP_Presets._bhvDoorWarp.
Proof.
  intros live_behavior Hprovenance.
  pose proof jp_stock_ssl_area1_has_no_static_door_behavior as
    (Hmacro_door & Hmacro_warp & Hscript_door & Hscript_warp).
  split; intro Hlive.
  - specialize
      (Hprovenance A1_JP_Presets._bhvDoor Hlive).
    unfold jp_stock_area1_behavior_source in Hprovenance.
    rewrite Hmacro_door, Hscript_door in Hprovenance.
    discriminate.
  - specialize
      (Hprovenance A1_JP_Presets._bhvDoorWarp Hlive).
    unfold jp_stock_area1_behavior_source in Hprovenance.
    rewrite Hmacro_warp, Hscript_warp in Hprovenance.
    discriminate.
Qed.

(** This packages exactly what the static receipts exclude.  It deliberately
    does not turn absence from the level data into a dynamic non-reachability
    theorem without object-spawn, pointer, and write provenance. *)
Definition StockArea1StaticDoorSourceExcluded : Prop :=
  us_area1_macro_mentions_behavior A1_US_Presets._bhvDoor = false /\
  us_area1_macro_mentions_behavior A1_US_Presets._bhvDoorWarp = false /\
  program_initializers_mention_addrof
    A1_US_Presets._bhvDoor A1_US_Script.prog = false /\
  program_initializers_mention_addrof
    A1_US_Presets._bhvDoorWarp A1_US_Script.prog = false /\
  jp_area1_macro_mentions_behavior A1_JP_Presets._bhvDoor = false /\
  jp_area1_macro_mentions_behavior A1_JP_Presets._bhvDoorWarp = false /\
  program_initializers_mention_addrof
    A1_JP_Presets._bhvDoor A1_JP_Script.prog = false /\
  program_initializers_mention_addrof
    A1_JP_Presets._bhvDoorWarp A1_JP_Script.prog = false.

Theorem stock_area1_static_door_source_excluded :
  StockArea1StaticDoorSourceExcluded.
Proof.
  unfold StockArea1StaticDoorSourceExcluded.
  pose proof us_stock_ssl_area1_has_no_static_door_behavior as Hus.
  pose proof jp_stock_ssl_area1_has_no_static_door_behavior as Hjp.
  tauto.
Qed.
