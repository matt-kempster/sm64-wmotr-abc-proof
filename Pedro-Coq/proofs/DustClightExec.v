From Coq Require Import List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Ctypes Events
  Globalenvs Integers Memory Values.
From Pedro.Generated Require Import us_behavior_script jp_behavior_script.
From Pedro.Proofs Require Import DustPRNG.

Import ListNotations.
Open Scope Z_scope.

Module UBS := us_behavior_script.
Module JBS := jp_behavior_script.

(** The PRNG implementation is byte-for-byte the same generated Clight
    function in the two supported versions.  Keeping these facts explicit
    lets the operational proof below be shared rather than duplicated. *)
Theorem random_u16_body_us_jp_identical :
  UBS.f_random_u16 = JBS.f_random_u16.
Proof. reflexivity. Qed.

Theorem random_seed_global_us_jp_identical :
  UBS._gRandomSeed16 = JBS._gRandomSeed16 /\
  UBS.v_gRandomSeed16 = JBS.v_gRandomSeed16.
Proof. split; reflexivity. Qed.

(** [random_u16] uses no composite type.  This deliberately tiny program is
    therefore a genuine executable semantic slice despite its empty composite
    header.  Both retained definitions are the exact [clightgen] terms.  This
    construction must not be generalized to the object-field functions in
    [DustClightLink], whose execution needs the real [struct Object] layout. *)
Definition rng_definitions :
    list (ident * globdef Clight.fundef type) :=
  [ (UBS._gRandomSeed16, Gvar UBS.v_gRandomSeed16);
    (UBS._random_u16, Gfun (Internal UBS.f_random_u16)) ].

Definition rng_program : Clight.program :=
  Clightdefs.mkprogram [] rng_definitions
    [UBS._gRandomSeed16; UBS._random_u16]
    UBS._random_u16 Logic.I.

Definition rng_ge : Clight.genv := Clight.globalenv rng_program.

Theorem rng_program_contains_generated_definitions :
  In (UBS._gRandomSeed16, Gvar UBS.v_gRandomSeed16)
      (prog_defs rng_program) /\
  In (UBS._random_u16, Gfun (Internal UBS.f_random_u16))
      (prog_defs rng_program).
Proof. split; simpl; auto. Qed.

(** Constructor tactics for the closed scalar expressions in the seed-zero
    execution.  Reads and writes of the seed cell are discharged by CompCert
    [Mem.load]/[Mem.store] facts supplied by the theorem below; no
    external-call axiom or hand-written transition relation is involved. *)
Ltac eval_closed_expr :=
  lazymatch goal with
  | |- eval_expr _ _ _ _ (Econst_int _ _) _ => constructor
  | |- eval_expr _ _ _ _ (Etempvar _ _) _ =>
      eapply eval_Etempvar; cbn; reflexivity
  | |- eval_expr _ _ _ _ (Evar _ _) _ =>
      eapply eval_Elvalue;
      [ eapply eval_Evar_global; [ reflexivity | eassumption ]
      | eapply deref_loc_value; [ reflexivity | cbn; eassumption ] ]
  | |- eval_expr _ _ _ _ (Ecast _ _) _ =>
      eapply eval_Ecast; [ eval_closed_expr | cbn; reflexivity ]
  | |- eval_expr _ _ _ _ (Ebinop _ _ _ _) _ =>
      eapply eval_Ebinop;
      [ eval_closed_expr | eval_closed_expr | cbn; reflexivity ]
  end.

Ltac exec_closed_stmt :=
  lazymatch goal with
  | |- exec_stmt _ _ _ _ _ Sskip _ _ _ _ => constructor
  | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
      eapply exec_Sseq_1 with (t1 := E0) (t2 := E0);
      [ exec_closed_stmt | exec_closed_stmt ]
  | |- exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ =>
      eapply exec_Sset; eval_closed_expr
  | |- exec_stmt _ _ _ _ _ (Sassign (Evar _ _) _) _ _ _ _ =>
      eapply exec_Sassign;
      [ eapply eval_Evar_global; [ reflexivity | eassumption ]
      | eval_closed_expr
      | cbn; reflexivity
      | eapply assign_loc_value; [ reflexivity | cbn; eassumption ] ]
  | |- exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
      first
        [ eapply exec_Sifthenelse with (b := false);
          [ eval_closed_expr | vm_compute; reflexivity
          | cbn; exec_closed_stmt ]
        | eapply exec_Sifthenelse with (b := true);
          [ eval_closed_expr | vm_compute; reflexivity
          | cbn; exec_closed_stmt ] ]
  | |- exec_stmt _ _ _ _ _ (Sreturn (Some _)) _ _ _ _ =>
      eapply exec_Sreturn_some; eval_closed_expr
  end.

(** Starting from a writable zero seed cell, the exact generated
    [random_u16] body has a real, silent Clight big-step.  It returns 57460 and
    stores 57460 back into the same [gRandomSeed16] cell.  The hypotheses are
    ordinary CompCert memory premises, not an assumed execution. *)
Theorem generated_random_u16_executes_from_zero_seed :
  forall memory_before seed_block,
    Genv.find_symbol rng_ge UBS._gRandomSeed16 = Some seed_block ->
    Mem.load Mint16unsigned memory_before seed_block 0 =
      Some (Vint Int.zero) ->
    Mem.valid_access memory_before Mint16unsigned seed_block 0 Writable ->
    exists memory_after,
      eval_funcall function_entry2 rng_ge memory_before
        (Internal UBS.f_random_u16) [] E0 memory_after
        (Vint (Int.repr 57460)) /\
      Mem.load Mint16unsigned memory_after seed_block 0 =
        Some (Vint (Int.repr 57460)).
Proof.
  intros memory_before seed_block Hsymbol Hload0 Hwrite0.
  destruct (Mem.valid_access_store memory_before Mint16unsigned
      seed_block 0 (Vint Int.zero) Hwrite0) as [memory_swapped Hstore0].
  pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore0
    Mint16unsigned seed_block 0 Writable Hwrite0) as Hwrite1.
  destruct (Mem.valid_access_store memory_swapped Mint16unsigned
      seed_block 0 (Vint (Int.repr 57460)) Hwrite1)
    as [memory_after Hstore1].
  pose proof (Mem.load_store_same _ _ _ _ _ _ Hstore0) as Hload1.
  pose proof (Mem.load_store_same _ _ _ _ _ _ Hstore1) as Hload2.
  cbn in Hload1, Hload2.
  exists memory_after.
  split.
  - eapply eval_funcall_internal.
    + eapply function_entry2_intro.
      * constructor.
      * constructor.
      * intros x y Hnone. inversion Hnone.
      * constructor.
      * reflexivity.
    + simpl fn_body. exec_closed_stmt.
    + cbn. split; [ discriminate | cbn; reflexivity ].
    + cbn. reflexivity.
  - exact Hload2.
Qed.

Theorem generated_execution_matches_z_recurrence_at_zero :
  random_u16_step_z 0 = 57460.
Proof. vm_compute. reflexivity. Qed.

(** This capstone connects an actual generated-Clight execution to the same
    recurrence used by [DustPRNG], at the retail initial seed.  It is a
    non-vacuous one-step theorem; the arbitrary-seed big-step refinement and
    the object/behavior scheduler remain separate obligations. *)
Theorem generated_random_u16_initial_step_is_recurrence :
  forall memory_before seed_block,
    Genv.find_symbol rng_ge UBS._gRandomSeed16 = Some seed_block ->
    Mem.load Mint16unsigned memory_before seed_block 0 =
      Some (Vint Int.zero) ->
    Mem.valid_access memory_before Mint16unsigned seed_block 0 Writable ->
    exists memory_after,
      eval_funcall function_entry2 rng_ge memory_before
        (Internal UBS.f_random_u16) [] E0 memory_after
        (Vint (Int.repr (random_u16_step_z 0))) /\
      Mem.load Mint16unsigned memory_after seed_block 0 =
        Some (Vint (Int.repr (random_u16_step_z 0))).
Proof.
  intros memory_before seed_block Hsymbol Hload Hwrite.
  rewrite generated_execution_matches_z_recurrence_at_zero.
  exact (generated_random_u16_executes_from_zero_seed
    memory_before seed_block Hsymbol Hload Hwrite).
Qed.

(** Named proposition consumed by the project capstone.  It remains a
    one-step, zero-seed leaf theorem; it does not turn the structural object
    slice into an executable whole-frame program. *)
Definition random_u16_zero_step_clight_claim : Prop :=
  forall memory_before seed_block,
    Genv.find_symbol rng_ge UBS._gRandomSeed16 = Some seed_block ->
    Mem.load Mint16unsigned memory_before seed_block 0 =
      Some (Vint Int.zero) ->
    Mem.valid_access memory_before Mint16unsigned seed_block 0 Writable ->
    exists memory_after,
      eval_funcall function_entry2 rng_ge memory_before
        (Internal UBS.f_random_u16) [] E0 memory_after
        (Vint (Int.repr (random_u16_step_z 0))) /\
      Mem.load Mint16unsigned memory_after seed_block 0 =
        Some (Vint (Int.repr (random_u16_step_z 0))).

Theorem checked_random_u16_zero_step_clight :
  random_u16_zero_step_clight_claim.
Proof.
  unfold random_u16_zero_step_clight_claim.
  exact generated_random_u16_initial_step_is_recurrence.
Qed.
