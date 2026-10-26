(* spine (via ObjFrame): OBJECTS phase S3 -- the OWN-SLOT frame (kSelf).
   Every object slot lives in the one gObjectPool block, so "the object's
   own slot" is a byte range of that block, not a block.  This file walks a
   body and proves that it changes the pool only inside the running slot
   [oc, oc + SZ) (oc: what gCurrentObject holds) and never changes
   gCurrentObject's own cell. *)
(* ====================================================================== *)
(* ObjSelf.v -- the own-slot frame (kSelf), generic over the table.       *)
(*                                                                        *)
(* SFR m m' = Mem.unchanged_on SFP m m',                                   *)
(* SFP b ofs = (b = pool /\ ofs outside [oc, oc+SZ)) \/ b = gCurrentObject *)
(* where (pool, oc) is the pointer gCurrentObject holds at entry (SI).    *)
(*                                                                        *)
(* A body is SELF-CLEAN (s_fun) when every store is                       *)
(*   - SELF: an lvalue built from a SELF temp (every definition is the    *)
(*     gCurrentObject load, or a self temp) by struct / union fields and  *)
(*     constant array indices, whose bytes lie inside [0, SZ) of the      *)
(*     slot (offsets from the TU's composite env, lifted to the link);    *)
(*   - or NP-rooted: its block is not the pool nor gCurrentObject's       *)
(*     (a local, a global other than gObjectPool / gCurrentObject, or a   *)
(*     pointer value built only from such addresses and non-pointer       *)
(*     loads);                                                            *)
(* and every call is a direct call of a table body / leaf whose           *)
(* parameter kinds (KSelf: the slot pointer; KNp: an NP pointer; KAny)    *)
(* the arguments meet.  No points-to analysis is assumed: a pointer       *)
(* loaded from memory is neither SELF nor NP, so a store through it (the  *)
(* parentObj chain, a spawned object, a script-indexed field) makes the   *)
(* body NOT self-clean -- those are the cross-slot writes, named by the   *)
(* census (ObjFrame).                                                     *)
(*                                                                        *)
(* No premise on SafeB or MWF: the walk needs only the symbols, the       *)
(* pointer gCurrentObject holds, and that the slot fits in ptrofs.        *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Errors.
From SM64.Generated Require object_list_processor.
From SM64.Proofs Require CameraModeBody MtxfBody ObjHelpersBodies PrintBodies SpawnBodies
  MathGeomGated CensusV2 SaveDoSaveBody.
From SM64.Proofs.WMotRRequiresA Require ObjWalk.

Import ListNotations.
Local Open Scope Z_scope.

Definition POOL : ident := object_list_processor._gObjectPool.
Definition GCO : ident := object_list_processor._gCurrentObject.

Inductive skind := KSelf | KNp | KAny.
Definition stab := list (ident * list skind).
Definition st_find (f : ident) (t : stab) : option (list skind) :=
  match find (fun p => Pos.eqb (fst p) f) t with Some (_, ks) => Some ks | None => None end.

Definition mem_i (x : ident) (l : list ident) : bool := existsb (Pos.eqb x) l.
Definition forbidden (x : ident) : bool := Pos.eqb x POOL || Pos.eqb x GCO.

Definition nonptr_chunk (ch : memory_chunk) : bool :=
  match ch with
  | Mint8signed | Mint8unsigned | Mint16signed | Mint16unsigned
  | Mfloat32 | Mfloat64 | Mint64 => true
  | _ => false
  end.

Definition zk (si : signedness) (k : int) : Z :=
  match si with Signed => Int.signed k | Unsigned => Int.unsigned k end.

(* ---------------------------------------------------------------------- *)
(* 1. The syntactic classes.                                                *)
(* ---------------------------------------------------------------------- *)

(* NP values: never a pointer into the pool or gCurrentObject's block *)
Section NP.
  Variable sn : list ident.

  Fixpoint npv (a : expr) : bool :=
    match a with
    | Econst_int _ _ | Econst_float _ _ | Econst_single _ _ | Econst_long _ _ => true
    | Esizeof _ _ | Ealignof _ _ | Eunop _ _ _ => true
    | Etempvar t _ => mem_i t sn
    | Eaddrof l _ =>
        match l with
        | Evar x _ => negb (forbidden x)
        | Ederef p _ | Efield p _ _ => npv p
        | _ => false
        end
    | Ebinop op a1 a2 _ =>
        (match op with Oadd => npv a1 && npv a2 | _ => false end)
        || CameraModeBody.never_ptr_binop op (typeof a1) (typeof a2)
    | Ecast a1 _ => npv a1
    | Evar x ty =>
        match access_mode ty with
        | By_value ch => nonptr_chunk ch
        | By_reference | By_copy => negb (forbidden x)
        | By_nothing => true
        end
    | Ederef p ty | Efield p _ ty =>
        match access_mode ty with
        | By_value ch => nonptr_chunk ch
        | By_reference | By_copy => npv p
        | By_nothing => true
        end
    end.

  (* the block of an lvalue *)
  Definition npl (a : expr) : bool :=
    match a with
    | Evar x _ => negb (forbidden x)
    | Ederef p _ | Efield p _ _ => npv p
    | _ => false
    end.
End NP.

(* integer constants, folding the `+ 0` of the o->oFoo macros *)
Fixpoint cint (a : expr) : option int :=
  match a with
  | Econst_int k _ => Some k
  | Ebinop Oadd a1 a2 _ =>
      match cint a1, cint a2, typeof a1, typeof a2 with
      | Some k1, Some k2, Tint I32 Signed _, Tint I32 Signed _ => Some (Int.add k1 k2)
      | _, _, _, _ => None
      end
  | _ => None
  end.

(* SELF addresses: the slot pointer plus a constant offset *)
Section SELF.
  Variable ce : composite_env.
  Variable ss : list ident.

  Definition fld_off (p : expr) (f : ident) (d : option Z) : option Z :=
    match d with
    | None => None
    | Some d0 =>
        match typeof p with
        | Tstruct id _ =>
            match ce ! id with
            | Some co =>
                if complete_members ce (co_members co) then
                  match field_offset ce f (co_members co) with
                  | OK (x, Full) => Some (d0 + x)
                  | _ => None
                  end
                else None
            | None => None
            end
        | Tunion id _ =>
            match ce ! id with
            | Some co =>
                if complete_members ce (co_members co) then
                  match union_field_offset ce f (co_members co) with
                  | OK (x, Full) => Some (d0 + x)
                  | _ => None
                  end
                else None
            | None => None
            end
        | _ => None
        end
    end.

  Fixpoint pad (a : expr) : option Z :=
    match a with
    | Etempvar t _ => if mem_i t ss then Some 0 else None
    | Ecast a1 _ => pad a1
    | Ebinop Oadd a1 a2 _ =>
        match cint a2 with
        | None => None
        | Some k =>
        match classify_add (typeof a1) (typeof a2) with
        | add_case_pi ty si =>
            if complete_type ce ty then
              match pad a1 with
              | Some d => Some (d + sizeof ce ty * zk si k)
              | None => None
              end
            else None
        | _ => None
        end
        end
    | Eaddrof l _ =>
        match l with
        | Ederef p _ => pad p
        | Efield p f _ => fld_off p f (pad p)
        | _ => None
        end
    | Ederef p ty =>
        match access_mode ty with
        | By_reference | By_copy => pad p
        | _ => None
        end
    | Efield p f ty =>
        match access_mode ty with
        | By_reference | By_copy => fld_off p f (pad p)
        | _ => None
        end
    | _ => None
    end.

  Definition lad (a : expr) : option Z :=
    match a with
    | Ederef p _ => pad p
    | Efield p f _ => fld_off p f (pad p)
    | _ => None
    end.

  Fixpoint selfv (a : expr) : bool :=
    match a with
    | Etempvar t _ => mem_i t ss
    | Ecast a1 _ => selfv a1
    | _ => false
    end.
End SELF.

Definition is_m32 (ty : type) : bool :=
  match access_mode ty with By_value Mint32 => true | _ => false end.

Definition selfdef (ss lv : list ident) (a : expr) : bool :=
  match a with
  | Evar x ty => Pos.eqb x GCO && negb (mem_i x lv) && is_m32 ty
  | _ => selfv ss a
  end.

Definition karg_ok (ss sn : list ident) (k : skind) (a : expr) : bool :=
  match k with KSelf => selfv ss a | KNp => npv sn a | KAny => true end.

Fixpoint args_ok (ss sn : list ident) (ks : list skind) (al : list expr) : bool :=
  match ks, al with
  | [], [] => true
  | k :: ks', a :: al' => karg_ok ss sn k a && args_ok ss sn ks' al'
  | _, _ => false
  end.

Definition self_store (ce : composite_env) (ss : list ident) (SZ : Z) (l : expr) : bool :=
  match access_mode (typeof l), lad ce ss l with
  | By_value ch, Some d => (0 <=? d) && (d + size_chunk ch <=? SZ)
  | _, _ => false
  end.

Definition st_set (ss sn lv : list ident) (id : ident) (a : expr) : bool :=
  (negb (mem_i id ss) || selfdef ss lv a) && (negb (mem_i id sn) || npv sn a).
Definition st_store (ce : composite_env) (ss sn : list ident) (SZ : Z) (l r : expr) : bool :=
  MtxfBody.is_byval (typeof l) && (npl sn l || self_store ce ss SZ l).
Definition st_call (ss sn lv : list ident) (tab : stab) (optid : option ident) (a : expr)
    (al : list expr) : bool :=
  match a with
  | Evar f (Tfunction _ _ _) =>
      negb (mem_i f lv) &&
      match st_find f tab with Some ks => args_ok ss sn ks al | None => false end
  | _ => false
  end
  && match optid with Some t => negb (mem_i t ss) && negb (mem_i t sn) | None => true end.

Definition s_chk (ce : composite_env) (SZ : Z) (tab : stab) (ss sn lv : list ident)
    (s : statement) : bool :=
  SpawnBodies.sw_chk (st_set ss sn lv) (st_store ce ss sn SZ) (st_call ss sn lv tab)
    (fun _ => true) s.

Fixpoint params_ok (ss sn : list ident) (ps : list ident) (ks : list skind) : bool :=
  match ps, ks with
  | [], [] => true
  | p :: ps', k :: ks' =>
      (negb (mem_i p ss) || match k with KSelf => true | _ => false end)
      && (negb (mem_i p sn) || match k with KNp => true | _ => false end)
      && params_ok ss sn ps' ks'
  | _, _ => false
  end.

(* the temp sets: the greatest sets whose every definition conforms *)
Fixpoint t_defs (s : statement) : list (ident * option expr) :=
  match s with
  | Sset t a => [(t, Some a)]
  | Scall (Some t) _ _ => [(t, None)]
  | Sbuiltin (Some t) _ _ _ => [(t, None)]
  | Ssequence s1 s2 | Sifthenelse _ s1 s2 | Sloop s1 s2 => t_defs s1 ++ t_defs s2
  | Slabel _ s1 => t_defs s1
  | Sswitch _ sl => t_defs_ls sl
  | _ => []
  end
with t_defs_ls (sl : labeled_statements) : list (ident * option expr) :=
  match sl with LSnil => [] | LScons _ s sl' => t_defs s ++ t_defs_ls sl' end.

Definition keep_self (lv : list ident) (ds : list (ident * option expr)) (ss : list ident) :=
  filter (fun t => forallb (fun d => negb (Pos.eqb (fst d) t) ||
                     match snd d with Some a => selfdef ss lv a | None => false end) ds) ss.
Definition keep_np (ds : list (ident * option expr)) (sn : list ident) :=
  filter (fun t => forallb (fun d => negb (Pos.eqb (fst d) t) ||
                     match snd d with Some a => npv sn a | None => false end) ds) sn.

Fixpoint iter_sets (n : nat) (lv : list ident) (ds : list (ident * option expr))
    (ss sn : list ident) : list ident * list ident :=
  match n with
  | O => (ss, sn)
  | S n' => iter_sets n' lv ds (keep_self lv ds ss) (keep_np ds sn)
  end.

Definition kind_params (k : skind) (ps : list ident) (ks : list skind) : list ident :=
  map fst (filter (fun p => match snd p, k with KSelf, KSelf | KNp, KNp => true | _, _ => false end)
             (combine ps ks)).

Definition sets_of (ks : list skind) (f : Clight.function) : list ident * list ident :=
  let lv := map fst (fn_vars f) in
  let ps := map fst (fn_params f) in
  let ts := map fst (fn_temps f) in
  let ds := t_defs (fn_body f) in
  iter_sets (S (List.length ts + List.length ps)) lv ds
    (kind_params KSelf ps ks ++ ts) (kind_params KNp ps ks ++ ts).

Definition s_fun (ce : composite_env) (SZ : Z) (tab : stab) (ks : list skind)
    (f : Clight.function) : bool :=
  let '(ss, sn) := sets_of ks f in
  s_chk ce SZ tab ss sn (map fst (fn_vars f)) (fn_body f)
  && params_ok ss sn (map fst (fn_params f)) ks.

(* ---------------------------------------------------------------------- *)
(* 2. Value bricks.                                                         *)
(* ---------------------------------------------------------------------- *)

Lemma unop_not_ptr : forall op v ty m b o,
    sem_unary_operation op v ty m = Some (Vptr b o) -> False.
Proof.
  intros op v ty m b o H.
  destruct op; cbn in H.
  - unfold sem_notbool in H. destruct (bool_val v ty m) as [bb|]; cbn in H; [ | discriminate H ].
    injection H as H. destruct (negb bb); discriminate H.
  - unfold sem_notint in H. destruct (classify_notint ty); destruct v; try discriminate H.
  - unfold sem_neg in H. destruct (classify_neg ty); destruct v; try discriminate H.
  - unfold sem_absfloat in H. destruct (classify_neg ty); destruct v; try discriminate H.
Qed.

Lemma load_nonptr : forall ch m b ofs v, nonptr_chunk ch = true ->
    Mem.load ch m b ofs = Some v -> forall b' o', v <> Vptr b' o'.
Proof.
  intros ch m b ofs v Hc Hl b' o' E. subst v.
  pose proof (Mem.load_cast _ _ _ _ _ Hl) as Hcast.
  pose proof (Mem.load_type _ _ _ _ _ Hl) as Hty.
  destruct ch; cbn in Hc; try discriminate Hc; cbn in Hcast, Hty; try discriminate Hcast;
    try contradiction; cbv in Hty; try discriminate Hty; try contradiction.
Qed.

Lemma ptrofs_add_repr : forall a b, Ptrofs.add (Ptrofs.repr a) (Ptrofs.repr b) = Ptrofs.repr (a + b).
Proof.
  intros a b. unfold Ptrofs.add. apply Ptrofs.eqm_samerepr.
  apply Ptrofs.eqm_add; apply Ptrofs.eqm_sym; apply Ptrofs.eqm_unsigned_repr.
Qed.

Lemma ptrofs_mul_repr : forall a b, Ptrofs.mul (Ptrofs.repr a) (Ptrofs.repr b) = Ptrofs.repr (a * b).
Proof.
  intros a b. unfold Ptrofs.mul. apply Ptrofs.eqm_samerepr.
  apply Ptrofs.eqm_mult; apply Ptrofs.eqm_sym; apply Ptrofs.eqm_unsigned_repr.
Qed.

Lemma add_oc : forall oc a b,
    Ptrofs.add (Ptrofs.add oc (Ptrofs.repr a)) (Ptrofs.repr b) = Ptrofs.add oc (Ptrofs.repr (a + b)).
Proof. intros oc a b. rewrite Ptrofs.add_assoc, ptrofs_add_repr. reflexivity. Qed.

Lemma ptrofs_of_int_zk : forall si k, ptrofs_of_int si k = Ptrofs.repr (zk si k).
Proof. intros [|] k; reflexivity. Qed.

Lemma alloc_vars_fresh : forall ge e0 m vars e m1,
    alloc_variables ge e0 m vars e m1 ->
    forall x b ty, e ! x = Some (b, ty) ->
      e0 ! x = Some (b, ty) \/ (Ple (Mem.nextblock m) b /\ In x (map fst vars)).
Proof.
  intros ge e0 m vars e m1 H. induction H as [e0 m0 | e0 m0 id ty0 vars0 m1 b1 m2 e2 Hal Hrest IH];
    intros x b ty Hx; [ left; exact Hx | ].
  destruct (IH x b ty Hx) as [Hs | (Hp & Hin)].
  - destruct (peq x id) as [-> | Hne].
    + rewrite PTree.gss in Hs. injection Hs as <- <-. right.
      split; [ rewrite (Mem.alloc_result _ _ _ _ _ Hal); apply Ple_refl | left; reflexivity ].
    + rewrite PTree.gso in Hs by exact Hne. left. exact Hs.
  - right. split; [ | right; exact Hin ].
    rewrite (Mem.nextblock_alloc _ _ _ _ _ Hal) in Hp.
    exact (Ple_trans _ _ _ (Ple_succ _) Hp).
Qed.

Lemma mem_i_in : forall x l, In x l -> mem_i x l = true.
Proof.
  intros x l H. apply existsb_exists. exists x. split; [ exact H | apply Pos.eqb_refl ].
Qed.

(* ---------------------------------------------------------------------- *)
(* 3. The walk.                                                             *)
(* ---------------------------------------------------------------------- *)

Section SW.
  Variable ge : genv.
  Variables pool gB : block.
  Variable oc : ptrofs.
  Variable SZ : Z.
  Hypothesis Hpool : Genv.find_symbol ge POOL = Some pool.
  Hypothesis HgB : Genv.find_symbol ge GCO = Some gB.
  Hypothesis HSZ : 0 <= SZ.
  Hypothesis Hoc : Ptrofs.unsigned oc + SZ <= Ptrofs.max_unsigned.
  Variable tab : stab.

  Lemma pool_ne_gB : pool <> gB.
  Proof.
    apply (Genv.global_addresses_distinct ge (id1 := POOL) (id2 := GCO)); [ | exact Hpool | exact HgB ].
    vm_compute. discriminate.
  Qed.

  Lemma glob_np : forall x b, forbidden x = false -> Genv.find_symbol ge x = Some b ->
      b <> pool /\ b <> gB.
  Proof.
    intros x b Hf Hs. unfold forbidden in Hf. apply orb_false_iff in Hf as [H1 H2].
    apply Pos.eqb_neq in H1. apply Pos.eqb_neq in H2.
    split; [ exact (Genv.global_addresses_distinct ge H1 Hs Hpool)
           | exact (Genv.global_addresses_distinct ge H2 Hs HgB) ].
  Qed.

  Definition NPv (v : val) : Prop := forall b o, v = Vptr b o -> b <> pool /\ b <> gB.
  Definition SVv (v : val) : Prop := forall b o, v = Vptr b o -> b = pool /\ o = oc.
  Definition TI (ss sn : list ident) (le : temp_env) : Prop :=
    forall t v, le ! t = Some v -> (mem_i t ss = true -> SVv v) /\ (mem_i t sn = true -> NPv v).
  Definition EI (lv : list ident) (e : env) : Prop :=
    forall x b ty, e ! x = Some (b, ty) -> b <> pool /\ b <> gB /\ mem_i x lv = true.
  Definition SI (m : mem) : Prop := Mem.load Mint32 m gB 0 = Some (Vptr pool oc).
  Definition GV (m : mem) : Prop := Plt pool (Mem.nextblock m) /\ Plt gB (Mem.nextblock m).
  Definition own (ofs : Z) : Prop := Ptrofs.unsigned oc <= ofs < Ptrofs.unsigned oc + SZ.
  Definition SFP (b : block) (ofs : Z) : Prop := (b = pool /\ ~ own ofs) \/ b = gB.
  Definition SFR (m m' : mem) : Prop := Mem.unchanged_on SFP m m'.
  Definition cext (ce : composite_env) : Prop :=
    forall id co, ce ! id = Some co -> (genv_cenv ge) ! id = Some co.

  Lemma SFR_refl : forall m, SFR m m.
  Proof. intros m. apply Mem.unchanged_on_refl. Qed.
  Lemma SFR_trans : forall m1 m2 m3, SFR m1 m2 -> SFR m2 m3 -> SFR m1 m3.
  Proof. intros m1 m2 m3 H1 H2. exact (Mem.unchanged_on_trans _ _ _ _ H1 H2). Qed.

  Lemma GV_SFR : forall m m', GV m -> SFR m m' -> GV m'.
  Proof.
    intros m m' (H1 & H2) HU. pose proof (Mem.unchanged_on_nextblock _ _ _ HU) as Hn.
    split; eapply Plt_Ple_trans; eassumption.
  Qed.

  Lemma SI_SFR : forall m m', SI m -> GV m -> SFR m m' -> SI m'.
  Proof.
    intros m m' Hs (_ & Hg) HU. unfold SI.
    rewrite (Mem.load_unchanged_on_1 _ _ _ Mint32 gB 0 HU Hg (fun i _ => or_intror eq_refl)).
    exact Hs.
  Qed.

  Lemma own_off : forall d, 0 <= d <= SZ ->
      Ptrofs.unsigned (Ptrofs.add oc (Ptrofs.repr d)) = Ptrofs.unsigned oc + d.
  Proof.
    intros d Hd. rewrite Ptrofs.add_unsigned.
    pose proof (Ptrofs.unsigned_range_2 oc) as Hr.
    rewrite (Ptrofs.unsigned_repr d) by lia.
    apply Ptrofs.unsigned_repr. lia.
  Qed.

  (* ---- expressions ---- *)
  Section EXPR.
    Variable ce : composite_env.
    Hypothesis Hce : cext ce.
    Variables ss sn : list ident.
    Variable e : env.
    Variable le : temp_env.
    Variable m : mem.
    Hypothesis HTI : TI ss sn le.
    Variable lv : list ident.
    Hypothesis HEI : EI lv e.

    Definition lshape (a : expr) : bool :=
      match a with Evar _ _ | Ederef _ _ | Efield _ _ _ => true | _ => false end.

    Lemma fld_off_sound : forall p f d0 x id co att delta bf,
        fld_off ce p f (Some d0) = Some x ->
        (typeof p = Tstruct id att /\ (genv_cenv ge) ! id = Some co
           /\ field_offset ge f (co_members co) = OK (delta, bf))
        \/ (typeof p = Tunion id att /\ (genv_cenv ge) ! id = Some co
           /\ union_field_offset ge f (co_members co) = OK (delta, bf)) ->
        x = d0 + delta /\ bf = Full.
    Proof.
      intros p f d0 x id co att delta bf Hf Hcase. unfold fld_off in Hf.
      destruct Hcase as [(Ht & Hc & Hfo) | (Ht & Hc & Hfo)]; rewrite Ht in Hf.
      - destruct (ce ! id) as [co'|] eqn:Ec; [ | discriminate Hf ].
        rewrite (Hce _ _ Ec) in Hc. injection Hc as <-.
        destruct (complete_members ce (co_members co')) eqn:Hcm; [ | discriminate Hf ].
        rewrite (field_offset_stable ce ge Hce f _ Hcm) in Hfo.
        destruct (field_offset ce f (co_members co')) as [[x0 [|]]|]; try discriminate Hf.
        injection Hf as <-. injection Hfo as <- <-. auto.
      - destruct (ce ! id) as [co'|] eqn:Ec; [ | discriminate Hf ].
        rewrite (Hce _ _ Ec) in Hc. injection Hc as <-.
        destruct (complete_members ce (co_members co')) eqn:Hcm; [ | discriminate Hf ].
        rewrite (union_field_offset_stable ce ge Hce f _ Hcm) in Hfo.
        destruct (union_field_offset ce f (co_members co')) as [[x0 [|]]|]; try discriminate Hf.
        injection Hf as <-. injection Hfo as <- <-. auto.
    Qed.

    Lemma fld_off_none : forall p f, fld_off ce p f None = None.
    Proof. reflexivity. Qed.

    Lemma s_eval :
      (forall a v, eval_expr ge e le m a v ->
         (npv sn a = true -> NPv v)
         /\ (forall d, pad ce ss a = Some d -> forall b o, v = Vptr b o ->
               b = pool /\ o = Ptrofs.add oc (Ptrofs.repr d))
         /\ (forall k, cint a = Some k -> v = Vint k))
      /\ (forall a b o bf, eval_lvalue ge e le m a b o bf ->
         (npl sn a = true -> b <> pool /\ b <> gB)
         /\ (forall d, lad ce ss a = Some d -> b = pool /\ o = Ptrofs.add oc (Ptrofs.repr d) /\ bf = Full)
         /\ lshape a = true).
    Proof.
      apply eval_expr_lvalue_ind.
      - (* const int *)
        intros i ty. split; [ intros _ b o E; discriminate E | split ];
          [ intros d Hd; discriminate Hd | intros k E; injection E as ->; reflexivity ].
      - intros f ty. split; [ intros _ b o E; discriminate E | split ];
          [ intros d Hd; discriminate Hd | intros k E; discriminate E ].
      - intros f ty. split; [ intros _ b o E; discriminate E | split ];
          [ intros d Hd; discriminate Hd | intros k E; discriminate E ].
      - intros i ty. split; [ intros _ b o E; discriminate E | split ];
          [ intros d Hd; discriminate Hd | intros k E; discriminate E ].
      - (* temp *)
        intros id ty v Hg. destruct (HTI id v Hg) as (Hs & Hn).
        split; [ intros H; exact (Hn H) | split; [ | intros k E; discriminate E ] ].
        intros d Hd b o E. cbn in Hd. destruct (mem_i id ss) eqn:Em; [ | discriminate Hd ].
        injection Hd as <-. destruct (Hs eq_refl b o E) as (-> & ->).
        rewrite Ptrofs.add_zero. auto.
      - (* addrof *)
        intros a ty loc ofs _ (Hn & Hl & Hsh).
        split; [ | split; [ | intros k E; discriminate E ] ].
        + intros H b o E. injection E as <- <-. apply Hn.
          destruct a; try discriminate Hsh; exact H.
        + intros d Hd b o E. injection E as <- <-.
          destruct (Hl d) as (-> & -> & _); [ | auto ].
          destruct a; try discriminate Hsh; cbn in Hd; try discriminate Hd; exact Hd.
      - (* unop *)
        intros op a ty v1 v _ _ Hs.
        split; [ intros _ b o E; subst v; exact (False_ind _ (unop_not_ptr _ _ _ _ _ _ Hs)) | split ];
          [ intros d Hd; discriminate Hd | intros k E; discriminate E ].
      - (* binop *)
        intros op a1 a2 ty v1 v2 v _ (Hn1 & Hp1 & Hc1) _ (Hn2 & _ & Hc2) Hs.
        split; [ | split ].
        + intros H b o E. subst v. cbn [npv] in H. apply orb_true_iff in H as [H | H].
          * destruct op; try discriminate H. apply andb_prop in H as [H1 H2].
            cbn in Hs. destruct (SaveDoSaveBody.sem_add_vptr_src _ _ _ _ _ _ _ _ Hs)
              as [(o1 & E1) | (o2 & E2)]; [ exact (Hn1 H1 b o1 E1) | exact (Hn2 H2 b o2 E2) ].
          * exact (False_ind _ (CameraModeBody.never_ptr_binop_sound _ _ _ _ _ _ _ _ _ H Hs)).
        + intros d Hd b o E. subst v.
          destruct op; try discriminate Hd.
          cbn [pad] in Hd. destruct (cint a2) as [k|] eqn:Eci; [ | discriminate Hd ].
          rewrite (Hc2 k eq_refl) in Hs.
          destruct (classify_add (typeof a1) (typeof a2)) eqn:Ecl; try discriminate Hd.
          destruct (complete_type ce ty0) eqn:Ect; [ | discriminate Hd ].
          destruct (pad ce ss a1) as [d0|] eqn:Ep; [ | discriminate Hd ]. injection Hd as <-.
          cbn in Hs. unfold sem_add in Hs. rewrite Ecl in Hs. unfold sem_add_ptr_int in Hs.
          destruct v1; try discriminate Hs; try (destruct Archi.ptr64; discriminate Hs).
          injection Hs as Eb Eo. subst b o.
          destruct (Hp1 d0 eq_refl _ _ eq_refl) as (-> & ->). split; [ reflexivity | ].
          rewrite (sizeof_stable ce ge Hce ty0 Ect), ptrofs_of_int_zk, ptrofs_mul_repr.
          apply add_oc.
        + intros k Hk. cbn [cint] in Hk. destruct op; try discriminate Hk.
          destruct (cint a1) as [k1|] eqn:E1; [ | discriminate Hk ].
          destruct (cint a2) as [k2|] eqn:E2; [ | discriminate Hk ].
          rewrite (Hc1 k1 eq_refl), (Hc2 k2 eq_refl) in Hs.
          destruct (typeof a1) as [ | [ | | | ] [ | ] ? | | | | | | | ]; try discriminate Hk;
          destruct (typeof a2) as [ | [ | | | ] [ | ] ? | | | | | | | ]; try discriminate Hk.
          injection Hk as <-. cbn in Hs. injection Hs as <-. reflexivity.
      - (* cast *)
        intros a ty v1 v _ (Hn & Hp & _) Hc.
        split; [ | split; [ | intros k E; discriminate E ] ].
        + intros H b o E. subst v. rewrite (CensusV2.sem_cast_vptr_inv _ _ _ _ _ _ Hc) in Hn.
          exact (Hn H b o eq_refl).
        + intros d Hd b o E. subst v. exact (Hp d Hd b o (CensusV2.sem_cast_vptr_inv _ _ _ _ _ _ Hc)).
      - (* sizeof *)
        intros ty1 ty. split; [ intros _ b o E; discriminate E | split ];
          [ intros d Hd; discriminate Hd | intros k E; discriminate E ].
      - intros ty1 ty. split; [ intros _ b o E; discriminate E | split ];
          [ intros d Hd; discriminate Hd | intros k E; discriminate E ].
      - (* lvalue read *)
        intros a loc ofs bf v _ (Hn & Hl & Hsh) Hd.
        split; [ | split; [ | intros k E; destruct a; try discriminate Hsh; discriminate E ] ].
        + intros H b o E. subst v.
          inv Hd.
          * (* by value *)
            assert (Hc : nonptr_chunk chunk = true).
            { destruct a; try discriminate Hsh; cbn [npv typeof] in H |- *;
                match goal with Ha : access_mode _ = By_value _ |- _ => cbn [typeof] in Ha; rewrite Ha in H end;
                exact H. }
            exact (False_ind _ (load_nonptr _ _ _ _ _ Hc H1 b o eq_refl)).
          * (* by reference *)
            apply Hn. destruct a; try discriminate Hsh; cbn [npv typeof] in H |- *;
              match goal with Ha : access_mode _ = By_reference |- _ => cbn [typeof] in Ha; rewrite Ha in H end;
              exact H.
          * apply Hn. destruct a; try discriminate Hsh; cbn [npv typeof] in H |- *;
              match goal with Ha : access_mode _ = By_copy |- _ => cbn [typeof] in Ha; rewrite Ha in H end;
              exact H.
          * match goal with Hb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hb end.
        + intros d Hp b o E. subst v.
          assert (Hlad : lad ce ss a = Some d /\ access_mode (typeof a) <> By_value Mint32 /\
                         (forall ch, access_mode (typeof a) <> By_value ch)).
          { destruct a; try discriminate Hsh; cbn [pad] in Hp; cbn [lad typeof];
              (destruct (access_mode t) eqn:Ea; try discriminate Hp);
              (split; [ exact Hp | split; [ intros X; discriminate X | intros ch X; discriminate X ] ]). }
          destruct Hlad as (Hlad & _ & Hnv).
          destruct (Hl d Hlad) as (-> & -> & ->).
          inv Hd; [ match goal with Ha : access_mode _ = By_value _ |- _ => exact (False_ind _ (Hnv _ Ha)) end | auto | auto ].
      - (* local *)
        intros id l ty He. destruct (HEI _ _ _ He) as (H1 & H2 & _).
        split; [ intros _; auto | split; [ intros d Hd; discriminate Hd | reflexivity ] ].
      - (* global *)
        intros id l ty He Hs.
        split; [ intros H; exact (glob_np id l (proj1 (negb_true_iff _) H) Hs) |
                 split; [ intros d Hd; discriminate Hd | reflexivity ] ].
      - (* deref *)
        intros a ty l ofs _ (Hn & Hp & _).
        split; [ intros H; exact (Hn H l ofs eq_refl) | split; [ | reflexivity ] ].
        intros d Hd. destruct (Hp d Hd l ofs eq_refl) as (-> & ->). auto.
      - (* field struct *)
        intros a i ty l ofs id co att delta bf _ (Hn & Hp & _) Ht Hc Hfo.
        split; [ intros H; exact (Hn H l ofs eq_refl) | split; [ | reflexivity ] ].
        intros d Hd. cbn [lad] in Hd.
        destruct (pad ce ss a) as [d0|] eqn:Ep; [ | discriminate Hd ].
        destruct (fld_off_sound a i d0 d id co att delta bf Hd (or_introl (conj Ht (conj Hc Hfo))))
          as (-> & ->).
        destruct (Hp d0 eq_refl l ofs eq_refl) as (-> & ->).
        split; [ reflexivity | split; [ apply add_oc | reflexivity ] ].
      - (* field union *)
        intros a i ty l ofs id co att delta bf _ (Hn & Hp & _) Ht Hc Hfo.
        split; [ intros H; exact (Hn H l ofs eq_refl) | split; [ | reflexivity ] ].
        intros d Hd. cbn [lad] in Hd.
        destruct (pad ce ss a) as [d0|] eqn:Ep; [ | discriminate Hd ].
        destruct (fld_off_sound a i d0 d id co att delta bf Hd (or_intror (conj Ht (conj Hc Hfo))))
          as (-> & ->).
        destruct (Hp d0 eq_refl l ofs eq_refl) as (-> & ->).
        split; [ reflexivity | split; [ apply add_oc | reflexivity ] ].
    Qed.

    Lemma selfv_sound : forall a v, eval_expr ge e le m a v -> selfv ss a = true -> SVv v.
    Proof.
      induction a; intros v Hev Hs; cbn in Hs; try discriminate Hs.
      - inv Hev; [ | match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end ].
        match goal with Hg : le ! _ = Some _ |- _ => exact (proj1 (HTI _ _ Hg) Hs) end.
      - inv Hev; [ | match goal with Hl : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inv Hl end ].
        intros b o E. subst v.
        match goal with Hc : sem_cast _ _ _ _ = Some _, He : eval_expr _ _ _ _ a _ |- _ =>
          rewrite (CensusV2.sem_cast_vptr_inv _ _ _ _ _ _ Hc) in He;
          exact (IHa _ He Hs b o eq_refl) end.
    Qed.

    Lemma gco_load : forall ty v, mem_i GCO lv = false -> is_m32 ty = true -> SI m ->
        eval_expr ge e le m (Evar GCO ty) v -> v = Vptr pool oc.
    Proof.
      intros ty v Hlv Hm Hsi Hev.
      assert (Hn : e ! GCO = None).
      { destruct (e ! GCO) as [[b t]|] eqn:E; [ | reflexivity ].
        destruct (HEI _ _ _ E) as (_ & _ & H). congruence. }
      inv Hev. match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end; [ congruence | ].
      match goal with Hs : Genv.find_symbol _ _ = Some _ |- _ => rewrite HgB in Hs; injection Hs as <- end.
      unfold is_m32 in Hm.
      match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end; cbn [typeof] in *.
      - match goal with Ha : access_mode ty = By_value _ |- _ => rewrite Ha in Hm end.
        destruct chunk; try discriminate Hm. unfold SI in Hsi.
        match goal with Hl : Mem.loadv _ _ _ = Some _ |- _ =>
          cbn in Hl; rewrite Ptrofs.unsigned_zero in Hl; congruence end.
      - match goal with Ha : access_mode ty = By_reference |- _ => rewrite Ha in Hm; discriminate Hm end.
      - match goal with Ha : access_mode ty = By_copy |- _ => rewrite Ha in Hm; discriminate Hm end.
    Qed.

    Lemma args_sound : forall al tys vargs ks,
        eval_exprlist ge e le m al tys vargs -> args_ok ss sn ks al = true ->
        Forall2 (fun k v => match k with KSelf => SVv v | KNp => NPv v | KAny => True end) ks vargs.
    Proof.
      intros al tys vargs ks H. revert ks. induction H as [| a bl ty tyl v1 v2 vl Hev Hc Hl IH];
        intros ks Hok; destruct ks as [| k ks]; cbn in Hok; try discriminate Hok; [ constructor | ].
      apply andb_prop in Hok as [Hk Hr]. constructor; [ | exact (IH ks Hr) ].
      destruct k; cbn in Hk.
      - intros b o E. subst v2. rewrite (CensusV2.sem_cast_vptr_inv _ _ _ _ _ _ Hc) in Hev.
        exact (selfv_sound _ _ Hev Hk b o eq_refl).
      - intros b o E. subst v2. rewrite (CensusV2.sem_cast_vptr_inv _ _ _ _ _ _ Hc) in Hev.
        exact (proj1 (proj1 s_eval _ _ Hev) Hk b o eq_refl).
      - exact I.
    Qed.
  End EXPR.

  Definition karg (k : skind) (v : val) : Prop :=
    match k with KSelf => SVv v | KNp => NPv v | KAny => True end.

  Variable sLeaf : Clight.fundef -> list skind -> Prop.

  Definition sGood (fd : Clight.fundef) (ks : list skind) : Prop :=
    (exists f ce, fd = Internal f /\ cext ce /\ s_fun ce SZ tab ks f = true) \/ sLeaf fd ks.

  Hypothesis HLeaf : forall fd ks, sLeaf fd ks ->
      forall m vargs t m' vres, eval_funcall function_entry2 ge m fd vargs t m' vres ->
      Forall2 karg ks vargs -> SI m -> GV m -> SFR m m'.
  Hypothesis HTab : forall f ks, st_find f tab = Some ks ->
      forall b fd, Genv.find_symbol ge f = Some b ->
      Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd -> sGood fd ks.

  Definition sPstmt (e : env) (le : temp_env) (m : mem) (s : statement) (t : trace)
      (le' : temp_env) (m' : mem) (out : outcome) : Prop :=
    exec_stmt function_entry2 ge e le m s t le' m' out /\
    forall ce ss sn lv, cext ce -> s_chk ce SZ tab ss sn lv s = true ->
      TI ss sn le -> EI lv e -> SI m -> GV m -> SFR m m' /\ TI ss sn le'.

  Definition sPfun (m : mem) (fd : Clight.fundef) (vargs : list val) (t : trace)
      (m' : mem) (vres : val) : Prop :=
    eval_funcall function_entry2 ge m fd vargs t m' vres /\
    forall ks, sGood fd ks -> Forall2 karg ks vargs -> SI m -> GV m -> SFR m m'.

  Lemma TI_set_out : forall ss sn le t v, mem_i t ss = false -> mem_i t sn = false ->
      TI ss sn le -> TI ss sn (PTree.set t v le).
  Proof.
    intros ss sn le t v H1 H2 HT t' v' Hg. destruct (peq t' t) as [-> | Hne].
    - split; intros H; congruence.
    - rewrite PTree.gso in Hg by exact Hne. exact (HT t' v' Hg).
  Qed.

  Lemma s_store : forall ce ss sn lv e le m l r t le' m' out,
      cext ce -> TI ss sn le -> EI lv e ->
      st_store ce ss sn SZ l r = true ->
      exec_stmt function_entry2 ge e le m (Sassign l r) t le' m' out -> SFR m m'.
  Proof.
    intros ce ss sn lv e le m l r t le' m' out Hce HT HE Hok Hx.
    unfold st_store in Hok. apply andb_prop in Hok as [Hbv Hok].
    inv Hx.
    match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => rename Hl into Hlv end.
    pose proof (s_eval ce Hce ss sn e _ m HT lv HE) as Hse.
    destruct Hse as (_ & Hse).
    destruct (Hse _ _ _ _ Hlv) as (Hn & Hp & _).
    match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => rename Ha into Hal end.
    apply orb_true_iff in Hok as [Hnp | Hself].
    - destruct (Hn Hnp) as (Hq1 & Hq2).
      apply (ObjWalk.assign_loc_unch _ _ _ _ _ _ _ _ _ Hal).
      intros i [(E & _) | E]; congruence.
    - unfold self_store in Hself.
      destruct (access_mode (typeof l)) eqn:Ea; try discriminate Hself.
      destruct (lad ce ss l) as [d|] eqn:Ed; [ | discriminate Hself ].
      apply andb_prop in Hself as [H0 Hsz]. apply Z.leb_le in H0. apply Z.leb_le in Hsz.
      destruct (Hp d eq_refl) as (-> & -> & ->).
      pose proof (size_chunk_pos m0) as Hpos.
      inv Hal.
      + match goal with Ha : access_mode _ = By_value _ |- _ => rewrite Ea in Ha; injection Ha as <- end.
        match goal with Hs : Mem.storev _ _ _ _ = Some _ |- _ => unfold Mem.storev in Hs end.
        eapply Mem.store_unchanged_on; [ eassumption | ].
        rewrite own_off by lia.
        intros i Hi [(_ & Hno) | E].
        * apply Hno. unfold own. lia.
        * exact (pool_ne_gB E).
      + match goal with Ha : access_mode _ = By_copy |- _ => rewrite Ea in Ha; discriminate Ha end.
  Qed.

  Lemma s_mutual :
    (forall e le m s t le' m' out,
        exec_stmt function_entry2 ge e le m s t le' m' out -> sPstmt e le m s t le' m' out) /\
    (forall m fd vargs t m' vres,
        eval_funcall function_entry2 ge m fd vargs t m' vres -> sPfun m fd vargs t m' vres).
  Proof.
    apply (exec_stmt_funcall_ind function_entry2 ge sPstmt sPfun); unfold sPstmt, sPfun.
    - (* Sskip *)
      intros e le m. split; [ constructor | ].
      intros ce ss sn lv _ _ HT _ _ _. exact (conj (SFR_refl m) HT).
    - (* Sassign *)
      intros e le m a1 a2 loc ofs bf v2 v m' Hl Hr Hc Ha.
      assert (Hx : exec_stmt function_entry2 ge e le m (Sassign a1 a2) E0 le m' Out_normal)
        by (eapply exec_Sassign; eassumption).
      split; [ exact Hx | ].
      intros ce ss sn lv Hce Hchk HT HE _ _. unfold s_chk in Hchk. cbn [SpawnBodies.sw_chk] in Hchk.
      exact (conj (s_store ce ss sn lv e le m a1 a2 _ _ _ _ Hce HT HE Hchk Hx) HT).
    - (* Sset *)
      intros e le m id a v Hev.
      split; [ exact (exec_Sset _ _ _ _ _ _ _ _ Hev) | ].
      intros ce ss sn lv Hce Hchk HT HE Hsi _. unfold s_chk in Hchk. cbn [SpawnBodies.sw_chk] in Hchk.
      split; [ apply SFR_refl | ].
      unfold st_set in Hchk. apply andb_prop in Hchk as [Hs Hn].
      intros t v' Hg. destruct (peq t id) as [-> | Hne].
      + rewrite PTree.gss in Hg. injection Hg as <-. split.
        * intros Hm. rewrite Hm in Hs. cbn in Hs.
          destruct a; cbn [selfdef] in Hs;
            try (eapply selfv_sound; [ exact HT | exact Hev | exact Hs ]).
          apply andb_prop in Hs as [Hs Hty]. apply andb_prop in Hs as [Hx Hlv].
          apply Pos.eqb_eq in Hx. subst i. apply negb_true_iff in Hlv.
          assert (Ev : v = Vptr pool oc) by (eapply gco_load; eassumption). rewrite Ev.
          intros b o E. injection E as <- <-. auto.
        * intros Hm. rewrite Hm in Hn. cbn in Hn.
          exact (proj1 (proj1 (s_eval ce Hce ss sn e le m HT lv HE) _ _ Hev) Hn).
      + rewrite PTree.gso in Hg by exact Hne. exact (HT t v' Hg).
    - (* Scall *)
      intros e le m optid a al targs tres cc vf vargs fd t m' vres Hcf Hev Hel Hff Hty _ IHf.
      split; [ exact (exec_Scall _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ Hcf Hev Hel Hff Hty (proj1 IHf)) | ].
      intros ce ss sn lv Hce Hchk HT HE Hsi Hgv. unfold s_chk in Hchk. cbn [SpawnBodies.sw_chk] in Hchk.
      unfold st_call in Hchk. apply andb_prop in Hchk as [Hc Ho].
      destruct a; try discriminate Hc. destruct t0; try discriminate Hc.
      apply andb_prop in Hc as [Hlv Hk]. apply negb_true_iff in Hlv.
      destruct (st_find i tab) as [ks|] eqn:Ef; [ | discriminate Hk ].
      assert (Hn : e ! i = None).
      { destruct (e ! i) as [[b0 tq]|] eqn:E; [ | reflexivity ].
        destruct (HE _ _ _ E) as (_ & _ & H). congruence. }
      destruct (MathGeomGated.evar_fun_val _ _ _ _ _ _ _ _ _ Hev Hn) as (b & Hs & ->).
      pose proof (HTab i ks Ef b fd Hs Hff) as Hg.
      assert (Hva : Forall2 karg ks vargs) by (eapply args_sound; eassumption).
      pose proof (proj2 IHf ks Hg Hva Hsi Hgv) as HF.
      split; [ exact HF | ].
      destruct optid as [tid|]; cbn; [ | exact HT ].
      apply andb_prop in Ho as [H1 H2]. apply negb_true_iff in H1. apply negb_true_iff in H2.
      exact (TI_set_out ss sn le tid vres H1 H2 HT).
    - (* Sbuiltin *)
      intros e le m optid ef al targs vargs t m' vres Hel Hext.
      split; [ exact (exec_Sbuiltin _ _ _ _ _ _ _ _ _ _ _ _ _ Hel Hext) | ].
      intros ce ss sn lv _ Hchk. unfold s_chk in Hchk. cbn [SpawnBodies.sw_chk] in Hchk. discriminate Hchk.
    - (* Sseq_1 *)
      intros e le m s1 s2 t1 le1 m1 t2 le2 m2 out D1 (_ & IH1) D2 (_ & IH2).
      split; [ exact (exec_Sseq_1 _ _ _ _ _ _ _ _ _ _ _ _ _ _ D1 D2) | ].
      intros ce ss sn lv Hce Hchk HT HE Hsi Hgv. unfold s_chk in Hchk. cbn [SpawnBodies.sw_chk] in Hchk.
      apply andb_prop in Hchk as [H1 H2].
      destruct (IH1 ce ss sn lv Hce H1 HT HE Hsi Hgv) as (HF1 & HT1).
      destruct (IH2 ce ss sn lv Hce H2 HT1 HE (SI_SFR _ _ Hsi Hgv HF1) (GV_SFR _ _ Hgv HF1))
        as (HF2 & HT2).
      exact (conj (SFR_trans _ _ _ HF1 HF2) HT2).
    - (* Sseq_2 *)
      intros e le m s1 s2 t1 le1 m1 out D1 (_ & IH1) Hne.
      split; [ exact (exec_Sseq_2 _ _ _ _ _ _ _ _ _ _ _ D1 Hne) | ].
      intros ce ss sn lv Hce Hchk HT HE Hsi Hgv. unfold s_chk in Hchk. cbn [SpawnBodies.sw_chk] in Hchk.
      apply andb_prop in Hchk as [H1 _]. exact (IH1 ce ss sn lv Hce H1 HT HE Hsi Hgv).
    - (* Sifthenelse *)
      intros e le m a s1 s2 v1 b t le' m' out Hev Hbv D (_ & IH).
      split; [ exact (exec_Sifthenelse _ _ _ _ _ _ _ _ _ _ _ _ _ _ Hev Hbv D) | ].
      intros ce ss sn lv Hce Hchk HT HE Hsi Hgv. unfold s_chk in Hchk. cbn [SpawnBodies.sw_chk] in Hchk.
      apply andb_prop in Hchk as [H1 H2].
      apply (IH ce ss sn lv Hce); [ destruct b; assumption | exact HT | exact HE | exact Hsi | exact Hgv ].
    - (* Sreturn None *)
      intros e le m. split; [ constructor | ].
      intros ce ss sn lv _ _ HT _ _ _. exact (conj (SFR_refl m) HT).
    - (* Sreturn Some *)
      intros e le m a v Hev. split; [ exact (exec_Sreturn_some _ _ _ _ _ _ _ Hev) | ].
      intros ce ss sn lv _ _ HT _ _ _. exact (conj (SFR_refl m) HT).
    - (* Sbreak *)
      intros e le m. split; [ constructor | ].
      intros ce ss sn lv _ _ HT _ _ _. exact (conj (SFR_refl m) HT).
    - (* Scontinue *)
      intros e le m. split; [ constructor | ].
      intros ce ss sn lv _ _ HT _ _ _. exact (conj (SFR_refl m) HT).
    - (* Sloop_stop1 *)
      intros e le m s1 s2 t le' m' out' out D (_ & IH) Hbr.
      split; [ exact (exec_Sloop_stop1 _ _ _ _ _ _ _ _ _ _ _ _ D Hbr) | ].
      intros ce ss sn lv Hce Hchk HT HE Hsi Hgv. unfold s_chk in Hchk. cbn [SpawnBodies.sw_chk] in Hchk.
      apply andb_prop in Hchk as [H1 _]. exact (IH ce ss sn lv Hce H1 HT HE Hsi Hgv).
    - (* Sloop_stop2 *)
      intros e le m s1 s2 t1 le1 m1 out1 t2 le2 m2 out2 out D1 (_ & IH1) Hnc D2 (_ & IH2) Hbr.
      split; [ eapply exec_Sloop_stop2; [ exact D1 | exact Hnc | exact D2 | exact Hbr ] | ].
      intros ce ss sn lv Hce Hchk HT HE Hsi Hgv. unfold s_chk in Hchk. cbn [SpawnBodies.sw_chk] in Hchk.
      apply andb_prop in Hchk as [H1 H2].
      destruct (IH1 ce ss sn lv Hce H1 HT HE Hsi Hgv) as (HF1 & HT1).
      destruct (IH2 ce ss sn lv Hce H2 HT1 HE (SI_SFR _ _ Hsi Hgv HF1) (GV_SFR _ _ Hgv HF1))
        as (HF2 & HT2).
      exact (conj (SFR_trans _ _ _ HF1 HF2) HT2).
    - (* Sloop_loop *)
      intros e le m s1 s2 t1 le1 m1 out1 t2 le2 m2 t3 le3 m3 out D1 (_ & IH1) Hnc D2 (_ & IH2) D3 (_ & IH3).
      split; [ eapply exec_Sloop_loop; [ exact D1 | exact Hnc | exact D2 | exact D3 ] | ].
      intros ce ss sn lv Hce Hchk HT HE Hsi Hgv.
      pose proof Hchk as Hchk'. unfold s_chk in Hchk. cbn [SpawnBodies.sw_chk] in Hchk.
      apply andb_prop in Hchk as [H1 H2].
      destruct (IH1 ce ss sn lv Hce H1 HT HE Hsi Hgv) as (HF1 & HT1).
      pose proof (SI_SFR _ _ Hsi Hgv HF1) as Hsi1. pose proof (GV_SFR _ _ Hgv HF1) as Hgv1.
      destruct (IH2 ce ss sn lv Hce H2 HT1 HE Hsi1 Hgv1) as (HF2 & HT2).
      destruct (IH3 ce ss sn lv Hce Hchk' HT2 HE (SI_SFR _ _ Hsi1 Hgv1 HF2) (GV_SFR _ _ Hgv1 HF2))
        as (HF3 & HT3).
      exact (conj (SFR_trans _ _ _ (SFR_trans _ _ _ HF1 HF2) HF3) HT3).
    - (* Sswitch *)
      intros e le m a t v n sl0 le1 m1 out Hev Hsw D (_ & IH).
      split; [ eapply exec_Sswitch; [ exact Hev | exact Hsw | exact D ] | ].
      intros ce ss sn lv Hce Hchk HT HE Hsi Hgv. unfold s_chk in Hchk. cbn [SpawnBodies.sw_chk] in Hchk.
      exact (IH ce ss sn lv Hce (SpawnBodies.sw_chk_select _ _ _ _ _ _ Hchk) HT HE Hsi Hgv).
    - (* funcall internal *)
      intros m f vargs t e le1 le2 m1 m2 out vres m3 Hentry _ IHb Hor Hfree.
      assert (D : eval_funcall function_entry2 ge m (Internal f) vargs t m3 vres)
        by (eapply eval_funcall_internal; [ exact Hentry | exact (proj1 IHb) | exact Hor | exact Hfree ]).
      split; [ exact D | ].
      intros ks Hg Hva Hsi Hgv.
      destruct Hg as [(f' & ce & Ef & Hce & Hchk) | Hlf]; [ | exact (HLeaf _ _ Hlf _ _ _ _ _ D Hva Hsi Hgv) ].
      injection Ef as <-.
      unfold s_fun in Hchk. destruct (sets_of ks f) as [ss sn].
      apply andb_prop in Hchk as [Hb Hpar].
      inv Hentry.
      match goal with H : alloc_variables _ _ _ _ _ _ |- _ => rename H into Hav end.
      match goal with H : bind_parameter_temps _ _ _ = Some _ |- _ => rename H into Hbp end.
      assert (HF1 : SFR m m1) by exact (ObjWalk.av_unch _ _ _ _ _ _ _ Hav).
      assert (HE : EI (map fst (fn_vars f)) e).
      { intros x b ty Hx.
        destruct (alloc_vars_fresh _ _ _ _ _ _ Hav x b ty Hx) as [Hq0 | (Hp & Hin)];
          [ rewrite PTree.gempty in Hq0; discriminate Hq0 | ].
        destruct Hgv as (G1 & G2).
        split; [ intros E; subst b; exact (Plt_strict _ (Plt_Ple_trans _ _ _ G1 Hp)) | ].
        split; [ intros E; subst b; exact (Plt_strict _ (Plt_Ple_trans _ _ _ G2 Hp)) | ].
        exact (mem_i_in _ _ Hin). }
      assert (HT : TI ss sn le1).
      { intros t0 v Hgt.
        destruct (ObjHelpersBodies.bind_get _ _ _ _ _ _ Hbp Hgt) as [Hu | (i & Hi & Hvi)].
        - apply MtxfBody.create_undef_temps_get in Hu. subst v.
          split; intros _ b o E; discriminate E.
        - destruct (PrintBodies.forall2_nth_l _ _ _ _ _ Hva Hvi) as (k & Hk).
          pose proof (PrintBodies.forall2_nth _ _ _ _ _ _ Hva Hk Hvi) as Hkv.
          clear -Hpar Hi Hk Hkv.
          revert i ks Hpar Hi Hk.
          induction (map fst (fn_params f)) as [| p ps IH]; intros i ks Hpar Hi Hk;
            [ destruct i; discriminate Hi | ].
          destruct ks as [| k0 ks]; cbn in Hpar; [ discriminate Hpar | ].
          apply andb_prop in Hpar as [Hpk Hr]. apply andb_prop in Hpk as [Hp1 Hp2].
          destruct i as [| i]; cbn in Hi, Hk.
          + injection Hi as <-. injection Hk as <-.
            split; intros Hm.
            * rewrite Hm in Hp1. destruct k0; try discriminate Hp1. exact Hkv.
            * rewrite Hm in Hp2. destruct k0; try discriminate Hp2. exact Hkv.
          + exact (IH i ks Hr Hi Hk). }
      destruct (proj2 IHb ce ss sn (map fst (fn_vars f)) Hce Hb HT HE
                  (SI_SFR _ _ Hsi Hgv HF1) (GV_SFR _ _ Hgv HF1)) as (HF2 & _).
      apply SFR_trans with m2; [ exact (SFR_trans _ _ _ HF1 HF2) | ].
      apply (ObjWalk.fl_unch _ _ _ _ Hfree). intros b lo hi Hin i _ Hp.
      destruct (ObjWalk.boe_in _ _ _ _ _ Hin) as (x & ty & Hx).
      destruct (HE _ _ _ Hx) as (Hq1 & Hq2 & _).
      destruct Hp as [(E & _) | E]; congruence.
    - (* funcall external *)
      intros m ef targs tres cc vargs t vres m' Hext.
      assert (D : eval_funcall function_entry2 ge m (External ef targs tres cc) vargs t m' vres)
        by (eapply eval_funcall_external; exact Hext).
      split; [ exact D | ].
      intros ks Hg Hva Hsi Hgv.
      destruct Hg as [(f' & ce & Ef & _) | Hlf]; [ discriminate Ef | ].
      exact (HLeaf _ _ Hlf _ _ _ _ _ D Hva Hsi Hgv).
  Qed.

  (* THE RESULT: a self-clean body changes the pool only inside the running
     slot and leaves gCurrentObject's cell alone *)
  Theorem s_fun_frame : forall ks fd m vargs t m' vres,
      sGood fd ks -> eval_funcall function_entry2 ge m fd vargs t m' vres ->
      Forall2 karg ks vargs -> SI m -> GV m -> SFR m m'.
  Proof.
    intros ks fd m vargs t m' vres Hg Hev Hva Hsi Hgv.
    exact (proj2 (proj2 s_mutual _ _ _ _ _ _ Hev) ks Hg Hva Hsi Hgv).
  Qed.
End SW.

(* ---------------------------------------------------------------------- *)
(* 4. Table lookup, and the kind GUESS for a table's fixpoint.            *)
(*    The guess is untrusted: whatever kinds it proposes, s_fun re-checks  *)
(*    the body against them, and s_fun_frame only uses checked entries.   *)
(* ---------------------------------------------------------------------- *)

Lemma st_find_split : forall {A} (l : list (ident * A * list skind)) (lf : stab) f ks,
    st_find f (map (fun c => let '(g, _, ks0) := c in (g, ks0)) l ++ lf) = Some ks ->
    (exists i, In (f, i, ks) l) \/ st_find f lf = Some ks.
Proof.
  intros A l lf f ks. induction l as [| [[g i] ks0] l IH]; intros H; [ right; exact H | ].
  unfold st_find in H. cbn [map app find fst] in H.
  destruct (Pos.eqb g f) eqn:E.
  - apply Pos.eqb_eq in E. subst g. injection H as <-. left. exists i. left. reflexivity.
  - destruct (IH H) as [(i' & Hi) | Hl]; [ left; exists i'; right; exact Hi | right; exact Hl ].
Qed.

Section GUESS.
  Variable OBJ : ident.

  Definition kind_of_ty (ty : type) : skind :=
    match ty with
    | Tpointer (Tstruct id _) _ => if Pos.eqb id OBJ then KSelf else KNp
    | Tpointer _ _ => KNp
    | _ => KAny
    end.

  Definition typed_kinds (f : Clight.function) : list skind :=
    map (fun p => kind_of_ty (snd p)) (fn_params f).

  Fixpoint etemps (a : expr) : list ident :=
    match a with
    | Etempvar t _ => [t]
    | Eaddrof a1 _ | Eunop _ a1 _ | Ecast a1 _ | Ederef a1 _ | Efield a1 _ _ => etemps a1
    | Ebinop _ a1 a2 _ => etemps a1 ++ etemps a2
    | _ => []
    end.

  (* temps a store address or a non-KAny argument is built from *)
  Fixpoint need0 (tab : stab) (s : statement) : list ident :=
    match s with
    | Sassign l _ => etemps l
    | Scall _ (Evar f _) al =>
        match st_find f tab with
        | Some ks => flat_map (fun p => match fst p with KAny => [] | _ => etemps (snd p) end)
                       (combine ks al)
        | None => []
        end
    | Ssequence s1 s2 | Sifthenelse _ s1 s2 | Sloop s1 s2 => need0 tab s1 ++ need0 tab s2
    | Sswitch _ sl => need0_ls tab sl
    | _ => []
    end
  with need0_ls (tab : stab) (sl : labeled_statements) : list ident :=
    match sl with LSnil => [] | LScons _ s sl' => need0 tab s ++ need0_ls tab sl' end.

  Fixpoint need_close (n : nat) (ds : list (ident * option expr)) (N : list ident) : list ident :=
    match n with
    | O => N
    | S n' => need_close n' ds (N ++ flat_map (fun d => if mem_i (fst d) N then
                                   match snd d with Some a => etemps a | None => [] end
                                   else []) ds)
    end.

  (* a parameter gets a kind only when the body needs one of it *)
  Definition smart_kinds (tab : stab) (f : Clight.function) : list skind :=
    let N := need_close 4 (t_defs (fn_body f)) (need0 tab (fn_body f)) in
    map (fun p => if mem_i (fst p) N then kind_of_ty (snd p) else KAny) (fn_params f).

  Definition any_kinds (f : Clight.function) : list skind := map (fun _ => KAny) (fn_params f).
End GUESS.
