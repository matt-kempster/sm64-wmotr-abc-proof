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
From SM64.Generated Require mario math_util mario_actions_automatic.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame Taint
  RealFrameLinked AGates CensusV2 RestSurface MWFReal SpawnInit MathGeomBodies
  MathGeomGated SurfaceBodies OutParamSurface LocalVarsSurface FloorsSurface.

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

(* ---------------------------------------------------------------------- *)
(* The vec bodies' destination is a block that was ALREADY valid at the     *)
(* call: it cannot be the body's own fresh _dest shadow, because the first  *)
(* element store would clobber the saved pointer and the second element's  *)
(* reload + dereference would fail.  (The rows' stack-local gate carries no  *)
(* validity of its own; this is where it comes from.)                       *)
(* ---------------------------------------------------------------------- *)

Lemma shadow_assign_store :
  forall ge e le m T bb v0 t le' m' out,
    e ! math_util._dest = Some (bb, tptr T) ->
    le ! math_util._dest = Some v0 ->
    exec_stmt function_entry2 ge e le m
      (Sassign (Evar math_util._dest (tptr T)) (Etempvar math_util._dest (tptr T)))
      t le' m' out ->
    le' = le /\ out = Out_normal /\ exists v', Mem.store Mptr m bb 0 v' = Some m'.
Proof.
  intros ge e le m T bb v0 t le' m' out Hed Hl0 Hexec.
  inv Hexec. split; [ reflexivity | split; [ reflexivity | ] ].
  match goal with Hlv : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hlv end;
    [ | match goal with Hnone : e ! math_util._dest = None |- _ =>
          rewrite Hed in Hnone; discriminate Hnone end ].
  match goal with He : e ! math_util._dest = Some (?loc, _) |- _ =>
    assert (loc = bb) by congruence; subst loc end.
  match goal with Hass : assign_loc _ _ _ _ _ Full _ _ |- _ => inv Hass end;
  [ match goal with Ham : access_mode _ = By_value _ |- _ =>
      cbn [access_mode typeof] in Ham; injection Ham as Hchunk; subst end
  | match goal with Ham : access_mode _ = By_copy |- _ =>
      cbn [access_mode typeof] in Ham; discriminate Ham end ].
  match goal with Hsv : Mem.storev _ _ _ ?vv = Some _ |- _ =>
    unfold Mem.storev in Hsv; rewrite Ptrofs.unsigned_zero in Hsv; exists vv; exact Hsv end.
Qed.

Lemma shadow_sset_load :
  forall ge e le m T bb tid t le' m' out,
    e ! math_util._dest = Some (bb, tptr T) ->
    exec_stmt function_entry2 ge e le m (Sset tid (Evar math_util._dest (tptr T)))
      t le' m' out ->
    m' = m /\ out = Out_normal /\
    exists v3, Mem.load Mptr m bb 0 = Some v3 /\ le' = PTree.set tid v3 le.
Proof.
  intros ge e le m T bb tid t le' m' out Hed Hexec.
  inv Hexec. split; [ reflexivity | split; [ reflexivity | ] ].
  match goal with Hev : eval_expr _ _ _ _ (Evar _ _) ?v3 |- _ => inv Hev; exists v3 end.
  match goal with Hlv : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hlv end;
    [ | match goal with Hnone : e ! math_util._dest = None |- _ =>
          rewrite Hed in Hnone; discriminate Hnone end ].
  match goal with He : e ! math_util._dest = Some (?loc, _) |- _ =>
    assert (loc = bb) by congruence; subst loc end.
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end;
    try (match goal with Ham : access_mode _ = By_reference |- _ =>
           cbn in Ham; discriminate Ham end);
    try (match goal with Ham : access_mode _ = By_copy |- _ =>
           cbn in Ham; discriminate Ham end);
    try (match goal with Hlb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hlb end).
  match goal with Ham : access_mode _ = By_value _ |- _ =>
    cbn in Ham; injection Ham as Hch; subst end.
  match goal with Hld : Mem.loadv _ _ _ = Some _ |- _ =>
    unfold Mem.loadv in Hld; rewrite Ptrofs.unsigned_zero in Hld end.
  split; [ assumption | reflexivity ].
Qed.

Lemma cast_same_nonptr : forall T v m v',
    (T = tfloat \/ T = tshort) -> sem_cast v T T m = Some v' ->
    forall b o, v' <> Vptr b o.
Proof.
  intros T v m v' HT Hc b o E. subst v'.
  destruct HT as [-> | ->]; destruct v; cbn in Hc; cbv [Archi.ptr64] in Hc; cbn in Hc;
    try discriminate Hc.
Qed.

(* an element store `*(tid + i) = rhs` stores a NON-pointer into tid's block *)
Lemma elem_assign_store :
  forall ge e le m tid T ii rhs b o t le' m' out,
    le ! tid = Some (Vptr b o) -> (T = tfloat \/ T = tshort) -> typeof rhs = T ->
    exec_stmt function_entry2 ge e le m
      (Sassign (Ederef (Ebinop Oadd (Etempvar tid (tptr T)) (Econst_int ii tint) (tptr T)) T)
         rhs) t le' m' out ->
    exists ch ofs v, Mem.store ch m b ofs v = Some m' /\ 0 < size_chunk ch /\
      (forall b' o', v <> Vptr b' o').
Proof.
  intros ge e le m tid T ii rhs b o t le' m' out Htid HT Hty Hexec.
  inv Hexec.
  match goal with Hlv : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ =>
    destruct (vec_elem_lvalue _ _ _ _ _ _ _ _ _ _ _ _ Htid HT Hlv) as (-> & _ & ->) end.
  match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ => rename Hc into Hcast end.
  try rewrite Hty in Hcast.
  pose proof (cast_same_nonptr _ _ _ _ HT Hcast) as Hnp.
  match goal with Hass : assign_loc _ _ _ _ _ Full _ _ |- _ => inv Hass end;
  [ | match goal with Ham : access_mode _ = By_copy |- _ =>
        destruct HT as [E | E]; rewrite E in Ham; cbn in Ham; discriminate Ham end ].
  match goal with Ham : access_mode _ = By_value ?c, Hsv : Mem.storev _ _ _ _ = Some _ |- _ =>
    unfold Mem.storev in Hsv; exists c; eexists; eexists;
    split; [ exact Hsv | split; [ destruct c; cbn; lia | exact Hnp ] ] end.
Qed.

(* the clobber: a non-pointer store into the 4-byte shadow, after which the
   shadow still reads back as a pointer, is impossible *)
Lemma shadow_clobber_false :
  forall m m0 bb vp m1 ch ofs v m2 b3 o3,
    Mem.alloc m 0 4 = (m0, bb) ->
    Mem.store Mptr m0 bb 0 vp = Some m1 ->
    Mem.store ch m1 bb ofs v = Some m2 -> 0 < size_chunk ch ->
    (forall b' o', v <> Vptr b' o') ->
    Mem.load Mptr m2 bb 0 = Some (Vptr b3 o3) ->
    False.
Proof.
  intros m m0 bb vp m1 ch ofs v m2 b3 o3 Ha Hs1 Hs2 Hsz Hnp Hld.
  assert (Hperm : Mem.perm m1 bb ofs Cur Writable).
  { apply (Mem.store_valid_access_3 _ _ _ _ _ _ Hs2). lia. }
  apply (Mem.perm_store_2 _ _ _ _ _ _ Hs1) in Hperm.
  apply (Mem.perm_alloc_3 _ _ _ _ _ Ha) in Hperm.
  destruct (Mem.load_pointer_store _ _ _ _ _ _ _ _ _ _ _ Hs2 Hld)
    as [(E & _) | [N | [Hle | Hle]]].
  - exact (Hnp _ _ E).
  - exact (N eq_refl).
  - unfold Mptr in Hle. cbv [Archi.ptr64] in Hle. cbn in Hle. lia.
  - lia.
Qed.

(* the shadow assign, at a pointer parameter: it stores exactly that pointer *)
Lemma shadow_assign_ptr :
  forall ge e le m T bb b o t le' m' out,
    e ! math_util._dest = Some (bb, tptr T) ->
    le ! math_util._dest = Some (Vptr b o) ->
    exec_stmt function_entry2 ge e le m
      (Sassign (Evar math_util._dest (tptr T)) (Etempvar math_util._dest (tptr T)))
      t le' m' out ->
    le' = le /\ out = Out_normal /\ Mem.store Mptr m bb 0 (Vptr b o) = Some m'.
Proof.
  intros ge e le m T bb b o t le' m' out Hed Hl0 Hexec.
  inv Hexec. split; [ reflexivity | split; [ reflexivity | ] ].
  match goal with Hlv : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hlv end;
    [ | match goal with Hnone : e ! math_util._dest = None |- _ =>
          rewrite Hed in Hnone; discriminate Hnone end ].
  match goal with He : e ! math_util._dest = Some (?loc, _) |- _ =>
    assert (loc = bb) by congruence; subst loc end.
  match goal with Hev : eval_expr _ _ _ _ (Etempvar _ _) ?v2 |- _ =>
    apply RealFrameValue.eval_expr_Etempvar_val in Hev;
    assert (v2 = Vptr b o) by congruence; subst v2 end.
  match goal with Hc : sem_cast (Vptr b o) _ _ _ = Some ?v |- _ =>
    assert (v = Vptr b o) by (cbn in Hc; congruence); subst v end.
  match goal with Hass : assign_loc _ _ _ _ _ Full _ _ |- _ => inv Hass end;
  [ match goal with Ham : access_mode _ = By_value _ |- _ =>
      cbn [access_mode typeof] in Ham; injection Ham as Hchunk; subst end
  | match goal with Ham : access_mode _ = By_copy |- _ =>
      cbn [access_mode typeof] in Ham; discriminate Ham end ].
  match goal with Hsv : Mem.storev _ _ _ _ = Some _ |- _ =>
    unfold Mem.storev in Hsv; rewrite Ptrofs.unsigned_zero in Hsv; exact Hsv end.
Qed.

(* one set-shape element block: reads the shadow (a pointer), stores a
   non-pointer into the pointed block *)
Lemma blk_set_inv :
  forall ge e le m T bb tid ii rhs t le' m' out,
    e ! math_util._dest = Some (bb, tptr T) ->
    (T = tfloat \/ T = tshort) -> typeof rhs = T ->
    exec_stmt function_entry2 ge e le m
      (Ssequence (Sset tid (Evar math_util._dest (tptr T)))
        (Sassign (Ederef (Ebinop Oadd (Etempvar tid (tptr T)) (Econst_int ii tint) (tptr T)) T)
           rhs)) t le' m' out ->
    out = Out_normal /\ exists b' o', Mem.load Mptr m bb 0 = Some (Vptr b' o') /\
      exists ch ofs v, Mem.store ch m b' ofs v = Some m' /\ 0 < size_chunk ch /\
        (forall b'' o'', v <> Vptr b'' o'').
Proof.
  intros ge e le m T bb tid ii rhs t le' m' out Hed HT Hty Hexec.
  subst T.
  inv Hexec.
  2: { match goal with Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _, Hn : _ <> Out_normal |- _ =>
         inv Hs; congruence end. }
  match goal with Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ =>
    destruct (shadow_sset_load _ _ _ _ _ _ _ _ _ _ _ Hed Hs) as (-> & _ & v3 & Hld & ->) end.
  match goal with Ha : exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ |- _ => rename Ha into HA end.
  pose proof HA as HA'. apply exec_Sassign_inv in HA' as (-> & _).
  split; [ reflexivity | ].
  pose proof HA as HA2. inv HA2.
  match goal with Hlv : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ =>
    destruct (deref_add_temp_ptr _ _ _ _ _ _ _ _ _ _ HT Hlv) as (b' & o' & Hb') end.
  rewrite PTree.gss in Hb'. injection Hb' as ->.
  exists b', o'. split; [ exact Hld | ].
  eapply elem_assign_store with (rhs := rhs); [ apply PTree.gss | exact HT | reflexivity | exact HA ].
Qed.

(* one copy-shape element block *)
Lemma blk_copy_inv :
  forall ge e le m T bb tid1 tid2 src ii t le' m' out,
    e ! math_util._dest = Some (bb, tptr T) ->
    (T = tfloat \/ T = tshort) -> tid1 <> tid2 ->
    exec_stmt function_entry2 ge e le m
      (Ssequence (Sset tid1 (Evar math_util._dest (tptr T)))
        (Ssequence (Sset tid2 src)
          (Sassign (Ederef (Ebinop Oadd (Etempvar tid1 (tptr T)) (Econst_int ii tint) (tptr T)) T)
             (Etempvar tid2 T)))) t le' m' out ->
    out = Out_normal /\ exists b' o', Mem.load Mptr m bb 0 = Some (Vptr b' o') /\
      exists ch ofs v, Mem.store ch m b' ofs v = Some m' /\ 0 < size_chunk ch /\
        (forall b'' o'', v <> Vptr b'' o'').
Proof.
  intros ge e le m T bb tid1 tid2 src ii t le' m' out Hed HT Hne Hexec.
  inv Hexec.
  2: { match goal with Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _, Hn : _ <> Out_normal |- _ =>
         inv Hs; congruence end. }
  match goal with Hs : exec_stmt _ _ _ _ _ (Sset tid1 _) _ _ _ _ |- _ =>
    destruct (shadow_sset_load _ _ _ _ _ _ _ _ _ _ _ Hed Hs) as (-> & _ & v3 & Hld & ->) end.
  match goal with Hq : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ => rename Hq into HQ end.
  inv HQ.
  2: { match goal with Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _, Hn : _ <> Out_normal |- _ =>
         inv Hs; congruence end. }
  match goal with Hs : exec_stmt _ _ _ _ _ (Sset tid2 _) _ _ _ _ |- _ => inv Hs end.
  match goal with Ha : exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ |- _ => rename Ha into HA end.
  pose proof HA as HA'. apply exec_Sassign_inv in HA' as (-> & _).
  split; [ reflexivity | ].
  pose proof HA as HA2. inv HA2.
  match goal with Hlv : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ =>
    destruct (deref_add_temp_ptr _ _ _ _ _ _ _ _ _ _ HT Hlv) as (b' & o' & Hb') end.
  rewrite PTree.gso in Hb' by exact Hne. rewrite PTree.gss in Hb'. injection Hb' as ->.
  exists b', o'. split; [ exact Hld | ].
  eapply elem_assign_store with (rhs := Etempvar tid2 T);
    [ rewrite PTree.gso by exact Hne; apply PTree.gss | exact HT | reflexivity | exact HA ].
Qed.

Lemma vec_out_valid_core :
  forall m m0 bb b o m1 ch ofs v m2 b3 o3,
    Mem.alloc m 0 4 = (m0, bb) ->
    Mem.store Mptr m0 bb 0 (Vptr b o) = Some m1 ->
    Mem.store ch m1 b ofs v = Some m2 -> 0 < size_chunk ch ->
    (forall b' o', v <> Vptr b' o') ->
    Mem.load Mptr m2 bb 0 = Some (Vptr b3 o3) ->
    Mem.valid_block m b.
Proof.
  intros m m0 bb b o m1 ch ofs v m2 b3 o3 Ha Hs1 Hs2 Hsz Hnp Hld.
  assert (Hv1 : Mem.valid_block m1 b).
  { destruct (Mem.store_valid_access_3 _ _ _ _ _ _ Hs2) as [Hrp _].
    apply (Mem.perm_valid_block _ _ ofs Cur Writable). apply Hrp. lia. }
  apply (Mem.store_valid_block_2 _ _ _ _ _ _ Hs1) in Hv1.
  destruct (Mem.valid_block_alloc_inv _ _ _ _ _ Ha _ Hv1) as [-> | Hv]; [ | exact Hv ].
  exfalso. exact (shadow_clobber_false _ _ _ _ _ _ _ _ _ _ _ Ha Hs1 Hs2 Hsz Hnp Hld).
Qed.

Lemma load_shadow_ptr : forall m0 bb b o m1,
    Mem.store Mptr m0 bb 0 (Vptr b o) = Some m1 ->
    Mem.load Mptr m1 bb 0 = Some (Vptr b o).
Proof.
  intros m0 bb b o m1 Hs. rewrite (Mem.load_store_same _ _ _ _ _ _ Hs).
  unfold Mptr. cbv [Archi.ptr64]. reflexivity.
Qed.

Ltac funcall_entry Hevf :=
  inv Hevf;
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end;
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => cbn [fn_vars] in Ha; inv Ha end;
  match goal with Ha : alloc_variables _ _ _ nil _ _ |- _ => inv Ha end.

(* the head statement of a sequence that cannot abort: it ran, normally,
   and the tail ran after it *)
Lemma seq_head_normal :
  forall ge e le m s1 s2 t le' m' out,
    exec_stmt function_entry2 ge e le m (Ssequence s1 s2) t le' m' out ->
    (forall t1 le1 m1 out1,
        exec_stmt function_entry2 ge e le m s1 t1 le1 m1 out1 -> out1 = Out_normal) ->
    exists t1 le1 m1 t2,
      exec_stmt function_entry2 ge e le m s1 t1 le1 m1 Out_normal /\
      exec_stmt function_entry2 ge e le1 m1 s2 t2 le' m' out.
Proof.
  intros ge e le m s1 s2 t le' m' out H Hn. inv H.
  - do 4 eexists. split; eassumption.
  - match goal with Hs : exec_stmt _ _ _ _ _ s1 _ _ _ ?o, Hne : ?o <> Out_normal |- _ =>
      exfalso; exact (Hne (Hn _ _ _ _ Hs)) end.
Qed.

Lemma seq_head_any :
  forall ge e le m s1 s2 t le' m' out,
    exec_stmt function_entry2 ge e le m (Ssequence s1 s2) t le' m' out ->
    exists t1 le1 m1 out1, exec_stmt function_entry2 ge e le m s1 t1 le1 m1 out1.
Proof. intros. inv H; do 4 eexists; eassumption. Qed.

Lemma vec_set_out_valid :
  forall ge m f T vargs t m' vres b o,
    (f = math_util.f_vec3f_set /\ T = tfloat \/ f = math_util.f_vec3s_set /\ T = tshort) ->
    eval_funcall function_entry2 ge m (Internal f) vargs t m' vres ->
    hd_error vargs = Some (Vptr b o) ->
    Mem.valid_block m b.
Proof.
  intros ge m f T vargs t m' vres b o Hf Hevf Hhd.
  assert (HT : T = tfloat \/ T = tshort) by (destruct Hf as [[_ ->] | [_ ->]]; auto).
  destruct Hf as [[-> ->] | [-> ->]].
  all: unfold math_util.f_vec3f_set, math_util.f_vec3s_set in Hevf.
  all: funcall_entry Hevf.
  all: match goal with Hal : Mem.alloc _ _ _ = (_, ?bb) |- _ =>
    rename Hal into Halc end.
  all: (match type of Halc with Mem.alloc ?mm _ _ = ?r =>
     change (Mem.alloc mm 0 4 = r) in Halc end).
  all: match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind end.
  all: match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hexec end.
  all: cbn [fn_params fn_temps fn_body] in Hbind, Hexec.
  all: (destruct vargs as [| a0 vr]; cbn [hd_error] in Hhd; [ discriminate Hhd | injection Hhd as -> ]).
  all: (destruct vr as [| a1 [| a2 [| a3 [| a4 vr]]]]; cbn [bind_parameter_temps] in Hbind;
    try discriminate Hbind).
  all: injection Hbind as <-.
  all: (destruct (seq_head_normal _ _ _ _ _ _ _ _ _ _ Hexec
              ltac:(intros ? ? ? ? Hs; inv Hs; reflexivity))
     as (? & ? & ? & ? & HA & Hrest)).
  all: match type of HA with exec_stmt _ _ _ ?LE _ _ _ _ _ _ =>
         assert (Hl0 : LE ! math_util._dest = Some (Vptr b o)) by (vm_compute; reflexivity) end.
  all: (destruct (shadow_assign_ptr _ _ _ _ _ _ _ _ _ _ _ _ (PTree.gss _ _ _) Hl0 HA)
     as (-> & _ & Hs1)).
  all: (destruct (seq_head_normal _ _ _ _ _ _ _ _ _ _ Hrest
              ltac:(intros ? ? ? ? Hs;
                    match type of Hs with
                    | exec_stmt _ _ _ _ _ (Ssequence _ (Sassign _ ?R)) _ _ _ _ =>
                        exact (proj1 (blk_set_inv _ _ _ _ _ _ _ _ R _ _ _ _
                                 (PTree.gss _ _ _) HT eq_refl Hs))
                    end))
     as (? & ? & ? & ? & HB1 & Hrest2)).
  all: match type of HB1 with
       | exec_stmt _ _ _ _ _ (Ssequence _ (Sassign _ ?R)) _ _ _ _ =>
           pose proof (blk_set_inv _ _ _ _ _ _ _ _ R _ _ _ _ (PTree.gss _ _ _) HT eq_refl HB1) as BHB1
       end.
  all: (destruct BHB1
     as (_ & b' & o' & Hld1 & ch & ofs & v & Hs2 & Hsz & Hnp)).
  all: rewrite (load_shadow_ptr _ _ _ _ _ Hs1) in Hld1; injection Hld1 as <- <-.
  all: (destruct (seq_head_any _ _ _ _ _ _ _ _ _ _ Hrest2) as (? & ? & ? & ? & HB2)).
  all: match type of HB2 with
       | exec_stmt _ _ _ _ _ (Ssequence _ (Sassign _ ?R)) _ _ _ _ =>
           pose proof (blk_set_inv _ _ _ _ _ _ _ _ R _ _ _ _ (PTree.gss _ _ _) HT eq_refl HB2) as BHB2
       end.
  all: (destruct BHB2
     as (_ & b3 & o3 & Hld2 & _)).
  all: exact (vec_out_valid_core _ _ _ _ _ _ _ _ _ _ _ _ Halc Hs1 Hs2 Hsz Hnp Hld2).
Qed.

Lemma vec_copy_out_valid :
  forall ge m f T vargs t m' vres b o,
    (f = math_util.f_vec3f_copy /\ T = tfloat \/ f = math_util.f_vec3s_copy /\ T = tshort) ->
    eval_funcall function_entry2 ge m (Internal f) vargs t m' vres ->
    hd_error vargs = Some (Vptr b o) ->
    Mem.valid_block m b.
Proof.
  intros ge m f T vargs t m' vres b o Hf Hevf Hhd.
  assert (HT : T = tfloat \/ T = tshort) by (destruct Hf as [[_ ->] | [_ ->]]; auto).
  assert (Hne56 : math_util._t'5 <> math_util._t'6) by (cbv; discriminate).
  assert (Hne34 : math_util._t'3 <> math_util._t'4) by (cbv; discriminate).
  destruct Hf as [[-> ->] | [-> ->]].
  all: unfold math_util.f_vec3f_copy, math_util.f_vec3s_copy in Hevf.
  all: funcall_entry Hevf.
  all: match goal with Hal : Mem.alloc _ _ _ = (_, ?bb) |- _ =>
    rename Hal into Halc end.
  all: (match type of Halc with Mem.alloc ?mm _ _ = ?r =>
     change (Mem.alloc mm 0 4 = r) in Halc end).
  all: match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind end.
  all: match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hexec end.
  all: cbn [fn_params fn_temps fn_body] in Hbind, Hexec.
  all: (destruct vargs as [| a0 vr]; cbn [hd_error] in Hhd; [ discriminate Hhd | injection Hhd as -> ]).
  all: (destruct vr as [| a1 [| a2 vr]]; cbn [bind_parameter_temps] in Hbind;
    try discriminate Hbind).
  all: injection Hbind as <-.
  all: (destruct (seq_head_normal _ _ _ _ _ _ _ _ _ _ Hexec
              ltac:(intros ? ? ? ? Hs; inv Hs; reflexivity))
     as (? & ? & ? & ? & HA & Hrest)).
  all: match type of HA with exec_stmt _ _ _ ?LE _ _ _ _ _ _ =>
         assert (Hl0 : LE ! math_util._dest = Some (Vptr b o)) by (vm_compute; reflexivity) end.
  all: (destruct (shadow_assign_ptr _ _ _ _ _ _ _ _ _ _ _ _ (PTree.gss _ _ _) Hl0 HA)
     as (-> & _ & Hs1)).
  all: (destruct (seq_head_normal _ _ _ _ _ _ _ _ _ _ Hrest
              ltac:(intros ? ? ? ? Hs;
                    exact (proj1 (blk_copy_inv _ _ _ _ _ _ _ _ _ _ _ _ _ _
                             (PTree.gss _ _ _) HT Hne56 Hs))))
     as (? & ? & ? & ? & HB1 & Hrest2)).
  all: (destruct (blk_copy_inv _ _ _ _ _ _ _ _ _ _ _ _ _ _ (PTree.gss _ _ _) HT Hne56 HB1)
     as (_ & b' & o' & Hld1 & ch & ofs & v & Hs2 & Hsz & Hnp)).
  all: rewrite (load_shadow_ptr _ _ _ _ _ Hs1) in Hld1; injection Hld1 as <- <-.
  all: (destruct (seq_head_any _ _ _ _ _ _ _ _ _ _ Hrest2) as (? & ? & ? & ? & HB2)).
  all: (destruct (blk_copy_inv _ _ _ _ _ _ _ _ _ _ _ _ _ _ (PTree.gss _ _ _) HT Hne34 HB2)
     as (_ & b3 & o3 & Hld2 & _)).
  all: exact (vec_out_valid_core _ _ _ _ _ _ _ _ _ _ _ _ Halc Hs1 Hs2 Hsz Hnp Hld2).
Qed.

Lemma vec3s_set_body_frame_B :
  forall (ge : genv) (MWF : mem -> Prop) (bm b_out : block) (oo : ptrofs),
    frame_oracles bm MWF ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m
        (Internal math_util.f_vec3s_set) vargs t m' vres ->
      hd_error vargs = Some (Vptr b_out oo) ->
      vec_out not_tainted bm MWF Mint16signed b_out oo -> Mem.valid_block m b_out ->
      Mem.valid_block m bm -> action_sat not_tainted m bm -> MWF m ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
Proof.
  intros ge MWF bm b_out oo Hor m vargs t m' vres
         Hevf Hhd Hvo Hbov Hv Hsat Hmwf.
  destruct Hor as (Halloc & Hfree & HallocB).
  pose proof (vec_out_cell _ _ _ _ tshort _ _ ge 0 Hvo eq_refl ltac:(lia)) as Hc0.
  pose proof (vec_out_cell _ _ _ _ tshort _ _ ge 1 Hvo eq_refl ltac:(lia)) as Hc1.
  pose proof (vec_out_cell _ _ _ _ tshort _ _ ge 2 Hvo eq_refl ltac:(lia)) as Hc2.
  assert (Hacs : access_mode tshort = By_value Mint16signed) by reflexivity.
  unfold math_util.f_vec3s_set in Hevf.
  inv Hevf.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfl end.
  (* ENTRY: alloc the _dest shadow, bind params *)
  inv Hentry.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => cbn [fn_vars] in Ha; inv Ha end.
  match goal with Ha : alloc_variables _ _ _ nil _ _ |- _ => inv Ha end.
  match goal with Halc : Mem.alloc _ _ _ = (_, ?bb) |- _ =>
    assert (Hbd_bm : bb <> bm)
      by (intro EE; subst bb; exact (Mem.fresh_block_alloc _ _ _ _ _ Halc Hv));
    assert (HbdB : blk_pres not_tainted bm MWF bb) by (eapply HallocB; eassumption);
    assert (Hbd_bo : bb <> b_out)
      by (intro EE; subst bb; exact (Mem.fresh_block_alloc _ _ _ _ _ Halc Hbov));
    assert (Hedest : (PTree.set math_util._dest (bb, tptr tshort) empty_env)
                       ! math_util._dest = Some (bb, tptr tshort)) by (apply PTree.gss)
  end.
  match goal with Halc : Mem.alloc _ _ _ = (?mm, _) |- _ =>
    assert (HmwfA : MWF mm) by (eapply Halloc; [ exact Halc | exact Hmwf ]);
    assert (HvA : Mem.valid_block mm bm)
      by (eapply Mem.valid_block_alloc; [ exact Halc | exact Hv ]);
    assert (HsatA : action_sat not_tainted mm bm)
      by (eapply action_sat_unchanged_on;
          [ eapply Mem.alloc_unchanged_on; exact Halc | exact Hv | exact Hsat ])
  end.
  (* le!_dest = Vptr b_out oo *)
  destruct vargs as [| a0 vargs1]; cbn [hd_error] in Hhd; [ discriminate Hhd | ].
  injection Hhd as ->.
  match goal with Hbp : bind_parameter_temps _ _ _ = Some ?LE |- _ =>
    cbn [fn_params] in Hbp;
    assert (Hled : LE ! math_util._dest = Some (Vptr b_out oo))
      by (eapply bind_parameter_temps_head; [ | exact Hbp ];
          cbn [var_names map fst]; intros [E|[E|[E|E]]]; try discriminate E; exact E)
  end.
  (* WALK: shadow store, then three vec3f_set store blocks, then Sreturn+free *)
  cbn [fn_body] in Hbody.
  peelseq.
  match goal with HA : exec_stmt _ _ _ _ _ (Sassign (Evar _ _) _) _ _ _ _ |- _ =>
    rename HA into HA0 end.
  destruct (vec_shadow_store_B _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
              HbdB Hedest Hled I HA0 HvA HsatA HmwfA)
    as (Hv1 & Hs1 & Hm1 & Hload1).
  peelseq.
  match goal with HB : exec_stmt _ _ _ _ _ (Ssequence (Sset _ _) (Sassign (Ederef _ _) _)) _ _ _ _ |- _ =>
    rename HB into HB0 end.
  destruct (vec_block_set_B _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
              Hc0 Hacs Hedest Hload1 (or_intror eq_refl) (not_eq_sym Hbd_bo) HB0 Hv1 Hs1 Hm1)
    as (Hv2 & Hs2 & Hm2 & Hload2).
  peelseq.
  match goal with HC : exec_stmt _ _ _ _ _ (Ssequence (Sset _ _) (Sassign (Ederef _ _) _)) _ _ _ _ |- _ =>
    rename HC into HC0 end.
  destruct (vec_block_set_B _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
              Hc1 Hacs Hedest Hload2 (or_intror eq_refl) (not_eq_sym Hbd_bo) HC0 Hv2 Hs2 Hm2)
    as (Hv3 & Hs3 & Hm3 & Hload3).
  peelseq.
  match goal with HD : exec_stmt _ _ _ _ _ (Ssequence (Sset _ _) (Sassign (Ederef _ _) _)) _ _ _ _ |- _ =>
    rename HD into HD0 end.
  destruct (vec_block_set_B _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
              Hc2 Hacs Hedest Hload3 (or_intror eq_refl) (not_eq_sym Hbd_bo) HD0 Hv3 Hs3 Hm3)
    as (Hv4 & Hs4 & Hm4 & Hload4).
  (* Sreturn: memory unchanged *)
  match goal with HRet : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ => inv HRet end.
  (* EXIT: free the sole shadow block (bm-distinct) *)
  rewrite blocks_of_env_mu_dest in Hfl.
  match goal with |- _ =>
    assert (Hforall : Forall (fun blh => let '(b,_,_) := blh in b <> bm)
                        ((_, 0, sizeof ge (tptr tshort)) :: nil))
      by (constructor; [ exact Hbd_bm | constructor ])
  end.
  destruct (vfc_free_list_frame not_tainted bm _ _ _ Hforall Hfl Hv4 Hs4) as (Hvf & Hsf).
  split; [ exact Hvf | split; [ exact Hsf | ] ].
  eapply Hfree; [ exact Hfl | exact Hm4 ].
Qed.

Lemma vec3s_set_dest_ptr : forall ge m vargs t m' vres,
  eval_funcall function_entry2 ge m (Internal math_util.f_vec3s_set) vargs t m' vres ->
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
    destruct (deref_add_temp_ptr _ _ _ _ _ _ _ _ _ _ (or_intror eq_refl) Hl)
      as (b & o & Hb) end.
  exists b, o. cbn [hd_error]. f_equal.
  eapply shadow_reload_ptr; [ apply PTree.gss | | exact Q1 | exact Q4 | exact Hb ].
  reflexivity.
Qed.

Lemma math_defmap_v3sset :
  (prog_defmap math_util.prog) ! mario_actions_automatic._vec3s_set
    = Some (Gfun (Internal math_util.f_vec3s_set)).
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* CAPSTONE ROWS DISCHARGED BY THE LINK (SPINE).  With math_util in the    *)
(* link, the destination-gated vec writer rows that NoAImpliesNoFlyLinked  *)
(* took as Hypotheses are theorems about the real bodies.                  *)
(* ====================================================================== *)

Section MathRows.
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
  Hypothesis Hbc_sym : exists gid, Genv.find_symbol (lp_ge lp) gid = Some bc.

  Let MWF := MWF_real lp bm bc oc0 SafeB.
  Let NoA := fun m => ctl_a_clear m bm.

  Let mr_window := sb_window lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm Hgms_blk
                     Hgtimer_blk Htable_blk Hktab_blk.

  Lemma mr_chase : forall mm ch bsafe (d : Z) vv mm',
      MWF mm -> SafeB bsafe ->
      (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store ch mm bsafe d vv = Some mm' -> MWF mm'.
  Proof.
    exact (mwf_real_chase lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm HSafeB_not_bc
             Hgms_blk Hgtimer_blk Htable_blk Hktab_blk).
  Qed.

  Lemma mr_local_pres : forall b, local_blk lp bm SafeB b ->
      blk_pres not_tainted bm MWF b.
  Proof.
    intros b Hl.
    apply (blk_pres_local bm MWF (local_blk lp bm SafeB)).
    - intros b0 (Hb0 & _). exact Hb0.
    - intros m ch b0 d v m' (Hb0 & HnS & Hgl) Hst HM0.
      destruct Hbc_sym as (gid & Hsy).
      eapply mwf_real_local_store; eauto.
    - exact Hl.
  Qed.

  (* the dg gate supplies the vec_out premise, at any <=12-byte vec3 *)
  Lemma dg_vec_out : forall ch vargs,
      size_chunk ch * 3 <= 12 ->
      arg0_dg lp bm SafeB vargs ->
      exists b o rest, vargs = Vptr b o :: rest /\ vec_out not_tainted bm MWF ch b o.
  Proof.
    intros ch vargs Hn
      [(b & o & rest & -> & Hs) | [(o & rest & -> & Hw) | (b & o & rest & -> & Hl)]].
    - exists b, o, rest. split; [ reflexivity | ].
      apply (osafe_vec_out bm MWF SafeB mr_window HSafeB_not_bm mr_chase 12 ch (Vptr b o));
        [ exact Hn | | reflexivity ].
      intros b' o' E. injection E as <- <-. right. exact Hs.
    - exists bm, o, rest. split; [ reflexivity | ].
      apply (osafe_vec_out bm MWF SafeB mr_window HSafeB_not_bm mr_chase 12 ch (Vptr bm o));
        [ exact Hn | | reflexivity ].
      intros b' o' E. injection E as <- <-. left. split; [ reflexivity | exact Hw ].
    - exists b, o, rest. split; [ reflexivity | ].
      exact (vec_out_of_blk bm MWF ch b o (mr_local_pres b Hl)).
  Qed.

  Ltac mr_finish Hframe :=
    destruct Hframe as (Hv' & Hs' & HM');
    exact (conj Hv' (conj Hs' (conj HM' (mwf_real_ctl lp bm bc oc0 SafeB _ HM')))).

  Lemma Hdg_v3f_proved :
    call_pres_ext_dg lp bm NoA MWF SafeB mario_actions_automatic._vec3f_copy.
  Proof.
    intros fd m0 vargs0 t0 m1 vres0 Hevf Hres Hdg _ HM Hv Hsat.
    pose proof (resolves_pin_fd lp _ _ _ _ LO_math math_defmap_v3fcopy Hres) as ->.
    destruct (dg_vec_out Mfloat32 vargs0 ltac:(cbn; lia) Hdg) as (b & o & rest & -> & Hvo).
    pose proof (vec_copy_out_valid _ _ _ tfloat _ _ _ _ b o
                  (or_introl (conj eq_refl eq_refl)) Hevf eq_refl) as Hbv.
    pose proof (vec3f_copy_body_frame_B (lp_ge lp) MWF bm b o
                  (sb_frame_oracles lp bm bc oc0 SafeB Hbc_bm)
                  m0 _ t0 m1 vres0 Hevf eq_refl Hvo Hbv Hv Hsat HM) as Hfr.
    mr_finish Hfr.
  Qed.

  Lemma Hdg_v3fset_proved :
    call_pres_ext_dg lp bm NoA MWF SafeB mario_actions_automatic._vec3f_set.
  Proof.
    intros fd m0 vargs0 t0 m1 vres0 Hevf Hres Hdg _ HM Hv Hsat.
    pose proof (resolves_pin_fd lp _ _ _ _ LO_math math_defmap_v3fset Hres) as ->.
    destruct (dg_vec_out Mfloat32 vargs0 ltac:(cbn; lia) Hdg) as (b & o & rest & -> & Hvo).
    pose proof (vec_set_out_valid _ _ _ tfloat _ _ _ _ b o
                  (or_introl (conj eq_refl eq_refl)) Hevf eq_refl) as Hbv.
    pose proof (vec3f_set_body_frame_B (lp_ge lp) MWF bm b o
                  (sb_frame_oracles lp bm bc oc0 SafeB Hbc_bm)
                  m0 _ t0 m1 vres0 Hevf eq_refl Hvo Hbv Hv Hsat HM) as Hfr.
    mr_finish Hfr.
  Qed.

  Lemma Hdg_v3scopy_proved :
    call_pres_ext_dg lp bm NoA MWF SafeB mario._vec3s_copy.
  Proof.
    intros fd m0 vargs0 t0 m1 vres0 Hevf Hres Hdg _ HM Hv Hsat.
    pose proof (resolves_pin_fd lp _ _ _ _ LO_math math_defmap_v3scopy Hres) as ->.
    destruct (dg_vec_out Mint16signed vargs0 ltac:(cbn; lia) Hdg) as (b & o & rest & -> & Hvo).
    pose proof (vec_copy_out_valid _ _ _ tshort _ _ _ _ b o
                  (or_intror (conj eq_refl eq_refl)) Hevf eq_refl) as Hbv.
    pose proof (vec3s_copy_body_frame_B (lp_ge lp) MWF bm b o
                  (sb_frame_oracles lp bm bc oc0 SafeB Hbc_bm)
                  m0 _ t0 m1 vres0 Hevf eq_refl Hvo Hbv Hv Hsat HM) as Hfr.
    mr_finish Hfr.
  Qed.

  Lemma Hdg_v3s_proved :
    call_pres_ext_dg lp bm NoA MWF SafeB mario_actions_automatic._vec3s_set.
  Proof.
    intros fd m0 vargs0 t0 m1 vres0 Hevf Hres Hdg _ HM Hv Hsat.
    pose proof (resolves_pin_fd lp _ _ _ _ LO_math math_defmap_v3sset Hres) as ->.
    destruct (dg_vec_out Mint16signed vargs0 ltac:(cbn; lia) Hdg) as (b & o & rest & -> & Hvo).
    pose proof (vec_set_out_valid _ _ _ tshort _ _ _ _ b o
                  (or_intror (conj eq_refl eq_refl)) Hevf eq_refl) as Hbv.
    pose proof (vec3s_set_body_frame_B (lp_ge lp) MWF bm b o
                  (sb_frame_oracles lp bm bc oc0 SafeB Hbc_bm)
                  m0 _ t0 m1 vres0 Hevf eq_refl Hvo Hbv Hv Hsat HM) as Hfr.
    mr_finish Hfr.
  Qed.
End MathRows.

(* ====================================================================== *)
(* THE PURE MATH ROWS (approach_f32 / approach_s32 / atan2s).  Their real   *)
(* bodies have no locals and no stores (atan2s's one callee, atan2_lookup,  *)
(* is pinned and store-free too), so a call leaves memory IDENTICAL: the   *)
(* any-argument row holds for ANY carried facts.                            *)
(* ====================================================================== *)

Lemma cpure2_funcall_memid :
  forall (ge : genv) f,
    fn_vars f = nil -> cpure2_chk (fn_body f) = true ->
    resolves_to ge math_util._atan2_lookup math_util.f_atan2_lookup ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m (Internal f) vargs t m' vres -> m' = m.
Proof.
  intros ge f Hfv Hchk Hpin m vargs t m' vres Hevf.
  inv Hevf.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
  inv Hentry.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => rewrite Hfv in Ha; inv Ha end.
  pose proof (cpure2_walk ge Hpin _ _ _ _ _ _ _ Hbody Hchk) as Em. subst.
  rewrite (eq_refl : blocks_of_env ge empty_env = nil) in Hfree.
  cbn [Mem.free_list] in Hfree. injection Hfree as <-. reflexivity.
Qed.

Lemma math_defmap_af32 :
  (prog_defmap math_util.prog) ! mario_actions_airborne._approach_f32
    = Some (Gfun (Internal math_util.f_approach_f32)).
Proof. vm_compute. reflexivity. Qed.
Lemma math_defmap_as32 :
  (prog_defmap math_util.prog) ! mario_actions_automatic._approach_s32
    = Some (Gfun (Internal math_util.f_approach_s32)).
Proof. vm_compute. reflexivity. Qed.
Lemma af32_pure : cpure2_chk (fn_body math_util.f_approach_f32) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma as32_pure : cpure2_chk (fn_body math_util.f_approach_s32) = true.
Proof. vm_compute. reflexivity. Qed.

Section MathPure.
  Variable lp : Clight.program.
  Variable bm : block.
  Variables NoA MWF : mem -> Prop.
  Hypothesis LO_math : linkorder math_util.prog lp.

  Lemma mp_resolves : forall id fr,
      (prog_defmap math_util.prog) ! id = Some (Gfun (Internal fr)) ->
      resolves_to (lp_ge lp) id fr.
  Proof.
    intros id fr Hdm bf f Hs Hf.
    destruct (linkorder_resolves_funct lp _ id fr LO_math Hdm) as (b' & Hs' & Hf').
    unfold lp_ge in Hs, Hf.
    rewrite Hs in Hs'. injection Hs' as <-.
    rewrite Genv.find_funct_find_funct_ptr in Hf'. congruence.
  Qed.

  Lemma call_pres_ext_pure : forall fid f,
      (prog_defmap math_util.prog) ! fid = Some (Gfun (Internal f)) ->
      fn_vars f = nil -> cpure2_chk (fn_body f) = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid f Hdm Hfv Hchk fd m0 vargs0 t0 m1 vres0 Hevf Hres HN HM Hv Hsat.
    pose proof (resolves_pin_fd lp _ _ _ _ LO_math Hdm Hres) as ->.
    rewrite (cpure2_funcall_memid _ _ Hfv Hchk (mp_resolves _ _ math_dm_atan2_lookup)
               _ _ _ _ _ Hevf).
    exact (conj Hv (conj Hsat (conj HM HN))).
  Qed.

  Lemma Hcpx_approach_f32_proved :
    call_pres_ext lp bm NoA MWF mario_actions_airborne._approach_f32.
  Proof. exact (call_pres_ext_pure _ _ math_defmap_af32 eq_refl af32_pure). Qed.

  Lemma Hcpx_approach_s32_proved :
    call_pres_ext lp bm NoA MWF mario_actions_automatic._approach_s32.
  Proof. exact (call_pres_ext_pure _ _ math_defmap_as32 eq_refl as32_pure). Qed.

  Lemma Hcpx_atan2s_proved :
    call_pres_ext lp bm NoA MWF mario._atan2s.
  Proof. exact (call_pres_ext_pure _ _ math_defmap_atan2s eq_refl atan2s_cpure2_chk). Qed.
End MathPure.
