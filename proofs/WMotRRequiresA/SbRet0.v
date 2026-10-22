(* ====================================================================== *)
(* SbRet0 (GOAL 2): act_soft_bonk returns FALSE without A.                *)
(*                                                                        *)
(* act_soft_bonk (mario_actions_airborne.c) returns TRUE only through     *)
(* check_wall_kick, which needs INPUT_A_PRESSED; the walk's start facts   *)
(* (KbRun's, FfRun.pc0F: m->input & 2178 = 0) prune it.  The same walk as *)
(* KbSb, checked for a constant 0 return on every outcome (r0_ok).        *)
(* FfWorld.fresh needs it: let_go_of_ledge enters SOFT_BONK with a stale *)
(* floorHeight, and only a FALSE return keeps that floor out of the next  *)
(* handler.                                                               *)
(* ====================================================================== *)

From Coq Require Import List ZArith Reals.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Events Globalenvs
  Ctypes Clight ClightBigstep.
From SM64.Generated Require mario_step mario mario_actions_airborne memory surface_collision level_update.
From SM64.Proofs Require Import Interp.SymExec2 Interp.LinkGenv MarioModel.LinkedTwelve
  MarioModel.OsDmaFloor MarioModel.MathGeomGated HeightInvariant HeightMoveCatalog WMotRLevel.
From SM64.Proofs.WMotRRequiresA Require Import FloorHeight FloorExec AirXc AirRun AirMatch
  FpuFloor ExtInert FfClass AirStart FfKeepCheck RetOk FfRun AhwRun KbRun WithGe.
Import ListNotations.

(* the outcome returns the constant 0 *)
Definition r0_ok (c : cpath) : bool :=
  match snd c with Sconst (Vint i) => Int.eq i Int.zero | _ => false end.

Definition kb_walk0 (acn : Z) (f : function) : bool :=
  with_ge ge12 false (fun g =>
    match sx_call g NBF (R0F g) gtabF (kvK acn g) (xcK acn g) jkeys mergeK true 3000 (g0F g)
            (Internal f) argsF with
    | Some cs => forallb r0_ok cs
    | None => false end).

(* the statement: every execution from a memory KbRun's start state
   describes returns 0 (kfinal's premises) *)
Definition kret0 (lp : Clight.program) (acn : Z) (fK : function) : Prop :=
  forall (m0 : mem) (gp : meminj),
  (forall b x, gp b = Some x -> Plt b (Mem.nextblock m0)) ->
  (forall ch b z v, gp b <> None -> Mem.load ch m0 b z = Some v -> val_old gp v) ->
  floor_data (globalenv lp) m0 ->
  forall E t m' vres,
  env_ok (globalenv lp) NBF (R0F (globalenv lp)) gtabF (kvK acn (globalenv lp)) m0 gp E ->
  (forall f, In f (pc0F (globalenv lp)) ->
     fact_holds (globalenv lp) (R0F (globalenv lp)) m0 (ufF (globalenv lp) m0 gp) E f) ->
  eval_funcall function_entry2 (globalenv lp) m0 (Internal fK)
    [Vptr (e_blk E RM) (Ptrofs.add (e_base E RM) Ptrofs.zero)] t m' vres ->
  vres = Vint Int.zero.

Section LP.
Variable lp : Clight.program.
Hypothesis H12 : linked12 lp.
Local Notation G := (globalenv lp).
Hypothesis Hdma : os_dma_floor.
Hypothesis Hsq : sqrtf_spec.
Hypothesis Hsqf : sqrtf_float.
Hypothesis Haudio : audio_inert.      (* LABELED OPEN PREMISE: audio, deferred *)
Hypothesis Hcamera : camera_inert.    (* LABELED OPEN PREMISE: camera, deferred *)

Variable acn : Z.
Variable fK : function.
Hypothesis Hwalk : kb_walk0 acn fK = true.

Theorem kb_kret0 : kret0 lp acn fK.
Proof.
  intros m0 gp GPO MC FD E t m' vres EO PC EV.
  assert (W : exists cs,
    sx_call G NBF (R0F G) gtabF (kvK acn G) (xcK acn G) jkeys mergeK true 3000 (g0F G)
      (Internal fK) argsF = Some cs /\ forall c, In c cs -> r0_ok c = true).
  { pose proof Hwalk as W. unfold kb_walk0, with_ge in W. rewrite (ge12_ok lp H12) in W.
    exact (consume _ r0_ok W). }
  destruct W as (cs & RUN & W).
  assert (MM0 : MMg G NBF (R0F G) gtabF (kvK acn G) m0 (ufF G m0 gp) gp E m0 (g0F G)).
  { apply MMg_init; [exact EO | apply Ple_refl |].
    intros f Hf. split; [exact (pc0F_nlt_k lp f Hf) | exact (PC f Hf)]. }
  assert (ARGS : Forall2 (fun a v => den G m0 E a = Some v /\ sok NBF (g_nx (g0F G)) a) argsF
                   [Vptr (e_blk E RM) (Ptrofs.add (e_base E RM) Ptrofs.zero)]).
  { constructor; [| constructor].
    split; [reflexivity |]. cbn [sok nlt g0F g_nx]. split; [unfold Plt, Pos.lt; reflexivity | exact Logic.I]. }
  destruct (sx_call_sound G NBF (R0F G) gtabF (kvK acn G) (xcK acn G) jkeys mergeK true m0 (ufF G m0 gp) gp
              GPO MC (xcK_sound lp H12 Hdma Hsq Hsqf Haudio Hcamera acn m0 gp GPO MC FD)
              3000 (g0F G) _ argsF cs E m0 _ t m' vres RUN MM0 ARGS EV) as (c & Hin & CMc).
  destruct c as [gs r]. destruct CMc as (E' & X & MM & DR & _).
  pose proof (W _ Hin) as OK. unfold r0_ok in OK. cbn [snd] in OK.
  destruct r as [v | | | | | | | | |]; try discriminate OK.
  destruct v; try discriminate OK. apply Int.same_if_eq in OK. subst i.
  cbn [den] in DR. injection DR as <-. reflexivity.
Qed.
End LP.
