(* ====================================================================== *)
(* PoleRun (GOAL 2): the pole grabs of the automatic dispatcher, walked    *)
(* on the link.                                                            *)
(*                                                                        *)
(* act_grab_pole_slow / act_grab_pole_fast (mario_actions_automatic.c)     *)
(* run set_pole_position, which reads usedObj (the pole) and Mario's       *)
(* oMarioPolePos, calls vec3f_find_ceil / find_floor, and may leave the    *)
(* pole (ACT_IDLE, ACT_FREEFALL, ACT_SOFT_BONK).  The walker's config is   *)
(* KbRun's plus:                                                           *)
(*   - region RU: the pole object usedObj (known cells: its oPosY,         *)
(*     hitboxDownOffset, hitboxHeight -- WMotR's one low pole);            *)
(*   - globals bhvTree, bhvGiantPole (compared against usedObj->behavior)  *)
(*     and gCurrLevelNum (a world cell);                                   *)
(*   - find_floor / find_ceil with the height facts kL / kC (PoleXc);      *)
(*   - the start fact kP: oMarioPolePos finite >= -1000 (pole_pos_ok);    *)
(*   - is_anim_at_end (memory unchanged, an int); play_sound and         *)
(*     set_sound_moving_speed (SndXc: clobbers proved from the real      *)
(*     audio/external.c bodies, regions RSR / RSRC / RSMS).                *)
(* Each outcome passes PoleClass.pole_ok, PoleKeep.fkp_ok and ret_ok.      *)
(* set_pole_position is not merged: a merge keeps only the facts common   *)
(* to all of its outcomes, and the height facts differ per outcome.       *)
(* ====================================================================== *)

From Coq Require Import List ZArith Reals.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Events Globalenvs
  Ctypes Clight ClightBigstep.
From SM64.Generated Require mario_step mario mario_actions_airborne mario_actions_automatic memory
  surface_collision level_update audio_external.
From SM64.Proofs Require Import Interp.SymExec2 Interp.LinkGenv MarioModel.LinkedTwelve
  MarioModel.OsDmaFloor MarioModel.MathGeomGated HeightInvariant HeightMoveCatalog WMotRLevel WMotRWorld.
From SM64.Proofs.WMotRRequiresA Require Import FloorHeight FloorExec AirXc AirRun AirMatch SmaXc
  ExtInert SndXc FfClass AirStart FfKeepCheck RetOk FfRun AhwRun KbRun WithGe
  PoleXc PoleClass PoleKeep PoleSound FfWorld FpWalk.
Import ListNotations.

Module AUT := mario_actions_automatic.

Definition NBP : positive := 24.
Definition RU : positive := 19.    (* usedObj, the pole *)
Definition RBT : positive := 20.   (* bhvTree *)
Definition RGP : positive := 17.   (* bhvGiantPole *)
Definition RLV : positive := 18.   (* gCurrLevelNum *)
(* set_sound_moving_speed's clobber (SndXc.c_ssms_sound) *)
Definition ssms_regs : list (ident * positive) := [(audio_external._sSoundMovingSpeed, RSMS)].
Definition kC : positive := 6.
Definition kL : positive := 7.
Definition kP : positive := 8.

Section CFG.
Variable acn : Z.
Variable g : genv.
Definition R0P : list (positive * Z) := R0F g ++ [(RU, szs g mario._Object)].
Definition gtabP : list (ident * positive) :=
  gtabF ++ [(AUT._bhvTree, RBT); (AUT._bhvGiantPole, RGP); (AUT._gCurrLevelNum, RLV)].
(* KbRun's known cells, and usedObj = the pole region with WMotR's low
   pole's oPosY, hitboxDownOffset and hitboxHeight *)
Definition kvP : list (positive * Z * memory_chunk * sval) :=
  kvK acn g ++
  [ (RM, USED_OFF, Mint32, Sptr RU Ptrofs.zero);
    (RU, O_POSY, Mfloat32, Sconst (Vsingle (Float32.of_int (Int.repr (-2739)))));
    (RU, HITBOX_DOWN_OFF, Mfloat32, Sconst (Vsingle Float32.zero));
    (RU, HITBOX_H_OFF, Mfloat32, Sconst (Vsingle (Float32.of_int (Int.repr 820)))) ].
Definition szSP : Z := szs g mario._Surface.
Definition xcIP (id : ident) : option xcontract :=
  if Pos.eqb id mario._find_floor then Some (c_ff2 NBP R0P RFI RMISS RCALLS kW kH kS kL szSP)
  else if Pos.eqb id mario._find_ceil then Some (c_fc2 NBP R0P RCALLS kW kC szSP)
  else air_xc NBP R0P RFI RMISS RCALLS kW kH kS szSP id.
Definition xcP (id : ident) : option xcontract :=
  match xcIP id with
  | Some k => Some k
  | None =>
    if Pos.eqb id mario._set_mario_animation then Some (c_sma NBP R0P gtabP kvP RLD RBUF RIOM RMQ RRM kB) else
    if Pos.eqb id mario._is_anim_at_end then Some xc_fresh else
    (* act_climbing_pole's climb animation and play_climbing_sounds' frame test *)
    if Pos.eqb id mario._set_mario_anim_with_accel then Some (c_smawa NBP R0P gtabP kvP RLD RBUF RIOM RMQ RRM kB) else
    if Pos.eqb id mario._is_anim_past_frame then Some xc_fresh else
    if Pos.eqb id AUT._play_sound then Some (c_snd R0P gtabP ps_regs) else
    if Pos.eqb id AUT._set_sound_moving_speed then Some (c_snd R0P gtabP ssms_regs) else None
  end.
Definition pc0P : list fact :=
  [Fuser kW (wargs R0P); Fbits (Sinit RM 2 Mint16unsigned) (Int.repr 2178);
   Fworld (Sinit RM (AirRun.fo g mario._MarioState mario._floor) Mint32) (szs g mario._Surface);
   Fworld (Sinit RM (AirRun.fo g mario._MarioState mario._area) Mint32) (szs g mario._Area);
   Fworld (Sptr RSIN Ptrofs.zero) Ptrofs.modulus;
   Fworld (Sptr RAR Ptrofs.zero) 4;
   Fworld (Sptr RLV Ptrofs.zero) 2;
   Fuser kB [Sinit RLD 8 Mint32; Sptr RBUF Ptrofs.zero];
   Fuser kP [init_cell kvP RO POLEPOS_OFF Mfloat32];
   Fuser kS (Sinit RM (AirRun.fo g mario._MarioState mario._floor) Mint32 :: wargs R0P);
   (* m->controller: a world object (act_holding_pole reads its stick) *)
   Fworld (Sinit RM FFW_CTL Mint32) SZ_CTL]
  ++ ffacts (Sinit RM (AirRun.fo g mario._MarioState mario._floor) Mint32).
Definition g0P : gst := mkg nil pc0P NBP nil nil.

(* the consumer facts' meaning *)
Definition ufP (m0 : mem) (gp : meminj) : positive -> list (option val) -> Prop :=
  fun k vs =>
    if Pos.eqb k kW then Wff g m0 gp (szs g mario._Surface) vs
    else if Pos.eqb k kS then surf_on g m0 vs
    else if Pos.eqb k kH then
      match vs with
      | [Some (Vsingle h); Some yv] => HPi (Hit_at g m0) (ycast yv) h /\ Hit_at g m0 h
      | _ => False
      end
    else if Pos.eqb k kB then
      exists b o o2, vs = [Some (Vptr b o); Some (Vptr b o2)] /\ Ptrofs.unsigned o + 24 <= Ptrofs.modulus
    else if Pos.eqb k kL then
      match vs with
      | [Some (Vsingle h); Some yv] => HPi (Hit_at g m0) (ycast yv) h
      | _ => False
      end
    else if Pos.eqb k kC then
      match vs with
      | [Some (Vsingle h); Some yv] => ceil_ok yv h
      | _ => False
      end
    else if Pos.eqb k kP then
      match vs with
      | [Some (Vsingle p)] => F32 p = true /\ (-1000 <= R2 p)%R
      | _ => False
      end
    else False.

(* each outcome: the move class, the kept world, the return *)
Definition pk_ok (c : cpath) : bool :=
  pole_ok NBP R0P kvP RM RO RU kP kC kH kL (fst c)
  && fkp_ok NBP R0P kvP RM RO RLD kS clokF (fst c) && no_reg RU (fst c)
  && ret_ok NBP R0P kvP RM c.
End CFG.

(* the leaf-particle and climbing-sound helpers write particleFlags or
   call play_sound only: merged *)
Definition mergeP (id : ident) : bool :=
  mergeK id || Pos.eqb id AUT._add_tree_leaf_particles || Pos.eqb id AUT._play_climbing_sounds.

Definition pole_walk (acn : Z) (f : function) : bool :=
  with_ge ge12 false (fun g =>
    match sx_call g NBP (R0P g) gtabP (kvP acn g) (xcP acn g) jkeys mergeP true 3000 (g0P acn g)
            (Internal f) argsF with
    | Some cs => forallb (pk_ok acn g) cs
    | None => false end).

Lemma dm_iae : (prog_defmap mario.prog) ! mario._is_anim_at_end
  = Some (Gfun (Internal mario.f_is_anim_at_end)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_smawa_h : (prog_defmap mario.prog) ! mario._set_mario_anim_with_accel
  = Some (Gfun (Internal mario.f_set_mario_anim_with_accel)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_ipf : (prog_defmap mario.prog) ! mario._is_anim_past_frame
  = Some (Gfun (Internal mario.f_is_anim_past_frame)).
Proof. vm_compute. reflexivity. Qed.
Lemma ps_aut : AUT._play_sound = AIR._play_sound.
Proof. reflexivity. Qed.

Section LP.
Variable lp : Clight.program.
Hypothesis H12 : linked12 lp.
Local Notation G := (globalenv lp).
Hypothesis Hdma : os_dma_floor.

Variable acn : Z.
Variable fK : function.
Hypothesis Hwalk : pole_walk acn fK = true.

Variables (m0 : mem) (gp : meminj).
Hypothesis GPO : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0).
Hypothesis MC : forall ch b z v, gp b <> None -> Mem.load ch m0 b z = Some v -> val_old gp v.
Hypothesis FD : floor_data G m0.

Local Notation uf := (ufP G m0 gp).

Lemma ufP_kW : forall vs, uf kW vs -> Wff G m0 gp (szs G mario._Surface) vs.
Proof. intros vs H. exact H. Qed.
Lemma ufP_kH_in : forall h yv, HPi (Hit_at G m0) (ycast yv) h -> Hit_at G m0 h ->
  uf kH [Some (Vsingle h); Some yv].
Proof. intros h yv A B. cbn. split; assumption. Qed.
Lemma ufP_kS : forall vs, surf_on G m0 vs -> uf kS vs.
Proof. intros vs H. exact H. Qed.
Lemma ufP_kS_out : forall vs, uf kS vs -> surf_on G m0 vs.
Proof. intros vs H. exact H. Qed.
Lemma ufP_kB : forall vs, uf kB vs ->
  exists b o o2, vs = [Some (Vptr b o); Some (Vptr b o2)] /\ Ptrofs.unsigned o + 24 <= Ptrofs.modulus.
Proof. intros vs H. exact H. Qed.
Lemma ufP_kL_in : forall h yv, HPi (Hit_at G m0) (ycast yv) h -> uf kL [Some (Vsingle h); Some yv].
Proof. intros h yv A. exact A. Qed.
Lemma ufP_kC_in : forall h yv, ceil_ok yv h -> uf kC [Some (Vsingle h); Some yv].
Proof. intros h yv A. exact A. Qed.

Lemma ufP_kP_out : forall vs, uf kP vs ->
  exists p, vs = [Some (Vsingle p)] /\ F32 p = true /\ (-1000 <= R2 p)%R.
Proof.
  intros vs H. cbn in H.
  destruct vs as [| [[| | | | p |]|] [| o r]]; try contradiction.
  exists p. split; [reflexivity | exact H].
Qed.
Lemma ufP_kC_out : forall vs, uf kC vs -> exists h yv, vs = [Some (Vsingle h); Some yv] /\ ceil_ok yv h.
Proof.
  intros vs H. cbn in H.
  destruct vs as [| [[| | | | h |]|] [| [yv|] [| o3 r]]]; try contradiction.
  exists h, yv. split; [reflexivity | exact H].
Qed.
Lemma ufP_kH_out : forall vs, uf kH vs -> exists h yv, vs = [Some (Vsingle h); Some yv]
                                               /\ HPi (Hit_at G m0) (ycast yv) h.
Proof.
  intros vs H. cbn in H.
  destruct vs as [| [[| | | | h |]|] [| [yv|] [| o3 r]]]; try contradiction.
  exists h, yv. split; [reflexivity | exact (proj1 H)].
Qed.
Lemma ufP_kL_out : forall vs, uf kL vs -> exists h yv, vs = [Some (Vsingle h); Some yv]
                                               /\ HPi (Hit_at G m0) (ycast yv) h.
Proof.
  intros vs H. cbn in H.
  destruct vs as [| [[| | | | h |]|] [| [yv|] [| o3 r]]]; try contradiction.
  exists h, yv. split; [reflexivity | exact H].
Qed.
(* this configuration names no y translation *)
Lemma ufP_kY_out : forall vs, uf kYp vs -> exists y, vs = [Some (Vint y)] /\ (-1 <= Int.signed y <= 174)%Z.
Proof. intros vs H. cbn in H. contradiction. Qed.

Let XSI := air_xc_sound_link lp (linked12_LO_surf lp H12) (linked12_LO_math lp H12)
             (linked12_LO_mario lp H12) NBP (R0P G) gtabP (kvP acn G) m0 uf gp
             RFI RMISS RCALLS kW kH kS (szs G mario._Surface) GPO eq_refl eq_refl eq_refl
             ufP_kW ufP_kH_in ufP_kS.

(* THE TABLE IS SOUND on the real link *)
Theorem xcP_sound : forall id k args g cps fd E m vargs t m' vres,
  xcP acn G id = Some k -> k args g = Some cps -> sfun_lookup G id = Some fd ->
  MMg G NBP (R0P G) gtabP (kvP acn G) m0 uf gp E m g ->
  Forall2 (fun a v => den G m0 E a = Some v /\ sok NBP (g_nx g) a) args vargs ->
  eval_funcall function_entry2 G m fd vargs t m' vres ->
  exists c, In c cps /\ CM G NBP (R0P G) gtabP (kvP acn G) m0 uf gp E (g_nx g) (g_loc g) m' vres c.
Proof.
  intros id k args g cps fd E m vargs t m' vres Hx Hk Hl MM HA EV.
  unfold xcP in Hx. destruct (xcIP G id) as [k0|] eqn:Xi.
  - injection Hx as <-. unfold xcIP in Xi.
    destruct (Pos.eqb_spec id mario._find_floor) as [-> | N1].
    { injection Xi as <-.
      rewrite (sfun_res_h _ _ _ _ (res_link lp _ _ _ (linked12_LO_surf lp H12) dm_ff) Hl) in EV.
      exact (c_ff2_sound G NBP (R0P G) gtabP (kvP acn G) m0 uf gp GPO RFI RMISS RCALLS kW kH kS kL
               (szs G mario._Surface) (cenv_has_link lp (linked12_LO_surf lp H12))
               (res_link lp _ _ _ (linked12_LO_surf lp H12) dm_ffl) eq_refl eq_refl eq_refl
               ufP_kW ufP_kS ufP_kH_in ufP_kL_in args g cps E m vargs t m' vres Hk MM HA EV). }
    destruct (Pos.eqb_spec id mario._find_ceil) as [-> | N2].
    { injection Xi as <-.
      rewrite (sfun_res_h _ _ _ _ (res_link lp _ _ _ (linked12_LO_surf lp H12) dm_fc) Hl) in EV.
      exact (c_fc2_sound G NBP (R0P G) gtabP (kvP acn G) m0 uf gp GPO RCALLS kW kC
               (szs G mario._Surface) (cenv_has_link lp (linked12_LO_surf lp H12))
               (res_link lp _ _ _ (linked12_LO_surf lp H12) dm_fcl) eq_refl
               ufP_kW ufP_kC_in args g cps E m vargs t m' vres Hk MM HA EV). }
    exact (XSI id k0 args g cps fd E m vargs t m' vres Xi Hk Hl MM HA EV).
  - destruct (Pos.eqb_spec id mario._set_mario_animation) as [-> | N1].
    + injection Hx as <-.
      rewrite (sfun_res_h _ _ _ _ (res_link lp _ _ _ (linked12_LO_mario lp H12) dm_sma_h) Hl) in EV.
      exact (c_sma_sound lp H12 Hdma NBP (R0P G) gtabP (kvP acn G) m0 uf gp GPO MC RLD RBUF RIOM RMQ RRM kB
               ufP_kB args g cps E m vargs t m' vres Hk MM HA EV).
    + destruct (Pos.eqb_spec id mario._is_anim_at_end) as [-> | N2].
      * injection Hx as <-.
        rewrite (sfun_res_h _ _ _ _ (res_link lp _ _ _ (linked12_LO_mario lp H12) dm_iae) Hl) in EV.
        destruct (anim_end_value_contract _ _ _ _ _ _ EV) as (-> & i & ->).
        exact (xc_fresh_sound G NBP (R0P G) gtabP (kvP acn G) (fun _ => None) (fun _ => false) m0 uf gp
                 E m g (Vint i) args cps Hk MM I).
      * destruct (Pos.eqb_spec id mario._set_mario_anim_with_accel) as [-> | N5].
        { injection Hx as <-.
          rewrite (sfun_res_h _ _ _ _ (res_link lp _ _ _ (linked12_LO_mario lp H12) dm_smawa_h) Hl) in EV.
          exact (c_smawa_sound lp H12 Hdma NBP (R0P G) gtabP (kvP acn G) m0 uf gp GPO MC RLD RBUF RIOM RMQ RRM kB
                   ufP_kB args g cps E m vargs t m' vres Hk MM HA EV). }
        destruct (Pos.eqb_spec id mario._is_anim_past_frame) as [-> | N6].
        { injection Hx as <-.
          rewrite (sfun_res_h _ _ _ _ (res_link lp _ _ _ (linked12_LO_mario lp H12) dm_ipf) Hl) in EV.
          destruct (past_frame_value_contract _ _ _ _ _ _ EV) as (-> & i & ->).
          exact (xc_fresh_sound G NBP (R0P G) gtabP (kvP acn G) (fun _ => None) (fun _ => false) m0 uf gp
                   E m g (Vint i) args cps Hk MM I). }
        destruct (Pos.eqb_spec id AUT._play_sound) as [-> | N3].
        { injection Hx as <-.
          rewrite (sfun_res _ _ _ _ (res_link lp _ _ _ (linked12_LO_audio_external lp H12) ps_defmap) Hl) in EV.
          exact (c_ps_sound lp NBP (R0P G) gtabP (kvP acn G) m0 uf gp GPO RSR RSRC
                   args g cps E m vargs t m' vres Hk MM EV). }
        destruct (Pos.eqb_spec id AUT._set_sound_moving_speed) as [-> | N4]; [| discriminate Hx].
        injection Hx as <-.
        rewrite (sfun_res _ _ _ _ (res_link lp _ _ _ (linked12_LO_audio_external lp H12) ssms_defmap) Hl) in EV.
        exact (c_ssms_sound lp NBP (R0P G) gtabP (kvP acn G) m0 uf gp GPO RSMS
                 args g cps E m vargs t m' vres Hk MM EV).
Qed.

Lemma polecheck_lp : exists cs,
  sx_call G NBP (R0P G) gtabP (kvP acn G) (xcP acn G) jkeys mergeP true 3000 (g0P acn G)
    (Internal fK) argsF = Some cs
  /\ forall c, In c cs -> pk_ok acn G c = true.
Proof.
  pose proof Hwalk as W. unfold pole_walk, with_ge in W. rewrite (ge12_ok lp H12) in W.
  exact (consume _ (pk_ok acn G) W).
Qed.

Lemma pc0P_nlt : forall f, In f (pc0P acn G) -> fact_nlt NBP f.
Proof.
  intros f H. cbn [pc0P app ffacts In] in H.
  repeat (destruct H as [<- | H]; [cbn; repeat split; try (unfold Plt; cbn; lia); repeat constructor; unfold Plt; cbn; lia |]).
  contradiction.
Qed.

(* THE THEOREM: every execution of the pole handler from a memory the
   start state describes keeps the world (fkp_ok) and moves Phi's cells
   by one RangedMove; in a pole action it keeps usedObj and the pole, and
   oMarioPolePos stays a finite float >= -1000 *)
Theorem pole_final : forall E t m' vres c0,
  env_ok G NBP (R0P G) gtabP (kvP acn G) m0 gp E ->
  (forall f, In f (pc0P acn G) -> fact_holds G (R0P G) m0 uf E f) ->
  eval_funcall function_entry2 G m0 (Internal fK)
    [Vptr (e_blk E RM) (Ptrofs.add (e_base E RM) Ptrofs.zero)] t m' vres ->
  read_cells (e_blk E RM) m0 c0 -> InRange c0 ->
  exists E' gs, Ext E E' NBP /\ MMg G NBP (R0P G) gtabP (kvP acn G) m0 uf gp E' m' gs
    /\ fkp_ok NBP (R0P G) (kvP acn G) RM RO RLD kS clokF gs = true /\ no_reg RU gs = true
    /\ RET (e_blk E RM) m0 m' vres
    /\ exists c2, read_cells (e_blk E RM) m' c2
       /\ RangedMove wmotr_floor wmotr_pole wmotr_cannon c0 c2
       /\ In (Int.unsigned (c_action c2)) POLE_OUT
       /\ c_vely c2 = c_vely c0
       /\ (In (Int.unsigned (c_action c2)) POLE_ACTS3 ->
             Mem.load Mint32 m' (e_blk E RM) USED_OFF = Mem.load Mint32 m0 (e_blk E RM) USED_OFF
             /\ (forall z, z = O_POSY \/ z = HITBOX_DOWN_OFF \/ z = HITBOX_H_OFF ->
                   Mem.load Mfloat32 m' (e_blk E RU) (addr E RU z)
                   = Mem.load Mfloat32 m0 (e_blk E RU) (addr E RU z))
             /\ exists p, Mem.load Mfloat32 m' (e_blk E RO) (addr E RO POLEPOS_OFF) = Some (Vsingle p)
                  /\ F32 p = true /\ (-1000 <= R2 p)%R).
Proof.
  intros E t m' vres c0 EO PC EV RC IR.
  destruct polecheck_lp as (cs & RUN & W).
  assert (MM0 : MMg G NBP (R0P G) gtabP (kvP acn G) m0 uf gp E m0 (g0P acn G)).
  { apply MMg_init; [exact EO | apply Ple_refl |].
    intros f Hf. split; [exact (pc0P_nlt f Hf) | exact (PC f Hf)]. }
  assert (ARGS : Forall2 (fun a v => den G m0 E a = Some v /\ sok NBP (g_nx (g0P acn G)) a) argsF
                   [Vptr (e_blk E RM) (Ptrofs.add (e_base E RM) Ptrofs.zero)]).
  { constructor; [| constructor].
    split; [reflexivity |]. cbn [sok nlt g0P g_nx]. split; [unfold Plt, Pos.lt; reflexivity | exact Logic.I]. }
  destruct (sx_call_sound G NBP (R0P G) gtabP (kvP acn G) (xcP acn G) jkeys mergeP true m0 uf gp
              GPO MC xcP_sound 3000 (g0P acn G) _ argsF cs E m0 _ t m' vres RUN MM0 ARGS EV) as (c & Hin & CMc).
  destruct c as [gs r]. destruct CMc as (E' & X & MM & DR & _).
  pose proof (W _ Hin) as OK. unfold pk_ok in OK. cbn [fst] in OK.
  apply andb_true_iff in OK as [OK RT]. apply andb_true_iff in OK as [OK NR].
  apply andb_true_iff in OK as [PO FK].
  exists E', gs. split; [exact X | split; [exact MM | split; [exact FK | split; [exact NR |]]]].
  destruct EO as (_ & _ & _ & GT & KV & _).
  destruct (GT level_update._gMarioStates RM eq_refl) as (_ & HbM & _).
  destruct (X RM ltac:(vm_compute; reflexivity)) as (BM & BaM & _).
  destruct (X RO ltac:(vm_compute; reflexivity)) as (BO & BaO & _).
  destruct (X RU ltac:(vm_compute; reflexivity)) as (BU & BaU & _).
  split; [rewrite <- BM; exact (ret_sound G NBP (R0P G) gtabP (kvP acn G) m0 uf gp GPO RM E' m' gs MM
                                 ltac:(rewrite BaM; exact HbM) r vres DR RT) |].
  rewrite <- BM in RC.
  destruct (pole_sound G NBP (R0P G) gtabP (kvP acn G) m0 uf gp GPO RM RO RU kP kC kH kL
              ufP_kP_out ufP_kC_out ufP_kH_out ufP_kL_out ufP_kY_out FD E' m' gs MM
              ltac:(rewrite BaM; exact HbM) c0 RC IR PO)
    as (c2 & RC2 & RM2 & Hout & Hv & Hk).
  exists c2. rewrite <- BM. split; [exact RC2 |]. split; [exact RM2 |]. split; [exact Hout |].
  split; [exact Hv |].
  intros H3. specialize (Hk H3).
  destruct (pole_keep_sound G NBP (R0P G) gtabP (kvP acn G) m0 uf gp GPO RM RO RU kP kC
              ufP_kP_out ufP_kC_out ufP_kY_out E' m' gs MM ltac:(rewrite BaM; exact HbM) Hk) as (U1 & U2 & U3).
  unfold addr. rewrite <- BU, <- BaU, <- BO, <- BaO.
  split; [exact U1 |]. split; [exact U2 | exact U3].
Qed.
End LP.

(* the walk theorem's statement, for either grab on the link *)
Definition pfinal (lp : Clight.program) (acn : Z) (fK : function) : Prop :=
  forall (m0 : mem) (gp : meminj),
  (forall b x, gp b = Some x -> Plt b (Mem.nextblock m0)) ->
  (forall ch b z v, gp b <> None -> Mem.load ch m0 b z = Some v -> val_old gp v) ->
  floor_data (globalenv lp) m0 ->
  forall E t m' vres c0,
  env_ok (globalenv lp) NBP (R0P (globalenv lp)) gtabP (kvP acn (globalenv lp)) m0 gp E ->
  (forall f, In f (pc0P acn (globalenv lp)) ->
     fact_holds (globalenv lp) (R0P (globalenv lp)) m0 (ufP (globalenv lp) m0 gp) E f) ->
  eval_funcall function_entry2 (globalenv lp) m0 (Internal fK)
    [Vptr (e_blk E RM) (Ptrofs.add (e_base E RM) Ptrofs.zero)] t m' vres ->
  read_cells (e_blk E RM) m0 c0 -> InRange c0 ->
  exists E' gs, Ext E E' NBP
    /\ MMg (globalenv lp) NBP (R0P (globalenv lp)) gtabP (kvP acn (globalenv lp)) m0
         (ufP (globalenv lp) m0 gp) gp E' m' gs
    /\ fkp_ok NBP (R0P (globalenv lp)) (kvP acn (globalenv lp)) RM RO RLD kS clokF gs = true
    /\ no_reg RU gs = true
    /\ RET (e_blk E RM) m0 m' vres
    /\ exists c2, read_cells (e_blk E RM) m' c2
       /\ RangedMove wmotr_floor wmotr_pole wmotr_cannon c0 c2
       /\ In (Int.unsigned (c_action c2)) POLE_OUT
       /\ c_vely c2 = c_vely c0
       /\ (In (Int.unsigned (c_action c2)) POLE_ACTS3 ->
             Mem.load Mint32 m' (e_blk E RM) USED_OFF = Mem.load Mint32 m0 (e_blk E RM) USED_OFF
             /\ (forall z, z = O_POSY \/ z = HITBOX_DOWN_OFF \/ z = HITBOX_H_OFF ->
                   Mem.load Mfloat32 m' (e_blk E RU) (addr E RU z)
                   = Mem.load Mfloat32 m0 (e_blk E RU) (addr E RU z))
             /\ exists p, Mem.load Mfloat32 m' (e_blk E RO) (addr E RO POLEPOS_OFF) = Some (Vsingle p)
                  /\ F32 p = true /\ (-1000 <= R2 p)%R).

Lemma pole_pfinal : forall lp, linked12 lp -> os_dma_floor ->
  forall acn fK, pole_walk acn fK = true -> pfinal lp acn fK.
Proof.
  intros lp H12 Hdma acn fK Hw m0 gp GPO MC FD.
  exact (pole_final lp H12 Hdma acn fK Hw m0 gp GPO MC FD).
Qed.
