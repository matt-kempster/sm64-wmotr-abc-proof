From Coq Require Import List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Ctypes Events Globalenvs
  Integers Memory Values.
From Pedro.Generated Require Import us_behavior_script.
From Pedro.Proofs Require Import DustClightExec.

Import ListNotations.
Open Scope Z_scope.
Module R := us_behavior_script.

(** Scalar leaves for the complete cog execution. The supplied stores are the
    two assignments made by the generated function; the proof establishes the
    entire function body between them. No emulator state is changed or assumed
    reachable here. Sharing these derivations avoids expanding the integer
    calculation repeatedly inside the larger object-field proof. *)
Ltac cog_rng_scalar_funcall :=
  eapply eval_funcall_internal;
  [eapply function_entry2_intro;
   [constructor | constructor | intros x y Hnone; inversion Hnone |
    constructor | reflexivity]
  |simpl fn_body; exec_closed_stmt
  |cbn; split; [discriminate | reflexivity]
  |cbn; reflexivity].

Lemma generated_random_u16_cog_first_draw :
  forall (ge : Clight.genv) before seed transient after,
    Genv.find_symbol ge R._gRandomSeed16 = Some seed ->
    Mem.load Mint16unsigned before seed 0 = Some (Vint (Int.repr 16)) ->
    Mem.store Mint16unsigned before seed 0 (Vint (Int.repr 4112)) =
      Some transient ->
    Mem.store Mint16unsigned transient seed 0 (Vint (Int.repr 59500)) =
      Some after ->
    eval_funcall function_entry2 ge before (Internal R.f_random_u16)
      [] E0 after (Vint (Int.repr 59500)).
Proof.
  intros ge before seed transient after Hsymbol Hload Hstore1 Hstore2.
  pose proof (Mem.load_store_same _ _ _ _ _ _ Hstore1) as Hload1.
  pose proof (Mem.load_store_same _ _ _ _ _ _ Hstore2) as Hload2.
  cbn in Hload1, Hload2.
  cog_rng_scalar_funcall.
Qed.

Lemma generated_random_u16_cog_second_draw :
  forall (ge : Clight.genv) before seed transient after,
    Genv.find_symbol ge R._gRandomSeed16 = Some seed ->
    Mem.load Mint16unsigned before seed 0 = Some (Vint (Int.repr 59500)) ->
    Mem.store Mint16unsigned before seed 0 (Vint (Int.repr 27780)) =
      Some transient ->
    Mem.store Mint16unsigned transient seed 0 (Vint (Int.repr 54874)) =
      Some after ->
    eval_funcall function_entry2 ge before (Internal R.f_random_u16)
      [] E0 after (Vint (Int.repr 54874)).
Proof.
  intros ge before seed transient after Hsymbol Hload Hstore1 Hstore2.
  pose proof (Mem.load_store_same _ _ _ _ _ _ Hstore1) as Hload1.
  pose proof (Mem.load_store_same _ _ _ _ _ _ Hstore2) as Hload2.
  cbn in Hload1, Hload2.
  cog_rng_scalar_funcall.
Qed.
