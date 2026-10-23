(* ====================================================================== *)
(* KbRun (GOAL 2): the air knockback family, walked on the link.          *)
(*                                                                        *)
(* act_soft_bonk, act_backward_air_kb and act_forward_air_kb share         *)
(* common_air_knockback_step (perform_air_step with no ledge grab, then    *)
(* a landing, a wall bonk that keeps the action, or nothing).  The same    *)
(* walker and contract table as FfRun, with the action cell known to be    *)
(* the case's constant (kvK acn); the wall kick is A-gated and pruned.     *)
(* Each outcome passes FfClass.ff_ok (whose air-step fact AirSum.MV holds  *)
(* from any air_entry action) and FfKeepCheck.fk_ok (the world is kept).  *)
(* The walk is computed once per action (sbcheck12, bkbcheck12,            *)
(* fkbcheck12); kb_final is generic in the action.                         *)
(* ====================================================================== *)

From Coq Require Import List ZArith Reals.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Events Globalenvs
  Ctypes Clight ClightBigstep.
From SM64.Generated Require mario_step mario mario_actions_airborne memory surface_collision level_update.
From SM64.Proofs Require Import Interp.SymExec2 Interp.LinkGenv MarioModel.LinkedTwelve
  MarioModel.OsDmaFloor MarioModel.MathGeomGated HeightInvariant HeightMoveCatalog WMotRLevel.
From SM64.Proofs.WMotRRequiresA Require Import FloorHeight FloorExec AirXc AirRun AirWr WallExec AirMatch AirMove SmaXc AirSum FpuFloor FpWalk ExtInert FfClass AirStart FfKeepCheck RetOk FfRun AhwRun WithGe.
Import ListNotations.

Module AIR := mario_actions_airborne.

Section CFG.
Variable acn : Z.
Variable g : genv.

(* known cells: marioObj, action = the case's constant, heldObj = riddenObj
   = NULL, animList = &gMarioAnimsBuf, statusForCamera =
   &gPlayerCameraState[0] (FfWorld.ffw's last conjunct) *)
Definition kvK : list (positive * Z * memory_chunk * sval) :=
  [ (RM, AirRun.fo g mario._MarioState mario._marioObj, Mint32, Sptr RO Ptrofs.zero);
    (RM, 12, Mint32, Sconst (Vint (Int.repr acn)));
    (RM, AirRun.fo g mario._MarioState mario._heldObj, Mint32, Sconst (Vint Int.zero));
    (RM, AirRun.fo g mario._MarioState mario._riddenObj, Mint32, Sconst (Vint Int.zero));
    (RM, AirRun.fo g mario._MarioState mario._animList, Mint32, Sptr RLD Ptrofs.zero);
    (RM, 148, Mint32, Sptr RPC Ptrofs.zero) ].
Definition xcK (id : ident) : option xcontract :=
  match xcI g id with
  | Some k => Some k
  | None =>
    if Pos.eqb id mario._set_mario_animation then Some (c_sma NBF (R0F g) gtabF kvK RLD RBUF RIOM RMQ RRM kB) else
    if Pos.eqb id AIR._update_air_without_turn then Some (c_wr NBF (R0F g) (uawt_ws g)) else
    if Pos.eqb id AIR._update_air_with_turn then Some (c_wr NBF (R0F g) (uawith_ws g)) else
    if Pos.eqb id mario_step._perform_air_step then
      Some (c_pas g NBF (R0F g) gtabF kvK (xcI g) (jkI g) mergef 400 (Internal mario_step.f_perform_air_step) RM RO kH kM)
    else if existsb (Pos.eqb id) ext_ids then Some xc_fresh else None
  end.
End CFG.


(* both checks of an outcome: the MoveChain class and the kept world *)
Definition kbk_ok (acn : Z) (g : genv) (c : cpath) : bool :=
  ff_ok NBF (R0F g) (kvK acn g) RM RO kM (fst c) && fk_ok NBF (R0F g) (kvK acn g) RM RO RLD kS clokF (fst c)
  && ret_ok NBF (R0F g) (kvK acn g) RM c.

(* the landing's two helpers are merged too (should_get_stuck_in_ground,
   check_fall_damage): soft bonk's walk then takes 315 s instead of 578 s;
   and play_mario_sound, whose flag and terrain tests split dive's walk 44
   ways before the air step (merged, the whole dive walk takes 90 s) *)
Definition mergeK (id : ident) : bool :=
  mergeF id || Pos.eqb id AIR._should_get_stuck_in_ground || Pos.eqb id AIR._check_fall_damage
  || Pos.eqb id AIR._play_mario_sound.

Definition kb_walk (acn : Z) (f : function) : bool :=
  with_ge ge12 false (fun g =>
    match sx_call g NBF (R0F g) gtabF (kvK acn g) (xcK acn g) jkeys mergeK true 3000 (g0F g)
            (Internal f) argsF with
    | Some cs => forallb (kbk_ok acn g) cs
    | None => false end).

(* THE WALKS, each in its own file so they build in parallel: KbSb, KbBkb,
   KbFkb, KbDv (vm_cast_no_check: the kernel computes each walk once, at
   Qed, instead of the tactic and then the kernel) *)

Section LP.
Variable lp : Clight.program.
Hypothesis H12 : linked12 lp.
Local Notation G := (globalenv lp).
Hypothesis Hdma : os_dma_floor.
Hypothesis Hsq : sqrtf_spec.
Hypothesis Hsqf : sqrtf_float.
Hypothesis Haudio : audio_inert.      (* LABELED OPEN PREMISE: audio, deferred *)

Variable acn : Z.
Variable fK : function.
Hypothesis Hwalk : kb_walk acn fK = true.
Hypothesis Hae : air_entry (Int.repr acn) = true.

Variables (m0 : mem) (gp : meminj).
Hypothesis GPO : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0).
Hypothesis MC : forall ch b z v, gp b <> None -> Mem.load ch m0 b z = Some v -> val_old gp v.
Hypothesis FD : floor_data G m0.

Local Notation uf := (ufF G m0 gp).

Lemma uf_kW_k : forall vs, uf kW vs -> Wff G m0 gp (szs G mario._Surface) vs.
Proof. intros vs H. exact H. Qed.
Lemma uf_kH_in_k : forall h yv, HPi (Hit_at G m0) (ycast yv) h -> Hit_at G m0 h ->
  uf kH [Some (Vsingle h); Some yv].
Proof. intros h yv A B. cbn. split; assumption. Qed.
Lemma uf_kH_out_k : forall vs, uf kH vs ->
  exists h yv, vs = [Some (Vsingle h); Some yv] /\ HPi (Hit_at G m0) (ycast yv) h /\ Hit_at G m0 h.
Proof.
  intros vs H. cbn in H.
  destruct vs as [| [[| | | | h |]|] [| [yv|] [| o3 r]]]; try contradiction.
  exists h, yv. split; [reflexivity | exact H].
Qed.
Lemma uf_kS_k : forall vs, surf_on m0 vs -> uf kS vs.
Proof. intros vs H. exact H. Qed.
Lemma uf_kM_k : forall vs, MV vs -> uf kM vs.
Proof. intros vs H. exact H. Qed.
Lemma uf_kM_k_out : forall vs, uf kM vs -> MV vs.
Proof. intros vs H. exact H. Qed.
Lemma uf_kB_k : forall vs, uf kB vs ->
  exists b o o2, vs = [Some (Vptr b o); Some (Vptr b o2)] /\ Ptrofs.unsigned o + 24 <= Ptrofs.modulus.
Proof. intros vs H. exact H. Qed.

Let XSI := air_xc_sound_link lp (linked12_LO_surf lp H12) (linked12_LO_math lp H12)
             (linked12_LO_mario lp H12) NBF (R0F G) gtabF (kvK acn G) m0 uf gp
             RFI RMISS RCALLS kW kH kS (szs G mario._Surface) GPO eq_refl eq_refl eq_refl uf_kW_k uf_kH_in_k uf_kS_k.

(* THE TABLE IS SOUND on the real link *)
Theorem xcK_sound : forall id k args g cps fd E m vargs t m' vres,
  xcK acn G id = Some k -> k args g = Some cps -> sfun_lookup G id = Some fd ->
  MMg G NBF (R0F G) gtabF (kvK acn G) m0 uf gp E m g ->
  Forall2 (fun a v => den G m0 E a = Some v /\ sok NBF (g_nx g) a) args vargs ->
  eval_funcall function_entry2 G m fd vargs t m' vres ->
  exists c, In c cps /\ CM G NBF (R0F G) gtabF (kvK acn G) m0 uf gp E (g_nx g) (g_loc g) m' vres c.
Proof.
  intros id k args g cps fd E m vargs t m' vres Hx Hk Hl MM HA EV.
  unfold xcK in Hx. destruct (xcI G id) as [k0|] eqn:Xi.
  - injection Hx as <-. exact (XSI id k0 args g cps fd E m vargs t m' vres Xi Hk Hl MM HA EV).
  - destruct (Pos.eqb_spec id mario._set_mario_animation) as [-> | N1].
    + injection Hx as <-.
      rewrite (sfun_res_h _ _ _ _ (res_link lp _ _ _ (linked12_LO_mario lp H12) dm_sma_h) Hl) in EV.
      exact (c_sma_sound lp H12 Hdma NBF (R0F G) gtabF (kvK acn G) m0 uf gp GPO MC RLD RBUF RIOM RMQ RRM kB
               uf_kB_k args g cps E m vargs t m' vres Hk MM HA EV).
    + destruct (Pos.eqb_spec id AIR._update_air_without_turn) as [-> | N2].
      * injection Hx as <-.
        rewrite (sfun_res_h _ _ _ _ (res_link lp _ _ _ (linked12_LO_air lp H12) dm_uawt_h) Hl) in EV.
        exact (c_uawt_sound lp H12 Hsq NBF (R0F G) gtabF (kvK acn G) m0 uf gp GPO
                 args g cps E m vargs t m' vres Hk MM HA EV).
      * destruct (Pos.eqb_spec id AIR._update_air_with_turn) as [-> | N2'].
        { injection Hx as <-.
          rewrite (sfun_res_h _ _ _ _ (res_link lp _ _ _ (linked12_LO_air lp H12) dm_uawith) Hl) in EV.
          exact (c_uawith_sound lp H12 Hsq NBF (R0F G) gtabF (kvK acn G) m0 uf gp GPO
                   args g cps E m vargs t m' vres Hk MM HA EV). }
        destruct (Pos.eqb_spec id mario_step._perform_air_step) as [-> | N3].
        -- injection Hx as <-.
           rewrite (sfun_res_h _ _ _ _ (res_link lp _ _ _ (linked12_LO_stp lp H12) dm_pas_h) Hl) in EV.
           exact (c_pas_sound G NBF (R0F G) gtabF (kvK acn G) (xcI G) (jkI G) mergef 400
                    (Internal mario_step.f_perform_air_step) RM RO kH kM m0 uf gp GPO MC XSI
                    level_update._gMarioStates eq_refl eq_refl uf_kH_out_k uf_kM_k FD
                    args g cps E m vargs t m' vres Hk MM HA EV).
        -- destruct (existsb (Pos.eqb id) (ext_ids)) eqn:Ex; [| discriminate Hx].
           injection Hx as <-.
           apply existsb_exists in Ex as (x & Ix & Ex). apply Pos.eqb_eq in Ex. subst x.
           destruct Ix as [<- | [<- | []]].
           ++ exact (ext_fresh_sound lp H12 _ _ ps_named ps_ni (audio_ps Haudio) NBF (R0F G) gtabF (kvK acn G) m0 uf gp GPO
                       args g cps fd E m vargs t m' vres Hk Hl MM EV).
           ++ exact (ext_fresh_sound lp H12 _ _ sqrtf_named_air_h sqrtf_ni (sqrtf_inert Hsq Hsqf)
                       NBF (R0F G) gtabF (kvK acn G) m0 uf gp GPO args g cps fd E m vargs t m' vres Hk Hl MM EV).
Qed.

Lemma kbcheck_lp : exists cs,
  sx_call G NBF (R0F G) gtabF (kvK acn G) (xcK acn G) jkeys mergeK true 3000 (g0F G)
    (Internal fK) argsF = Some cs
  /\ forall c, In c cs -> kbk_ok acn G c = true.
Proof.
  pose proof Hwalk as W. unfold kb_walk, with_ge in W. rewrite (ge12_ok lp H12) in W.
  exact (consume _ (kbk_ok acn G) W).
Qed.

Lemma pc0F_nlt_k : forall f, In f (pc0F G) -> fact_nlt NBF f.
Proof.
  intros f H. cbn [pc0F app ffacts In] in H.
  repeat (destruct H as [<- | H]; [cbn; repeat split; try (unfold Plt; cbn; lia); repeat constructor; unfold Plt; cbn; lia |]).
  contradiction.
Qed.

(* THE THEOREM: every execution of the case's real handler from a memory
   the start state describes is a MoveChain of Phi's cells *)
Theorem kb_final : forall E t m' vres c0,
  env_ok G NBF (R0F G) gtabF (kvK acn G) m0 gp E ->
  (forall f, In f (pc0F G) -> fact_holds G (R0F G) m0 uf E f) ->
  eval_funcall function_entry2 G m0 (Internal fK)
    [Vptr (e_blk E RM) (Ptrofs.add (e_base E RM) Ptrofs.zero)] t m' vres ->
  read_cells (e_blk E RM) m0 c0 -> budget_ok c0 ->
  FloorRefreshOK wmotr_floor (R2 (c_posy c0)) (R2 (c_floorh c0)) ->
  exists E' gs, Ext E E' NBF /\ MMg G NBF (R0F G) gtabF (kvK acn G) m0 uf gp E' m' gs
    /\ fk_ok NBF (R0F G) (kvK acn G) RM RO RLD kS clokF gs = true
    /\ RET (e_blk E RM) m0 m' vres
    /\ exists c2, read_cells (e_blk E RM) m' c2 /\ MoveChain wmotr_floor wmotr_pole wmotr_cannon c0 c2
       /\ fro_ff c2.
Proof.
  intros E t m' vres c0 EO PC EV RC Hb FRO.
  destruct kbcheck_lp as (cs & RUN & W).
  assert (MM0 : MMg G NBF (R0F G) gtabF (kvK acn G) m0 uf gp E m0 (g0F G)).
  { apply MMg_init; [exact EO | apply Ple_refl |].
    intros f Hf. split; [exact (pc0F_nlt_k f Hf) | exact (PC f Hf)]. }
  assert (ARGS : Forall2 (fun a v => den G m0 E a = Some v /\ sok NBF (g_nx (g0F G)) a) argsF
                   [Vptr (e_blk E RM) (Ptrofs.add (e_base E RM) Ptrofs.zero)]).
  { constructor; [| constructor].
    split; [reflexivity |]. cbn [sok nlt g0F g_nx]. split; [unfold Plt, Pos.lt; reflexivity | exact Logic.I]. }
  destruct (sx_call_sound G NBF (R0F G) gtabF (kvK acn G) (xcK acn G) jkeys mergeK true m0 uf gp
              GPO MC xcK_sound 3000 (g0F G) _ argsF cs E m0 _ t m' vres RUN MM0 ARGS EV) as (c & Hin & CMc).
  destruct c as [gs r]. destruct CMc as (E' & X & MM & DR & _).
  pose proof (W _ Hin) as OK. unfold kbk_ok in OK. cbn [fst] in OK.
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
  assert (Hact0 : c_action c0 = Int.repr acn).
  { destruct (KV RM 12%Z Mint32 (Sconst (Vint (Int.repr acn)))) as (_ & _ & L);
      [cbn [kvK]; right; left; reflexivity |].
    unfold addr in L. rewrite HbM, Ptrofs.unsigned_zero, Z.add_0_l in L.
    destruct RC as (HA & _). change OFS_ACTION with 12%Z in HA. rewrite HA in L. cbn [den] in L.
    injection L as ->. reflexivity. }
  assert (Hact : pas_entry (c_action c0) (state_of c0) = true) by (rewrite Hact0; exact (air_pas _ _ Hae)).
  split; [rewrite <- BM; exact (ret_sound G NBF (R0F G) gtabF (kvK acn G) m0 uf gp GPO RM E' m' gs MM
                                 ltac:(rewrite BaM; exact HbM) r vres DR RT) |].
  rewrite <- BM in RC |- *.
  exact (ff_sound G NBF (R0F G) gtabF (kvK acn G) m0 uf gp GPO RM RO kM uf_kM_k_out E' m' gs MM
           ltac:(rewrite BaM; exact HbM) HO0 c0 RC Hact Hb FRO OK).
Qed.
End LP.

(* the walk theorem's statement, for any case's handler on the link
   (KbRow.kb_row takes it; ground pound's is GpRun.gp_kfinal) *)
Definition kfinal (lp : Clight.program) (acn : Z) (fK : function) : Prop :=
  forall (m0 : mem) (gp : meminj),
  (forall b x, gp b = Some x -> Plt b (Mem.nextblock m0)) ->
  (forall ch b z v, gp b <> None -> Mem.load ch m0 b z = Some v -> val_old gp v) ->
  floor_data (globalenv lp) m0 ->
  forall E t m' vres c0,
  env_ok (globalenv lp) NBF (R0F (globalenv lp)) gtabF (kvK acn (globalenv lp)) m0 gp E ->
  (forall f, In f (pc0F (globalenv lp)) ->
     fact_holds (globalenv lp) (R0F (globalenv lp)) m0 (ufF (globalenv lp) m0 gp) E f) ->
  eval_funcall function_entry2 (globalenv lp) m0 (Internal fK)
    [Vptr (e_blk E RM) (Ptrofs.add (e_base E RM) Ptrofs.zero)] t m' vres ->
  read_cells (e_blk E RM) m0 c0 -> budget_ok c0 ->
  FloorRefreshOK wmotr_floor (R2 (c_posy c0)) (R2 (c_floorh c0)) ->
  exists E' gs, Ext E E' NBF
    /\ MMg (globalenv lp) NBF (R0F (globalenv lp)) gtabF (kvK acn (globalenv lp)) m0
         (ufF (globalenv lp) m0 gp) gp E' m' gs
    /\ fk_ok NBF (R0F (globalenv lp)) (kvK acn (globalenv lp)) RM RO RLD kS clokF gs = true
    /\ RET (e_blk E RM) m0 m' vres
    /\ exists c2, read_cells (e_blk E RM) m' c2 /\ MoveChain wmotr_floor wmotr_pole wmotr_cannon c0 c2
       /\ fro_ff c2.

Lemma kb_kfinal : forall lp, linked12 lp -> os_dma_floor -> sqrtf_spec -> sqrtf_float ->
  audio_inert -> forall acn fK, kb_walk acn fK = true -> air_entry (Int.repr acn) = true ->
  kfinal lp acn fK.
Proof.
  (* explicit: eassumption would unify kb_walk with the other hypotheses,
     unfolding the walk onto the whole link (it ran > 10 min) *)
  intros lp H12 Hdma Hsq Hsqf Ha acn fK Hw Hae m0 gp GPO MC FD.
  exact (kb_final lp H12 Hdma Hsq Hsqf Ha acn fK Hw Hae m0 gp GPO MC FD).
Qed.
