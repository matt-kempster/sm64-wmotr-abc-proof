(* ====================================================================== *)
(* RlRun (GOAL 2): act_forward_rollout / act_backward_rollout, walked on  *)
(* the link.                                                              *)
(*                                                                        *)
(* The same walker and contract table as KbRun (KbRun.xcK at the case's   *)
(* constant), its landing helpers merged (KbRun.mergeK).  The walk takes  *)
(* both states:                                                           *)
(*   state 0, the launch: vel[1] := 30, state := 1 (airborne.c:1354-1356, *)
(*     1395-1397), then the air step from those cells (FfClass.rl_ok:     *)
(*     S_roll_launch, then ff_okE at FfClass.ent_roll);                  *)
(*   state <> 0: the air step from the entry cells (ff_ok).              *)
(* After the step: a landing (FREEFALL_LAND_STOP), a wall (forwardVel     *)
(* only), nothing, and state 1 -> 2 (FfClass's state-bump branch).        *)
(* Each outcome also passes FfKeepCheck.fk_ok (the world is kept).        *)
(* rl_kfinal is KbRun.kfinal for the case, which KbRow.kb_row takes.      *)
(* The walks are RlF (forward) and RlB (backward), one per file.          *)
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

Definition FRN : Z := 16779430.   (* ACT_FORWARD_ROLLOUT, 0x010008A6 *)
Definition BRN : Z := 16779437.   (* ACT_BACKWARD_ROLLOUT, 0x010008AD *)

(* both checks of an outcome: the MoveChain class and the kept world *)
Definition rlk_ok (acn : Z) (g : genv) (c : cpath) : bool :=
  rl_ok NBF (R0F g) (kvK acn g) RM RO kM (fst c)
  && fk_ok NBF (R0F g) (kvK acn g) RM RO RLD kS clokF (fst c)
  && ret_ok NBF (R0F g) (kvK acn g) RM c.

Definition rl_walk (acn : Z) (fK : function) : bool :=
  with_ge ge12 false (fun g =>
    match sx_call g NBF (R0F g) gtabF (kvK acn g) (xcK acn g) jkeys mergeK true 3000 (g0F g)
            (Internal fK) argsF with
    | Some cs => forallb (rlk_ok acn g) cs
    | None => false end).

Section LP.
Variable lp : Clight.program.
Hypothesis H12 : linked12 lp.
Local Notation G := (globalenv lp).
Hypothesis Hdma : os_dma_floor.
Hypothesis Hsq : sqrtf_spec.
Hypothesis Hsqf : sqrtf_float.

Variable acn : Z.
Variable fK : function.
Hypothesis Hwalk : rl_walk acn fK = true.

Lemma rlcheck_lp : exists cs,
  sx_call G NBF (R0F G) gtabF (kvK acn G) (xcK acn G) jkeys mergeK true 3000 (g0F G)
    (Internal fK) argsF = Some cs
  /\ forall c, In c cs -> rlk_ok acn G c = true.
Proof.
  pose proof Hwalk as W. unfold rl_walk, with_ge in W. rewrite (ge12_ok lp H12) in W.
  exact (consume _ (rlk_ok acn G) W).
Qed.

(* THE THEOREM: every execution of the case's real handler from a memory
   the start state describes is a MoveChain of Phi's cells *)
Theorem rl_kfinal : kfinal lp acn fK.
Proof.
  intros m0 gp GPO MC FD E t m' vres c0 EO PC EV RC Hb FRO.
  destruct rlcheck_lp as (cs & RUN & W).
  assert (MM0 : MMg G NBF (R0F G) gtabF (kvK acn G) m0 (ufF G m0 gp) gp E m0 (g0F G)).
  { apply MMg_init; [exact EO | apply Ple_refl |].
    intros f Hf. split; [exact (pc0F_nlt_k lp f Hf) | exact (PC f Hf)]. }
  assert (ARGS : Forall2 (fun a v => den G m0 E a = Some v /\ sok NBF (g_nx (g0F G)) a) argsF
                   [Vptr (e_blk E RM) (Ptrofs.add (e_base E RM) Ptrofs.zero)]).
  { constructor; [| constructor].
    split; [reflexivity |]. cbn [sok nlt g0F g_nx]. split; [unfold Plt, Pos.lt; reflexivity | exact Logic.I]. }
  destruct (sx_call_sound G NBF (R0F G) gtabF (kvK acn G) (xcK acn G) jkeys mergeK true m0 (ufF G m0 gp) gp
              GPO MC (xcK_sound lp H12 Hdma Hsq Hsqf acn m0 gp GPO MC FD)
              3000 (g0F G) _ argsF cs E m0 _ t m' vres RUN MM0 ARGS EV) as (c & Hin & CMc).
  destruct c as [gs r]. destruct CMc as (E' & X & MM & DR & _).
  pose proof (W _ Hin) as OK. unfold rlk_ok in OK. cbn [fst] in OK.
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
  split; [rewrite <- BM; exact (ret_sound G NBF (R0F G) gtabF (kvK acn G) m0 (ufF G m0 gp) gp GPO RM E' m' gs MM
                                 ltac:(rewrite BaM; exact HbM) r vres DR RT) |].
  rewrite <- BM in RC |- *.
  exact (rl_sound G NBF (R0F G) gtabF (kvK acn G) m0 (ufF G m0 gp) gp GPO RM RO kM (uf_kM_k_out lp m0 gp)
           E' m' gs MM ltac:(rewrite BaM; exact HbM) HO0 c0 RC Hb FRO OK).
Qed.
End LP.

Lemma rl_kfinal_all : forall lp, linked12 lp -> os_dma_floor -> sqrtf_spec -> sqrtf_float ->
  forall acn fK, rl_walk acn fK = true -> kfinal lp acn fK.
Proof.
  (* explicit: eassumption would unfold the walk onto the link *)
  intros lp H12 Hdma Hsq Hsqf acn fK Hw. exact (rl_kfinal lp H12 Hdma Hsq Hsqf acn fK Hw).
Qed.
