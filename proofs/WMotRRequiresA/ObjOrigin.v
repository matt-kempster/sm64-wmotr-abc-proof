(* ====================================================================== *)
(* spine (via BhvStep's spawn rows): OBJECTS -- spawn_object_at_origin   *)
(* (object_helpers.c), run by its real body:                              *)
(*   - segmented_to_virtual(behavior): memory.c's real body (the identity *)
(*     on this build);                                                    *)
(*   - create_object (ObjMake.create_real);                               *)
(*   - obj->parentObj = parent; areaIndex / activeAreaIndex copied from   *)
(*     the parent's graph node (killed: the parent's values are not      *)
(*     tracked);                                                         *)
(*   - geo_obj_init(&obj->header.gfx, gLoadedGraphNodes[model], ...)     *)
(*     (ObjGeo.geo_ok).                                                   *)
(* Result: create_real's disjunction, with origin_facts.                  *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory
  Globalenvs Ctypes Cop Clight ClightBigstep Clightdefs Events Errors.
From compcert Require Linking.
From SM64.Generated Require graph_node spawn_object object_list_processor area math_util memory object_helpers.
From SM64.Proofs Require Import SymbolicLinking LinkedTwelve RealFrameLinked.
From SM64.Proofs.WMotRRequiresA Require Import ObjWorld ObjRing ObjAlloc ObjCreate ObjMake ObjGeo.
From SM64.Proofs.WMotRRequiresA Require ObjSelf RenderAnim ObjLoop.

Import ListNotations.
Local Open Scope Z_scope.
Local Transparent Archi.ptr64.

Module RA := RenderAnim.
Module SO := SM64.Generated.spawn_object.
Module OH := SM64.Generated.object_helpers.
Module MEM := SM64.Generated.memory.
Module GN := SM64.Generated.graph_node.
Module MU := SM64.Generated.math_util.

(* ---------------------------------------------------------------------- *)
(* 1. The body, cut into named statements.                                 *)
(* ---------------------------------------------------------------------- *)
Definition OTH : type := Tstruct OH._Object noattr.
Definition ONH : type := Tstruct OH._ObjectNode noattr.
Definition GNOH : type := Tstruct OH._GraphNodeObject noattr.
Definition GNH : type := Tstruct OH._GraphNode noattr.
Definition PPG : type := tptr (tptr GNH).
Definition OBJ : expr := Ederef (Etempvar OH._obj (tptr OTH)) OTH.
Definition PAR : expr := Ederef (Etempvar OH._parent (tptr OTH)) OTH.
Definition GFX (p : expr) : expr := Efield (Efield p OH._header ONH) OH._gfx GNOH.

Definition S0 : statement :=
  Ssequence
    (Scall (Some OH._t'1) (Evar OH._segmented_to_virtual (Tfunction [tptr tvoid] (tptr tvoid) cc_default))
       [Etempvar OH._behavior (tptr tuint)])
    (Sset OH._behaviorAddr (Etempvar OH._t'1 (tptr tvoid))).
Definition S1 : statement :=
  Ssequence
    (Scall (Some OH._t'2) (Evar OH._create_object (Tfunction [tptr tuint] (tptr OTH) cc_default))
       [Etempvar OH._behaviorAddr (tptr tuint)])
    (Sset OH._obj (Etempvar OH._t'2 (tptr OTH))).
Definition LPAR : expr := Efield OBJ OH._parentObj (tptr OTH).
Definition S2 : statement := Sassign LPAR (Etempvar OH._parent (tptr OTH)).
Definition LAI : expr := Efield (GFX OBJ) OH._areaIndex tschar.
Definition LAAI : expr := Efield (GFX OBJ) OH._activeAreaIndex tschar.
Definition S3 : statement :=
  Ssequence (Sset OH._t'6 (Efield (GFX PAR) OH._areaIndex tschar)) (Sassign LAI (Etempvar OH._t'6 tschar)).
Definition S4 : statement :=
  Ssequence (Sset OH._t'5 (Efield (GFX PAR) OH._areaIndex tschar)) (Sassign LAAI (Etempvar OH._t'5 tschar)).
Definition GEOC : statement :=
  Scall None
    (Evar OH._geo_obj_init (Tfunction [tptr GNOH; tptr tvoid; tptr tfloat; tptr tshort] tvoid cc_default))
    [Ecast (Eaddrof (GFX OBJ) (tptr GNOH)) (tptr GNOH); Etempvar OH._t'4 (tptr GNH);
     Evar OH._gVec3fZero (tarray tfloat 3); Evar OH._gVec3sZero (tarray tshort 3)].
Definition S5 : statement :=
  Ssequence (Sset OH._t'3 (Evar OH._gLoadedGraphNodes PPG))
    (Ssequence (Sset OH._t'4 (Ederef (Ebinop Oadd (Etempvar OH._t'3 PPG) (Etempvar OH._model tuint) PPG) (tptr GNH)))
       GEOC).
Definition S6 : statement := Sreturn (Some (Etempvar OH._obj (tptr OTH))).

Lemma OB_eq : fn_body OH.f_spawn_object_at_origin =
  Ssequence S0 (Ssequence S1 (Ssequence S2 (Ssequence S3 (Ssequence S4 (Ssequence S5 S6))))).
Proof. reflexivity. Qed.

Definition CEH : composite_env := prog_comp_env OH.prog.
Definition D_AI : Z := 24.
Definition D_AAI : Z := 25.
Lemma lad_par : ObjSelf.lad CEH [OH._obj] LPAR = Some O_PARENT.
Proof. vm_compute. reflexivity. Qed.
Lemma lad_ai : ObjSelf.lad CEH [OH._obj] LAI = Some D_AI.
Proof. vm_compute. reflexivity. Qed.
Lemma lad_aai : ObjSelf.lad CEH [OH._obj] LAAI = Some D_AAI.
Proof. vm_compute. reflexivity. Qed.
Lemma lad_gfx : ObjSelf.lad CEH [OH._obj] (GFX OBJ) = Some 0.
Proof. vm_compute. reflexivity. Qed.
Lemma wr_par : wr_ok O_PARENT 4 = true.
Proof. vm_compute. reflexivity. Qed.
Lemma wr_ai : wr_ok D_AI 1 = true.
Proof. vm_compute. reflexivity. Qed.
Lemma wr_aai : wr_ok D_AAI 1 = true.
Proof. vm_compute. reflexivity. Qed.

(* create_object's facts, then parentObj := parent, areaIndex /
   activeAreaIndex killed, then geo_obj_init *)
Definition origin_facts (i : Z) (bv pv : val) : list fact :=
  geo_facts (kill D_AAI 1 (kill D_AI 1 ((Mint32, O_PARENT, SC pv) :: kill O_PARENT 4 (create_facts i bv)))).

(* ---------------------------------------------------------------------- *)
(* 2. Small steps.                                                         *)
(* ---------------------------------------------------------------------- *)
Lemma cast_pp_lr : forall a b v v' m, sem_cast v (tptr a) (tptr b) m = Some v' -> Val.load_result Mint32 v' = v'.
Proof. intros a b v v' m H. destruct v; cbn in H; try discriminate H; injection H as <-; reflexivity. Qed.

Lemma s2v_ok : forall (ge : genv) m v t m' vr,
  (exists b o, v = Vptr b o) ->
  eval_funcall function_entry2 ge m (Internal MEM.f_segmented_to_virtual) [v] t m' vr -> m' = m /\ vr = v.
Proof.
  intros ge m v t m' vr (b & o & ->) H.
  destruct (fcall_inv0 ge MEM.f_segmented_to_virtual m _ t m' vr eq_refl H) as (le & le' & out & Hbd & Hx & Hov).
  cbn [fn_params MEM.f_segmented_to_virtual bind_parameter_temps] in Hbd. injection Hbd as Hle.
  cbn [fn_body MEM.f_segmented_to_virtual] in Hx.
  apply RA.ret_inv in Hx as (-> & v1 & Ev & ->).
  subst le.
  inv Ev; [ | match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end ].
  match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _, Hc : sem_cast _ _ _ _ = Some _ |- _ =>
    apply RA.ev_temp in Ht; rewrite PTree.gss in Ht; injection Ht as <-;
    cbn [typeof] in Hc; apply RA.cast_ptr_id in Hc; subst end.
  cbn [outcome_result_value fn_return MEM.f_segmented_to_virtual typeof] in Hov. destruct Hov as (_ & Hov).
  apply RA.cast_ptr_id in Hov. subst vr. auto.
Qed.

Lemma exl4 : forall (G : genv) e le m a1 a2 a3 a4 tys vs, eval_exprlist G e le m [a1; a2; a3; a4] tys vs ->
  exists ty1 tys' v1 w1 w2 w3 w4, tys = ty1 :: tys' /\ vs = [w1; w2; w3; w4] /\ eval_expr G e le m a1 v1
    /\ sem_cast v1 (typeof a1) ty1 m = Some w1.
Proof.
  intros G e le m a1 a2 a3 a4 tys vs H.
  inv H. match goal with H : eval_exprlist _ _ _ _ _ _ _ |- _ => inv H end.
  match goal with H : eval_exprlist _ _ _ _ _ _ _ |- _ => inv H end.
  match goal with H : eval_exprlist _ _ _ _ _ _ _ |- _ => inv H end.
  match goal with H : eval_exprlist _ _ _ _ _ _ _ |- _ => inv H end.
  eauto 15.
Qed.

Lemma ev_cast_addr : forall (G : genv) e le m l ty ty' v,
  eval_expr G e le m (Ecast (Eaddrof l ty) ty') v ->
  exists b o bf, eval_lvalue G e le m l b o bf /\ sem_cast (Vptr b o) ty ty' m = Some v.
Proof.
  intros G e le m l ty ty' v H. inv H; [ | match goal with Hl : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inv Hl end ].
  match goal with Ha : eval_expr _ _ _ _ (Eaddrof _ _) _ |- _ =>
    inv Ha; [ | match goal with Hl : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hl end ] end.
  eauto.
Qed.

Lemma dm_s2v : (prog_defmap MEM.prog) ! OH._segmented_to_virtual = Some (Gfun (Internal MEM.f_segmented_to_virtual)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_co : (prog_defmap SO.prog) ! OH._create_object = Some (Gfun (Internal SO.f_create_object)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_goi : (prog_defmap GN.prog) ! OH._geo_obj_init = Some (Gfun (Internal GN.f_geo_obj_init)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_vset : (prog_defmap MU.prog) ! GN._vec3f_set = Some (Gfun (Internal MU.f_vec3f_set)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_vfc : (prog_defmap MU.prog) ! GN._vec3f_copy = Some (Gfun (Internal MU.f_vec3f_copy)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_vsc : (prog_defmap MU.prog) ! GN._vec3s_copy = Some (Gfun (Internal MU.f_vec3s_copy)).
Proof. vm_compute. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* 3. On the real linked program.                                          *)
(* ---------------------------------------------------------------------- *)
Section LINKED.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Notation G := (lp_ge lp).

  (* SPAWN_OBJECT_AT_ORIGIN ON THE REAL PROGRAM.  Premises: create_real's,
     with the behavior pointer's first word w. *)
  Theorem origin_real : forall pool la fl bpg gol,
    Genv.find_symbol G object_list_processor._gObjectPool = Some pool ->
    Genv.find_symbol G object_list_processor._gObjectListArray = Some la ->
    Genv.find_symbol G object_list_processor._gFreeObjectList = Some fl ->
    Genv.find_symbol G area._gObjParentGraphNode = Some bpg ->
    Genv.find_symbol G object_list_processor._gObjectLists = Some gol ->
    forall m rs fs pv ua mdl bs o w t m' vr,
    rings m pool la = Some rs -> free_list m pool fl = Some fs -> NoDup (concat rs ++ fs) ->
    gfx_ok G pool m -> Mem.load Mint32 m gol 0 = Some (Vptr la Ptrofs.zero) ->
    Mem.load Mint32 m bs (Ptrofs.unsigned o) = Some (Vint w) ->
    bhv_list w < 13 -> bhv_list w <> 4 -> bhv_list w <> 5 -> bhv_list w <> 10 ->
    eval_funcall function_entry2 G m (Internal OH.f_spawn_object_at_origin) [pv; ua; mdl; Vptr bs o] t m' vr ->
    (* EMPTY FREE LIST: named, as in alloc_real *)
    fs = []
    \/ (exists k fs', fs = k :: fs' /\ 0 <= k < NSLOT /\ vr = slot_v pool k
        /\ rings m' pool la = Some (upd rs (Z.to_nat (bhv_list w)) (nth (Z.to_nat (bhv_list w)) rs [] ++ [k]))
        /\ free_list m' pool fl = Some fs'
        /\ gfx_ok G pool m'
        /\ Mem.unchanged_on (fun b z => AKEEP pool la fl bpg b z /\ KP pool (k * OSZ) b z) m m'
        /\ facts m' pool (k * OSZ) (slot_v pool k) (origin_facts (bhv_list w) (Vptr bs o) pv)).
  Proof.
    intros pool la fl bpg gol Hp Hl Hf Hb Hgl m rs fs pv ua mdl bs o w t m' vr Hr Hfl Hnd Hg Hgo Hw Hi13 Hi4 Hi5 Hi10 H.
    assert (Hpl : pool <> la) by (apply (sym_ne lp _ _ _ _ Hp Hl); RA.neq).
    assert (Hpf : pool <> fl) by (apply (sym_ne lp _ _ _ _ Hp Hf); RA.neq).
    assert (Hlf : la <> fl) by (apply (sym_ne lp _ _ _ _ Hl Hf); RA.neq).
    assert (Hpb : pool <> bpg) by (apply (sym_ne lp _ _ _ _ Hp Hb); RA.neq).
    assert (Hlb : la <> bpg) by (apply (sym_ne lp _ _ _ _ Hl Hb); RA.neq).
    assert (Hfb : fl <> bpg) by (apply (sym_ne lp _ _ _ _ Hf Hb); RA.neq).
    destruct dm_gco as (gd & Hdm).
    destruct (linkorder_resolves_symbol lp SO.prog _ gd (linked12_LO_spawn_object lp H12) Hdm) as (gB & HgB).
    assert (Hceh : ObjSelf.cext G CEH) by exact (cenv_of lp _ (linked12_LO_object_helpers lp H12)).
    assert (Hceg : ObjSelf.cext G CEG) by exact (cenv_of lp _ (linked12_LO_graph_node lp H12)).
    destruct (fcall_inv0 G OH.f_spawn_object_at_origin m _ t m' vr eq_refl H) as (le & le' & out & Hbd & Hx & Hov).
    cbn [fn_params OH.f_spawn_object_at_origin bind_parameter_temps] in Hbd. injection Hbd as Hle.
    assert (Hbh : le ! OH._behavior = Some (Vptr bs o)) by (rewrite <- Hle; apply PTree.gss).
    assert (Hpa : le ! OH._parent = Some pv).
    { rewrite <- Hle. rewrite PTree.gso by RA.neq. rewrite PTree.gso by RA.neq. rewrite PTree.gso by RA.neq.
      apply PTree.gss. }
    rewrite OB_eq in Hx.
    (* behaviorAddr = segmented_to_virtual(behavior) *)
    sq Hx t1 le1 m1 t2 X0 X1.
    apply RA.seq_inv in X0 as [(ta & lea & ma & tb & Ca & Sa) | (Ca & Hne)].
    2:{ exfalso. apply Hne. exact (nb_normal _ _ _ _ _ _ _ _ _ Ca eq_refl). }
    apply RA.call_inv in Ca as (tyargs & tyres & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hc & -> & _).
    cbn in Hcf. injection Hcf as <- <- <-.
    match type of Evf with eval_expr _ _ _ _ (Evar _ ?ty) _ =>
      destruct (RA.ev_fun G empty_env _ _ _ ty vf (PTree.gempty _ _) eq_refl Evf) as (bf & Hsf & ->) end.
    rewrite (fun_res lp _ _ _ (linked12_LO_memory lp H12) dm_s2v bf fd Hsf Hff) in Hc.
    destruct (ObjLoop.exl1 _ _ _ _ _ _ _ Eal) as (ty1 & u & u' & Ety & -> & Eu & Cu).
    injection Ety as <-.
    apply RA.ev_temp in Eu. rewrite Hbh in Eu. injection Eu as <-.
    cbn [typeof] in Cu. apply RA.cast_ptr_id in Cu. subst u'.
    destruct (s2v_ok G m _ _ _ _ (ex_intro _ bs (ex_intro _ o eq_refl)) Hc) as (-> & ->). clear Hc.
    apply RA.set_inv in Sa as (v & Hv & -> & -> & _).
    apply RA.ev_temp in Hv. cbn [set_opttemp] in Hv. rewrite PTree.gss in Hv. injection Hv as <-.
    (* obj = create_object(behaviorAddr) *)
    sq X1 t3 le3 m3 t4 X2 X3.
    apply RA.seq_inv in X2 as [(tc & lec & mc & td & Cc & Sc) | (Cc & Hne)].
    2:{ exfalso. apply Hne. exact (nb_normal _ _ _ _ _ _ _ _ _ Cc eq_refl). }
    apply RA.call_inv in Cc as (tyargs2 & tyres2 & cc2 & vf2 & vargs2 & fd2 & vres2 & Hcf2 & Evf2 & Eal2 & Hff2 & _ & Hc & -> & _).
    cbn in Hcf2. injection Hcf2 as <- <- <-.
    match type of Evf2 with eval_expr _ _ _ _ (Evar _ ?ty) _ =>
      destruct (RA.ev_fun G empty_env _ _ _ ty vf2 (PTree.gempty _ _) eq_refl Evf2) as (bf2 & Hsf2 & ->) end.
    rewrite (fun_res lp _ _ _ (linked12_LO_spawn_object lp H12) dm_co bf2 fd2 Hsf2 Hff2) in Hc.
    destruct (ObjLoop.exl1 _ _ _ _ _ _ _ Eal2) as (ty1 & u & u' & Ety & -> & Eu & Cu).
    injection Ety as <-.
    apply RA.ev_temp in Eu. rewrite PTree.gss in Eu. injection Eu as <-.
    cbn [typeof] in Cu. apply RA.cast_ptr_id in Cu. subst u'.
    destruct (create_real lp H12 pool la fl bpg gol Hp Hl Hf Hb Hgl m rs fs bs o w _ _ _
                Hr Hfl Hnd Hg Hgo Hw Hi13 Hi4 Hi5 Hi10 Hc)
      as [E | (k & fs' & E & Hk & Ev & R & F & Gx & U & HF)].
    { left. exact E. }
    right. exists k, fs'. subst vres2. clear Hc.
    apply RA.set_inv in Sc as (v & Hv & -> & -> & _).
    apply RA.ev_temp in Hv. cbn [set_opttemp] in Hv. rewrite PTree.gss in Hv. injection Hv as <-.
    set (le9 := PTree.set OH._obj (slot_v pool k) _) in X3.
    assert (Hx9 : le9 ! OH._obj = Some (slot_v pool k)) by (unfold le9; apply PTree.gss).
    assert (Hp9 : le9 ! OH._parent = Some pv).
    { unfold le9. cbn [set_opttemp]. rewrite !PTree.gso by RA.neq. exact Hpa. }
    clearbody le9.
    (* obj->parentObj = parent *)
    sq X3 t5 le5 m5 t6 X4 X5.
    destruct (st_any G pool gB Hp HgB CEH Hceh OH._obj k Hk LPAR _ _ _ _ _ _ _ O_PARENT Mint32
                lad_par eq_refl wr_par Hx9 X4) as (v2 & v & Ev2 & Cv & -> & _ & St2 & U2).
    apply RA.ev_temp in Ev2. rewrite Hp9 in Ev2. injection Ev2 as <-.
    cbn [typeof LPAR] in Cv. pose proof (cast_pp_lr _ _ _ _ _ Cv) as Lr. apply RA.cast_ptr_id in Cv. subst v.
    pose proof (facts_store _ pool (k * OSZ) (slot_v pool k) _ Mint32 O_PARENT _ _ (SC pv) St2 Lr HF) as HF2.
    assert (Vp : Mem.valid_block mc pool).
    { apply (Mem.valid_access_valid_block mc Mint32 pool (k * OSZ + O_PARENT)).
      apply (Mem.valid_access_implies _ _ _ _ Writable). exact (Mem.store_valid_access_3 _ _ _ _ _ _ St2).
      constructor. }
    (* areaIndex / activeAreaIndex *)
    sq X5 t7 le7 m7 t8 X6 X7.
    apply RA.seq_inv in X6 as [(te & lee & me & tf & Se & Ae) | (Se & Hne)].
    2:{ apply RA.set_inv in Se as (_ & _ & _ & _ & E'). contradiction. }
    apply RA.set_inv in Se as (v6 & _ & -> & -> & _).
    assert (Hx9' : (PTree.set OH._t'6 v6 le9) ! OH._obj = Some (slot_v pool k)) by (rewrite PTree.gso by RA.neq; exact Hx9).
    destruct (st_any G pool gB Hp HgB CEH Hceh OH._obj k Hk LAI _ _ _ _ _ _ _ D_AI Mint8signed
                lad_ai eq_refl wr_ai Hx9' Ae) as (v2a & va & _ & _ & -> & _ & St3 & U3).
    pose proof (facts_store_kill _ pool (k * OSZ) (slot_v pool k) _ Mint8signed D_AI _ _ St3 HF2) as HF3.
    sq X7 t9 le10 m10 t10 X8 X9.
    apply RA.seq_inv in X8 as [(tg & leg & mg & th & Sg & Ag) | (Sg & Hne)].
    2:{ apply RA.set_inv in Sg as (_ & _ & _ & _ & E'). contradiction. }
    apply RA.set_inv in Sg as (v5 & _ & -> & -> & _).
    assert (Hx9'' : (PTree.set OH._t'5 v5 (PTree.set OH._t'6 v6 le9)) ! OH._obj = Some (slot_v pool k))
      by (rewrite !PTree.gso by RA.neq; exact Hx9).
    destruct (st_any G pool gB Hp HgB CEH Hceh OH._obj k Hk LAAI _ _ _ _ _ _ _ D_AAI Mint8signed
                lad_aai eq_refl wr_aai Hx9'' Ag) as (v2b & vb & _ & _ & -> & _ & St4 & U4).
    pose proof (facts_store_kill _ pool (k * OSZ) (slot_v pool k) _ Mint8signed D_AAI _ _ St4 HF3) as HF4.
    pose proof (Mem.valid_block_unchanged_on _ _ _ _ (Mem.unchanged_on_trans _ _ _ _ U2 (Mem.unchanged_on_trans _ _ _ _ U3 U4)) Vp) as Vp4.
    (* geo_obj_init(&obj->header.gfx, gLoadedGraphNodes[model], gVec3fZero, gVec3sZero) *)
    sq X9 t11 le11 m11 t12 X10 X11.
    apply RA.seq_inv in X10 as [(ti & lei & mi & tj & Si & X12) | (Si & Hne)].
    2:{ apply RA.set_inv in Si as (_ & _ & _ & _ & E'). contradiction. }
    apply RA.set_inv in Si as (v3 & _ & -> & -> & _).
    apply RA.seq_inv in X12 as [(tk & lek & mk & tl & Sk & Cg) | (Sk & Hne)].
    2:{ apply RA.set_inv in Sk as (_ & _ & _ & _ & E'). contradiction. }
    apply RA.set_inv in Sk as (v4 & _ & -> & -> & _).
    unfold GEOC in Cg.
    apply RA.call_inv in Cg as (tyargs3 & tyres3 & cc3 & vf3 & vargs3 & fd3 & vres3 & Hcf3 & Evf3 & Eal3 & Hff3 & _ & Hc & -> & _).
    cbn in Hcf3. injection Hcf3 as <- <- <-.
    match type of Evf3 with eval_expr _ _ _ _ (Evar _ ?ty) _ =>
      destruct (RA.ev_fun G empty_env _ _ _ ty vf3 (PTree.gempty _ _) eq_refl Evf3) as (bf3 & Hsf3 & ->) end.
    rewrite (fun_res lp _ _ _ (linked12_LO_graph_node lp H12) dm_goi bf3 fd3 Hsf3 Hff3) in Hc.
    destruct (exl4 _ _ _ _ _ _ _ _ _ _ Eal3) as (ty1 & tys' & v1 & w1 & w2 & w3 & w4 & Ety & -> & Ev1 & Cv1).
    injection Ety as <- _.
    assert (Hx12 : (PTree.set OH._t'4 v4 (PTree.set OH._t'3 v3 (PTree.set OH._t'5 v5 (PTree.set OH._t'6 v6 le9))))
                     ! OH._obj = Some (slot_v pool k)) by (rewrite !PTree.gso by RA.neq; exact Hx9).
    assert (Ew1 : w1 = slot_v pool k).
    { destruct (ev_cast_addr _ _ _ _ _ _ _ _ Ev1) as (b1 & o1 & bf1 & Hl1 & Hc1).
      apply RA.cast_ptr_id in Hc1. subst v1.
      destruct (lad_at G pool gB Hp HgB CEH Hceh OH._obj k _ _ _ _ _ _ 0 Hx12 Hl1 lad_gfx) as (-> & -> & ->).
      cbn [typeof] in Cv1. apply RA.cast_ptr_id in Cv1. subst w1.
      unfold slot_v. change (Ptrofs.repr 0) with Ptrofs.zero. rewrite Ptrofs.add_zero. reflexivity. }
    subst w1.
    destruct (geo_ok G pool gB Hp HgB Hceg
                (fun b fd => fun_res lp _ _ _ (linked12_LO_math lp H12) dm_vset b fd)
                (fun b fd => fun_res lp _ _ _ (linked12_LO_math lp H12) dm_vfc b fd)
                (fun b fd => fun_res lp _ _ _ (linked12_LO_math lp H12) dm_vsc b fd)
                k Hk _ _ _ _ _ _ _ _ Hc Vp4 HF4) as (U5 & HF5).
    (* return obj *)
    unfold S6 in X11. apply RA.ret_inv in X11 as (-> & v9 & Ev9 & ->).
    apply RA.ev_temp in Ev9. cbn [set_opttemp] in Ev9. rewrite Hx12 in Ev9. injection Ev9 as <-.
    cbn [outcome_result_value fn_return OH.f_spawn_object_at_origin typeof] in Hov. destruct Hov as (_ & Hov).
    apply RA.cast_ptr_id in Hov. subst vr.
    assert (Us : Mem.unchanged_on (KP pool (k * OSZ)) mc m11).
    { exact (Mem.unchanged_on_trans _ _ _ _ U2 (Mem.unchanged_on_trans _ _ _ _ U3
               (Mem.unchanged_on_trans _ _ _ _ U4 U5))). }
    refine (conj E (conj Hk (conj eq_refl (conj _ (conj _ (conj _ (conj _ HF5))))))).
    - exact (rings_keep pool la (KP pool (k * OSZ)) (KP_rcell pool la fl bpg Hpl Hpf Hlf Hpb Hlb Hfb k Hk)
               (fun i => or_introl (not_eq_sym Hpl)) mc m11 _ Hpl Us R).
    - exact (free_keep pool fl (KP pool (k * OSZ)) (KP_rcell pool la fl bpg Hpl Hpf Hlf Hpb Hlb Hfb k Hk)
               (fun i => or_introl (not_eq_sym Hpf)) mc m11 _ Us F).
    - apply (proj2 (gfx_at_iff pool bpg Hpb G m11 Hb)).
      exact (gfx_keep pool bpg (KP pool (k * OSZ)) mc m11 Us (KP_gcell pool la fl bpg Hpl Hpf Hlf Hpb Hlb Hfb k Hk)
               (proj1 (gfx_at_iff pool bpg Hpb G mc Hb) Gx)).
    - exact (Mem.unchanged_on_trans _ _ _ _ U (Mem.unchanged_on_implies _ _ _ _ Us (fun b z Hz _ => proj2 Hz))).
  Qed.
End LINKED.
