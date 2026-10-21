(* ====================================================================== *)
(* THREE OBJECT-HELPER ROWS, PROVED FROM THEIR REAL BODIES                 *)
(* (SPINE: premise sweep, 2026-10-21).                                     *)
(*                                                                        *)
(* object_helpers.c is linked (the 20th TU, LinkedTwelve.tu_rest), so the  *)
(* three arg0-gated (cs) rows both capstones took are lemmas here, walked  *)
(* over the generated bodies:                                              *)
(*  - obj_mark_for_deletion(obj): obj->activeFlags = 0.                   *)
(*  - obj_scale(obj, scale): obj->header.gfx.scale[0..2] = scale.          *)
(*  - obj_set_held_state(obj, heldBehavior):                              *)
(*      obj->parentObj = gCurrentObject;                                  *)
(*      if (obj->oFlags & OBJ_FLAG_HOLDABLE) obj->oHeldState = 1 / 2 / 3; *)
(*      else { obj->curBhvCommand = segmented_to_virtual(heldBehavior);   *)
(*             obj->bhvStackIndex = 0; }                                  *)
(* Every store goes through the never-reassigned parameter obj, which the  *)
(* cs gate puts in a SafeB block when it is a pointer.  Two stores write   *)
(* POINTER-typed fields, so MWF's load closure (R7) needs the stored value *)
(* to be SafeB if it is a pointer:                                         *)
(*  - parentObj gets the value loaded from gCurrentObject, a SafeB symbol  *)
(*    (CensusV2.safe_ptr_syms, SpawnInit.SafeB_syms_ok (c)), so R7 itself *)
(*    makes the loaded pointer SafeB;                                     *)
(*  - curBhvCommand gets segmented_to_virtual's result.  Its real memory.c *)
(*    body returns ((sSegmentTable[seg] + off) | 0x80000000) cast to a     *)
(*    pointer: an integer OR, never a Vptr (s2v_ret_nonptr), and it stores *)
(*    nothing (MathBodies.cpure2_funcall_memid).                          *)
(* No row is false as stated; no new premise.                              *)
(*                                                                        *)
(* The walk (tw_walk) is BullyBodies' frozen-temps walk with a temp-env    *)
(* invariant: every temp in {obj, t'3, t'1} holds a SafeB block if it      *)
(* holds a pointer.                                                        *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario memory math_util object_helpers
  mario_actions_cutscene interaction.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame Taint
  RealFrameLinked AGates CensusV2 RestSurface MWFReal SpawnInit MathGeomBodies
  MathGeomGated OutParamSurface MathBodies LinkedTwelve.
From SM64.Proofs Require MtxfBody ActWriterSurface.

Import ListNotations.

(* ---------------------------------------------------------------------- *)
(* 1. The temp-invariant walk.                                             *)
(* ---------------------------------------------------------------------- *)

Section TW.
  Variable ge : genv.
  Variable e : env.
  Variable bm : block.
  Variable MWF : mem -> Prop.
  Variable P : temp_env -> Prop.
  Variable set_ok : ident -> expr -> bool.
  Variable store_ok : expr -> expr -> bool.
  Variable call_ok : option ident -> expr -> list expr -> bool.

  Hypothesis Hset : forall id a le m v,
      set_ok id a = true -> P le -> ow_facts bm MWF m ->
      eval_expr ge e le m a v -> P (PTree.set id v le).
  Hypothesis Hstore : forall lv rhs le m t le' m' out,
      store_ok lv rhs = true -> P le ->
      exec_stmt function_entry2 ge e le m (Sassign lv rhs) t le' m' out ->
      ow_facts bm MWF m -> ow_facts bm MWF m'.
  Hypothesis Hcall : forall optid a al le m t le' m' out,
      call_ok optid a al = true -> P le ->
      exec_stmt function_entry2 ge e le m (Scall optid a al) t le' m' out ->
      ow_facts bm MWF m -> ow_facts bm MWF m' /\ P le'.

  Fixpoint tw_chk (s : statement) : bool :=
    match s with
    | Sskip | Sbreak | Scontinue | Sreturn _ => true
    | Sset id a => set_ok id a
    | Sassign lv rhs => store_ok lv rhs
    | Scall optid a al => call_ok optid a al
    | Ssequence s1 s2 => tw_chk s1 && tw_chk s2
    | Sifthenelse _ s1 s2 => tw_chk s1 && tw_chk s2
    | _ => false
    end.

  Lemma tw_walk : forall e1 le m s t le' m' out,
      exec_stmt function_entry2 ge e1 le m s t le' m' out -> e1 = e ->
      tw_chk s = true -> P le -> ow_facts bm MWF m ->
      ow_facts bm MWF m' /\ P le'.
  Proof.
    intros e1 le m s t le' m' out Hexec.
    induction Hexec; intros He Hchk Hp Hf; subst; cbn [tw_chk] in Hchk;
      try discriminate Hchk.
    - (* Sskip *) split; assumption.
    - (* Sassign *)
      split; [ | exact Hp ].
      lazymatch goal with Hl : eval_lvalue ?gg ?ee ?ll ?mm a1 _ _ _ |- _ =>
        assert (Hx : exec_stmt function_entry2 gg ee ll mm (Sassign a1 a2) E0 ll m' Out_normal)
          by (eapply exec_Sassign; eassumption) end.
      exact (Hstore _ _ _ _ _ _ _ _ Hchk Hp Hx Hf).
    - (* Sset *)
      split; [ exact Hf | ]. eapply Hset; eassumption.
    - (* Scall *)
      lazymatch goal with Hee : eval_expr ?gg ?ee ?ll ?mm a _,
                          Hfc : eval_funcall _ _ _ _ _ ?tt ?mm' ?vr |- _ =>
        assert (Hx : exec_stmt function_entry2 gg ee ll mm (Scall optid a al) tt
                       (set_opttemp optid vr ll) mm' Out_normal)
          by (eapply exec_Scall; eassumption) end.
      exact (Hcall _ _ _ _ _ _ _ _ _ Hchk Hp Hx Hf).
    - (* Sseq_1 *)
      apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 eq_refl H1 Hp Hf) as [Hf1 Hp1].
      exact (IHHexec2 eq_refl H2 Hp1 Hf1).
    - (* Sseq_2 *)
      apply andb_prop in Hchk as [H1 _].
      exact (IHHexec eq_refl H1 Hp Hf).
    - (* Sifthenelse *)
      apply andb_prop in Hchk as [H1 H2].
      apply IHHexec; [ reflexivity | destruct b; assumption | exact Hp | exact Hf ].
    - split; assumption.
    - split; assumption.
    - split; assumption.
    - split; assumption.
  Qed.
End TW.

(* the body frame: a no-locals body walked by tw_chk *)
Lemma tw_body_frame :
  forall (ge : genv) (MWF : mem -> Prop) bm (f : Clight.function) P set_ok store_ok call_ok,
    fn_vars f = nil ->
    tw_chk set_ok store_ok call_ok (fn_body f) = true ->
    (forall id a le m v,
       set_ok id a = true -> P le -> ow_facts bm MWF m ->
       eval_expr ge empty_env le m a v -> P (PTree.set id v le)) ->
    (forall lv rhs le m t le' m' out,
       store_ok lv rhs = true -> P le ->
       exec_stmt function_entry2 ge empty_env le m (Sassign lv rhs) t le' m' out ->
       ow_facts bm MWF m -> ow_facts bm MWF m') ->
    (forall optid a al le m t le' m' out,
       call_ok optid a al = true -> P le ->
       exec_stmt function_entry2 ge empty_env le m (Scall optid a al) t le' m' out ->
       ow_facts bm MWF m -> ow_facts bm MWF m' /\ P le') ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m (Internal f) vargs t m' vres ->
      (forall le1, bind_parameter_temps (fn_params f) vargs
                     (create_undef_temps (fn_temps f)) = Some le1 -> P le1) ->
      ow_facts bm MWF m -> ow_facts bm MWF m'.
Proof.
  intros ge MWF bm f P set_ok store_ok call_ok Hvars Hchk Hset Hst Hca
         m vargs t m' vres Hevf HP0 Hf0.
  inv Hevf.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
  inv Hentry.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    rewrite Hvars in Ha; inv Ha end.
  match goal with Hb : bind_parameter_temps _ _ _ = Some ?LE |- _ =>
    pose proof (HP0 LE Hb) as HP1 end.
  destruct (tw_walk ge empty_env bm MWF P set_ok store_ok call_ok Hset Hst Hca
              _ _ _ _ _ _ _ _ Hbody eq_refl Hchk HP1 Hf0) as (Hf1 & _).
  change (blocks_of_env ge empty_env) with (@nil (block * Z * Z)) in Hfree.
  cbn [Mem.free_list] in Hfree. injection Hfree as <-.
  exact Hf1.
Qed.

(* ---------------------------------------------------------------------- *)
(* 2. segmented_to_virtual returns a non-pointer.                          *)
(* ---------------------------------------------------------------------- *)

(* expressions whose value is never a pointer: an integer OR, under casts *)
Fixpoint rnp_expr (a : expr) : bool :=
  match a with
  | Ecast a' _ => rnp_expr a'
  | Ebinop Oor _ _ _ => true
  | _ => false
  end.

Lemma rnp_expr_ok : forall (ge : genv) e le m a v,
    eval_expr ge e le m a v -> rnp_expr a = true -> nonptr v.
Proof.
  intros ge e le m a. induction a; intros v Hev Hr; cbn [rnp_expr] in Hr;
    try discriminate Hr.
  - (* Ebinop *)
    destruct b; try discriminate Hr.
    inversion Hev; subst;
      [ | match goal with Hl : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ =>
            inversion Hl end ].
    match goal with Hb : sem_binary_operation _ Oor _ _ _ _ _ = Some _ |- _ =>
      cbn [sem_binary_operation] in Hb;
      exact (ActWriterSurface.sem_or_nonptr _ _ _ _ _ _ Hb) end.
  - (* Ecast *)
    inversion Hev; subst;
      [ | match goal with Hl : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ =>
            inversion Hl end ].
    match goal with Hx : eval_expr _ _ _ _ a _, Hc : sem_cast _ _ _ _ = Some _ |- _ =>
      exact (ActWriterSurface.sem_cast_nonptr_pres _ _ _ _ _ Hc (IHa _ Hx Hr)) end.
Qed.

Fixpoint rnp_chk (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue | Sset _ _ | Sassign _ _ | Scall _ _ _
  | Sreturn None => true
  | Sreturn (Some a) => rnp_expr a
  | Ssequence s1 s2 => rnp_chk s1 && rnp_chk s2
  | Sifthenelse _ s1 s2 => rnp_chk s1 && rnp_chk s2
  | _ => false
  end.

Lemma rnp_walk : forall (ge : genv) e le m s t le' m' out,
    exec_stmt function_entry2 ge e le m s t le' m' out -> rnp_chk s = true ->
    forall v ty, out = Out_return (Some (v, ty)) -> nonptr v.
Proof.
  intros ge e le m s t le' m' out Hexec.
  induction Hexec; intros Hchk v0 ty0 Hout; cbn [rnp_chk] in Hchk;
    try discriminate Hchk; try discriminate Hout.
  - apply andb_prop in Hchk as [_ H2]. exact (IHHexec2 H2 _ _ Hout).
  - apply andb_prop in Hchk as [H1 _]. exact (IHHexec H1 _ _ Hout).
  - apply andb_prop in Hchk as [H1 H2].
    exact (IHHexec ltac:(destruct b; assumption) _ _ Hout).
  - injection Hout as -> _.
    match goal with Hx : eval_expr _ _ _ _ a _ |- _ => exact (rnp_expr_ok _ _ _ _ _ _ Hx Hchk) end.
Qed.

Lemma s2v_rnp : rnp_chk (fn_body memory.f_segmented_to_virtual) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma s2v_ret_nonptr : forall (ge : genv) m vargs t m' vres,
    eval_funcall function_entry2 ge m (Internal memory.f_segmented_to_virtual)
      vargs t m' vres -> nonptr vres.
Proof.
  intros ge m vargs t m' vres Hevf. inv Hevf.
  match goal with Ho : outcome_result_value _ _ _ _ |- _ => rename Ho into Hout end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
  change (fn_return memory.f_segmented_to_virtual) with (tptr tvoid) in Hout.
  destruct out as [ | | | [[v' t']|]]; cbn in Hout; try contradiction.
  destruct Hout as (_ & Hc).
  exact (ActWriterSurface.sem_cast_nonptr_pres _ _ _ _ _ Hc
           (rnp_walk _ _ _ _ _ _ _ _ _ Hbody s2v_rnp _ _ eq_refl)).
Qed.

(* ---------------------------------------------------------------------- *)
(* 3. The recognizer for the three bodies.                                  *)
(* ---------------------------------------------------------------------- *)

Definition oh_pts : list ident :=
  [object_helpers._obj; object_helpers._t'3; object_helpers._t'1].

Definition oh_P (SafeB : block -> Prop) (le : temp_env) : Prop :=
  forall t b o, mem_id t oh_pts = true -> le ! t = Some (Vptr b o) -> SafeB b.

(* t'3 = gCurrentObject *)
Definition gco_expr (a : expr) : bool :=
  match a with
  | Evar x (Tpointer _ _) => Pos.eqb x object_helpers._gCurrentObject
  | _ => false
  end.

Definition oh_set_ok (id : ident) (a : expr) : bool :=
  negb (Pos.eqb id object_helpers._obj) && negb (Pos.eqb id object_helpers._t'1)
  && (negb (Pos.eqb id object_helpers._t'3) || gco_expr a).

Definition safe_rhs (rhs : expr) : bool :=
  match rhs with
  | Etempvar t _ => mem_id t oh_pts
  | Econst_int _ _ => true
  | _ => false
  end.

Definition oh_store_ok (lv rhs : expr) : bool :=
  match chain_root_l lv with
  | Some t => Pos.eqb t object_helpers._obj && MtxfBody.is_byval (typeof lv)
              && (nonptr_scalar (typeof lv) || safe_rhs rhs)
  | None => false
  end.

(* t'1 = segmented_to_virtual(..) *)
Definition oh_call_ok (optid : option ident) (a : expr) (al : list expr) : bool :=
  match optid, a with
  | Some ti, Evar f (Tfunction _ _ _) =>
      Pos.eqb ti object_helpers._t'1 && Pos.eqb f object_helpers._segmented_to_virtual
  | _, _ => false
  end.

(* NON-VACUITY: the recognizer accepts the three REAL generated bodies *)
Lemma omfd_chk :
  tw_chk oh_set_ok oh_store_ok oh_call_ok
    (fn_body object_helpers.f_obj_mark_for_deletion) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma scale_chk :
  tw_chk oh_set_ok oh_store_ok oh_call_ok (fn_body object_helpers.f_obj_scale) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma osh_chk :
  tw_chk oh_set_ok oh_store_ok oh_call_ok
    (fn_body object_helpers.f_obj_set_held_state) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma oh_dm_omfd :
  (prog_defmap object_helpers.prog) ! mario_actions_cutscene._obj_mark_for_deletion
    = Some (Gfun (Internal object_helpers.f_obj_mark_for_deletion)).
Proof. vm_compute. reflexivity. Qed.
Lemma oh_dm_scale :
  (prog_defmap object_helpers.prog) ! mario_actions_cutscene._obj_scale
    = Some (Gfun (Internal object_helpers.f_obj_scale)).
Proof. vm_compute. reflexivity. Qed.
Lemma oh_dm_osh :
  (prog_defmap object_helpers.prog) ! interaction._obj_set_held_state
    = Some (Gfun (Internal object_helpers.f_obj_set_held_state)).
Proof. vm_compute. reflexivity. Qed.
Lemma mem_dm_s2v :
  (prog_defmap memory.prog) ! object_helpers._segmented_to_virtual
    = Some (Gfun (Internal memory.f_segmented_to_virtual)).
Proof. vm_compute. reflexivity. Qed.
Lemma gco_safe_sym : mem_id object_helpers._gCurrentObject safe_ptr_syms = true.
Proof. vm_compute. reflexivity. Qed.

(* the entry invariant: obj is the cs-gated arg0, t'3 / t'1 start undefined *)
Lemma oh_P_entry : forall (SafeB : block -> Prop) ty ps temps vargs le1,
    ~ In object_helpers._obj (var_names ps) ->
    ~ In object_helpers._t'3 (var_names ps) ->
    ~ In object_helpers._t'1 (var_names ps) ->
    bind_parameter_temps ((object_helpers._obj, ty) :: ps) vargs
      (create_undef_temps temps) = Some le1 ->
    arg0_cond_safe SafeB vargs ->
    oh_P SafeB le1.
Proof.
  intros SafeB ty ps temps vargs le1 Hn0 Hn3 Hn1 Hb Harg t b o Ht Hle.
  destruct vargs as [| v0 vr]; [ discriminate Hb | ].
  unfold oh_pts in Ht. cbn [mem_id existsb] in Ht.
  apply orb_true_iff in Ht as [Ht | Ht];
    [ apply Pos.eqb_eq in Ht; subst t
    | apply orb_true_iff in Ht as [Ht | Ht];
      [ apply Pos.eqb_eq in Ht; subst t
      | rewrite orb_false_r in Ht; apply Pos.eqb_eq in Ht; subst t ] ].
  - rewrite (bind_parameter_temps_head _ _ _ _ _ _ _ Hn0 Hb) in Hle.
    injection Hle as ->. exact (Harg b o eq_refl).
  - rewrite (bind_parameter_temps_gso _ _ _ _ _ Hb) in Hle;
      [ | cbn [var_names map fst]; intros [E | Hin];
          [ discriminate E | exact (Hn3 Hin) ] ].
    apply MtxfBody.create_undef_temps_get in Hle. discriminate Hle.
  - rewrite (bind_parameter_temps_gso _ _ _ _ _ Hb) in Hle;
      [ | cbn [var_names map fst]; intros [E | Hin];
          [ discriminate E | exact (Hn1 Hin) ] ].
    apply MtxfBody.create_undef_temps_get in Hle. discriminate Hle.
Qed.

(* ---------------------------------------------------------------------- *)
(* 4. The rows, at the concrete MWF_real.                                   *)
(* ---------------------------------------------------------------------- *)

Section ObjHelperRows.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variables bm bc : block.
  Variable oc0 : ptrofs.
  Variable SafeB : block -> Prop.
  (* the Twelve capstone's own facts *)
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hspawn : exists init, spawn_ok lp init bm bc oc0.

  Let MWF := MWF_real lp bm bc oc0 SafeB.
  Let NoA := fun m => ctl_a_clear m bm.

  Lemma oh_Hbc_bm : bc <> bm.
  Proof. destruct Hspawn as (init & Hs). exact (spawn_Hbc_bm lp init bm bc oc0 Hs). Qed.
  Lemma oh_not_bm : forall b, SafeB b -> b <> bm.
  Proof. destruct Hspawn as (init & Hs). exact (safeb_not_bm lp init bm bc oc0 SafeB Hs HSafeB_syms). Qed.
  Lemma oh_not_bc : ~ SafeB bc.
  Proof. destruct Hspawn as (init & Hs). exact (safeb_not_bc lp init bm bc oc0 SafeB Hs HSafeB_syms). Qed.
  Lemma oh_gms : forall gb,
      Genv.find_symbol (lp_ge lp) mario._gMarioState = Some gb ->
      gb <> bm /\ gb <> bc /\ ~ SafeB gb.
  Proof. destruct Hspawn as (init & Hs). exact (gms_blk lp init bm bc oc0 SafeB Hs HSafeB_syms). Qed.
  Lemma oh_gtimer : forall gb,
      Genv.find_symbol (lp_ge lp) interaction._gGlobalTimer = Some gb ->
      gb <> bm /\ gb <> bc /\ ~ SafeB gb.
  Proof. destruct Hspawn as (init & Hs). exact (gtimer_blk lp init bm bc oc0 SafeB Hs HSafeB_syms). Qed.
  Lemma oh_table : forall tb,
      Genv.find_symbol (lp_ge lp) interaction._sInteractionHandlers = Some tb ->
      tb <> bm /\ tb <> bc /\ ~ SafeB tb.
  Proof. destruct Hspawn as (init & Hs). exact (table_blk lp init bm bc oc0 SafeB Hs HSafeB_syms). Qed.
  Lemma oh_ktab : forall gid kb,
      mem_id gid knockback_table_ids = true ->
      Genv.find_symbol (lp_ge lp) gid = Some kb ->
      kb <> bm /\ kb <> bc /\ ~ SafeB kb.
  Proof. destruct Hspawn as (init & Hs). exact (ktab_blk lp init bm bc oc0 SafeB Hs HSafeB_syms). Qed.

  (* a SafeB-if-pointer store into a SafeB block keeps the carried facts *)
  Lemma oh_safe_store : forall b ch z v m1 m2,
      SafeB b -> (forall bb oo, v = Vptr bb oo -> SafeB bb) ->
      Mem.store ch m1 b z v = Some m2 -> ow_facts bm MWF m1 -> ow_facts bm MWF m2.
  Proof.
    intros b ch z v m1 m2 Hs Hv Hst (Hvb & Hsat & HM).
    split; [ eauto using Mem.store_valid_block_1 | split ].
    - eapply action_sat_unchanged_on with (m := m1); [ | exact Hvb | exact Hsat ].
      eapply Mem.store_unchanged_on; [ exact Hst | ].
      intros i _ [Hb _]. exact (oh_not_bm b Hs Hb).
    - exact (mwf_real_chase_ptr lp bm bc oc0 SafeB oh_Hbc_bm oh_not_bm oh_not_bc oh_gms
               oh_gtimer oh_table oh_ktab _ _ _ _ _ _ HM Hs Hv Hst).
  Qed.

  Lemma oh_store : forall lv rhs le m t le' m' out,
      oh_store_ok lv rhs = true -> oh_P SafeB le ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m (Sassign lv rhs) t le' m' out ->
      ow_facts bm MWF m -> ow_facts bm MWF m'.
  Proof.
    intros lv rhs le m t le' m' out Hok HP Hx Hf.
    unfold oh_store_ok in Hok.
    destruct (chain_root_l lv) as [tr|] eqn:Hcr; [ | discriminate Hok ].
    apply andb_prop in Hok as [Hok Hval]. apply andb_prop in Hok as [Ht Hbv].
    apply Pos.eqb_eq in Ht. subst tr.
    inv Hx.
    match goal with Hl : eval_lvalue _ _ _ _ lv _ _ _ |- _ =>
      destruct (chain_root_l_block _ _ _ _ _ _ _ _ _ Hcr Hl) as (o0 & Hle) end.
    assert (Hobj : mem_id object_helpers._obj oh_pts = true) by (vm_compute; reflexivity).
    pose proof (HP object_helpers._obj _ _ Hobj Hle) as Hsb.
    (* the stored value is SafeB if it is a pointer *)
    match goal with
    | Hr : eval_expr _ _ _ _ rhs ?v2, Hc : sem_cast ?v2 _ _ _ = Some ?v |- _ =>
      assert (Hsv : forall bb oo, v = Vptr bb oo -> SafeB bb)
    end.
    { intros bb oo ->.
      apply orb_true_iff in Hval as [Hnp | Hsr].
      - match goal with Hc : sem_cast _ _ _ _ = Some (Vptr _ _) |- _ =>
          exfalso; exact (sem_cast_to_nonptr_scalar _ _ _ _ _ Hnp Hc bb oo eq_refl) end.
      - match goal with Hc : sem_cast _ _ _ _ = Some (Vptr _ _) |- _ =>
          pose proof (sem_cast_vptr_inv _ _ _ _ _ _ Hc) as Ev end.
        subst.
        destruct rhs as [ ii ity | | | | tx tty | | | | | | | | | ]; try discriminate Hsr.
        + match goal with Hr : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
            inversion Hr; subst;
            try match goal with Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                  inversion Hl end end.
        + cbn [safe_rhs] in Hsr.
          match goal with Hr : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
            inversion Hr; subst;
            try match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ =>
                  inversion Hl end end.
          match goal with Hg : _ ! _ = Some (Vptr bb oo) |- _ => exact (HP _ _ _ Hsr Hg) end. }
    match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Ha end.
    - match goal with Hst : Mem.storev _ _ _ _ = Some _ |- _ =>
        unfold Mem.storev in Hst; exact (oh_safe_store _ _ _ _ _ _ Hsb Hsv Hst Hf) end.
    - unfold MtxfBody.is_byval in Hbv.
      match goal with Hc : access_mode _ = By_copy |- _ => rewrite Hc in Hbv; discriminate Hbv end.
    - match goal with Hb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hb end.
      match goal with Hst : Mem.storev _ _ _ _ = Some _ |- _ =>
        unfold Mem.storev in Hst;
        refine (oh_safe_store _ _ _ _ _ _ Hsb _ Hst Hf); intros bb oo E; discriminate E end.
  Qed.

  Lemma oh_set : forall id a le m v,
      oh_set_ok id a = true -> oh_P SafeB le -> ow_facts bm MWF m ->
      eval_expr (lp_ge lp) empty_env le m a v -> oh_P SafeB (PTree.set id v le).
  Proof.
    intros id a le m v Hok HP (_ & _ & HM) Hev t b o Ht Hle.
    unfold oh_set_ok in Hok.
    apply andb_prop in Hok as [Hok Hg]. apply andb_prop in Hok as [Hn0 Hn1].
    destruct (peq t id) as [-> | Hne].
    - rewrite PTree.gss in Hle. injection Hle as ->.
      unfold oh_pts in Ht. cbn [mem_id existsb] in Ht.
      apply negb_true_iff in Hn0. apply negb_true_iff in Hn1.
      rewrite Hn0, Hn1 in Ht. cbn [orb] in Ht. rewrite orb_false_r in Ht.
      rewrite Ht in Hg. cbn [negb orb] in Hg.
      apply Pos.eqb_eq in Ht. subst id.
      destruct a as [ | | | | | | | | | | | | | ]; try discriminate Hg.
      (* a = Evar x ty: the gCurrentObject load *)
      match type of Hg with gco_expr (Evar ?x ?ty) = true =>
        destruct ty as [ | | | | pt pa | | | | ]; try discriminate Hg;
        cbn [gco_expr] in Hg; apply Pos.eqb_eq in Hg; subst x end.
      inversion Hev; subst.
      match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inversion Hl; subst end.
      + match goal with Hz : empty_env ! _ = Some _ |- _ => rewrite PTree.gempty in Hz; discriminate Hz end.
      + match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inversion Hd; subst end.
        * match goal with Ha : access_mode _ = By_value _ |- _ => cbn in Ha; injection Ha as <- end.
          match goal with Hs : Genv.find_symbol _ _ = Some ?gb,
                          Hld : Mem.loadv _ _ _ = Some (Vptr b o) |- _ =>
            pose proof (proj2 (proj2 HSafeB_syms) _ _ gco_safe_sym Hs) as Hgs;
            exact (mwf_real_chase_step lp bm bc oc0 SafeB _ _ _ _ _ HM Hgs Hld) end.
        * match goal with Ha : access_mode _ = By_reference |- _ => discriminate Ha end.
        * match goal with Ha : access_mode _ = By_copy |- _ => discriminate Ha end.
    - rewrite PTree.gso in Hle by exact Hne. exact (HP _ _ _ Ht Hle).
  Qed.

  Lemma oh_call : forall optid a al le m t le' m' out,
      oh_call_ok optid a al = true -> oh_P SafeB le ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m (Scall optid a al) t le' m' out ->
      ow_facts bm MWF m -> ow_facts bm MWF m' /\ oh_P SafeB le'.
  Proof.
    intros optid a al le m t le' m' out Hok HP Hx Hf.
    destruct optid as [ti|]; [ | discriminate Hok ].
    destruct a as [ | | | | fid fty | | | | | | | | | ]; try discriminate Hok.
    destruct fty as [ | | | | | | targs tres tcc | | ]; try discriminate Hok.
    cbn [oh_call_ok] in Hok. apply andb_prop in Hok as [Hti Hfid].
    apply Pos.eqb_eq in Hti. apply Pos.eqb_eq in Hfid. subst ti fid.
    inv Hx.
    match goal with Hcf : classify_fun _ = fun_case_f _ _ _ |- _ =>
      cbn in Hcf; injection Hcf as <- <- <- end.
    match goal with Hee : eval_expr _ _ _ _ (Evar _ _) ?vf |- _ =>
      destruct (evar_fun_val _ _ _ _ _ _ _ _ _ Hee (PTree.gempty _ _)) as (lf & Hsy & ->) end.
    destruct (linkorder_resolves_funct lp _ _ _ (linked12_LO_memory lp H12) mem_dm_s2v)
      as (b' & Hs' & Hff').
    unfold lp_ge in Hsy. rewrite Hsy in Hs'. injection Hs' as <-.
    assert (Hpure : cpure2_chk (fn_body memory.f_segmented_to_virtual) = true)
      by (vm_compute; reflexivity).
    match goal with Hff : Genv.find_funct _ _ = Some ?fd |- _ =>
      unfold lp_ge in Hff; rewrite Hff' in Hff; injection Hff as <- end.
    match goal with Hfc : eval_funcall _ _ _ (Internal memory.f_segmented_to_virtual) _ _ _ _ |- _ =>
      pose proof (cpure2_funcall_memid _ memory.f_segmented_to_virtual eq_refl Hpure
                    (mp_resolves lp (linked12_LO_math lp H12) _ _ math_dm_atan2_lookup)
                    _ _ _ _ _ Hfc) as Em;
      pose proof (s2v_ret_nonptr _ _ _ _ _ _ Hfc) as Hnp
    end.
    subst. split; [ exact Hf | ].
    intros t0 b o Ht0 Hle. cbn [set_opttemp] in Hle.
    destruct (peq t0 object_helpers._t'1) as [-> | Hne].
    - rewrite PTree.gss in Hle. injection Hle as Ev. exfalso. exact (Hnp _ _ Ev).
    - rewrite PTree.gso in Hle by exact Hne. exact (HP _ _ _ Ht0 Hle).
  Qed.

  Lemma oh_body_frame : forall f,
      fn_vars f = nil ->
      tw_chk oh_set_ok oh_store_ok oh_call_ok (fn_body f) = true ->
      forall ty ps,
      fn_params f = (object_helpers._obj, ty) :: ps ->
      ~ In object_helpers._obj (var_names ps) ->
      ~ In object_helpers._t'3 (var_names ps) ->
      ~ In object_helpers._t'1 (var_names ps) ->
      forall m vargs t m' vres,
        eval_funcall function_entry2 (lp_ge lp) m (Internal f) vargs t m' vres ->
        arg0_cond_safe SafeB vargs ->
        ow_facts bm MWF m -> ow_facts bm MWF m'.
  Proof.
    intros f Hv Hchk ty ps Hps Hn0 Hn3 Hn1 m vargs t m' vres Hevf Harg Hf.
    refine (tw_body_frame (lp_ge lp) MWF bm f (oh_P SafeB) oh_set_ok oh_store_ok oh_call_ok
              Hv Hchk oh_set oh_store oh_call m vargs t m' vres Hevf _ Hf).
    intros le1 Hb. rewrite Hps in Hb.
    exact (oh_P_entry SafeB ty ps _ vargs le1 Hn0 Hn3 Hn1 Hb Harg).
  Qed.

  Ltac notin := cbn [var_names map fst]; intros Hin;
    repeat (destruct Hin as [Hin | Hin]; [ discriminate Hin | ]); exact Hin.

  Lemma Hcsp_omfd_proved :
    call_pres_ext_cs lp bm NoA MWF SafeB mario_actions_cutscene._obj_mark_for_deletion.
  Proof.
    intros fd m0 vargs0 t0 m1 vres0 Hevf Hres Harg _ HM Hv Hsat.
    pose proof (resolves_pin_fd lp _ _ _ _ (linked12_LO_object_helpers lp H12) oh_dm_omfd Hres)
      as ->.
    destruct (oh_body_frame object_helpers.f_obj_mark_for_deletion eq_refl omfd_chk
                (tptr (Tstruct object_helpers._Object noattr)) nil eq_refl
                ltac:(notin) ltac:(notin) ltac:(notin)
                _ _ _ _ _ Hevf Harg (conj Hv (conj Hsat HM))) as (Hv' & Hs' & HM').
    exact (conj Hv' (conj Hs' (conj HM' (mwf_real_ctl lp bm bc oc0 SafeB _ HM')))).
  Qed.

  Lemma Hcsp_scale_proved :
    call_pres_ext_cs lp bm NoA MWF SafeB mario_actions_cutscene._obj_scale.
  Proof.
    intros fd m0 vargs0 t0 m1 vres0 Hevf Hres Harg _ HM Hv Hsat.
    pose proof (resolves_pin_fd lp _ _ _ _ (linked12_LO_object_helpers lp H12) oh_dm_scale Hres)
      as ->.
    destruct (oh_body_frame object_helpers.f_obj_scale eq_refl scale_chk
                (tptr (Tstruct object_helpers._Object noattr))
                ((object_helpers._scale, tfloat) :: nil) eq_refl
                ltac:(notin) ltac:(notin) ltac:(notin)
                _ _ _ _ _ Hevf Harg (conj Hv (conj Hsat HM))) as (Hv' & Hs' & HM').
    exact (conj Hv' (conj Hs' (conj HM' (mwf_real_ctl lp bm bc oc0 SafeB _ HM')))).
  Qed.

  Lemma Hcsp_osh_proved :
    call_pres_ext_cs lp bm NoA MWF SafeB interaction._obj_set_held_state.
  Proof.
    intros fd m0 vargs0 t0 m1 vres0 Hevf Hres Harg _ HM Hv Hsat.
    pose proof (resolves_pin_fd lp _ _ _ _ (linked12_LO_object_helpers lp H12) oh_dm_osh Hres)
      as ->.
    destruct (oh_body_frame object_helpers.f_obj_set_held_state eq_refl osh_chk
                (tptr (Tstruct object_helpers._Object noattr))
                ((object_helpers._heldBehavior, tptr tuint) :: nil) eq_refl
                ltac:(notin) ltac:(notin) ltac:(notin)
                _ _ _ _ _ Hevf Harg (conj Hv (conj Hsat HM))) as (Hv' & Hs' & HM').
    exact (conj Hv' (conj Hs' (conj HM' (mwf_real_ctl lp bm bc oc0 SafeB _ HM')))).
  Qed.
End ObjHelperRows.
