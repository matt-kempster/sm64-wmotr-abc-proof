(* ====================================================================== *)
(* THE FIVE LIFTED SURFACE BODIES, DISCHARGED (SPINE: P1' link widening,   *)
(* 2026-10-17).                                                            *)
(*                                                                        *)
(* surface_collision.prog is now IN the link (LinkedTwelve.tu_rest), so    *)
(* find_floor / find_ceil / f32_find_wall_collision / find_water_level /   *)
(* find_poison_gas_level resolve to their REAL generated bodies           *)
(* (RestSurface.rest_internal_cases, under LO_surf).  This file proves     *)
(* the gated per-body residual RestSurface.body_pres_w for each of them    *)
(* at the concrete MWF_real, from the clightgen'd ASTs (MathGeomGated /    *)
(* MathGeomBodies frames) and MWFReal's bricks -- no new rows:             *)
(*  - alloc/free keep MWF_real (mwf_real_alloc / mwf_real_free);          *)
(*  - a fresh stack local is store-safe (mwf_real_local_store: it is not   *)
(*    bm, bc, a SafeB block or any global -- all valid before the alloc);  *)
(*  - the statics gNumCalls / gNumFindFloorMisses /                        *)
(*    gFindFloorIncludeSurfaceIntangible are censused stored globals       *)
(*    (mwf_real_glob);                                                    *)
(*  - the internal helpers (find_floor_from_list, find_ceil_from_list,     *)
(*    find_wall_collisions[_from_list]) are pinned by LO_surf;            *)
(*  - every out-pointer is a Mario window cell, by the engine's call gate  *)
(*    (wgate, proved at every censused call site by CensusV2.chk_call_gate)*)
(*    and mwf_real_window.                                                *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario mario_step mario_actions_automatic surface_collision.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame Taint
  RealFrameLinked AGates CensusV2 RestSurface MWFReal SpawnInit MathGeomBodies MathGeomGated
  LocalVarsSurface OutParamSurface FloorsSurface.

Import ListNotations.

Lemma nth_vptr_nth_error : forall (l : list val) k b o,
  nth k l Vundef = Vptr b o -> nth_error l k = Some (Vptr b o).
Proof.
  induction l as [| x l IH]; intros [| k] b o H; cbn in *.
  - discriminate H.
  - discriminate H.
  - subst x. reflexivity.
  - exact (IH k b o H).
Qed.

(* the internal helpers' real bodies (closed goals: vm before any evar) *)
Lemma surf_dm_ffl :
  (prog_defmap surface_collision.prog) ! surface_collision._find_floor_from_list
    = Some (Gfun (Internal surface_collision.f_find_floor_from_list)).
Proof. vm_compute. reflexivity. Qed.
Lemma surf_dm_fcl :
  (prog_defmap surface_collision.prog) ! surface_collision._find_ceil_from_list
    = Some (Gfun (Internal surface_collision.f_find_ceil_from_list)).
Proof. vm_compute. reflexivity. Qed.
Lemma surf_dm_fwc :
  (prog_defmap surface_collision.prog) ! surface_collision._find_wall_collisions
    = Some (Gfun (Internal surface_collision.f_find_wall_collisions)).
Proof. vm_compute. reflexivity. Qed.
Lemma surf_dm_fwcl :
  (prog_defmap surface_collision.prog) ! surface_collision._find_wall_collisions_from_list
    = Some (Gfun (Internal surface_collision.f_find_wall_collisions_from_list)).
Proof. vm_compute. reflexivity. Qed.

Section SurfaceBodies.
  Variable lp : Clight.program.
  Variables bm bc : block.
  Variable oc0 : ptrofs.
  Variable SafeB : block -> Prop.

  (* MWFReal's block-distinctness side conditions -- at the capstone every
     one is DERIVED from the spawn condition (NoAImpliesNoFlyLinked). *)
  Hypothesis Hbc_bm : bc <> bm.
  Hypothesis HSafeB_not_bm : forall b, SafeB b -> b <> bm.
  Hypothesis Hgms_blk : forall gb,
      Genv.find_symbol (lp_ge lp) mario._gMarioState = Some gb ->
      gb <> bm /\ gb <> bc /\ ~ SafeB gb.
  Hypothesis Hglob_blk : forall gid bg,
      mem_id gid stored_globals = true ->
      Genv.find_symbol (lp_ge lp) gid = Some bg ->
      bg <> bm /\ bg <> bc /\ ~ SafeB bg.
  Hypothesis Hgtimer_blk : forall gb,
      Genv.find_symbol (lp_ge lp) interaction._gGlobalTimer = Some gb ->
      gb <> bm /\ gb <> bc /\ ~ SafeB gb.
  Hypothesis Htable_blk : forall tb,
      Genv.find_symbol (lp_ge lp) interaction._sInteractionHandlers = Some tb ->
      tb <> bm /\ tb <> bc /\ ~ SafeB tb.
  Hypothesis Hktab_blk : forall gid kb,
      mem_id gid knockback_table_ids = true ->
      Genv.find_symbol (lp_ge lp) gid = Some kb ->
      kb <> bm /\ kb <> bc /\ ~ SafeB kb.

  Hypothesis LO_surf : linkorder surface_collision.prog lp.

  Let MWF := MWF_real lp bm bc oc0 SafeB.

  Lemma sb_window : forall mm mm' ch (delta : Z) vv,
      MWF mm -> store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF mm'.
  Proof.
    exact (mwf_real_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm Hgms_blk
             Hgtimer_blk Htable_blk Hktab_blk).
  Qed.

  (* a fresh stack block: not bm / bc / SafeB / any global *)
  Definition fresh_local (b : block) : Prop :=
    b <> bm /\ b <> bc /\ ~ SafeB b /\
    (forall gid bg, Genv.find_symbol (lp_ge lp) gid = Some bg -> b <> bg).

  Lemma fresh_local_alloc : forall m lo hi m' b,
      Mem.alloc m lo hi = (m', b) -> MWF m -> fresh_local b.
  Proof.
    intros m lo hi m' b Ha HM.
    pose proof (Mem.fresh_block_alloc _ _ _ _ _ Ha) as Hfr.
    split; [ | split; [ | split ] ].
    - intro E. subst b. exact (Hfr (mwf_real_valid lp bm bc oc0 SafeB m HM)).
    - intro E. subst b. exact (Hfr (mwf_real_valid_bc lp bm bc oc0 SafeB m HM)).
    - intro Hs. exact (Hfr (mwf_real_safe_valid lp bm bc oc0 SafeB m HM b Hs)).
    - intros gid bg Hs E. subst b. apply Hfr.
      eapply glob_valid_of_nextbound; [ | exact Hs ].
      exact (mwf_real_nextbound lp bm bc oc0 SafeB m HM).
  Qed.

  Lemma sb_frame_oracles : frame_oracles bm MWF.
  Proof.
    split; [ | split ].
    - exact (mwf_real_alloc lp bm bc oc0 SafeB Hbc_bm).
    - exact (mwf_real_free lp bm bc oc0 SafeB Hbc_bm).
    - intros m lo hi m'' b Ha HM _.
      apply (blk_pres_local bm MWF fresh_local).
      + intros b0 (Hb & _). exact Hb.
      + intros m0 ch b0 d v m0' (Hb & Hbc & HnS & Hgl) Hst HM0.
        eapply mwf_real_local_store; eauto.
      + exact (fresh_local_alloc _ _ _ _ _ Ha HM).
  Qed.

  (* the three surface statics are censused stored globals *)
  Lemma sb_statics : forall x bg, In x ff_stat ->
      Genv.find_symbol (lp_ge lp) x = Some bg -> blk_pres not_tainted bm MWF bg.
  Proof.
    intros x bg Hin Hs.
    assert (Hmem : mem_id x stored_globals = true)
      by (destruct Hin as [<- | [<- | [<- | []]]]; vm_compute; reflexivity).
    destruct (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob_blk x Hmem bg Hs)
      as (Hne & Hst).
    exact (blk_pres_glob bm MWF bg Hne Hst).
  Qed.

  Lemma sb_statics_c : forall x bg, In x fc_stat ->
      Genv.find_symbol (lp_ge lp) x = Some bg -> blk_pres not_tainted bm MWF bg.
  Proof.
    intros x bg Hin. apply sb_statics.
    destruct Hin as [<- | []]. left. reflexivity.
  Qed.

  (* the internal helpers resolve to their real bodies *)
  Lemma sb_resolves : forall id fr,
      (prog_defmap surface_collision.prog) ! id = Some (Gfun (Internal fr)) ->
      resolves_to (lp_ge lp) id fr.
  Proof.
    intros id fr Hdm bf f Hs Hf.
    destruct (linkorder_resolves_funct lp _ id fr LO_surf Hdm) as (b' & Hs' & Hf').
    unfold lp_ge in Hs, Hf.
    rewrite Hs in Hs'. injection Hs' as <-.
    rewrite Genv.find_funct_find_funct_ptr in Hf'. congruence.
  Qed.

  (* the gate at a window-only out-param slot *)
  Lemma sb_out : forall v, owin bm 4 v ->
      exists o, v = Vptr bm o /\ out_cell not_tainted bm MWF bm o.
  Proof. exact (owin_out_cell bm MWF sb_window). Qed.

  Lemma wgate_ffc_elim : forall vargs,
      wgate bm SafeB T_ffc vargs -> owin bm 4 (nth 3 vargs Vundef).
  Proof.
    intros vargs H. unfold wgate in H.
    destruct (type_eq T_ffc T_ffc) as [_ | N]; [ exact H | exact (False_ind _ (N eq_refl)) ].
  Qed.

  Lemma wgate_f32w_elim : forall vargs,
      wgate bm SafeB T_f32w vargs ->
      owin bm 4 (nth 0 vargs Vundef) /\ owin bm 4 (nth 1 vargs Vundef)
      /\ owin bm 4 (nth 2 vargs Vundef).
  Proof.
    intros vargs H. unfold wgate in H.
    destruct (type_eq T_f32w T_ffc) as [E | _]; [ discriminate E | ].
    destruct (type_eq T_f32w T_f32w) as [_ | N]; [ exact H | exact (False_ind _ (N eq_refl)) ].
  Qed.

  (* ---- the five body_pres_w discharges ---- *)

  Lemma find_floor_pres :
    body_pres_w lp MWF bm SafeB surface_collision.f_find_floor.
  Proof.
    intros m vargs t m' vres Hg Hevf HM Hv Hsat.
    change (type_of_fundef (Internal surface_collision.f_find_floor)) with T_ffc in Hg.
    destruct (sb_out _ (wgate_ffc_elim _ Hg)) as (o & Ho & Hcell).
    exact (find_floor_body_frame_pinned (lp_ge lp) MWF bm bm o sb_frame_oracles
             sb_statics
             (sb_resolves _ _ surf_dm_ffl)
             m vargs t m' vres Hevf (nth_vptr_nth_error _ _ _ _ Ho) Hcell Hv Hsat HM).
  Qed.

  Lemma find_ceil_pres :
    body_pres_w lp MWF bm SafeB surface_collision.f_find_ceil.
  Proof.
    intros m vargs t m' vres Hg Hevf HM Hv Hsat.
    change (type_of_fundef (Internal surface_collision.f_find_ceil)) with T_ffc in Hg.
    destruct (sb_out _ (wgate_ffc_elim _ Hg)) as (o & Ho & Hcell).
    exact (find_ceil_body_frame_pinned (lp_ge lp) MWF bm bm o sb_frame_oracles
             sb_statics_c
             (sb_resolves _ _ surf_dm_fcl)
             m vargs t m' vres Hevf (nth_vptr_nth_error _ _ _ _ Ho) Hcell Hv Hsat HM).
  Qed.

  Lemma f32_find_wall_collision_pres :
    body_pres_w lp MWF bm SafeB surface_collision.f_f32_find_wall_collision.
  Proof.
    intros m vargs t m' vres Hg Hevf HM Hv Hsat.
    change (type_of_fundef (Internal surface_collision.f_f32_find_wall_collision))
      with T_f32w in Hg.
    destruct (wgate_f32w_elim _ Hg) as (Gx & Gy & Gz).
    destruct (sb_out _ Gx) as (ox & Hox & Hcx).
    destruct (sb_out _ Gy) as (oy & Hoy & Hcy).
    destruct (sb_out _ Gz) as (oz & Hoz & Hcz).
    exact (f32_find_wall_collision_body_frame_pinned (lp_ge lp) MWF bm bm bm bm
             ox oy oz sb_frame_oracles sb_statics_c
             (sb_resolves _ _ surf_dm_fwc)
             (sb_resolves _ _ surf_dm_fwcl)
             m vargs t m' vres Hevf
             (nth_vptr_nth_error _ _ _ _ Hox) (nth_vptr_nth_error _ _ _ _ Hoy)
             (nth_vptr_nth_error _ _ _ _ Hoz) Hcx Hcy Hcz Hv Hsat HM).
  Qed.

  Lemma find_water_level_pres :
    body_pres_w lp MWF bm SafeB surface_collision.f_find_water_level.
  Proof.
    intros m vargs t m' vres _ Hevf HM Hv Hsat.
    exact (find_water_level_body_frame (lp_ge lp) (fun _ => True) MWF bm
             m vargs t m' vres Hevf I HM Hv Hsat).
  Qed.

  Lemma find_poison_gas_level_pres :
    body_pres_w lp MWF bm SafeB surface_collision.f_find_poison_gas_level.
  Proof.
    intros m vargs t m' vres _ Hevf HM Hv Hsat.
    exact (find_poison_gas_level_body_frame (lp_ge lp) (fun _ => True) MWF bm
             (mwf_real_alloc lp bm bc oc0 SafeB Hbc_bm)
             (mwf_real_free lp bm bc oc0 SafeB Hbc_bm)
             m vargs t m' vres Hevf I HM Hv Hsat).
  Qed.
End SurfaceBodies.

(* ====================================================================== *)
(* CAPSTONE ROWS DISCHARGED BY THE LINK (SPINE).  With surface_collision   *)
(* in the link, four engine-callee rows that NoAImpliesNoFlyLinked used to *)
(* take as Hypotheses are now theorems about the real bodies:              *)
(*   find_floor (out-cell row), find_water_level (no-store row),          *)
(*   f32_find_wall_collision (window-or-local row), find_wall_collisions   *)
(*   (local row).                                                         *)
(* ====================================================================== *)

Lemma bind_len : forall params vargs le le',
  bind_parameter_temps params vargs le = Some le' -> length params = length vargs.
Proof.
  induction params as [| [x ty] ps IH]; intros [| v vs] le le' H; cbn in H;
    try discriminate H; cbn; [ reflexivity | f_equal; eapply IH; exact H ].
Qed.

Lemma funcall_len : forall (ge : genv) m f vargs t m' vres,
  eval_funcall function_entry2 ge m (Internal f) vargs t m' vres ->
  length vargs = length (fn_params f).
Proof.
  intros ge m f vargs t m' vres H. inv H.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
  symmetry. eapply bind_len; eassumption.
Qed.

Lemma last_val_nth : forall vs v, last_val vs = Some v ->
  nth_error vs (pred (length vs)) = Some v.
Proof.
  induction vs as [| x vs IH]; intros v H; [ discriminate H | ].
  destruct vs as [| y vs].
  - cbn in H. injection H as <-. reflexivity.
  - change (last_val (y :: vs) = Some v) in H.
    specialize (IH v H). cbn [length pred] in IH |- *. exact IH.
Qed.


(* straight-line inversion kit *)
Lemma exec_Sset_inv : forall ge e le m id a t le' m' out,
  exec_stmt function_entry2 ge e le m (Sset id a) t le' m' out ->
  out = Out_normal /\ m' = m /\ exists v, eval_expr ge e le m a v /\ le' = PTree.set id v le.
Proof. intros. inv H. eauto 6. Qed.

Lemma exec_Sassign_inv : forall ge e le m a1 a2 t le' m' out,
  exec_stmt function_entry2 ge e le m (Sassign a1 a2) t le' m' out ->
  out = Out_normal /\ le' = le.
Proof. intros. inv H. auto. Qed.

(* the head of a sequence executes; if it finishes normally the tail runs *)
Lemma exec_Sseq_inv : forall ge e le m s1 s2 t le' m' out,
  exec_stmt function_entry2 ge e le m (Ssequence s1 s2) t le' m' out ->
  exists t1 le1 m1 out1, exec_stmt function_entry2 ge e le m s1 t1 le1 m1 out1 /\
    (out1 = Out_normal -> exists t2, exec_stmt function_entry2 ge e le1 m1 s2 t2 le' m' out).
Proof.
  intros. inv H.
  - do 4 eexists. split; [ eassumption | intros _; eexists; eassumption ].
  - do 4 eexists. split; [ eassumption | intros E; congruence ].
Qed.

Lemma eval_deref_temp_ptr : forall ge e le m x ty ty' v,
  eval_expr ge e le m (Ederef (Etempvar x ty) ty') v ->
  exists b o, le ! x = Some (Vptr b o).
Proof.
  intros. inv H.
  match goal with H : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv H end.
  match goal with H : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => inv H end; eauto.
  match goal with H : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv H end.
Qed.

Lemma eval_field_deref_temp_ptr : forall ge e le m x ty ty' f fty v,
  eval_expr ge e le m (Efield (Ederef (Etempvar x ty) ty') f fty) v ->
  exists b o, le ! x = Some (Vptr b o).
Proof.
  intros. inv H.
  match goal with H : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv H end;
  match goal with H : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => apply eval_deref_temp_ptr in H; exact H end.
Qed.

Lemma find_wall_collisions_arg_ptr : forall ge m vargs t m' vres,
  eval_funcall function_entry2 ge m (Internal surface_collision.f_find_wall_collisions) vargs t m' vres ->
  exists b o, nth_error vargs 0 = Some (Vptr b o).
Proof.
  intros ge m vargs t m' vres H. inv H.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
  match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hexec end.
  cbn [fn_params fn_temps fn_body] in Hbind, Hexec.
  destruct vargs as [| a0 [| a1 vr]]; cbn [bind_parameter_temps] in Hbind;
    try discriminate Hbind.
  injection Hbind as <-.
  apply exec_Sseq_inv in Hexec as (? & ? & ? & ? & Q1 & K1).
  apply exec_Sset_inv in Q1 as (-> & -> & ? & _ & ->).
  destruct (K1 eq_refl) as (? & Q2).
  apply exec_Sseq_inv in Q2 as (? & ? & ? & ? & Q3 & _).
  apply exec_Sseq_inv in Q3 as (? & ? & ? & ? & Q4 & _).
  apply exec_Sset_inv in Q4 as (_ & _ & ? & Hev & _).
  apply eval_field_deref_temp_ptr in Hev as (b & o & Hle).
  vm_compute in Hle. injection Hle as ->. exists b, o. reflexivity.
Qed.

Lemma exec_set_assign_inv : forall ge e le m id a a1 a2 t le' m' out,
  exec_stmt function_entry2 ge e le m (Ssequence (Sset id a) (Sassign a1 a2)) t le' m' out ->
  out = Out_normal /\ exists v, eval_expr ge e le m a v /\ le' = PTree.set id v le.
Proof.
  intros. inv H.
  - match goal with H : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv H end.
    match goal with H : exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ |- _ => inv H end.
    eauto.
  - match goal with H : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv H end.
    congruence.
Qed.

Lemma f32_find_wall_collision_args_ptr : forall ge m vargs t m' vres,
  eval_funcall function_entry2 ge m
    (Internal surface_collision.f_f32_find_wall_collision) vargs t m' vres ->
  (exists b o, nth_error vargs 0 = Some (Vptr b o)) /\
  (exists b o, nth_error vargs 1 = Some (Vptr b o)) /\
  (exists b o, nth_error vargs 2 = Some (Vptr b o)).
Proof.
  intros ge m vargs t m' vres H. inv H.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
  match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hexec end.
  cbn [fn_params fn_temps fn_body] in Hbind, Hexec.
  destruct vargs as [| a0 [| a1 [| a2 [| a3 [| a4 [| a5 vr]]]]]];
    cbn [bind_parameter_temps] in Hbind; try discriminate Hbind.
  injection Hbind as <-.
  apply exec_Sseq_inv in Hexec as (? & ? & ? & ? & Q1 & K1).
  apply exec_Sset_inv in Q1 as (-> & -> & ? & _ & ->).
  destruct (K1 eq_refl) as (? & Q2).
  apply exec_Sseq_inv in Q2 as (? & ? & ? & ? & Q3 & K3).
  apply exec_Sassign_inv in Q3 as (-> & ->).
  destruct (K3 eq_refl) as (? & Q4).
  apply exec_Sseq_inv in Q4 as (? & ? & ? & ? & Q5 & K5).
  apply exec_Sassign_inv in Q5 as (-> & ->).
  destruct (K5 eq_refl) as (? & Q6).
  apply exec_Sseq_inv in Q6 as (? & ? & ? & ? & Q7 & K7).
  apply exec_set_assign_inv in Q7 as (-> & ? & Hx & ->).
  apply eval_deref_temp_ptr in Hx as (bx & ox & Hlx).
  destruct (K7 eq_refl) as (? & Q8).
  apply exec_Sseq_inv in Q8 as (? & ? & ? & ? & Q9 & K9).
  apply exec_set_assign_inv in Q9 as (-> & ? & Hy & ->).
  apply eval_deref_temp_ptr in Hy as (by_ & oy & Hly).
  destruct (K9 eq_refl) as (? & Q10).
  apply exec_Sseq_inv in Q10 as (? & ? & ? & ? & Q11 & _).
  apply exec_set_assign_inv in Q11 as (_ & ? & Hz & _).
  apply eval_deref_temp_ptr in Hz as (bz & oz & Hlz).
  vm_compute in Hlx. vm_compute in Hly. vm_compute in Hlz.
  injection Hlx as ->. injection Hly as ->. injection Hlz as ->.
  split; [ exists bx, ox | split; [ exists by_, oy | exists bz, oz ] ]; reflexivity.
Qed.

Section Rows.
  Variable lp : Clight.program.
  Variables bm bc : block.
  Variable oc0 : ptrofs.
  Variable SafeB : block -> Prop.
  Hypothesis Hbc_bm : bc <> bm.
  Hypothesis HSafeB_not_bm : forall b, SafeB b -> b <> bm.
  Hypothesis Hgms_blk : forall gb,
      Genv.find_symbol (lp_ge lp) mario._gMarioState = Some gb ->
      gb <> bm /\ gb <> bc /\ ~ SafeB gb.
  Hypothesis Hglob_blk : forall gid bg,
      mem_id gid stored_globals = true ->
      Genv.find_symbol (lp_ge lp) gid = Some bg ->
      bg <> bm /\ bg <> bc /\ ~ SafeB bg.
  Hypothesis Hgtimer_blk : forall gb,
      Genv.find_symbol (lp_ge lp) interaction._gGlobalTimer = Some gb ->
      gb <> bm /\ gb <> bc /\ ~ SafeB gb.
  Hypothesis Htable_blk : forall tb,
      Genv.find_symbol (lp_ge lp) interaction._sInteractionHandlers = Some tb ->
      tb <> bm /\ tb <> bc /\ ~ SafeB tb.
  Hypothesis Hktab_blk : forall gid kb,
      mem_id gid knockback_table_ids = true ->
      Genv.find_symbol (lp_ge lp) gid = Some kb ->
      kb <> bm /\ kb <> bc /\ ~ SafeB kb.
  Hypothesis LO_surf : linkorder surface_collision.prog lp.
  Hypothesis Hbc_sym : exists gid, Genv.find_symbol (lp_ge lp) gid = Some bc.
  Hypothesis LO_mario : linkorder mario.prog lp.

  Let MWF := MWF_real lp bm bc oc0 SafeB.
  Let NoA := fun m => ctl_a_clear m bm.

  Lemma local_out_cell : forall b o, local_blk lp bm SafeB b ->
      out_cell not_tainted bm MWF b o.
  Proof.
    intros b o Hl.
    apply (out_cell_local bm MWF (local_blk lp bm SafeB)).
    - intros b0 (Hb & _). exact Hb.
    - intros m ch b0 d v m' (Hb & HnS & Hgl) Hst HM.
      destruct Hbc_sym as (gid & Hs).
      eapply mwf_real_local_store; eauto.
    - exact Hl.
  Qed.

  Lemma Hocp_find_floor_proved :
    call_pres_ext_oc lp bm NoA MWF SafeB mario._find_floor.
  Proof.
    intros fd m0 vargs0 t0 m1 vres0 Hevf Hres (b & ofs & Hl & Hloc) _ HM Hv Hsat.
    destruct Hres as (bb & Hs & Hf).
    pose proof (resolves_pin_fd lp _ _ _ _ LO_surf surf_defmap_ff
                  (ex_intro _ bb (conj Hs Hf))) as ->.
    pose proof (funcall_len _ _ _ _ _ _ _ Hevf) as Hlen.
    apply last_val_nth in Hl. rewrite Hlen in Hl. cbn in Hl.
    destruct (find_floor_body_frame_pinned (lp_ge lp) MWF bm b ofs
                (sb_frame_oracles lp bm bc oc0 SafeB Hbc_bm)
                (sb_statics lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                (sb_resolves lp LO_surf _ _ surf_dm_ffl)
                m0 vargs0 t0 m1 vres0 Hevf Hl (local_out_cell b ofs Hloc) Hv Hsat HM)
      as (Hv' & Hs' & HM').
    exact (conj Hv' (conj Hs' (conj HM' (mwf_real_ctl lp bm bc oc0 SafeB m1 HM')))).
  Qed.

  Lemma Hxcp_fwl_proved :
    call_pres_ext lp bm NoA MWF mario_step._find_water_level.
  Proof.
    intros fd m0 vargs0 t0 m1 vres0 Hevf Hres Hno HM Hv Hsat.
    destruct Hres as (bb & Hs & Hf).
    pose proof (resolves_pin_fd lp _ _ _ _ LO_surf surf_defmap_fw
                  (ex_intro _ bb (conj Hs Hf))) as ->.
    rewrite (find_water_level_memid _ _ _ _ _ _ Hevf).
    exact (conj Hv (conj Hsat (conj HM Hno))).
  Qed.

  Lemma wol_out_cell : forall b o,
      (b = bm /\ store_window_ok (Ptrofs.unsigned o) 4 = true) \/ local_blk lp bm SafeB b ->
      out_cell not_tainted bm MWF b o.
  Proof.
    intros b o [(-> & Hw) | Hl].
    - rewrite <- (Ptrofs.repr_unsigned o).
      apply (out_cell_window bm MWF (sb_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm
               Hgms_blk Hgtimer_blk Htable_blk Hktab_blk)); [ exact Hw | ].
      pose proof (Ptrofs.unsigned_range_2 o). lia.
    - exact (local_out_cell b o Hl).
  Qed.

  Lemma Hwolcp_fwc_proved :
    call_pres_ext_wol lp bm NoA MWF SafeB mario_actions_automatic._f32_find_wall_collision.
  Proof.
    intros fd m0 vargs0 t0 m1 vres0 Hevf Hres Hwol _ HM Hv Hsat.
    destruct Hres as (bb & Hs & Hf).
    pose proof (resolves_pin_fd lp _ _ _ _ LO_surf surf_defmap_ffwc
                  (ex_intro _ bb (conj Hs Hf))) as ->.
    destruct (f32_find_wall_collision_args_ptr _ _ _ _ _ _ Hevf)
      as ((bx & ox & Hx) & (by_ & oy & Hy) & (bz & oz & Hz)).
    destruct (f32_find_wall_collision_body_frame_pinned (lp_ge lp) MWF bm bx by_ bz ox oy oz
                (sb_frame_oracles lp bm bc oc0 SafeB Hbc_bm)
                (sb_statics_c lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                (sb_resolves lp LO_surf _ _ surf_dm_fwc)
                (sb_resolves lp LO_surf _ _ surf_dm_fwcl)
                m0 vargs0 t0 m1 vres0 Hevf Hx Hy Hz
                (wol_out_cell _ _ (Hwol _ _ (nth_error_In _ _ Hx)))
                (wol_out_cell _ _ (Hwol _ _ (nth_error_In _ _ Hy)))
                (wol_out_cell _ _ (Hwol _ _ (nth_error_In _ _ Hz))) Hv Hsat HM)
      as (Hv' & Hs' & HM').
    exact (conj Hv' (conj Hs' (conj HM' (mwf_real_ctl lp bm bc oc0 SafeB m1 HM')))).
  Qed.

  Lemma Holcp_fwc_proved :
    call_pres_ext_ol lp bm NoA MWF SafeB mario._find_wall_collisions.
  Proof.
    intros fd m0 vargs0 t0 m1 vres0 Hevf Hres Hol _ HM Hv Hsat.
    destruct Hres as (bb & Hs & Hf).
    pose proof (resolves_pin_fd lp _ _ _ _ LO_surf surf_dm_fwc
                  (ex_intro _ bb (conj Hs Hf))) as ->.
    destruct (find_wall_collisions_arg_ptr _ _ _ _ _ _ Hevf) as (b & o & Hb).
    assert (Hloc : local_blk lp bm SafeB b) by exact (Hol _ _ (nth_error_In _ _ Hb)).
    assert (HB : blk_pres not_tainted bm MWF b).
    { apply (blk_pres_local bm MWF (local_blk lp bm SafeB)).
      - intros b0 (Hb0 & _). exact Hb0.
      - intros m ch b0 d v m' (Hb0 & HnS & Hgl) Hst HM0.
        destruct Hbc_sym as (gid & Hsy).
        eapply mwf_real_local_store; eauto.
      - exact Hloc. }
    destruct (find_wall_collisions_body_frame_pinned (lp_ge lp) MWF bm b o
                (sb_statics_c lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
                (sb_resolves lp LO_surf _ _ surf_dm_fwcl)
                m0 vargs0 t0 m1 vres0 Hevf Hb HB Hv Hsat HM)
      as (Hv' & Hs' & HM').
    exact (conj Hv' (conj Hs' (conj HM' (mwf_real_ctl lp bm bc oc0 SafeB m1 HM')))).
  Qed.
  (* vec3f_find_ceil(pos, h, &ceil) with ceil a caller stack local: its real
     mario.c body forwards &ceil to the real find_ceil (RestSurface.vfc_walk
     at G := local_blk), whose only store is through that local cell. *)
  Lemma Hocp_find_ceil_proved :
    call_pres_ext_oc lp bm NoA MWF SafeB mario_actions_automatic._vec3f_find_ceil.
  Proof.
    intros fd m0 vargs0 t0 m1 vres0 Hevf Hres (b & ofs & Hl & Hloc) _ HM Hv Hsat.
    pose proof (resolves_pin_fd lp _ _ _ _ LO_mario mario_defmap_vfc Hres) as ->.
    pose proof (funcall_len _ _ _ _ _ _ _ Hevf) as Hlen.
    apply last_val_nth in Hl. rewrite Hlen in Hl. cbn in Hl.
    destruct (vfc_walk lp LO_surf MWF bm (fun b _ => local_blk lp bm SafeB b)
                (mwf_real_alloc lp bm bc oc0 SafeB Hbc_bm)
                (mwf_real_free lp bm bc oc0 SafeB Hbc_bm))
      with (m := m0) (vargs := vargs0) (t := t0) (m' := m1) (vres := vres0)
      as (Hv' & Hs' & HM').
    - intros m va t m' vr (b' & o' & Hn & Hlb) Hev HM0 HV HS.
      exact (find_ceil_body_frame_pinned (lp_ge lp) MWF bm b' o'
               (sb_frame_oracles lp bm bc oc0 SafeB Hbc_bm)
               (sb_statics_c lp bm bc oc0 SafeB Hbc_bm Hglob_blk)
               (sb_resolves lp LO_surf _ _ surf_dm_fcl)
               m va t m' vr Hev (nth_vptr_nth_error _ _ _ _ Hn)
               (local_out_cell b' o' Hlb) HV HS HM0).
    - exists b, ofs. split; [ | exact Hloc ].
      destruct vargs0 as [| ? [| ? [| x ?]]]; try discriminate Hl.
      injection Hl as ->. reflexivity.
    - exact Hevf.
    - exact HM.
    - exact Hv.
    - exact Hsat.
    - exact (conj Hv' (conj Hs' (conj HM' (mwf_real_ctl lp bm bc oc0 SafeB m1 HM')))).
  Qed.
End Rows.
