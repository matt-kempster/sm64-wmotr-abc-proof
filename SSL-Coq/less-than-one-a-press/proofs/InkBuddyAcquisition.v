(** A remembered conversation target does not authorize a fresh grab.
    This is the actual generated mario_check_object_grab body, in the
    selected program environment. A live input word lacking GRABBABLE makes
    it return false without a call or any memory write. It does not prove
    that all reachable pickup histories lack the flag or select non-Buddy
    actors; the full pointer/collision/slot-lifetime invariant is separate. *)
From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import us_interaction jp_interaction.
From LessThanOneAPress.Proofs Require Import GameTypes InkActionPassStart
  InkControllerEdge InkBackwardSource InkBackwardExecution InkCopyCaller
  InkBuddyMovement ObjectContactNecessity ObjectContactReadback
  ReadOnlyClightPaths SelectedClightTarget.
Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.
Local Opaque selected_clight_target.
Module IBA := us_interaction.

Definition iba_function version := match version with
| VersionUS => us_interaction.f_mario_check_object_grab
| VersionJP => jp_interaction.f_mario_check_object_grab end.
Definition iba_prefix version :=
  ocn_prefix_items 2 (fn_body (iba_function version)).
Definition iba_return := Sreturn (Some (Etempvar IBA._result tuint)).

Lemma iba_generated_shape : forall version,
  fn_body (iba_function version) =
    ocn_prepend (iba_prefix version) iba_return /\
  forallb ibk_normal (iba_prefix version) = true.
Proof. intros []; split; reflexivity. Qed.

Lemma iba_selected_input_field : forall version,
  ibcc_field_ok (prog_comp_env (selected_clight_target version))
    IBA._MarioState IBA._input 2 = true.
Proof.
  intro version.
  exact (proj2 (proj2 (proj2 (proj2 (proj2 (ice_selected_fields version)))))).
Qed.

(** Construct the skipped path from the actual input load; no skipped-branch
    execution or pointer-preservation premise is assumed. The arbitrary
    remembered usedObj/heldObj cells are never read on this path. *)
Lemma iba_no_grabbable_path : forall version le memory mario flags,
  le ! IBA._m = Some (Vptr mario Ptrofs.zero) ->
  Mem.load Mint16unsigned memory mario 2 = Some (Vint flags) ->
  Int.and flags (Int.repr 2048) = Int.zero ->
  exists final,
    readonly_path (Clight.globalenv (selected_clight_target version))
      empty_env memory le (ocn_prepend (iba_prefix version) Sskip) final /\
    final ! IBA._result = Some (Vint Int.zero).
Proof.
  intros version le memory mario flags Hm Hinput Hclear.
  destruct version;
    (eexists; split;
    [ cbn [iba_prefix iba_function ocn_prefix_items ocn_prepend
        us_interaction.f_mario_check_object_grab
        jp_interaction.f_mario_check_object_grab fn_body];
      eapply ro_seq;
        [apply ro_set; apply eval_Econst_int|];
      eapply ro_seq;
        [eapply ro_seq|apply ro_skip];
      [ apply ro_set;
        eapply ias_field_read with (offset := 2) (chunk := Mint16unsigned);
          [apply iba_selected_input_field|reflexivity|
           rewrite PTree.gso by discriminate; exact Hm|exact Hinput]
      | eapply ro_if with
          (v := Vint (Int.and flags (Int.repr 2048))) (choice := false);
          [eapply eval_Ebinop;
            [apply eval_Etempvar; apply PTree.gss|
             apply eval_Econst_int|reflexivity]|
           rewrite Hclear; reflexivity|apply ro_skip] ]
    | rewrite PTree.gso by discriminate; apply PTree.gss ]).
Qed.

Definition IBANoFreshGrab : Prop :=
  forall version le memory mario flags trace final after out,
  le ! IBA._m = Some (Vptr mario Ptrofs.zero) ->
  Mem.load Mint16unsigned memory mario 2 = Some (Vint flags) ->
  Int.and flags (Int.repr 2048) = Int.zero ->
  ocn_exec (Clight.globalenv (selected_clight_target version))
    empty_env le memory (fn_body (iba_function version))
    trace final after out ->
  trace = E0 /\ after = memory /\
    out = Out_return (Some (Vint Int.zero, tuint)).

Theorem iba_selector_without_grabbable_returns_false : IBANoFreshGrab.
Proof.
  intros version le memory mario flags trace final after out Hm Hinput Hclear Hrun.
  destruct (iba_no_grabbable_path version le memory mario flags Hm Hinput Hclear)
    as (ready & Hpath & Hzero).
  destruct (iba_generated_shape version) as [Hbody Hnormal].
  rewrite Hbody in Hrun.
  destruct (ibk_split_prefix _ _ _ _ _ _ _ _ _ _ Hnormal Hrun)
    as (cut & cutmem & pre & post & Htrace & Hprefix & Hreturn).
  destruct (readonly_path_forces_every_execution _ _ _ _ _ _ Hpath _ _ _ _ Hprefix)
    as (-> & -> & -> & _).
  unfold iba_return in Hreturn. inversion Hreturn; subst.
  match goal with Hv : eval_expr _ _ _ _ (Etempvar IBA._result _) ?v |- _ =>
    assert (v = Vint Int.zero) by
      (eapply ocn_temp_value; [exact Hv|exact Hzero]); subst v end.
  repeat split; reflexivity.
Qed.

(** Together these exact guards close two local shortcuts: a remembered
    dialog pointer without a fresh grab flag cannot pass the selector, and
    the three named pickup actions cannot pass native NPC readiness. This
    conjunction is not a full-history no-acquisition theorem. *)
Definition InkBuddyAcquisitionBoundary : Prop :=
  IBANoFreshGrab /\ IBMReadyPickupExclusion.
Theorem iba_buddy_acquisition_guards_checked : InkBuddyAcquisitionBoundary.
Proof.
  split; [exact iba_selector_without_grabbable_returns_false|
    exact ibm_pickup_actions_cannot_pass_npc_readiness].
Qed.
