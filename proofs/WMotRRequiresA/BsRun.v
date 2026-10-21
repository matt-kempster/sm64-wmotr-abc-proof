(* ====================================================================== *)
(* BsRun (GOAL 2): act_butt_slide_air, walked on the link.                *)
(*                                                                        *)
(* The same walker and contract table as KbRun (KbRun.xcK at the case's   *)
(* constant), its landing helpers merged (KbRun.mergeK).  The handler     *)
(* first ticks actionTimer (airborne.c:1436; FfClass.bs_ok: S_tick to the *)
(* ticked cells), then the timer gate to FREEFALL, or the air step from   *)
(* the ticked cells (FfClass.ent_bs): a landing (BUTT_SLIDE), the bounce  *)
(* (state 1, vel[1] := -vel[1] / 2), a wall (BACKWARD_AIR_KB), nothing.   *)
(* Each outcome also passes FfKeepCheck.fk_ok (the world is kept).        *)
(* bs_kfinal is KbRun.kfinal for the case at state 0 (the frame world's   *)
(* fresh-floor claim, FfWorld.ffw, covers butt-slide air at state 0 only:  *)
(* the bounce lands to state 1 with floorHeight a quarter step stale).    *)
(* The walk is BsW.                                                       *)
(* ====================================================================== *)

From Coq Require Import List ZArith Reals.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Events Globalenvs
  Ctypes Clight ClightBigstep.
From SM64.Generated Require mario_step mario mario_actions_airborne memory surface_collision level_update.
From SM64.Proofs Require Import Interp.SymExec2 Interp.LinkGenv MarioModel.LinkedTwelve
  MarioModel.OsDmaFloor MarioModel.MathGeomGated HeightInvariant HeightMoveCatalog WMotRLevel.
From SM64.Proofs.WMotRRequiresA Require Import FloorHeight FloorExec AirXc AirRun AirWr WallExec AirMatch AirMove SmaXc AirSum FpuFloor FpWalk ExtInert FfClass AirStart FfKeepCheck FfRun WithGe KbRun.
Import ListNotations.

Module AIR := mario_actions_airborne.

Definition BSN : Z := 50333838.   (* ACT_BUTT_SLIDE_AIR, 0x0300088E *)

(* both checks of an outcome: the MoveChain class and the kept world *)
Definition bsk_ok (g : genv) (c : cpath) : bool :=
  bs_ok NBF (R0F g) (kvK BSN g) RM RO kM (fst c)
  && fk_ok NBF (R0F g) (kvK BSN g) RM RO RLD kS clokF (fst c).

Definition bs_walk (fK : function) : bool :=
  with_ge ge12 false (fun g =>
    match sx_call g NBF (R0F g) gtabF (kvK BSN g) (xcK BSN g) jkeys mergeK true 3000 (g0F g)
            (Internal fK) argsF with
    | Some cs => forallb (bsk_ok g) cs
    | None => false end).

Section LP.
Variable lp : Clight.program.
Hypothesis H12 : linked12 lp.
Local Notation G := (globalenv lp).
Hypothesis Hdma : os_dma_floor.
Hypothesis Hsq : sqrtf_spec.
Hypothesis Hsqf : sqrtf_float.
Hypothesis Haudio : audio_inert.      (* LABELED OPEN PREMISE: audio, deferred *)
Hypothesis Hcamera : camera_inert.    (* LABELED OPEN PREMISE: camera, deferred *)

Variable fK : function.
Hypothesis Hwalk : bs_walk fK = true.

Lemma bscheck_lp : exists cs,
  sx_call G NBF (R0F G) gtabF (kvK BSN G) (xcK BSN G) jkeys mergeK true 3000 (g0F G)
    (Internal fK) argsF = Some cs
  /\ forall c, In c cs -> bsk_ok G c = true.
Proof.
  pose proof Hwalk as W. unfold bs_walk, with_ge in W. rewrite (ge12_ok lp H12) in W.
  exact (consume _ (bsk_ok G) W).
Qed.

(* butt-slide air in fro_st is at state 0 *)
Lemma bs_st0 : forall s, fro_st (Int.repr BSN) s = true -> s = 0%Z.
Proof.
  intros s H. unfold fro_st, bsa0, sk0 in H.
  replace (fro_entry (Int.repr BSN)) with false in H by (vm_compute; reflexivity).
  replace (Int.eq (Int.repr BSN) ACT_BUTT_SLIDE_AIR) with true in H by (vm_compute; reflexivity).
  replace (Int.eq (Int.repr BSN) ACT_SLIDE_KICK) with false in H by (vm_compute; reflexivity).
  cbn [orb andb] in H. rewrite Bool.orb_false_r in H. apply Z.eqb_eq. exact H.
Qed.

Theorem bs_kfinal : kfinal lp BSN fK.
Proof.
  intros m0 gp GPO MC FD E t m' vres c0 EO PC EV RC Hb Hst FRO.
  destruct bscheck_lp as (cs & RUN & W).
  assert (MM0 : MMg G NBF (R0F G) gtabF (kvK BSN G) m0 (ufF G m0 gp) gp E m0 (g0F G)).
  { apply MMg_init; [exact EO | apply Ple_refl |].
    intros f Hf. split; [exact (pc0F_nlt_k lp f Hf) | exact (PC f Hf)]. }
  assert (ARGS : Forall2 (fun a v => den G m0 E a = Some v /\ sok NBF (g_nx (g0F G)) a) argsF
                   [Vptr (e_blk E RM) (Ptrofs.add (e_base E RM) Ptrofs.zero)]).
  { constructor; [| constructor].
    split; [reflexivity |]. cbn [sok nlt g0F g_nx]. split; [unfold Plt, Pos.lt; reflexivity | exact Logic.I]. }
  destruct (sx_call_sound G NBF (R0F G) gtabF (kvK BSN G) (xcK BSN G) jkeys mergeK true m0 (ufF G m0 gp) gp
              GPO MC (xcK_sound lp H12 Hdma Hsq Hsqf Haudio Hcamera BSN m0 gp GPO MC FD)
              3000 (g0F G) _ argsF cs E m0 _ t m' vres RUN MM0 ARGS EV) as (c & Hin & CMc).
  destruct c as [gs r]. destruct CMc as (E' & X & MM & _).
  pose proof (W _ Hin) as OK. unfold bsk_ok in OK. cbn [fst] in OK.
  apply andb_true_iff in OK as [OK FK].
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
  rewrite <- BM in RC |- *.
  exact (bs_sound G NBF (R0F G) gtabF (kvK BSN G) m0 (ufF G m0 gp) gp GPO RM RO kM (uf_kM_k_out lp m0 gp)
           E' m' gs MM ltac:(rewrite BaM; exact HbM) HO0 c0 RC (bs_st0 _ Hst) Hb FRO OK).
Qed.
End LP.

Lemma bs_kfinal_all : forall lp, linked12 lp -> os_dma_floor -> sqrtf_spec -> sqrtf_float ->
  audio_inert -> camera_inert -> forall fK, bs_walk fK = true -> kfinal lp BSN fK.
Proof.
  (* explicit: eassumption would unfold the walk onto the link *)
  intros lp H12 Hdma Hsq Hsqf Ha Hc fK Hw. exact (bs_kfinal lp H12 Hdma Hsq Hsqf Ha Hc fK Hw).
Qed.
