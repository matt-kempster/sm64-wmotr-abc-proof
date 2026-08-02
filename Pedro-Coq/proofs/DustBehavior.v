From Coq Require Import Bool List PArith.BinPos ZArith.
From compcert Require Import AST Clight Ctypes Integers.
From Pedro.Generated Require Import
  us_mario us_spawn_object us_object_list_processor us_object_helpers
  us_behavior_script us_behavior_actions us_behavior_data
  jp_mario jp_spawn_object jp_object_list_processor jp_object_helpers
  jp_behavior_script jp_behavior_actions jp_behavior_data.
From Pedro.Proofs Require Import ASTFacts GameTypes.

Import ListNotations.
Open Scope Z_scope.

Module UM := us_mario.
Module USpawn := us_spawn_object.
Module UOL := us_object_list_processor.
Module UOH := us_object_helpers.
Module UBS := us_behavior_script.
Module UBA := us_behavior_actions.
Module UBD := us_behavior_data.

Module JM := jp_mario.
Module JSpawn := jp_spawn_object.
Module JOL := jp_object_list_processor.
Module JOH := jp_object_helpers.
Module JBS := jp_behavior_script.
Module JBA := jp_behavior_actions.
Module JBD := jp_behavior_data.

(** This file deliberately proves a source-derived, executable scheduling
    reduction. It is not a [ClightBigstep] execution theorem, and its three
    Boolean premises are not proofs of retail reachability, normal time state,
    or object-pool availability. Those remain separate obligations. *)

Inductive first_frame_stop : Type :=
| StopDelay
| StopEndRepeat
| StopEndLoop
| StopDeactivate
| StopEndOfData
| StopMalformed.

Record decoded_address : Type := {
  decoded_ident : ident;
  decoded_offset : ptrofs
}.

Record decoded_spawn : Type := {
  decoded_model : Z;
  decoded_behavior : decoded_address
}.

Record first_frame_acc : Type := {
  acc_object_list : option Z;
  acc_parent_clears : list (Z * Z);
  acc_spawns : list decoded_spawn;
  acc_natives : list decoded_address
}.

Record first_frame_effect : Type := {
  effect_object_list : option Z;
  effect_parent_clears : list (Z * Z);
  effect_spawns : list decoded_spawn;
  effect_natives : list decoded_address;
  effect_stop : first_frame_stop
}.

Definition empty_first_frame_acc : first_frame_acc :=
  {| acc_object_list := None;
     acc_parent_clears := [];
     acc_spawns := [];
     acc_natives := [] |}.

Definition finish_first_frame
    (acc : first_frame_acc) (stop : first_frame_stop) : first_frame_effect :=
  {| effect_object_list := acc_object_list acc;
     effect_parent_clears := acc_parent_clears acc;
     effect_spawns := acc_spawns acc;
     effect_natives := acc_natives acc;
     effect_stop := stop |}.

Definition command_opcode (word : int) : Z :=
  Z.shiftr (Int.unsigned word) 24.

Definition command_second_u8 (word : int) : Z :=
  Z.land (Z.shiftr (Int.unsigned word) 16) 255.

Definition command_second_u16 (word : int) : Z :=
  Z.land (Z.shiftr (Int.unsigned word) 16) 65535.

Definition with_object_list
    (list_index : Z) (acc : first_frame_acc) : first_frame_acc :=
  {| acc_object_list := Some list_index;
     acc_parent_clears := acc_parent_clears acc;
     acc_spawns := acc_spawns acc;
     acc_natives := acc_natives acc |}.

Definition add_parent_clear
    (field mask : Z) (acc : first_frame_acc) : first_frame_acc :=
  {| acc_object_list := acc_object_list acc;
     acc_parent_clears := acc_parent_clears acc ++ [(field, mask)];
     acc_spawns := acc_spawns acc;
     acc_natives := acc_natives acc |}.

Definition add_spawn
    (model : Z) (behavior : ident) (offset : ptrofs)
    (acc : first_frame_acc) : first_frame_acc :=
  {| acc_object_list := acc_object_list acc;
     acc_parent_clears := acc_parent_clears acc;
     acc_spawns := acc_spawns acc ++
       [{| decoded_model := model;
           decoded_behavior :=
             {| decoded_ident := behavior; decoded_offset := offset |} |}];
     acc_natives := acc_natives acc |}.

Definition add_native
    (native : ident) (offset : ptrofs)
    (acc : first_frame_acc) : first_frame_acc :=
  {| acc_object_list := acc_object_list acc;
     acc_parent_clears := acc_parent_clears acc;
     acc_spawns := acc_spawns acc;
     acc_natives := acc_natives acc ++
       [{| decoded_ident := native; decoded_offset := offset |}] |}.

(** Execute only the commands that the stock dust scripts can encounter on
    their first update. Unknown one-word commands are intentionally skipped;
    malformed multiword commands stop explicitly instead of being guessed. *)
Fixpoint decode_first_frame_from
    (fuel : nat) (data : list init_data) (acc : first_frame_acc)
    : first_frame_effect :=
  match fuel with
  | O => finish_first_frame acc StopMalformed
  | S fuel' =>
      match data with
      | [] => finish_first_frame acc StopEndOfData
      | Init_int32 word :: rest =>
          let opcode := command_opcode word in
          if Z.eqb opcode 0 then
            decode_first_frame_from fuel' rest
              (with_object_list (command_second_u16 word) acc)
          else if Z.eqb opcode 51 then
            match rest with
            | Init_int32 mask :: tail =>
                decode_first_frame_from fuel' tail
                  (add_parent_clear (command_second_u8 word)
                    (Int.unsigned mask) acc)
            | _ => finish_first_frame acc StopMalformed
            end
          else if Z.eqb opcode 28 then
            match rest with
            | Init_int32 model :: Init_addrof behavior offset :: tail =>
                decode_first_frame_from fuel' tail
                  (add_spawn (Int.unsigned model) behavior offset acc)
            | _ => finish_first_frame acc StopMalformed
            end
          else if Z.eqb opcode 12 then
            match rest with
            | Init_addrof native offset :: tail =>
                decode_first_frame_from fuel' tail
                  (add_native native offset acc)
            | _ => finish_first_frame acc StopMalformed
            end
          else if Z.eqb opcode 1 then finish_first_frame acc StopDelay
          else if Z.eqb opcode 6 then finish_first_frame acc StopEndRepeat
          else if Z.eqb opcode 9 then finish_first_frame acc StopEndLoop
          else if Z.eqb opcode 29 then finish_first_frame acc StopDeactivate
          else decode_first_frame_from fuel' rest acc
      | _ :: _ => finish_first_frame acc StopMalformed
      end
  end.

Definition decode_first_frame (data : list init_data) : first_frame_effect :=
  decode_first_frame_from (S (length data)) data empty_first_frame_acc.

Definition expected_mist_effect
    (puff1 puff2 : ident) : first_frame_effect :=
  {| effect_object_list := Some 8;
     effect_parent_clears := [(22, 1)];
     effect_spawns :=
       [{| decoded_model := 142;
           decoded_behavior :=
             {| decoded_ident := puff1;
                decoded_offset := Ptrofs.repr 0 |} |};
        {| decoded_model := 150;
           decoded_behavior :=
             {| decoded_ident := puff2;
                decoded_offset := Ptrofs.repr 0 |} |}];
     effect_natives := [];
     effect_stop := StopDelay |}.

Definition expected_puff1_effect (native : ident) : first_frame_effect :=
  {| effect_object_list := Some 8;
     effect_parent_clears := [(22, 1)];
     effect_spawns := [];
     effect_natives :=
       [{| decoded_ident := native; decoded_offset := Ptrofs.repr 0 |}];
     effect_stop := StopEndLoop |}.

Definition expected_puff2_effect (native : ident) : first_frame_effect :=
  {| effect_object_list := Some 12;
     effect_parent_clears := [];
     effect_spawns := [];
     effect_natives :=
       [{| decoded_ident := native; decoded_offset := Ptrofs.repr 0 |}];
     effect_stop := StopEndRepeat |}.

Theorem mist_first_frame_decodes_us :
  decode_first_frame (gvar_init UBD.v_bhvMistParticleSpawner) =
  expected_mist_effect UBD._bhvWhitePuff1 UBD._bhvWhitePuff2.
Proof. vm_compute. reflexivity. Qed.

Theorem puff1_first_frame_decodes_us :
  decode_first_frame (gvar_init UBD.v_bhvWhitePuff1) =
  expected_puff1_effect UBD._bhv_white_puff_1_loop.
Proof. vm_compute. reflexivity. Qed.

Theorem puff2_first_frame_decodes_us :
  decode_first_frame (gvar_init UBD.v_bhvWhitePuff2) =
  expected_puff2_effect UBD._bhv_white_puff_2_loop.
Proof. vm_compute. reflexivity. Qed.

Theorem mist_first_frame_decodes_jp :
  decode_first_frame (gvar_init JBD.v_bhvMistParticleSpawner) =
  expected_mist_effect JBD._bhvWhitePuff1 JBD._bhvWhitePuff2.
Proof. vm_compute. reflexivity. Qed.

Theorem puff1_first_frame_decodes_jp :
  decode_first_frame (gvar_init JBD.v_bhvWhitePuff1) =
  expected_puff1_effect JBD._bhv_white_puff_1_loop.
Proof. vm_compute. reflexivity. Qed.

Theorem puff2_first_frame_decodes_jp :
  decode_first_frame (gvar_init JBD.v_bhvWhitePuff2) =
  expected_puff2_effect JBD._bhv_white_puff_2_loop.
Proof. vm_compute. reflexivity. Qed.

(** A provider receipt is deliberately weaker than materializing a linked
    program: it checks that the provider TU contains an Internal definition at
    the cross-TU identifier. CompCert linking metatheory can consume these facts
    once an actual linked program is supplied. *)
Fixpoint has_internal_definition
    (wanted : ident)
    (defs : list (ident * globdef Clight.fundef type)) : bool :=
  match defs with
  | [] => false
  | (found, definition) :: rest =>
      if Pos.eqb wanted found then
        match definition with
        | Gfun (Internal _) => true
        | _ => false
        end
      else has_internal_definition wanted rest
  end.

Fixpoint has_global_definition
    (wanted : ident)
    (defs : list (ident * globdef Clight.fundef type)) : bool :=
  match defs with
  | [] => false
  | (found, definition) :: rest =>
      if Pos.eqb wanted found then
        match definition with
        | Gvar _ => true
        | _ => false
        end
      else has_global_definition wanted rest
  end.

Definition cross_tu_identifiers_us : bool :=
  Pos.eqb UOL._execute_mario_action UM._execute_mario_action &&
  Pos.eqb UOL._spawn_object_at_origin UOH._spawn_object_at_origin &&
  Pos.eqb UOH._create_object USpawn._create_object &&
  Pos.eqb UOL._cur_obj_update UBS._cur_obj_update &&
  Pos.eqb UOL._bhvMistParticleSpawner UBD._bhvMistParticleSpawner &&
  Pos.eqb UBD._bhv_white_puff_1_loop UBA._bhv_white_puff_1_loop &&
  Pos.eqb UBD._bhv_white_puff_2_loop UBA._bhv_white_puff_2_loop &&
  Pos.eqb UBA._obj_translate_xz_random UOH._obj_translate_xz_random &&
  Pos.eqb UOH._random_float UBS._random_float.

Definition cross_tu_identifiers_jp : bool :=
  Pos.eqb JOL._execute_mario_action JM._execute_mario_action &&
  Pos.eqb JOL._spawn_object_at_origin JOH._spawn_object_at_origin &&
  Pos.eqb JOH._create_object JSpawn._create_object &&
  Pos.eqb JOL._cur_obj_update JBS._cur_obj_update &&
  Pos.eqb JOL._bhvMistParticleSpawner JBD._bhvMistParticleSpawner &&
  Pos.eqb JBD._bhv_white_puff_1_loop JBA._bhv_white_puff_1_loop &&
  Pos.eqb JBD._bhv_white_puff_2_loop JBA._bhv_white_puff_2_loop &&
  Pos.eqb JBA._obj_translate_xz_random JOH._obj_translate_xz_random &&
  Pos.eqb JOH._random_float JBS._random_float.

Definition runtime_providers_us : bool :=
  has_internal_definition UM._execute_mario_action (prog_defs UM.prog) &&
  has_internal_definition UOL._bhv_mario_update (prog_defs UOL.prog) &&
  has_internal_definition UOL._spawn_particle (prog_defs UOL.prog) &&
  has_internal_definition UOL._update_objects_starting_at (prog_defs UOL.prog) &&
  has_internal_definition UOL._update_non_terrain_objects (prog_defs UOL.prog) &&
  has_internal_definition UOH._spawn_object_at_origin (prog_defs UOH.prog) &&
  has_internal_definition USpawn._try_allocate_object (prog_defs USpawn.prog) &&
  has_internal_definition USpawn._allocate_object (prog_defs USpawn.prog) &&
  has_internal_definition USpawn._create_object (prog_defs USpawn.prog) &&
  has_internal_definition UBS._cur_obj_update (prog_defs UBS.prog) &&
  has_internal_definition UBA._bhv_white_puff_1_loop (prog_defs UBA.prog) &&
  has_internal_definition UBA._bhv_white_puff_2_loop (prog_defs UBA.prog) &&
  has_internal_definition UOH._obj_translate_xz_random (prog_defs UOH.prog) &&
  has_internal_definition UBS._random_float (prog_defs UBS.prog) &&
  has_internal_definition UBS._random_u16 (prog_defs UBS.prog) &&
  has_global_definition UBD._bhvMistParticleSpawner (prog_defs UBD.prog) &&
  has_global_definition UBD._bhvWhitePuff1 (prog_defs UBD.prog) &&
  has_global_definition UBD._bhvWhitePuff2 (prog_defs UBD.prog).

Definition runtime_providers_jp : bool :=
  has_internal_definition JM._execute_mario_action (prog_defs JM.prog) &&
  has_internal_definition JOL._bhv_mario_update (prog_defs JOL.prog) &&
  has_internal_definition JOL._spawn_particle (prog_defs JOL.prog) &&
  has_internal_definition JOL._update_objects_starting_at (prog_defs JOL.prog) &&
  has_internal_definition JOL._update_non_terrain_objects (prog_defs JOL.prog) &&
  has_internal_definition JOH._spawn_object_at_origin (prog_defs JOH.prog) &&
  has_internal_definition JSpawn._try_allocate_object (prog_defs JSpawn.prog) &&
  has_internal_definition JSpawn._allocate_object (prog_defs JSpawn.prog) &&
  has_internal_definition JSpawn._create_object (prog_defs JSpawn.prog) &&
  has_internal_definition JBS._cur_obj_update (prog_defs JBS.prog) &&
  has_internal_definition JBA._bhv_white_puff_1_loop (prog_defs JBA.prog) &&
  has_internal_definition JBA._bhv_white_puff_2_loop (prog_defs JBA.prog) &&
  has_internal_definition JOH._obj_translate_xz_random (prog_defs JOH.prog) &&
  has_internal_definition JBS._random_float (prog_defs JBS.prog) &&
  has_internal_definition JBS._random_u16 (prog_defs JBS.prog) &&
  has_global_definition JBD._bhvMistParticleSpawner (prog_defs JBD.prog) &&
  has_global_definition JBD._bhvWhitePuff1 (prog_defs JBD.prog) &&
  has_global_definition JBD._bhvWhitePuff2 (prog_defs JBD.prog).

Theorem cross_tu_identifier_receipt_us : cross_tu_identifiers_us = true.
Proof. vm_compute. reflexivity. Qed.

Theorem cross_tu_identifier_receipt_jp : cross_tu_identifiers_jp = true.
Proof. vm_compute. reflexivity. Qed.

Theorem runtime_provider_receipt_us : runtime_providers_us = true.
Proof. vm_compute. reflexivity. Qed.

Theorem runtime_provider_receipt_jp : runtime_providers_jp = true.
Proof. vm_compute. reflexivity. Qed.

(** This receipt is the source justification for the cost table used by the
    dust-only scheduler below: each timer-zero puff native reaches one
    [obj_translate_xz_random], that helper contains two direct [random_float]
    calls, and each [random_float] reaches [random_u16]. *)
Definition puff_native_rng_source_receipt (version : GameVersion) : Prop :=
  match version with
  | VersionUS =>
      calls_ident_s UBA._obj_translate_xz_random
        (fn_body UBA.f_bhv_white_puff_1_loop) = true /\
      calls_ident_s UBA._obj_translate_xz_random
        (fn_body UBA.f_bhv_white_puff_2_loop) = true /\
      count_occ Pos.eq_dec
        (direct_callees_s (fn_body UOH.f_obj_translate_xz_random))
        UOH._random_float = 2%nat /\
      calls_ident_s UBS._random_u16 (fn_body UBS.f_random_float) = true
  | VersionJP =>
      calls_ident_s JBA._obj_translate_xz_random
        (fn_body JBA.f_bhv_white_puff_1_loop) = true /\
      calls_ident_s JBA._obj_translate_xz_random
        (fn_body JBA.f_bhv_white_puff_2_loop) = true /\
      count_occ Pos.eq_dec
        (direct_callees_s (fn_body JOH.f_obj_translate_xz_random))
        JOH._random_float = 2%nat /\
      calls_ident_s JBS._random_u16 (fn_body JBS.f_random_float) = true
  end.

Theorem puff_native_rng_source_receipt_us :
  puff_native_rng_source_receipt VersionUS.
Proof.
  unfold puff_native_rng_source_receipt.
  vm_compute.
  repeat split.
Qed.

Theorem puff_native_rng_source_receipt_jp :
  puff_native_rng_source_receipt VersionJP.
Proof.
  unfold puff_native_rng_source_receipt.
  vm_compute.
  repeat split.
Qed.

Theorem puff_native_rng_source_receipt_supported :
  forall version, puff_native_rng_source_receipt version.
Proof.
  intros []; [exact puff_native_rng_source_receipt_us |
              exact puff_native_rng_source_receipt_jp].
Qed.

Fixpoint signed_int8_initializers (data : list init_data) : option (list Z) :=
  match data with
  | [] => Some []
  | Init_int8 value :: rest =>
      match signed_int8_initializers rest with
      | Some values => Some (Int.signed value :: values)
      | None => None
      end
  | _ :: _ => None
  end.

Definition complete_object_list_order : list Z :=
  [11; 9; 10; 0; 5; 4; 2; 6; 8; 12; -1].

Definition normal_nonterrain_order : list Z :=
  [10; 0; 5; 4; 2; 6; 8; 12].

Theorem object_list_order_us :
  signed_int8_initializers (gvar_init UOL.v_sObjectListUpdateOrder) =
  Some complete_object_list_order.
Proof. vm_compute. reflexivity. Qed.

Theorem object_list_order_jp :
  signed_int8_initializers (gvar_init JOL.v_sObjectListUpdateOrder) =
  Some complete_object_list_order.
Proof. vm_compute. reflexivity. Qed.

Theorem normal_nonterrain_order_us :
  firstn 8 (skipn 2 complete_object_list_order) = normal_nonterrain_order.
Proof. reflexivity. Qed.

Theorem normal_nonterrain_order_jp :
  firstn 8 (skipn 2 complete_object_list_order) = normal_nonterrain_order.
Proof. reflexivity. Qed.

Definition is_dynamic_next_set
    (cursor next_field : ident) (destination : ident) (rhs : expr) : bool :=
  Pos.eqb destination cursor &&
  match rhs with
  | Efield (Ederef (Etempvar source _) _) found_next _ =>
      Pos.eqb source cursor && Pos.eqb found_next next_field
  | _ => false
  end.

Fixpoint update_then_dynamic_next_s
    (updater cursor next_field : ident) (s : statement) : bool :=
  match s with
  | Ssequence (Scall _ (Evar found_updater _) _)
      (Ssequence (Sset destination rhs) rest) =>
      (Pos.eqb found_updater updater &&
       is_dynamic_next_set cursor next_field destination rhs) ||
      update_then_dynamic_next_s updater cursor next_field rest
  | Ssequence a b | Sloop a b =>
      update_then_dynamic_next_s updater cursor next_field a ||
      update_then_dynamic_next_s updater cursor next_field b
  | Sifthenelse _ yes no =>
      update_then_dynamic_next_s updater cursor next_field yes ||
      update_then_dynamic_next_s updater cursor next_field no
  | Sswitch _ cases =>
      update_then_dynamic_next_ls updater cursor next_field cases
  | Slabel _ body =>
      update_then_dynamic_next_s updater cursor next_field body
  | _ => false
  end
with update_then_dynamic_next_ls
    (updater cursor next_field : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      update_then_dynamic_next_s updater cursor next_field body ||
      update_then_dynamic_next_ls updater cursor next_field rest
  end.

Definition normal_walk_source_receipt (version : GameVersion) : Prop :=
  match version with
  | VersionUS =>
      calls_ident_s UOL._update_objects_in_list
        (fn_body UOL.f_update_non_terrain_objects) = true /\
      statement_mentions_ident_s UOL._sObjectListUpdateOrder
        (fn_body UOL.f_update_non_terrain_objects) = true /\
      statement_mentions_int_s 2
        (fn_body UOL.f_update_non_terrain_objects) = true /\
      update_then_dynamic_next_s UOL._cur_obj_update UOL._firstObj UOL._next
        (fn_body UOL.f_update_objects_starting_at) = true
  | VersionJP =>
      calls_ident_s JOL._update_objects_in_list
        (fn_body JOL.f_update_non_terrain_objects) = true /\
      statement_mentions_ident_s JOL._sObjectListUpdateOrder
        (fn_body JOL.f_update_non_terrain_objects) = true /\
      statement_mentions_int_s 2
        (fn_body JOL.f_update_non_terrain_objects) = true /\
      update_then_dynamic_next_s JOL._cur_obj_update JOL._firstObj JOL._next
        (fn_body JOL.f_update_objects_starting_at) = true
  end.

Theorem normal_walk_source_receipt_us :
  normal_walk_source_receipt VersionUS.
Proof. unfold normal_walk_source_receipt. vm_compute. repeat split. Qed.

Theorem normal_walk_source_receipt_jp :
  normal_walk_source_receipt VersionJP.
Proof. unfold normal_walk_source_receipt. vm_compute. repeat split. Qed.

Inductive dust_runtime_object : Type :=
| RuntimeMist
| RuntimePuff1
| RuntimePuff2.

Record dust_schedule_state : Type := {
  schedule_default : list dust_runtime_object;
  schedule_unimportant : list dust_runtime_object;
  schedule_executed : list dust_runtime_object;
  schedule_rng_advances : nat;
  schedule_allocations : nat;
  schedule_mario_active_dust : bool
}.

Definition effect_for
    (version : GameVersion) (object : dust_runtime_object)
    : first_frame_effect :=
  match version, object with
  | VersionUS, RuntimeMist =>
      decode_first_frame (gvar_init UBD.v_bhvMistParticleSpawner)
  | VersionUS, RuntimePuff1 =>
      decode_first_frame (gvar_init UBD.v_bhvWhitePuff1)
  | VersionUS, RuntimePuff2 =>
      decode_first_frame (gvar_init UBD.v_bhvWhitePuff2)
  | VersionJP, RuntimeMist =>
      decode_first_frame (gvar_init JBD.v_bhvMistParticleSpawner)
  | VersionJP, RuntimePuff1 =>
      decode_first_frame (gvar_init JBD.v_bhvWhitePuff1)
  | VersionJP, RuntimePuff2 =>
      decode_first_frame (gvar_init JBD.v_bhvWhitePuff2)
  end.

Definition classify_behavior
    (version : GameVersion) (behavior : ident)
    : option dust_runtime_object :=
  match version with
  | VersionUS =>
      if Pos.eqb behavior UBD._bhvWhitePuff1 then Some RuntimePuff1
      else if Pos.eqb behavior UBD._bhvWhitePuff2 then Some RuntimePuff2
      else None
  | VersionJP =>
      if Pos.eqb behavior JBD._bhvWhitePuff1 then Some RuntimePuff1
      else if Pos.eqb behavior JBD._bhvWhitePuff2 then Some RuntimePuff2
      else None
  end.

Definition native_rng_cost
    (version : GameVersion) (native : ident) : nat :=
  match version with
  | VersionUS =>
      if Pos.eqb native UBA._bhv_white_puff_1_loop then 2
      else if Pos.eqb native UBA._bhv_white_puff_2_loop then 2
      else 0
  | VersionJP =>
      if Pos.eqb native JBA._bhv_white_puff_1_loop then 2
      else if Pos.eqb native JBA._bhv_white_puff_2_loop then 2
      else 0
  end.

Definition effect_rng_cost
    (version : GameVersion) (effect : first_frame_effect) : nat :=
  fold_left Nat.add
    (map (fun address => native_rng_cost version (decoded_ident address))
      (effect_natives effect)) 0%nat.

Definition put_default
    (queue : list dust_runtime_object) (state : dust_schedule_state)
    : dust_schedule_state :=
  {| schedule_default := queue;
     schedule_unimportant := schedule_unimportant state;
     schedule_executed := schedule_executed state;
     schedule_rng_advances := schedule_rng_advances state;
     schedule_allocations := schedule_allocations state;
     schedule_mario_active_dust := schedule_mario_active_dust state |}.

Definition put_unimportant
    (queue : list dust_runtime_object) (state : dust_schedule_state)
    : dust_schedule_state :=
  {| schedule_default := schedule_default state;
     schedule_unimportant := queue;
     schedule_executed := schedule_executed state;
     schedule_rng_advances := schedule_rng_advances state;
     schedule_allocations := schedule_allocations state;
     schedule_mario_active_dust := schedule_mario_active_dust state |}.

Definition enqueue_spawn
    (version : GameVersion) (spawn : decoded_spawn)
    (state : dust_schedule_state) : dust_schedule_state :=
  match classify_behavior version
          (decoded_ident (decoded_behavior spawn)) with
  | None => state
  | Some child =>
      let child_effect := effect_for version child in
      match effect_object_list child_effect with
      | Some 8 =>
          {| schedule_default := schedule_default state ++ [child];
             schedule_unimportant := schedule_unimportant state;
             schedule_executed := schedule_executed state;
             schedule_rng_advances := schedule_rng_advances state;
             schedule_allocations := S (schedule_allocations state);
             schedule_mario_active_dust := schedule_mario_active_dust state |}
      | Some 12 =>
          {| schedule_default := schedule_default state;
             schedule_unimportant := schedule_unimportant state ++ [child];
             schedule_executed := schedule_executed state;
             schedule_rng_advances := schedule_rng_advances state;
             schedule_allocations := S (schedule_allocations state);
             schedule_mario_active_dust := schedule_mario_active_dust state |}
      | _ => state
      end
  end.

Definition execute_scheduled_object
    (version : GameVersion) (object : dust_runtime_object)
    (state : dust_schedule_state) : dust_schedule_state :=
  let effect := effect_for version object in
  let active_after :=
    match object with
    | RuntimeMist => false
    | _ => schedule_mario_active_dust state
    end in
  let state_after_native :=
    {| schedule_default := schedule_default state;
       schedule_unimportant := schedule_unimportant state;
       schedule_executed := schedule_executed state ++ [object];
       schedule_rng_advances :=
         schedule_rng_advances state + effect_rng_cost version effect;
       schedule_allocations := schedule_allocations state;
       schedule_mario_active_dust := active_after |} in
  fold_left (fun current spawn => enqueue_spawn version spawn current)
    (effect_spawns effect) state_after_native.

Fixpoint execute_default_projection
    (fuel : nat) (version : GameVersion) (state : dust_schedule_state)
    : dust_schedule_state :=
  match fuel with
  | O => state
  | S fuel' =>
      match schedule_default state with
      | [] => state
      | object :: rest =>
          execute_default_projection fuel' version
            (execute_scheduled_object version object (put_default rest state))
      end
  end.

Fixpoint execute_unimportant_projection
    (fuel : nat) (version : GameVersion) (state : dust_schedule_state)
    : dust_schedule_state :=
  match fuel with
  | O => state
  | S fuel' =>
      match schedule_unimportant state with
      | [] => state
      | object :: rest =>
          execute_unimportant_projection fuel' version
            (execute_scheduled_object version object
              (put_unimportant rest state))
      end
  end.

Definition exact_normal_orderb (version : GameVersion) : bool :=
  match version with
  | VersionUS =>
      match signed_int8_initializers (gvar_init UOL.v_sObjectListUpdateOrder) with
      | Some order =>
          forallb (fun pair => Z.eqb (fst pair) (snd pair))
            (combine (firstn 8 (skipn 2 order)) normal_nonterrain_order) &&
          Nat.eqb (length (firstn 8 (skipn 2 order)))
            (length normal_nonterrain_order)
      | None => false
      end
  | VersionJP =>
      match signed_int8_initializers (gvar_init JOL.v_sObjectListUpdateOrder) with
      | Some order =>
          forallb (fun pair => Z.eqb (fst pair) (snd pair))
            (combine (firstn 8 (skipn 2 order)) normal_nonterrain_order) &&
          Nat.eqb (length (firstn 8 (skipn 2 order)))
            (length normal_nonterrain_order)
      | None => false
      end
  end.

Definition dynamic_nextb (version : GameVersion) : bool :=
  match version with
  | VersionUS =>
      update_then_dynamic_next_s UOL._cur_obj_update UOL._firstObj UOL._next
        (fn_body UOL.f_update_objects_starting_at)
  | VersionJP =>
      update_then_dynamic_next_s JOL._cur_obj_update JOL._firstObj JOL._next
        (fn_body JOL.f_update_objects_starting_at)
  end.

(** [accepted_dust], [normal_frame], and [allocations_succeed] are explicit
    premises, not facts established by this executor. The state is the dust-only
    projection of the live DEFAULT and UNIMPORTANT queues. *)
Definition execute_source_derived_dust_frame
    (version : GameVersion)
    (accepted_dust normal_frame allocations_succeed : bool)
    : option dust_schedule_state :=
  if accepted_dust && normal_frame && allocations_succeed &&
     exact_normal_orderb version && dynamic_nextb version then
    let initial :=
      {| schedule_default := [RuntimeMist];
         schedule_unimportant := [];
         schedule_executed := [];
         schedule_rng_advances := 0;
         schedule_allocations := 1;
         schedule_mario_active_dust := true |} in
    let after_default := execute_default_projection 4 version initial in
    Some (execute_unimportant_projection 4 version after_default)
  else None.

Definition completed_dust_frame : dust_schedule_state :=
  {| schedule_default := [];
     schedule_unimportant := [];
     schedule_executed := [RuntimeMist; RuntimePuff1; RuntimePuff2];
     schedule_rng_advances := 4;
     schedule_allocations := 3;
     schedule_mario_active_dust := false |}.

Theorem source_derived_dust_frame_us :
  execute_source_derived_dust_frame VersionUS true true true =
  Some completed_dust_frame.
Proof. vm_compute. reflexivity. Qed.

Theorem source_derived_dust_frame_jp :
  execute_source_derived_dust_frame VersionJP true true true =
  Some completed_dust_frame.
Proof. vm_compute. reflexivity. Qed.

Theorem source_derived_dust_frame_supported :
  forall version,
    execute_source_derived_dust_frame version true true true =
    Some completed_dust_frame.
Proof.
  intros []; [exact source_derived_dust_frame_us |
              exact source_derived_dust_frame_jp].
Qed.

(** The conclusion is conditional and model-scoped: it says the decoded dust
    objects are all consumed by this frame's normal-list projection. It does not
    assert a CompCert big-step, an emulator trace, or a reachable retail state. *)
Theorem conditional_same_frame_dust_schedule :
  forall version accepted_dust normal_frame allocations_succeed state,
    accepted_dust = true ->
    normal_frame = true ->
    allocations_succeed = true ->
    execute_source_derived_dust_frame version accepted_dust normal_frame
      allocations_succeed = Some state ->
    schedule_executed state = [RuntimeMist; RuntimePuff1; RuntimePuff2] /\
    schedule_rng_advances state = 4%nat /\
    schedule_mario_active_dust state = false.
Proof.
  intros version accepted_dust normal_frame allocations_succeed state
    -> -> -> Hrun.
  rewrite (source_derived_dust_frame_supported version) in Hrun.
  inversion Hrun; subst state.
  repeat split; reflexivity.
Qed.
