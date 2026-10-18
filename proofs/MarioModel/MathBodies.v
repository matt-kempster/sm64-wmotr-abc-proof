(* ====================================================================== *)
(* THE FOUR LIFTED MATH_UTIL BODIES, DISCHARGED (SPINE: P1' math_util     *)
(* link widening, 2026-10-17).                                             *)
(*                                                                        *)
(* math_util.prog is now IN the link (LinkedTwelve.tu_rest), so the four   *)
(* engine-whitelisted ids it defines -- vec3f_set, vec3f_copy, vec3s_copy  *)
(* and atan2s -- resolve to their REAL generated bodies                    *)
(* (RestSurface.rest_internal_cases, under LO_math).  This file proves the *)
(* gated per-body residual RestSurface.body_pres_w for each of them at the *)
(* concrete MWF_real, from the clightgen'd ASTs (MathGeomGated frames) and *)
(* MWFReal's bricks -- no new rows:                                         *)
(*  - the vec writers store only through arg0, and the engine's call gate  *)
(*    (wgate: osafe, proved at every censused call site) puts arg0 in a    *)
(*    12-/6-byte-safe Mario window or a SafeB block (mwf_real_window /     *)
(*    mwf_real_chase);                                                     *)
(*  - each vec body really does need arg0 to be a pointer: it stores it    *)
(*    into its _dest shadow, reloads it, and dereferences dest+0           *)
(*    (vec_dest_ptr), so the gate's pointer case is the only case;         *)
(*  - atan2s stores nothing (its only callee, atan2_lookup, is pinned by   *)
(*    LO_math and is also store-free).                                      *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario math_util.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame Taint
  RealFrameLinked AGates CensusV2 RestSurface MWFReal SpawnInit MathGeomBodies
  MathGeomGated SurfaceBodies.

Import ListNotations.

(* ---------------------------------------------------------------------- *)
(* The vec bodies force arg0 to be a pointer.                               *)
(* ---------------------------------------------------------------------- *)

(* dest + i, dereferenced: the temp must hold a pointer *)
Lemma deref_add_temp_ptr :
  forall ge e le m tid T ii loc ofs bf,
    (T = tfloat \/ T = tshort) ->
    eval_lvalue ge e le m
      (Ederef (Ebinop Oadd (Etempvar tid (tptr T)) (Econst_int ii tint) (tptr T)) T)
      loc ofs bf ->
    exists b o, le ! tid = Some (Vptr b o).
Proof.
  intros ge e le m tid T ii loc ofs bf HT Hlv.
  inv Hlv.
  match goal with Hev : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ => inv Hev end;
    [ | match goal with Hl : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hl end ].
  match goal with H1 : eval_expr _ _ _ _ (Etempvar _ _) ?v1 |- _ =>
    apply RealFrameValue.eval_expr_Etempvar_val in H1; rename v1 into v1' end.
  match goal with H2 : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => inv H2 end;
    [ | match goal with Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv Hl end ].
  match goal with Hb : sem_binary_operation _ _ ?v1 _ _ _ _ = Some _ |- _ =>
    destruct v1; destruct HT as [-> | ->]; cbn in Hb; try discriminate Hb end;
  eauto.
Qed.

(* the shadow round trip: `dest = dest_param; t = dest;` -- if the reloaded
   temp is a pointer, the parameter was that pointer *)
Lemma shadow_reload_ptr :
  forall ge e le m T b_dest v0 tid t1 le1 m1 out1 t2 le2 m2 out2 b o,
    e ! math_util._dest = Some (b_dest, tptr T) ->
    le ! math_util._dest = Some v0 ->
    exec_stmt function_entry2 ge e le m
      (Sassign (Evar math_util._dest (tptr T)) (Etempvar math_util._dest (tptr T)))
      t1 le1 m1 out1 ->
    exec_stmt function_entry2 ge e le1 m1 (Sset tid (Evar math_util._dest (tptr T)))
      t2 le2 m2 out2 ->
    le2 ! tid = Some (Vptr b o) ->
    v0 = Vptr b o.
Proof.
  intros ge e le m T b_dest v0 tid t1 le1 m1 out1 t2 le2 m2 out2 b o
         Hed Hl0 Hassign Hset Htid.
  inv Hassign.
  match goal with Hlv : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hlv end;
    [ | match goal with Hnone : e ! math_util._dest = None |- _ =>
          rewrite Hed in Hnone; discriminate Hnone end ].
  match goal with He : e ! math_util._dest = Some (?loc, _) |- _ =>
    assert (loc = b_dest) by congruence; subst loc end.
  match goal with Hev : eval_expr _ _ _ _ (Etempvar _ _) ?v2 |- _ =>
    apply RealFrameValue.eval_expr_Etempvar_val in Hev;
    assert (v2 = v0) by congruence; subst v2 end.
  match goal with Hass : assign_loc _ _ _ _ _ Full _ _ |- _ => inv Hass end;
  [ match goal with Ham : access_mode _ = By_value _ |- _ =>
      cbn [access_mode typeof] in Ham; injection Ham as Hchunk; subst end
  | match goal with Ham : access_mode _ = By_copy |- _ =>
      cbn [access_mode typeof] in Ham; discriminate Ham end ].
  match goal with Hsv : Mem.storev _ _ _ _ = Some _ |- _ =>
    unfold Mem.storev in Hsv; rewrite Ptrofs.unsigned_zero in Hsv;
    rename Hsv into Hst end.
  inv Hset.
  rewrite PTree.gss in Htid. injection Htid as Hv3.
  match goal with Hev : eval_expr _ _ _ _ (Evar _ _) _ |- _ => inv Hev end.
  match goal with Hlv : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hlv end;
    [ | match goal with Hnone : e ! math_util._dest = None |- _ =>
          rewrite Hed in Hnone; discriminate Hnone end ].
  match goal with He : e ! math_util._dest = Some (?loc, _) |- _ =>
    assert (loc = b_dest) by congruence; subst loc end.
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end;
    try (match goal with Ham : access_mode _ = By_reference |- _ =>
           cbn in Ham; discriminate Ham end);
    try (match goal with Ham : access_mode _ = By_copy |- _ =>
           cbn in Ham; discriminate Ham end);
    try (match goal with Hlb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hlb end).
  match goal with Ham : access_mode _ = By_value _ |- _ =>
    cbn in Ham; injection Ham as Hch; subst end.
  match goal with Hld : Mem.loadv _ _ _ = Some _ |- _ =>
    unfold Mem.loadv in Hld; rewrite Ptrofs.unsigned_zero in Hld;
    rewrite (Mem.load_store_same _ _ _ _ _ _ Hst) in Hld;
    injection Hld as Hlr end.
  subst.
  match goal with Hc : sem_cast v0 _ _ _ = Some _ |- _ => rename Hc into Hcast end.
  cbv [Mptr Archi.ptr64] in *.
  destruct v0; cbn in Hcast; cbv [Archi.ptr64] in Hcast; cbn in Hcast;
    try discriminate Hcast; injection Hcast as Hcv; subst;
    cbn in Hlr; cbv [Archi.ptr64] in Hlr; cbn in Hlr; try discriminate Hlr.
  injection Hlr as -> ->. reflexivity.
Qed.

Lemma vec3f_set_dest_ptr : forall ge m vargs t m' vres,
  eval_funcall function_entry2 ge m (Internal math_util.f_vec3f_set) vargs t m' vres ->
  exists b o, hd_error vargs = Some (Vptr b o).
Proof.
  intros ge m vargs t m' vres H. inv H.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
  match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hexec end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    cbn [fn_vars] in Ha; inv Ha end.
  match goal with Ha : alloc_variables _ _ _ nil _ _ |- _ => inv Ha end.
  cbn [fn_params fn_temps fn_body] in Hbind, Hexec.
  destruct vargs as [| a0 vr]; cbn [bind_parameter_temps] in Hbind;
    [ discriminate Hbind | ].
  destruct vr as [| a1 [| a2 [| a3 [| a4 vr]]]]; cbn [bind_parameter_temps] in Hbind;
    try discriminate Hbind.
  injection Hbind as <-.
  apply exec_Sseq_inv in Hexec as (? & ? & ? & ? & Q1 & K1).
  pose proof Q1 as Q1'.
  apply exec_Sassign_inv in Q1' as (-> & ->).
  destruct (K1 eq_refl) as (? & Q2).
  apply exec_Sseq_inv in Q2 as (? & ? & ? & ? & Q3 & _).
  apply exec_Sseq_inv in Q3 as (? & ? & ? & ? & Q4 & K4).
  pose proof Q4 as Q4'.
  apply exec_Sset_inv in Q4' as (-> & -> & ? & _ & ->).
  destruct (K4 eq_refl) as (? & Q5).
  inv Q5.
  match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ =>
    destruct (deref_add_temp_ptr _ _ _ _ _ _ _ _ _ _ (or_introl eq_refl) Hl)
      as (b & o & Hb) end.
  exists b, o. cbn [hd_error]. f_equal.
  eapply shadow_reload_ptr; [ apply PTree.gss | | exact Q1 | exact Q4 | exact Hb ].
  reflexivity.
Qed.

Lemma vec_copy_dest_ptr : forall ge m f vargs t m' vres T,
  (T = tfloat \/ T = tshort) ->
  (f = math_util.f_vec3f_copy /\ T = tfloat \/ f = math_util.f_vec3s_copy /\ T = tshort) ->
  eval_funcall function_entry2 ge m (Internal f) vargs t m' vres ->
  exists b o, hd_error vargs = Some (Vptr b o).
Proof.
  intros ge m f vargs t m' vres T HT Hf H.
  destruct Hf as [[-> ->] | [-> ->]]; clear HT; inv H;
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end;
  match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind end;
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hexec end;
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    cbn [fn_vars] in Ha; inv Ha end;
  match goal with Ha : alloc_variables _ _ _ nil _ _ |- _ => inv Ha end;
  cbn [fn_params fn_temps fn_body] in Hbind, Hexec;
  (destruct vargs as [| a0 vr]; cbn [bind_parameter_temps] in Hbind;
    [ discriminate Hbind | ]);
  (destruct vr as [| a1 [| a2 vr]]; cbn [bind_parameter_temps] in Hbind;
    try discriminate Hbind);
  injection Hbind as <-;
  apply exec_Sseq_inv in Hexec as (? & ? & ? & ? & Q1 & K1);
  pose proof Q1 as Q1';
  apply exec_Sassign_inv in Q1' as (-> & ->);
  destruct (K1 eq_refl) as (? & Q2);
  apply exec_Sseq_inv in Q2 as (? & ? & ? & ? & Q3 & _);
  apply exec_Sseq_inv in Q3 as (? & ? & ? & ? & Q4 & K4);
  pose proof Q4 as Q4';
  apply exec_Sset_inv in Q4' as (-> & -> & ? & _ & ->);
  destruct (K4 eq_refl) as (? & Q5);
  apply exec_Sseq_inv in Q5 as (? & ? & ? & ? & Q6 & K6);
  pose proof Q6 as Q6';
  apply exec_Sset_inv in Q6' as (-> & -> & ? & _ & ->);
  destruct (K6 eq_refl) as (? & Q7);
  inv Q7;
  match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ =>
    first [ destruct (deref_add_temp_ptr _ _ _ _ _ _ _ _ _ _ (or_introl eq_refl) Hl)
              as (b & o & Hb)
          | destruct (deref_add_temp_ptr _ _ _ _ _ _ _ _ _ _ (or_intror eq_refl) Hl)
              as (b & o & Hb) ] end;
  rewrite PTree.gso in Hb by (cbv; discriminate);
  exists b, o; cbn [hd_error]; f_equal;
  (eapply shadow_reload_ptr; [ apply PTree.gss | | exact Q1 | exact Q4 | exact Hb ]);
  reflexivity.
Qed.

(* the math_util helper atan2s calls *)
Lemma math_dm_atan2_lookup :
  (prog_defmap math_util.prog) ! math_util._atan2_lookup
    = Some (Gfun (Internal math_util.f_atan2_lookup)).
Proof. vm_compute. reflexivity. Qed.

Section MathBodies.
  Variable lp : Clight.program.
  Variables bm bc : block.
  Variable oc0 : ptrofs.
  Variable SafeB : block -> Prop.

  Hypothesis Hbc_bm : bc <> bm.
  Hypothesis HSafeB_not_bm : forall b, SafeB b -> b <> bm.
  Hypothesis HSafeB_not_bc : ~ SafeB bc.
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

  Hypothesis LO_math : linkorder math_util.prog lp.

  Let MWF := MWF_real lp bm bc oc0 SafeB.

  Let mb_window := sb_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm Hgms_blk
                     Hgtimer_blk Htable_blk Hktab_blk.
  Let mb_oracles := sb_frame_oracles lp bm bc oc0 SafeB Hbc_bm.

  Lemma mb_chase : forall mm ch bsafe (d : Z) vv mm',
      MWF mm -> SafeB bsafe ->
      (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store ch mm bsafe d vv = Some mm' -> MWF mm'.
  Proof.
    exact (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm HSafeB_not_bc
             Hgms_blk Hgtimer_blk Htable_blk Hktab_blk).
  Qed.

  (* an osafe destination is valid: bm, or a SafeB block *)
  Lemma mb_out_valid : forall n m b o,
      MWF m -> osafe bm SafeB n (Vptr b o) -> Mem.valid_block m b.
  Proof.
    intros n m b o HM Hg.
    destruct (Hg b o eq_refl) as [[-> _] | Hs].
    - exact (mwf_real_valid lp bm bc oc0 SafeB m HM).
    - exact (mwf_real_safe_valid lp bm bc oc0 SafeB m HM b Hs).
  Qed.

  Lemma wgate_v3fset_elim : forall vargs,
      wgate bm SafeB T_v3fset vargs -> osafe bm SafeB 12 (nth 0 vargs Vundef).
  Proof.
    intros vargs H. unfold wgate in H.
    destruct (type_eq T_v3fset T_ffc) as [E | _]; [ discriminate E | ].
    destruct (type_eq T_v3fset T_f32w) as [E | _]; [ discriminate E | ].
    destruct (type_eq T_v3fset T_v3fcopy) as [E | _]; [ discriminate E | ].
    destruct (type_eq T_v3fset T_v3fset) as [_ | N]; [ exact H | exact (False_ind _ (N eq_refl)) ].
  Qed.

  Lemma wgate_v3fcopy_elim : forall vargs,
      wgate bm SafeB T_v3fcopy vargs -> osafe bm SafeB 12 (nth 0 vargs Vundef).
  Proof.
    intros vargs H. unfold wgate in H.
    destruct (type_eq T_v3fcopy T_ffc) as [E | _]; [ discriminate E | ].
    destruct (type_eq T_v3fcopy T_f32w) as [E | _]; [ discriminate E | ].
    destruct (type_eq T_v3fcopy T_v3fcopy) as [_ | N]; [ exact H | exact (False_ind _ (N eq_refl)) ].
  Qed.

  Lemma wgate_v3scopy_elim : forall vargs,
      wgate bm SafeB T_v3scopy vargs -> osafe bm SafeB 6 (nth 0 vargs Vundef).
  Proof.
    intros vargs H. unfold wgate in H.
    destruct (type_eq T_v3scopy T_ffc) as [E | _]; [ discriminate E | ].
    destruct (type_eq T_v3scopy T_f32w) as [E | _]; [ discriminate E | ].
    destruct (type_eq T_v3scopy T_v3fcopy) as [E | _]; [ discriminate E | ].
    destruct (type_eq T_v3scopy T_v3fset) as [E | _]; [ discriminate E | ].
    destruct (type_eq T_v3scopy T_v3scopy) as [_ | N]; [ exact H | exact (False_ind _ (N eq_refl)) ].
  Qed.

  Lemma hd_nth0 : forall (l : list val) v, hd_error l = Some v -> nth 0 l Vundef = v.
  Proof. intros [| x l] v H; cbn in *; [ discriminate H | congruence ]. Qed.

  (* ---- the four body_pres_w discharges ---- *)

  Lemma vec3f_set_pres :
    body_pres_w lp MWF bm SafeB math_util.f_vec3f_set.
  Proof.
    intros m vargs t m' vres Hg Hevf HM Hv Hsat.
    change (type_of_fundef (Internal math_util.f_vec3f_set)) with T_v3fset in Hg.
    apply wgate_v3fset_elim in Hg.
    destruct (vec3f_set_dest_ptr _ _ _ _ _ _ Hevf) as (b & o & Hhd).
    rewrite (hd_nth0 _ _ Hhd) in Hg.
    exact (vec3f_set_body_frame_B (lp_ge lp) MWF bm b o mb_oracles
             m vargs t m' vres Hevf Hhd
             (osafe_vec_out bm MWF SafeB mb_window HSafeB_not_bm mb_chase
                12 Mfloat32 _ b o ltac:(cbn; lia) Hg eq_refl)
             (mb_out_valid _ _ _ _ HM Hg) Hv Hsat HM).
  Qed.

  Lemma vec3f_copy_pres :
    body_pres_w lp MWF bm SafeB math_util.f_vec3f_copy.
  Proof.
    intros m vargs t m' vres Hg Hevf HM Hv Hsat.
    change (type_of_fundef (Internal math_util.f_vec3f_copy)) with T_v3fcopy in Hg.
    apply wgate_v3fcopy_elim in Hg.
    destruct (vec_copy_dest_ptr _ _ _ _ _ _ _ tfloat (or_introl eq_refl)
                (or_introl (conj eq_refl eq_refl)) Hevf) as (b & o & Hhd).
    rewrite (hd_nth0 _ _ Hhd) in Hg.
    exact (vec3f_copy_body_frame_B (lp_ge lp) MWF bm b o mb_oracles
             m vargs t m' vres Hevf Hhd
             (osafe_vec_out bm MWF SafeB mb_window HSafeB_not_bm mb_chase
                12 Mfloat32 _ b o ltac:(cbn; lia) Hg eq_refl)
             (mb_out_valid _ _ _ _ HM Hg) Hv Hsat HM).
  Qed.

  Lemma vec3s_copy_pres :
    body_pres_w lp MWF bm SafeB math_util.f_vec3s_copy.
  Proof.
    intros m vargs t m' vres Hg Hevf HM Hv Hsat.
    change (type_of_fundef (Internal math_util.f_vec3s_copy)) with T_v3scopy in Hg.
    apply wgate_v3scopy_elim in Hg.
    destruct (vec_copy_dest_ptr _ _ _ _ _ _ _ tshort (or_intror eq_refl)
                (or_intror (conj eq_refl eq_refl)) Hevf) as (b & o & Hhd).
    rewrite (hd_nth0 _ _ Hhd) in Hg.
    exact (vec3s_copy_body_frame_B (lp_ge lp) MWF bm b o mb_oracles
             m vargs t m' vres Hevf Hhd
             (osafe_vec_out bm MWF SafeB mb_window HSafeB_not_bm mb_chase
                6 Mint16signed _ b o ltac:(cbn; lia) Hg eq_refl)
             (mb_out_valid _ _ _ _ HM Hg) Hv Hsat HM).
  Qed.

  Lemma mb_resolves : forall id fr,
      (prog_defmap math_util.prog) ! id = Some (Gfun (Internal fr)) ->
      resolves_to (lp_ge lp) id fr.
  Proof.
    intros id fr Hdm bf f Hs Hf.
    destruct (linkorder_resolves_funct lp _ id fr LO_math Hdm) as (b' & Hs' & Hf').
    unfold lp_ge in Hs, Hf.
    rewrite Hs in Hs'. injection Hs' as <-.
    rewrite Genv.find_funct_find_funct_ptr in Hf'. congruence.
  Qed.

  Lemma atan2s_pres :
    body_pres_w lp MWF bm SafeB math_util.f_atan2s.
  Proof.
    intros m vargs t m' vres _ Hevf HM Hv Hsat.
    exact (atan2s_body_frame_pinned (lp_ge lp) MWF bm
             (mb_resolves _ _ math_dm_atan2_lookup)
             m vargs t m' vres Hevf HM Hv Hsat).
  Qed.
End MathBodies.
