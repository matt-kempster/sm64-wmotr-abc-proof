(* ====================================================================== *)
(* spine (via BhvStep's row 28): OBJECTS -- bhv_cmd_spawn_child           *)
(* (behavior_script.c, SPAWN_CHILD), run by its real body:                *)
(*   model = gCurBhvCommand[1]; behavior = gCurBhvCommand[2];             *)
(*   child = spawn_object_at_origin(gCurrentObject, 0, model, behavior)   *)
(*     (ObjOrigin.origin_real);                                           *)
(*   obj_copy_pos_and_angle(child, gCurrentObject) (ObjCopy.cpa_ok);      *)
(*   gCurBhvCommand += 3; return BHV_PROC_CONTINUE.                       *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory
  Globalenvs Ctypes Cop Clight ClightBigstep Clightdefs Events Errors.
From compcert Require Linking.
From SM64.Generated Require graph_node spawn_object object_list_processor area math_util memory object_helpers behavior_script.
From SM64.Proofs Require Import SymbolicLinking LinkedTwelve RealFrameLinked.
From SM64.Proofs.WMotRRequiresA Require Import ObjWorld ObjRing ObjAlloc ObjCreate ObjMake ObjGeo ObjOrigin ObjCopy.
From SM64.Proofs.WMotRRequiresA Require ObjSelf RenderAnim ObjLoop.

Import ListNotations.
Local Open Scope Z_scope.
Local Transparent Archi.ptr64.

Module RA := RenderAnim.
Module SO := SM64.Generated.spawn_object.
Module OH := SM64.Generated.object_helpers.
Module BS := SM64.Generated.behavior_script.

(* ---------------------------------------------------------------------- *)
(* 1. The body.                                                            *)
(* ---------------------------------------------------------------------- *)
Definition OTB : type := Tstruct BS._Object noattr.
Definition GCBC : expr := Evar BS._gCurBhvCommand (tptr tuint).
Definition WD (x : ident) (n : Z) : expr :=
  Ederef (Ebinop Oadd (Etempvar x (tptr tuint)) (Econst_int (Int.repr n) tint) (tptr tuint)) tuint.
Definition P1 : statement :=
  Ssequence (Sset BS._t'7 GCBC)
    (Ssequence (Sset BS._t'8 (WD BS._t'7 1)) (Sset BS._model (Ecast (Etempvar BS._t'8 tuint) tuint))).
Definition P2 : statement :=
  Ssequence (Sset BS._t'5 GCBC)
    (Ssequence (Sset BS._t'6 (WD BS._t'5 2)) (Sset BS._behavior (Ecast (Etempvar BS._t'6 tuint) (tptr tvoid)))).
Definition SPC : statement :=
  Scall (Some BS._t'1)
    (Evar BS._spawn_object_at_origin (Tfunction [tptr OTB; tint; tuint; tptr tuint] (tptr OTB) cc_default))
    [Etempvar BS._t'4 (tptr OTB); Econst_int (Int.repr 0) tint; Etempvar BS._model tuint;
     Etempvar BS._behavior (tptr tuint)].
Definition P3 : statement :=
  Ssequence (Ssequence (Sset BS._t'4 (Evar BS._gCurrentObject (tptr OTB))) SPC)
    (Sset BS._child (Etempvar BS._t'1 (tptr OTB))).
Definition CPC : statement :=
  Scall None
    (Evar BS._obj_copy_pos_and_angle (Tfunction [tptr OTB; tptr OTB] tvoid cc_default))
    [Etempvar BS._child (tptr OTB); Etempvar BS._t'3 (tptr OTB)].
Definition P4 : statement := Ssequence (Sset BS._t'3 (Evar BS._gCurrentObject (tptr OTB))) CPC.
Definition P5 : statement :=
  Ssequence (Sset BS._t'2 GCBC)
    (Sassign GCBC (Ebinop Oadd (Etempvar BS._t'2 (tptr tuint)) (Econst_int (Int.repr 3) tint) (tptr tuint))).
Definition RET0 : statement := Sreturn (Some (Econst_int (Int.repr 0) tint)).

Lemma SCB_eq : fn_body BS.f_bhv_cmd_spawn_child =
  Ssequence P1 (Ssequence P2 (Ssequence P3 (Ssequence P4 (Ssequence P5 RET0)))).
Proof. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* 2. Small steps.                                                         *)
(* ---------------------------------------------------------------------- *)
Fixpoint so (s : statement) : bool :=
  match s with
  | Sset _ _ => true
  | Ssequence a b => so a && so b
  | _ => false
  end.

Lemma so_mem : forall (ge : genv) e le m s t le' m' out,
  exec_stmt function_entry2 ge e le m s t le' m' out -> so s = true -> m' = m /\ out = Out_normal.
Proof.
  intros ge e le m s t le' m' out H. induction H; cbn [so]; intros Hs; try discriminate Hs; auto.
  - apply andb_true_iff in Hs as [H1 H2].
    destruct (IHexec_stmt1 H1) as (-> & _). exact (IHexec_stmt2 H2).
  - apply andb_true_iff in Hs as [H1 H2]. destruct (IHexec_stmt H1) as (_ & E). contradiction.
Qed.

Lemma ld_idx : forall (ge : genv) le m x n b o v,
  le ! x = Some (Vptr b o) -> eval_expr ge empty_env le m (WD x n) v ->
  Mem.loadv Mint32 m (Vptr b (Ptrofs.add o (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_ints (Int.repr n))))) = Some v.
Proof.
  intros ge le m x n b o v Hx H. unfold WD in H. inv H.
  match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _, Hd : deref_loc _ _ _ _ _ _ |- _ =>
    inv Hl; inv Hd; cbn in *; try discriminate end.
  match goal with Ha : By_value _ = By_value _ |- _ => injection Ha as <- end.
  match goal with He : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
    apply RA.ev_binop in He as (x1 & x2 & X1 & X2 & X3) end.
  apply RA.ev_temp in X1. rewrite Hx in X1. injection X1 as <-.
  apply RA.ev_const in X2. subst x2. cbn [typeof] in X3.
  assert (E : sem_binary_operation ge Oadd (Vptr b o) (tptr tuint) (Vint (Int.repr n)) tint m
              = Some (Vptr b (Ptrofs.add o (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_ints (Int.repr n)))))) by reflexivity.
  rewrite E in X3. injection X3 as <- <-. assumption.
Qed.

Lemma exl4f : forall (G : genv) e le m a1 a2 a3 a4 tys vs, eval_exprlist G e le m [a1; a2; a3; a4] tys vs ->
  exists t1 t2 t3 t4 v1 v2 v3 v4 w1 w2 w3 w4, tys = [t1; t2; t3; t4] /\ vs = [w1; w2; w3; w4]
    /\ eval_expr G e le m a1 v1 /\ sem_cast v1 (typeof a1) t1 m = Some w1
    /\ eval_expr G e le m a2 v2 /\ sem_cast v2 (typeof a2) t2 m = Some w2
    /\ eval_expr G e le m a3 v3 /\ sem_cast v3 (typeof a3) t3 m = Some w3
    /\ eval_expr G e le m a4 v4 /\ sem_cast v4 (typeof a4) t4 m = Some w4.
Proof.
  intros G e le m a1 a2 a3 a4 tys vs H.
  inv H. match goal with H : eval_exprlist _ _ _ _ _ _ _ |- _ => inv H end.
  match goal with H : eval_exprlist _ _ _ _ _ _ _ |- _ => inv H end.
  match goal with H : eval_exprlist _ _ _ _ _ _ _ |- _ => inv H end.
  match goal with H : eval_exprlist _ _ _ _ _ _ _ |- _ => inv H end.
  do 12 eexists. repeat split; eassumption.
Qed.

Lemma facts_store_other : forall m b' z ch v m' b base ov F,
  Mem.store ch m b' z v = Some m' -> b' <> b -> facts m b base ov F -> facts m' b base ov F.
Proof.
  intros m b' z ch v m' b base ov F Hs Hn HF ch' d s Hin.
  rewrite (Mem.load_store_other _ _ _ _ _ _ Hs); [ exact (HF _ _ _ Hin) | left; exact (not_eq_sym Hn) ].
Qed.

Lemma dm_soo : (prog_defmap OH.prog) ! BS._spawn_object_at_origin = Some (Gfun (Internal OH.f_spawn_object_at_origin)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_cpa : (prog_defmap OH.prog) ! BS._obj_copy_pos_and_angle = Some (Gfun (Internal OH.f_obj_copy_pos_and_angle)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_cp : (prog_defmap OH.prog) ! OH._obj_copy_pos = Some (Gfun (Internal OH.f_obj_copy_pos)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_ca : (prog_defmap OH.prog) ! OH._obj_copy_angle = Some (Gfun (Internal OH.f_obj_copy_angle)).
Proof. vm_compute. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* 3. On the real linked program.                                          *)
(* ---------------------------------------------------------------------- *)
Section LINKED.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Notation G := (lp_ge lp).

  (* SPAWN_CHILD ON THE REAL PROGRAM.  Premises: origin_real's, the command
     pointer (cs, co) in gCurBhvCommand, its word 2 = the child's script
     pointer (bs, o), whose first word is w. *)
  Theorem child_real : forall pool la fl bpg gol bc,
    Genv.find_symbol G object_list_processor._gObjectPool = Some pool ->
    Genv.find_symbol G object_list_processor._gObjectListArray = Some la ->
    Genv.find_symbol G object_list_processor._gFreeObjectList = Some fl ->
    Genv.find_symbol G area._gObjParentGraphNode = Some bpg ->
    Genv.find_symbol G object_list_processor._gObjectLists = Some gol ->
    Genv.find_symbol G BS._gCurBhvCommand = Some bc ->
    forall m rs fs cs co bs o w t m' vr,
    rings m pool la = Some rs -> free_list m pool fl = Some fs -> NoDup (concat rs ++ fs) ->
    gfx_ok G pool m -> Mem.load Mint32 m gol 0 = Some (Vptr la Ptrofs.zero) ->
    Mem.load Mint32 m bc 0 = Some (Vptr cs co) ->
    Mem.loadv Mint32 m (Vptr cs (Ptrofs.add co (Ptrofs.repr 8))) = Some (Vptr bs o) ->
    Mem.load Mint32 m bs (Ptrofs.unsigned o) = Some (Vint w) ->
    bhv_list w < 13 -> bhv_list w <> 4 -> bhv_list w <> 5 -> bhv_list w <> 10 ->
    eval_funcall function_entry2 G m (Internal BS.f_bhv_cmd_spawn_child) [] t m' vr ->
    (* EMPTY FREE LIST: named, as in alloc_real *)
    fs = []
    \/ (exists k fs' pv, fs = k :: fs' /\ 0 <= k < NSLOT /\ vr = Vint (Int.repr 0)
        /\ Mem.load Mint32 m' bc 0 = Some (Vptr cs (Ptrofs.add co (Ptrofs.repr 12)))
        /\ rings m' pool la = Some (upd rs (Z.to_nat (bhv_list w)) (nth (Z.to_nat (bhv_list w)) rs [] ++ [k]))
        /\ free_list m' pool fl = Some fs'
        /\ gfx_ok G pool m'
        /\ Mem.unchanged_on (fun b z => AKEEP pool la fl bpg b z /\ KP pool (k * OSZ) b z /\ b <> bc) m m'
        /\ facts m' pool (k * OSZ) (slot_v pool k) (cpa_facts (origin_facts (bhv_list w) (Vptr bs o) pv))).
  Proof.
    intros pool la fl bpg gol bc Hp Hl Hf Hb Hgl Hbc m rs fs cs co bs o w t m' vr
      Hr Hfl Hnd Hg Hgo Hc0 Hw8 Hw Hi13 Hi4 Hi5 Hi10 H.
    assert (Hpl : pool <> la) by (apply (sym_ne lp _ _ _ _ Hp Hl); RA.neq).
    assert (Hpf : pool <> fl) by (apply (sym_ne lp _ _ _ _ Hp Hf); RA.neq).
    assert (Hlf : la <> fl) by (apply (sym_ne lp _ _ _ _ Hl Hf); RA.neq).
    assert (Hpb : pool <> bpg) by (apply (sym_ne lp _ _ _ _ Hp Hb); RA.neq).
    assert (Hlb : la <> bpg) by (apply (sym_ne lp _ _ _ _ Hl Hb); RA.neq).
    assert (Hfb : fl <> bpg) by (apply (sym_ne lp _ _ _ _ Hf Hb); RA.neq).
    assert (Hpc : pool <> bc) by (apply (sym_ne lp _ _ _ _ Hp Hbc); RA.neq).
    assert (Hlc : la <> bc) by (apply (sym_ne lp _ _ _ _ Hl Hbc); RA.neq).
    assert (Hfc : fl <> bc) by (apply (sym_ne lp _ _ _ _ Hf Hbc); RA.neq).
    assert (Hbgc : bpg <> bc) by (apply (sym_ne lp _ _ _ _ Hb Hbc); RA.neq).
    destruct dm_gco as (gd & Hdm).
    destruct (linkorder_resolves_symbol lp SO.prog _ gd (linked12_LO_spawn_object lp H12) Hdm) as (gB & HgB).
    assert (Hceh : ObjSelf.cext G ObjCopy.CEH) by exact (cenv_of lp _ (linked12_LO_object_helpers lp H12)).
    destruct (fcall_inv0 G BS.f_bhv_cmd_spawn_child m _ t m' vr eq_refl H) as (le & le' & out & Hbd & Hx & Hov).
    rewrite SCB_eq in Hx.
    (* model *)
    apply RA.seq_inv in Hx as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Hne)];
      [ | destruct (so_mem _ _ _ _ _ _ _ _ _ X1 eq_refl) as (_ & E); contradiction ].
    destruct (so_mem _ _ _ _ _ _ _ _ _ X1 eq_refl) as (-> & _).
    (* behavior *)
    apply RA.seq_inv in X2 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Hne)];
      [ | destruct (so_mem _ _ _ _ _ _ _ _ _ X3 eq_refl) as (_ & E); contradiction ].
    unfold P2 in X3.
    apply RA.seq_inv in X3 as [(ta & lea & ma & tb & A1 & A2) | (A1 & Hne)];
      [ | apply RA.set_inv in A1 as (_ & _ & _ & _ & E); contradiction ].
    apply RA.set_inv in A1 as (v5 & E5 & -> & -> & _).
    destruct (RA.ev_gvar G empty_env m le1 _ (tptr tuint) v5 Mint32 (PTree.gempty _ _) eq_refl E5) as (b5 & Hb5 & Hl5).
    rewrite Hbc in Hb5. injection Hb5 as <-. cbn [Mem.loadv] in Hl5. rewrite Ptrofs.unsigned_zero, Hc0 in Hl5.
    injection Hl5 as <-. clear E5.
    apply RA.seq_inv in A2 as [(tc & lec & mc & td & A3 & A4) | (A3 & Hne)];
      [ | apply RA.set_inv in A3 as (_ & _ & _ & _ & E); contradiction ].
    apply RA.set_inv in A3 as (v6 & E6 & -> & -> & _).
    pose proof (ld_idx G _ m BS._t'5 2 cs co v6 (PTree.gss _ _ _) E6) as L6.
    assert (E8 : Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_ints (Int.repr 2)) = Ptrofs.repr 8) by reflexivity.
    rewrite E8, Hw8 in L6. injection L6 as <-. clear E6.
    apply RA.set_inv in A4 as (vb & Eb & -> & -> & _).
    inv Eb; [ | match goal with Hq : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inv Hq end ].
    match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _, Hcs : sem_cast _ _ _ _ = Some _ |- _ =>
      apply RA.ev_temp in Ht; rewrite PTree.gss in Ht; injection Ht as <-;
      cbn [typeof] in Hcs; assert (Ecs : sem_cast (Vptr bs o) tuint (tptr tvoid) m = Some (Vptr bs o)) by reflexivity;
      rewrite Ecs in Hcs; injection Hcs as <- end.
    set (le4 := PTree.set BS._behavior (Vptr bs o) _) in X4.
    assert (Hbh : le4 ! BS._behavior = Some (Vptr bs o)) by (unfold le4; apply PTree.gss).
    clearbody le4.
    (* child = spawn_object_at_origin(gCurrentObject, 0, model, behavior) *)
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Hne)];
      [ | exfalso; apply Hne; exact (nb_normal _ _ _ _ _ _ _ _ _ X5 eq_refl) ].
    unfold P3 in X5.
    apply RA.seq_inv in X5 as [(te & lee & me & tf & A5 & A6) | (A5 & Hne)];
      [ | exfalso; apply Hne; exact (nb_normal _ _ _ _ _ _ _ _ _ A5 eq_refl) ].
    apply RA.seq_inv in A5 as [(tg & leg & mg & th & A7 & A8) | (A7 & Hne)];
      [ | apply RA.set_inv in A7 as (_ & _ & _ & _ & E); contradiction ].
    apply RA.set_inv in A7 as (v4 & _ & -> & -> & _).
    unfold SPC in A8.
    apply RA.call_inv in A8 as (tyargs & tyres & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hcl & -> & _).
    cbn in Hcf. injection Hcf as <- <- <-.
    match type of Evf with eval_expr _ _ _ _ (Evar _ ?ty) _ =>
      destruct (RA.ev_fun G empty_env _ _ _ ty vf (PTree.gempty _ _) eq_refl Evf) as (bf & Hsf & ->) end.
    rewrite (fun_res lp _ _ _ (linked12_LO_object_helpers lp H12) dm_soo bf fd Hsf Hff) in Hcl.
    destruct (exl4f _ _ _ _ _ _ _ _ _ _ Eal)
      as (t1' & t2' & t3' & t4' & u1 & u2 & u3 & u4 & w1 & w2 & w3 & w4 & Ety & -> & _ & _ & _ & _ & _ & _ & Eu4 & Cu4).
    injection Ety as <- <- <- <-.
    apply RA.ev_temp in Eu4. rewrite PTree.gso in Eu4 by RA.neq. rewrite Hbh in Eu4. injection Eu4 as <-.
    cbn [typeof] in Cu4. apply RA.cast_ptr_id in Cu4. subst w4.
    destruct (origin_real lp H12 pool la fl bpg gol Hp Hl Hf Hb Hgl m rs fs w1 w2 w3 bs o w _ _ _
                Hr Hfl Hnd Hg Hgo Hw Hi13 Hi4 Hi5 Hi10 Hcl)
      as [E | (k & fs' & E & Hk & Ev & R & F & Gx & U & HF)].
    { left. exact E. }
    right. exists k, fs', w1. subst vres.
    apply RA.set_inv in A6 as (v & Hv & -> & -> & _).
    apply RA.ev_temp in Hv. cbn [set_opttemp] in Hv. rewrite PTree.gss in Hv. injection Hv as <-.
    set (le6 := PTree.set BS._child (slot_v pool k) _) in X6.
    assert (Hch : le6 ! BS._child = Some (slot_v pool k)) by (unfold le6; apply PTree.gss).
    clearbody le6.
    (* obj_copy_pos_and_angle(child, gCurrentObject) *)
    apply RA.seq_inv in X6 as [(t7 & le7 & m7 & t8 & X7 & X8) | (X7 & Hne)];
      [ | exfalso; apply Hne; exact (nb_normal _ _ _ _ _ _ _ _ _ X7 eq_refl) ].
    unfold P4 in X7.
    apply RA.seq_inv in X7 as [(ti & lei & mi & tj & A9 & A10) | (A9 & Hne)];
      [ | apply RA.set_inv in A9 as (_ & _ & _ & _ & E'); contradiction ].
    apply RA.set_inv in A9 as (v3 & _ & -> & -> & _).
    unfold CPC in A10.
    apply RA.call_inv in A10 as (tyargs2 & tyres2 & cc2 & vf2 & vargs2 & fd2 & vres2 & Hcf2 & Evf2 & Eal2 & Hff2 & _ & Hcl2 & -> & _).
    cbn in Hcf2. injection Hcf2 as <- <- <-.
    match type of Evf2 with eval_expr _ _ _ _ (Evar _ ?ty) _ =>
      destruct (RA.ev_fun G empty_env _ _ _ ty vf2 (PTree.gempty _ _) eq_refl Evf2) as (bf2 & Hsf2 & ->) end.
    rewrite (fun_res lp _ _ _ (linked12_LO_object_helpers lp H12) dm_cpa bf2 fd2 Hsf2 Hff2) in Hcl2.
    destruct (ObjLoop.exl2 _ _ _ _ _ _ _ _ Eal2) as (ta1 & tb1 & y1 & y2 & z1 & z2 & Ea2 & -> & Ey1 & Cy1 & _ & _).
    injection Ea2 as <- <-.
    apply RA.ev_temp in Ey1. rewrite PTree.gso in Ey1 by RA.neq. rewrite Hch in Ey1. injection Ey1 as <-.
    cbn [typeof] in Cy1. apply RA.cast_ptr_id in Cy1. subst z1.
    destruct (cpa_ok G pool gB Hp HgB k Hk Hceh
                (fun b fd => fun_res lp _ _ _ (linked12_LO_object_helpers lp H12) dm_cp b fd)
                (fun b fd => fun_res lp _ _ _ (linked12_LO_object_helpers lp H12) dm_ca b fd)
                _ _ _ _ _ _ Hcl2 HF) as (U7 & HF7).
    (* gCurBhvCommand += 3 *)
    assert (AKc : forall z, AKEEP pool la fl bpg bc z /\ KP pool (k * OSZ) bc z).
    { intros z. split; [ split | left; exact (not_eq_sym Hpc) ].
      - intros [(E1 & _) | (E1 & _)]; [ exact (Hpc (eq_sym E1)) | exact (Hbgc (eq_sym E1)) ].
      - intros [(E1 & _) | [E1 | E1]]; [ exact (Hpc (eq_sym E1)) | exact (Hlc (eq_sym E1)) | exact (Hfc (eq_sym E1)) ]. }
    assert (Lc7 : Mem.load Mint32 m7 bc 0 = Some (Vptr cs co)).
    { apply (Mem.load_unchanged_on _ _ _ Mint32 bc 0 _ U7); [ intros i _; exact (proj2 (AKc i)) | ].
      apply (Mem.load_unchanged_on _ _ _ Mint32 bc 0 _ U); [ intros i _; exact (AKc i) | exact Hc0 ]. }
    apply RA.seq_inv in X8 as [(t9 & le9 & m9 & t10 & X9 & X10) | (X9 & Hne)];
      [ | exfalso; apply Hne; exact (nb_normal _ _ _ _ _ _ _ _ _ X9 eq_refl) ].
    unfold P5 in X9.
    apply RA.seq_inv in X9 as [(tk & lek & mk & tl & A11 & A12) | (A11 & Hne)];
      [ | apply RA.set_inv in A11 as (_ & _ & _ & _ & E'); contradiction ].
    apply RA.set_inv in A11 as (v2 & E2 & -> & -> & _).
    destruct (RA.ev_gvar G empty_env m7 _ _ (tptr tuint) v2 Mint32 (PTree.gempty _ _) eq_refl E2) as (b2 & Hb2 & Hl2).
    rewrite Hbc in Hb2. injection Hb2 as <-. cbn [Mem.loadv] in Hl2. rewrite Ptrofs.unsigned_zero, Lc7 in Hl2.
    injection Hl2 as <-. clear E2.
    apply RA.assign_inv in A12 as (b' & o' & bf' & vv2 & vv & Hlv & Evv & Hcv & Has & -> & _).
    apply (RA.lv_gvar G empty_env m7) in Hlv as (Hb' & -> & ->); [ | apply PTree.gempty ].
    rewrite Hbc in Hb'. injection Hb' as <-.
    pose proof (RA.store_by_value _ (tptr tuint) _ _ _ _ _ _ Mint32 eq_refl eq_refl Has) as Hs.
    rewrite Ptrofs.unsigned_zero in Hs.
    apply RA.ev_binop in Evv as (x1 & x2 & Y1 & Y2 & Y3).
    apply RA.ev_temp in Y1. rewrite PTree.gss in Y1. injection Y1 as <-.
    apply RA.ev_const in Y2. subst x2. cbn [typeof] in Y3, Hcv.
    assert (E3 : sem_binary_operation G Oadd (Vptr cs co) (tptr tuint) (Vint (Int.repr 3)) tint m7
                 = Some (Vptr cs (Ptrofs.add co (Ptrofs.repr 12)))) by reflexivity.
    rewrite E3 in Y3. injection Y3 as <-. apply RA.cast_ptr_id in Hcv. subst vv.
    (* return 0 *)
    unfold RET0 in X10. apply RA.ret_inv in X10 as (-> & v9 & Ev9 & ->).
    apply RA.ev_const in Ev9. subst v9.
    cbn [outcome_result_value fn_return BS.f_bhv_cmd_spawn_child typeof] in Hov. destruct Hov as (_ & Hov).
    cbn in Hov. injection Hov as <-.
    assert (U9 : Mem.unchanged_on (fun b _ => b <> bc) m7 m9).
    { apply (Mem.store_unchanged_on _ _ _ _ _ _ _ Hs). intros i _ Hn. exact (Hn eq_refl). }
    assert (Us : Mem.unchanged_on (fun b z => KP pool (k * OSZ) b z /\ b <> bc) me m9).
    { refine (Mem.unchanged_on_trans _ _ _ _ (Mem.unchanged_on_implies _ _ _ _ U7 (fun b z Hz _ => proj1 Hz))
                (Mem.unchanged_on_implies _ _ _ _ U9 (fun b z Hz _ => proj2 Hz))). }
    assert (KPc : forall j i, 0 <= j < NSLOT -> j * OSZ + O_NEXT <= i < j * OSZ + O_PREV + 4 ->
                  KP pool (k * OSZ) pool i /\ pool <> bc)
      by (intros j i Hj Hi; exact (conj (KP_rcell pool la fl bpg Hpl Hpf Hlf Hpb Hlb Hfb k Hk j i Hj Hi) Hpc)).
    refine (conj E (conj Hk (conj eq_refl (conj (Mem.load_store_same _ _ _ _ _ _ Hs) (conj _ (conj _ (conj _ (conj _ _)))))))).
    - exact (rings_keep pool la _ KPc (fun i => conj (or_introl (not_eq_sym Hpl)) Hlc) me m9 _ Hpl Us R).
    - exact (free_keep pool fl _ KPc (fun i => conj (or_introl (not_eq_sym Hpf)) Hfc) me m9 _ Us F).
    - apply (proj2 (gfx_at_iff pool bpg Hpb G m9 Hb)).
      refine (gfx_keep pool bpg _ me m9 Us _ (proj1 (gfx_at_iff pool bpg Hpb G me Hb) Gx)).
      intros b z Hz. split; [ exact (KP_gcell pool la fl bpg Hpl Hpf Hlf Hpb Hlb Hfb k Hk b z Hz) | ].
      destruct Hz as [(-> & _) | (-> & _)]; [ exact Hpc | exact Hbgc ].
    - refine (Mem.unchanged_on_trans _ _ _ _ (Mem.unchanged_on_implies _ _ _ _ U (fun b z Hz _ => conj (proj1 Hz) (proj1 (proj2 Hz))))
                (Mem.unchanged_on_implies _ _ _ _ Us (fun b z Hz _ => proj2 Hz))).
    - exact (facts_store_other _ _ _ _ _ _ _ _ _ _ Hs (not_eq_sym Hpc) HF7).
  Qed.
End LINKED.
