(* ====================================================================== *)
(* FfRun (unwired, GOAL 2): the real act_freefall, walked on the link.    *)
(*                                                                        *)
(* THE THEOREM (ff_move): every execution of the real act_freefall from a *)
(* memory the start state describes, with Mario's cells c0 in budget,     *)
(* ends with cells c2 such that MoveChain c0 c2.  The walk runs once on   *)
(* the real link (vm_compute, ~4 min); its table answers                  *)
(*   find_floor / find_ceil / walls / atan2s ...   AirXc (real bodies)    *)
(*   perform_air_step                              AirSum.c_pas           *)
(*   set_mario_animation                           SmaXc.c_sma (DMA floor)*)
(*   update_air_without_turn                       AirWr (FPU floor)      *)
(*   play_sound / set_camera_shake_from_hit / sqrtf  ExtInert             *)
(* and every one of the walk's outcomes passes FfClass.ff_ok.             *)
(*                                                                        *)
(* Premises: the start state (env_ok + the start facts, to be proved from *)
(* the frame memory), the floor data and floor refresh of AirMove, the    *)
(* hardware floors (DMA, FPU), and the labeled audio/camera premises.     *)
(* ====================================================================== *)

From Coq Require Import List ZArith Reals.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Events Globalenvs
  Ctypes Clight ClightBigstep.
From SM64.Generated Require mario_step mario mario_actions_airborne memory surface_collision level_update.
From SM64.Proofs Require Import Interp.SymExec2 Interp.LinkGenv MarioModel.LinkedTwelve
  MarioModel.OsDmaFloor MarioModel.MathGeomGated HeightInvariant HeightMoveCatalog WMotRLevel.
From SM64.Proofs.WMotRRequiresA Require Import FloorHeight FloorExec AirXc AirRun AirWr WallExec AirMatch AirMove SmaXc AirSum FpuFloor FpWalk ExtInert FfClass AirStart FfKeepCheck.
Import ListNotations.

Module AIR := mario_actions_airborne.

Definition NBF : positive := 16.
Definition RSIN : positive := 7.
Definition RLD : positive := 8.
Definition RBUF : positive := 9.
Definition RIOM : positive := 10.
Definition RMQ : positive := 11.
Definition RRM : positive := 12.
Definition kM : positive := 3.
Definition kB : positive := 4.

Section CFG.
Variable g : genv.

Definition R0F : list (positive * Z) :=
  [(RM, szs g mario._MarioState); (RO, szs g mario._Object); (RFI, 2); (RMISS, 4); (RCALLS, 6);
   (RLD, szs g mario._DmaHandlerList); (RBUF, Ptrofs.modulus); (RIOM, 20); (RMQ, 24); (RRM, 4)].
Definition gtabF : list (ident * positive) :=
  [(surface_collision._gFindFloorIncludeSurfaceIntangible, RFI);
   (surface_collision._gNumFindFloorMisses, RMISS); (surface_collision._gNumCalls, RCALLS);
   (mario._gSineTable, RSIN); (level_update._gMarioStates, RM); (mario._gMarioAnimsBuf, RLD);
   (memory._gDmaIoMesg, RIOM); (memory._gDmaMesgQueue, RMQ); (memory._gMainReceivedMesg, RRM)].
(* known cells: marioObj, action = ACT_FREEFALL, heldObj = riddenObj = NULL,
   animList = &gMarioAnimsBuf *)
Definition kvF : list (positive * Z * memory_chunk * sval) :=
  [ (RM, AirRun.fo g mario._MarioState mario._marioObj, Mint32, Sptr RO Ptrofs.zero);
    (RM, 12, Mint32, Sconst (Vint (Int.repr 16779404)));
    (RM, AirRun.fo g mario._MarioState mario._heldObj, Mint32, Sconst (Vint Int.zero));
    (RM, AirRun.fo g mario._MarioState mario._riddenObj, Mint32, Sconst (Vint Int.zero));
    (RM, AirRun.fo g mario._MarioState mario._animList, Mint32, Sptr RLD Ptrofs.zero) ].
(* the start facts: AirRun's, the sine table's block, the anim buffer, and
   the entry floor is a WMotR surface off the regions *)
Definition pc0F : list fact :=
  [Fuser kW (wargs R0F); Fbits (Sinit RM 2 Mint16unsigned) (Int.repr 130);
   Fworld (Sinit RM (AirRun.fo g mario._MarioState mario._floor) Mint32) (szs g mario._Surface);
   Fworld (Sinit RM (AirRun.fo g mario._MarioState mario._area) Mint32) (szs g mario._Area);
   Fworld (Sptr RSIN Ptrofs.zero) Ptrofs.modulus;
   Fuser kB [Sinit RLD 8 Mint32; Sptr RBUF Ptrofs.zero];
   Fuser kS (Sinit RM (AirRun.fo g mario._MarioState mario._floor) Mint32 :: wargs R0F)]
  ++ ffacts (Sinit RM (AirRun.fo g mario._MarioState mario._floor) Mint32).
Definition xcI : ident -> option xcontract := air_xc NBF R0F RFI RMISS RCALLS kW kH kS (szs g mario._Surface).
Definition jkI : list (positive * Z * memory_chunk) := jkeys ++ [(RM, AirRun.fo g mario._MarioState mario._wall, Mint32)].
Definition ext_ids : list ident := [AIR._play_sound; AIR._sqrtf; AIR._set_camera_shake_from_hit].
Definition xcF (id : ident) : option xcontract :=
  match xcI id with
  | Some k => Some k
  | None =>
    if Pos.eqb id mario._set_mario_animation then Some (c_sma NBF R0F gtabF kvF RLD RBUF RIOM RMQ RRM kB) else
    if Pos.eqb id AIR._update_air_without_turn then Some (c_wr NBF R0F (uawt_ws g)) else
    if Pos.eqb id mario_step._perform_air_step then
      Some (c_pas g NBF R0F gtabF kvF xcI jkI mergef 400 (Internal mario_step.f_perform_air_step) RM RO kH kM)
    else if existsb (Pos.eqb id) ext_ids then Some xc_fresh else None
  end.
Definition mergeF (id : ident) : bool := mergef id || Pos.eqb id AIR._check_fall_damage_or_get_stuck.
Definition g0F : gst := mkg nil pc0F NBF nil nil.
Definition argsF : list sval := [Sptr RM Ptrofs.zero].

(* the consumer facts' meaning *)
Definition ufF (m0 : mem) (gp : meminj) : positive -> list (option val) -> Prop :=
  fun k vs =>
    if Pos.eqb k kW then Wff g m0 gp (szs g mario._Surface) vs
    else if Pos.eqb k kS then surf_on m0 vs
    else if Pos.eqb k kH then
      match vs with
      | [Some (Vsingle h); Some yv] => HPi (Hit_at g m0) (ycast yv) h /\ Hit_at g m0 h
      | _ => False
      end
    else if Pos.eqb k kM then MV vs
    else if Pos.eqb k kB then
      exists b o o2, vs = [Some (Vptr b o); Some (Vptr b o2)] /\ Ptrofs.unsigned o + 24 <= Ptrofs.modulus
    else False.
End CFG.

(* both checks of an outcome: the MoveChain class and the kept world *)
Definition clokF : list positive := [RBUF; RIOM; RMQ; RRM].
Definition ffk_ok (g : genv) (c : cpath) : bool :=
  ff_ok NBF (R0F g) (kvF g) RM RO kM (fst c) && fk_ok NBF (R0F g) (kvF g) RM RO RLD kS clokF (fst c).

(* THE WALK, computed once on the real link *)
Lemma ffcheck12 : match ge12 with
  | Some g => match sx_call g NBF (R0F g) gtabF (kvF g) (xcF g) jkeys mergeF true 3000 (g0F g)
                      (Internal AIR.f_act_freefall) argsF with
              | Some cs => forallb (ffk_ok g) cs
              | None => false end
  | None => false end = true.
Proof. vm_compute. reflexivity. Qed.

Lemma dm_pas : (prog_defmap mario_step.prog) ! mario_step._perform_air_step
  = Some (Gfun (Internal mario_step.f_perform_air_step)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_sma : (prog_defmap mario.prog) ! mario._set_mario_animation
  = Some (Gfun (Internal mario.f_set_mario_animation)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_uawt : (prog_defmap AIR.prog) ! AIR._update_air_without_turn
  = Some (Gfun (Internal AIR.f_update_air_without_turn)).
Proof. vm_compute. reflexivity. Qed.
Lemma sqrtf_named_air : ext_named ((prog_defmap AIR.prog) ! AIR._sqrtf) "sqrtf" = true.
Proof. vm_compute. reflexivity. Qed.

Lemma sfun_res : forall ge id f fd, resolves_to ge id f -> sfun_lookup ge id = Some fd -> fd = Internal f.
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
Hypothesis Haudio : audio_inert.      (* LABELED OPEN PREMISE: audio, deferred *)
Hypothesis Hcamera : camera_inert.    (* LABELED OPEN PREMISE: camera, deferred *)

Variables (m0 : mem) (gp : meminj).
Hypothesis GPO : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0).
Hypothesis MC : forall ch b z v, gp b <> None -> Mem.load ch m0 b z = Some v -> val_old gp v.
Hypothesis FD : floor_data G m0.

Local Notation uf := (ufF G m0 gp).

Lemma uf_kW : forall vs, uf kW vs -> Wff G m0 gp (szs G mario._Surface) vs.
Proof. intros vs H. exact H. Qed.
Lemma uf_kH_in : forall h yv, HPi (Hit_at G m0) (ycast yv) h -> Hit_at G m0 h ->
  uf kH [Some (Vsingle h); Some yv].
Proof. intros h yv A B. cbn. split; assumption. Qed.
Lemma uf_kH_out : forall vs, uf kH vs ->
  exists h yv, vs = [Some (Vsingle h); Some yv] /\ HPi (Hit_at G m0) (ycast yv) h /\ Hit_at G m0 h.
Proof.
  intros vs H. cbn in H.
  destruct vs as [| [[| | | | h |]|] [| [yv|] [| o3 r]]]; try contradiction.
  exists h, yv. split; [reflexivity | exact H].
Qed.
Lemma uf_kS : forall vs, surf_on m0 vs -> uf kS vs.
Proof. intros vs H. exact H. Qed.
Lemma uf_kM : forall vs, MV vs -> uf kM vs.
Proof. intros vs H. exact H. Qed.
Lemma uf_kM_out : forall vs, uf kM vs -> MV vs.
Proof. intros vs H. exact H. Qed.
Lemma uf_kB : forall vs, uf kB vs ->
  exists b o o2, vs = [Some (Vptr b o); Some (Vptr b o2)] /\ Ptrofs.unsigned o + 24 <= Ptrofs.modulus.
Proof. intros vs H. exact H. Qed.

Let XSI := air_xc_sound_link lp (linked12_LO_surf lp H12) (linked12_LO_math lp H12)
             (linked12_LO_mario lp H12) NBF (R0F G) gtabF (kvF G) m0 uf gp
             RFI RMISS RCALLS kW kH kS (szs G mario._Surface) GPO eq_refl eq_refl eq_refl uf_kW uf_kH_in uf_kS.

(* THE TABLE IS SOUND on the real link *)
Theorem xcF_sound : forall id k args g cps fd E m vargs t m' vres,
  xcF G id = Some k -> k args g = Some cps -> sfun_lookup G id = Some fd ->
  MMg G NBF (R0F G) gtabF (kvF G) m0 uf gp E m g ->
  Forall2 (fun a v => den G m0 E a = Some v /\ sok NBF (g_nx g) a) args vargs ->
  eval_funcall function_entry2 G m fd vargs t m' vres ->
  exists c, In c cps /\ CM G NBF (R0F G) gtabF (kvF G) m0 uf gp E (g_nx g) (g_loc g) m' vres c.
Proof.
  intros id k args g cps fd E m vargs t m' vres Hx Hk Hl MM HA EV.
  unfold xcF in Hx. destruct (xcI G id) as [k0|] eqn:Xi.
  - injection Hx as <-. exact (XSI id k0 args g cps fd E m vargs t m' vres Xi Hk Hl MM HA EV).
  - destruct (Pos.eqb_spec id mario._set_mario_animation) as [-> | N1].
    + injection Hx as <-.
      rewrite (sfun_res _ _ _ _ (res_link lp _ _ _ (linked12_LO_mario lp H12) dm_sma) Hl) in EV.
      exact (c_sma_sound lp H12 Hdma NBF (R0F G) gtabF (kvF G) m0 uf gp GPO MC RLD RBUF RIOM RMQ RRM kB
               uf_kB args g cps E m vargs t m' vres Hk MM HA EV).
    + destruct (Pos.eqb_spec id AIR._update_air_without_turn) as [-> | N2].
      * injection Hx as <-.
        rewrite (sfun_res _ _ _ _ (res_link lp _ _ _ (linked12_LO_air lp H12) dm_uawt) Hl) in EV.
        exact (c_uawt_sound lp H12 Hsq NBF (R0F G) gtabF (kvF G) m0 uf gp GPO
                 args g cps E m vargs t m' vres Hk MM HA EV).
      * destruct (Pos.eqb_spec id mario_step._perform_air_step) as [-> | N3].
        -- injection Hx as <-.
           rewrite (sfun_res _ _ _ _ (res_link lp _ _ _ (linked12_LO_stp lp H12) dm_pas) Hl) in EV.
           exact (c_pas_sound G NBF (R0F G) gtabF (kvF G) (xcI G) (jkI G) mergef 400
                    (Internal mario_step.f_perform_air_step) RM RO kH kM m0 uf gp GPO MC XSI
                    level_update._gMarioStates eq_refl eq_refl uf_kH_out uf_kM FD
                    args g cps E m vargs t m' vres Hk MM HA EV).
        -- destruct (existsb (Pos.eqb id) (ext_ids)) eqn:Ex; [| discriminate Hx].
           injection Hx as <-.
           apply existsb_exists in Ex as (x & Ix & Ex). apply Pos.eqb_eq in Ex. subst x.
           destruct Ix as [<- | [<- | [<- | []]]].
           ++ exact (ext_fresh_sound lp H12 _ _ ps_named ps_ni Haudio NBF (R0F G) gtabF (kvF G) m0 uf gp GPO
                       args g cps fd E m vargs t m' vres Hk Hl MM EV).
           ++ exact (ext_fresh_sound lp H12 _ _ sqrtf_named_air sqrtf_ni (sqrtf_inert Hsq Hsqf)
                       NBF (R0F G) gtabF (kvF G) m0 uf gp GPO args g cps fd E m vargs t m' vres Hk Hl MM EV).
           ++ exact (ext_fresh_sound lp H12 _ _ csh_named csh_ni Hcamera NBF (R0F G) gtabF (kvF G) m0 uf gp GPO
                       args g cps fd E m vargs t m' vres Hk Hl MM EV).
Qed.

Lemma ffcheck_lp : exists cs,
  sx_call G NBF (R0F G) gtabF (kvF G) (xcF G) jkeys mergeF true 3000 (g0F G)
    (Internal AIR.f_act_freefall) argsF = Some cs
  /\ forall c, In c cs -> ffk_ok G c = true.
Proof.
  pose proof ffcheck12 as W. rewrite (ge12_ok lp H12) in W.
  exact (consume _ (ffk_ok G) W).
Qed.

Lemma pc0F_nlt : forall f, In f (pc0F G) -> fact_nlt NBF f.
Proof.
  intros f H. cbn [pc0F app ffacts In] in H.
  repeat (destruct H as [<- | H]; [cbn; repeat split; try (unfold Plt; cbn; lia); repeat constructor; unfold Plt; cbn; lia |]).
  contradiction.
Qed.

(* THE THEOREM: every execution of the real act_freefall from a memory the
   start state describes is a MoveChain of Phi's cells *)
Theorem ff_final : forall E t m' vres c0,
  env_ok G NBF (R0F G) gtabF (kvF G) m0 gp E ->
  (forall f, In f (pc0F G) -> fact_holds G (R0F G) m0 uf E f) ->
  eval_funcall function_entry2 G m0 (Internal AIR.f_act_freefall)
    [Vptr (e_blk E RM) (Ptrofs.add (e_base E RM) Ptrofs.zero)] t m' vres ->
  read_cells (e_blk E RM) m0 c0 -> budget_ok c0 ->
  FloorRefreshOK wmotr_floor (R2 (c_posy c0)) (R2 (c_floorh c0)) ->
  exists E' gs, Ext E E' NBF /\ MMg G NBF (R0F G) gtabF (kvF G) m0 uf gp E' m' gs
    /\ fk_ok NBF (R0F G) (kvF G) RM RO RLD kS clokF gs = true
    /\ exists c2, read_cells (e_blk E RM) m' c2 /\ MoveChain wmotr_floor wmotr_pole wmotr_cannon c0 c2
       /\ fro_ff c2.
Proof.
  intros E t m' vres c0 EO PC EV RC Hb FRO.
  destruct ffcheck_lp as (cs & RUN & W).
  assert (MM0 : MMg G NBF (R0F G) gtabF (kvF G) m0 uf gp E m0 (g0F G)).
  { apply MMg_init; [exact EO | apply Ple_refl |].
    intros f Hf. split; [exact (pc0F_nlt f Hf) | exact (PC f Hf)]. }
  assert (ARGS : Forall2 (fun a v => den G m0 E a = Some v /\ sok NBF (g_nx (g0F G)) a) argsF
                   [Vptr (e_blk E RM) (Ptrofs.add (e_base E RM) Ptrofs.zero)]).
  { constructor; [| constructor].
    split; [reflexivity |]. cbn [sok nlt g0F g_nx]. split; [unfold Plt, Pos.lt; reflexivity | exact Logic.I]. }
  destruct (sx_call_sound G NBF (R0F G) gtabF (kvF G) (xcF G) jkeys mergeF true m0 uf gp
              GPO MC xcF_sound 3000 (g0F G) _ argsF cs E m0 _ t m' vres RUN MM0 ARGS EV) as (c & Hin & CMc).
  destruct c as [gs r]. destruct CMc as (E' & X & MM & _).
  pose proof (W _ Hin) as OK. unfold ffk_ok in OK. cbn [fst] in OK.
  apply andb_true_iff in OK as [OK FK].
  exists E', gs. split; [exact X | split; [exact MM | split; [exact FK |]]].
  (* the entry, through E' *)
  destruct EO as (_ & _ & _ & GT & KV & _).
  destruct (GT level_update._gMarioStates RM eq_refl) as (_ & HbM & _).
  destruct (X RM ltac:(vm_compute; reflexivity)) as (BM & BaM & _).
  destruct (X RO ltac:(vm_compute; reflexivity)) as (BO & BaO & _).
  assert (HO0 : Mem.load Mint32 m0 (e_blk E' RM) oMO = Some (Vptr (e_blk E' RO) (e_base E' RO))).
  { destruct (KV RM (AirRun.fo G mario._MarioState mario._marioObj) Mint32 (Sptr RO Ptrofs.zero))
      as (_ & _ & L); [cbn [kvF]; left; reflexivity |].
    rewrite BM, BaO, BO. rewrite (proj1 (layout_lp lp H12)) in L.
    unfold addr in L. rewrite HbM, Ptrofs.unsigned_zero, Z.add_0_l in L.
    cbn [SymExec2.den] in L. rewrite Ptrofs.add_zero in L. exact L. }
  assert (Hff : c_action c0 = ACT_FREEFALL).
  { destruct (KV RM 12%Z Mint32 (Sconst (Vint (Int.repr 16779404)))) as (_ & _ & L);
      [cbn [kvF]; right; left; reflexivity |].
    unfold addr in L. rewrite HbM, Ptrofs.unsigned_zero, Z.add_0_l in L.
    destruct RC as (HA & _). change OFS_ACTION with 12%Z in HA. rewrite HA in L. cbn [den] in L.
    injection L as ->. reflexivity. }
  assert (Hact : air_entry (c_action c0) = true) by (rewrite Hff; reflexivity).
  rewrite <- BM in RC |- *.
  exact (ff_sound G NBF (R0F G) gtabF (kvF G) m0 uf gp GPO RM RO kM uf_kM_out E' m' gs MM
           ltac:(rewrite BaM; exact HbM) HO0 c0 RC Hact Hb FRO OK).
Qed.
(* the MoveChain alone *)
Theorem ff_move : forall E t m' vres c0,
  env_ok G NBF (R0F G) gtabF (kvF G) m0 gp E ->
  (forall f, In f (pc0F G) -> fact_holds G (R0F G) m0 uf E f) ->
  eval_funcall function_entry2 G m0 (Internal AIR.f_act_freefall)
    [Vptr (e_blk E RM) (Ptrofs.add (e_base E RM) Ptrofs.zero)] t m' vres ->
  read_cells (e_blk E RM) m0 c0 -> budget_ok c0 ->
  FloorRefreshOK wmotr_floor (R2 (c_posy c0)) (R2 (c_floorh c0)) ->
  exists c2, read_cells (e_blk E RM) m' c2 /\ MoveChain wmotr_floor wmotr_pole wmotr_cannon c0 c2
    /\ fro_ff c2.
Proof.
  intros E t m' vres c0 EO PC EV RC Hb FRO.
  destruct (ff_final E t m' vres c0 EO PC EV RC Hb FRO) as (_ & _ & _ & _ & _ & H). exact H.
Qed.
End LP.
