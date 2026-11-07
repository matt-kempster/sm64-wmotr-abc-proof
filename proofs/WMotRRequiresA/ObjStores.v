(* spine (via HeightFrame, 2026-11-03): update_objects' own stores keep
   Pobjl and the frame block's noref (the row Hobj_stores). *)
(* ====================================================================== *)
(* ObjStores.v -- THE OBJECT PHASE'S OWN STORES.                          *)
(*                                                                        *)
(* update_objects' body, outside its calls, is 17 straight store blocks   *)
(* (ObjPhase.uo_list's OBlk entries).  Every one of them is, by a vm      *)
(* check on the generated body (uo_sok), a sequence of temp sets and      *)
(* stores of these shapes:                                                *)
(*   - cycleCounts[i] = <anything>        (the frame's stack block);      *)
(*   - g = <an int>, g a global outside every invariant's footprint      *)
(*     (ClearKeep.gs_ok, not obj_w's, not a script): gTimeStopState      *)
(*     &= / |= a mask, the room counters and the camera-collision flag   *)
(*     = 0, gPrevFrameObjectCount = gObjectCounter;                      *)
(*   - gObjectLists = gObjectListArray, the value it already holds        *)
(*     (obj_w's ow_gol), so no load changes (store_same_ptr).            *)
(* THEOREM stores_safe: such a block keeps any R closed under the three  *)
(* kinds of store, together with the frame block's noref.                *)
(* ====================================================================== *)

From Coq Require Import ZArith Lia List Bool.
From compcert Require Import Coqlib Integers Floats Values AST Ctypes Cop Clight
  ClightBigstep Clightdefs Memory Memdata Maps Globalenvs Events.
From SM64.Generated Require object_list_processor.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked LinkedTwelve CensusV2 MWFReal
  SpawnInit NoAImpliesNoFlyLinked.
From SM64.Proofs.WMotRRequiresA Require FrameCalls ObjWorld PollKeep ObjPhase BhvVM RenderAnim ClearKeep.
Import ListNotations.
Local Open Scope Z_scope.

Module OLP := object_list_processor.

(* ---------------------------------------------------------------------- *)
(* 1. Memory facts.                                                        *)
(* ---------------------------------------------------------------------- *)

Lemma check_value_eq : forall n v q l, check_value n v q l = true -> l = inj_value_rec n v q.
Proof.
  induction n as [| n IH]; intros v q l H; destruct l as [| [ | | v' q' k ] l ]; cbn in H;
    try discriminate H; [ reflexivity | ].
  apply andb_prop in H as [H H4]. apply andb_prop in H as [H H3]. apply andb_prop in H as [H1 H2].
  apply proj_sumbool_true in H1. apply proj_sumbool_true in H2. apply Nat.eqb_eq in H3.
  subst v' q' k. cbn [inj_value_rec]. f_equal. exact (IH v q l H4).
Qed.

(* a 32-bit load that yields a pointer read exactly that pointer's bytes *)
Lemma decode_ptr32 : forall l b o, decode_val Mint32 l = Vptr b o -> l = encode_val Mint32 (Vptr b o).
Proof.
  intros l b o H. unfold decode_val in H. destruct (proj_bytes l); [ discriminate H | ].
  cbn [Archi.ptr64] in H.
  destruct (proj_value Q32 l) eqn:E; cbn in H; try discriminate H.
  injection H as <- <-. unfold proj_value in E.
  destruct l as [| [ | | v q k ] l ]; try discriminate E.
  destruct (check_value (size_quantity_nat Q32) v Q32 (Fragment v q k :: l)) eqn:C; [ | discriminate E ].
  subst v. apply check_value_eq in C. exact C.
Qed.

Lemma setN_getN_pt : forall n p c q,
  ZMap.get q (Mem.setN (Mem.getN n p c) p c) = ZMap.get q c.
Proof.
  induction n as [| n IH]; intros p c q; [ reflexivity | ].
  cbn [Mem.getN Mem.setN].
  set (c' := ZMap.set p (ZMap.get p c) c).
  assert (G : Mem.getN n (p + 1) c = Mem.getN n (p + 1) c').
  { apply Mem.getN_exten. intros i Hi. unfold c'. rewrite ZMap.gso by lia. reflexivity. }
  rewrite G, IH. unfold c'. rewrite ZMap.gsspec. destruct (ZIndexed.eq q p) as [-> | _]; reflexivity.
Qed.

Section TR.
Local Transparent Mem.load.
(* storing back the pointer a cell already holds changes no load *)
Lemma store_same_ptr : forall m b z bp op m2,
  Mem.load Mint32 m b z = Some (Vptr bp op) -> Mem.store Mint32 m b z (Vptr bp op) = Some m2 ->
  forall ch b' z', Mem.load ch m2 b' z' = Mem.load ch m b' z'.
Proof.
  intros m b z bp op m2 L St.
  assert (Eb : Mem.getN 4 z (PMap.get b (Mem.mem_contents m)) = encode_val Mint32 (Vptr bp op)).
  { unfold Mem.load in L. destruct (Mem.valid_access_dec m Mint32 b z Readable); [ | discriminate L ].
    injection L as L. exact (decode_ptr32 _ _ _ L). }
  assert (CA : forall b0 q, ZMap.get q (PMap.get b0 (Mem.mem_contents m2))
                            = ZMap.get q (PMap.get b0 (Mem.mem_contents m))).
  { intros b0 q. rewrite (Mem.store_mem_contents _ _ _ _ _ _ St).
    destruct (peq b0 b) as [-> | Ne].
    - rewrite PMap.gss, <- Eb. apply setN_getN_pt.
    - rewrite PMap.gso by exact Ne. reflexivity. }
  intros ch b' z'. unfold Mem.load.
  destruct (Mem.valid_access_dec m2 ch b' z' Readable) as [V2 | N2];
  destruct (Mem.valid_access_dec m ch b' z' Readable) as [V1 | N1].
  - f_equal. f_equal. apply Mem.getN_exten. intros i _. apply CA.
  - exfalso. exact (N1 (Mem.store_valid_access_2 _ _ _ _ _ _ St _ _ _ _ V2)).
  - exfalso. exact (N2 (Mem.store_valid_access_1 _ _ _ _ _ _ St _ _ _ _ V1)).
  - reflexivity.
Qed.
End TR.

(* the fragments a store writes are fragments of the stored value *)
Lemma enc_frag : forall ch v v' q k, In (Fragment v' q k) (encode_val ch v) -> v' = v.
Proof.
  intros ch v v' q k H. unfold encode_val in H.
  destruct v; destruct ch; cbn [Archi.ptr64] in H;
    first [ apply repeat_spec in H; discriminate H
          | apply in_map_iff in H; destruct H as (? & E & _); discriminate E
          | destruct (in_inj_value _ _ _ H) as (? & E); injection E as E _ _; exact E ].
Qed.

(* (the frame block's privacy across a store: ObjPhase.noref_store_in /
   noref_store_sym) *)

(* ---------------------------------------------------------------------- *)
(* 2. The store shapes, decided on the generated body.                     *)
(* ---------------------------------------------------------------------- *)
Definition teq (t1 t2 : type) : bool := if type_eq t1 t2 then true else false.

Lemma teq_eq : forall t1 t2, teq t1 t2 = true -> t1 = t2.
Proof. intros t1 t2 H. unfold teq in H. destruct (type_eq t1 t2); [ exact e | discriminate H ]. Qed.

(* cycleCounts[i] *)
Definition cc_ok (a : expr) : bool :=
  match a with
  | Ederef (Ebinop Oadd (Evar c t1) (Econst_int _ t2) t3) t4 =>
      Pos.eqb c OLP._cycleCounts && teq t1 (tarray tlong 30) && teq t2 tint && teq t3 (tptr tlong)
      && teq t4 tlong
  | _ => false
  end.

(* a global no invariant reads *)
Definition gok (g : ident) : bool :=
  ClearKeep.gs_ok g && negb (existsb (Pos.eqb g) PollKeep.ow_ids)
  && negb (existsb (Pos.eqb g) (map BhvVM.v_s BhvVM.vm_tab)) && negb (Pos.eqb g OLP._cycleCounts).

(* the stored value is an int *)
Definition rv_ok (ty : type) (a : expr) : bool :=
  match a with
  | Econst_int _ t => teq ty tshort && teq t tint
  | Etempvar _ t => teq ty tshort && teq t tuint
  | Ebinop op (Etempvar _ t1) a2 t =>
      match op with Oand | Oor => true | _ => false end
      && teq ty tuint && teq t1 tuint && teq (typeof a2) tint && teq t tuint
  | _ => false
  end.

(* gObjectLists = gObjectListArray *)
Definition gol_ok (g : ident) (ty : type) (a : expr) : bool :=
  match a with
  | Evar l t => Pos.eqb g OLP._gObjectLists && Pos.eqb l OLP._gObjectListArray
      && teq ty (tptr (Tstruct OLP._ObjectNode noattr)) && teq t (tarray (Tstruct OLP._ObjectNode noattr) 16)
  | _ => false
  end.

Fixpoint sok (s : statement) : bool :=
  match s with
  | Sskip | Sset _ _ => true
  | Ssequence s1 s2 => sok s1 && sok s2
  | Sassign a1 a2 =>
      cc_ok a1 || match a1 with Evar g ty => (gok g && rv_ok ty a2) || gol_ok g ty a2 | _ => false end
  | _ => false
  end.

Definition blk_sok (o : FrameCalls.obl) : bool :=
  match o with FrameCalls.OBlk s => sok s | _ => true end.

(* THE CHECK, on the generated update_objects *)
Lemma uo_sok : forallb blk_sok ObjPhase.uo_list = true.
Proof. vm_compute. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* 3. The shapes' effects.                                                 *)
(* ---------------------------------------------------------------------- *)
Lemma binop_int : forall (ce : composite_env) op v1 v2 m v,
  (op = Oand \/ op = Oor) -> sem_binary_operation ce op v1 tuint v2 tint m = Some v -> exists i, v = Vint i.
Proof.
  intros ce op v1 v2 m v [-> | ->] H; destruct v1; destruct v2; cbn in H; try discriminate H;
    injection H as <-; eexists; reflexivity.
Qed.

Lemma rv_int : forall (ge : genv) e le m ty a v2 v, rv_ok ty a = true ->
  eval_expr ge e le m a v2 -> sem_cast v2 (typeof a) ty m = Some v -> exists i, v = Vint i.
Proof.
  intros ge e le m ty a v2 v Hr He Hc.
  destruct a as [ i0 t0 | | | | | x0 t0 | | | | op a3 a4 t0 | | | | ]; cbn [rv_ok] in Hr; try discriminate Hr.
  - apply andb_prop in Hr as [T1 T2]. apply teq_eq in T1. apply teq_eq in T2. subst ty t0.
    apply RenderAnim.ev_const in He. subst v2. cbn in Hc. injection Hc as <-. eexists; reflexivity.
  - apply andb_prop in Hr as [T1 T2]. apply teq_eq in T1. apply teq_eq in T2. subst ty t0.
    cbn [typeof] in Hc. destruct v2; cbn in Hc; try discriminate Hc. injection Hc as <-. eexists; reflexivity.
  - destruct a3; try discriminate Hr.
    apply andb_prop in Hr as [Hr T5]. apply andb_prop in Hr as [Hr T4]. apply andb_prop in Hr as [Hr T3].
    apply andb_prop in Hr as [Hop T2].
    apply teq_eq in T2. apply teq_eq in T3. apply teq_eq in T4. apply teq_eq in T5. subst.
    apply RenderAnim.ev_binop in He as (v1 & v3 & _ & _ & Hb). cbn [typeof] in Hb, Hc. rewrite T4 in Hb.
    assert (Op : op = Oand \/ op = Oor) by (destruct op; try discriminate Hop; auto).
    destruct (binop_int ge op v1 v3 m v2 Op Hb) as (i1 & ->). cbn in Hc. injection Hc as <-.
    eexists; reflexivity.
Qed.

Section ST.
  Variable G : genv.
  Variable b : block.
  Variable R : mem -> Prop.
  Hypothesis RG : forall id bg ch z i m m2, Genv.find_symbol G id = Some bg -> ClearKeep.gs_ok id = true ->
    existsb (Pos.eqb id) PollKeep.ow_ids = false ->
    existsb (Pos.eqb id) (map BhvVM.v_s BhvVM.vm_tab) = false ->
    Mem.store ch m bg z (Vint i) = Some m2 -> R m -> R m2.
  Hypothesis RL : forall gol la m m2, Genv.find_symbol G OLP._gObjectLists = Some gol ->
    Genv.find_symbol G OLP._gObjectListArray = Some la ->
    Mem.store Mint32 m gol 0 (Vptr la Ptrofs.zero) = Some m2 -> R m -> R m2.
  Hypothesis RB : forall m m2, R m -> ObjPhase.noref G b m -> Mem.unchanged_on (fun b' _ => b' <> b) m m2 -> R m2.

  Let Q := fun m => R m /\ ObjPhase.noref G b m.
  Let e := ObjPhase.uo_env b.

  Lemma e_glob : forall g, Pos.eqb g OLP._cycleCounts = false -> e ! g = None.
  Proof.
    intros g H. unfold e, ObjPhase.uo_env. rewrite PTree.gso; [ apply PTree.gempty | ].
    intros ->. rewrite Pos.eqb_refl in H. discriminate H.
  Qed.

  Lemma cc_safe : forall a1 a2, cc_ok a1 = true -> ObjPhase.safeE G Q e (Sassign a1 a2).
  Proof.
    intros a1 a2 Hc le m t le' m' out (HR & Hn) H.
    destruct a1 as [ | | | | | | p t4 | | | | | | | ]; try discriminate Hc.
    destruct p as [ | | | | | | | | | op p1 p2 t3 | | | | ]; try discriminate Hc.
    destruct op; try discriminate Hc.
    destruct p1 as [ | | | | c t1 | | | | | | | | | ]; try discriminate Hc.
    destruct p2 as [ i t2 | | | | | | | | | | | | | ]; try discriminate Hc.
    cbn [cc_ok] in Hc.
    apply andb_prop in Hc as [Hc T4]. apply andb_prop in Hc as [Hc T3]. apply andb_prop in Hc as [Hc T2].
    apply andb_prop in Hc as [Ec T1]. apply Pos.eqb_eq in Ec.
    apply teq_eq in T1. apply teq_eq in T2. apply teq_eq in T3. apply teq_eq in T4. subst.
    apply RenderAnim.assign_inv in H as (bb & o & bf & v2 & v & Hl & _ & _ & Ha & _ & _).
    inv Hl.
    match goal with Hx : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
      apply RenderAnim.ev_binop in Hx as (v1 & v3 & E1 & E3 & Hbo) end.
    apply RenderAnim.ev_const in E3. subst v3.
    inv E1. match goal with Hx : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hx end.
    2: { match goal with Hx : e ! _ = None |- _ =>
           unfold e, ObjPhase.uo_env in Hx; rewrite PTree.gss in Hx; discriminate Hx end. }
    match goal with Hx : e ! _ = Some _ |- _ =>
      unfold e, ObjPhase.uo_env in Hx; rewrite PTree.gss in Hx; injection Hx as <- end.
    match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end;
      match goal with Ha0 : access_mode _ = _ |- _ => cbn in Ha0; try discriminate Ha0 end.
    cbn in Hbo. injection Hbo as <- <-.
    apply (RenderAnim.store_by_value G tlong _ _ _ _ _ _ Mint64 eq_refl eq_refl) in Ha.
    split.
    - apply (RB m m' HR Hn). apply (Mem.store_unchanged_on _ _ _ _ _ _ _ Ha).
      intros i0 _ N. exact (N eq_refl).
    - exact (ObjPhase.noref_store_in _ _ _ _ _ _ _ Ha Hn).
  Qed.

  Lemma g_safe : forall g ty a2, gok g = true -> rv_ok ty a2 = true -> ObjPhase.safeE G Q e (Sassign (Evar g ty) a2).
  Proof.
    intros g ty a2 Hg Hr le m t le' m' out (HR & Hn) H.
    unfold gok in Hg. apply andb_prop in Hg as [Hg Hcc]. apply andb_prop in Hg as [Hg Hsc].
    apply andb_prop in Hg as [Hok How]. apply negb_true_iff in Hcc, Hsc, How.
    apply RenderAnim.assign_inv in H as (bb & o & bf & v2 & v & Hl & Hv & Hc & Ha & _ & _).
    apply RenderAnim.lv_gvar in Hl as (Hs & -> & ->); [ | exact (e_glob g Hcc) ].
    cbn [typeof] in Hc, Ha.
    destruct (rv_int G e le m ty a2 v2 v Hr Hv Hc) as (i & ->).
    assert (Hty : ty = tshort \/ ty = tuint).
    { destruct a2 as [ | | | | | | | | | op a3 a4 t0 | | | | ]; cbn [rv_ok] in Hr; try discriminate Hr;
        try (apply andb_prop in Hr as [T _]; left; exact (teq_eq _ _ T)).
      destruct a3; try discriminate Hr.
      apply andb_prop in Hr as [Hr _]. apply andb_prop in Hr as [Hr _]. apply andb_prop in Hr as [Hr _].
      apply andb_prop in Hr as [_ T]. right. exact (teq_eq _ _ T). }
    assert (St : exists ch, Mem.store ch m bb 0 (Vint i) = Some m').
    { destruct Hty as [-> | ->].
      - exists Mint16signed. exact (RenderAnim.store_by_value G tshort _ _ _ _ _ _ Mint16signed eq_refl eq_refl Ha).
      - exists Mint32. exact (RenderAnim.store_by_value G tuint _ _ _ _ _ _ Mint32 eq_refl eq_refl Ha). }
    destruct St as (ch & St).
    split.
    - exact (RG g bb ch 0 i m m' Hs Hok How Hsc St HR).
    - refine (ObjPhase.noref_store_sym _ _ _ _ _ _ _ _ (ex_intro _ _ Hs) _ St Hn). intros x o E. discriminate E.
  Qed.

  Lemma gol_safe : forall g ty a2, gol_ok g ty a2 = true -> ObjPhase.safeE G Q e (Sassign (Evar g ty) a2).
  Proof.
    intros g ty a2 Hg le m t le' m' out (HR & Hn) H.
    destruct a2 as [ | | | | l t0 | | | | | | | | | ]; try discriminate Hg. cbn [gol_ok] in Hg.
    apply andb_prop in Hg as [Hg T2]. apply andb_prop in Hg as [Hg T1]. apply andb_prop in Hg as [E1 E2].
    apply Pos.eqb_eq in E1. apply Pos.eqb_eq in E2. apply teq_eq in T1. apply teq_eq in T2. subst.
    apply RenderAnim.assign_inv in H as (bb & o & bf & v2 & v & Hl & Hv & Hc & Ha & _ & _).
    apply RenderAnim.lv_gvar in Hl as (Hs & -> & ->); [ | exact (e_glob OLP._gObjectLists eq_refl) ].
    apply RenderAnim.ev_fun in Hv as (la & Hla & ->); [ | exact (e_glob OLP._gObjectListArray eq_refl) | reflexivity ].
    cbn in Hc. injection Hc as <-.
    apply (RenderAnim.store_by_value G (tptr (Tstruct OLP._ObjectNode noattr)) _ _ _ _ _ _ Mint32 eq_refl eq_refl) in Ha.
    split.
    - exact (RL bb la m m' Hs Hla Ha HR).
    - refine (ObjPhase.noref_store_sym _ _ _ _ _ _ _ _ (ex_intro _ _ Hs) _ Ha Hn).
      intros x o E. injection E as <- _. exact (ex_intro _ _ Hla).
  Qed.

  Lemma sok_safe : forall s, sok s = true -> ObjPhase.safeE G Q e s.
  Proof.
    induction s; intros H; cbn [sok] in H; try discriminate H.
    - exact (ObjPhase.safeE_skip G Q e).
    - apply orb_true_iff in H as [H | H]; [ exact (cc_safe _ _ H) | ].
      match goal with |- context [Sassign ?a1 _] => destruct a1; try discriminate H end.
      apply orb_true_iff in H as [H | H].
      + apply andb_prop in H as [H1 H2]. exact (g_safe _ _ _ H1 H2).
      + exact (gol_safe _ _ _ H).
    - exact (ObjPhase.safeE_set G Q e _ _).
    - apply andb_prop in H as [H1 H2]. exact (ObjPhase.safeE_seq G Q e _ _ (IHs1 H1) (IHs2 H2)).
  Qed.

  (* THE THEOREM: every store block of update_objects *)
  Theorem stores_safe : forall s, In (FrameCalls.OBlk s) ObjPhase.uo_list -> ObjPhase.safeE G Q e s.
  Proof.
    intros s Hin. apply sok_safe.
    exact (proj1 (forallb_forall _ _) uo_sok _ Hin).
  Qed.
End ST.

(* ---------------------------------------------------------------------- *)
(* 4. gObjectLists = gObjectListArray keeps ClearKeep's Pc.               *)
(* ---------------------------------------------------------------------- *)
Section GK.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Notation G := (lp_ge lp).
  Variable bm : block.
  Hypothesis Hbm_sym : Genv.find_symbol G level_update._gMarioStates = Some bm.
  Variables (bc : block) (oc0 : ptrofs) (SafeB : block -> Prop).
  Hypothesis Hbc_sym : Genv.find_symbol G mario._gControllers = Some bc.
  Hypothesis Hoc0 : oc0 = Ptrofs.zero.

  Theorem gol_keep : forall gol la m m2,
    Genv.find_symbol G OLP._gObjectLists = Some gol -> Genv.find_symbol G OLP._gObjectListArray = Some la ->
    Mem.store Mint32 m gol 0 (Vptr la Ptrofs.zero) = Some m2 ->
    ClearKeep.Pc lp bm bc oc0 SafeB m -> ClearKeep.Pc lp bm bc oc0 SafeB m2.
  Proof.
    intros gol la m m2 Hg Hl St (Ok & Hphi & HD & Hst & How).
    pose proof How as (pool & la' & fl & gol' & gmo & sdp & gdi & rs & fs & _ & Hla' & _ & Hgol' & _ & _ & _ & C).
    rewrite Hg in Hgol'. injection Hgol' as <-. rewrite Hl in Hla'. injection Hla' as <-.
    pose proof (ObjWorld.ow_gol _ _ _ _ _ _ _ _ _ _ _ _ C) as L0.
    pose proof (store_same_ptr m gol 0 la Ptrofs.zero m2 L0 St) as LE.
    assert (Hv : forall b0 o0, Vptr la Ptrofs.zero = Vptr b0 o0 ->
              (exists idv, Genv.find_symbol G idv = Some b0) /\ (SafeB gol -> SafeB b0)).
    { intros b0 o0 E. injection E as <- <-. split; [ exists OLP._gObjectListArray; exact Hl | ].
      intros Hsg. pose proof Ok as (_ & _ & HM).
      pose proof HM as (_ & _ & _ & _ & _ & _ & _ & R7 & _).
      exact (R7 gol Ptrofs.zero la Ptrofs.zero Hsg L0). }
    destruct (ClearKeep.gstore_core_p lp H12 bm Hbm_sym bc oc0 SafeB Hbc_sym Hoc0 OLP._gObjectLists gol Mint32 0 _
                m m2 Hg ltac:(vm_compute; reflexivity) Hv St Ok Hphi HD Hst) as (Ok2 & Hphi2 & HD2 & Hst2 & _).
    refine (conj Ok2 (conj Hphi2 (conj HD2 (conj Hst2 _)))).
    apply (PollKeep.obj_w_unch m m2 G bm); [ | | | | exact How ].
    - intros id b0 _ _ ch z. apply LE.
    - intros b0 _ ch z. apply LE.
    - intros z _. apply LE.
    - intros s0 b0 _ _ ch z. apply LE.
  Qed.
End GK.
