From Coq Require Import Bool String List PArith.BinPos ZArith.
From compcert Require Import AST Clight Ctypes Integers.
From Pedro.Generated Require Import
  us_level_scripts
  us_audio_external us_graph_node us_memory us_save_file us_spawn_sound
  us_math_util us_spawn_object us_surface_collision
  us_behavior_actions us_behavior_data us_behavior_script
  us_macro_special_objects us_obj_behaviors us_obj_behaviors_2 us_object_helpers
  us_object_list_processor
  us_ttc_area1_macro us_ttc_level_script
  jp_level_scripts
  jp_audio_external jp_graph_node jp_memory jp_save_file jp_spawn_sound
  jp_math_util jp_spawn_object jp_surface_collision
  jp_behavior_actions jp_behavior_data jp_behavior_script
  jp_macro_special_objects jp_obj_behaviors jp_obj_behaviors_2 jp_object_helpers
  jp_object_list_processor
  jp_ttc_area1_macro jp_ttc_level_script.
From Pedro.Proofs Require Import
  ASTFacts DustPRNG GameTypes TTCDebugBoundary TTCRNGWindow.

Import ListNotations.
Open Scope Z_scope.

Module UCensusActions := us_behavior_actions.
Module UCensusSharedLevel := us_level_scripts.
Module UCensusAudio := us_audio_external.
Module UCensusData := us_behavior_data.
Module UCensusGraph := us_graph_node.
Module UCensusMemory := us_memory.
Module UCensusMath := us_math_util.
Module UCensusSave := us_save_file.
Module UCensusSound := us_spawn_sound.
Module UCensusSpawn := us_spawn_object.
Module UCensusCollision := us_surface_collision.
Module UCensusScript := us_behavior_script.
Module UCensusMacro := us_macro_special_objects.
Module UCensusObjects := us_obj_behaviors.
Module UCensusTTC := us_obj_behaviors_2.
Module UCensusHelpers := us_object_helpers.
Module UCensusLists := us_object_list_processor.
Module UCensusAreaMacro := us_ttc_area1_macro.
Module UCensusLevel := us_ttc_level_script.

Module JCensusActions := jp_behavior_actions.
Module JCensusSharedLevel := jp_level_scripts.
Module JCensusAudio := jp_audio_external.
Module JCensusData := jp_behavior_data.
Module JCensusGraph := jp_graph_node.
Module JCensusMemory := jp_memory.
Module JCensusMath := jp_math_util.
Module JCensusSave := jp_save_file.
Module JCensusSound := jp_spawn_sound.
Module JCensusSpawn := jp_spawn_object.
Module JCensusCollision := jp_surface_collision.
Module JCensusScript := jp_behavior_script.
Module JCensusMacro := jp_macro_special_objects.
Module JCensusObjects := jp_obj_behaviors.
Module JCensusTTC := jp_obj_behaviors_2.
Module JCensusHelpers := jp_object_helpers.
Module JCensusLists := jp_object_list_processor.
Module JCensusAreaMacro := jp_ttc_area1_macro.
Module JCensusLevel := jp_ttc_level_script.

Fixpoint init_int8_signed_values_result
    (values : list init_data) : option (list Z) :=
  match values with
  | [] => Some []
  | Init_int8 value :: rest =>
      match init_int8_signed_values_result rest with
      | Some values => Some (Int.signed value :: values)
      | None => None
      end
  | _ => None
  end.

Fixpoint init_int16_signed_values_result
    (values : list init_data) : option (list Z) :=
  match values with
  | [] => Some []
  | Init_int16 value :: rest =>
      match init_int16_signed_values_result rest with
      | Some values => Some (Int.signed value :: values)
      | None => None
      end
  | _ => None
  end.

Definition ptrofs_is_zero (offset : ptrofs) : bool :=
  if Ptrofs.eq_dec offset (Ptrofs.repr 0) then true else false.

Definition generated_object_list_update_order_result
    (version : GameVersion) : option (list Z) :=
  match version with
  | VersionUS =>
      init_int8_signed_values_result
        (gvar_init UCensusLists.v_sObjectListUpdateOrder)
  | VersionJP =>
      init_int8_signed_values_result
        (gvar_init JCensusLists.v_sObjectListUpdateOrder)
  end.

Definition generated_object_list_update_order
    (version : GameVersion) : list Z :=
  match generated_object_list_update_order_result version with
  | Some order => order
  | None => []
  end.

Definition ttc_exact_macro_words_result
    (version : GameVersion) : option (list Z) :=
  match version with
  | VersionUS =>
      init_int16_signed_values_result
        (gvar_init UCensusAreaMacro.v_ttc_seg7_macro_objs)
  | VersionJP =>
      init_int16_signed_values_result
        (gvar_init JCensusAreaMacro.v_ttc_seg7_macro_objs)
  end.

Definition ttc_exact_macro_words (version : GameVersion) : list Z :=
  match ttc_exact_macro_words_result version with
  | Some words => words
  | None => []
  end.

Definition ttc_exact_macro_records (version : GameVersion) : list (list Z) :=
  chunks5 (ttc_exact_macro_words version).

(** The generated [struct MacroPreset] initializer is a repeated
    pointer/halfword/halfword triple.  This parser deliberately fails closed:
    any different initializer shape yields no further behavior identifiers. *)
Fixpoint macro_preset_behavior_ids_result
    (values : list init_data) : option (list ident) :=
  match values with
  | Init_addrof behavior offset :: Init_int16 _ :: Init_int16 _ :: rest =>
      if ptrofs_is_zero offset
      then
        match macro_preset_behavior_ids_result rest with
        | Some behaviors => Some (behavior :: behaviors)
        | None => None
        end
      else None
  | [] => Some []
  | _ => None
  end.

Definition macro_preset_behaviors_result
    (version : GameVersion) : option (list ident) :=
  match version with
  | VersionUS =>
      macro_preset_behavior_ids_result
        (gvar_init UCensusMacro.v_sMacroObjectPresets)
  | VersionJP =>
      macro_preset_behavior_ids_result
        (gvar_init JCensusMacro.v_sMacroObjectPresets)
  end.

Definition macro_preset_behaviors (version : GameVersion) : list ident :=
  match macro_preset_behaviors_result version with
  | Some behaviors => behaviors
  | None => []
  end.

Definition macro_code_behavior
    (version : GameVersion) (code : Z) : option ident :=
  if 31 <=? code
  then nth_error (macro_preset_behaviors version) (Z.to_nat (code - 31))
  else None.

Definition ttc_macro_behavior_options
    (version : GameVersion) : list (option ident) :=
  map (fun record => macro_code_behavior version (macro_record_code record))
    (ttc_exact_macro_records version).

Fixpoint resolved_behavior_ids (behaviors : list (option ident)) : list ident :=
  match behaviors with
  | [] => []
  | Some behavior :: rest => behavior :: resolved_behavior_ids rest
  | None :: rest => resolved_behavior_ids rest
  end.

Fixpoint unresolved_behavior_count (behaviors : list (option ident)) : nat :=
  match behaviors with
  | [] => O
  | Some _ :: rest => unresolved_behavior_count rest
  | None :: rest => S (unresolved_behavior_count rest)
  end.

Definition ttc_macro_behavior_ids (version : GameVersion) : list ident :=
  resolved_behavior_ids (ttc_macro_behavior_options version).

Fixpoint find_global_variable_initializer
    (wanted : ident)
    (definitions : list (ident * globdef Clight.fundef type))
    : option (list init_data) :=
  match definitions with
  | [] => None
  | (found, Gvar variable) :: rest =>
      if Pos.eqb wanted found
      then Some (gvar_init variable)
      else find_global_variable_initializer wanted rest
  | _ :: rest => find_global_variable_initializer wanted rest
  end.

Definition behavior_initializer
    (version : GameVersion) (behavior : ident) : option (list init_data) :=
  match version with
  | VersionUS =>
      find_global_variable_initializer behavior (prog_defs UCensusData.prog)
  | VersionJP =>
      find_global_variable_initializer behavior (prog_defs JCensusData.prog)
  end.

(** [create_object] extracts bits 16--31 when the first behavior opcode is
    [BEGIN] (zero), and otherwise inserts the object into [OBJ_LIST_DEFAULT]
    (enum value 8).  The latter case matters for TTC's [bhvSpinAirborneWarp], whose
    one-word script is [BREAK]. *)
Definition behavior_object_list
    (version : GameVersion) (behavior : ident) : option Z :=
  match behavior_initializer version behavior with
  | Some (Init_int32 word :: _) =>
      if Z.eqb (Z.shiftr (Int.unsigned word) 24) 0
      then Some (Z.land (Z.shiftr (Int.unsigned word) 16) 65535)
      else Some 8
  | _ => None
  end.

Definition ttc_macro_object_lists (version : GameVersion) : list (option Z) :=
  map (behavior_object_list version) (ttc_macro_behavior_ids version).

Definition count_object_list
    (wanted : Z) (lists : list (option Z)) : nat :=
  length
    (filter
      (fun found =>
        match found with
        | Some value => Z.eqb value wanted
        | None => false
        end)
      lists).

Definition unresolved_object_lists (lists : list (option Z)) : nat :=
  length
    (filter
      (fun found =>
        match found with Some _ => false | None => true end)
      lists).

(** Scratch-visible computation targets; the proved theorem below records
    their stable values without retaining [Eval] output in the source. *)
Definition ttc_macro_phase_census (version : GameVersion) : list nat :=
  map
    (fun object_list => count_object_list object_list
      (ttc_macro_object_lists version))
    [11; 9; 10; 0; 5; 4; 2; 6; 8; 12].

Theorem generated_ttc_macro_behavior_resolution_complete_us_jp :
  forall version,
    ttc_exact_macro_words_result version =
      Some (ttc_exact_macro_words version) /\
    macro_preset_behaviors_result version =
      Some (macro_preset_behaviors version) /\
    length (macro_preset_behaviors version) = 366%nat /\
    length (ttc_exact_macro_words version) = 551%nat /\
    skipn 550 (ttc_exact_macro_words version) = [30] /\
    length (ttc_exact_macro_records version) = 110%nat /\
    length (ttc_macro_behavior_options version) = 110%nat /\
    unresolved_behavior_count (ttc_macro_behavior_options version) = 0%nat /\
    length (ttc_macro_behavior_ids version) = 110%nat /\
    unresolved_object_lists (ttc_macro_object_lists version) = 0%nat.
Proof. intros []; vm_compute; repeat split; reflexivity. Qed.

(* Expected value discovered by evaluating the generated initializers. *)
Theorem generated_ttc_macro_phase_census_us_jp :
  forall version,
    ttc_macro_phase_census version = [1; 78; 0; 0; 0; 5; 2; 24; 0; 0]%nat.
Proof. intros []; vm_compute; reflexivity. Qed.

(** * Generated behavior/native call census *)

Definition command_opcode (word : int) : Z :=
  Z.shiftr (Int.unsigned word) 24.

(** The pinned [data/behavior_data.c] macro definitions determine the exact
    number and shape of generated [BehaviorScript] words for opcodes 0--55.
    Parsing only at those command boundaries is essential: argument words can
    have high bytes that look like CALL, GOTO, CALL_NATIVE, or a random opcode.
    Unknown opcodes, truncated commands, and unexpected relocation shapes all
    fail closed.  This TTC-local census also requires every relocation to have
    offset zero.  Thus a reachable [GOTO(script + n)] is rejected rather than
    silently approximated; the generated closure theorem proves that no such
    offset occurs among the stock TTC descriptors in this scope. *)
Definition z_inb (needle : Z) (values : list Z) : bool :=
  existsb (Z.eqb needle) values.

Definition behavior_command_entry_count (opcode : Z) : option nat :=
  if (0 <=? opcode) && (opcode <=? 55)
  then
    if z_inb opcode
         [2; 4; 12; 19; 20; 21; 22; 23; 35; 39; 42; 46; 47; 49; 51; 54; 55]
    then Some 2%nat
    else if z_inb opcode [28; 41; 43; 44]
    then Some 3%nat
    else if Z.eqb opcode 48
    then Some 5%nat
    else Some 1%nat
  else None.

Record behavior_script_scan := {
  behavior_scan_targets : list ident;
  behavior_scan_natives : list ident;
  behavior_scan_has_random : bool
}.

Definition empty_behavior_script_scan : behavior_script_scan :=
  {| behavior_scan_targets := [];
     behavior_scan_natives := [];
     behavior_scan_has_random := false |}.

Definition append_behavior_script_scan
    (first rest : behavior_script_scan) : behavior_script_scan :=
  {| behavior_scan_targets :=
       behavior_scan_targets first ++ behavior_scan_targets rest;
     behavior_scan_natives :=
       behavior_scan_natives first ++ behavior_scan_natives rest;
     behavior_scan_has_random :=
       (behavior_scan_has_random first ||
        behavior_scan_has_random rest)%bool |}.

Definition all_init_int32 (values : list init_data) : bool :=
  forallb
    (fun value =>
      match value with Init_int32 _ => true | _ => false end)
    values.

Definition behavior_command_scan
    (word : int) (command : list init_data)
    : option behavior_script_scan :=
  let opcode := command_opcode word in
  if z_inb opcode [2; 4]
  then
    match command with
    | Init_int32 _ :: Init_addrof target offset :: [] =>
        if ptrofs_is_zero offset
        then
          Some
            {| behavior_scan_targets := [target];
               behavior_scan_natives := [];
               behavior_scan_has_random := false |}
        else None
    | _ => None
    end
  else if Z.eqb opcode 12
  then
    match command with
    | Init_int32 _ :: Init_addrof native offset :: [] =>
        if ptrofs_is_zero offset
        then
          Some
            {| behavior_scan_targets := [];
               behavior_scan_natives := [native];
               behavior_scan_has_random := false |}
        else None
    | _ => None
    end
  else if z_inb opcode [39; 42; 55]
  then
    match command with
    | Init_int32 _ :: Init_addrof _ offset :: [] =>
        if ptrofs_is_zero offset
        then Some empty_behavior_script_scan
        else None
    | _ => None
    end
  else if z_inb opcode [28; 41; 44]
  then
    match command with
    | Init_int32 _ :: Init_int32 _ :: Init_addrof _ offset :: [] =>
        if ptrofs_is_zero offset
        then Some empty_behavior_script_scan
        else None
    | _ => None
    end
  else if all_init_int32 command
  then
    Some
      {| behavior_scan_targets := [];
         behavior_scan_natives := [];
         behavior_scan_has_random :=
           ((19 <=? opcode) && (opcode <=? 23))%bool |}
  else None.

Fixpoint parse_behavior_script
    (fuel : nat) (values : list init_data)
    : option behavior_script_scan :=
  match values with
  | [] => Some empty_behavior_script_scan
  | Init_int32 word :: _ =>
      match fuel with
      | O => None
      | S remaining =>
          match behavior_command_entry_count (command_opcode word) with
          | None => None
          | Some count =>
              if Nat.leb count (length values)
              then
                match behavior_command_scan word (firstn count values),
                      parse_behavior_script remaining (skipn count values) with
                | Some command_scan, Some rest_scan =>
                    Some (append_behavior_script_scan command_scan rest_scan)
                | _, _ => None
                end
              else None
          end
      end
  | _ => None
  end.

Definition behavior_script_scan_result
    (version : GameVersion) (behavior : ident)
    : option behavior_script_scan :=
  match behavior_initializer version behavior with
  | Some values => parse_behavior_script (length values) values
  | None => None
  end.

(** Behavior bytecode [CALL] and [GOTO] are opcodes 2 and 4.  Following these
    edges is necessary before collecting [CALL_NATIVE] roots: a top-level
    stock behavior can delegate its loop to a separate behavior array. *)
Definition behavior_script_targets
    (version : GameVersion) (behavior : ident) : list ident :=
  match behavior_script_scan_result version behavior with
  | Some scan => behavior_scan_targets scan
  | None => []
  end.

(** [CALL_NATIVE] is opcode 12 and its relocation is decoded only when it is
    the second word of a complete command. *)
Definition behavior_native_calls
    (version : GameVersion) (behavior : ident) : list ident :=
  match behavior_script_scan_result version behavior with
  | Some scan => behavior_scan_natives scan
  | None => []
  end.

Definition behavior_pointer_commands_valid
    (version : GameVersion) (behavior : ident) : bool :=
  match behavior_script_scan_result version behavior with
  | Some _ => true
  | None => false
  end.

Definition add_behavior_script_targets
    (version : GameVersion) (reached : list ident) : list ident :=
  nodup Pos.eq_dec
    (reached ++ flat_map (behavior_script_targets version) reached).

Fixpoint close_behavior_scripts
    (fuel : nat) (version : GameVersion) (reached : list ident) : list ident :=
  match fuel with
  | O => reached
  | S remaining =>
      close_behavior_scripts remaining version
        (add_behavior_script_targets version reached)
  end.

Definition behavior_has_random_command
    (version : GameVersion) (behavior : ident) : bool :=
  match behavior_script_scan_result version behavior with
  | Some scan => behavior_scan_has_random scan
  | None => false
  end.

Fixpoint internal_function_definitions
    (definitions : list (ident * globdef Clight.fundef type))
    : list (ident * function) :=
  match definitions with
  | [] => []
  | (name, Gfun (Internal body)) :: rest =>
      (name, body) :: internal_function_definitions rest
  | _ :: rest => internal_function_definitions rest
  end.

Fixpoint has_named_external_function
    (wanted : ident) (external_name : string)
    (definitions : list (ident * globdef Clight.fundef type)) : bool :=
  match definitions with
  | [] => false
  | (found, Gfun (External (EF_external found_name _) _ _ _)) :: rest =>
      if Pos.eqb wanted found
      then String.eqb external_name found_name
      else has_named_external_function wanted external_name rest
  | _ :: rest => has_named_external_function wanted external_name rest
  end.

Definition census_internal_functions
    (version : GameVersion) : list (ident * function) :=
  match version with
  | VersionUS =>
      internal_function_definitions (prog_defs UCensusAudio.prog) ++
      internal_function_definitions (prog_defs UCensusGraph.prog) ++
      internal_function_definitions (prog_defs UCensusMemory.prog) ++
      internal_function_definitions (prog_defs UCensusSave.prog) ++
      internal_function_definitions (prog_defs UCensusSound.prog) ++
      internal_function_definitions (prog_defs UCensusMath.prog) ++
      internal_function_definitions (prog_defs UCensusSpawn.prog) ++
      internal_function_definitions (prog_defs UCensusCollision.prog) ++
      internal_function_definitions (prog_defs UCensusActions.prog) ++
      internal_function_definitions (prog_defs UCensusObjects.prog) ++
      internal_function_definitions (prog_defs UCensusTTC.prog) ++
      internal_function_definitions (prog_defs UCensusHelpers.prog) ++
      internal_function_definitions (prog_defs UCensusLists.prog) ++
      internal_function_definitions (prog_defs UCensusScript.prog)
  | VersionJP =>
      internal_function_definitions (prog_defs JCensusAudio.prog) ++
      internal_function_definitions (prog_defs JCensusGraph.prog) ++
      internal_function_definitions (prog_defs JCensusMemory.prog) ++
      internal_function_definitions (prog_defs JCensusSave.prog) ++
      internal_function_definitions (prog_defs JCensusSound.prog) ++
      internal_function_definitions (prog_defs JCensusMath.prog) ++
      internal_function_definitions (prog_defs JCensusSpawn.prog) ++
      internal_function_definitions (prog_defs JCensusCollision.prog) ++
      internal_function_definitions (prog_defs JCensusActions.prog) ++
      internal_function_definitions (prog_defs JCensusObjects.prog) ++
      internal_function_definitions (prog_defs JCensusTTC.prog) ++
      internal_function_definitions (prog_defs JCensusHelpers.prog) ++
      internal_function_definitions (prog_defs JCensusLists.prog) ++
      internal_function_definitions (prog_defs JCensusScript.prog)
  end.

Definition function_names (functions : list (ident * function)) : list ident :=
  map fst functions.

Definition identifier_in (identifier : ident) (identifiers : list ident) : bool :=
  existsb (Pos.eqb identifier) identifiers.

(** A duplicate generated function name would make the concatenated
    cross-translation-unit graph ambiguous.  Equality with [nodup] is a
    compact decidable certificate of [NoDup] for the exact generated list. *)
Definition census_function_names_are_unique
    (version : GameVersion) : Prop :=
  nodup Pos.eq_dec (function_names (census_internal_functions version)) =
  function_names (census_internal_functions version).

Definition generated_function_callgraph
    (functions : list (ident * function)) : list (ident * list ident) :=
  map
    (fun entry => (fst entry, direct_callees_s (fn_body (snd entry))))
    functions.

Definition callgraph_entry_calls_any
    (reached : list ident) (entry : ident * list ident) : bool :=
  existsb
    (fun callee => identifier_in callee reached)
    (snd entry).

Definition add_rng_callers_in
    (callgraph : list (ident * list ident))
    (reached : list ident) : list ident :=
  nodup Pos.eq_dec
    (reached ++
      map fst (filter (callgraph_entry_calls_any reached) callgraph)).

Fixpoint close_rng_callers_in
    (fuel : nat) (callgraph : list (ident * list ident))
    (reached : list ident) : list ident :=
  match fuel with
  | O => reached
  | S remaining =>
      close_rng_callers_in remaining callgraph
        (add_rng_callers_in callgraph reached)
  end.

Definition add_rng_callers
    (functions : list (ident * function)) (reached : list ident) : list ident :=
  add_rng_callers_in (generated_function_callgraph functions) reached.

Definition close_rng_callers
    (fuel : nat) (functions : list (ident * function))
    (reached : list ident) : list ident :=
  close_rng_callers_in fuel (generated_function_callgraph functions) reached.

Definition random_u16_identifier (version : GameVersion) : ident :=
  match version with
  | VersionUS => UCensusScript._random_u16
  | VersionJP => JCensusScript._random_u16
  end.

Definition random_seed_identifier (version : GameVersion) : ident :=
  match version with
  | VersionUS => UCensusScript._gRandomSeed16
  | VersionJP => JCensusScript._gRandomSeed16
  end.

Definition behavior_script_internal_functions
    (version : GameVersion) : list (ident * function) :=
  match version with
  | VersionUS => internal_function_definitions (prog_defs UCensusScript.prog)
  | VersionJP => internal_function_definitions (prog_defs JCensusScript.prog)
  end.

Definition behavior_script_public_identifiers
    (version : GameVersion) : list ident :=
  match version with
  | VersionUS => prog_public UCensusScript.prog
  | VersionJP => prog_public JCensusScript.prog
  end.

Fixpoint global_lvalue_write_count_s
    (global : ident) (body : statement) : nat :=
  match body with
  | Sassign destination _ =>
      if expression_mentions_ident global destination then 1%nat else O
  | Ssequence first second | Sloop first second =>
      (global_lvalue_write_count_s global first +
       global_lvalue_write_count_s global second)%nat
  | Sifthenelse _ yes no =>
      (global_lvalue_write_count_s global yes +
       global_lvalue_write_count_s global no)%nat
  | Slabel _ nested => global_lvalue_write_count_s global nested
  | Sswitch _ cases => global_lvalue_write_count_ls global cases
  | _ => O
  end
with global_lvalue_write_count_ls
    (global : ident) (cases : labeled_statements) : nat :=
  match cases with
  | LSnil => O
  | LScons _ body rest =>
      (global_lvalue_write_count_s global body +
       global_lvalue_write_count_ls global rest)%nat
  end.

Definition random_seed_mentioning_functions
    (version : GameVersion) : list ident :=
  map fst
    (filter
      (fun entry =>
        statement_mentions_ident_s (random_seed_identifier version)
          (fn_body (snd entry)))
      (behavior_script_internal_functions version)).

Definition random_seed_writing_functions
    (version : GameVersion) : list ident :=
  map fst
    (filter
      (fun entry =>
        negb (Nat.eqb
          (global_lvalue_write_count_s (random_seed_identifier version)
            (fn_body (snd entry))) O))
      (behavior_script_internal_functions version)).

Definition random_seed_syntactic_write_count
    (version : GameVersion) : nat :=
  sum_nat
    (map
      (fun entry =>
        global_lvalue_write_count_s (random_seed_identifier version)
          (fn_body (snd entry)))
      (behavior_script_internal_functions version)).

Definition definition_count
    (wanted : ident)
    (definitions : list (ident * globdef Clight.fundef type)) : nat :=
  count_occ Pos.eq_dec (map fst definitions) wanted.

Definition random_seed_definition_count (version : GameVersion) : nat :=
  match version with
  | VersionUS =>
      definition_count UCensusScript._gRandomSeed16
        (prog_defs UCensusScript.prog)
  | VersionJP =>
      definition_count JCensusScript._gRandomSeed16
        (prog_defs JCensusScript.prog)
  end.

Fixpoint global_initializer_addrof_identifiers
    (definitions : list (ident * globdef Clight.fundef type)) : list ident :=
  match definitions with
  | [] => []
  | (_, Gvar variable) :: rest =>
      initializer_addrof_idents (gvar_init variable) ++
      global_initializer_addrof_identifiers rest
  | _ :: rest => global_initializer_addrof_identifiers rest
  end.

Definition random_seed_initializer_reference_count
    (version : GameVersion) : nat :=
  match version with
  | VersionUS =>
      count_occ Pos.eq_dec
        (global_initializer_addrof_identifiers (prog_defs UCensusScript.prog))
        UCensusScript._gRandomSeed16
  | VersionJP =>
      count_occ Pos.eq_dec
        (global_initializer_addrof_identifiers (prog_defs JCensusScript.prog))
        JCensusScript._gRandomSeed16
  end.

(** Eight reverse-callgraph rounds are enough for the selected generated TTC
    scheduler/behavior units.  [rng_caller_closure_is_stable] below is the
    generated certificate that the finite computation reached a fixed point;
    the number eight is not used as an unproved depth assumption. *)
Definition rng_reaching_functions (version : GameVersion) : list ident :=
  let functions := census_internal_functions version in
  close_rng_callers 8 functions [random_u16_identifier version].

Definition rng_caller_closure_is_stable (version : GameVersion) : Prop :=
  add_rng_callers
    (census_internal_functions version)
    (rng_reaching_functions version) = rng_reaching_functions version.

(** Classification is descriptor-local.  In particular, a [CALL] or [GOTO]
    edge cannot hide a random bytecode command or a [CALL_NATIVE] root in a
    different behavior array.  The finite-closure theorem below separately
    proves that all of these target arrays resolve and that eight rounds are a
    fixed point. *)
Definition behavior_closed_scripts
    (version : GameVersion) (behavior : ident) : list ident :=
  close_behavior_scripts 8 version [behavior].

(** LevelScript commands store their byte length in bits 16--23.  Parsing by
    that generated length distinguishes OBJECT/MARIO behavior operands from
    model, collision, function, and subscript pointers.  A zero, non-word, or
    truncated command fails the parse; OBJECT, MARIO, and script-control
    opcodes additionally require the exact target-operand relocation position
    and a zero offset.
    Other commands are only length-delimited here.  In particular, native
    CALL/CALL_LOOP execution belongs to the separate linked-chain proof. *)
Definition level_command_size_bytes (word : int) : Z :=
  Z.land (Z.shiftr (Int.unsigned word) 16) 255.

Definition level_command_opcode (word : int) : Z :=
  Z.shiftr (Int.unsigned word) 24.

Definition level_command_behavior_operand
    (word : int) (command : list init_data) : option (option ident) :=
  let opcode := level_command_opcode word in
  if Z.eqb opcode 36
  then
    match command with
    | Init_int32 _ :: _ :: _ :: _ :: _ ::
        Init_addrof behavior offset :: [] =>
        if ptrofs_is_zero offset then Some (Some behavior) else None
    | _ => None
    end
  else if Z.eqb opcode 37
  then
    match command with
    | Init_int32 _ :: _ :: Init_addrof behavior offset :: [] =>
        if ptrofs_is_zero offset then Some (Some behavior) else None
    | _ => None
    end
  else Some None.

Fixpoint parse_level_script_behavior_ids
    (fuel : nat) (values : list init_data) : option (list ident) :=
  match values with
  | [] => Some []
  | _ =>
      match fuel with
      | O => None
      | S remaining =>
          match values with
          | Init_int32 word :: _ =>
              let size := level_command_size_bytes word in
              if (negb (Z.eqb size 0) &&
                  Z.eqb (Z.modulo size 4) 0)%bool
              then
                let count := Z.to_nat (Z.div size 4) in
                if Nat.leb count (length values)
                then
                  match level_command_behavior_operand
                          word (firstn count values),
                        parse_level_script_behavior_ids
                          remaining (skipn count values) with
                  | Some (Some behavior), Some rest => Some (behavior :: rest)
                  | Some None, Some rest => Some rest
                  | _, _ => None
                  end
                else None
              else None
          | _ => None
          end
      end
  end.

Definition parse_level_script_initializer
    (values : list init_data) : option (list ident) :=
  parse_level_script_behavior_ids (length values) values.

Definition level_command_script_target_operand
    (word : int) (command : list init_data) : option (option ident) :=
  let opcode := level_command_opcode word in
  if (Z.eqb opcode 0 || Z.eqb opcode 1)%bool
  then
    match command with
    | Init_int32 _ :: _ :: _ :: Init_addrof target offset :: [] =>
        if ptrofs_is_zero offset then Some (Some target) else None
    | _ => None
    end
  else if (Z.eqb opcode 5 || Z.eqb opcode 6)%bool
  then
    match command with
    | Init_int32 _ :: Init_addrof target offset :: [] =>
        if ptrofs_is_zero offset then Some (Some target) else None
    | _ => None
    end
  else if (Z.eqb opcode 12 || Z.eqb opcode 13)%bool
  then
    match command with
    | Init_int32 _ :: _ :: Init_addrof target offset :: [] =>
        if ptrofs_is_zero offset then Some (Some target) else None
    | _ => None
    end
  else Some None.

Fixpoint parse_level_script_control_target_ids
    (fuel : nat) (values : list init_data) : option (list ident) :=
  match values with
  | [] => Some []
  | _ =>
      match fuel with
      | O => None
      | S remaining =>
          match values with
          | Init_int32 word :: _ =>
              let size := level_command_size_bytes word in
              if (negb (Z.eqb size 0) &&
                  Z.eqb (Z.modulo size 4) 0)%bool
              then
                let count := Z.to_nat (Z.div size 4) in
                if Nat.leb count (length values)
                then
                  match level_command_script_target_operand
                          word (firstn count values),
                        parse_level_script_control_target_ids
                          remaining (skipn count values) with
                  | Some (Some target), Some rest => Some (target :: rest)
                  | Some None, Some rest => Some rest
                  | _, _ => None
                  end
                else None
              else None
          | _ => None
          end
      end
  end.

Definition parse_level_script_control_targets
    (values : list init_data) : option (list ident) :=
  parse_level_script_control_target_ids (length values) values.

Definition ttc_level_script_behavior_ids_result
    (version : GameVersion) : option (list ident) :=
  match version with
  | VersionUS =>
      match
        parse_level_script_initializer
          (gvar_init UCensusLevel.v_level_ttc_entry),
        parse_level_script_initializer
          (gvar_init UCensusLevel.v_script_func_local_1),
        parse_level_script_initializer
          (gvar_init UCensusLevel.v_script_func_local_2)
      with
      | Some entry, Some local1, Some local2 =>
          Some (entry ++ local1 ++ local2)
      | _, _, _ => None
      end
  | VersionJP =>
      match
        parse_level_script_initializer
          (gvar_init JCensusLevel.v_level_ttc_entry),
        parse_level_script_initializer
          (gvar_init JCensusLevel.v_script_func_local_1),
        parse_level_script_initializer
          (gvar_init JCensusLevel.v_script_func_local_2)
      with
      | Some entry, Some local1, Some local2 =>
          Some (entry ++ local1 ++ local2)
      | _, _, _ => None
      end
  end.

Definition ttc_level_entry_control_targets_result
    (version : GameVersion) : option (list ident) :=
  match version with
  | VersionUS =>
      parse_level_script_control_targets
        (gvar_init UCensusLevel.v_level_ttc_entry)
  | VersionJP =>
      parse_level_script_control_targets
        (gvar_init JCensusLevel.v_level_ttc_entry)
  end.

Definition expected_ttc_level_entry_control_targets
    (version : GameVersion) : list ident :=
  match version with
  | VersionUS =>
      [UCensusSharedLevel._script_func_global_1;
       UCensusSharedLevel._script_func_global_2;
       UCensusLevel._script_func_local_1;
       UCensusLevel._script_func_local_2]
  | VersionJP =>
      [JCensusSharedLevel._script_func_global_1;
       JCensusSharedLevel._script_func_global_2;
       JCensusLevel._script_func_local_1;
       JCensusLevel._script_func_local_2]
  end.

Definition ttc_shared_level_behavior_ids_result
    (version : GameVersion) : option (list ident * list ident) :=
  match version with
  | VersionUS =>
      match
        parse_level_script_initializer
          (gvar_init UCensusSharedLevel.v_script_func_global_1),
        parse_level_script_initializer
          (gvar_init UCensusSharedLevel.v_script_func_global_2)
      with
      | Some global1, Some global2 => Some (global1, global2)
      | _, _ => None
      end
  | VersionJP =>
      match
        parse_level_script_initializer
          (gvar_init JCensusSharedLevel.v_script_func_global_1),
        parse_level_script_initializer
          (gvar_init JCensusSharedLevel.v_script_func_global_2)
      with
      | Some global1, Some global2 => Some (global1, global2)
      | _, _ => None
      end
  end.

Definition ttc_shared_level_control_targets_result
    (version : GameVersion) : option (list ident * list ident) :=
  match version with
  | VersionUS =>
      match
        parse_level_script_control_targets
          (gvar_init UCensusSharedLevel.v_script_func_global_1),
        parse_level_script_control_targets
          (gvar_init UCensusSharedLevel.v_script_func_global_2)
      with
      | Some global1, Some global2 => Some (global1, global2)
      | _, _ => None
      end
  | VersionJP =>
      match
        parse_level_script_control_targets
          (gvar_init JCensusSharedLevel.v_script_func_global_1),
        parse_level_script_control_targets
          (gvar_init JCensusSharedLevel.v_script_func_global_2)
      with
      | Some global1, Some global2 => Some (global1, global2)
      | _, _ => None
      end
  end.

Definition ttc_local_level_control_targets_result
    (version : GameVersion) : option (list ident * list ident) :=
  match version with
  | VersionUS =>
      match
        parse_level_script_control_targets
          (gvar_init UCensusLevel.v_script_func_local_1),
        parse_level_script_control_targets
          (gvar_init UCensusLevel.v_script_func_local_2)
      with
      | Some local1, Some local2 => Some (local1, local2)
      | _, _ => None
      end
  | VersionJP =>
      match
        parse_level_script_control_targets
          (gvar_init JCensusLevel.v_script_func_local_1),
        parse_level_script_control_targets
          (gvar_init JCensusLevel.v_script_func_local_2)
      with
      | Some local1, Some local2 => Some (local1, local2)
      | _, _ => None
      end
  end.

Definition expected_ttc_level_script_behavior_ids
    (version : GameVersion) : list ident :=
  match version with
  | VersionUS =>
      [UCensusData._bhvMario; UCensusData._bhvSpinAirborneWarp;
       UCensusData._bhvPoleGrabbing; UCensusData._bhvThwomp;
       UCensusData._bhvStar; UCensusData._bhvStar; UCensusData._bhvStar;
       UCensusData._bhvStar; UCensusData._bhvStar;
       UCensusData._bhvHiddenRedCoinStar]
  | VersionJP =>
      [JCensusData._bhvMario; JCensusData._bhvSpinAirborneWarp;
       JCensusData._bhvPoleGrabbing; JCensusData._bhvThwomp;
       JCensusData._bhvStar; JCensusData._bhvStar; JCensusData._bhvStar;
       JCensusData._bhvStar; JCensusData._bhvStar;
       JCensusData._bhvHiddenRedCoinStar]
  end.

Definition ttc_area_behavior_ids (version : GameVersion) : list ident :=
  match ttc_level_script_behavior_ids_result version with
  | Some behaviors => behaviors
  | None => []
  end.

Definition ttc_static_behavior_ids (version : GameVersion) : list ident :=
  ttc_area_behavior_ids version ++ ttc_macro_behavior_ids version.

Definition is_after_player_object_list (object_list : option Z) : bool :=
  match object_list with
  | Some value =>
      existsb (Z.eqb value) [5; 4; 2; 6; 8; 12]
  | None => false
  end.

Definition behaviors_in_object_list
    (version : GameVersion) (wanted : Z) (behaviors : list ident) : list ident :=
  filter
    (fun behavior =>
      match behavior_object_list version behavior with
      | Some found => Z.eqb found wanted
      | None => false
      end)
    behaviors.

(** This is scheduler order, not source descriptor order. *)
Definition ttc_static_after_player_behavior_ids
    (version : GameVersion) : list ident :=
  flat_map
    (fun object_list =>
      behaviors_in_object_list version object_list
        (ttc_static_behavior_ids version))
    [5; 4; 2; 6; 8; 12].

Definition ttc_after_player_behavior_closure
    (version : GameVersion) : list ident :=
  close_behavior_scripts 8 version
    (ttc_static_after_player_behavior_ids version).

Fixpoint identifier_list_eqb (left right : list ident) : bool :=
  match left, right with
  | [], [] => true
  | left_head :: left_tail, right_head :: right_tail =>
      Pos.eqb left_head right_head &&
      identifier_list_eqb left_tail right_tail
  | _, _ => false
  end.

Definition behavior_initializer_resolves
    (version : GameVersion) (behavior : ident) : bool :=
  match behavior_initializer version behavior with
  | Some _ => true
  | None => false
  end.

Definition descriptor_behavior_closure_valid
    (version : GameVersion) (behavior : ident) : bool :=
  let scripts := behavior_closed_scripts version behavior in
  identifier_list_eqb
    (add_behavior_script_targets version scripts) scripts &&
  forallb (behavior_initializer_resolves version) scripts &&
  forallb (behavior_pointer_commands_valid version) scripts.

Definition invalid_after_player_descriptor_behavior_closures
    (version : GameVersion) : list ident :=
  filter
    (fun behavior => negb (descriptor_behavior_closure_valid version behavior))
    (ttc_static_after_player_behavior_ids version).

Definition after_player_behavior_closure_is_stable
    (version : GameVersion) : Prop :=
  add_behavior_script_targets version
    (ttc_after_player_behavior_closure version) =
  ttc_after_player_behavior_closure version.

Definition unresolved_after_player_behavior_targets
    (version : GameVersion) : list ident :=
  filter
    (fun behavior =>
      match behavior_initializer version behavior with
      | Some _ => false
      | None => true
      end)
    (ttc_after_player_behavior_closure version).

Definition ttc_after_player_behavior_native_roots
    (version : GameVersion) : list ident :=
  nodup Pos.eq_dec
    (flat_map (behavior_native_calls version)
      (ttc_after_player_behavior_closure version)).

(** The one reached indirect native dispatch is the Heave-Ho action table.
    Its four table entries are generated data, not a hand-written whitelist;
    adding them to the forward roots makes their own direct-call closure part
    of the same fail-closed computation. *)
Definition heave_ho_action_targets (version : GameVersion) : list ident :=
  match version with
  | VersionUS =>
      initializer_addrof_idents (gvar_init UCensusActions.v_sHeaveHoActions)
  | VersionJP =>
      initializer_addrof_idents (gvar_init JCensusActions.v_sHeaveHoActions)
  end.

Definition expected_heave_ho_action_targets
    (version : GameVersion) : list ident :=
  match version with
  | VersionUS =>
      [UCensusActions._heave_ho_act_0; UCensusActions._heave_ho_act_1;
       UCensusActions._heave_ho_act_2; UCensusActions._heave_ho_act_3]
  | VersionJP =>
      [JCensusActions._heave_ho_act_0; JCensusActions._heave_ho_act_1;
       JCensusActions._heave_ho_act_2; JCensusActions._heave_ho_act_3]
  end.

Definition expected_heave_ho_action_initializer
    (version : GameVersion) : list init_data :=
  map (fun target => Init_addrof target (Ptrofs.repr 0))
    (expected_heave_ho_action_targets version).

Definition heave_ho_loop_identifier (version : GameVersion) : ident :=
  match version with
  | VersionUS => UCensusActions._bhv_heave_ho_loop
  | VersionJP => JCensusActions._bhv_heave_ho_loop
  end.

Definition behavior_decoded_native_roots
    (version : GameVersion) (behavior : ident) : list ident :=
  let scripts := behavior_closed_scripts version behavior in
  let direct := flat_map (behavior_native_calls version) scripts in
  if identifier_in (heave_ho_loop_identifier version) direct
  then direct ++ heave_ho_action_targets version
  else direct.

Definition behavior_can_reach_rng_in
    (version : GameVersion) (rng_callers : list ident)
    (behavior : ident) : bool :=
  let scripts := behavior_closed_scripts version behavior in
  existsb (behavior_has_random_command version) scripts ||
  existsb
    (fun native => identifier_in native rng_callers)
    (behavior_decoded_native_roots version behavior).

Definition behavior_can_reach_rng
    (version : GameVersion) (behavior : ident) : bool :=
  behavior_can_reach_rng_in version (rng_reaching_functions version) behavior.

Definition ttc_after_player_native_roots
    (version : GameVersion) : list ident :=
  nodup Pos.eq_dec
    (ttc_after_player_behavior_native_roots version ++
     heave_ho_action_targets version).

Definition ttc_after_player_rng_behavior_ids
    (version : GameVersion) : list ident :=
  let rng_callers := rng_reaching_functions version in
  filter (behavior_can_reach_rng_in version rng_callers)
    (ttc_static_after_player_behavior_ids version).

Definition circling_amp_behavior_identifier (version : GameVersion) : ident :=
  match version with
  | VersionUS => UCensusData._bhvCirclingAmp
  | VersionJP => JCensusData._bhvCirclingAmp
  end.

Definition bobomb_behavior_identifier (version : GameVersion) : ident :=
  match version with
  | VersionUS => UCensusData._bhvBobomb
  | VersionJP => JCensusData._bhvBobomb
  end.

Definition hidden_red_coin_star_behavior_identifier
    (version : GameVersion) : ident :=
  match version with
  | VersionUS => UCensusData._bhvHiddenRedCoinStar
  | VersionJP => JCensusData._bhvHiddenRedCoinStar
  end.

Definition circling_amp_native_roots (version : GameVersion) : list ident :=
  match version with
  | VersionUS =>
      [UCensusObjects._bhv_circling_amp_init;
       UCensusObjects._bhv_circling_amp_loop]
  | VersionJP =>
      [JCensusObjects._bhv_circling_amp_init;
       JCensusObjects._bhv_circling_amp_loop]
  end.

Definition bobomb_native_roots (version : GameVersion) : list ident :=
  match version with
  | VersionUS =>
      [UCensusObjects._bhv_bobomb_init;
       UCensusObjects._bhv_bobomb_loop]
  | VersionJP =>
      [JCensusObjects._bhv_bobomb_init;
       JCensusObjects._bhv_bobomb_loop]
  end.

Definition hidden_red_coin_star_native_roots
    (version : GameVersion) : list ident :=
  match version with
  | VersionUS =>
      [UCensusObjects._bhv_hidden_red_coin_star_init;
       UCensusObjects._bhv_hidden_red_coin_star_loop]
  | VersionJP =>
      [JCensusObjects._bhv_hidden_red_coin_star_init;
       JCensusObjects._bhv_hidden_red_coin_star_loop]
  end.

(** The boundary-aware behavior parser supplies exact generated opcode/pointer
    receipts for each of the five reported candidates, tethering each stock
    descriptor to its intended native roots. *)
Definition ttc_rng_candidate_behavior_tethers
    (version : GameVersion) : Prop :=
  behavior_closed_scripts version
    (circling_amp_behavior_identifier version) =
      [circling_amp_behavior_identifier version] /\
  behavior_decoded_native_roots version
    (circling_amp_behavior_identifier version) =
      circling_amp_native_roots version /\
  behavior_closed_scripts version
    (bobomb_behavior_identifier version) =
      [bobomb_behavior_identifier version] /\
  behavior_decoded_native_roots version
    (bobomb_behavior_identifier version) =
      bobomb_native_roots version /\
  behavior_closed_scripts version
    (hidden_red_coin_star_behavior_identifier version) =
      [hidden_red_coin_star_behavior_identifier version] /\
  behavior_decoded_native_roots version
    (hidden_red_coin_star_behavior_identifier version) =
      hidden_red_coin_star_native_roots version.

Definition amp_bobomb_rng_callsite_receipt (version : GameVersion) : Prop :=
  match version with
  | VersionUS =>
      UCensusObjects._random_u16 = UCensusScript._random_u16 /\
      UCensusObjects._random_float = UCensusScript._random_float /\
      direct_call_count_s UCensusObjects._random_u16
        (fn_body UCensusObjects.f_bhv_circling_amp_init) = 1%nat /\
      direct_call_count_s UCensusObjects._random_u16
        (fn_body UCensusObjects.f_bhv_circling_amp_loop) = 0%nat /\
      direct_call_count_s UCensusObjects._random_float
        (fn_body UCensusObjects.f_bhv_circling_amp_loop) = 0%nat /\
      direct_call_count_s UCensusObjects._random_u16
        (fn_body UCensusObjects.f_bhv_bobomb_init) = 0%nat /\
      direct_call_count_s UCensusObjects._random_float
        (fn_body UCensusObjects.f_bhv_bobomb_init) = 0%nat /\
      direct_call_count_s UCensusObjects._curr_obj_random_blink
        (fn_body UCensusObjects.f_bhv_bobomb_loop) = 1%nat /\
      direct_call_count_s UCensusObjects._random_u16
        (fn_body UCensusObjects.f_bhv_bobomb_loop) = 0%nat /\
      direct_call_count_s UCensusObjects._random_float
        (fn_body UCensusObjects.f_bhv_bobomb_loop) = 0%nat /\
      direct_call_count_s UCensusObjects._random_float
        (fn_body UCensusObjects.f_curr_obj_random_blink) = 1%nat /\
      direct_call_count_s UCensusScript._random_u16
        (fn_body UCensusScript.f_random_float) = 1%nat
  | VersionJP =>
      JCensusObjects._random_u16 = JCensusScript._random_u16 /\
      JCensusObjects._random_float = JCensusScript._random_float /\
      direct_call_count_s JCensusObjects._random_u16
        (fn_body JCensusObjects.f_bhv_circling_amp_init) = 1%nat /\
      direct_call_count_s JCensusObjects._random_u16
        (fn_body JCensusObjects.f_bhv_circling_amp_loop) = 0%nat /\
      direct_call_count_s JCensusObjects._random_float
        (fn_body JCensusObjects.f_bhv_circling_amp_loop) = 0%nat /\
      direct_call_count_s JCensusObjects._random_u16
        (fn_body JCensusObjects.f_bhv_bobomb_init) = 0%nat /\
      direct_call_count_s JCensusObjects._random_float
        (fn_body JCensusObjects.f_bhv_bobomb_init) = 0%nat /\
      direct_call_count_s JCensusObjects._curr_obj_random_blink
        (fn_body JCensusObjects.f_bhv_bobomb_loop) = 1%nat /\
      direct_call_count_s JCensusObjects._random_u16
        (fn_body JCensusObjects.f_bhv_bobomb_loop) = 0%nat /\
      direct_call_count_s JCensusObjects._random_float
        (fn_body JCensusObjects.f_bhv_bobomb_loop) = 0%nat /\
      direct_call_count_s JCensusObjects._random_float
        (fn_body JCensusObjects.f_curr_obj_random_blink) = 1%nat /\
      direct_call_count_s JCensusScript._random_u16
        (fn_body JCensusScript.f_random_float) = 1%nat
  end.

Definition hidden_red_star_rng_callsite_receipt
    (version : GameVersion) : Prop :=
  match version with
  | VersionUS =>
      direct_call_count_s UCensusObjects._spawn_mist_particles
        (fn_body UCensusObjects.f_bhv_hidden_red_coin_star_loop) = 1%nat /\
      direct_call_count_s UCensusActions._spawn_mist_particles_variable
        (fn_body UCensusHelpers.f_spawn_mist_particles) = 1%nat /\
      direct_call_count_s UCensusHelpers._cur_obj_spawn_particles
        (fn_body UCensusActions.f_spawn_mist_particles_variable) = 1%nat /\
      direct_call_count_s UCensusHelpers._random_float
        (fn_body UCensusHelpers.f_cur_obj_spawn_particles) = 3%nat /\
      direct_call_count_s UCensusHelpers._random_u16
        (fn_body UCensusHelpers.f_cur_obj_spawn_particles) = 1%nat
  | VersionJP =>
      direct_call_count_s JCensusObjects._spawn_mist_particles
        (fn_body JCensusObjects.f_bhv_hidden_red_coin_star_loop) = 1%nat /\
      direct_call_count_s JCensusActions._spawn_mist_particles_variable
        (fn_body JCensusHelpers.f_spawn_mist_particles) = 1%nat /\
      direct_call_count_s JCensusHelpers._cur_obj_spawn_particles
        (fn_body JCensusActions.f_spawn_mist_particles_variable) = 1%nat /\
      direct_call_count_s JCensusHelpers._random_float
        (fn_body JCensusHelpers.f_cur_obj_spawn_particles) = 3%nat /\
      direct_call_count_s JCensusHelpers._random_u16
        (fn_body JCensusHelpers.f_cur_obj_spawn_particles) = 1%nat
  end.

Definition ttc_after_player_random_command_behavior_ids
    (version : GameVersion) : list ident :=
  filter
    (fun behavior =>
      existsb (behavior_has_random_command version)
        (behavior_closed_scripts version behavior))
    (ttc_static_after_player_behavior_ids version).

Definition ttc_static_object_lists (version : GameVersion) : list (option Z) :=
  map (behavior_object_list version) (ttc_static_behavior_ids version).

Definition ttc_after_player_rng_object_lists
    (version : GameVersion) : list (option Z) :=
  map (behavior_object_list version)
    (ttc_after_player_rng_behavior_ids version).

Definition ttc_after_player_rng_phase_census
    (version : GameVersion) : list nat :=
  map
    (fun object_list => count_object_list object_list
      (ttc_after_player_rng_object_lists version))
    [5; 4; 2; 6; 8; 12].

(** Forward closure from the exact post-PLAYER stock behavior roots.  Unlike
    the reverse RNG classification, this computation exposes every missing
    generated function body instead of silently treating it as RNG-free. *)
Definition add_forward_callees_in
    (callgraph : list (ident * list ident))
    (reached : list ident) : list ident :=
  nodup Pos.eq_dec
    (reached ++
      flat_map
        (fun entry =>
          if identifier_in (fst entry) reached
          then snd entry
          else [])
        callgraph).

Fixpoint close_forward_callees_in
    (fuel : nat) (callgraph : list (ident * list ident))
    (reached : list ident) : list ident :=
  match fuel with
  | O => reached
  | S remaining =>
      close_forward_callees_in remaining callgraph
        (add_forward_callees_in callgraph reached)
  end.

Definition add_forward_callees
    (functions : list (ident * function)) (reached : list ident) : list ident :=
  add_forward_callees_in (generated_function_callgraph functions) reached.

Definition close_forward_callees
    (fuel : nat) (functions : list (ident * function))
    (reached : list ident) : list ident :=
  close_forward_callees_in fuel
    (generated_function_callgraph functions) reached.

Definition ttc_after_player_native_closure
    (version : GameVersion) : list ident :=
  close_forward_callees 16 (census_internal_functions version)
    (ttc_after_player_native_roots version).

Definition after_player_native_closure_is_stable
    (version : GameVersion) : Prop :=
  add_forward_callees
    (census_internal_functions version)
    (ttc_after_player_native_closure version) =
  ttc_after_player_native_closure version.

Definition unresolved_after_player_native_callees
    (version : GameVersion) : list ident :=
  filter
    (fun callee =>
      negb (identifier_in callee
        (function_names (census_internal_functions version))))
    (ttc_after_player_native_closure version).

Definition sqrtf_identifier (version : GameVersion) : ident :=
  match version with
  | VersionUS => UCensusMath._sqrtf
  | VersionJP => JCensusMath._sqrtf
  end.

Definition sqrtf_is_declared_external (version : GameVersion) : bool :=
  match version with
  | VersionUS =>
      has_named_external_function UCensusMath._sqrtf "sqrtf"%string
        (prog_defs UCensusMath.prog)
  | VersionJP =>
      has_named_external_function JCensusMath._sqrtf "sqrtf"%string
        (prog_defs JCensusMath.prog)
  end.

(** [direct_callees_s] intentionally collects only [Scall] nodes whose
    function expression is syntactically [Evar].  Completeness therefore also
    requires a separate census of indirect calls in every reached body. *)
Fixpoint indirect_call_count_s (body : statement) : nat :=
  match body with
  | Scall _ (Evar _ _) _ => O
  | Scall _ _ _ => 1%nat
  | Ssequence first second | Sloop first second =>
      (indirect_call_count_s first + indirect_call_count_s second)%nat
  | Sifthenelse _ yes no =>
      (indirect_call_count_s yes + indirect_call_count_s no)%nat
  | Slabel _ nested => indirect_call_count_s nested
  | Sswitch _ cases => indirect_call_count_ls cases
  | _ => O
  end
with indirect_call_count_ls (cases : labeled_statements) : nat :=
  match cases with
  | LSnil => O
  | LScons _ body rest =>
      (indirect_call_count_s body + indirect_call_count_ls rest)%nat
  end.

Fixpoint direct_single_ident_argument_call_count_s
    (callee argument : ident) (body : statement) : nat :=
  match body with
  | Scall _ (Evar found _) [Evar found_argument _] =>
      if (Pos.eqb found callee && Pos.eqb found_argument argument)%bool
      then 1%nat else O
  | Ssequence first second | Sloop first second =>
      (direct_single_ident_argument_call_count_s callee argument first +
       direct_single_ident_argument_call_count_s callee argument second)%nat
  | Sifthenelse _ yes no =>
      (direct_single_ident_argument_call_count_s callee argument yes +
       direct_single_ident_argument_call_count_s callee argument no)%nat
  | Slabel _ nested =>
      direct_single_ident_argument_call_count_s callee argument nested
  | Sswitch _ cases =>
      direct_single_ident_argument_call_count_ls callee argument cases
  | _ => O
  end
with direct_single_ident_argument_call_count_ls
    (callee argument : ident) (cases : labeled_statements) : nat :=
  match cases with
  | LSnil => O
  | LScons _ body rest =>
      (direct_single_ident_argument_call_count_s callee argument body +
       direct_single_ident_argument_call_count_ls callee argument rest)%nat
  end.

(** [cur_obj_call_action_function] is the sole reached indirect-call helper.
    This generated-AST matcher ties that call to the supplied action table:
    it loads [gCurrentObject->rawData.asS32[49]] (the action field), indexes
    the one pointer-table parameter with that value, and invokes the loaded
    pointer with no arguments.  Every temporary identifier is checked for
    consistent reuse, so merely counting one indirect [Scall] is not enough
    to satisfy this receipt. *)
Definition object_action_index_expression_matches
    (object_tmp raw_data_field as_s32_field : ident)
    (index_expression : expr) : bool :=
  match index_expression with
  | Ederef
      (Ebinop Oadd
        (Efield
          (Efield
            (Ederef (Etempvar found_object_tmp _) _) found_raw_data _)
          found_as_s32 _)
        (Econst_int found_index _) _) _ =>
      (Pos.eqb found_object_tmp object_tmp &&
       Pos.eqb found_raw_data raw_data_field &&
       Pos.eqb found_as_s32 as_s32_field &&
       Int.eq found_index (Int.repr 49))%bool
  | _ => false
  end.

Definition cur_obj_action_dispatch_shape
    (parameter action_function_tmp current_object raw_data_field as_s32_field
      : ident)
    (body : function) : bool :=
  match fn_params body, fn_body body with
  | (found_parameter, _) :: [],
      Ssequence
        (Ssequence
          (Sset object_tmp (Evar found_current_object _))
          (Ssequence
            (Sset index_tmp index_expression)
            (Sset found_action_tmp
              (Ederef
                (Ebinop Oadd
                  (Etempvar used_parameter _)
                  (Etempvar used_index_tmp _) _) _))))
        (Scall None (Etempvar called_action_tmp _) []) =>
      (Pos.eqb found_parameter parameter &&
       Pos.eqb used_parameter parameter &&
       Pos.eqb found_current_object current_object &&
       Pos.eqb found_action_tmp action_function_tmp &&
       Pos.eqb called_action_tmp action_function_tmp &&
       Pos.eqb used_index_tmp index_tmp &&
       object_action_index_expression_matches
         object_tmp raw_data_field as_s32_field index_expression)%bool
  | _, _ => false
  end.

Definition heave_ho_action_table_dispatch_receipt
    (version : GameVersion) : Prop :=
  match version with
  | VersionUS =>
      gvar_init UCensusActions.v_sHeaveHoActions =
        expected_heave_ho_action_initializer VersionUS /\
      heave_ho_action_targets VersionUS =
        expected_heave_ho_action_targets VersionUS /\
      cur_obj_action_dispatch_shape
        UCensusHelpers._actionFunctions UCensusHelpers._actionFunction
        UCensusHelpers._gCurrentObject UCensusHelpers._rawData
        UCensusHelpers._asS32
        UCensusHelpers.f_cur_obj_call_action_function = true
  | VersionJP =>
      gvar_init JCensusActions.v_sHeaveHoActions =
        expected_heave_ho_action_initializer VersionJP /\
      heave_ho_action_targets VersionJP =
        expected_heave_ho_action_targets VersionJP /\
      cur_obj_action_dispatch_shape
        JCensusHelpers._actionFunctions JCensusHelpers._actionFunction
        JCensusHelpers._gCurrentObject JCensusHelpers._rawData
        JCensusHelpers._asS32
        JCensusHelpers.f_cur_obj_call_action_function = true
  end.

Definition heave_ho_dispatch_receipt (version : GameVersion) : Prop :=
  heave_ho_action_table_dispatch_receipt version /\
  match version with
  | VersionUS =>
      direct_call_count_s UCensusHelpers._cur_obj_call_action_function
        (fn_body UCensusActions.f_heave_ho_move) = 1%nat /\
      direct_single_ident_argument_call_count_s
        UCensusHelpers._cur_obj_call_action_function
        UCensusActions._sHeaveHoActions
        (fn_body UCensusActions.f_heave_ho_move) = 1%nat /\
      indirect_call_count_s
        (fn_body UCensusHelpers.f_cur_obj_call_action_function) = 1%nat
  | VersionJP =>
      direct_call_count_s JCensusHelpers._cur_obj_call_action_function
        (fn_body JCensusActions.f_heave_ho_move) = 1%nat /\
      direct_single_ident_argument_call_count_s
        JCensusHelpers._cur_obj_call_action_function
        JCensusActions._sHeaveHoActions
        (fn_body JCensusActions.f_heave_ho_move) = 1%nat /\
      indirect_call_count_s
        (fn_body JCensusHelpers.f_cur_obj_call_action_function) = 1%nat
  end.

Definition cur_obj_call_action_function_identifier
    (version : GameVersion) : ident :=
  match version with
  | VersionUS => UCensusHelpers._cur_obj_call_action_function
  | VersionJP => JCensusHelpers._cur_obj_call_action_function
  end.

Definition reached_internal_functions_in
    (functions : list (ident * function))
    (reached : list ident) : list (ident * function) :=
  filter
    (fun entry => identifier_in (fst entry) reached)
    functions.

Definition reached_internal_functions
    (version : GameVersion) : list (ident * function) :=
  reached_internal_functions_in
    (census_internal_functions version)
    (ttc_after_player_native_closure version).

Definition reached_indirect_callers_in
    (functions : list (ident * function))
    (reached : list ident) : list ident :=
  map fst
    (filter
      (fun entry => negb (Nat.eqb
        (indirect_call_count_s (fn_body (snd entry))) O))
      (reached_internal_functions_in functions reached)).

Definition reached_indirect_callers
    (version : GameVersion) : list ident :=
  reached_indirect_callers_in
    (census_internal_functions version)
    (ttc_after_player_native_closure version).

Definition reached_indirect_call_count_in
    (functions : list (ident * function))
    (reached : list ident) : nat :=
  sum_nat
    (map
      (fun entry => indirect_call_count_s (fn_body (snd entry)))
      (reached_internal_functions_in functions reached)).

Definition reached_indirect_call_count (version : GameVersion) : nat :=
  reached_indirect_call_count_in
    (census_internal_functions version)
    (ttc_after_player_native_closure version).

Definition reached_direct_callers_of_in
    (functions : list (ident * function))
    (reached : list ident) (callee : ident) : list ident :=
  map fst
    (filter
      (fun entry => negb (Nat.eqb
        (direct_call_count_s callee (fn_body (snd entry))) O))
      (reached_internal_functions_in functions reached)).

Definition reached_direct_call_count_of_in
    (functions : list (ident * function))
    (reached : list ident) (callee : ident) : nat :=
  sum_nat
    (map
      (fun entry => direct_call_count_s callee (fn_body (snd entry)))
      (reached_internal_functions_in functions reached)).

Definition reached_action_dispatch_callers (version : GameVersion) : list ident :=
  reached_direct_callers_of_in
    (census_internal_functions version)
    (ttc_after_player_native_closure version)
    (cur_obj_call_action_function_identifier version).

Definition reached_action_dispatch_call_count (version : GameVersion) : nat :=
  reached_direct_call_count_of_in
    (census_internal_functions version)
    (ttc_after_player_native_closure version)
    (cur_obj_call_action_function_identifier version).

Definition heave_ho_move_identifier (version : GameVersion) : ident :=
  match version with
  | VersionUS => UCensusActions._heave_ho_move
  | VersionJP => JCensusActions._heave_ho_move
  end.

Definition expected_ttc_after_player_rng_behavior_ids
    (version : GameVersion) : list ident :=
  [circling_amp_behavior_identifier version;
   circling_amp_behavior_identifier version;
   bobomb_behavior_identifier version;
   bobomb_behavior_identifier version;
   hidden_red_coin_star_behavior_identifier version].

(** The reverse and forward closures dominate verification time.  This one
    generated receipt binds each closure once per version and projects every
    closure-dependent result from those shared values.  The later named
    theorems are logical projections, not repeated VM computations. *)
Definition ttc_heavy_generated_census_receipt
    (version : GameVersion) : Prop :=
  let functions := census_internal_functions version in
  let callgraph := generated_function_callgraph functions in
  let rng :=
    close_rng_callers_in 8 callgraph [random_u16_identifier version] in
  let native :=
    close_forward_callees_in 16 callgraph
      (ttc_after_player_native_roots version) in
  let reached_functions :=
    reached_internal_functions_in functions native in
  add_rng_callers_in callgraph rng = rng /\
  add_forward_callees_in callgraph native = native /\
  filter
    (fun callee => negb (identifier_in callee (function_names functions)))
    native = [sqrtf_identifier version] /\
  filter (behavior_can_reach_rng_in version rng)
    (ttc_static_after_player_behavior_ids version) =
      expected_ttc_after_player_rng_behavior_ids version /\
  map fst
    (filter
      (fun entry => negb (Nat.eqb
        (indirect_call_count_s (fn_body (snd entry))) O))
      reached_functions) =
      [cur_obj_call_action_function_identifier version] /\
  sum_nat
    (map
      (fun entry => indirect_call_count_s (fn_body (snd entry)))
      reached_functions) = 1%nat /\
  map fst
    (filter
      (fun entry => negb (Nat.eqb
        (direct_call_count_s
          (cur_obj_call_action_function_identifier version)
          (fn_body (snd entry))) O))
      reached_functions) = [heave_ho_move_identifier version] /\
  sum_nat
    (map
      (fun entry => direct_call_count_s
        (cur_obj_call_action_function_identifier version)
        (fn_body (snd entry)))
      reached_functions) = 1%nat.

Theorem generated_ttc_level_script_behavior_resolution_complete_us_jp :
  forall version,
    ttc_level_script_behavior_ids_result version =
      Some (expected_ttc_level_script_behavior_ids version) /\
    ttc_level_entry_control_targets_result version =
      Some (expected_ttc_level_entry_control_targets version) /\
    ttc_shared_level_behavior_ids_result version = Some ([], []) /\
    ttc_shared_level_control_targets_result version = Some ([], []) /\
    ttc_local_level_control_targets_result version = Some ([], []) /\
    ttc_area_behavior_ids version =
      expected_ttc_level_script_behavior_ids version.
Proof. intros []; vm_compute; repeat split; reflexivity. Qed.

Theorem generated_ttc_level_script_census_projection_us_jp :
  forall version,
    ttc_level_script_behavior_ids_result version =
      Some (expected_ttc_level_script_behavior_ids version) /\
    ttc_level_entry_control_targets_result version =
      Some (expected_ttc_level_entry_control_targets version) /\
    ttc_shared_level_behavior_ids_result version = Some ([], []) /\
    ttc_shared_level_control_targets_result version = Some ([], []) /\
    ttc_local_level_control_targets_result version = Some ([], []).
Proof.
  intro version.
  destruct
    (generated_ttc_level_script_behavior_resolution_complete_us_jp version)
    as [Hbehaviors [Hentry [Hshared [Hshared_targets [Hlocal _]]]]].
  repeat split; assumption.
Qed.

Theorem generated_ttc_area_and_static_descriptor_counts_us_jp :
  forall version,
    length (ttc_area_behavior_ids version) = 10%nat /\
    length (ttc_static_behavior_ids version) = 120%nat /\
    unresolved_object_lists (ttc_static_object_lists version) = 0%nat.
Proof. intros []; vm_compute; repeat split; reflexivity. Qed.

Theorem generated_ttc_after_player_behavior_closure_us_jp :
  forall version,
    length (ttc_static_after_player_behavior_ids version) = 38%nat /\
    after_player_behavior_closure_is_stable version /\
    unresolved_after_player_behavior_targets version = [] /\
    invalid_after_player_descriptor_behavior_closures version = [].
Proof. intros []; vm_compute; repeat split; reflexivity. Qed.

Theorem generated_census_function_names_unique_us_jp :
  forall version, census_function_names_are_unique version.
Proof. intros []; vm_compute; reflexivity. Qed.

Theorem generated_census_function_names_NoDup_us_jp :
  forall version,
    NoDup (function_names (census_internal_functions version)).
Proof.
  intro version.
  pose proof (generated_census_function_names_unique_us_jp version) as H.
  unfold census_function_names_are_unique in H.
  rewrite <- H.
  apply NoDup_nodup.
Qed.

Theorem generated_ttc_heavy_census_receipt_us_jp :
  forall version, ttc_heavy_generated_census_receipt version.
Proof. intros []; vm_compute; repeat split; reflexivity. Qed.

Theorem generated_rng_reverse_callgraph_fixed_point_us_jp :
  forall version, rng_caller_closure_is_stable version.
Proof.
  intro version.
  destruct (generated_ttc_heavy_census_receipt_us_jp version)
    as [Hreverse _].
  exact Hreverse.
Qed.

Theorem generated_ttc_after_player_native_closure_stable_us_jp :
  forall version, after_player_native_closure_is_stable version.
Proof.
  intro version.
  destruct (generated_ttc_heavy_census_receipt_us_jp version)
    as [_ [Hforward _]].
  exact Hforward.
Qed.

Theorem generated_ttc_after_player_native_terminal_frontier_us_jp :
  forall version,
    unresolved_after_player_native_callees version =
      [sqrtf_identifier version] /\
    sqrtf_is_declared_external version = true.
Proof.
  intro version.
  destruct (generated_ttc_heavy_census_receipt_us_jp version)
    as [_ [_ [Hterminal _]]].
  split.
  - exact Hterminal.
  - destruct version; vm_compute; reflexivity.
Qed.

(** Fail-closed semantic boundary: [sqrtf] is an [EF_external] declaration in
    the generated Clight units.  The theorem above proves it is the complete
    internal-callgraph frontier, but CompCert's abstract external-call relation
    does not by itself prove that the implementation cannot mutate the seed or
    call back into [random_u16].  Consequently this file does not advertise an
    effect-complete linked census until a verified [sqrtf] external contract
    (or a generated implementation) is supplied. *)
Theorem generated_ttc_native_effect_frontier_is_nonempty_us_jp :
  forall version, unresolved_after_player_native_callees version <> [].
Proof.
  intro version.
  rewrite (proj1
    (generated_ttc_after_player_native_terminal_frontier_us_jp version)).
  discriminate.
Qed.

Theorem generated_ttc_after_player_behavior_bytecode_has_no_random_command_us_jp :
  forall version, ttc_after_player_random_command_behavior_ids version = [].
Proof. intros []; vm_compute; reflexivity. Qed.

Theorem generated_ttc_rng_candidate_behavior_tethers_us_jp :
  forall version, ttc_rng_candidate_behavior_tethers version.
Proof. intros []; vm_compute; repeat split; reflexivity. Qed.

Theorem generated_ttc_after_player_rng_descriptors_us_jp :
  forall version,
    ttc_after_player_rng_behavior_ids version =
      expected_ttc_after_player_rng_behavior_ids version.
Proof.
  intro version.
  destruct (generated_ttc_heavy_census_receipt_us_jp version)
    as [_ [_ [_ [Hdescriptors _]]]].
  exact Hdescriptors.
Qed.

Theorem generated_ttc_after_player_rng_object_lists_us_jp :
  forall version,
    ttc_after_player_rng_object_lists version =
      [Some 4; Some 4; Some 2; Some 2; Some 6].
Proof.
  intro version.
  unfold ttc_after_player_rng_object_lists.
  rewrite generated_ttc_after_player_rng_descriptors_us_jp.
  destruct version; vm_compute; reflexivity.
Qed.

Theorem generated_ttc_after_player_rng_phase_census_us_jp :
  forall version,
    ttc_after_player_rng_phase_census version = [0; 2; 2; 1; 0; 0]%nat.
Proof.
  intro version.
  unfold ttc_after_player_rng_phase_census.
  rewrite generated_ttc_after_player_rng_object_lists_us_jp.
  vm_compute; reflexivity.
Qed.

Theorem generated_amp_bobomb_rng_callsite_receipt_us_jp :
  forall version, amp_bobomb_rng_callsite_receipt version.
Proof. intros []; vm_compute; repeat split; reflexivity. Qed.

Theorem generated_hidden_red_star_rng_callsite_receipt_us_jp :
  forall version, hidden_red_star_rng_callsite_receipt version.
Proof. intros []; vm_compute; repeat split; reflexivity. Qed.

Theorem generated_object_list_update_order_us_jp :
  forall version,
    generated_object_list_update_order_result version =
      Some [11; 9; 10; 0; 5; 4; 2; 6; 8; 12; -1] /\
    generated_object_list_update_order version =
      [11; 9; 10; 0; 5; 4; 2; 6; 8; 12; -1] /\
    nth_error (generated_object_list_update_order version) 3 = Some 0 /\
    nth_error (generated_object_list_update_order version) 5 = Some 4 /\
    nth_error (generated_object_list_update_order version) 6 = Some 2 /\
    nth_error (generated_object_list_update_order version) 9 = Some 12.
Proof. intros []; vm_compute; repeat split; reflexivity. Qed.

Theorem generated_ttc_after_player_indirect_dispatch_decoded_us_jp :
  forall version,
    reached_indirect_callers version =
      [cur_obj_call_action_function_identifier version] /\
    reached_indirect_call_count version = 1%nat /\
    reached_action_dispatch_callers version =
      [heave_ho_move_identifier version] /\
    reached_action_dispatch_call_count version = 1%nat /\
    heave_ho_dispatch_receipt version.
Proof.
  intro version.
  destruct (generated_ttc_heavy_census_receipt_us_jp version)
    as [_ [_ [_ [_ [Hindirect_callers
      [Hindirect_count [Hdirect_callers Hdirect_count]]]]]]].
  repeat split; try assumption.
  all: destruct version; vm_compute; repeat split; reflexivity.
Qed.

(** The seed is file-local in the generated [behavior_script.c] unit.  More
    strongly, scanning every generated internal body finds no occurrence of
    its identifier outside [random_u16], so it is neither directly written nor
    has its address passed elsewhere in this translation unit.  The five
    writes are syntactic branch occurrences inside that one function; an
    executed call follows one branch and therefore does not execute all five. *)
Theorem generated_random_seed_writer_uniqueness_us_jp :
  forall version,
    identifier_in (random_seed_identifier version)
      (behavior_script_public_identifiers version) = false /\
    random_seed_definition_count version = 1%nat /\
    random_seed_initializer_reference_count version = 0%nat /\
    random_seed_mentioning_functions version =
      [random_u16_identifier version] /\
    random_seed_writing_functions version =
      [random_u16_identifier version] /\
    random_seed_syntactic_write_count version = 5%nat.
Proof. intros []; vm_compute; repeat split; reflexivity. Qed.

(** Scope boundary: this file closes the finite generated-Clight *stock
    descriptor and internal-callgraph* census for
    lists strictly after PLAYER in the same scheduler pass.  It deliberately
    makes no claim about dynamically inserted objects, nor about the next
    frame's SURFACE prefix before a selected spinner.  It also exposes, rather
    than assumes away, the one [sqrtf] external-effect frontier above.  Dynamic
    objects require the authenticated live-pool certificate and frame trace. *)
Definition ttc_static_post_player_scheduler_lists : list Z :=
  [5; 4; 2; 6; 8; 12].

Theorem ttc_rng_census_static_scope_boundary :
  ttc_static_post_player_scheduler_lists = [5; 4; 2; 6; 8; 12] /\
  ~ In 9 ttc_static_post_player_scheduler_lists.
Proof.
  split; [reflexivity |].
  unfold ttc_static_post_player_scheduler_lists.
  simpl.
  intuition discriminate.
Qed.

(** Linker-receipt projection for the one non-dust owner observed in the
    committed F/F+1 trace.  The runtime checker validates the raw behavior
    address on every event; this proposition pairs that address with the
    generated [bhvBobomb] identifier and its exactly decoded native roots.
    The clean retail-map authentication remains external evidence, not a
    CompCert source-to-binary refinement theorem. *)
Definition ttc_debug_outside_behavior_identifier
    (version : GameVersion) : ident :=
  bobomb_behavior_identifier version.

Definition expected_ttc_debug_outside_behavior_address
    (version : GameVersion) : Z :=
  match version with
  | VersionUS => 2148459252
  | VersionJP => 2148447348
  end.

Definition ttc_debug_outside_bobomb_linker_projection
    (version : GameVersion) : Prop :=
  ttc_debug_rng_behavior_address version TTCDebugOutsideList2 =
    expected_ttc_debug_outside_behavior_address version /\
  ttc_debug_outside_behavior_identifier version =
    bobomb_behavior_identifier version /\
  behavior_decoded_native_roots version
    (ttc_debug_outside_behavior_identifier version) =
      bobomb_native_roots version /\
  In (ttc_debug_outside_behavior_identifier version)
    (expected_ttc_after_player_rng_behavior_ids version).

Theorem checked_ttc_debug_outside_bobomb_linker_projection_us_jp :
  forall version, ttc_debug_outside_bobomb_linker_projection version.
Proof. intros []; vm_compute; repeat split; auto. Qed.

Definition ttc_rng_static_census_claim : Prop :=
  (forall version, rng_caller_closure_is_stable version) /\
  (forall version,
    ttc_level_script_behavior_ids_result version =
      Some (expected_ttc_level_script_behavior_ids version) /\
    ttc_level_entry_control_targets_result version =
      Some (expected_ttc_level_entry_control_targets version) /\
    ttc_shared_level_behavior_ids_result version = Some ([], []) /\
    ttc_shared_level_control_targets_result version = Some ([], []) /\
    ttc_local_level_control_targets_result version = Some ([], [])) /\
  (forall version,
    ttc_exact_macro_words_result version =
      Some (ttc_exact_macro_words version) /\
    macro_preset_behaviors_result version =
      Some (macro_preset_behaviors version) /\
    length (macro_preset_behaviors version) = 366%nat /\
    length (ttc_exact_macro_words version) = 551%nat /\
    skipn 550 (ttc_exact_macro_words version) = [30] /\
    length (ttc_exact_macro_records version) = 110%nat /\
    length (ttc_macro_behavior_options version) = 110%nat /\
    unresolved_behavior_count (ttc_macro_behavior_options version) = 0%nat /\
    length (ttc_macro_behavior_ids version) = 110%nat /\
    unresolved_object_lists (ttc_macro_object_lists version) = 0%nat) /\
  (forall version, census_function_names_are_unique version) /\
  (forall version,
    NoDup (function_names (census_internal_functions version))) /\
  (forall version,
    length (ttc_static_after_player_behavior_ids version) = 38%nat /\
    after_player_behavior_closure_is_stable version /\
    unresolved_after_player_behavior_targets version = [] /\
    invalid_after_player_descriptor_behavior_closures version = []) /\
  (forall version, after_player_native_closure_is_stable version) /\
  (forall version,
    unresolved_after_player_native_callees version =
      [sqrtf_identifier version] /\
    sqrtf_is_declared_external version = true) /\
  (forall version,
    ttc_after_player_random_command_behavior_ids version = []) /\
  (forall version, ttc_rng_candidate_behavior_tethers version) /\
  (forall version,
    ttc_after_player_rng_behavior_ids version =
      expected_ttc_after_player_rng_behavior_ids version) /\
  (forall version,
    ttc_after_player_rng_phase_census version = [0; 2; 2; 1; 0; 0]%nat) /\
  (forall version,
    generated_object_list_update_order_result version =
      Some [11; 9; 10; 0; 5; 4; 2; 6; 8; 12; -1] /\
    generated_object_list_update_order version =
      [11; 9; 10; 0; 5; 4; 2; 6; 8; 12; -1] /\
    nth_error (generated_object_list_update_order version) 3 = Some 0 /\
    nth_error (generated_object_list_update_order version) 5 = Some 4 /\
    nth_error (generated_object_list_update_order version) 6 = Some 2 /\
    nth_error (generated_object_list_update_order version) 9 = Some 12) /\
  (forall version, amp_bobomb_rng_callsite_receipt version) /\
  (forall version, hidden_red_star_rng_callsite_receipt version) /\
  (forall version,
    reached_indirect_callers version =
      [cur_obj_call_action_function_identifier version] /\
    reached_indirect_call_count version = 1%nat /\
    reached_action_dispatch_callers version =
      [heave_ho_move_identifier version] /\
    reached_action_dispatch_call_count version = 1%nat /\
    heave_ho_dispatch_receipt version) /\
  (forall version,
    identifier_in (random_seed_identifier version)
      (behavior_script_public_identifiers version) = false /\
    random_seed_definition_count version = 1%nat /\
    random_seed_initializer_reference_count version = 0%nat /\
    random_seed_mentioning_functions version =
      [random_u16_identifier version] /\
    random_seed_writing_functions version =
      [random_u16_identifier version] /\
    random_seed_syntactic_write_count version = 5%nat).

Theorem checked_ttc_rng_static_census_us_jp :
  ttc_rng_static_census_claim.
Proof.
  unfold ttc_rng_static_census_claim.
  refine (conj generated_rng_reverse_callgraph_fixed_point_us_jp _).
  refine (conj generated_ttc_level_script_census_projection_us_jp _).
  refine (conj generated_ttc_macro_behavior_resolution_complete_us_jp _).
  refine (conj generated_census_function_names_unique_us_jp _).
  refine (conj generated_census_function_names_NoDup_us_jp _).
  refine (conj generated_ttc_after_player_behavior_closure_us_jp _).
  refine (conj generated_ttc_after_player_native_closure_stable_us_jp _).
  refine (conj generated_ttc_after_player_native_terminal_frontier_us_jp _).
  refine (conj
    generated_ttc_after_player_behavior_bytecode_has_no_random_command_us_jp _).
  refine (conj generated_ttc_rng_candidate_behavior_tethers_us_jp _).
  refine (conj generated_ttc_after_player_rng_descriptors_us_jp _).
  refine (conj generated_ttc_after_player_rng_phase_census_us_jp _).
  refine (conj generated_object_list_update_order_us_jp _).
  refine (conj generated_amp_bobomb_rng_callsite_receipt_us_jp _).
  refine (conj generated_hidden_red_star_rng_callsite_receipt_us_jp _).
  refine (conj generated_ttc_after_player_indirect_dispatch_decoded_us_jp _).
  exact generated_random_seed_writer_uniqueness_us_jp.
Qed.

(** The committed debug receipt supplies the dynamic facts that a static
    descriptor census cannot: exact executed call order, frame timers, owner
    classes, and seed transitions.  [make runtime-receipt] independently
    checks the emulator rows, retail addresses, and this Coq projection; the
    Coq theorem itself starts from the projected constants and is not a proof
    of emulator reachability or of the outside owner's behavior identity.
    It deliberately preserves the receipt's SLOW/debug provenance: it is not
    a stock or Pedro reachability theorem and does not describe the next
    frame's SURFACE prefix. *)
Definition ttc_debug_slow_observed_rng_census_claim : Prop :=
  ttc_rng_static_census_claim /\
  (forall version, ttc_debug_outside_bobomb_linker_projection version) /\
  map event_call_index ttc_debug_slow_rng_events = seq 33 10 /\
  map event_timer ttc_debug_slow_frame_f_events =
    repeat 414%nat 5%nat /\
  map event_timer ttc_debug_slow_frame_f1_events =
    repeat 415%nat 5%nat /\
  map event_owner ttc_debug_slow_frame_f_events =
    [TTCDebugOutsideList2; TTCDebugDustPuff1; TTCDebugDustPuff1;
     TTCDebugDustPuff2; TTCDebugDustPuff2] /\
  map event_owner ttc_debug_slow_frame_f1_events =
    [TTCDebugOutsideList2; TTCDebugDustPuff1; TTCDebugDustPuff1;
     TTCDebugDustPuff2; TTCDebugDustPuff2] /\
  ttc_debug_dust_call_count ttc_debug_slow_frame_f_events = 4%nat /\
  ttc_debug_dust_call_count ttc_debug_slow_frame_f1_events = 4%nat /\
  forallb ttc_debug_rng_event_stepb ttc_debug_slow_rng_events = true /\
  ttc_debug_rng_trace_chainb ttc_debug_slow_rng_events = true /\
  rng_steps 5 26276 = 13554 /\
  rng_steps 5 13554 = 23201 /\
  rng_steps 10 26276 = 23201 /\
  origin_is_stockb ttc_level_select_snapshot_origin = false /\
  (forall version,
    snapshot_ttc_speed_setting (ttc_level_select_snapshot version) =
      ttc_speed_slow /\
    snapshot_ttc_speed_setting (ttc_level_select_snapshot version) <>
      ttc_speed_random).

Theorem checked_ttc_debug_slow_observed_rng_census_us_jp :
  ttc_debug_slow_observed_rng_census_claim.
Proof.
  unfold ttc_debug_slow_observed_rng_census_claim.
  destruct ttc_debug_slow_trace_exact_scheduler_projection
    as [Hcall_indices [Htimer_f [Htimer_f1
      [_ [_ [Hdust_f Hdust_f1]]]]]].
  destruct ttc_debug_slow_trace_exact_seed_advances
    as [Hstep [Hchain [Hfive_f [Hfive_f1 Hten]]]].
  assert (Howners_f :
    map event_owner ttc_debug_slow_frame_f_events =
      [TTCDebugOutsideList2; TTCDebugDustPuff1; TTCDebugDustPuff1;
       TTCDebugDustPuff2; TTCDebugDustPuff2]) by
    (vm_compute; reflexivity).
  assert (Howners_f1 :
    map event_owner ttc_debug_slow_frame_f1_events =
      [TTCDebugOutsideList2; TTCDebugDustPuff1; TTCDebugDustPuff1;
       TTCDebugDustPuff2; TTCDebugDustPuff2]) by
    (vm_compute; reflexivity).
  refine (conj checked_ttc_rng_static_census_us_jp _).
  refine (conj checked_ttc_debug_outside_bobomb_linker_projection_us_jp _).
  refine (conj Hcall_indices _).
  refine (conj Htimer_f _).
  refine (conj Htimer_f1 _).
  refine (conj Howners_f _).
  refine (conj Howners_f1 _).
  refine (conj Hdust_f _).
  refine (conj Hdust_f1 _).
  refine (conj Hstep _).
  refine (conj Hchain _).
  refine (conj Hfive_f _).
  refine (conj Hfive_f1 _).
  refine (conj Hten _).
  refine (conj ttc_level_select_snapshot_is_not_stock_origin _).
  exact ttc_level_select_snapshot_is_slow_not_random.
Qed.
