(* ====================================================================== *)
(* spine (via BhvStep's row 40): OBJECTS -- ANIMATE's callee,             *)
(* geo_obj_init_animation (graph_node.c), run by its real body:          *)
(*   animSegmented = segmented_to_virtual(animPtrAddr);                  *)
(*   anim = segmented_to_virtual( *animSegmented);                       *)
(*   if (node->animInfo.curAnim != anim) {                               *)
(*     curAnim = anim; animFrame = startFrame + (flags & 2 ? 1 : -1);     *)
(*     animAccel = 0; animYTrans = 0; }                                  *)
(* goia_real: the run writes nothing or exactly these four cells of the   *)
(* node's animInfo (@56: curAnim @+4, animFrame @+8, animAccel @+16,      *)
(* animYTrans @+2), and curAnim gets the pointer *animPtrAddr held.      *)
(* segmented_to_virtual is the identity (TRUST 2.2), run on its real     *)
(* body (memory.c).  Nothing is assumed about the values: the run itself *)
(* gives every load it makes.                                            *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory
  Globalenvs Ctypes Cop Clight ClightBigstep Clightdefs Events Errors.
From SM64.Generated Require graph_node memory.
From SM64.Proofs.WMotRRequiresA Require RenderAnim ObjLoop ObjAlloc.

Import ListNotations.
Local Open Scope Z_scope.
Local Transparent Archi.ptr64.

Module RA := RenderAnim.
Module GN := SM64.Generated.graph_node.

(* p + i, p : T *, i : int, landing on a pointer: p was a pointer (ILP32) *)
Lemma padd_inv : forall (ce : composite_env) v t i m b o,
  sem_binary_operation ce Oadd v (tptr (tptr t)) (Vint i) tint m = Some (Vptr b o) ->
  exists o0, v = Vptr b o0 /\ o = Ptrofs.add o0 (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_ints i)).
Proof.
  intros ce v t i m b o H. destruct v; cbn in H; try discriminate H.
  injection H as <- <-. eauto.
Qed.

Section GOIA.
  Variable ge : genv.
  Hypothesis Hcenv : forall id co, (prog_comp_env GN.prog) ! id = Some co -> (genv_cenv ge) ! id = Some co.
  Hypothesis Hs2v : forall b fd, Genv.find_symbol ge GN._segmented_to_virtual = Some b ->
    Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd -> fd = Internal memory.f_segmented_to_virtual.

  Ltac getn H := repeat first [ rewrite PTree.gss in H | rewrite PTree.gso in H by RA.neq ].
  Ltac fo_tac := apply (RA.fo_ok_lift (prog_comp_env GN.prog)); [ vm_compute; reflexivity | exact Hcenv ].

  Lemma fo_ai : forall co, (genv_cenv ge) ! GN._GraphNodeObject = Some co ->
    field_offset ge GN._animInfo (co_members co) = OK (56, Full).
  Proof. fo_tac. Qed.
  Lemma fo_ca : forall co, (genv_cenv ge) ! GN._AnimInfo = Some co ->
    field_offset ge GN._curAnim (co_members co) = OK (4, Full).
  Proof. fo_tac. Qed.
  Lemma fo_af : forall co, (genv_cenv ge) ! GN._AnimInfo = Some co ->
    field_offset ge GN._animFrame (co_members co) = OK (8, Full).
  Proof. fo_tac. Qed.
  Lemma fo_aa : forall co, (genv_cenv ge) ! GN._AnimInfo = Some co ->
    field_offset ge GN._animAccel (co_members co) = OK (16, Full).
  Proof. fo_tac. Qed.
  Lemma fo_ay : forall co, (genv_cenv ge) ! GN._AnimInfo = Some co ->
    field_offset ge GN._animYTrans (co_members co) = OK (2, Full).
  Proof. fo_tac. Qed.
  Lemma fo_fl : forall co, (genv_cenv ge) ! GN._Animation = Some co ->
    field_offset ge GN._flags (co_members co) = OK (0, Full).
  Proof. fo_tac. Qed.
  Lemma fo_sf : forall co, (genv_cenv ge) ! GN._Animation = Some co ->
    field_offset ge GN._startFrame (co_members co) = OK (4, Full).
  Proof. fo_tac. Qed.

  (* p->f1.f2, p a temp holding a struct pointer, f1 a struct member *)
  Lemma ev_fld2 : forall e le m x S1 f1 S2 f2 ty v ch d1 d2,
    (forall co, (genv_cenv ge) ! S1 = Some co -> field_offset ge f1 (co_members co) = OK (d1, Full)) ->
    (forall co, (genv_cenv ge) ! S2 = Some co -> field_offset ge f2 (co_members co) = OK (d2, Full)) ->
    access_mode ty = By_value ch ->
    eval_expr ge e le m (Efield (Efield (Ederef (Etempvar x (tptr (Tstruct S1 noattr))) (Tstruct S1 noattr))
                                  f1 (Tstruct S2 noattr)) f2 ty) v ->
    exists b o, le ! x = Some (Vptr b o)
      /\ Mem.loadv ch m (Vptr b (Ptrofs.add (Ptrofs.add o (Ptrofs.repr d1)) (Ptrofs.repr d2))) = Some v.
  Proof.
    intros e le m x S1 f1 S2 f2 ty v ch d1 d2 Hf1 Hf2 Ham H.
    inv H. match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hl end.
    all: try (match goal with Ht : typeof _ = Tunion _ _ |- _ => cbn in Ht; discriminate Ht end).
    match goal with Ht : typeof _ = Tstruct _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
    match goal with Hc : (genv_cenv ge) ! S2 = Some ?co, Hf : field_offset _ f2 _ = OK _ |- _ =>
      rewrite (Hf2 _ Hc) in Hf; injection Hf; intros; subst end.
    match goal with He : eval_expr _ _ _ _ (Efield _ _ _) _ |- _ => inv He end.
    match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hl end.
    all: try (match goal with Ht : typeof _ = Tunion _ _ |- _ => cbn in Ht; discriminate Ht end).
    match goal with Ht : typeof _ = Tstruct _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
    match goal with Hc : (genv_cenv ge) ! S1 = Some ?co, Hf : field_offset _ f1 _ = OK _ |- _ =>
      rewrite (Hf1 _ Hc) in Hf; injection Hf; intros; subst end.
    cbn [typeof] in *. match goal with Hd : deref_loc (Tstruct _ _) _ _ _ _ _ |- _ => inv Hd end;
      cbn in *; try discriminate.
    match goal with He : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv He end.
    match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
    cbn [typeof] in *. match goal with Hd : deref_loc (Tstruct _ _) _ _ _ _ _ |- _ => inv Hd end;
      cbn in *; try discriminate.
    match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply RA.ev_temp in Ht end.
    do 2 eexists; split; [ eassumption | ].
    match goal with Hd : deref_loc ty _ _ _ _ _ |- _ => inv Hd end; try congruence.
    repeat match goal with H1 : access_mode _ = By_value ?c |- _ =>
      tryif constr_eq H1 Ham then fail else (rewrite Ham in H1; injection H1; intros; subst; clear H1) end.
    assumption.
  Qed.

  Lemma lv_fld2 : forall e le m x S1 f1 S2 f2 ty b' o' bf d1 d2,
    (forall co, (genv_cenv ge) ! S1 = Some co -> field_offset ge f1 (co_members co) = OK (d1, Full)) ->
    (forall co, (genv_cenv ge) ! S2 = Some co -> field_offset ge f2 (co_members co) = OK (d2, Full)) ->
    eval_lvalue ge e le m (Efield (Efield (Ederef (Etempvar x (tptr (Tstruct S1 noattr))) (Tstruct S1 noattr))
                                    f1 (Tstruct S2 noattr)) f2 ty) b' o' bf ->
    exists o, le ! x = Some (Vptr b' o) /\ o' = Ptrofs.add (Ptrofs.add o (Ptrofs.repr d1)) (Ptrofs.repr d2)
      /\ bf = Full.
  Proof.
    intros e le m x S1 f1 S2 f2 ty b' o' bf d1 d2 Hf1 Hf2 H.
    inv H. all: try (match goal with Ht : typeof _ = Tunion _ _ |- _ => cbn in Ht; discriminate Ht end).
    match goal with Ht : typeof _ = Tstruct _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
    match goal with Hc : (genv_cenv ge) ! S2 = Some ?co, Hf : field_offset _ f2 _ = OK _ |- _ =>
      rewrite (Hf2 _ Hc) in Hf; injection Hf; intros; subst end.
    match goal with He : eval_expr _ _ _ _ (Efield _ _ _) _ |- _ => inv He end.
    match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hl end.
    all: try (match goal with Ht : typeof _ = Tunion _ _ |- _ => cbn in Ht; discriminate Ht end).
    match goal with Ht : typeof _ = Tstruct _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
    match goal with Hc : (genv_cenv ge) ! S1 = Some ?co, Hf : field_offset _ f1 _ = OK _ |- _ =>
      rewrite (Hf1 _ Hc) in Hf; injection Hf; intros; subst end.
    cbn [typeof] in *. match goal with Hd : deref_loc (Tstruct _ _) _ _ _ _ _ |- _ => inv Hd end;
      cbn in *; try discriminate.
    match goal with He : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv He end.
    match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
    cbn [typeof] in *. match goal with Hd : deref_loc (Tstruct _ _) _ _ _ _ _ |- _ => inv Hd end;
      cbn in *; try discriminate.
    match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply RA.ev_temp in Ht end.
    eauto.
  Qed.

  (* *p, p a temp of pointer type *)
  Lemma ev_deref1 : forall e le m x ty v ch, access_mode ty = By_value ch ->
    eval_expr ge e le m (Ederef (Etempvar x (tptr ty)) ty) v ->
    exists b o, le ! x = Some (Vptr b o) /\ Mem.loadv ch m (Vptr b o) = Some v.
  Proof.
    intros e le m x ty v ch Ham H. inv H.
    match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
    match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply RA.ev_temp in Ht end.
    cbn [typeof] in *.
    match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end; try congruence.
    all: match goal with H1 : access_mode _ = By_value ?c |- _ =>
      tryif constr_eq H1 Ham then fail else (rewrite Ham in H1; injection H1; intros; subst) end.
    all: eauto.
  Qed.

  (* tmp = segmented_to_virtual(x): the identity on any value it accepts *)
  Lemma s2v_any : forall le m t le' m' out tmp x ty v,
    exec_stmt function_entry2 ge empty_env le m
      (Scall (Some tmp) (Evar GN._segmented_to_virtual (Tfunction [tptr tvoid] (tptr tvoid) cc_default))
         [Etempvar x (tptr ty)]) t le' m' out ->
    le ! x = Some v -> m' = m /\ le' = PTree.set tmp v le /\ out = Out_normal.
  Proof.
    intros le m t le' m' out tmp x ty v H Hx.
    apply RA.call_inv in H as (tya & tyr & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hc & -> & ->).
    cbn in Hcf. injection Hcf as <- <- <-.
    destruct (RA.ev_fun ge empty_env m le _ (Tfunction [tptr tvoid] (tptr tvoid) cc_default) vf
                (PTree.gempty _ _) eq_refl Evf) as (bf & Hs & ->).
    rewrite (Hs2v bf fd Hs Hff) in Hc.
    destruct (ObjLoop.exl1 _ _ _ _ _ _ _ Eal) as (ty1 & v1 & w1 & E1 & -> & Ev1 & C1). injection E1 as <-.
    apply RA.ev_temp in Ev1. rewrite Hx in Ev1. injection Ev1 as <-.
    cbn [typeof] in C1. apply RA.cast_ptr_id in C1. subst w1.
    apply ObjAlloc.fcall_inv0 in Hc as (le1 & le2 & out1 & Hb & Hx2 & Hor); [ | reflexivity ].
    cbn in Hb. injection Hb as <-. cbn [fn_body memory.f_segmented_to_virtual] in Hx2.
    apply RA.ret_inv in Hx2 as (-> & rv & Erv & ->).
    apply RA.ev_cast in Erv as (r0 & Er0 & Cr). apply RA.ev_temp in Er0. rewrite PTree.gss in Er0.
    injection Er0 as <-. cbn [typeof] in Cr. apply RA.cast_ptr_id in Cr. subst rv.
    cbn in Hor. destruct Hor as (_ & Hor). cbn [typeof] in Hor. apply RA.cast_ptr_id in Hor. subst vres.
    cbn [set_opttemp]. split; [ reflexivity | split; reflexivity ].
    all: first [ exact tvoid | exact m ].
  Qed.

  Definition AIo (go : ptrofs) (d : Z) : Z :=
    Ptrofs.unsigned (Ptrofs.add (Ptrofs.add go (Ptrofs.repr 56)) (Ptrofs.repr d)).

  (* THE CALLEE: nothing, or the four animInfo cells, curAnim from *animPtrAddr *)
  Theorem goia_real : forall m gb go a2 t m' vr,
    eval_funcall function_entry2 ge m (Internal GN.f_geo_obj_init_animation) [Vptr gb go; a2] t m' vr ->
    exists ab ao, a2 = Vptr ab ao /\
    (m' = m
    \/ exists va v1 v2 v3 m1 m2 m3,
         Mem.loadv Mint32 m (Vptr ab ao) = Some va
         /\ Mem.store Mint32 m gb (AIo go 4) va = Some m1
         /\ Mem.store Mint16signed m1 gb (AIo go 8) v1 = Some m2
         /\ Mem.store Mint32 m2 gb (AIo go 16) v2 = Some m3
         /\ Mem.store Mint16signed m3 gb (AIo go 2) v3 = Some m').
  Proof.
    intros m gb go a2 t m' vr H.
    apply ObjAlloc.fcall_inv0 in H as (le & le' & out & Hb & X & _); [ | reflexivity ].
    cbn [fn_params GN.f_geo_obj_init_animation bind_parameter_temps] in Hb. injection Hb as <-.
    cbn [fn_body GN.f_geo_obj_init_animation] in X.
    apply RA.seq_inv in X as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)];
      [ | exfalso; exact (Xn (ObjLoop.plain_out _ _ _ _ _ _ _ _ _ X1 eq_refl)) ].
    apply RA.seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)];
      [ | exfalso; exact (Xn (ObjLoop.plain_out _ _ _ _ _ _ _ _ _ X3 eq_refl)) ].
    apply s2v_any with (v := a2) in X3 as (-> & -> & _); [ | reflexivity ].
    apply RA.set_inv in X4 as (v4 & Ev4 & -> & -> & _).
    apply RA.ev_temp in Ev4. rewrite PTree.gss in Ev4. injection Ev4 as <-.
    apply RA.seq_inv in X2 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)];
      [ | exfalso; exact (Xn (ObjLoop.plain_out _ _ _ _ _ _ _ _ _ X5 eq_refl)) ].
    apply RA.seq_inv in X5 as [(t7 & le7 & m7 & t8 & X7 & X8) | (X7 & Xn)];
      [ | exfalso; exact (Xn (ObjLoop.plain_out _ _ _ _ _ _ _ _ _ X7 eq_refl)) ].
    apply RA.seq_inv in X7 as [(t9 & le9 & m9 & t10 & X9 & X10) | (X9 & Xn)];
      [ | exfalso; exact (Xn (ObjLoop.plain_out _ _ _ _ _ _ _ _ _ X9 eq_refl)) ].
    apply RA.set_inv in X9 as (va & Eva & -> & -> & _).
    apply (ev_deref1 _ _ _ _ (tptr (Tstruct GN._Animation noattr)) _ Mint32 eq_refl) in Eva as (b1 & o1 & E1 & La).
    rewrite PTree.gss in E1. injection E1 as ->.
    exists b1, o1. split; [ reflexivity | ].
    apply s2v_any with (v := va) in X10 as (-> & -> & _); [ | apply PTree.gss ].
    apply RA.set_inv in X8 as (v8 & Ev8 & -> & -> & _).
    apply RA.ev_temp in Ev8. rewrite PTree.gss in Ev8. injection Ev8 as <-.
    apply RA.seq_inv in X6 as [(u1 & ke1 & n1 & u2 & Y1 & Y2) | (Y1 & Xn)];
      [ | exfalso; exact (Xn (ObjLoop.plain_out _ _ _ _ _ _ _ _ _ Y1 eq_refl)) ].
    apply RA.set_inv in Y1 as (vc & Evc & -> & -> & _).
    apply RA.if_inv in Y2 as (vb & bb & Evb & Hbb & Y2).
    destruct bb.
    2: { apply RA.skip_inv in Y2 as (-> & _ & _). left. reflexivity. }
    right.
    apply RA.seq_inv in Y2 as [(u3 & ke3 & n3 & u4 & Y3 & Y4) | (Y3 & Xn)];
      [ | exfalso; exact (Xn (ObjLoop.plain_out _ _ _ _ _ _ _ _ _ Y3 eq_refl)) ].
    (* curAnim = anim *)
    apply RA.assign_inv in Y3 as (bq & oq & bfq & vq & vq' & Lq & Eq & Cq & Aq & -> & _).
    apply (lv_fld2 _ _ _ _ _ _ _ _ _ _ _ _ _ _ fo_ai fo_ca) in Lq as (oq0 & Eoq & -> & ->).
    getn Eoq. injection Eoq as <- <-.
    apply RA.ev_temp in Eq. getn Eq. injection Eq as <-.
    cbn [typeof] in Cq. apply RA.cast_ptr_id in Cq. subst vq'.
    pose proof (RA.store_by_value _ (tptr (Tstruct GN._Animation noattr)) _ _ _ _ _ _ Mint32 eq_refl eq_refl Aq) as S1.
    apply RA.seq_inv in Y4 as [(u5 & ke5 & n5 & u6 & Y5 & Y6) | (Y5 & Xn)];
      [ | exfalso; exact (Xn (ObjLoop.plain_out _ _ _ _ _ _ _ _ _ Y5 eq_refl)) ].
    apply RA.seq_inv in Y5 as [(u7 & ke7 & n7 & u8 & Y7 & Y8) | (Y7 & Xn)];
      [ | exfalso; exact (Xn (ObjLoop.plain_out _ _ _ _ _ _ _ _ _ Y7 eq_refl)) ].
    apply RA.seq_inv in Y8 as [(u9 & ke9 & n9 & u10 & Y9 & Y10) | (Y9 & Xn)];
      [ | exfalso; exact (Xn (ObjLoop.plain_out _ _ _ _ _ _ _ _ _ Y9 eq_refl)) ].
    (* t'6 = anim->flags; t'3 = flags & 2 ? 1 : -1 (temps only) *)
    apply RA.seq_inv in Y7 as [(u13 & ke13 & n13 & u14 & Z1 & Z2) | (Z1 & Xn)];
      [ | exfalso; exact (Xn (ObjLoop.plain_out _ _ _ _ _ _ _ _ _ Z1 eq_refl)) ].
    apply RA.set_inv in Z1 as (vfl & _ & -> & -> & _).
    apply RA.if_inv in Z2 as (vz & bz & _ & _ & Z2).
    destruct bz; apply RA.set_inv in Z2 as (v3 & _ & -> & -> & _).
    all: apply RA.set_inv in Y9 as (vs & _ & -> & -> & _).
    (* animFrame = startFrame + t'3 *)
    all: apply RA.assign_inv in Y10 as (bf2 & of2 & bff2 & w2 & w2' & Lf & _ & _ & Af & -> & _).
    all: apply (lv_fld2 _ _ _ _ _ _ _ _ _ _ _ _ _ _ fo_ai fo_af) in Lf as (of0 & Eof & -> & ->).
    all: getn Eof; injection Eof as <- <-.
    all: pose proof (RA.store_by_value _ tshort _ _ _ _ _ _ Mint16signed eq_refl eq_refl Af) as S2.
    (* animAccel = 0; animYTrans = 0 *)
    all: apply RA.seq_inv in Y6 as [(u11 & ke11 & n11 & u12 & Y11 & Y12) | (Y11 & Xn)];
      [ | exfalso; exact (Xn (ObjLoop.plain_out _ _ _ _ _ _ _ _ _ Y11 eq_refl)) ].
    all: apply RA.assign_inv in Y11 as (bf3 & of3 & bff3 & w3 & w3' & Lc & _ & _ & Ac & -> & _).
    all: apply (lv_fld2 _ _ _ _ _ _ _ _ _ _ _ _ _ _ fo_ai fo_aa) in Lc as (oc0 & Eoc & -> & ->).
    all: getn Eoc; injection Eoc as <- <-.
    all: pose proof (RA.store_by_value _ tint _ _ _ _ _ _ Mint32 eq_refl eq_refl Ac) as S3.
    all: apply RA.assign_inv in Y12 as (bf4 & of4 & bff4 & w4 & w4' & Ly & _ & _ & Ay & -> & _).
    all: apply (lv_fld2 _ _ _ _ _ _ _ _ _ _ _ _ _ _ fo_ai fo_ay) in Ly as (oy0 & Eoy & -> & ->).
    all: getn Eoy; injection Eoy as <- <-.
    all: pose proof (RA.store_by_value _ tshort _ _ _ _ _ _ Mint16signed eq_refl eq_refl Ay) as S4.
    all: exists va, w2', w3', w4', n3, n5, n11.
    all: exact (conj La (conj S1 (conj S2 (conj S3 S4)))).
  Qed.
End GOIA.
