(* ====================================================================== *)
(* GpRun (GOAL 2): act_ground_pound, walked on the link.                  *)
(*                                                                        *)
(* The same walker and contract table as KbRun (KbRun.xcK at the case's   *)
(* constant ACT_GROUND_POUND), with should_get_stuck_in_ground and         *)
(* check_fall_damage merged too.  The walk takes both states:             *)
(*   state 0, the windup: pos[1] rises 20 - 2*timer while timer < 10      *)
(*     (FfClass.gpw_ok: S_gp_windup, or S_gp_hold when it does not rise); *)
(*   state <> 0, the fall: perform_air_step, then a landing (BUTT_STUCK /  *)
(*     GROUND_POUND_LAND / the hard knockback), a wall (BACKWARD_AIR_KB,   *)
(*     vel[1] ends <= 0), or nothing (FfClass.ff_ok, its step's entry a    *)
(*     ground-pound fall, FfClass.gp_ok).                                 *)
(* Each outcome also passes FfKeepCheck.fk_ok (the world is kept).        *)
(* gp_kfinal is KbRun.kfinal for the case, which KbRow.kb_row takes.      *)
(* ====================================================================== *)

From Coq Require Import List ZArith Reals.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Events Globalenvs
  Ctypes Clight ClightBigstep.
From SM64.Generated Require mario_step mario mario_actions_airborne memory surface_collision level_update.
From SM64.Proofs Require Import Interp.SymExec2 Interp.LinkGenv MarioModel.LinkedTwelve
  MarioModel.OsDmaFloor MarioModel.MathGeomGated HeightInvariant HeightMoveCatalog WMotRLevel.
From SM64.Proofs.WMotRRequiresA Require Import FloorHeight FloorExec AirXc AirRun AirWr WallExec AirMatch AirMove SmaXc AirSum FpuFloor FpWalk ExtInert FfClass AirStart FfKeepCheck RetOk FfRun WithGe KbRun.
Import ListNotations.

Module AIR := mario_actions_airborne.

Definition GPN : Z := 8390825.   (* ACT_GROUND_POUND, 0x008008A9 *)

(* the landing's two helpers are merged as well *)
Definition mergeG (id : ident) : bool :=
  mergeF id || Pos.eqb id AIR._should_get_stuck_in_ground || Pos.eqb id AIR._check_fall_damage.

(* both checks of an outcome: the MoveChain class and the kept world *)
Definition gpk_ok (g : genv) (c : cpath) : bool :=
  gp_ok NBF (R0F g) (kvK GPN g) RM RO kM (fst c)
  && fk_ok NBF (R0F g) (kvK GPN g) RM RO RLD kS clokF (fst c)
  && ret_ok NBF (R0F g) (kvK GPN g) RM c.

Definition gp_walk : bool :=
  with_ge ge12 false (fun g =>
    match sx_call g NBF (R0F g) gtabF (kvK GPN g) (xcK GPN g) jkeys mergeG true 3000 (g0F g)
            (Internal AIR.f_act_ground_pound) argsF with
    | Some cs => forallb (gpk_ok g) cs
    | None => false end).

(* THE WALK, computed once on the real link *)
Lemma gpcheck12 : gp_walk = true.
Proof. vm_cast_no_check (eq_refl true). Qed.

Section LP.
Variable lp : Clight.program.
Hypothesis H12 : linked12 lp.
Local Notation G := (globalenv lp).
Hypothesis Hdma : os_dma_floor.
Hypothesis Hsq : sqrtf_spec.
Hypothesis Hsqf : sqrtf_float.
Hypothesis Haudio : audio_inert.      (* LABELED OPEN PREMISE: audio, deferred *)
Hypothesis Hcamera : camera_inert.    (* LABELED OPEN PREMISE: camera, deferred *)

Lemma gpcheck_lp : exists cs,
  sx_call G NBF (R0F G) gtabF (kvK GPN G) (xcK GPN G) jkeys mergeG true 3000 (g0F G)
    (Internal AIR.f_act_ground_pound) argsF = Some cs
  /\ forall c, In c cs -> gpk_ok G c = true.
Proof.
  pose proof gpcheck12 as W. unfold gp_walk, with_ge in W. rewrite (ge12_ok lp H12) in W.
  exact (consume _ (gpk_ok G) W).
Qed.

(* THE THEOREM: every execution of the real act_ground_pound from a memory
   the start state describes is a MoveChain of Phi's cells *)
Theorem gp_kfinal : kfinal lp GPN AIR.f_act_ground_pound.
Proof.
  intros m0 gp GPO MC FD E t m' vres c0 EO PC EV RC Hb FRO.
  destruct gpcheck_lp as (cs & RUN & W).
  assert (MM0 : MMg G NBF (R0F G) gtabF (kvK GPN G) m0 (ufF G m0 gp) gp E m0 (g0F G)).
  { apply MMg_init; [exact EO | apply Ple_refl |].
    intros f Hf. split; [exact (pc0F_nlt_k lp f Hf) | exact (PC f Hf)]. }
  assert (ARGS : Forall2 (fun a v => den G m0 E a = Some v /\ sok NBF (g_nx (g0F G)) a) argsF
                   [Vptr (e_blk E RM) (Ptrofs.add (e_base E RM) Ptrofs.zero)]).
  { constructor; [| constructor].
    split; [reflexivity |]. cbn [sok nlt g0F g_nx]. split; [unfold Plt, Pos.lt; reflexivity | exact Logic.I]. }
  destruct (sx_call_sound G NBF (R0F G) gtabF (kvK GPN G) (xcK GPN G) jkeys mergeG true m0 (ufF G m0 gp) gp
              GPO MC (xcK_sound lp H12 Hdma Hsq Hsqf Haudio Hcamera GPN m0 gp GPO MC FD)
              3000 (g0F G) _ argsF cs E m0 _ t m' vres RUN MM0 ARGS EV) as (c & Hin & CMc).
  destruct c as [gs r]. destruct CMc as (E' & X & MM & DR & _).
  pose proof (W _ Hin) as OK. unfold gpk_ok in OK. cbn [fst] in OK.
  apply andb_true_iff in OK as [OK RT]. apply andb_true_iff in OK as [OK FK].
  exists E', gs. split; [exact X | split; [exact MM | split; [exact FK |]]].
  destruct EO as (_ & _ & _ & GT & KV & _).
  destruct (GT level_update._gMarioStates RM eq_refl) as (_ & HbM & _).
  destruct (X RM ltac:(vm_compute; reflexivity)) as (BM & BaM & _).
  destruct (X RO ltac:(vm_compute; reflexivity)) as (BO & BaO & _).
  assert (HO0 : Mem.load Mint32 m0 (e_blk E' RM) oMO = Some (Vptr (e_blk E' RO) (e_base E' RO))).
  { destruct (KV RM (AirRun.fo G mario._MarioState mario._marioObj) Mint32 (Sptr RO Ptrofs.zero))
      as (_ & _ & L); [cbn [kvK]; left; reflexivity |].
    rewrite BM, BaO, BO. rewrite (proj1 (layout_lp lp H12)) in L.
    unfold addr in L. rewrite HbM, Ptrofs.unsigned_zero, Z.add_0_l in L.
    cbn [SymExec2.den] in L. rewrite Ptrofs.add_zero in L. exact L. }
  split; [rewrite <- BM; exact (ret_sound G NBF (R0F G) gtabF (kvK GPN G) m0 (ufF G m0 gp) gp GPO RM E' m' gs MM
                                 ltac:(rewrite BaM; exact HbM) r vres DR RT) |].
  rewrite <- BM in RC |- *.
  exact (gp_sound G NBF (R0F G) gtabF (kvK GPN G) m0 (ufF G m0 gp) gp GPO RM RO kM (uf_kM_k_out lp m0 gp)
           E' m' gs MM ltac:(rewrite BaM; exact HbM) HO0 c0 RC Hb FRO OK).
Qed.
End LP.
