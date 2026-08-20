(** Narrow producer closure for the rank-2 timer-131 Graphics retry.

    The timer-131 geometry is known to accept a non-null retry if Graphics is
    high enough while Mario's raw Object still overlaps the upper warp.  This
    file asks whether either of the two receiver-generic source paths that can
    create such a Graphics/Object difference supplies that prestate in stock
    SSL Area 1:

    - the behavior tail [obj_update_gfx_pos_and_angle], whose Y result is raw
      Object Y plus [oGraphYOffset]; and
    - [obj_set_gfx_pos_at_obj_pos], which copies all three Graphics coordinates
      from another Object and is called by the Chuckya/King-Bob-omb anchor.

    The checked result is deliberately a source/finite-geometry boundary, not
    a retail reachability theorem.  It rules out every encoded stock
    [SET_FLOAT(oGraphYOffset, value)] as being large enough, and it rules out
    the two anchor-parent behaviors from the audited stock Area-1 selectors.
    A concrete non-stock [+1160] offset is also shown to make a timer-131 face
    query succeed at the warp-centre X/Z.  Thus the geometry is possible, but
    the remaining route would have to escape the checked provenance through a
    forged/indirect behavior command, pointer alias, external or out-of-bounds
    store, object-slot lifetime failure, or an incomplete live-source
    projection. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Ctypes Integers.
From LessThanOneAPress.Generated Require Import
  us_behavior_actions us_behavior_data us_behavior_script
  us_macro_special_objects us_spawn_object us_ssl_script
  jp_behavior_actions jp_behavior_data jp_behavior_script
  jp_macro_special_objects jp_spawn_object jp_ssl_script.
From LessThanOneAPress.Proofs Require Import
  ASTFacts Area1ButterflyStaticOriginClosure Area1EntryDepthClosure Area1FirstNull
  ClightFacts ClightRefinement JPGeneratedWriterCensus JPSlotLifetime
  PyramidTopPU PyramidTopSurface Timer131Surface ZeroAQuicksandEntryBoundary.

Import ListNotations.
Local Open Scope Z_scope.

Module ITP_USA := us_behavior_actions.
Module ITP_USD := us_behavior_data.
Module ITP_USB := us_behavior_script.
Module ITP_USM := us_macro_special_objects.
Module ITP_USSpawn := us_spawn_object.
Module ITP_JPA := jp_behavior_actions.
Module ITP_JPD := jp_behavior_data.
Module ITP_JPB := jp_behavior_script.
Module ITP_JPM := jp_macro_special_objects.
Module ITP_JPSpawn := jp_spawn_object.

(** Decode the one-word behavior commands produced by
    [SET_FLOAT(field, value)].  Opcode 14 is [bhv_cmd_set_float], field 21 is
    [oGraphYOffset], and the payload is a signed 16-bit integer. *)
Definition behavior_word_opcode (word : int) : Z :=
  Z.land (Z.shiftr (Int.unsigned word) 24) 255.

Definition behavior_word_field (word : int) : Z :=
  Z.land (Z.shiftr (Int.unsigned word) 16) 255.

Definition behavior_word_signed16 (word : int) : Z :=
  let raw := Z.land (Int.unsigned word) 65535 in
  if raw <? 32768 then raw else raw - 65536.

Fixpoint graph_y_offset_commands_in_initializer
    (data : list init_data) : list Z :=
  match data with
  | [] => []
  | Init_int32 word :: rest =>
      if (Z.eqb (behavior_word_opcode word) 14 &&
          Z.eqb (behavior_word_field word) 21)%bool
      then behavior_word_signed16 word ::
           graph_y_offset_commands_in_initializer rest
      else graph_y_offset_commands_in_initializer rest
  | _ :: rest => graph_y_offset_commands_in_initializer rest
  end.

Fixpoint graph_y_offset_commands_in_definitions
    (definitions : list (ident * globdef (fundef function) type)) : list Z :=
  match definitions with
  | [] => []
  | (_, Gvar variable) :: rest =>
      graph_y_offset_commands_in_initializer (gvar_init variable) ++
      graph_y_offset_commands_in_definitions rest
  | _ :: rest => graph_y_offset_commands_in_definitions rest
  end.

(** A second, opcode-neutral scan is important: it verifies that no stock
    command aimed at field 21 uses ADD_FLOAT, random-float, SUM_FLOAT, or any
    other behavior opcode omitted by the [SET_FLOAT] decoder above. *)
Fixpoint behavior_field_commands_in_initializer
    (field : Z) (data : list init_data) : list (Z * Z) :=
  match data with
  | [] => []
  | Init_int32 word :: rest =>
      if Z.eqb (behavior_word_field word) field
      then (behavior_word_opcode word, behavior_word_signed16 word) ::
           behavior_field_commands_in_initializer field rest
      else behavior_field_commands_in_initializer field rest
  | _ :: rest => behavior_field_commands_in_initializer field rest
  end.

Fixpoint behavior_field_commands_in_definitions
    (field : Z)
    (definitions : list (ident * globdef (fundef function) type))
    : list (Z * Z) :=
  match definitions with
  | [] => []
  | (_, Gvar variable) :: rest =>
      behavior_field_commands_in_initializer field (gvar_init variable) ++
      behavior_field_commands_in_definitions field rest
  | _ :: rest => behavior_field_commands_in_definitions field rest
  end.

Definition stock_graph_y_offset_command_values : list Z :=
  [25; 30; 70; 50; 0; 10; 60; 60; 30; 25; -16; 40; 40; 5;
   -288; -288; 25; 27; 130; 130; 130; 110; 180; 180;
   30; 30; 30; 30; 30; 30; 30; 30; 240; 40; -60; 10; 10; 30; 10; 10].

Definition stock_graph_y_field_commands : list (Z * Z) :=
  map (fun value => (14, value)) stock_graph_y_offset_command_values.

(** Bilateral, exact, whole-[behavior_data.c] receipt.  Scanning every global
    initializer rather than a hand-picked behavior prevents omission of an
    otherwise obscure stock script. *)
Definition stock_graph_y_offset_commands_bilateral_claim : Prop :=
  graph_y_offset_commands_in_definitions (prog_defs us_behavior_data.prog) =
    stock_graph_y_offset_command_values /\
  graph_y_offset_commands_in_definitions (prog_defs jp_behavior_data.prog) =
    stock_graph_y_offset_command_values /\
  behavior_field_commands_in_definitions 21
    (prog_defs us_behavior_data.prog) = stock_graph_y_field_commands /\
  behavior_field_commands_in_definitions 21
    (prog_defs jp_behavior_data.prog) = stock_graph_y_field_commands /\
  length stock_graph_y_offset_command_values = 40%nat.

Theorem stock_graph_y_offset_commands_exact_bilateral :
  stock_graph_y_offset_commands_bilateral_claim.
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem every_stock_graph_y_offset_command_is_at_most_240 :
  forall offset,
    In offset stock_graph_y_offset_command_values ->
    offset <= 240.
Proof.
  intros offset Hoffset.
  unfold stock_graph_y_offset_command_values in Hoffset.
  cbn in Hoffset.
  intuition lia.
Qed.

Theorem every_stock_graph_y_field_command_is_small_set_float :
  forall opcode offset,
    In (opcode, offset) stock_graph_y_field_commands ->
    opcode = 14 /\ offset <= 240.
Proof.
  intros opcode offset Hcommand.
  unfold stock_graph_y_field_commands in Hcommand.
  apply in_map_iff in Hcommand.
  destruct Hcommand as (value & Hpair & Hvalue).
  inversion Hpair; subst.
  split; [reflexivity |].
  now apply every_stock_graph_y_offset_command_is_at_most_240.
Qed.

(** This is the route-relevant numeric exclusion.  It does not claim that a
    live Mario object actually executes one of the decoded commands; it says
    that even granting such execution, every stock payload is too small. *)
Theorem stock_behavior_offset_cannot_install_timer131_top_retry :
  forall object_position graphics_position floor_y offset,
    In offset stock_graph_y_offset_command_values ->
    upper_warp_contact object_position ->
    -32768 <= position_y graphics_position < 32768 ->
    timer131_top_floor_min_y <= floor_y ->
    floor_query_can_return graphics_position floor_y ->
    position_y graphics_position = position_y object_position + offset ->
    False.
Proof.
  intros object_position graphics_position floor_y offset
    Hoffset Hwarp Hrange Hfloor Hquery Hgraphics.
  pose proof (every_stock_graph_y_offset_command_is_at_most_240
    offset Hoffset) as Hbounded.
  pose proof (timer131_warp_retry_requires_at_least_632_graphics_y_gap
    object_position graphics_position floor_y
    Hwarp Hrange Hfloor Hquery) as Hrequired.
  lia.
Qed.

(** Source link from the packed command to the interpreter.  The table entry
    and the exact identifiers used by the handler are checked bilaterally.
    Executed-table integrity and live [gCurrentObject] identity remain semantic
    obligations rather than being inferred from initializer order. *)
Definition graph_y_offset_interpreter_source_claim : Prop :=
  nth_error (gvar_init ITP_USB.v_BehaviorCmdTable) 14 =
    Some (Init_addrof ITP_USB._bhv_cmd_set_float (Ptrofs.repr 0)) /\
  nth_error (gvar_init ITP_JPB.v_BehaviorCmdTable) 14 =
    Some (Init_addrof ITP_JPB._bhv_cmd_set_float (Ptrofs.repr 0)) /\
  statement_mentions_ident_s ITP_USB._gCurrentObject
    (fn_body ITP_USB.f_bhv_cmd_set_float) = true /\
  statement_mentions_ident_s ITP_USB._rawData
    (fn_body ITP_USB.f_bhv_cmd_set_float) = true /\
  statement_mentions_ident_s ITP_USB._asF32
    (fn_body ITP_USB.f_bhv_cmd_set_float) = true /\
  statement_mentions_ident_s ITP_JPB._gCurrentObject
    (fn_body ITP_JPB.f_bhv_cmd_set_float) = true /\
  statement_mentions_ident_s ITP_JPB._rawData
    (fn_body ITP_JPB.f_bhv_cmd_set_float) = true /\
  statement_mentions_ident_s ITP_JPB._asF32
    (fn_body ITP_JPB.f_bhv_cmd_set_float) = true.

Theorem graph_y_offset_interpreter_source_checked :
  graph_y_offset_interpreter_source_claim.
Proof.
  unfold graph_y_offset_interpreter_source_claim.
  vm_compute. repeat split; reflexivity.
Qed.

(** The live-current-object question is reduced to the traversal node rather
    than silently assumed.  Both ordinary and time-stop traversals assign
    [gCurrentObject] from the node being visited before calling
    [cur_obj_update].  The behavior interpreter and behavior tail then use
    that same global.  A linked execution still must prove that the visited
    node is the live [gMarioObject] and that no alias/external write intervenes. *)
Definition assigns_global_from_cast_temp_s
    (global source : ident) (statement : statement) : bool :=
  match statement with
  | Sassign (Evar found_global _) (Ecast (Etempvar found_source _) _) =>
      Pos.eqb found_global global && Pos.eqb found_source source
  | _ => false
  end.

Fixpoint contains_global_from_temp_before_call_s
    (global source callee : ident) (statement : statement) : bool :=
  match statement with
  | Ssequence first rest =>
      (assigns_global_from_cast_temp_s global source first &&
       calls_ident_s callee rest)%bool ||
      contains_global_from_temp_before_call_s global source callee first ||
      contains_global_from_temp_before_call_s global source callee rest
  | Sloop first rest =>
      contains_global_from_temp_before_call_s global source callee first ||
      contains_global_from_temp_before_call_s global source callee rest
  | Sifthenelse _ if_true if_false =>
      contains_global_from_temp_before_call_s global source callee if_true ||
      contains_global_from_temp_before_call_s global source callee if_false
  | Sswitch _ cases =>
      contains_global_from_temp_before_call_ls global source callee cases
  | Slabel _ body =>
      contains_global_from_temp_before_call_s global source callee body
  | _ => false
  end
with contains_global_from_temp_before_call_ls
    (global source callee : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_global_from_temp_before_call_s global source callee body ||
      contains_global_from_temp_before_call_ls global source callee rest
  end.

Definition current_object_behavior_tail_source_claim : Prop :=
  contains_global_from_temp_before_call_s
    ITP_JPB._gCurrentObject JGC_Objects._firstObj ITP_JPB._cur_obj_update
    (fn_body JGC_Objects.f_update_objects_starting_at) = true /\
  contains_global_from_temp_before_call_s
    ITP_JPB._gCurrentObject JGC_Objects._firstObj ITP_JPB._cur_obj_update
    (fn_body JGC_Objects.f_update_objects_during_time_stop) = true /\
  contains_global_to_unary_call_s
    ITP_JPB._gCurrentObject ITP_JPB._obj_update_gfx_pos_and_angle
    (fn_body ITP_JPB.f_cur_obj_update) = true /\
  contains_temp_bit_guarded_call_s
    ITP_JPB._objFlags 0 ITP_JPB._obj_update_gfx_pos_and_angle
    (fn_body ITP_JPB.f_cur_obj_update) = true.

Theorem current_object_behavior_tail_source_checked :
  current_object_behavior_tail_source_claim.
Proof.
  unfold current_object_behavior_tail_source_claim.
  vm_compute. repeat split; reflexivity.
Qed.

(** The normal Mario-local flag/offset path is narrower still.  Fresh object
    allocation zeroes all 80 raw-data words, [bhvMario] contains no graphical
    Y-offset command, and its one flag command ORs 0x100 (bit 8), whose bit 0
    is clear.  The direct Mario callbacks also have no exact flag/offset
    lvalue.  These receipts do not replace the live slot/interpreter
    induction: an aliased, forged, indirect, or external store remains an
    explicit escape. *)
Definition mario_tail_flag_offset_source_claim : Prop :=
  assigns_dynamic_raw_s32_zero_s
    ITP_USSpawn._rawData ITP_USSpawn._asS32 ITP_USSpawn._i
    (fn_body ITP_USSpawn.f_allocate_object) = true /\
  assigns_dynamic_raw_s32_zero_s
    ITP_JPSpawn._rawData ITP_JPSpawn._asS32 ITP_JPSpawn._i
    (fn_body ITP_JPSpawn.f_allocate_object) = true /\
  statement_mentions_int_s 80
    (fn_body ITP_USSpawn.f_allocate_object) = true /\
  statement_mentions_int_s 80
    (fn_body ITP_JPSpawn.f_allocate_object) = true /\
  graph_y_offset_commands_in_initializer
    (gvar_init ITP_USD.v_bhvMario) = [] /\
  graph_y_offset_commands_in_initializer
    (gvar_init ITP_JPD.v_bhvMario) = [] /\
  bhv_mario_flag_and_callbacks_source_shape_us_claim /\
  bhv_mario_flag_and_callbacks_source_shape_jp_claim /\
  Z.land 256 1 = 0 /\
  assigns_nested_array_slot_s JGC_Mario._rawData JGC_Mario._asS32 1
    (fn_body JGC_Objects.f_bhv_mario_update) = false /\
  assigns_nested_array_slot_s JGC_Mario._rawData JGC_Mario._asF32 21
    (fn_body JGC_Objects.f_bhv_mario_update) = false /\
  assigns_nested_array_slot_s JGC_Mario._rawData JGC_Mario._asS32 1
    (fn_body JGC_Debug.f_try_print_debug_mario_level_info) = false /\
  assigns_nested_array_slot_s JGC_Mario._rawData JGC_Mario._asF32 21
    (fn_body JGC_Debug.f_try_print_debug_mario_level_info) = false /\
  assigns_nested_array_slot_s JGC_Mario._rawData JGC_Mario._asS32 1
    (fn_body JGC_Debug.f_try_do_mario_debug_object_spawn) = false /\
  assigns_nested_array_slot_s JGC_Mario._rawData JGC_Mario._asF32 21
    (fn_body JGC_Debug.f_try_do_mario_debug_object_spawn) = false.

Theorem mario_tail_flag_offset_source_checked :
  mario_tail_flag_offset_source_claim.
Proof.
  unfold mario_tail_flag_offset_source_claim,
    bhv_mario_flag_and_callbacks_source_shape_us_claim,
    bhv_mario_flag_and_callbacks_source_shape_jp_claim,
    bhv_mario_initializer_prefix_us, bhv_mario_initializer_prefix_jp.
  vm_compute. repeat split; reflexivity.
Qed.

(** Static call/initializer scans for the only full cross-object Graphics
    copy among the four receiver-generic Y writers. *)
Fixpoint direct_call_sites
    (callee : ident)
    (definitions : list (ident * globdef (fundef function) type)) : list ident :=
  match definitions with
  | [] => []
  | (id, Gfun (Internal body)) :: rest =>
      if calls_ident_s callee (fn_body body)
      then id :: direct_call_sites callee rest
      else direct_call_sites callee rest
  | _ :: rest => direct_call_sites callee rest
  end.

Fixpoint statement_mention_sites
    (needle : ident)
    (definitions : list (ident * globdef (fundef function) type)) : list ident :=
  match definitions with
  | [] => []
  | (id, Gfun (Internal body)) :: rest =>
      if statement_mentions_ident_s needle (fn_body body)
      then id :: statement_mention_sites needle rest
      else statement_mention_sites needle rest
  | _ :: rest => statement_mention_sites needle rest
  end.

Fixpoint initializer_owner_sites
    (needle : ident)
    (definitions : list (ident * globdef (fundef function) type)) : list ident :=
  match definitions with
  | [] => []
  | (id, Gvar variable) :: rest =>
      if initializer_list_mentions_addrof needle (gvar_init variable)
      then id :: initializer_owner_sites needle rest
      else initializer_owner_sites needle rest
  | _ :: rest => initializer_owner_sites needle rest
  end.

Definition generated_definitions_of (units : list Clight.program) :=
  concat (map (fun unit => prog_defs unit) units).

Definition is_two_globals_to_binary_call_s
    (first_global second_global callee : ident) (statement : statement) : bool :=
  match statement with
  | Ssequence
      (Sset first_temp (Evar found_first _))
      (Ssequence
        (Sset second_temp (Evar found_second _))
        (Scall _ (Evar found_callee _)
          [Etempvar first_argument _; Etempvar second_argument _])) =>
      Pos.eqb found_first first_global &&
      Pos.eqb found_second second_global &&
      Pos.eqb found_callee callee &&
      Pos.eqb first_argument first_temp &&
      Pos.eqb second_argument second_temp
  | _ => false
  end.

Fixpoint contains_two_globals_to_binary_call_s
    (first_global second_global callee : ident)
    (statement : statement) : bool :=
  match statement with
  | Ssequence first rest | Sloop first rest =>
      is_two_globals_to_binary_call_s
        first_global second_global callee statement ||
      contains_two_globals_to_binary_call_s
        first_global second_global callee first ||
      contains_two_globals_to_binary_call_s
        first_global second_global callee rest
  | Sifthenelse _ if_true if_false =>
      contains_two_globals_to_binary_call_s
        first_global second_global callee if_true ||
      contains_two_globals_to_binary_call_s
        first_global second_global callee if_false
  | Sswitch _ cases =>
      contains_two_globals_to_binary_call_ls
        first_global second_global callee cases
  | Slabel _ body =>
      contains_two_globals_to_binary_call_s
        first_global second_global callee body
  | _ => is_two_globals_to_binary_call_s
      first_global second_global callee statement
  end
with contains_two_globals_to_binary_call_ls
    (first_global second_global callee : ident)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_two_globals_to_binary_call_s
        first_global second_global callee body ||
      contains_two_globals_to_binary_call_ls
        first_global second_global callee rest
  end.

Definition anchor_call_chain_source_claim : Prop :=
  direct_call_sites ITP_JPA._obj_set_gfx_pos_at_obj_pos
    (generated_definitions_of jp_translation_units) =
      [ITP_JPA._common_anchor_mario_behavior] /\
  direct_call_sites ITP_JPA._common_anchor_mario_behavior
    (generated_definitions_of jp_translation_units) =
      [ITP_JPA._bhv_bobomb_anchor_mario_loop;
       ITP_JPA._bhv_chuckya_anchor_mario_loop] /\
  direct_call_sites ITP_USA._obj_set_gfx_pos_at_obj_pos
    (generated_definitions_of us_translation_units) =
      [ITP_USA._common_anchor_mario_behavior] /\
  direct_call_sites ITP_USA._common_anchor_mario_behavior
    (generated_definitions_of us_translation_units) =
      [ITP_USA._bhv_bobomb_anchor_mario_loop;
       ITP_USA._bhv_chuckya_anchor_mario_loop] /\
  contains_two_globals_to_binary_call_s
    ITP_JPA._gMarioObject ITP_JPA._gCurrentObject
    ITP_JPA._obj_set_gfx_pos_at_obj_pos
    (fn_body ITP_JPA.f_common_anchor_mario_behavior) = true /\
  contains_two_globals_to_binary_call_s
    ITP_USA._gMarioObject ITP_USA._gCurrentObject
    ITP_USA._obj_set_gfx_pos_at_obj_pos
    (fn_body ITP_USA.f_common_anchor_mario_behavior) = true.

Theorem anchor_call_chain_source_checked :
  anchor_call_chain_source_claim.
Proof.
  unfold anchor_call_chain_source_claim, generated_definitions_of,
    direct_call_sites.
  vm_compute. repeat split; reflexivity.
Qed.

(** The two parent scripts spawn only their corresponding anchor children,
    and the child scripts select the callbacks above. *)
Definition anchor_parent_child_initializer_source_claim : Prop :=
  initializer_addrof_subsequenceb [ITP_JPD._bhvBobombAnchorMario]
    (gvar_init ITP_JPD.v_bhvKingBobomb) = true /\
  initializer_addrof_subsequenceb [ITP_JPD._bhvChuckyaAnchorMario]
    (gvar_init ITP_JPD.v_bhvChuckya) = true /\
  initializer_addrof_subsequenceb [ITP_JPA._bhv_bobomb_anchor_mario_loop]
    (gvar_init ITP_JPD.v_bhvBobombAnchorMario) = true /\
  initializer_addrof_subsequenceb [ITP_JPA._bhv_chuckya_anchor_mario_loop]
    (gvar_init ITP_JPD.v_bhvChuckyaAnchorMario) = true /\
  initializer_addrof_subsequenceb [ITP_USD._bhvBobombAnchorMario]
    (gvar_init ITP_USD.v_bhvKingBobomb) = true /\
  initializer_addrof_subsequenceb [ITP_USD._bhvChuckyaAnchorMario]
    (gvar_init ITP_USD.v_bhvChuckya) = true /\
  initializer_addrof_subsequenceb [ITP_USA._bhv_bobomb_anchor_mario_loop]
    (gvar_init ITP_USD.v_bhvBobombAnchorMario) = true /\
  initializer_addrof_subsequenceb [ITP_USA._bhv_chuckya_anchor_mario_loop]
    (gvar_init ITP_USD.v_bhvChuckyaAnchorMario) = true.

Theorem anchor_parent_child_initializer_source_checked :
  anchor_parent_child_initializer_source_claim.
Proof.
  unfold anchor_parent_child_initializer_source_claim.
  vm_compute. repeat split; reflexivity.
Qed.

(** Neither parent behavior is selected by SSL Area 1's regular object list,
    macro-object stream, or the three selected special-object presets.  The
    whole generated C corpus also contains no direct mention capable of
    spawning either parent.  This is static provenance closure only; forged
    behavior pointers and memory corruption remain outside it. *)
Definition anchor_parent_static_area1_exclusion_claim : Prop :=
  us_area1_macro_mentions_behavior ITP_USD._bhvChuckya = false /\
  us_area1_macro_mentions_behavior ITP_USD._bhvKingBobomb = false /\
  jp_area1_macro_mentions_behavior ITP_JPD._bhvChuckya = false /\
  jp_area1_macro_mentions_behavior ITP_JPD._bhvKingBobomb = false /\
  program_initializers_mention_addrof
    ITP_USD._bhvChuckya us_ssl_script.prog = false /\
  program_initializers_mention_addrof
    ITP_USD._bhvKingBobomb us_ssl_script.prog = false /\
  program_initializers_mention_addrof
    ITP_JPD._bhvChuckya jp_ssl_script.prog = false /\
  program_initializers_mention_addrof
    ITP_JPD._bhvKingBobomb jp_ssl_script.prog = false /\
  selected_area1_special_source ITP_USD._bhvChuckya
    (gvar_init ITP_USM.v_sSpecialObjectPresets) = false /\
  selected_area1_special_source ITP_USD._bhvKingBobomb
    (gvar_init ITP_USM.v_sSpecialObjectPresets) = false /\
  selected_area1_special_source ITP_JPD._bhvChuckya
    (gvar_init ITP_JPM.v_sSpecialObjectPresets) = false /\
  selected_area1_special_source ITP_JPD._bhvKingBobomb
    (gvar_init ITP_JPM.v_sSpecialObjectPresets) = false /\
  initializer_owner_sites ITP_USD._bhvChuckya
    (generated_definitions_of us_translation_units) =
      [ITP_USM._sMacroObjectPresets] /\
  initializer_owner_sites ITP_USD._bhvKingBobomb
    (generated_definitions_of us_translation_units) = [] /\
  initializer_owner_sites ITP_JPD._bhvChuckya
    (generated_definitions_of jp_translation_units) =
      [ITP_JPM._sMacroObjectPresets] /\
  initializer_owner_sites ITP_JPD._bhvKingBobomb
    (generated_definitions_of jp_translation_units) = [] /\
  statement_mention_sites ITP_USD._bhvChuckya
    (generated_definitions_of us_translation_units) = [] /\
  statement_mention_sites ITP_USD._bhvKingBobomb
    (generated_definitions_of us_translation_units) = [] /\
  statement_mention_sites ITP_JPD._bhvChuckya
    (generated_definitions_of jp_translation_units) = [] /\
  statement_mention_sites ITP_JPD._bhvKingBobomb
    (generated_definitions_of jp_translation_units) = [].

Theorem anchor_parent_static_area1_exclusion_checked :
  anchor_parent_static_area1_exclusion_claim.
Proof.
  unfold anchor_parent_static_area1_exclusion_claim,
    generated_definitions_of, statement_mention_sites,
    initializer_owner_sites,
    selected_area1_special_source, area1_selected_special_preset_ids,
    special_preset_table_selects_behavior,
    special_preset_record_selects_behavior,
    us_area1_macro_mentions_behavior, jp_area1_macro_mentions_behavior,
    macro_list_mentions_behavior, program_initializers_mention_addrof.
  vm_compute. repeat split; reflexivity.
Qed.

(** A finite counter-witness to any claim that the timer-131 retry geometry
    itself is impossible.  At the warp-centre X/Z, a Graphics Y of 1928 is
    accepted on the modeled face.  Relative to raw Object Y 768 this is
    exactly [+1160]—well outside the complete stock command census above. *)
Definition timer131_center_high_query : Area1IntegerQuery := {|
  area1_query_x := -2048;
  area1_query_y := 1928;
  area1_query_z := -1024
|}.

Definition timer131_center_high_graphics_position : PositionZ := {|
  position_x := -2048;
  position_y := 1928;
  position_z := -1024
|}.

Definition nonstock_1160_offset_timer131_retry_claim : Prop :=
  upper_warp_contact upper_warp_center /\
  position_x timer131_center_high_graphics_position =
    position_x upper_warp_center /\
  position_z timer131_center_high_graphics_position =
    position_z upper_warp_center /\
  position_y timer131_center_high_graphics_position =
    position_y upper_warp_center + 1160 /\
  ~ In 1160 stock_graph_y_offset_command_values /\
  timer131_buffer_observation
    timer131_center_high_query timer131_retry_face =
      Some (1157276704, 1063190528, false).

Theorem nonstock_1160_offset_builds_accepted_timer131_retry :
  nonstock_1160_offset_timer131_retry_claim.
Proof.
  unfold nonstock_1160_offset_timer131_retry_claim,
    upper_warp_contact, horizontal_distance_squared,
    upper_warp_center, upper_warp_x, upper_warp_y, upper_warp_z,
    upper_warp_radius, upper_warp_height, mario_hitbox_radius,
    mario_hitbox_height, timer131_center_high_graphics_position,
    timer131_center_high_query, stock_graph_y_offset_command_values,
    timer131_buffer_observation, area1_loaded_floor_height,
    area1_loaded_floor_buffer_difference, area1_loaded_plane_for_triangle,
    area1_compute_loaded_plane, area1_source_normal_components,
    area1_source_triangle_vertices, timer131_vertices_s16,
    timer131_retry_face, area1_f32_reciprocal_via_double,
    area1_f32_of_Z, f32_of_Z.
  vm_compute. repeat split; try reflexivity; try lia; try discriminate.
Qed.

(** Checked boundary assembled for assumption auditing and documentation. *)
Definition InkTimer131ProducerCheckedBoundary : Prop :=
  stock_graph_y_offset_commands_bilateral_claim /\
  graph_y_offset_interpreter_source_claim /\
  current_object_behavior_tail_source_claim /\
  mario_tail_flag_offset_source_claim /\
  anchor_call_chain_source_claim /\
  anchor_parent_child_initializer_source_claim /\
  anchor_parent_static_area1_exclusion_claim /\
  nonstock_1160_offset_timer131_retry_claim.

Theorem ink_timer131_producer_checked_boundary_holds :
  InkTimer131ProducerCheckedBoundary.
Proof.
  unfold InkTimer131ProducerCheckedBoundary.
  split; [exact stock_graph_y_offset_commands_exact_bilateral |].
  split; [exact graph_y_offset_interpreter_source_checked |].
  split; [exact current_object_behavior_tail_source_checked |].
  split; [exact mario_tail_flag_offset_source_checked |].
  split; [exact anchor_call_chain_source_checked |].
  split; [exact anchor_parent_child_initializer_source_checked |].
  split; [exact anchor_parent_static_area1_exclusion_checked |].
  exact nonstock_1160_offset_builds_accepted_timer131_retry.
Qed.

(** What remains before this source result can decide clean retail execution. *)
Record InkTimer131ProducerRetailResidual : Type := {
  ink_live_current_is_mario_object : Prop;
  ink_mario_slot_epoch_is_preserved : Prop;
  ink_behavior_table_and_dispatch_are_faithful : Prop;
  ink_no_forged_or_indirect_behavior_command : Prop;
  ink_no_alias_oob_or_external_graphics_write : Prop;
  ink_dynamic_area1_spawn_closure_matches_static_sources : Prop;
  ink_first_null_and_retry_project_to_live_find_floor : Prop
}.
