(** Retaining the handstand height through ordinary enemy damage.

    The generated damage selector treats ON_POLE as airborne.  This file
    executes that actual two-read fragment in the selected linked program,
    with unchanged memory, and couples it to the real initializer call's
    position/velocity frame.  It does NOT produce a clean enemy installation,
    execute the rest of the damage caller, or certify collision quarters.
    The accompanying retail experiment explicitly relocates a real Goomba. *)

From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Globalenvs Integers Maps Memory Smallstep Values.
From LessThanOneAPress.Generated Require Import us_interaction jp_interaction.
From LessThanOneAPress.Proofs Require Import ASTFacts GameTypes
  Area2Rank11PoleExitSplit Area2Rank11BodyResolution Area2Rank11LivePoleExit
  Area2Rank11FallingInitializer SelectedClightTarget.

Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.
Module R11DI := us_interaction.

Definition rank11_knockback_body version :=
  rank11_native_body version R11KnockbackSelector.

Fixpoint rank11_right_sequence_tail (count : nat) (body : statement) :=
  match count, body with
  | O, _ => body
  | S rest, Ssequence _ tail => rank11_right_sequence_tail rest tail
  | _, _ => Sskip
  end.

Definition rank11_damage_terrain_fragment version :=
  match rank11_right_sequence_tail 5 (fn_body (rank11_knockback_body version)) with
  | Ssequence terrain _ => terrain
  | _ => Sskip
  end.

Definition rank11_flag_expression (bit : Z) :=
  Ebinop Oshl (Econst_int (Int.repr 1) tint)
    (Econst_int (Int.repr bit) tint) tint.

Definition rank11_damage_water_mask :=
  Ebinop Oor (rank11_flag_expression 13) (rank11_flag_expression 14) tint.

Definition rank11_damage_air_mask :=
  Ebinop Oor
    (Ebinop Oor (rank11_flag_expression 11) (rank11_flag_expression 20) tint)
    (rank11_flag_expression 21) tint.

Definition rank11_damage_terrain_statement :=
  Ssequence
    (Sset R11DI._t'16 (rank11_mario_field_expression R11MU._action tuint))
    (Sifthenelse
      (Ebinop Oand (Etempvar R11DI._t'16 tuint) rank11_damage_water_mask tuint)
      (Sset R11DI._terrainIndex (Ecast (Econst_int (Int.repr 2) tint) tshort))
      (Ssequence
        (Sset R11DI._t'17 (rank11_mario_field_expression R11MU._action tuint))
        (Sifthenelse
          (Ebinop Oand (Etempvar R11DI._t'17 tuint) rank11_damage_air_mask tuint)
          (Sset R11DI._terrainIndex (Ecast (Econst_int (Int.repr 1) tint) tshort))
          Sskip))).

Lemma rank11_damage_terrain_statement_is_generated : forall version,
  rank11_damage_terrain_fragment version = rank11_damage_terrain_statement.
Proof. intros []; reflexivity. Qed.

Inductive Rank11DamagePolePose :=
| R11DamageHolding | R11DamageTransition | R11DamageHandstand.

Definition rank11_damage_pole_action pose := Int.repr (match pose with
  | R11DamageHolding => 135267136
  | R11DamageTransition => 1049412
  | R11DamageHandstand => 1049413
  end).

Lemma rank11_damage_pole_masks : forall pose,
  Int.and (rank11_damage_pole_action pose) (Int.repr 24576) = Int.zero /\
  Int.and (rank11_damage_pole_action pose) (Int.repr 3147776) = Int.repr 1048576.
Proof. intros []; vm_compute; split; reflexivity. Qed.

Definition rank11_damage_terrain_locals locals action :=
  PTree.set R11DI._terrainIndex (Vint (Int.repr 1))
    (PTree.set R11DI._t'17 (Vint action)
      (PTree.set R11DI._t'16 (Vint action) locals)).

Section SELECTED_EXECUTION.
Variable version : GameVersion.
Let ge := Clight.globalenv (selected_clight_target version).

Lemma rank11_damage_water_mask_evaluates : forall environment locals memory,
  eval_expr ge environment locals memory rank11_damage_water_mask
    (Vint (Int.repr 24576)).
Proof.
  intros. unfold rank11_damage_water_mask, rank11_flag_expression.
  eapply eval_Ebinop.
  - eapply eval_Ebinop; [constructor | constructor | reflexivity].
  - eapply eval_Ebinop; [constructor | constructor | reflexivity].
  - reflexivity.
Qed.

Lemma rank11_damage_air_mask_evaluates : forall environment locals memory,
  eval_expr ge environment locals memory rank11_damage_air_mask
    (Vint (Int.repr 3147776)).
Proof.
  intros. unfold rank11_damage_air_mask, rank11_flag_expression.
  eapply eval_Ebinop.
  - eapply eval_Ebinop.
    + eapply eval_Ebinop; [constructor | constructor | reflexivity].
    + eapply eval_Ebinop; [constructor | constructor | reflexivity].
    + reflexivity.
  - eapply eval_Ebinop; [constructor | constructor | reflexivity].
  - reflexivity.
Qed.

Theorem rank11_pole_damage_executes_air_terrain_selection :
  forall pose environment locals memory mario,
    locals ! R11MU._m = Some (Vptr mario Ptrofs.zero) ->
    Mem.load Mint32 memory mario 12 = Some (Vint (rank11_damage_pole_action pose)) ->
    ClightBigstep.Clight2.exec_stmt ge environment locals memory
      (rank11_damage_terrain_fragment version) E0
      (rank11_damage_terrain_locals locals (rank11_damage_pole_action pose))
      memory Out_normal.
Proof.
  intros pose environment locals memory mario Hm Haction.
  destruct (rank11_damage_pole_masks pose) as [Hwater Hair].
  rewrite rank11_damage_terrain_statement_is_generated.
  unfold rank11_damage_terrain_statement, rank11_damage_terrain_locals.
  eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
  - eapply exec_Sset with (v := Vint (rank11_damage_pole_action pose)).
    eapply rank11_mario_field_read; eauto; try reflexivity; cbn; auto.
  - eapply exec_Sifthenelse with (v1 := Vint Int.zero) (b := false).
    + eapply eval_Ebinop.
      * apply eval_Etempvar. apply PTree.gss.
      * apply rank11_damage_water_mask_evaluates.
      * change (Some (Vint (Int.and (rank11_damage_pole_action pose)
          (Int.repr 24576))) = Some (Vint Int.zero)).
        rewrite Hwater. reflexivity.
    + reflexivity.
    + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * eapply exec_Sset with (v := Vint (rank11_damage_pole_action pose)).
        eapply rank11_mario_field_read; eauto; try reflexivity; try (cbn; auto).
        rewrite PTree.gso by discriminate. exact Hm.
      * eapply exec_Sifthenelse with (v1 := Vint (Int.repr 1048576)) (b := true).
        -- eapply eval_Ebinop.
           ++ apply eval_Etempvar. apply PTree.gss.
           ++ apply rank11_damage_air_mask_evaluates.
           ++ change (Some (Vint (Int.and (rank11_damage_pole_action pose)
                (Int.repr 3147776))) = Some (Vint (Int.repr 1048576))).
              rewrite Hair. reflexivity.
        -- reflexivity.
        -- eapply exec_Sset. eapply eval_Ecast; [constructor | reflexivity].
Qed.

Theorem rank11_pole_damage_selection_is_connected :
  forall pose environment locals memory mario continuation,
    locals ! R11MU._m = Some (Vptr mario Ptrofs.zero) ->
    Mem.load Mint32 memory mario 12 = Some (Vint (rank11_damage_pole_action pose)) ->
    @Smallstep.star _ _ Clight.step2 ge
      (State (rank11_knockback_body version) (rank11_damage_terrain_fragment version)
        continuation environment locals memory) E0
      (State (rank11_knockback_body version) Sskip continuation environment
        (rank11_damage_terrain_locals locals (rank11_damage_pole_action pose)) memory).
Proof.
  intros pose environment locals memory mario continuation Hm Haction.
  pose proof (rank11_pole_damage_executes_air_terrain_selection pose
    environment locals memory mario Hm Haction) as Hexecute.
  destruct (ClightBigstep.exec_stmt_steps Clight.function_entry2
    (selected_clight_target version) _ _ _ _ _ _ _ _ Hexecute
    (rank11_knockback_body version) continuation) as (last & Hsteps & Houtcome).
  inversion Houtcome; subst last. exact Hsteps.
Qed.
End SELECTED_EXECUTION.

Definition Rank11PoleDamageSelectionBoundary : Prop :=
  forall version pose environment locals memory mario continuation,
    locals ! R11MU._m = Some (Vptr mario Ptrofs.zero) ->
    Mem.load Mint32 memory mario 12 = Some (Vint (rank11_damage_pole_action pose)) ->
    exists function_block,
      Genv.find_symbol (Clight.globalenv (selected_clight_target version))
        R11DI._determine_knockback_action = Some function_block /\
      Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version))
        function_block = Some (Internal (rank11_knockback_body version)) /\
      @Smallstep.star _ _ Clight.step2
        (Clight.globalenv (selected_clight_target version))
        (State (rank11_knockback_body version) (rank11_damage_terrain_fragment version)
          continuation environment locals memory) E0
        (State (rank11_knockback_body version) Sskip continuation environment
          (rank11_damage_terrain_locals locals (rank11_damage_pole_action pose)) memory).

Theorem rank11_selected_pole_damage_selection_holds : Rank11PoleDamageSelectionBoundary.
Proof.
  intros version pose environment locals memory mario continuation Hm Haction.
  destruct (rank11_selected_native_body_resolves version R11KnockbackSelector)
    as (function_block & Hsymbol & Hbody).
  exists function_block. split; [exact Hsymbol |]. split; [exact Hbody |].
  eapply rank11_pole_damage_selection_is_connected; eauto.
Qed.

(** These are initializer-byte receipts, not an assumption that a reached
    table read sees its initializer.  The separate private-table invariant
    supplies persistence.  In particular neither normal air entry is a long
    jump.  Proving strength/direction and reaching the read remains separate. *)
Definition rank11_normal_air_damage_initializers version : Prop :=
  let forward := match version with
    | VersionUS => us_interaction.v_sForwardKnockbackActions
    | VersionJP => jp_interaction.v_sForwardKnockbackActions end in
  let backward := match version with
    | VersionUS => us_interaction.v_sBackwardKnockbackActions
    | VersionJP => jp_interaction.v_sBackwardKnockbackActions end in
  firstn 2 (skipn 3 (gvar_init forward)) =
    [Init_int32 (rank11_falling_action R11ForwardDamage);
     Init_int32 (rank11_falling_action R11ForwardDamage)] /\
  firstn 2 (skipn 3 (gvar_init backward)) =
    [Init_int32 (rank11_falling_action R11BackwardDamage);
     Init_int32 (rank11_falling_action R11BackwardDamage)].

Theorem rank11_normal_air_damage_initializers_checked : forall version,
  rank11_normal_air_damage_initializers version.
Proof. intros []; vm_compute; split; reflexivity. Qed.

Definition Rank11HandstandDamageBoundary : Prop :=
  (forall version, rank11_damage_terrain_fragment version =
     rank11_damage_terrain_statement /\ rank11_normal_air_damage_initializers version) /\
  Rank11PoleDamageSelectionBoundary /\ Rank11FallingCallClosure.

Theorem rank11_handstand_damage_boundary_holds : Rank11HandstandDamageBoundary.
Proof.
  split.
  - intro version. split; [apply rank11_damage_terrain_statement_is_generated |
      apply rank11_normal_air_damage_initializers_checked].
  - split; [exact rank11_selected_pole_damage_selection_holds |
      exact rank11_selected_falling_call_safely_returns].
Qed.
