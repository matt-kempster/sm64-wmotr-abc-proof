(* ====================================================================== *)
(* spine (via BhvStep's spawn rows): OBJECTS -- create_object, run by its *)
(* real body (spawn_object.c:255-290), on top of ObjCreate's              *)
(* allocate_object.                                                       *)
(*   - the list index: objListIndex = (bhvScript[0] >> 16) & 0xFFFF when  *)
(*     the script's first command is BEGIN (top byte 0), else 8          *)
(*     (OBJ_LIST_DEFAULT) -- bhv_list, read from the script word;        *)
(*   - objList = gObjectLists + index (gObjectLists = &gObjectListArray, *)
(*     obj_w's ow_gol);                                                  *)
(*   - allocate_object (ObjCreate.alloc_real);                           *)
(*   - curBhvCommand / behavior := bhvScript, ACTIVE_FLAG_UNIMPORTANT for *)
(*     list 12, and the switch.  Lists 4 / 5 / 10 (OBJ_LIST_DESTRUCTIVE / *)
(*     GENACTOR / LEVEL) call snap_object_to_floor (find_floor): they are *)
(*     NOT walked here -- the premise bhv_list w <> 4 / 5 / 10 is a      *)
(*     positive fact about the script being spawned.                     *)
(* Result: the same disjunction as alloc_real, with create_facts.        *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory
  Globalenvs Ctypes Cop Clight ClightBigstep Clightdefs Events Errors.
From compcert Require Linking.
From SM64.Generated Require graph_node spawn_object object_list_processor area math_util.
From SM64.Proofs Require Import SymbolicLinking LinkedTwelve RealFrameLinked.
From SM64.Proofs.WMotRRequiresA Require Import ObjWorld ObjRing ObjAlloc ObjCreate.
From SM64.Proofs.WMotRRequiresA Require ObjSelf RenderAnim ObjLoop.

Import ListNotations.
Local Open Scope Z_scope.
Local Transparent Archi.ptr64.

Module RA := RenderAnim.
Module SO := SM64.Generated.spawn_object.

(* ---------------------------------------------------------------------- *)
(* 1. Statements that always complete normally.                            *)
(* ---------------------------------------------------------------------- *)
Fixpoint nb (s : statement) : bool :=
  match s with
  | Sskip | Sset _ _ | Sassign _ _ | Scall _ _ _ | Sbuiltin _ _ _ _ => true
  | Ssequence a b | Sifthenelse _ a b => nb a && nb b
  | _ => false
  end.

Lemma nb_normal : forall (ge : genv) e le m s t le' m' out,
  exec_stmt function_entry2 ge e le m s t le' m' out -> nb s = true -> out = Out_normal.
Proof.
  intros ge e le m s t le' m' out H. induction H; cbn [nb]; intros Hn; try discriminate Hn; try reflexivity.
  all: apply andb_true_iff in Hn as [Hn1 Hn2].
  all: first [ solve [ auto ] | solve [ exfalso; auto ] | destruct b; auto ].
Qed.

(* ---------------------------------------------------------------------- *)
(* 2. The body, cut into named statements.                                 *)
(* ---------------------------------------------------------------------- *)
Definition ON : type := Tstruct SO._ObjectNode noattr.
Definition SCR : expr :=
  Ederef (Ebinop Oadd (Etempvar SO._bhvScript (tptr tuint)) (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint.
Definition IDX : statement :=
  Ssequence (Sset SO._t'4 SCR)
    (Sifthenelse (Ebinop Oeq (Ebinop Oshr (Etempvar SO._t'4 tuint) (Econst_int (Int.repr 24) tint) tuint)
                   (Econst_int (Int.repr 0) tint) tint)
      (Ssequence (Sset SO._t'5 SCR)
         (Sset SO._objListIndex
            (Ebinop Oand (Ebinop Oshr (Etempvar SO._t'5 tuint) (Econst_int (Int.repr 16) tint) tuint)
               (Econst_int (Int.repr 65535) tint) tuint)))
      (Sset SO._objListIndex (Econst_int (Int.repr 8) tint))).
Definition LST : statement :=
  Ssequence (Sset SO._t'3 (Evar SO._gObjectLists (tptr ON)))
    (Sset SO._objList (Ebinop Oadd (Etempvar SO._t'3 (tptr ON)) (Etempvar SO._objListIndex tint) (tptr ON))).
Definition CALL : statement :=
  Ssequence
    (Scall (Some SO._t'1) (Evar SO._allocate_object (Tfunction [tptr ON] (tptr OT) cc_default))
       [Etempvar SO._objList (tptr ON)])
    (Sset SO._obj (Etempvar SO._t'1 (tptr OT))).
Definition FLD (f : ident) (ty : type) : expr := Efield (Ederef (Etempvar SO._obj (tptr OT)) OT) f ty.
Definition L1 : expr := FLD SO._curBhvCommand (tptr tuint).
Definition L2 : expr := FLD SO._behavior (tptr tuint).
Definition LF : expr := FLD SO._activeFlags tshort.
Definition ST1 : statement := Sassign L1 (Etempvar SO._bhvScript (tptr tuint)).
Definition ST2 : statement := Sassign L2 (Etempvar SO._behavior (tptr tuint)).
Definition OR12 : expr :=
  Ebinop Oor (Etempvar SO._t'2 tshort)
    (Ebinop Oshl (Econst_int (Int.repr 1) tint) (Econst_int (Int.repr 4) tint) tint) tint.
Definition IF12 : statement :=
  Sifthenelse (Ebinop Oeq (Etempvar SO._objListIndex tint) (Econst_int (Int.repr 12) tint) tint)
    (Ssequence (Sset SO._t'2 LF) (Sassign LF OR12)) Sskip.
Definition SNAP : statement :=
  Ssequence
    (Scall None (Evar SO._snap_object_to_floor (Tfunction [tptr OT] tvoid cc_default))
       [Etempvar SO._obj (tptr OT)])
    Sbreak.
Definition SWL : labeled_statements :=
  LScons (Some 4) Sskip (LScons (Some 5) Sskip (LScons (Some 10) SNAP (LScons None Sbreak LSnil))).
Definition SW : statement := Sswitch (Etempvar SO._objListIndex tint) SWL.
Definition RET : statement := Sreturn (Some (Etempvar SO._obj (tptr OT))).

Lemma CB_eq : fn_body SO.f_create_object =
  Ssequence (Sset SO._behavior (Etempvar SO._bhvScript (tptr tuint)))
    (Ssequence IDX (Ssequence LST (Ssequence CALL (Ssequence ST1 (Ssequence ST2
      (Ssequence IF12 (Ssequence SW RET))))))).
Proof. reflexivity. Qed.

Lemma lad_L1 : ObjSelf.lad CE [SO._obj] L1 = Some O_CMD.
Proof. vm_compute. reflexivity. Qed.
Lemma lad_L2 : ObjSelf.lad CE [SO._obj] L2 = Some O_BHV.
Proof. vm_compute. reflexivity. Qed.
Lemma lad_LF : ObjSelf.lad CE [SO._obj] LF = Some O_FLAGS.
Proof. vm_compute. reflexivity. Qed.
Lemma wr_L1 : wr_ok O_CMD 4 = true.
Proof. vm_compute. reflexivity. Qed.
Lemma wr_L2 : wr_ok O_BHV 4 = true.
Proof. vm_compute. reflexivity. Qed.
Lemma wr_LF : wr_ok O_FLAGS 2 = true.
Proof. vm_compute. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* 3. The list index and the facts.                                        *)
(* ---------------------------------------------------------------------- *)
(* objListIndex, from the script's first word *)
Definition idx_v (w : int) : int :=
  if Int.eq (Int.shru w (Int.repr 24)) Int.zero
  then Int.and (Int.shru w (Int.repr 16)) (Int.repr 65535) else Int.repr 8.
Definition bhv_list (w : int) : Z := Int.unsigned (idx_v w).

(* alloc_facts, then curBhvCommand and behavior := the script pointer;
   list 12 (OBJ_LIST_UNIMPORTANT) also gets ACTIVE_FLAG_UNIMPORTANT *)
Definition cf0 (bv : val) : list fact :=
  (Mint32, O_BHV, SC bv) :: kill O_BHV 4 ((Mint32, O_CMD, SC bv) :: kill O_CMD 4 alloc_facts).
Definition create_facts (i : Z) (bv : val) : list fact :=
  if Z.eqb i 12 then (Mint16signed, O_FLAGS, SC (Vint (Int.repr 273))) :: kill O_FLAGS 2 (cf0 bv)
  else cf0 bv.

Lemma inb_ok : forall f F, existsb (fact_eqb f) F = true -> In f F.
Proof.
  intros f F H. apply existsb_exists in H as (y & Hy & E). apply fact_eqb_eq in E. rewrite E. exact Hy.
Qed.

Lemma af_flags : In (Mint16signed, O_FLAGS, SC (Vint (Int.repr 257))) alloc_facts.
Proof. apply inb_ok. vm_compute. reflexivity. Qed.

Lemma cf_gen : forall bv F f, In f F -> disj O_CMD 4 f = true -> disj O_BHV 4 f = true ->
  In f ((Mint32, O_BHV, SC bv) :: kill O_BHV 4 ((Mint32, O_CMD, SC bv) :: kill O_CMD 4 F)).
Proof.
  intros bv F f H H1 H2. right. apply filter_In. split; [ | exact H2 ].
  right. apply filter_In. split; [ exact H | exact H1 ].
Qed.

Lemma cf0_flags : forall bv, In (Mint16signed, O_FLAGS, SC (Vint (Int.repr 257))) (cf0 bv).
Proof. intros bv. exact (cf_gen bv alloc_facts _ af_flags eq_refl eq_refl). Qed.

Lemma ofs_n : forall n, (n < 13)%nat ->
  Ptrofs.add Ptrofs.zero (Ptrofs.mul (Ptrofs.repr NODESZ) (Ptrofs.of_ints (Int.repr (Z.of_nat n))))
  = Ptrofs.repr (hoff n).
Proof. intros n H. do 13 (destruct n as [|n]; [ reflexivity | ]). lia. Qed.

Lemma sz_ok_on : ObjLoop.sz_ok (prog_comp_env SO.prog) SO._ObjectNode NODESZ = true.
Proof. vm_compute. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* 4. Generic steps.                                                       *)
(* ---------------------------------------------------------------------- *)
Section STEPS.
  Variable ge : genv.
  Notation xs := (exec_stmt function_entry2 ge empty_env).

  Lemma ld_script : forall le m bs o w v,
    le ! SO._bhvScript = Some (Vptr bs o) -> Mem.load Mint32 m bs (Ptrofs.unsigned o) = Some (Vint w) ->
    eval_expr ge empty_env le m SCR v -> v = Vint w.
  Proof.
    intros le m bs o w v Hs Hw H. unfold SCR in H. inv H.
    match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _, Hd : deref_loc _ _ _ _ _ _ |- _ =>
      apply RA.lv_deref0 in Hl as (o0 & Hx & -> & E); rewrite Hs in Hx; injection Hx as <- <-;
      injection E as ->; inv Hd end; cbn in *; try discriminate.
    match goal with Ha : By_value _ = By_value _, Hl : Mem.load _ _ _ _ = Some _ |- _ =>
      injection Ha as <-;
      assert (Z0 : Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_ints (Int.repr 0)) = Ptrofs.zero) by reflexivity;
      rewrite Z0, Ptrofs.add_zero, Hw in Hl; injection Hl as <-; reflexivity end.
  Qed.

  Lemma idx_ok : forall le m bs o w t le' m' out,
    le ! SO._bhvScript = Some (Vptr bs o) -> Mem.load Mint32 m bs (Ptrofs.unsigned o) = Some (Vint w) ->
    xs le m IDX t le' m' out ->
    m' = m /\ out = Out_normal /\ le' ! SO._objListIndex = Some (Vint (idx_v w))
    /\ (forall y, y <> SO._objListIndex -> y <> SO._t'4 -> y <> SO._t'5 -> le' ! y = le ! y).
  Proof.
    intros le m bs o w t le' m' out Hs Hw H. unfold IDX in H.
    apply RA.seq_inv in H as [(t1 & le1 & m1 & t2 & A & B) | (A & Hne)].
    2:{ apply RA.set_inv in A as (_ & _ & _ & _ & E). contradiction. }
    apply RA.set_inv in A as (v4 & E4 & -> & -> & _).
    rewrite (ld_script _ _ _ _ _ _ Hs Hw E4) in *. clear E4.
    apply RA.if_inv in B as (vc & bc & Ec & Bc & B).
    apply RA.ev_binop in Ec as (a1 & a2 & Ea1 & Ea2 & Sa).
    apply RA.ev_binop in Ea1 as (b1 & b2 & Eb1 & Eb2 & Sb).
    apply RA.ev_temp in Eb1. rewrite PTree.gss in Eb1. injection Eb1 as <-.
    apply RA.ev_const in Eb2. apply RA.ev_const in Ea2. subst b2 a2.
    cbn [typeof] in Sa, Sb, Bc.
    assert (E1 : sem_binary_operation ge Oshr (Vint w) tuint (Vint (Int.repr 24)) tint m
                 = Some (Vint (Int.shru w (Int.repr 24)))) by reflexivity.
    rewrite E1 in Sb. injection Sb as <-.
    assert (E2 : sem_binary_operation ge Oeq (Vint (Int.shru w (Int.repr 24))) tuint (Vint (Int.repr 0)) tint m
                 = Some (Val.of_bool (Int.eq (Int.shru w (Int.repr 24)) Int.zero))) by reflexivity.
    rewrite E2 in Sa. injection Sa as <-. rewrite bool_ofb in Bc. injection Bc as <-.
    unfold idx_v. destruct (Int.eq (Int.shru w (Int.repr 24)) Int.zero).
    - apply RA.seq_inv in B as [(t3 & le3 & m3 & t4 & A & C) | (A & Hne)].
      2:{ apply RA.set_inv in A as (_ & _ & _ & _ & E). contradiction. }
      apply RA.set_inv in A as (v5 & E5 & -> & -> & _).
      assert (Hs' : (PTree.set SO._t'4 (Vint w) le) ! SO._bhvScript = Some (Vptr bs o))
        by (rewrite PTree.gso by RA.neq; exact Hs).
      rewrite (ld_script _ _ _ _ _ _ Hs' Hw E5) in *. clear E5.
      apply RA.set_inv in C as (v6 & E6 & -> & -> & ->).
      apply RA.ev_binop in E6 as (a1 & a2 & Ea1 & Ea2 & Sa).
      apply RA.ev_binop in Ea1 as (b1 & b2 & Eb1 & Eb2 & Sb).
      apply RA.ev_temp in Eb1. rewrite PTree.gss in Eb1. injection Eb1 as <-.
      apply RA.ev_const in Eb2. apply RA.ev_const in Ea2. subst b2 a2.
      cbn [typeof] in Sa, Sb.
      assert (E3 : sem_binary_operation ge Oshr (Vint w) tuint (Vint (Int.repr 16)) tint m
                   = Some (Vint (Int.shru w (Int.repr 16)))) by reflexivity.
      rewrite E3 in Sb. injection Sb as <-.
      assert (E4 : sem_binary_operation ge Oand (Vint (Int.shru w (Int.repr 16))) tuint (Vint (Int.repr 65535)) tint m
                   = Some (Vint (Int.and (Int.shru w (Int.repr 16)) (Int.repr 65535)))) by reflexivity.
      rewrite E4 in Sa. injection Sa as <-.
      refine (conj eq_refl (conj eq_refl (conj (PTree.gss _ _ _) _))).
      intros y H1 H2 H3. rewrite !PTree.gso by assumption. reflexivity.
    - apply RA.set_inv in B as (v6 & E6 & -> & -> & ->).
      apply RA.ev_const in E6. subst v6.
      refine (conj eq_refl (conj eq_refl (conj (PTree.gss _ _ _) _))).
      intros y H1 H2 H3. rewrite !PTree.gso by assumption. reflexivity.
  Qed.

  Hypothesis Hcs : forall id co, (prog_comp_env SO.prog) ! id = Some co -> (genv_cenv ge) ! id = Some co.

  Lemma lst_ok : forall gol la le m n t le' m' out,
    Genv.find_symbol ge SO._gObjectLists = Some gol -> Mem.load Mint32 m gol 0 = Some (Vptr la Ptrofs.zero) ->
    le ! SO._objListIndex = Some (Vint (Int.repr (Z.of_nat n))) -> (n < 13)%nat ->
    xs le m LST t le' m' out ->
    m' = m /\ out = Out_normal /\ le' ! SO._objList = Some (Vptr la (Ptrofs.repr (hoff n)))
    /\ (forall y, y <> SO._objList -> y <> SO._t'3 -> le' ! y = le ! y).
  Proof.
    intros gol la le m n t le' m' out Hg Hgo Hi Hn H. unfold LST in H.
    apply RA.seq_inv in H as [(t1 & le1 & m1 & t2 & A & B) | (A & Hne)].
    2:{ apply RA.set_inv in A as (_ & _ & _ & _ & E). contradiction. }
    apply RA.set_inv in A as (v3 & E3 & -> & -> & _).
    destruct (RA.ev_gvar ge empty_env m le SO._gObjectLists (tptr ON) v3 Mint32 (PTree.gempty _ _) eq_refl E3) as (b & Hb & Hl).
    rewrite Hg in Hb. injection Hb as <-. cbn [Mem.loadv] in Hl. rewrite Ptrofs.unsigned_zero, Hgo in Hl.
    injection Hl as <-. clear E3.
    apply RA.set_inv in B as (v & Ev & -> & -> & ->).
    apply RA.ev_binop in Ev as (x1 & x2 & X1 & X2 & X3).
    apply RA.ev_temp in X1. rewrite PTree.gss in X1. injection X1 as <-.
    apply RA.ev_temp in X2. rewrite PTree.gso in X2 by RA.neq. rewrite Hi in X2. injection X2 as <-.
    cbn [typeof] in X3.
    assert (E : sem_binary_operation ge Oadd (Vptr la Ptrofs.zero) (tptr ON) (Vint (Int.repr (Z.of_nat n))) tint m
                = Some (Vptr la (Ptrofs.add Ptrofs.zero (Ptrofs.mul (Ptrofs.repr NODESZ)
                                                          (Ptrofs.of_ints (Int.repr (Z.of_nat n)))))))
      by (rewrite <- (ObjLoop.sz_ok_lift _ _ _ _ sz_ok_on Hcs); reflexivity).
    rewrite (ofs_n n Hn) in E.
    rewrite E in X3. injection X3 as <-.
    refine (conj eq_refl (conj eq_refl (conj (PTree.gss _ _ _) _))).
    intros y H1 H2. rewrite !PTree.gso by assumption. reflexivity.
  Qed.

  Lemma sw_ok : forall le m idx t le' m' out,
    le ! SO._objListIndex = Some (Vint idx) ->
    Int.unsigned idx <> 4 -> Int.unsigned idx <> 5 -> Int.unsigned idx <> 10 ->
    xs le m SW t le' m' out -> le' = le /\ m' = m /\ out = Out_normal.
  Proof.
    intros le m idx t le' m' out Hi H4 H5 H10 H. unfold SW in H. inv H.
    match goal with Ha : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      apply RA.ev_temp in Ha; rewrite Hi in Ha; injection Ha as <- end.
    match goal with Hs : sem_switch_arg _ _ = Some _ |- _ => cbn in Hs; injection Hs as <- end.
    assert (E : select_switch (Int.unsigned idx) SWL = LScons None Sbreak LSnil).
    { unfold select_switch, SWL. cbn [select_switch_case].
      destruct (zeq 4 (Int.unsigned idx)); [ lia | ].
      destruct (zeq 5 (Int.unsigned idx)); [ lia | ].
      destruct (zeq 10 (Int.unsigned idx)); [ lia | ].
      reflexivity. }
    match goal with Hx : exec_stmt _ _ _ _ _ (seq_of_labeled_statement _) _ _ _ _ |- _ =>
      rewrite E in Hx; cbn [seq_of_labeled_statement] in Hx;
      apply RA.seq_inv in Hx as [(t1 & le1 & m1 & t2 & A & B) | (A & Hne)] end.
    - apply break_inv in A as (_ & _ & E'). discriminate E'.
    - apply break_inv in A as (-> & -> & ->). auto.
  Qed.
End STEPS.

Section ST.
  Variable ge : genv.
  Variables pool gB : block.
  Hypothesis Hpool : Genv.find_symbol ge ObjSelf.POOL = Some pool.
  Hypothesis HgB : Genv.find_symbol ge ObjSelf.GCO = Some gB.
  Variable ce : composite_env.
  Hypothesis Hce : ObjSelf.cext ge ce.
  Variable x : ident.
  Variable k : Z.
  Hypothesis Hk : 0 <= k < NSLOT.

  (* a store through the slot temp, at a lad-named offset *)
  Lemma st_any : forall l r le m t le' m' out d ch,
    ObjSelf.lad ce [x] l = Some d -> access_mode (typeof l) = By_value ch -> wr_ok d (size_chunk ch) = true ->
    le ! x = Some (slot_v pool k) ->
    exec_stmt function_entry2 ge empty_env le m (Sassign l r) t le' m' out ->
    exists v2 v, eval_expr ge empty_env le m r v2 /\ sem_cast v2 (typeof r) (typeof l) m = Some v
      /\ le' = le /\ out = Out_normal /\ Mem.store ch m pool (k * OSZ + d) v = Some m'
      /\ Mem.unchanged_on (KP pool (k * OSZ)) m m'.
  Proof.
    intros l r le m t le' m' out d ch Ed Ea Ew Hx H.
    apply RA.assign_inv in H as (b & o & bf & v2 & v & Hl & He & Hc & Has & -> & ->).
    destruct (lad_at ge pool gB Hpool HgB ce Hce x k le m l b o bf d Hx Hl Ed) as (-> & -> & ->).
    pose proof (RA.store_by_value ge (typeof l) m pool _ Full v m' ch Ea eq_refl Has) as Hs.
    destruct (wr_ok_range _ _ Ew) as (Hd0 & Hd1 & Hn).
    pose proof (size_chunk_pos ch) as Hsz.
    rewrite (slot_fld k d Hk) in Hs by lia.
    exists v2, v. refine (conj He (conj Hc (conj eq_refl (conj eq_refl (conj Hs _))))).
    apply (Mem.store_unchanged_on (KP pool (k * OSZ)) ch m pool (k * OSZ + d) v m' Hs).
    intros i Hi. exact (wr_ok_nkp pool (k * OSZ) d (size_chunk ch) i Ew Hi).
  Qed.

  (* a load through the slot temp *)
  Lemma ld_fld : forall a f ty le m v d ch,
    ObjSelf.lad ce [x] (Efield a f ty) = Some d -> access_mode ty = By_value ch -> 0 <= d < OSZ ->
    le ! x = Some (slot_v pool k) ->
    eval_expr ge empty_env le m (Efield a f ty) v -> Mem.load ch m pool (k * OSZ + d) = Some v.
  Proof.
    intros a f ty le m v d ch Ed Ea Hd Hx H. inv H.
    match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _, Hdl : deref_loc _ _ _ _ _ _ |- _ =>
      destruct (lad_at ge pool gB Hpool HgB ce Hce x k le m _ _ _ _ d Hx Hl Ed) as (-> & -> & ->);
      inv Hdl end; cbn [typeof] in *; try congruence.
    match goal with Hld : Mem.loadv _ _ _ = Some _ |- _ =>
      cbn [Mem.loadv] in Hld; rewrite (slot_fld k d Hk Hd) in Hld end.
    match goal with Ha : access_mode _ = By_value _ |- _ => rewrite Ea in Ha; injection Ha as <- end.
    assumption.
  Qed.
End ST.

(* ---------------------------------------------------------------------- *)
(* 5. create_object on the real linked program.                            *)
(* ---------------------------------------------------------------------- *)
Lemma dm_ao : (prog_defmap SO.prog) ! SO._allocate_object = Some (Gfun (Internal SO.f_allocate_object)).
Proof. vm_compute. reflexivity. Qed.

Lemma eq_ii : forall (ce : composite_env) m a b,
  sem_binary_operation ce Oeq (Vint a) tint (Vint b) tint m = Some (Val.of_bool (Int.eq a b)).
Proof. reflexivity. Qed.

Ltac sq H t1 le1 m1 t2 H1 H2 :=
  let Hne := fresh "Hne" in
  apply RA.seq_inv in H as [(t1 & le1 & m1 & t2 & H1 & H2) | (H1 & Hne)];
  [ | exfalso; apply Hne; exact (nb_normal _ _ _ _ _ _ _ _ _ H1 eq_refl) ].

Section LINKED.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Notation G := (lp_ge lp).

  (* CREATE_OBJECT ON THE REAL PROGRAM.  Premises: the five symbols, obj_w's
     ow_rings / ow_free / ow_part (NoDup) / ow_gfx / ow_gol, the script's
     first word w, and that its list is not 4 / 5 / 10 (no floor snap). *)
  Theorem create_real : forall pool la fl bpg gol,
    Genv.find_symbol G object_list_processor._gObjectPool = Some pool ->
    Genv.find_symbol G object_list_processor._gObjectListArray = Some la ->
    Genv.find_symbol G object_list_processor._gFreeObjectList = Some fl ->
    Genv.find_symbol G area._gObjParentGraphNode = Some bpg ->
    Genv.find_symbol G object_list_processor._gObjectLists = Some gol ->
    forall m rs fs bs o w t m' vr,
    rings m pool la = Some rs -> free_list m pool fl = Some fs -> NoDup (concat rs ++ fs) ->
    gfx_ok G pool m -> Mem.load Mint32 m gol 0 = Some (Vptr la Ptrofs.zero) ->
    Mem.load Mint32 m bs (Ptrofs.unsigned o) = Some (Vint w) ->
    bhv_list w < 13 -> bhv_list w <> 4 -> bhv_list w <> 5 -> bhv_list w <> 10 ->
    eval_funcall function_entry2 G m (Internal SO.f_create_object) [Vptr bs o] t m' vr ->
    (* EMPTY FREE LIST: named, as in alloc_real *)
    fs = []
    \/ (exists k fs', fs = k :: fs' /\ 0 <= k < NSLOT /\ vr = slot_v pool k
        /\ rings m' pool la = Some (upd rs (Z.to_nat (bhv_list w)) (nth (Z.to_nat (bhv_list w)) rs [] ++ [k]))
        /\ free_list m' pool fl = Some fs'
        /\ gfx_ok G pool m'
        /\ Mem.unchanged_on (fun b z => AKEEP pool la fl bpg b z /\ KP pool (k * OSZ) b z) m m'
        /\ facts m' pool (k * OSZ) (slot_v pool k) (create_facts (bhv_list w) (Vptr bs o))).
  Proof.
    intros pool la fl bpg gol Hp Hl Hf Hb Hgl m rs fs bs o w t m' vr Hr Hfl Hnd Hg Hgo Hw Hi13 Hi4 Hi5 Hi10 H.
    assert (Hpl : pool <> la) by (apply (sym_ne lp _ _ _ _ Hp Hl); RA.neq).
    assert (Hpf : pool <> fl) by (apply (sym_ne lp _ _ _ _ Hp Hf); RA.neq).
    assert (Hlf : la <> fl) by (apply (sym_ne lp _ _ _ _ Hl Hf); RA.neq).
    assert (Hpb : pool <> bpg) by (apply (sym_ne lp _ _ _ _ Hp Hb); RA.neq).
    assert (Hlb : la <> bpg) by (apply (sym_ne lp _ _ _ _ Hl Hb); RA.neq).
    assert (Hfb : fl <> bpg) by (apply (sym_ne lp _ _ _ _ Hf Hb); RA.neq).
    destruct dm_gco as (gd & Hdm).
    destruct (linkorder_resolves_symbol lp SO.prog _ gd (linked12_LO_spawn_object lp H12) Hdm) as (gB & HgB).
    assert (Hcs : forall id co, (prog_comp_env SO.prog) ! id = Some co -> (genv_cenv G) ! id = Some co)
      by exact (cenv_of lp _ (linked12_LO_spawn_object lp H12)).
    assert (Hce' : ObjSelf.cext G CE) by exact Hcs.
    set (n := Z.to_nat (bhv_list w)) in *.
    assert (Hn : (n < NLIST)%nat).
    { unfold n, NLIST. pose proof (Int.unsigned_range (idx_v w)). unfold bhv_list in *. lia. }
    assert (Eidx : idx_v w = Int.repr (Z.of_nat n)).
    { unfold n, bhv_list. rewrite Z2Nat.id by (apply Int.unsigned_range). symmetry. apply Int.repr_unsigned. }
    destruct (fcall_inv0 G SO.f_create_object m _ t m' vr eq_refl H) as (le & le' & out & Hbd & Hx & Hov).
    cbn [fn_params SO.f_create_object bind_parameter_temps] in Hbd. injection Hbd as Hle.
    assert (Hs0 : le ! SO._bhvScript = Some (Vptr bs o)) by (rewrite <- Hle; apply PTree.gss).
    rewrite CB_eq in Hx.
    (* behavior = bhvScript *)
    sq Hx t1 le1 m1 t2 H1 H2.
    apply RA.set_inv in H1 as (v1 & Ev1 & -> & -> & _).
    apply RA.ev_temp in Ev1. rewrite Hs0 in Ev1. injection Ev1 as <-.
    (* the list index *)
    sq H2 t3 le3 m3 t4 H3 H4.
    assert (Hs1 : (PTree.set SO._behavior (Vptr bs o) le) ! SO._bhvScript = Some (Vptr bs o))
      by (rewrite PTree.gso by RA.neq; exact Hs0).
    destruct (idx_ok G _ m bs o w _ _ _ _ Hs1 Hw H3)
      as (-> & _ & Hi3 & Ho3).
    rewrite Eidx in Hi3.
    (* objList = gObjectLists + index *)
    sq H4 t5 le5 m5 t6 H5 H6.
    destruct (lst_ok G Hcs gol la _ m n _ _ _ _ Hgl Hgo Hi3 Hn H5) as (-> & _ & Hl5 & Ho5).
    (* obj = allocate_object(objList) *)
    sq H6 t7 le7 m7 t8 H7 H8.
    apply RA.seq_inv in H7 as [(ta & lea & ma & tb & Ha & Hb2) | (Ha & Hne)].
    2:{ exfalso. apply Hne. exact (nb_normal _ _ _ _ _ _ _ _ _ Ha eq_refl). }
    apply RA.call_inv in Ha as (tyargs & tyres & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hc & -> & _).
    cbn in Hcf. injection Hcf as <- <- <-.
    match type of Evf with eval_expr _ _ _ _ (Evar _ ?ty) _ =>
      destruct (RA.ev_fun G empty_env _ _ _ ty vf (PTree.gempty _ _) eq_refl Evf) as (bf & Hsf & ->) end.
    rewrite (fun_res lp _ _ _ (linked12_LO_spawn_object lp H12) dm_ao bf fd Hsf Hff) in Hc.
    destruct (ObjLoop.exl1 _ _ _ _ _ _ _ Eal) as (ty1 & u & u' & Ety & -> & Eu & Cu).
    injection Ety as <-.
    apply RA.ev_temp in Eu. rewrite Hl5 in Eu. injection Eu as <-.
    cbn [typeof] in Cu. apply RA.cast_ptr_id in Cu. subst u'.
    destruct (alloc_real lp H12 pool la fl bpg Hp Hl Hf Hb m rs fs n _ _ _ Hr Hfl Hnd Hg Hn Hc)
      as [E | (k & fs' & E & Hk & Ev & R & F & Gx & U & HF)].
    { left. exact E. }
    right. exists k, fs'. subst vres.
    apply RA.set_inv in Hb2 as (v & Hv & -> & -> & _).
    apply RA.ev_temp in Hv. cbn [set_opttemp] in Hv. rewrite PTree.gss in Hv. injection Hv as <-.
    set (le9 := PTree.set SO._obj (slot_v pool k) _) in H8.
    assert (Hx9 : le9 ! SO._obj = Some (slot_v pool k)) by (unfold le9; apply PTree.gss).
    assert (Hb9 : le9 ! SO._bhvScript = Some (Vptr bs o)).
    { unfold le9. cbn [set_opttemp]. rewrite !PTree.gso by RA.neq. rewrite Ho5 by RA.neq. rewrite Ho3 by RA.neq.
      rewrite PTree.gso by RA.neq. exact Hs0. }
    assert (Hh9 : le9 ! SO._behavior = Some (Vptr bs o)).
    { unfold le9. cbn [set_opttemp]. rewrite !PTree.gso by RA.neq. rewrite Ho5 by RA.neq. rewrite Ho3 by RA.neq.
      apply PTree.gss. }
    assert (Hi9 : le9 ! SO._objListIndex = Some (Vint (Int.repr (Z.of_nat n)))).
    { unfold le9. cbn [set_opttemp]. rewrite !PTree.gso by RA.neq. rewrite Ho5 by RA.neq. exact Hi3. }
    clearbody le9.
    (* curBhvCommand = bhvScript *)
    sq H8 t9 le10 m10 t10 H9 H10.
    destruct (st_any G pool gB Hp HgB CE Hce' SO._obj k Hk L1 _ _ _ _ _ _ _ O_CMD Mint32
                lad_L1 eq_refl wr_L1 Hx9 H9) as (v2 & v & Ev & Cv & -> & _ & S1 & U1).
    apply RA.ev_temp in Ev. rewrite Hb9 in Ev. injection Ev as <-.
    cbn [typeof L1 FLD] in Cv. apply RA.cast_ptr_id in Cv. subst v.
    pose proof (facts_store _ pool (k * OSZ) (slot_v pool k) alloc_facts Mint32 O_CMD _ _ (SC (Vptr bs o))
                  S1 eq_refl HF) as HF1.
    (* behavior = behavior *)
    sq H10 t11 le11 m11 t12 H11 H12'.
    destruct (st_any G pool gB Hp HgB CE Hce' SO._obj k Hk L2 _ _ _ _ _ _ _ O_BHV Mint32
                lad_L2 eq_refl wr_L2 Hx9 H11) as (v2 & v & Ev & Cv & -> & _ & S2 & U2).
    apply RA.ev_temp in Ev. rewrite Hh9 in Ev. injection Ev as <-.
    cbn [typeof L2 FLD] in Cv. apply RA.cast_ptr_id in Cv. subst v.
    pose proof (facts_store _ pool (k * OSZ) (slot_v pool k) _ Mint32 O_BHV _ _ (SC (Vptr bs o))
                  S2 eq_refl HF1) as HF2.
    change (facts m11 pool (k * OSZ) (slot_v pool k) (cf0 (Vptr bs o))) in HF2.
    (* if (objListIndex == OBJ_LIST_UNIMPORTANT) *)
    sq H12' t13 le13 m13 t14 H13 H14.
    apply RA.if_inv in H13 as (vc & bc & Ec & Bc & H13).
    apply RA.ev_binop in Ec as (a1 & a2 & Ea1 & Ea2 & Sa).
    apply RA.ev_temp in Ea1. rewrite Hi9 in Ea1. injection Ea1 as <-.
    apply RA.ev_const in Ea2. subst a2. cbn [typeof] in Sa, Bc.
    rewrite eq_ii in Sa. injection Sa as <-. rewrite bool_ofb in Bc. injection Bc as <-.
    assert (HF3 : exists m3', facts m3' pool (k * OSZ) (slot_v pool k) (create_facts (bhv_list w) (Vptr bs o))
                    /\ Mem.unchanged_on (KP pool (k * OSZ)) m11 m3' /\ m13 = m3' /\ le13 ! SO._obj = Some (slot_v pool k)
                    /\ le13 ! SO._objListIndex = Some (Vint (Int.repr (Z.of_nat n)))).
    { destruct (Int.eq (Int.repr (Z.of_nat n)) (Int.repr 12)) eqn:E12.
      - assert (Hw12 : bhv_list w = 12).
        { unfold bhv_list. rewrite Eidx. apply Int.same_if_eq in E12. rewrite E12. reflexivity. }
        apply RA.seq_inv in H13 as [(ta' & lea' & ma' & tb' & A & B) | (A & Hne)].
        2:{ apply RA.set_inv in A as (_ & _ & _ & _ & E'). contradiction. }
        apply RA.set_inv in A as (vf2 & Ef & -> & -> & _).
        assert (JF : 0 <= O_FLAGS < OSZ) by (unfold O_FLAGS, OSZ; lia).
        pose proof (ld_fld G pool gB Hp HgB CE Hce' SO._obj k Hk _ _ _ _ _ _ O_FLAGS Mint16signed
                      lad_LF eq_refl JF Hx9 Ef) as Lf.
        rewrite (HF2 _ _ _ (cf0_flags (Vptr bs o))) in Lf. injection Lf as <-. clear Ef.
        assert (Hx' : (PTree.set SO._t'2 (Vint (Int.repr 257)) le9) ! SO._obj = Some (slot_v pool k))
          by (rewrite PTree.gso by RA.neq; exact Hx9).
        destruct (st_any G pool gB Hp HgB CE Hce' SO._obj k Hk LF _ _ _ _ _ _ _ O_FLAGS Mint16signed
                    lad_LF eq_refl wr_LF Hx' B) as (v2 & v & Ev & Cv & -> & _ & S3 & U3).
        unfold OR12 in Ev.
        apply RA.ev_binop in Ev as (x1 & x2 & X1 & X2 & X3).
        apply RA.ev_temp in X1. rewrite PTree.gss in X1. injection X1 as <-.
        apply RA.ev_binop in X2 as (y1 & y2 & Y1 & Y2 & Y3).
        apply RA.ev_const in Y1. apply RA.ev_const in Y2. subst y1 y2.
        cbn [typeof] in X3, Y3.
        assert (Esh : sem_binary_operation G Oshl (Vint (Int.repr 1)) tint (Vint (Int.repr 4)) tint m11
                      = Some (Vint (Int.repr 16))) by reflexivity.
        rewrite Esh in Y3. injection Y3 as <-.
        assert (Eor : sem_binary_operation G Oor (Vint (Int.repr 257)) tshort (Vint (Int.repr 16)) tint m11
                      = Some (Vint (Int.repr 273))) by reflexivity.
        rewrite Eor in X3. injection X3 as <-.
        cbn [typeof LF FLD OR12] in Cv.
        assert (Ec : sem_cast (Vint (Int.repr 273)) tint tshort m11 = Some (Vint (Int.repr 273))) by reflexivity.
        rewrite Ec in Cv. injection Cv as <-.
        exists m13. rewrite Hw12. unfold create_facts. rewrite Z.eqb_refl.
        refine (conj (facts_store _ pool (k * OSZ) (slot_v pool k) _ Mint16signed O_FLAGS _ _ (SC (Vint (Int.repr 273))) S3 eq_refl HF2)
                  (conj U3 (conj eq_refl _))).
        rewrite !PTree.gso by RA.neq. split; [ exact Hx9 | exact Hi9 ].
      - assert (Hw12 : bhv_list w <> 12).
        { unfold bhv_list. rewrite Eidx. intros E'. rewrite <- E' in E12. rewrite Int.repr_unsigned in E12.
          rewrite Int.eq_true in E12. discriminate E12. }
        apply RA.skip_inv in H13 as (-> & -> & _).
        exists m11. unfold create_facts. rewrite (proj2 (Z.eqb_neq _ _) Hw12).
        refine (conj HF2 (conj (Mem.unchanged_on_refl _ _) (conj eq_refl (conj Hx9 Hi9)))). }
    destruct HF3 as (m3' & HF3 & U3 & -> & Hx13 & Hi13').
    (* the switch: lists 4 / 5 / 10 excluded *)
    assert (J4 : Int.unsigned (Int.repr (Z.of_nat n)) <> 4) by (rewrite <- Eidx; exact Hi4).
    assert (J5 : Int.unsigned (Int.repr (Z.of_nat n)) <> 5) by (rewrite <- Eidx; exact Hi5).
    assert (J10 : Int.unsigned (Int.repr (Z.of_nat n)) <> 10) by (rewrite <- Eidx; exact Hi10).
    apply RA.seq_inv in H14 as [(t15 & le15 & m15 & t16 & H15 & H16) | (H15 & Hne)].
    2:{ destruct (sw_ok G _ _ _ _ _ _ _ Hi13' J4 J5 J10 H15) as (_ & _ & E').
        contradiction. }
    destruct (sw_ok G _ _ _ _ _ _ _ Hi13' J4 J5 J10 H15) as (-> & -> & _).
    (* return obj *)
    unfold RET in H16. apply RA.ret_inv in H16 as (-> & v9 & Ev9 & ->).
    apply RA.ev_temp in Ev9. rewrite Hx13 in Ev9. injection Ev9 as <-.
    cbn [outcome_result_value fn_return SO.f_create_object typeof] in Hov. destruct Hov as (_ & Hov).
    apply RA.cast_ptr_id in Hov. subst vr.
    assert (Us : Mem.unchanged_on (KP pool (k * OSZ)) ma m3').
    { exact (Mem.unchanged_on_trans _ _ _ _ U1 (Mem.unchanged_on_trans _ _ _ _ U2 U3)). }
    refine (conj E (conj Hk (conj eq_refl (conj _ (conj _ (conj _ (conj _ HF3))))))).
    - exact (rings_keep pool la (KP pool (k * OSZ)) (KP_rcell pool la fl bpg Hpl Hpf Hlf Hpb Hlb Hfb k Hk)
               (fun i => or_introl (not_eq_sym Hpl)) ma m3' _ Hpl Us R).
    - exact (free_keep pool fl (KP pool (k * OSZ)) (KP_rcell pool la fl bpg Hpl Hpf Hlf Hpb Hlb Hfb k Hk)
               (fun i => or_introl (not_eq_sym Hpf)) ma m3' _ Us F).
    - apply (proj2 (gfx_at_iff pool bpg Hpb G m3' Hb)).
      exact (gfx_keep pool bpg (KP pool (k * OSZ)) ma m3' Us (KP_gcell pool la fl bpg Hpl Hpf Hlf Hpb Hlb Hfb k Hk)
               (proj1 (gfx_at_iff pool bpg Hpb G ma Hb) Gx)).
    - exact (Mem.unchanged_on_trans _ _ _ _ U (Mem.unchanged_on_implies _ _ _ _ Us (fun b z Hz _ => proj2 Hz))).
  Qed.
End LINKED.
