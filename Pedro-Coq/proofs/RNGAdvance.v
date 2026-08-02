From Coq Require Import Bool List PArith.BinPos ZArith.
From compcert Require Import AST Clight Floats Integers.
From Pedro.Generated Require Import
  us_object_list_processor us_behavior_data us_behavior_actions
  us_object_helpers us_behavior_script
  jp_object_list_processor jp_behavior_data jp_behavior_actions
  jp_object_helpers jp_behavior_script.
From Pedro.Proofs Require Import ASTFacts GameTypes.

Import ListNotations.

Module UOL := us_object_list_processor.
Module UBD := us_behavior_data.
Module UBA := us_behavior_actions.
Module UOH := us_object_helpers.
Module UBS := us_behavior_script.

Module JOL := jp_object_list_processor.
Module JBD := jp_behavior_data.
Module JBA := jp_behavior_actions.
Module JOH := jp_object_helpers.
Module JBS := jp_behavior_script.

Definition rng_source_chain_receipt (version : GameVersion) : Prop :=
  match version with
  | VersionUS =>
      firstn 2 (gvar_init UOL.v_sParticleTypes) =
        [Init_int32 (Int.repr 1); Init_int32 (Int.repr 1)] /\
      nth_error (gvar_init UOL.v_sParticleTypes) 4 =
        Some (Init_addrof UOL._bhvMistParticleSpawner (Ptrofs.repr 0)) /\
      calls_ident_s UOL._spawn_particle (fn_body UOL.f_bhv_mario_update) = true /\
      initializer_addrof_subsequenceb
        [UBD._bhvWhitePuff1; UBD._bhvWhitePuff2]
        (gvar_init UBD.v_bhvMistParticleSpawner) = true /\
      initializer_addrof_subsequenceb
        [UBD._bhv_white_puff_1_loop]
        (gvar_init UBD.v_bhvWhitePuff1) = true /\
      initializer_addrof_subsequenceb
        [UBD._bhv_white_puff_2_loop]
        (gvar_init UBD.v_bhvWhitePuff2) = true /\
      calls_ident_s UBA._obj_translate_xz_random
        (fn_body UBA.f_bhv_white_puff_1_loop) = true /\
      calls_ident_s UBA._obj_translate_xz_random
        (fn_body UBA.f_bhv_white_puff_2_loop) = true /\
      count_occ Pos.eq_dec
        (direct_callees_s (fn_body UOH.f_obj_translate_xz_random))
        UOH._random_float = 2%nat /\
      calls_ident_s UBS._random_u16 (fn_body UBS.f_random_float) = true /\
      statement_assigns_global_s UBS._gRandomSeed16
        (fn_body UBS.f_random_u16) = true /\
      statement_mentions_int_s 22026 (fn_body UBS.f_random_u16) = true /\
      statement_mentions_int_s 43605 (fn_body UBS.f_random_u16) = true /\
      statement_mentions_int_s 8180 (fn_body UBS.f_random_u16) = true /\
      statement_mentions_int_s 33152 (fn_body UBS.f_random_u16) = true
  | VersionJP =>
      firstn 2 (gvar_init JOL.v_sParticleTypes) =
        [Init_int32 (Int.repr 1); Init_int32 (Int.repr 1)] /\
      nth_error (gvar_init JOL.v_sParticleTypes) 4 =
        Some (Init_addrof JOL._bhvMistParticleSpawner (Ptrofs.repr 0)) /\
      calls_ident_s JOL._spawn_particle (fn_body JOL.f_bhv_mario_update) = true /\
      initializer_addrof_subsequenceb
        [JBD._bhvWhitePuff1; JBD._bhvWhitePuff2]
        (gvar_init JBD.v_bhvMistParticleSpawner) = true /\
      initializer_addrof_subsequenceb
        [JBD._bhv_white_puff_1_loop]
        (gvar_init JBD.v_bhvWhitePuff1) = true /\
      initializer_addrof_subsequenceb
        [JBD._bhv_white_puff_2_loop]
        (gvar_init JBD.v_bhvWhitePuff2) = true /\
      calls_ident_s JBA._obj_translate_xz_random
        (fn_body JBA.f_bhv_white_puff_1_loop) = true /\
      calls_ident_s JBA._obj_translate_xz_random
        (fn_body JBA.f_bhv_white_puff_2_loop) = true /\
      count_occ Pos.eq_dec
        (direct_callees_s (fn_body JOH.f_obj_translate_xz_random))
        JOH._random_float = 2%nat /\
      calls_ident_s JBS._random_u16 (fn_body JBS.f_random_float) = true /\
      statement_assigns_global_s JBS._gRandomSeed16
        (fn_body JBS.f_random_u16) = true /\
      statement_mentions_int_s 22026 (fn_body JBS.f_random_u16) = true /\
      statement_mentions_int_s 43605 (fn_body JBS.f_random_u16) = true /\
      statement_mentions_int_s 8180 (fn_body JBS.f_random_u16) = true /\
      statement_mentions_int_s 33152 (fn_body JBS.f_random_u16) = true
  end.

Theorem rng_source_chain_receipt_us :
  rng_source_chain_receipt VersionUS.
Proof.
  unfold rng_source_chain_receipt.
  vm_compute.
  repeat split.
Qed.

Theorem rng_source_chain_receipt_jp :
  rng_source_chain_receipt VersionJP.
Proof.
  unfold rng_source_chain_receipt.
  vm_compute.
  repeat split.
Qed.

Theorem rng_source_chain_receipt_supported :
  forall version, rng_source_chain_receipt version.
Proof.
  intros []; [exact rng_source_chain_receipt_us |
              exact rng_source_chain_receipt_jp].
Qed.
