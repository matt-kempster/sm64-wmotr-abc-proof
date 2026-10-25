(* ====================================================================== *)
(* AhwRun (GOAL 2): the real act_air_hit_wall, walked on the link.        *)
(*                                                                        *)
(* The same walker and contract table as FfRun (act_freefall), with the   *)
(* action cell known to be ACT_AIR_HIT_WALL.  The walk's 19 outcomes:      *)
(* the A-pressed wall kick is pruned by the input fact (A clear); the rest *)
(* stay in AIR_HIT_WALL (timer + 1) or switch to BACKWARD_AIR_KB /         *)
(* SOFT_BONK with vel[1] kept or zeroed when it was > 0.  Each passes      *)
(* FfClass.ahw_ok (one S_switch, FfClass.ahw_sound) and FfKeepCheck.fk_ok  *)
(* (the frame world is kept).                                              *)
(* ====================================================================== *)

From Coq Require Import List ZArith Reals.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Events Globalenvs
  Ctypes Clight ClightBigstep.
From SM64.Generated Require mario_step mario mario_actions_airborne memory surface_collision level_update.
From SM64.Proofs Require Import Interp.SymExec2 Interp.LinkGenv MarioModel.LinkedTwelve
  MarioModel.OsDmaFloor MarioModel.MathGeomGated HeightInvariant HeightMoveCatalog WMotRLevel.
From SM64.Proofs.WMotRRequiresA Require Import FloorHeight FloorExec AirXc AirRun AirWr WallExec AirMatch AirMove SmaXc AirSum FpuFloor FpWalk ExtInert SndXc FfClass AirStart FfKeepCheck RetOk FfRun.
Import ListNotations.

Module AIR := mario_actions_airborne.

Section CFG.
Variable g : genv.

(* known cells: marioObj, action = ACT_AIR_HIT_WALL, heldObj = riddenObj = NULL,
   animList = &gMarioAnimsBuf *)
Definition kvH : list (positive * Z * memory_chunk * sval) :=
  [ (RM, AirRun.fo g mario._MarioState mario._marioObj, Mint32, Sptr RO Ptrofs.zero);
    (RM, 12, Mint32, Sconst (Vint (Int.repr 2215)));
    (RM, AirRun.fo g mario._MarioState mario._heldObj, Mint32, Sconst (Vint Int.zero));
    (RM, AirRun.fo g mario._MarioState mario._riddenObj, Mint32, Sconst (Vint Int.zero));
    (RM, AirRun.fo g mario._MarioState mario._animList, Mint32, Sptr RLD Ptrofs.zero) ].
Definition xcH (id : ident) : option xcontract :=
  match xcI g id with
  | Some k => Some k
  | None =>
    if Pos.eqb id mario._set_mario_animation then Some (c_sma NBF (R0F g) gtabF kvH RLD RBUF RIOM RMQ RRM kB) else
    if Pos.eqb id AIR._update_air_without_turn then Some (c_wr NBF (R0F g) (uawt_ws g)) else
    if Pos.eqb id AIR._play_sound then Some (c_snd (R0F g) gtabF ps_regs) else
    if Pos.eqb id mario_step._perform_air_step then
      Some (c_pas g NBF (R0F g) gtabF kvH (xcI g) (jkI g) mergef 400 (Internal mario_step.f_perform_air_step) RM RO kH kM)
    else if existsb (Pos.eqb id) ext_ids then Some xc_fresh else None
  end.
End CFG.


(* both checks of an outcome: the MoveChain class and the kept world *)
Definition ahk_ok (g : genv) (c : cpath) : bool :=
  ahw_ok NBF (R0F g) (kvH g) RM RO kM (fst c) && fk_ok NBF (R0F g) (kvH g) RM RO RLD kS clokF (fst c)
  && ret_ok NBF (R0F g) (kvH g) RM c.

(* THE WALK of act_air_hit_wall, computed once on the real link *)
Lemma ahwcheck12 : match ge12 with
  | Some g => match sx_call g NBF (R0F g) gtabF (kvH g) (xcH g) jkeys mergeF true 3000 (g0F g)
                      (Internal AIR.f_act_air_hit_wall) argsF with
              | Some cs => forallb (ahk_ok g) cs
              | None => false end
  | None => false end = true.
Proof. vm_cast_no_check (eq_refl true). Qed.  (* computed once, by the kernel *)

Lemma dm_pas_h : (prog_defmap mario_step.prog) ! mario_step._perform_air_step
  = Some (Gfun (Internal mario_step.f_perform_air_step)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_sma_h : (prog_defmap mario.prog) ! mario._set_mario_animation
  = Some (Gfun (Internal mario.f_set_mario_animation)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_uawt_h : (prog_defmap AIR.prog) ! AIR._update_air_without_turn
  = Some (Gfun (Internal AIR.f_update_air_without_turn)).
Proof. vm_compute. reflexivity. Qed.
Lemma sqrtf_named_air_h : ext_named ((prog_defmap AIR.prog) ! AIR._sqrtf) "sqrtf" = true.
Proof. vm_compute. reflexivity. Qed.

Lemma sfun_res_h : forall ge id f fd, resolves_to ge id f -> sfun_lookup ge id = Some fd -> fd = Internal f.
Proof.
  intros ge id f fd R H. unfold sfun_lookup in H.
  destruct (Genv.find_symbol (genv_genv ge) id) as [b|] eqn:Hs; [| discriminate H].
  exact (R b fd Hs H).
Qed.

Section LP.
Variable lp : Clight.program.
Hypothesis H12 : linked12 lp.
Local Notation G := (globalenv lp).
Hypothesis Hdma : os_dma_floor.
Hypothesis Hsq : sqrtf_spec.
Hypothesis Hsqf : sqrtf_float.

Variables (m0 : mem) (gp : meminj).
Hypothesis GPO : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0).
Hypothesis MC : forall ch b z v, gp b <> None -> Mem.load ch m0 b z = Some v -> val_old gp v.
Hypothesis FD : floor_data G m0.

Local Notation uf := (ufF G m0 gp).

Lemma uf_kW_h : forall vs, uf kW vs -> Wff G m0 gp (szs G mario._Surface) vs.
Proof. intros vs H. exact H. Qed.
Lemma uf_kH_in_h : forall h yv, HPi (Hit_at G m0) (ycast yv) h -> Hit_at G m0 h ->
  uf kH [Some (Vsingle h); Some yv].
Proof. intros h yv A B. cbn. split; assumption. Qed.
Lemma uf_kH_out_h : forall vs, uf kH vs ->
  exists h yv, vs = [Some (Vsingle h); Some yv] /\ HPi (Hit_at G m0) (ycast yv) h /\ Hit_at G m0 h.
Proof.
  intros vs H. cbn in H.
  destruct vs as [| [[| | | | h |]|] [| [yv|] [| o3 r]]]; try contradiction.
  exists h, yv. split; [reflexivity | exact H].
Qed.
Lemma uf_kS_h : forall vs, surf_on G m0 vs -> uf kS vs.
Proof. intros vs H. exact H. Qed.
Lemma uf_kM_h : forall vs, MV vs -> uf kM vs.
Proof. intros vs H. exact H. Qed.
Lemma uf_kM_h_out : forall vs, uf kM vs -> MV vs.
Proof. intros vs H. exact H. Qed.
Lemma uf_kB_h : forall vs, uf kB vs ->
  exists b o o2, vs = [Some (Vptr b o); Some (Vptr b o2)] /\ Ptrofs.unsigned o + 24 <= Ptrofs.modulus.
Proof. intros vs H. exact H. Qed.

Let XSI := air_xc_sound_link lp (linked12_LO_surf lp H12) (linked12_LO_math lp H12)
             (linked12_LO_mario lp H12) NBF (R0F G) gtabF (kvH G) m0 uf gp
             RFI RMISS RCALLS kW kH kS (szs G mario._Surface) GPO eq_refl eq_refl eq_refl uf_kW_h uf_kH_in_h uf_kS_h.

(* THE TABLE IS SOUND on the real link *)
Theorem xcH_sound : forall id k args g cps fd E m vargs t m' vres,
  xcH G id = Some k -> k args g = Some cps -> sfun_lookup G id = Some fd ->
  MMg G NBF (R0F G) gtabF (kvH G) m0 uf gp E m g ->
  Forall2 (fun a v => den G m0 E a = Some v /\ sok NBF (g_nx g) a) args vargs ->
  eval_funcall function_entry2 G m fd vargs t m' vres ->
  exists c, In c cps /\ CM G NBF (R0F G) gtabF (kvH G) m0 uf gp E (g_nx g) (g_loc g) m' vres c.
Proof.
  intros id k args g cps fd E m vargs t m' vres Hx Hk Hl MM HA EV.
  unfold xcH in Hx. destruct (xcI G id) as [k0|] eqn:Xi.
  - injection Hx as <-. exact (XSI id k0 args g cps fd E m vargs t m' vres Xi Hk Hl MM HA EV).
  - destruct (Pos.eqb_spec id mario._set_mario_animation) as [-> | N1].
    + injection Hx as <-.
      rewrite (sfun_res_h _ _ _ _ (res_link lp _ _ _ (linked12_LO_mario lp H12) dm_sma_h) Hl) in EV.
      exact (c_sma_sound lp H12 Hdma NBF (R0F G) gtabF (kvH G) m0 uf gp GPO MC RLD RBUF RIOM RMQ RRM kB
               uf_kB_h args g cps E m vargs t m' vres Hk MM HA EV).
    + destruct (Pos.eqb_spec id AIR._update_air_without_turn) as [-> | N2].
      * injection Hx as <-.
        rewrite (sfun_res_h _ _ _ _ (res_link lp _ _ _ (linked12_LO_air lp H12) dm_uawt_h) Hl) in EV.
        exact (c_uawt_sound lp H12 Hsq NBF (R0F G) gtabF (kvH G) m0 uf gp GPO
                 args g cps E m vargs t m' vres Hk MM HA EV).
      * destruct (Pos.eqb_spec id AIR._play_sound) as [-> | Nps].
        { injection Hx as <-.
          rewrite (sfun_res _ _ _ _ (res_link lp _ _ _ (linked12_LO_audio_external lp H12) ps_defmap) Hl) in EV.
          exact (c_ps_sound lp NBF (R0F G) gtabF (kvH G) m0 uf gp GPO RSR RSRC
                   args g cps E m vargs t m' vres Hk MM EV). }
        destruct (Pos.eqb_spec id mario_step._perform_air_step) as [-> | N3].
        -- injection Hx as <-.
           rewrite (sfun_res_h _ _ _ _ (res_link lp _ _ _ (linked12_LO_stp lp H12) dm_pas_h) Hl) in EV.
           exact (c_pas_sound G NBF (R0F G) gtabF (kvH G) (xcI G) (jkI G) mergef 400
                    (Internal mario_step.f_perform_air_step) RM RO kH kM m0 uf gp GPO MC XSI
                    level_update._gMarioStates eq_refl eq_refl uf_kH_out_h uf_kM_h FD
                    args g cps E m vargs t m' vres Hk MM HA EV).
        -- destruct (existsb (Pos.eqb id) (ext_ids)) eqn:Ex; [| discriminate Hx].
           injection Hx as <-.
           apply existsb_exists in Ex as (x & Ix & Ex). apply Pos.eqb_eq in Ex. subst x.
           destruct Ix as [<- | []].
           exact (ext_fresh_sound lp H12 _ _ sqrtf_named_air_h sqrtf_ni (sqrtf_inert Hsq Hsqf)
                       NBF (R0F G) gtabF (kvH G) m0 uf gp GPO args g cps fd E m vargs t m' vres Hk Hl MM EV).
Qed.

Lemma ahwcheck_lp : exists cs,
  sx_call G NBF (R0F G) gtabF (kvH G) (xcH G) jkeys mergeF true 3000 (g0F G)
    (Internal AIR.f_act_air_hit_wall) argsF = Some cs
  /\ forall c, In c cs -> ahk_ok G c = true.
Proof.
  pose proof ahwcheck12 as W. rewrite (ge12_ok lp H12) in W.
  exact (consume _ (ahk_ok G) W).
Qed.

Lemma pc0F_nlt_h : forall f, In f (pc0F G) -> fact_nlt NBF f.
Proof.
  intros f H. cbn [pc0F app ffacts In] in H.
  repeat (destruct H as [<- | H]; [cbn; repeat split; try (unfold Plt; cbn; lia); repeat constructor; unfold Plt; cbn; lia |]).
  contradiction.
Qed.

(* THE THEOREM: every execution of the real act_air_hit_wall from a memory
   the start state describes is a MoveChain of Phi's cells *)
Theorem ahw_final : forall E t m' vres c0,
  env_ok G NBF (R0F G) gtabF (kvH G) m0 gp E ->
  (forall f, In f (pc0F G) -> fact_holds G (R0F G) m0 uf E f) ->
  eval_funcall function_entry2 G m0 (Internal AIR.f_act_air_hit_wall)
    [Vptr (e_blk E RM) (Ptrofs.add (e_base E RM) Ptrofs.zero)] t m' vres ->
  read_cells (e_blk E RM) m0 c0 -> budget_ok c0 ->
  FloorRefreshOK wmotr_floor (R2 (c_posy c0)) (R2 (c_floorh c0)) ->
  exists E' gs, Ext E E' NBF /\ MMg G NBF (R0F G) gtabF (kvH G) m0 uf gp E' m' gs
    /\ fk_ok NBF (R0F G) (kvH G) RM RO RLD kS clokF gs = true
    /\ RET (e_blk E RM) m0 m' vres
    /\ exists c2, read_cells (e_blk E RM) m' c2 /\ MoveChain wmotr_floor wmotr_pole wmotr_cannon c0 c2
       /\ fro_ff c2.
Proof.
  intros E t m' vres c0 EO PC EV RC Hb FRO.
  destruct ahwcheck_lp as (cs & RUN & W).
  assert (MM0 : MMg G NBF (R0F G) gtabF (kvH G) m0 uf gp E m0 (g0F G)).
  { apply MMg_init; [exact EO | apply Ple_refl |].
    intros f Hf. split; [exact (pc0F_nlt_h f Hf) | exact (PC f Hf)]. }
  assert (ARGS : Forall2 (fun a v => den G m0 E a = Some v /\ sok NBF (g_nx (g0F G)) a) argsF
                   [Vptr (e_blk E RM) (Ptrofs.add (e_base E RM) Ptrofs.zero)]).
  { constructor; [| constructor].
    split; [reflexivity |]. cbn [sok nlt g0F g_nx]. split; [unfold Plt, Pos.lt; reflexivity | exact Logic.I]. }
  destruct (sx_call_sound G NBF (R0F G) gtabF (kvH G) (xcH G) jkeys mergeF true m0 uf gp
              GPO MC xcH_sound 3000 (g0F G) _ argsF cs E m0 _ t m' vres RUN MM0 ARGS EV) as (c & Hin & CMc).
  destruct c as [gs r]. destruct CMc as (E' & X & MM & DR & _).
  pose proof (W _ Hin) as OK. unfold ahk_ok in OK. cbn [fst] in OK.
  apply andb_true_iff in OK as [OK RT]. apply andb_true_iff in OK as [OK FK].
  exists E', gs. split; [exact X | split; [exact MM | split; [exact FK |]]].
  destruct EO as (_ & _ & _ & GT & KV & _).
  destruct (GT level_update._gMarioStates RM eq_refl) as (_ & HbM & _).
  destruct (X RM ltac:(vm_compute; reflexivity)) as (BM & BaM & _).
  destruct (X RO ltac:(vm_compute; reflexivity)) as (BO & BaO & _).
  assert (HO0 : Mem.load Mint32 m0 (e_blk E' RM) oMO = Some (Vptr (e_blk E' RO) (e_base E' RO))).
  { destruct (KV RM (AirRun.fo G mario._MarioState mario._marioObj) Mint32 (Sptr RO Ptrofs.zero))
      as (_ & _ & L); [cbn [kvH]; left; reflexivity |].
    rewrite BM, BaO, BO. rewrite (proj1 (layout_lp lp H12)) in L.
    unfold addr in L. rewrite HbM, Ptrofs.unsigned_zero, Z.add_0_l in L.
    cbn [SymExec2.den] in L. rewrite Ptrofs.add_zero in L. exact L. }
  assert (Hact : c_action c0 = Int.repr 2215).
  { destruct (KV RM 12%Z Mint32 (Sconst (Vint (Int.repr 2215)))) as (_ & _ & L);
      [cbn [kvH]; right; left; reflexivity |].
    unfold addr in L. rewrite HbM, Ptrofs.unsigned_zero, Z.add_0_l in L.
    destruct RC as (HA & _). change OFS_ACTION with 12%Z in HA. rewrite HA in L. cbn [den] in L.
    injection L as ->. reflexivity. }
  assert (M0 : mode_of c0 = M_Air) by (unfold mode_of; rewrite Hact; vm_compute; reflexivity).
  split; [rewrite <- BM; exact (ret_sound G NBF (R0F G) gtabF (kvH G) m0 uf gp GPO RM E' m' gs MM
                                 ltac:(rewrite BaM; exact HbM) r vres DR RT) |].
  rewrite <- BM in RC |- *.
  exact (ahw_sound G NBF (R0F G) gtabF (kvH G) m0 uf gp GPO RM RO kM E' m' gs MM
           ltac:(rewrite BaM; exact HbM) HO0 c0 RC Hb FRO M0 OK).
Qed.
End LP.
