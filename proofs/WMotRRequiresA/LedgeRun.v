(* ====================================================================== *)
(* LedgeRun (GOAL 2): the ledge cases of the automatic dispatcher, walked *)
(* on the link.                                                            *)
(*                                                                        *)
(* act_ledge_grab / act_ledge_climb_down (mario_actions_automatic.c) read *)
(* Mario's floor, ceiling and input, may let go of the ledge              *)
(* (let_go_of_ledge: find_floor behind Mario, pos[1] down by 100 or onto  *)
(* that floor, SOFT_BONK, TRUE), switch into a climb (TRUE, pos[1] kept), *)
(* or snap pos[1] to floorHeight (stop_and_set_height_to_floor) and set   *)
(* an animation (FALSE).  The walker's config is KbRun's (the action cell *)
(* = the case's constant; m->input's A bits clear prune the A-gated       *)
(* climb) plus:                                                            *)
(*   - find_floor with the height fact kL (PoleXc.c_ff2: HPi of the       *)
(*     result, so a missed floor is -11000 or bounded);                    *)
(*   - is_anim_at_end (memory unchanged, an int) and play_sound (audio).   *)
(* Each outcome passes LedgeClass.ledge_ok, FfKeepCheck.fk_ok and either   *)
(* RetOk.ret_ok or the let-go shape (LedgeClass.letgo_ok).                 *)
(* ====================================================================== *)

From Coq Require Import List ZArith Reals Lra Relations.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Events Globalenvs
  Ctypes Clight ClightBigstep.
From SM64.Generated Require mario_step mario mario_actions_airborne mario_actions_automatic memory
  surface_collision level_update.
From SM64.Proofs Require Import Interp.SymExec2 Interp.LinkGenv MarioModel.LinkedTwelve
  MarioModel.OsDmaFloor MarioModel.MathGeomGated HeightInvariant HeightMoveCatalog WMotRLevel WMotRWorld.
From SM64.Proofs.WMotRRequiresA Require Import FloorHeight FloorExec AirXc AirRun AirMatch SmaXc
  ExtInert FfClass AirStart FfKeepCheck RetOk FfRun AhwRun KbRun WithGe PoleXc PoleRun FfWorld HeightBudgetArith LedgeClass.
Import ListNotations.

Module AUT := mario_actions_automatic.

Section CFG.
Variable acn : Z.
Variable g : genv.
Definition xcL (id : ident) : option xcontract :=
  if Pos.eqb id mario._find_floor
  then Some (c_ff2 NBF (R0F g) RFI RMISS RCALLS kW kH kS kL (szs g mario._Surface))
  else match xcI g id with
  | Some k => Some k
  | None =>
    if Pos.eqb id mario._set_mario_animation then Some (c_sma NBF (R0F g) gtabF (kvK acn g) RLD RBUF RIOM RMQ RRM kB) else
    if Pos.eqb id mario._is_anim_at_end then Some xc_fresh else
    if Pos.eqb id AUT._play_sound then Some xc_fresh else None
  end.

(* the consumer facts' meaning: FfRun's, and kL *)
Definition ufL (m0 : mem) (gp : meminj) : positive -> list (option val) -> Prop :=
  fun k vs =>
    if Pos.eqb k kL then
      match vs with
      | [Some (Vsingle h); Some yv] => HPi (Hit_at g m0) (ycast yv) h
      | _ => False
      end
    else ufF g m0 gp k vs.
End CFG.

(* each outcome: the move class, the kept world, the return (FALSE / the
   two cells kept, or the let-go) *)
Definition lk_ok (acn : Z) (g : genv) (c : cpath) : bool :=
  ledge_ok NBF (R0F g) (kvK acn g) RM RO kH kL (fst c)
  && fk_ok NBF (R0F g) (kvK acn g) RM RO RLD kS clokF (fst c)
  && (ret_ok NBF (R0F g) (kvK acn g) RM c || letgo_ok NBF (R0F g) (kvK acn g) RM kH kL (fst c)).

Definition ledge_walk (acn : Z) (f : function) : bool :=
  with_ge ge12 false (fun g =>
    match sx_call g NBF (R0F g) gtabF (kvK acn g) (xcL acn g) jkeys mergeK true 3000 (g0F g)
            (Internal f) argsF with
    | Some cs => forallb (lk_ok acn g) cs
    | None => false end).

(* let_go_of_ledge's outcome: SOFT_BONK, floorHeight kept, pos[1] at most
   101 below the entry's (y - 100.0f rounded, or a floor not below it) *)
Definition LETGO (bm : block) (m0 m' : mem) : Prop :=
  exists y0 y', Mem.load Mfloat32 m0 bm OFS_POSY = Some (Vsingle y0)
    /\ Mem.load Mfloat32 m' bm OFS_POSY = Some (Vsingle y')
    /\ Mem.load Mfloat32 m' bm OFS_FLOORH = Mem.load Mfloat32 m0 bm OFS_FLOORH
    /\ Mem.load Mint32 m' bm 12 = Some (Vint (Int.repr SB_ACT))
    /\ (R2 y0 - 101 <= R2 y')%R.

(* the let-go leaves the floor fresh: the entry's floor was within the
   slack (y + 140), the drop is at most 101, and the outcome is SOFT_BONK *)
Lemma letgo_fresh : forall bm m m' acn,
  Mem.load Mint32 m bm 12 = Some (Vint (Int.repr acn)) ->
  Int.eq (Int.repr acn) (Int.repr SB_ACT) = false ->
  fresh bm m -> LETGO bm m m' -> fresh bm m'.
Proof.
  intros bm m m' acn La N F (y0 & y' & Ly0 & Ly' & Lf & Lsb & Dy).
  intros y fh Ly Lfh. rewrite Ly' in Ly. injection Ly as <-.
  rewrite Lf in Lfh.
  destruct (F y0 fh Ly0 Lfh) as (FRO & [S | [S | S]]).
  - rewrite La in S. assert (S2 : Int.repr acn = Int.repr SB_ACT) by congruence. rewrite S2, Int.eq_true in N. discriminate N.
  - split; [left; exact S | left; exact Lsb].
  - split; [| left; exact Lsb].
    destruct FRO as [Z | (W & _)]; [left; exact Z | right; split; [exact W |]].
    unfold FRESH_SLACK in S. unfold STEP_UP. lra.
Qed.

(* the walk theorem's statement, for a ledge handler on the link: kfinal's
   premises; the walk's world (with ufL), the kept world, RET or the
   let-go, and one RangedMove *)
Definition lfinal (lp : Clight.program) (acn : Z) (fK : function) : Prop :=
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
         (ufL (globalenv lp) m0 gp) gp E' m' gs
    /\ fk_ok NBF (R0F (globalenv lp)) (kvK acn (globalenv lp)) RM RO RLD kS clokF gs = true
    /\ (RET (e_blk E RM) m0 m' vres \/ LETGO (e_blk E RM) m0 m')
    /\ exists c2, read_cells (e_blk E RM) m' c2 /\ MoveChain wmotr_floor wmotr_pole wmotr_cannon c0 c2.

Section LP.
Variable lp : Clight.program.
Hypothesis H12 : linked12 lp.
Local Notation G := (globalenv lp).
Hypothesis Hdma : os_dma_floor.
Hypothesis Haudio : audio_inert.      (* LABELED OPEN PREMISE: audio, deferred *)

Variable acn : Z.
Variable fK : function.
Hypothesis Hwalk : ledge_walk acn fK = true.
Hypothesis Hacn : In acn LEDGE_IN.

Variables (m0 : mem) (gp : meminj).
Hypothesis GPO : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0).
Hypothesis MC : forall ch b z v, gp b <> None -> Mem.load ch m0 b z = Some v -> val_old gp v.
Hypothesis FD : floor_data G m0.

Local Notation uf := (ufL G m0 gp).

Lemma ufL_kW : forall vs, uf kW vs -> Wff G m0 gp (szs G mario._Surface) vs.
Proof. intros vs H. exact H. Qed.
Lemma ufL_kH_in : forall h yv, HPi (Hit_at G m0) (ycast yv) h -> Hit_at G m0 h ->
  uf kH [Some (Vsingle h); Some yv].
Proof. intros h yv A B. cbn. split; assumption. Qed.
Lemma ufL_kS : forall vs, surf_on m0 vs -> uf kS vs.
Proof. intros vs H. exact H. Qed.
Lemma ufL_kB : forall vs, uf kB vs ->
  exists b o o2, vs = [Some (Vptr b o); Some (Vptr b o2)] /\ Ptrofs.unsigned o + 24 <= Ptrofs.modulus.
Proof. intros vs H. exact H. Qed.
Lemma ufL_kL_in : forall h yv, HPi (Hit_at G m0) (ycast yv) h -> uf kL [Some (Vsingle h); Some yv].
Proof. intros h yv A. exact A. Qed.
Lemma ufL_kH_out : forall vs, uf kH vs -> exists h yv, vs = [Some (Vsingle h); Some yv]
                                               /\ HPi (Hit_at G m0) (ycast yv) h.
Proof.
  intros vs H. cbn in H.
  destruct vs as [| [[| | | | h |]|] [| [yv|] [| o3 r]]]; try contradiction.
  exists h, yv. split; [reflexivity | exact (proj1 H)].
Qed.
Lemma ufL_kL_out : forall vs, uf kL vs -> exists h yv, vs = [Some (Vsingle h); Some yv]
                                               /\ HPi (Hit_at G m0) (ycast yv) h.
Proof.
  intros vs H. cbn in H.
  destruct vs as [| [[| | | | h |]|] [| [yv|] [| o3 r]]]; try contradiction.
  exists h, yv. split; [reflexivity | exact H].
Qed.

Let XSI := air_xc_sound_link lp (linked12_LO_surf lp H12) (linked12_LO_math lp H12)
             (linked12_LO_mario lp H12) NBF (R0F G) gtabF (kvK acn G) m0 uf gp
             RFI RMISS RCALLS kW kH kS (szs G mario._Surface) GPO eq_refl eq_refl eq_refl
             ufL_kW ufL_kH_in ufL_kS.

(* THE TABLE IS SOUND on the real link *)
Theorem xcL_sound : forall id k args g cps fd E m vargs t m' vres,
  xcL acn G id = Some k -> k args g = Some cps -> sfun_lookup G id = Some fd ->
  MMg G NBF (R0F G) gtabF (kvK acn G) m0 uf gp E m g ->
  Forall2 (fun a v => den G m0 E a = Some v /\ sok NBF (g_nx g) a) args vargs ->
  eval_funcall function_entry2 G m fd vargs t m' vres ->
  exists c, In c cps /\ CM G NBF (R0F G) gtabF (kvK acn G) m0 uf gp E (g_nx g) (g_loc g) m' vres c.
Proof.
  intros id k args g cps fd E m vargs t m' vres Hx Hk Hl MM HA EV.
  unfold xcL in Hx.
  destruct (Pos.eqb_spec id mario._find_floor) as [-> | N0].
  { injection Hx as <-.
    rewrite (sfun_res_h _ _ _ _ (res_link lp _ _ _ (linked12_LO_surf lp H12) dm_ff) Hl) in EV.
    exact (c_ff2_sound G NBF (R0F G) gtabF (kvK acn G) m0 uf gp GPO RFI RMISS RCALLS kW kH kS kL
             (szs G mario._Surface) (cenv_has_link lp (linked12_LO_surf lp H12))
             (res_link lp _ _ _ (linked12_LO_surf lp H12) dm_ffl) eq_refl eq_refl eq_refl
             ufL_kW ufL_kS ufL_kH_in ufL_kL_in args g cps E m vargs t m' vres Hk MM HA EV). }
  destruct (xcI G id) as [k0|] eqn:Xi.
  - injection Hx as <-. exact (XSI id k0 args g cps fd E m vargs t m' vres Xi Hk Hl MM HA EV).
  - destruct (Pos.eqb_spec id mario._set_mario_animation) as [-> | N1].
    + injection Hx as <-.
      rewrite (sfun_res_h _ _ _ _ (res_link lp _ _ _ (linked12_LO_mario lp H12) dm_sma_h) Hl) in EV.
      exact (c_sma_sound lp H12 Hdma NBF (R0F G) gtabF (kvK acn G) m0 uf gp GPO MC RLD RBUF RIOM RMQ RRM kB
               ufL_kB args g cps E m vargs t m' vres Hk MM HA EV).
    + destruct (Pos.eqb_spec id mario._is_anim_at_end) as [-> | N2].
      * injection Hx as <-.
        rewrite (sfun_res_h _ _ _ _ (res_link lp _ _ _ (linked12_LO_mario lp H12) dm_iae) Hl) in EV.
        destruct (anim_end_value_contract _ _ _ _ _ _ EV) as (-> & i & ->).
        exact (xc_fresh_sound G NBF (R0F G) gtabF (kvK acn G) (fun _ => None) (fun _ => false) m0 uf gp
                 E m g (Vint i) args cps Hk MM I).
      * destruct (Pos.eqb_spec id AUT._play_sound) as [-> | N3]; [| discriminate Hx].
        injection Hx as <-. rewrite ps_aut in Hl.
        exact (ext_fresh_sound lp H12 _ _ ps_named ps_ni (audio_ps Haudio) NBF (R0F G) gtabF (kvK acn G) m0 uf gp GPO
                 args g cps fd E m vargs t m' vres Hk Hl MM EV).
Qed.

Lemma ledgecheck_lp : exists cs,
  sx_call G NBF (R0F G) gtabF (kvK acn G) (xcL acn G) jkeys mergeK true 3000 (g0F G)
    (Internal fK) argsF = Some cs
  /\ forall c, In c cs -> lk_ok acn G c = true.
Proof.
  pose proof Hwalk as W. unfold ledge_walk, with_ge in W. rewrite (ge12_ok lp H12) in W.
  exact (consume _ (lk_ok acn G) W).
Qed.

(* THE THEOREM: every execution of the ledge handler from a memory the
   start state describes keeps the world (fk_ok), returns FALSE with the
   two cells kept or lets go of the ledge, and moves Phi's cells by one
   RangedMove *)
Theorem ledge_final : forall E t m' vres c0,
  env_ok G NBF (R0F G) gtabF (kvK acn G) m0 gp E ->
  (forall f, In f (pc0F G) -> fact_holds G (R0F G) m0 (ufF G m0 gp) E f) ->
  eval_funcall function_entry2 G m0 (Internal fK)
    [Vptr (e_blk E RM) (Ptrofs.add (e_base E RM) Ptrofs.zero)] t m' vres ->
  read_cells (e_blk E RM) m0 c0 -> budget_ok c0 ->
  FloorRefreshOK wmotr_floor (R2 (c_posy c0)) (R2 (c_floorh c0)) ->
  exists E' gs, Ext E E' NBF /\ MMg G NBF (R0F G) gtabF (kvK acn G) m0 uf gp E' m' gs
    /\ fk_ok NBF (R0F G) (kvK acn G) RM RO RLD kS clokF gs = true
    /\ (RET (e_blk E RM) m0 m' vres \/ LETGO (e_blk E RM) m0 m')
    /\ exists c2, read_cells (e_blk E RM) m' c2 /\ MoveChain wmotr_floor wmotr_pole wmotr_cannon c0 c2.
Proof.
  intros E t m' vres c0 EO PC EV RC Hb FRO.
  destruct ledgecheck_lp as (cs & RUN & W).
  assert (PCL : forall f, In f (pc0F G) -> fact_holds G (R0F G) m0 uf E f).
  { intros f Hf. pose proof (PC f Hf) as H. cbn [pc0F app ffacts In] in Hf.
    repeat (destruct Hf as [<- | Hf]; [exact H |]). contradiction. }
  assert (MM0 : MMg G NBF (R0F G) gtabF (kvK acn G) m0 uf gp E m0 (g0F G)).
  { apply MMg_init; [exact EO | apply Ple_refl |].
    intros f Hf. split; [exact (pc0F_nlt_k lp f Hf) | exact (PCL f Hf)]. }
  assert (ARGS : Forall2 (fun a v => den G m0 E a = Some v /\ sok NBF (g_nx (g0F G)) a) argsF
                   [Vptr (e_blk E RM) (Ptrofs.add (e_base E RM) Ptrofs.zero)]).
  { constructor; [| constructor].
    split; [reflexivity |]. cbn [sok nlt g0F g_nx]. split; [unfold Plt, Pos.lt; reflexivity | exact Logic.I]. }
  destruct (sx_call_sound G NBF (R0F G) gtabF (kvK acn G) (xcL acn G) jkeys mergeK true m0 uf gp
              GPO MC xcL_sound 3000 (g0F G) _ argsF cs E m0 _ t m' vres RUN MM0 ARGS EV) as (c & Hin & CMc).
  destruct c as [gs r]. destruct CMc as (E' & X & MM & DR & _).
  pose proof (W _ Hin) as OK. unfold lk_ok in OK. cbn [fst] in OK.
  apply andb_true_iff in OK as [OK RT]. apply andb_true_iff in OK as [LO FK].
  exists E', gs. split; [exact X | split; [exact MM | split; [exact FK |]]].
  destruct EO as (_ & _ & _ & GT & KV & _).
  destruct (GT level_update._gMarioStates RM eq_refl) as (_ & HbM & _).
  destruct (X RM ltac:(vm_compute; reflexivity)) as (BM & BaM & _).
  destruct (X RO ltac:(vm_compute; reflexivity)) as (BO & BaO & _).
  assert (HbM' : e_base E' RM = Ptrofs.zero) by (rewrite BaM; exact HbM).
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
  assert (Hacn0 : exists z, In z LEDGE_IN /\ c_action c0 = Int.repr z)
    by (exists acn; split; [exact Hacn | exact Hact0]).
  rewrite <- BM in RC |- *.
  split.
  - apply orb_true_iff in RT as [RT | RT].
    + left. exact (ret_sound G NBF (R0F G) gtabF (kvK acn G) m0 uf gp GPO RM E' m' gs MM HbM' r vres DR RT).
    + right.
      destruct (letgo_sound G NBF (R0F G) gtabF (kvK acn G) m0 uf gp GPO RM kH kL ufL_kH_out ufL_kL_out FD
                  E' m' gs MM HbM' c0 RC Hb RT) as (y' & LY & LF & LA & Low).
      destruct RC as (_ & _ & _ & Y0 & _).
      exists (c_posy c0), y'. split; [exact Y0 |]. split; [exact LY |]. split; [exact LF |].
      split; [exact LA | exact Low].
  - destruct (ledge_sound G NBF (R0F G) gtabF (kvK acn G) m0 uf gp GPO RM RO kH kL ufL_kH_out ufL_kL_out FD
                E' m' gs MM HbM' c0 RC Hb Hacn0 FRO HO0 LO) as (c2 & RC2 & RM2).
    exists c2. split; [exact RC2 |]. apply rt_step. exact RM2.
Qed.
End LP.

Lemma ledge_lfinal : forall lp, linked12 lp -> os_dma_floor -> audio_inert ->
  forall acn fK, ledge_walk acn fK = true -> In acn LEDGE_IN -> lfinal lp acn fK.
Proof.
  intros lp H12 Hdma Ha acn fK Hw Hacn m0 gp GPO MC FD.
  exact (ledge_final lp H12 Hdma Ha acn fK Hw Hacn m0 gp GPO MC FD).
Qed.

Lemma in_ledge_in : forall z, existsb (Z.eqb z) LEDGE_IN = true -> In z LEDGE_IN.
Proof.
  intros z H. apply existsb_exists in H as (x & Hx & E). apply Z.eqb_eq in E. subst. exact Hx.
Qed.
