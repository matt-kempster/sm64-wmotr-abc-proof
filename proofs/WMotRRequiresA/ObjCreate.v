(* spine (via BhvStep's spawn rows): OBJECTS -- allocate_object, run by its
   real body (spawn_object.c:121-182), on top of ObjAlloc's
   try_allocate_object.
     - a SLOT-STORE WALKER (fx / fx_sound): a statement made of stores
       through the fresh slot pointer at constant offsets, temp sets and
       ifs keeps a list of VALUE FACTS about the slot's cells (chunk,
       offset, value: a constant, or the slot pointer itself) and changes
       nothing outside the slot's non-link bytes (KP);
     - the two non-fragment pieces by hand: the rawData zeroing loop
       (80 words) and mtxf_identity(obj->transform) (the real math_util
       body: 16 stores inside the matrix);
     - alloc_ok / alloc_real: from obj_w's rings / free list / gfx, the
       real call, when the free list is NONEMPTY, pops its head k into
       ring i, keeps gfx, returns slot k, writes the fresh-object field
       values (alloc_facts), and changes nothing else but link cells.
       When the free list is EMPTY the body runs find_unimportant_object
       / unload_object (or loops forever): that branch is NAMED, not
       assumed away (the conclusion's first disjunct carries no memory
       fact). *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory
  Globalenvs Ctypes Cop Clight ClightBigstep Clightdefs Events Errors.
From compcert Require Linking.
From SM64.Generated Require graph_node spawn_object object_list_processor area math_util.
From SM64.Proofs Require Import SymbolicLinking LinkedTwelve RealFrameLinked.
From SM64.Proofs.WMotRRequiresA Require Import ObjWorld ObjRing ObjAlloc.
From SM64.Proofs.WMotRRequiresA Require ObjSelf RenderAnim ObjLoop.

Import ListNotations.
Local Open Scope Z_scope.
Local Transparent Archi.ptr64.

Module RA := RenderAnim.
Module SO := SM64.Generated.spawn_object.
Module MU := SM64.Generated.math_util.
Module GN := SM64.Generated.graph_node.

(* ---------------------------------------------------------------------- *)
(* 1. Value facts about one slot.                                          *)
(* ---------------------------------------------------------------------- *)
(* a fact's value: a closed constant, or the slot's own pointer (kept
   symbolic so the fact lists stay closed terms) *)
Inductive sv := SC (v : val) | SSelf.

Definition ival (ov : val) (s : sv) : val := match s with SC v => v | SSelf => ov end.

Definition fact : Type := (memory_chunk * Z * sv)%type.

Definition sv_eqb (a b : sv) : bool :=
  match a, b with
  | SC v1, SC v2 => if Val.eq v1 v2 then true else false
  | SSelf, SSelf => true
  | _, _ => false
  end.

Definition fact_eqb (x y : fact) : bool :=
  match x, y with
  | (c1, d1, s1), (c2, d2, s2) =>
      (if chunk_eq c1 c2 then true else false) && Z.eqb d1 d2 && sv_eqb s1 s2
  end.

Lemma fact_eqb_eq : forall x y, fact_eqb x y = true -> x = y.
Proof.
  intros [[c1 d1] s1] [[c2 d2] s2] H. cbn in H.
  apply andb_true_iff in H as [H H3]. apply andb_true_iff in H as [H1 H2].
  destruct (chunk_eq c1 c2) as [<- | ]; [ | discriminate H1 ].
  apply Z.eqb_eq in H2. subst d2.
  destruct s1, s2; cbn in H3; try discriminate H3; [ | reflexivity ].
  destruct (Val.eq v v0) as [<- | ]; [ reflexivity | discriminate H3 ].
Qed.

(* every fact holds at slot base `base` of block b *)
Definition facts (m : mem) (b : block) (base : Z) (ov : val) (F : list fact) : Prop :=
  forall ch d s, In (ch, d, s) F -> Mem.load ch m b (base + d) = Some (ival ov s).

Definition disj (d n : Z) (x : fact) : bool :=
  match x with (ch, d', _) => (d' + size_chunk ch <=? d) || (d + n <=? d') end.
Definition kill (d n : Z) (F : list fact) : list fact := filter (disj d n) F.
Definition inter (F G : list fact) : list fact := filter (fun x => existsb (fact_eqb x) G) F.

Lemma facts_nil : forall m b base ov, facts m b base ov [].
Proof. intros m b base ov ch d s H. destruct H. Qed.

Lemma facts_store_kill : forall m b base ov F ch d w m',
  Mem.store ch m b (base + d) w = Some m' -> facts m b base ov F ->
  facts m' b base ov (kill d (size_chunk ch) F).
Proof.
  intros m b base ov F ch d w m' Hs HF ch' d' s Hin.
  apply filter_In in Hin as [Hin Hd]. cbn in Hd.
  rewrite (Mem.load_store_other _ _ _ _ _ _ Hs). { exact (HF _ _ _ Hin). }
  right. apply orb_true_iff in Hd as [Hd | Hd]; apply Z.leb_le in Hd; [ left | right ]; lia.
Qed.

Lemma facts_store : forall m b base ov F ch d w m' s,
  Mem.store ch m b (base + d) w = Some m' -> Val.load_result ch w = ival ov s ->
  facts m b base ov F -> facts m' b base ov ((ch, d, s) :: kill d (size_chunk ch) F).
Proof.
  intros m b base ov F ch d w m' s Hs Hv HF ch' d' s' [E | Hin].
  - injection E as <- <- <-. rewrite (Mem.load_store_same _ _ _ _ _ _ Hs). rewrite Hv. reflexivity.
  - exact (facts_store_kill m b base ov F ch d w m' Hs HF ch' d' s' Hin).
Qed.

Lemma facts_inter_l : forall m b base ov F G, facts m b base ov F -> facts m b base ov (inter F G).
Proof. intros m b base ov F G HF ch d s Hin. apply filter_In in Hin as [Hin _]. exact (HF _ _ _ Hin). Qed.

Lemma facts_inter_r : forall m b base ov F G, facts m b base ov G -> facts m b base ov (inter F G).
Proof.
  intros m b base ov F G HG ch d s Hin. apply filter_In in Hin as [_ Hin].
  apply existsb_exists in Hin as (y & Hy & E). apply fact_eqb_eq in E. subst y. exact (HG _ _ _ Hy).
Qed.

Lemma facts_unch : forall (P : block -> Z -> Prop) m m' b base ov F,
  Mem.unchanged_on P m m' ->
  (forall ch d s, In (ch, d, s) F -> forall i, base + d <= i < base + d + size_chunk ch -> P b i) ->
  facts m b base ov F -> facts m' b base ov F.
Proof.
  intros P m m' b base ov F U HP HF ch d s Hin.
  apply (Mem.load_unchanged_on P m m' ch b (base + d) (ival ov s) U).
  - intros i Hi. exact (HP _ _ _ Hin i Hi).
  - exact (HF _ _ _ Hin).
Qed.

(* a store that misses the fact cells keeps the facts *)
Lemma facts_kill_unch : forall m m' b base ov F d n,
  Mem.unchanged_on (fun b' z => b' <> b \/ z < base + d \/ base + d + n <= z) m m' ->
  facts m b base ov F -> facts m' b base ov (kill d n F).
Proof.
  intros m m' b base ov F d n U HF.
  apply (facts_unch _ m m' b base ov (kill d n F) U).
  - intros ch d' s Hin i Hi. apply filter_In in Hin as [_ Hd]. cbn in Hd.
    right. apply orb_true_iff in Hd as [Hd | Hd]; apply Z.leb_le in Hd; [ left | right ]; lia.
  - intros ch d' s Hin. apply filter_In in Hin as [Hin _]. exact (HF _ _ _ Hin).
Qed.

(* ---------------------------------------------------------------------- *)
(* 2. Constant right-hand sides and their casts.                           *)
(* ---------------------------------------------------------------------- *)
Definition tyb (t u : type) : bool := if type_eq t u then true else false.

Lemma tyb_eq : forall t u, tyb t u = true -> t = u.
Proof. intros t u H. unfold tyb in H. destruct (type_eq t u); [ exact e | discriminate H ]. Qed.

Fixpoint cv (a : expr) : option val :=
  match a with
  | Econst_int i t => if tyb t tint then Some (Vint i) else None
  | Econst_single f t => if tyb t tfloat then Some (Vsingle f) else None
  | Eunop Oneg a1 _ =>
      if tyb (typeof a1) tint then
        match cv a1 with Some (Vint i) => Some (Vint (Int.neg i)) | _ => None end
      else if tyb (typeof a1) tfloat then
        match cv a1 with Some (Vsingle f) => Some (Vsingle (Float32.neg f)) | _ => None end
      else None
  | Eunop Onotint a1 _ =>
      if tyb (typeof a1) tint then
        match cv a1 with Some (Vint i) => Some (Vint (Int.not i)) | _ => None end
      else None
  | Ebinop op a1 a2 _ =>
      if tyb (typeof a1) tint && tyb (typeof a2) tint then
        match op, cv a1, cv a2 with
        | Oor, Some (Vint i), Some (Vint j) => Some (Vint (Int.or i j))
        | Oand, Some (Vint i), Some (Vint j) => Some (Vint (Int.and i j))
        | Oshl, Some (Vint i), Some (Vint j) =>
            if Int.ltu j Int.iwordsize then Some (Vint (Int.shl i j)) else None
        | _, _, _ => None
        end
      else None
  | Ecast a1 (Tpointer _ _) =>
      if tyb (typeof a1) tint then
        match cv a1 with Some (Vint i) => Some (Vint i) | _ => None end
      else None
  | _ => None
  end.

Lemma no_lv_const : forall (ge : genv) e le m i t b o bf, ~ eval_lvalue ge e le m (Econst_int i t) b o bf.
Proof. intros ge e le m i t b o bf H. inv H. Qed.

Ltac kill_lv := try (match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end).

Lemma cv_sound : forall (ge : genv) e le m a v, eval_expr ge e le m a v -> forall w, cv a = Some w -> v = w.
Proof.
  intros ge e le m a. induction a; intros v H w Hc; cbn [cv] in Hc; try discriminate Hc.
  - destruct (tyb t tint); [ | discriminate Hc ]. injection Hc as <-. inv H; kill_lv. reflexivity.
  - destruct (tyb t tfloat); [ | discriminate Hc ]. injection Hc as <-. inv H; kill_lv. reflexivity.
  - inv H; kill_lv.
    match goal with Hs : sem_unary_operation _ _ _ _ = Some _, He : eval_expr _ _ _ _ a _ |- _ =>
      rename Hs into Hs0; rename He into He0 end.
    destruct u; try discriminate Hc.
    + destruct (tyb (typeof a) tint) eqn:Et; [ | discriminate Hc ].
      apply tyb_eq in Et. rewrite Et in Hs0.
      destruct (cv a) as [[]|]; try discriminate Hc. injection Hc as <-.
      rewrite (IHa _ He0 _ eq_refl) in Hs0. cbn in Hs0. injection Hs0 as <-. reflexivity.
    + destruct (tyb (typeof a) tint) eqn:Et.
      * apply tyb_eq in Et. rewrite Et in Hs0.
        destruct (cv a) as [[]|]; try discriminate Hc. injection Hc as <-.
        rewrite (IHa _ He0 _ eq_refl) in Hs0. cbn in Hs0. injection Hs0 as <-. reflexivity.
      * destruct (tyb (typeof a) tfloat) eqn:Ef; [ | discriminate Hc ].
        apply tyb_eq in Ef. rewrite Ef in Hs0.
        destruct (cv a) as [[]|]; try discriminate Hc. injection Hc as <-.
        rewrite (IHa _ He0 _ eq_refl) in Hs0. cbn in Hs0. injection Hs0 as <-. reflexivity.
  - inv H; kill_lv.
    match goal with Hs : sem_binary_operation _ _ _ _ _ _ _ = Some _,
                    E1 : eval_expr _ _ _ _ a1 _, E2 : eval_expr _ _ _ _ a2 _ |- _ =>
      rename Hs into Hs0; rename E1 into He1; rename E2 into He2 end.
    destruct (tyb (typeof a1) tint) eqn:E1; [ | discriminate Hc ].
    destruct (tyb (typeof a2) tint) eqn:E2; [ | discriminate Hc ]. cbn in Hc.
    apply tyb_eq in E1. apply tyb_eq in E2. rewrite E1, E2 in Hs0.
    destruct b; try discriminate Hc;
      (destruct (cv a1) as [[]|]; try discriminate Hc; destruct (cv a2) as [[]|]; try discriminate Hc;
       rewrite (IHa1 _ He1 _ eq_refl), (IHa2 _ He2 _ eq_refl) in Hs0; cbn in Hs0).
    + injection Hc as <-. injection Hs0 as <-. reflexivity.
    + injection Hc as <-. injection Hs0 as <-. reflexivity.
    + destruct (Int.ltu i0 Int.iwordsize); [ | discriminate Hc ].
      injection Hc as <-. injection Hs0 as <-. reflexivity.
  - destruct t; try discriminate Hc.
    destruct (tyb (typeof a) tint) eqn:Et; [ | discriminate Hc ]. apply tyb_eq in Et.
    destruct (cv a) as [[]|]; try discriminate Hc. injection Hc as <-.
    inv H; kill_lv.
    match goal with Hs : sem_cast _ _ _ _ = Some _, He : eval_expr _ _ _ _ a _ |- _ =>
      rewrite (IHa _ He _ eq_refl), Et in Hs; cbn in Hs; injection Hs as <-; reflexivity end.
Qed.

(* the cast of a store's value to the lvalue type *)
Definition cst (v : val) (t1 t2 : type) : option val :=
  match v with
  | Vint i =>
      if tyb t1 tint then
        if tyb t2 tint || tyb t2 tuint then Some v
        else if tyb t2 tshort then Some (Vint (Int.sign_ext 16 i))
        else match t2 with Tpointer _ _ => Some v | _ => None end
      else match t1, t2 with Tpointer _ _, Tpointer _ _ => Some v | _, _ => None end
  | Vsingle _ => if tyb t1 tfloat && tyb t2 tfloat then Some v else None
  | Vptr _ _ => match t1, t2 with Tpointer _ _, Tpointer _ _ => Some v | _, _ => None end
  | _ => None
  end.

Lemma cst_sound : forall v t1 t2 m w w', cst v t1 t2 = Some w -> sem_cast v t1 t2 m = Some w' -> w' = w.
Proof.
  intros v t1 t2 m w w' Hc Hs. unfold cst in Hc.
  destruct v; try discriminate Hc.
  - destruct (tyb t1 tint) eqn:E1.
    + apply tyb_eq in E1. subst t1.
      destruct (tyb t2 tint) eqn:E2; [ apply tyb_eq in E2; subst t2; cbn in Hs, Hc; congruence | ].
      destruct (tyb t2 tuint) eqn:E3; [ apply tyb_eq in E3; subst t2; cbn in Hs, Hc; congruence | ].
      cbn in Hc. destruct (tyb t2 tshort) eqn:E4; [ apply tyb_eq in E4; subst t2; cbn in Hs, Hc; congruence | ].
      destruct t2; try discriminate Hc. cbn in Hs, Hc. congruence.
    + destruct t1; try discriminate Hc. destruct t2; try discriminate Hc. cbn in Hs, Hc. congruence.
  - destruct (tyb t1 tfloat) eqn:E1; [ | discriminate Hc ].
    destruct (tyb t2 tfloat) eqn:E2; [ | discriminate Hc ].
    apply tyb_eq in E1. apply tyb_eq in E2. subst. cbn in Hs, Hc. congruence.
  - destruct t1; try discriminate Hc. destruct t2; try discriminate Hc. cbn in Hs, Hc. congruence.
Qed.

(* ---------------------------------------------------------------------- *)
(* 3. The slot-store walker.                                               *)
(* ---------------------------------------------------------------------- *)
(* the link cells a store must avoid: header.gfx.node.{prev,next,parent,
   children} and header.{next,prev} *)
Definition WX : list (Z * Z) := [(4, 20); (96, 104)].
Definition wr_ok (d n : Z) : bool :=
  (0 <=? d) && (d + n <=? OSZ) && (0 <? n)
  && forallb (fun r => (d + n <=? fst r) || (snd r <=? d)) WX.

(* the bytes a walked statement keeps: everything but slot k's non-link bytes *)
Definition KP (pool : block) (b0 : Z) (b : block) (z : Z) : Prop :=
  b <> pool \/ z < b0 \/ b0 + OSZ <= z \/ (b0 + 4 <= z < b0 + 20) \/ (b0 + 96 <= z < b0 + 104).

Lemma wr_ok_nkp : forall pool b0 d n i, wr_ok d n = true -> b0 + d <= i < b0 + d + n -> ~ KP pool b0 pool i.
Proof.
  intros pool b0 d n i H Hi. unfold wr_ok in H. cbn in H.
  repeat (apply andb_true_iff in H as [H ?]).
  repeat match goal with Hb : (_ <=? _) = true |- _ => apply Z.leb_le in Hb
                       | Hb : (_ <? _) = true |- _ => apply Z.ltb_lt in Hb
                       | Hb : (_ || _) = true |- _ => apply orb_true_iff in Hb as [Hb | Hb] end;
  unfold KP, OSZ in *; intros [Hn | [Hn | [Hn | [Hn | Hn]]]]; try (apply Hn; reflexivity); lia.
Qed.

Lemma wr_ok_range : forall d n, wr_ok d n = true -> 0 <= d /\ d + n <= OSZ /\ 0 < n.
Proof.
  intros d n H. unfold wr_ok in H. apply andb_true_iff in H as [H _].
  apply andb_true_iff in H as [H H3]. apply andb_true_iff in H as [H1 H2].
  apply Z.leb_le in H1. apply Z.leb_le in H2. apply Z.ltb_lt in H3. lia.
Qed.

Section FX.
  Variable ce : composite_env.
  Variable x : ident.

  Definition sval (r : expr) (tl : type) (ch : memory_chunk) : option sv :=
    match r with
    | Etempvar y _ =>
        if Pos.eqb y x then
          match typeof r, tl, ch with
          | Tpointer _ _, Tpointer _ _, Mint32 => Some SSelf
          | _, _, _ => None
          end
        else None
    | _ =>
        match cv r with
        | Some v => match cst v (typeof r) tl with
                    | Some w => Some (SC (Val.load_result ch w))
                    | None => None
                    end
        | None => None
        end
    end.

  Fixpoint fx (s : statement) (F : list fact) : option (list fact) :=
    match s with
    | Sskip => Some F
    | Sassign l r =>
        match ObjSelf.lad ce [x] l, access_mode (typeof l) with
        | Some d, By_value ch =>
            if wr_ok d (size_chunk ch) then
              Some (match sval r (typeof l) ch with
                    | Some s0 => (ch, d, s0) :: kill d (size_chunk ch) F
                    | None => kill d (size_chunk ch) F
                    end)
            else None
        | _, _ => None
        end
    | Sset y _ => if Pos.eqb y x then None else Some F
    | Ssequence a b => match fx a F with Some F1 => fx b F1 | None => None end
    | Sifthenelse _ a b =>
        match fx a F, fx b F with Some Fa, Some Fb => Some (inter Fa Fb) | _, _ => None end
    | _ => None
    end.
End FX.

(* the first n statements of a right-nested sequence, walked *)
Fixpoint fxl (ce : composite_env) (x : ident) (n : nat) (s : statement) (F : list fact)
    : option (list fact * statement) :=
  match n with
  | O => Some (F, s)
  | S n' =>
      match s with
      | Ssequence a b => match fx ce x a F with Some F1 => fxl ce x n' b F1 | None => None end
      | _ => None
      end
  end.

(* the words [d, d + 4n) all zero *)
Definition zeros (d : Z) (n : nat) : list fact :=
  map (fun j => (Mint32, d + 4 * Z.of_nat j, SC (Vint Int.zero))) (seq 0 n).

Lemma facts_app : forall m b base ov F G, facts m b base ov F -> facts m b base ov G -> facts m b base ov (F ++ G).
Proof. intros m b base ov F G HF HG ch d s Hin. apply in_app_or in Hin as [H | H]; [ exact (HF _ _ _ H) | exact (HG _ _ _ H) ]. Qed.

Lemma facts_incl : forall m b base ov F G, (forall y, In y F -> In y G) -> facts m b base ov G -> facts m b base ov F.
Proof. intros m b base ov F G I HG ch d s Hin. exact (HG _ _ _ (I _ Hin)). Qed.

Lemma kill_in : forall d n F y, In y (kill d n F) -> In y F.
Proof. intros d n F y H. apply filter_In in H as [H _]. exact H. Qed.

Lemma kill_sub : forall d n d' n' F y, d <= d' -> d' + n' <= d + n ->
  In y (kill d n F) -> In y (kill d' n' (kill d n F)).
Proof.
  intros d n d' n' F y H1 H2 H. apply filter_In. split; [ exact H | ].
  apply filter_In in H as [_ Hd]. destruct y as [[ch z] s]. cbn in Hd |- *.
  apply orb_true_iff in Hd as [Hd | Hd]; apply Z.leb_le in Hd; apply orb_true_iff; [ left | right ]; apply Z.leb_le; lia.
Qed.

Lemma facts_zeros : forall m b base ov d n,
  (forall j, 0 <= j < Z.of_nat n -> Mem.load Mint32 m b (base + d + 4 * j) = Some (Vint Int.zero)) ->
  facts m b base ov (zeros d n).
Proof.
  intros m b base ov d n H ch d' s Hin. apply in_map_iff in Hin as (j & E & Hj).
  apply in_seq in Hj. injection E as <- <- <-. cbn [ival].
  rewrite Z.add_assoc. apply H. lia.
Qed.

Lemma signed_small : forall n, 0 <= n <= 1000 -> Int.signed (Int.repr n) = n.
Proof.
  intros n Hn. apply Int.signed_repr.
  change Int.min_signed with (-2147483648). change Int.max_signed with 2147483647. lia.
Qed.

Lemma add1_small : forall n, 0 <= n <= 1000 -> Int.add (Int.repr n) (Int.repr 1) = Int.repr (n + 1).
Proof.
  intros n Hn. rewrite Int.add_unsigned, !Int.unsigned_repr; [ reflexivity | | ];
    change Int.max_unsigned with 4294967295; lia.
Qed.

Lemma lt_small : forall n c, 0 <= n <= 1000 -> 0 <= c <= 1000 ->
  Int.lt (Int.repr n) (Int.repr c) = (n <? c).
Proof.
  intros n c Hn Hc. destruct (Int.lt (Int.repr n) (Int.repr c)) eqn:E.
  - apply RA.lt_true in E. rewrite !signed_small in E by lia. symmetry. apply Z.ltb_lt. exact E.
  - apply RA.lt_false in E. rewrite !signed_small in E by lia. symmetry. apply Z.ltb_ge. exact E.
Qed.

Lemma bo_lt : forall (ce : composite_env) m a b,
  sem_binary_operation ce Olt (Vint a) tint (Vint b) tint m = Some (Val.of_bool (Int.lt a b)).
Proof. reflexivity. Qed.

Lemma bool_ofb : forall c m, bool_val (Val.of_bool c) tint m = Some c.
Proof. destruct c; reflexivity. Qed.

Lemma add_pi : forall (ce : composite_env) m b o n,
  sem_binary_operation ce Oadd (Vptr b o) (tarray tint 80) (Vint n) tint m
  = Some (Vptr b (Ptrofs.add o (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_ints n)))).
Proof. reflexivity. Qed.

Lemma add_ii80 : forall (ce : composite_env) m a n,
  sem_binary_operation ce Oadd (Vint a) (tarray tint 80) (Vint n) tint m
  = Some (Vint (Int.add a (Int.mul (Int.repr 4) n))).
Proof. reflexivity. Qed.

Lemma break_inv : forall (ge : genv) e le m t le' m' out,
  exec_stmt function_entry2 ge e le m Sbreak t le' m' out -> le' = le /\ m' = m /\ out = Out_break.
Proof. intros. inv H. auto. Qed.

(* the statement fxl leaves, and the facts it computes *)
Fixpoint sdrop (n : nat) (s : statement) : statement :=
  match n, s with
  | O, _ => s
  | S n', Ssequence _ b => sdrop n' b
  | S _, _ => s
  end.

Definition ffacts (ce : composite_env) (x : ident) (n : nat) (s : statement) (F : list fact) : list fact :=
  match fxl ce x n s F with Some (F', _) => F' | None => [] end.

Lemma fxl_ok : forall ce x n s F, fxl ce x n s F <> None ->
  fxl ce x n s F = Some (ffacts ce x n s F, sdrop n s).
Proof.
  intros ce x n. unfold ffacts. induction n; intros s F H; cbn [fxl sdrop] in *; [ reflexivity | ].
  destruct s; try (exfalso; apply H; reflexivity).
  destruct (fx ce x s1 F) as [F1|]; [ | exfalso; apply H; reflexivity ].
  exact (IHn s2 F1 H).
Qed.

Section WALK.
  Variable ge : genv.
  Variables pool gB : block.
  Hypothesis Hpool : Genv.find_symbol ge ObjSelf.POOL = Some pool.
  Hypothesis HgB : Genv.find_symbol ge ObjSelf.GCO = Some gB.
  Variable ce : composite_env.
  Hypothesis Hce : ObjSelf.cext ge ce.
  Variable x : ident.
  Variable k : Z.
  Hypothesis Hk : 0 <= k < NSLOT.
  Notation b0 := (k * OSZ).
  Notation ov := (slot_v pool k).
  Notation xs := (exec_stmt function_entry2 ge empty_env).

  (* an lvalue lad names: slot k's byte b0 + d *)
  Lemma lad_at : forall le m l b o bf d, le ! x = Some ov ->
    eval_lvalue ge empty_env le m l b o bf -> ObjSelf.lad ce [x] l = Some d ->
    b = pool /\ o = Ptrofs.add (Ptrofs.repr b0) (Ptrofs.repr d) /\ bf = Full.
  Proof.
    intros le m l b o bf d Hx Hl Hd.
    assert (TI : ObjSelf.TI None ge pool pool gB Ptrofs.zero [] [] le).
    { intros t v _. split; intros E; discriminate E. }
    assert (EI : ObjSelf.EI None ge pool pool gB [] empty_env).
    { intros y b' ty E. rewrite PTree.gempty in E. discriminate E. }
    assert (HTb : forall t v, le ! t = Some v -> ObjSelf.mem_i t [x] = true ->
              forall b' o', v = Vptr b' o' -> b' = pool /\ o' = Ptrofs.repr b0).
    { intros t v Ht Hm b' o' E. cbn in Hm. rewrite orb_false_r in Hm. apply Pos.eqb_eq in Hm. subst t.
      rewrite Hx in Ht. injection Ht as <-. unfold slot_v in E. injection E as <- <-. auto. }
    destruct (proj2 (ObjSelf.pad_gen None ge pool pool gB Ptrofs.zero Hpool HgB ce Hce [] [] empty_env le m TI
                       [] EI [x] (fun o' => o' = Ptrofs.repr b0) HTb) l b o bf Hl d Hd)
      as (-> & (o0 & -> & ->) & ->).
    auto.
  Qed.

  Lemma fx_sound : forall s F F', fx ce x s F = Some F' ->
    forall le m t le' m' out, xs le m s t le' m' out ->
    le ! x = Some ov -> facts m pool b0 ov F ->
    out = Out_normal /\ le' ! x = Some ov /\ facts m' pool b0 ov F' /\ Mem.unchanged_on (KP pool b0) m m'.
  Proof.
    induction s; intros F F' Hf le m t0 le' m' out H Hx HF; cbn [fx] in Hf; try discriminate Hf.
    - (* skip *)
      injection Hf as <-. apply RA.skip_inv in H as (-> & -> & ->).
      auto using Mem.unchanged_on_refl.
    - (* assign *)
      destruct (ObjSelf.lad ce [x] e) as [d|] eqn:Ed; [ | discriminate Hf ].
      destruct (access_mode (typeof e)) as [ch| | | ] eqn:Ea; try discriminate Hf.
      destruct (wr_ok d (size_chunk ch)) eqn:Ew; [ | discriminate Hf ]. injection Hf as <-.
      apply RA.assign_inv in H as (b & o & bf & v2 & v & Hl & He & Hc & Has & -> & ->).
      destruct (lad_at le m e b o bf d Hx Hl Ed) as (-> & -> & ->).
      pose proof (RA.store_by_value ge (typeof e) m pool _ Full v m' ch Ea eq_refl Has) as Hs.
      destruct (wr_ok_range _ _ Ew) as (Hd0 & Hd1 & Hn).
      pose proof (size_chunk_pos ch) as Hsz.
      rewrite (slot_fld k d Hk) in Hs by lia.
      split; [ reflexivity | split; [ exact Hx | split ] ].
      + destruct (sval x e0 (typeof e) ch) as [s0|] eqn:Esv.
        * apply (facts_store m pool b0 ov F ch d v m' s0 Hs); [ | exact HF ].
          unfold sval in Esv. destruct e0;
            try (destruct (cv _) as [w|] eqn:Ecv; [ | discriminate Esv ];
                 destruct (cst w _ (typeof e)) as [w'|] eqn:Ecs; [ | discriminate Esv ];
                 injection Esv as <-; cbn [ival];
                 rewrite (cv_sound _ _ _ _ _ _ He _ Ecv) in Hc;
                 rewrite (cst_sound _ _ _ _ _ _ Ecs Hc); reflexivity).
          (* the slot pointer *)
          destruct (Pos.eqb i x) eqn:Ei; [ | discriminate Esv ]. apply Pos.eqb_eq in Ei. subst i.
          cbn [typeof] in Esv, Hc. destruct t; try discriminate Esv.
          destruct (typeof e) eqn:Etl; try discriminate Esv. destruct ch; try discriminate Esv.
          injection Esv as <-. apply RA.ev_temp in He. rewrite Hx in He. injection He as <-.
          unfold slot_v in Hc. cbn in Hc. injection Hc as <-. reflexivity.
        * exact (facts_store_kill m pool b0 ov F ch d v m' Hs HF).
      + apply (Mem.store_unchanged_on (KP pool b0) ch m pool (b0 + d) v m' Hs).
        intros i Hi. exact (wr_ok_nkp pool b0 d (size_chunk ch) i Ew Hi).
    - (* set *)
      destruct (Pos.eqb i x) eqn:Ei; [ discriminate Hf | ]. injection Hf as <-.
      apply RA.set_inv in H as (v & _ & -> & -> & ->).
      split; [ reflexivity | split; [ | split; [ exact HF | apply Mem.unchanged_on_refl ] ] ].
      rewrite PTree.gso; [ exact Hx | ]. intros E. subst i. rewrite Pos.eqb_refl in Ei. discriminate Ei.
    - (* sequence *)
      destruct (fx ce x s1 F) as [F1|] eqn:E1; [ | discriminate Hf ].
      apply RA.seq_inv in H as [(t1 & le1 & m1 & t2 & H1 & H2) | (H1 & Hn)].
      + destruct (IHs1 F F1 E1 _ _ _ _ _ _ H1 Hx HF) as (_ & Hx1 & HF1 & U1).
        destruct (IHs2 F1 F' Hf _ _ _ _ _ _ H2 Hx1 HF1) as (Ho & Hx2 & HF2 & U2).
        split; [ exact Ho | split; [ exact Hx2 | split; [ exact HF2 | exact (Mem.unchanged_on_trans _ _ _ _ U1 U2) ] ] ].
      + destruct (IHs1 F F1 E1 _ _ _ _ _ _ H1 Hx HF) as (Ho & _). contradiction.
    - (* if *)
      destruct (fx ce x s1 F) as [Fa|] eqn:Ea; [ | discriminate Hf ].
      destruct (fx ce x s2 F) as [Fb|] eqn:Eb; [ | discriminate Hf ]. injection Hf as <-.
      apply RA.if_inv in H as (v & bb & _ & _ & H).
      destruct bb.
      + destruct (IHs1 F Fa Ea _ _ _ _ _ _ H Hx HF) as (Ho & Hx1 & HF1 & U).
        split; [ exact Ho | split; [ exact Hx1 | split; [ apply facts_inter_l; exact HF1 | exact U ] ] ].
      + destruct (IHs2 F Fb Eb _ _ _ _ _ _ H Hx HF) as (Ho & Hx1 & HF1 & U).
        split; [ exact Ho | split; [ exact Hx1 | split; [ apply facts_inter_r; exact HF1 | exact U ] ] ].
  Qed.

  (* one walked statement at the head of a sequence *)
  Lemma fx_seq : forall a b F F', fx ce x a F = Some F' ->
    forall le m t le' m' out, xs le m (Ssequence a b) t le' m' out ->
    le ! x = Some ov -> facts m pool b0 ov F ->
    exists le1 m1 t2, xs le1 m1 b t2 le' m' out /\ le1 ! x = Some ov /\ facts m1 pool b0 ov F'
      /\ Mem.unchanged_on (KP pool b0) m m1.
  Proof.
    intros a b F F' Hf le m t le' m' out H Hx HF.
    apply RA.seq_inv in H as [(t1 & le1 & m1 & t2 & H1 & H2) | (H1 & Hn)].
    - destruct (fx_sound a F F' Hf _ _ _ _ _ _ H1 Hx HF) as (_ & Hx1 & HF1 & U).
      exists le1, m1, t2. auto.
    - destruct (fx_sound a F F' Hf _ _ _ _ _ _ H1 Hx HF) as (Ho & _). contradiction.
  Qed.
  Lemma fxl_sound : forall n s F F' s', fxl ce x n s F = Some (F', s') ->
    forall le m t le' m' out, xs le m s t le' m' out ->
    le ! x = Some ov -> facts m pool b0 ov F ->
    exists le1 m1 t2, xs le1 m1 s' t2 le' m' out /\ le1 ! x = Some ov /\ facts m1 pool b0 ov F'
      /\ Mem.unchanged_on (KP pool b0) m m1.
  Proof.
    induction n; intros s F F' s' Hf le m t le' m' out H Hx HF; cbn [fxl] in Hf.
    - injection Hf as <- <-. exists le, m, t. auto using Mem.unchanged_on_refl.
    - destruct s; try discriminate Hf.
      destruct (fx ce x s1 F) as [F1|] eqn:E1; [ | discriminate Hf ].
      destruct (fx_seq s1 s2 F F1 E1 _ _ _ _ _ _ H Hx HF) as (le1 & m1 & t1 & H1 & Hx1 & HF1 & U1).
      destruct (IHn s2 F1 F' s' Hf _ _ _ _ _ _ H1 Hx1 HF1) as (le2 & m2 & t2 & H2 & Hx2 & HF2 & U2).
      exists le2, m2, t2. split; [ exact H2 | split; [ exact Hx2 | split; [ exact HF2 | ] ] ].
      exact (Mem.unchanged_on_trans _ _ _ _ U1 U2).
  Qed.

  (* ---- the rawData zeroing loop (spawn_object.c:139-141) ---- *)
  Section ZL.
    Variable i : ident.
    Hypothesis Hix : i <> x.
    Variable arr : expr.
    Variable d : Z.
    Hypothesis Hpad : ObjSelf.pad ce [x] arr = Some d.
    Hypothesis Harr : typeof arr = tarray tint 80.
    Hypothesis Hw : wr_ok d 320 = true.

    Definition ZB : statement :=
      Ssequence
        (Sifthenelse (Ebinop Olt (Etempvar i tint) (Econst_int (Int.repr 80) tint) tint) Sskip Sbreak)
        (Sassign (Ederef (Ebinop Oadd arr (Etempvar i tint) (tptr tint)) tint) (Econst_int (Int.repr 0) tint)).
    Definition ZI : statement := Sset i (Ebinop Oadd (Etempvar i tint) (Econst_int (Int.repr 1) tint) tint).

    Lemma arr_val : forall le m v, le ! x = Some ov -> eval_expr ge empty_env le m arr v ->
      forall b o, v = Vptr b o -> b = pool /\ o = Ptrofs.add (Ptrofs.repr b0) (Ptrofs.repr d).
    Proof.
      intros le m v Hx He b o E.
      assert (TI : ObjSelf.TI None ge pool pool gB Ptrofs.zero [] [] le).
      { intros t v' _. split; intros E'; discriminate E'. }
      assert (EI : ObjSelf.EI None ge pool pool gB [] empty_env).
      { intros y b' ty E'. rewrite PTree.gempty in E'. discriminate E'. }
      assert (HTb : forall t v', le ! t = Some v' -> ObjSelf.mem_i t [x] = true ->
                forall b' o', v' = Vptr b' o' -> b' = pool /\ o' = Ptrofs.repr b0).
      { intros t v' Ht Hm b' o' E'. cbn in Hm. rewrite orb_false_r in Hm. apply Pos.eqb_eq in Hm. subst t.
        rewrite Hx in Ht. injection Ht as <-. unfold slot_v in E'. injection E' as <- <-. auto. }
      destruct (proj1 (ObjSelf.pad_gen None ge pool pool gB Ptrofs.zero Hpool HgB ce Hce [] [] empty_env le m TI
                         [] EI [x] (fun o' => o' = Ptrofs.repr b0) HTb) arr v He d Hpad b o E)
        as (-> & o0 & -> & ->).
      auto.
    Qed.

    Lemma zaddr : forall le m n l o, le ! i = Some (Vint (Int.repr n)) -> 0 <= n < 80 -> le ! x = Some ov ->
      eval_expr ge empty_env le m (Ebinop Oadd arr (Etempvar i tint) (tptr tint)) (Vptr l o) ->
      l = pool /\ Ptrofs.unsigned o = b0 + d + 4 * n.
    Proof.
      intros le m n l o Hi Hn Hx H. inv H; kill_lv.
      match goal with E1 : eval_expr _ _ _ _ arr ?v1, E2 : eval_expr _ _ _ _ (Etempvar i _) ?v2,
                      Hs : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ =>
        rename E1 into Ea; rename E2 into Et; rename Hs into Hs0 end.
      apply RA.ev_temp in Et. rewrite Hi in Et. injection Et as <-.
      rewrite Harr in Hs0. cbn [typeof] in Hs0.
      destruct (wr_ok_range _ _ Hw) as (Hd0 & Hd1 & _).
      destruct v1;
        try (rewrite add_ii80 in Hs0; discriminate Hs0);
        try (cbn in Hs0; discriminate Hs0).
      rewrite add_pi in Hs0. injection Hs0 as <- <-.
      destruct (arr_val _ _ _ Hx Ea _ _ eq_refl) as (-> & ->).
      split; [ reflexivity | ].
      unfold Ptrofs.of_ints. rewrite signed_small by lia.
      rewrite ObjSelf.ptrofs_mul_repr, Ptrofs.add_assoc, ObjSelf.ptrofs_add_repr.
      rewrite (slot_fld k (d + 4 * n) Hk) by (unfold OSZ in *; lia). lia.
    Qed.

    Lemma zbody : forall le m t le1 m1 out1 n,
      exec_stmt function_entry2 ge empty_env le m ZB t le1 m1 out1 ->
      le ! i = Some (Vint (Int.repr n)) -> 0 <= n <= 80 -> le ! x = Some ov ->
      (n < 80 /\ out1 = Out_normal /\ le1 = le
         /\ Mem.store Mint32 m pool (b0 + d + 4 * n) (Vint Int.zero) = Some m1)
      \/ (n = 80 /\ out1 = Out_break /\ m1 = m /\ le1 = le).
    Proof.
      intros le m t le1 m1 out1 n H Hi Hn Hx. unfold ZB in H.
      apply RA.seq_inv in H as [(t1 & lea & ma & t2 & H1 & H2) | (H1 & Hne)].
      - apply RA.if_inv in H1 as (v & bb & Hc & Hb & H1).
        inv Hc; kill_lv.
        match goal with E1 : eval_expr _ _ _ _ (Etempvar i _) _, E2 : eval_expr _ _ _ _ (Econst_int _ _) _,
                        Hs : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ =>
          apply RA.ev_temp in E1; rewrite Hi in E1; injection E1 as <-;
          apply RA.ev_const in E2; subst; cbn [typeof] in Hs; rewrite bo_lt in Hs; injection Hs as <- end.
        cbn [typeof] in Hb. rewrite bool_ofb in Hb. injection Hb as <-.
        rewrite lt_small in H1 by lia.
        destruct (n <? 80) eqn:Elt.
        + apply RA.skip_inv in H1 as (-> & -> & _). apply Z.ltb_lt in Elt.
          left. split; [ exact Elt | ].
          apply RA.assign_inv in H2 as (b & o & bf & v2 & v & Hl & He & Hcs & Has & -> & ->).
          split; [ reflexivity | split; [ reflexivity | ] ].
          inv Hl.
          match goal with Ha : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
            destruct (zaddr _ _ n _ _ Hi (conj (proj1 Hn) Elt) Hx Ha) as (-> & Ho) end.
          apply RA.ev_const in He. subst v2. cbn [typeof] in Hcs. apply RA.cast_tint_id in Hcs. subst v.
          pose proof (RA.store_by_value ge tint m pool _ Full _ m1 Mint32 eq_refl eq_refl Has) as Hs.
          rewrite Ho in Hs. exact Hs.
        + apply break_inv in H1 as (_ & _ & E). discriminate E.
      - apply RA.if_inv in H1 as (v & bb & Hc & Hb & H1).
        inv Hc; kill_lv.
        match goal with E1 : eval_expr _ _ _ _ (Etempvar i _) _, E2 : eval_expr _ _ _ _ (Econst_int _ _) _,
                        Hs : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ =>
          apply RA.ev_temp in E1; rewrite Hi in E1; injection E1 as <-;
          apply RA.ev_const in E2; subst; cbn [typeof] in Hs; rewrite bo_lt in Hs; injection Hs as <- end.
        cbn [typeof] in Hb. rewrite bool_ofb in Hb. injection Hb as <-.
        rewrite lt_small in H1 by lia.
        destruct (n <? 80) eqn:Elt.
        + apply RA.skip_inv in H1 as (_ & _ & E). contradiction.
        + apply break_inv in H1 as (-> & -> & ->). apply Z.ltb_ge in Elt.
          right. split; [ lia | auto ].
    Qed.

    Lemma zinc : forall le m t le1 m1 out1 n,
      exec_stmt function_entry2 ge empty_env le m ZI t le1 m1 out1 ->
      le ! i = Some (Vint (Int.repr n)) -> 0 <= n < 80 ->
      le1 = PTree.set i (Vint (Int.repr (n + 1))) le /\ m1 = m /\ out1 = Out_normal.
    Proof.
      intros le m t le1 m1 out1 n H Hi Hn. unfold ZI in H.
      apply RA.set_inv in H as (v & He & -> & -> & ->).
      inv He; kill_lv.
      match goal with E1 : eval_expr _ _ _ _ (Etempvar i _) _, E2 : eval_expr _ _ _ _ (Econst_int _ _) _,
                      Hs : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ =>
        apply RA.ev_temp in E1; rewrite Hi in E1; injection E1 as <-;
        apply RA.ev_const in E2; subst; cbn [typeof] in Hs; rewrite RA.op_add_ii in Hs; injection Hs as <- end.
      rewrite add1_small by lia. auto.
    Qed.

    Lemma zloop_run : forall le m t le' m' out,
      exec_stmt function_entry2 ge empty_env le m (Sloop ZB ZI) t le' m' out ->
      forall n F, le ! i = Some (Vint (Int.repr n)) -> 0 <= n <= 80 -> le ! x = Some ov ->
      (forall j, 0 <= j < n -> Mem.load Mint32 m pool (b0 + d + 4 * j) = Some (Vint Int.zero)) ->
      facts m pool b0 ov (kill d 320 F) ->
      out = Out_normal /\ le' ! x = Some ov
      /\ (forall j, 0 <= j < 80 -> Mem.load Mint32 m' pool (b0 + d + 4 * j) = Some (Vint Int.zero))
      /\ facts m' pool b0 ov (kill d 320 F) /\ Mem.unchanged_on (KP pool b0) m m'.
    Proof.
      intros le m t le' m' out H. remember (Sloop ZB ZI) as s eqn:Es. remember empty_env as e0 eqn:Ee.
      induction H; try discriminate Es; injection Es as E1 E2; subst; intros n F Hi Hn Hx Hz HF.
      - (* stop1: the body broke out *)
        destruct (zbody _ _ _ _ _ _ n H Hi Hn Hx) as [(_ & -> & _) | (-> & -> & -> & ->)].
        + inv H0.
        + inv H0. split; [ reflexivity | split; [ exact Hx | split; [ exact Hz | split; [ exact HF | ] ] ] ].
          apply Mem.unchanged_on_refl.
      - (* stop2: the increment cannot leave abnormally *)
        destruct (zbody _ _ _ _ _ _ n H Hi Hn Hx) as [(Hn' & -> & -> & _) | (_ & -> & _)]; [ | inv H0 ].
        destruct (zinc _ _ _ _ _ _ n H1 Hi ltac:(lia)) as (_ & _ & ->). inv H2.
      - (* one more round *)
        destruct (zbody _ _ _ _ _ _ n H Hi Hn Hx) as [(Hn' & -> & -> & Hs) | (_ & -> & _)]; [ | inv H0 ].
        destruct (zinc _ _ _ _ _ _ n H1 Hi ltac:(lia)) as (-> & -> & _).
        destruct (IHexec_stmt3 eq_refl eq_refl (n + 1) F) as (Ho & Hx' & Hz' & HF' & U).
        + rewrite PTree.gss. reflexivity.
        + lia.
        + rewrite PTree.gso by (apply not_eq_sym; exact Hix). exact Hx.
        + intros j Hj. destruct (Z.eq_dec j n) as [-> | Hjn].
          * rewrite (Mem.load_store_same _ _ _ _ _ _ Hs). reflexivity.
          * rewrite (Mem.load_store_other _ _ _ _ _ _ Hs); [ apply Hz; lia | ].
            right. cbn [size_chunk]. lia.
        + apply (facts_incl m1 pool b0 ov _ (kill (d + 4 * n) 4 (kill d 320 F))).
          * intros y Hy. apply (kill_sub d 320); [ lia | lia | exact Hy ].
          * replace (b0 + d + 4 * n) with (b0 + (d + 4 * n)) in Hs by lia.
            exact (facts_store_kill m pool b0 ov _ Mint32 (d + 4 * n) _ m1 Hs HF).
        + split; [ exact Ho | split; [ exact Hx' | split; [ exact Hz' | split; [ exact HF' | ] ] ] ].
          refine (Mem.unchanged_on_trans _ _ _ _ _ U).
          apply (Mem.store_unchanged_on (KP pool b0) Mint32 m pool (b0 + d + 4 * n) _ m1 Hs).
          intros z Hz0. cbn [size_chunk] in Hz0. apply (wr_ok_nkp pool b0 d 320 z Hw). lia.
    Qed.

    Lemma zloop : forall le m t le' m' out F,
      exec_stmt function_entry2 ge empty_env le m
        (Ssequence (Sset i (Econst_int (Int.repr 0) tint)) (Sloop ZB ZI)) t le' m' out ->
      le ! x = Some ov -> facts m pool b0 ov F ->
      out = Out_normal /\ le' ! x = Some ov /\ facts m' pool b0 ov (zeros d 80 ++ kill d 320 F)
      /\ Mem.unchanged_on (KP pool b0) m m'.
    Proof.
      intros le m t le' m' out F H Hx HF.
      apply RA.seq_inv in H as [(t1 & le1 & m1 & t2 & H1 & H2) | (H1 & Hne)].
      - apply RA.set_inv in H1 as (v & Hv & -> & -> & _). apply RA.ev_const in Hv. subst v.
        destruct (zloop_run _ _ _ _ _ _ H2 0 F) as (Ho & Hx' & Hz & HF' & U).
        + rewrite PTree.gss. reflexivity.
        + lia.
        + rewrite PTree.gso by (apply not_eq_sym; exact Hix). exact Hx.
        + intros j Hj. lia.
        + apply (facts_incl m pool b0 ov _ F); [ apply kill_in | exact HF ].
        + split; [ exact Ho | split; [ exact Hx' | split; [ | exact U ] ] ].
          apply facts_app; [ | exact HF' ].
          apply facts_zeros. intros j Hj. apply Hz. cbn in Hj. lia.
      - apply RA.set_inv in H1 as (_ & _ & _ & _ & E). contradiction.
    Qed.
  End ZL.
End WALK.

(* ---------------------------------------------------------------------- *)
(* 4. mtxf_identity (math_util.c:229-240), its real body: two strided      *)
(*    store loops through a float pointer, all inside the 4x4 matrix.     *)
(* ---------------------------------------------------------------------- *)
Lemma add_pf : forall (ce : composite_env) m b o s,
  sem_binary_operation ce Oadd (Vptr b o) (tptr tfloat) (Vint s) tint m
  = Some (Vptr b (Ptrofs.add o (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_ints s)))).
Proof. reflexivity. Qed.

Section ML.
  Variable ge : genv.
  Variables dt it : ident.
  Hypothesis Hdi : dt <> it.
  Variables N S c c0 z0 : Z.
  Variable B : block.
  Hypothesis Hr : 0 <= c0 /\ 0 <= S <= 100 /\ 0 < N <= 100 /\ c0 + S * (N - 1) <= 15.
  Hypothesis Hz0 : 0 <= z0 /\ z0 + 64 <= Ptrofs.max_unsigned.

  Definition MB : statement :=
    Ssequence
      (Sifthenelse (Ebinop Olt (Etempvar it tint) (Econst_int (Int.repr N) tint) tint) Sskip Sbreak)
      (Sassign (Ederef (Etempvar dt (tptr tfloat)) tfloat) (Econst_int (Int.repr c) tint)).
  Definition MI : statement :=
    Ssequence
      (Sset dt (Ebinop Oadd (Etempvar dt (tptr tfloat)) (Econst_int (Int.repr S) tint) (tptr tfloat)))
      (Sset it (Ebinop Oadd (Etempvar it tint) (Econst_int (Int.repr 1) tint) tint)).
  Definition MF (b : block) (z : Z) : Prop := b <> B \/ z < z0 \/ z0 + 64 <= z.
  Definition dpos (n : Z) : val := Vptr B (Ptrofs.repr (z0 + 4 * (c0 + S * n))).

  Lemma mbody : forall e le m t le1 m1 out1 n,
    exec_stmt function_entry2 ge e le m MB t le1 m1 out1 ->
    le ! it = Some (Vint (Int.repr n)) -> 0 <= n <= N -> le ! dt = Some (dpos n) ->
    (n < N /\ out1 = Out_normal /\ le1 = le
       /\ exists v, Mem.store Mfloat32 m B (z0 + 4 * (c0 + S * n)) v = Some m1)
    \/ (n = N /\ out1 = Out_break /\ m1 = m /\ le1 = le).
  Proof.
    intros e le m t le1 m1 out1 n H Hi Hn Hd. unfold MB in H.
    apply RA.seq_inv in H as [(t1 & lea & ma & t2 & H1 & H2) | (H1 & Hne)].
    - apply RA.if_inv in H1 as (v & bb & Hc & Hb & H1).
      inv Hc; kill_lv.
      match goal with E1 : eval_expr _ _ _ _ (Etempvar it _) _, E2 : eval_expr _ _ _ _ (Econst_int _ _) _,
                      Hs : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ =>
        apply RA.ev_temp in E1; rewrite Hi in E1; injection E1 as <-;
        apply RA.ev_const in E2; subst; cbn [typeof] in Hs; rewrite bo_lt in Hs; injection Hs as <- end.
      cbn [typeof] in Hb. rewrite bool_ofb in Hb. injection Hb as <-.
      rewrite lt_small in H1 by lia.
      destruct (n <? N) eqn:Elt.
      + apply RA.skip_inv in H1 as (-> & -> & _). apply Z.ltb_lt in Elt.
        assert (Hbd : 0 <= z0 + 4 * (c0 + S * n) <= Ptrofs.max_unsigned)
          by (destruct Hr as (Hr1 & Hr2 & Hr3 & Hr4); assert (S * n <= S * (N - 1)) by nia; assert (0 <= S * n) by nia; lia).
        left. split; [ exact Elt | ].
        apply RA.assign_inv in H2 as (b & o & bf & v2 & v & Hl & He & Hcs & Has & -> & ->).
        split; [ reflexivity | split; [ reflexivity | ] ].
        inv Hl.
        match goal with Ha : eval_expr _ _ _ _ (Etempvar dt _) _ |- _ =>
          apply RA.ev_temp in Ha; rewrite Hd in Ha; unfold dpos in Ha; injection Ha as <- <- end.
        exists v. pose proof (RA.store_by_value ge tfloat m B _ Full v m1 Mfloat32 eq_refl eq_refl Has) as Hs.
        rewrite Ptrofs.unsigned_repr in Hs; [ exact Hs | ].
        exact Hbd.
      + apply break_inv in H1 as (_ & _ & E). discriminate E.
    - apply RA.if_inv in H1 as (v & bb & Hc & Hb & H1).
      inv Hc; kill_lv.
      match goal with E1 : eval_expr _ _ _ _ (Etempvar it _) _, E2 : eval_expr _ _ _ _ (Econst_int _ _) _,
                      Hs : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ =>
        apply RA.ev_temp in E1; rewrite Hi in E1; injection E1 as <-;
        apply RA.ev_const in E2; subst; cbn [typeof] in Hs; rewrite bo_lt in Hs; injection Hs as <- end.
      cbn [typeof] in Hb. rewrite bool_ofb in Hb. injection Hb as <-.
      rewrite lt_small in H1 by lia.
      destruct (n <? N) eqn:Elt.
      + apply RA.skip_inv in H1 as (_ & _ & E). contradiction.
      + apply break_inv in H1 as (-> & -> & ->). apply Z.ltb_ge in Elt.
        right. split; [ lia | auto ].
  Qed.

  Lemma minc : forall e le m t le1 m1 out1 n,
    exec_stmt function_entry2 ge e le m MI t le1 m1 out1 ->
    le ! it = Some (Vint (Int.repr n)) -> 0 <= n < N -> le ! dt = Some (dpos n) ->
    le1 = PTree.set it (Vint (Int.repr (n + 1))) (PTree.set dt (dpos (n + 1)) le) /\ m1 = m /\ out1 = Out_normal.
  Proof.
    intros e le m t le1 m1 out1 n H Hi Hn Hd. unfold MI in H.
    apply RA.seq_inv in H as [(t1 & lea & ma & t2 & H1 & H2) | (H1 & Hne)].
    - apply RA.set_inv in H1 as (v & He & -> & -> & _).
      apply RA.set_inv in H2 as (w & Hw & -> & -> & ->).
      inv He; kill_lv.
      match goal with E1 : eval_expr _ _ _ _ (Etempvar dt _) _, E2 : eval_expr _ _ _ _ (Econst_int _ _) _,
                      Hs : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ =>
        apply RA.ev_temp in E1; rewrite Hd in E1; injection E1 as <-;
        apply RA.ev_const in E2; subst; cbn [typeof] in Hs; unfold dpos in Hs; rewrite add_pf in Hs;
        injection Hs as <- end.
      inv Hw; kill_lv.
      match goal with E1 : eval_expr _ _ _ _ (Etempvar it _) _, E2 : eval_expr _ _ _ _ (Econst_int _ _) _,
                      Hs : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ =>
        apply RA.ev_temp in E1; rewrite PTree.gso in E1 by (apply not_eq_sym; exact Hdi);
        rewrite Hi in E1; injection E1 as <-;
        apply RA.ev_const in E2; subst; cbn [typeof] in Hs; rewrite RA.op_add_ii in Hs; injection Hs as <- end.
      rewrite add1_small by lia. split; [ | auto ].
      unfold dpos, Ptrofs.of_ints. rewrite signed_small by lia.
      rewrite ObjSelf.ptrofs_mul_repr, ObjSelf.ptrofs_add_repr.
      assert (E : z0 + 4 * (c0 + S * n) + 4 * S = z0 + 4 * (c0 + S * (n + 1))) by lia.
      match goal with |- PTree.set _ _ (PTree.set _ (Vptr _ (Ptrofs.repr ?a)) _) = PTree.set _ _ (PTree.set _ (Vptr _ (Ptrofs.repr ?b)) _) => assert (Eab : a = b) by exact E; rewrite Eab; reflexivity end.
    - apply RA.set_inv in H1 as (_ & _ & _ & _ & E). contradiction.
  Qed.

  Lemma mloop : forall e le m t le' m' out,
    exec_stmt function_entry2 ge e le m (Sloop MB MI) t le' m' out ->
    forall n, le ! it = Some (Vint (Int.repr n)) -> 0 <= n <= N -> le ! dt = Some (dpos n) ->
    out = Out_normal /\ (forall y, y <> dt -> y <> it -> le' ! y = le ! y) /\ Mem.unchanged_on MF m m'.
  Proof.
    intros e le m t le' m' out H. remember (Sloop MB MI) as s eqn:Es.
    induction H; try discriminate Es; injection Es as E1 E2; subst; intros n Hi Hn Hd.
    - destruct (mbody _ _ _ _ _ _ _ n H Hi Hn Hd) as [(_ & -> & _) | (-> & -> & -> & ->)].
      + inv H0.
      + inv H0. split; [ reflexivity | split; [ auto | apply Mem.unchanged_on_refl ] ].
    - destruct (mbody _ _ _ _ _ _ _ n H Hi Hn Hd) as [(Hn' & -> & -> & _) | (_ & -> & _)]; [ | inv H0 ].
      destruct (minc _ _ _ _ _ _ _ n H1 Hi ltac:(lia) Hd) as (_ & _ & ->). inv H2.
    - destruct (mbody _ _ _ _ _ _ _ n H Hi Hn Hd) as [(Hn' & -> & -> & v & Hs) | (_ & -> & _)]; [ | inv H0 ].
      destruct (minc _ _ _ _ _ _ _ n H1 Hi ltac:(lia) Hd) as (-> & -> & _).
      destruct (IHexec_stmt3 eq_refl (n + 1)) as (Ho & Hle & U).
      + rewrite PTree.gss. reflexivity.
      + lia.
      + rewrite PTree.gso by exact Hdi. rewrite PTree.gss. reflexivity.
      + split; [ exact Ho | split ].
        * intros y H1y H2y. rewrite (Hle y H1y H2y), PTree.gso by exact H2y. rewrite PTree.gso by exact H1y. reflexivity.
        * refine (Mem.unchanged_on_trans _ _ _ _ _ U).
          apply (Mem.store_unchanged_on MF Mfloat32 m B _ v m1 Hs).
          intros z Hz. cbn [size_chunk] in Hz. unfold MF.
          destruct Hr as (H1' & H2' & H3' & H4'). assert (S * n <= S * (N - 1)) by nia.
          intros [Hb | [Hb | Hb]]; [ apply Hb; reflexivity | lia | lia ].
  Qed.
End ML.

Lemma dm_mid : (prog_defmap MU.prog) ! SO._mtxf_identity = Some (Gfun (Internal MU.f_mtxf_identity)).
Proof. vm_compute. reflexivity. Qed.

(* THE CALL: mtxf_identity(mtx) writes only inside mtx's 64 bytes *)
Lemma mtx_ok : forall (ge : genv) m B z0 t m' vr, 0 <= z0 -> z0 + 64 <= Ptrofs.max_unsigned ->
  eval_funcall function_entry2 ge m (Internal MU.f_mtxf_identity) [Vptr B (Ptrofs.repr z0)] t m' vr ->
  Mem.unchanged_on (MF z0 B) m m'.
Proof.
  intros ge m B z0 t m' vr Hz1 Hz2 H.
  destruct (fcall_inv0 ge MU.f_mtxf_identity m _ t m' vr eq_refl H) as (le & le' & out & Hb & Hx & _).
  cbn in Hb. injection Hb as <-.
  cbn [fn_body MU.f_mtxf_identity] in Hx.
  apply RA.seq_inv in Hx as [(t1 & le1 & m1 & t2 & H1 & H2) | (H1 & Hne)].
  - (* the first loop: dest = (f32* )mtx + 1, 14 zero stores *)
    apply RA.seq_inv in H1 as [(ta & lea & ma & tb & Ha & Hl) | (Ha & Hne)].
    + apply RA.seq_inv in Ha as [(tc & lec & mc & td & Hc & Hd) | (Hc & Hne)];
        [ | apply RA.set_inv in Hc as (_ & _ & _ & _ & E); contradiction ].
      apply RA.set_inv in Hc as (v & Hv & -> & -> & _).
      apply RA.set_inv in Hd as (w & Hw & -> & -> & _). apply RA.ev_const in Hw. subst w.
      inv Hv; kill_lv.
      match goal with Ec : eval_expr _ _ _ _ (Ecast _ _) _, E2 : eval_expr _ _ _ _ (Econst_int _ _) _,
                      Hs : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ =>
        inv Ec; kill_lv; apply RA.ev_const in E2; subst end.
      match goal with Et : eval_expr _ _ _ _ (Etempvar _ _) _, Hc : sem_cast _ _ _ _ = Some _ |- _ =>
        apply RA.ev_temp in Et; cbn in Et; injection Et as <-; apply RA.cast_ptr_id in Hc; subst end.
      match goal with Hs : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ =>
        cbn [typeof] in Hs; rewrite add_pf in Hs; injection Hs as <- end.
      destruct (mloop ge MU._dest MU._i ltac:(RA.neq) 14 1 0 1 z0 B ltac:(lia) (conj Hz1 Hz2)
                  _ _ _ _ _ _ _ Hl 0) as (Ho1 & Hle1 & U1).
      * reflexivity.
      * lia.
      * unfold dpos. rewrite PTree.gso by RA.neq. rewrite PTree.gss. f_equal. f_equal. unfold Ptrofs.of_ints. rewrite signed_small by lia.
        rewrite ObjSelf.ptrofs_mul_repr, ObjSelf.ptrofs_add_repr. f_equal; lia.
      * (* the second loop: dest = (f32* )mtx, 4 diagonal one stores *)
        apply RA.seq_inv in H2 as [(te & lee & me & tf & He & Hl2) | (He & Hne)].
        -- apply RA.seq_inv in He as [(tg & leg & mg & th & Hg & Hh) | (Hg & Hne)];
             [ | apply RA.set_inv in Hg as (_ & _ & _ & _ & E); contradiction ].
           apply RA.set_inv in Hg as (v & Hv & -> & -> & _).
           apply RA.set_inv in Hh as (w & Hw & -> & -> & _). apply RA.ev_const in Hw. subst w.
           inv Hv; kill_lv.
           match goal with Et : eval_expr _ _ _ _ (Etempvar _ _) _, Hc : sem_cast _ _ _ _ = Some _ |- _ =>
             apply RA.ev_temp in Et; rewrite (Hle1 MU._mtx ltac:(RA.neq) ltac:(RA.neq)) in Et;
             cbn in Et; injection Et as <-; apply RA.cast_ptr_id in Hc; subst end.
           destruct (mloop ge MU._dest MU._i ltac:(RA.neq) 4 5 1 0 z0 B ltac:(lia) (conj Hz1 Hz2)
                       _ _ _ _ _ _ _ Hl2 0) as (_ & _ & U2).
           ++ apply PTree.gss.
           ++ lia.
           ++ unfold dpos. rewrite PTree.gso by RA.neq. rewrite PTree.gss. do 3 f_equal. lia.
           ++ exact (Mem.unchanged_on_trans _ _ _ _ U1 U2).
        -- apply RA.seq_inv in He as [(tg & leg & mg & th & Hg & Hh) | (Hg & Hne')].
           ++ apply RA.set_inv in Hh as (_ & _ & _ & _ & E). contradiction.
           ++ apply RA.set_inv in Hg as (_ & _ & _ & _ & E). contradiction.
    + apply RA.seq_inv in Ha as [(tg & leg & mg & th & Hg & Hh) | (Hg & Hne')].
      * apply RA.set_inv in Hh as (_ & _ & _ & _ & E). contradiction.
      * apply RA.set_inv in Hg as (_ & _ & _ & _ & E). contradiction.
  - apply RA.seq_inv in H1 as [(ta & lea & ma & tb & Ha & Hl) | (Ha & Hne')].
    + (* the loop ends normally *)
      apply RA.seq_inv in Ha as [(tc & lec & mc & td & Hc & Hd) | (Hc & Hne'')];
        [ | apply RA.set_inv in Hc as (_ & _ & _ & _ & E); contradiction ].
      apply RA.set_inv in Hc as (v & Hv & -> & -> & _).
      apply RA.set_inv in Hd as (w & Hw & -> & -> & _). apply RA.ev_const in Hw. subst w.
      inv Hv; kill_lv.
      match goal with Ec : eval_expr _ _ _ _ (Ecast _ _) _, E2 : eval_expr _ _ _ _ (Econst_int _ _) _,
                      Hs : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ =>
        inv Ec; kill_lv; apply RA.ev_const in E2; subst end.
      match goal with Et : eval_expr _ _ _ _ (Etempvar _ _) _, Hc : sem_cast _ _ _ _ = Some _ |- _ =>
        apply RA.ev_temp in Et; cbn in Et; injection Et as <-; apply RA.cast_ptr_id in Hc; subst end.
      match goal with Hs : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ =>
        cbn [typeof] in Hs; rewrite add_pf in Hs; injection Hs as <- end.
      destruct (mloop ge MU._dest MU._i ltac:(RA.neq) 14 1 0 1 z0 B ltac:(lia) (conj Hz1 Hz2)
                  _ _ _ _ _ _ _ Hl 0) as (Ho1 & _ & _).
      * reflexivity.
      * lia.
      * unfold dpos. rewrite PTree.gso by RA.neq. rewrite PTree.gss. f_equal. f_equal. unfold Ptrofs.of_ints. rewrite signed_small by lia.
        rewrite ObjSelf.ptrofs_mul_repr, ObjSelf.ptrofs_add_repr. f_equal; lia.
      * contradiction.
    + apply RA.seq_inv in Ha as [(tg & leg & mg & th & Hg & Hh) | (Hg & Hne'')].
      * apply RA.set_inv in Hh as (_ & _ & _ & _ & E). contradiction.
      * apply RA.set_inv in Hg as (_ & _ & _ & _ & E). contradiction.
Qed.

(* ---------------------------------------------------------------------- *)
(* 5. allocate_object (spawn_object.c:121-182).                            *)
(* ---------------------------------------------------------------------- *)
Definition OT : type := Tstruct SO._Object noattr.
Definition CE : composite_env := prog_comp_env SO.prog.
Definition RAW_ARR : expr :=
  Efield (Efield (Ederef (Etempvar SO._obj (tptr OT)) OT) SO._rawData (Tunion SO.__764 noattr))
    SO._asS32 (tarray tint 80).
Definition TR_OFF : Z := 540.   (* Object.transform *)
Definition RAW_D : Z := 136.    (* Object.rawData *)

(* the body after the allocation and its NULL check; the part after the
   zeroing loop; the part after mtxf_identity *)
Definition AR1 : statement := sdrop 2 (fn_body SO.f_allocate_object).
Definition AR2 : statement := sdrop 6 AR1.
Definition AR3 : statement := sdrop 17 AR2.

(* THE FRESH SLOT'S CELLS after allocate_object: every constant the body
   stores (activeFlags = ACTIVE_FLAG_ACTIVE | ACTIVE_FLAG_UNK8, parentObj =
   the slot itself, prevObj / platform / collisionData / respawnInfo /
   throwMatrix = NULL, the hitbox fields, bhvStackIndex = 0, rawData all
   zero but for the five words the body sets after the loop, ...), as
   computed by the walker over the real statements *)
Definition alloc_facts : list fact :=
  ffacts CE SO._obj 9 AR3
    (kill TR_OFF 64 (ffacts CE SO._obj 16 AR2
       (zeros RAW_D 80 ++ kill RAW_D 320 (ffacts CE SO._obj 5 AR1 [])))).

Definition ZLOOP : statement :=
  Ssequence (Sset SO._i (Econst_int (Int.repr 0) tint)) (Sloop (ZB SO._i RAW_ARR) (ZI SO._i)).
Definition MCALL : statement :=
  Scall None (Evar SO._mtxf_identity (Tfunction [tptr (tarray tfloat 4)] tvoid cc_default))
    [Efield (Ederef (Etempvar SO._obj (tptr OT)) OT) SO._transform (tarray (tarray tfloat 4) 4)].

(* the real body, cut at the two hand-walked statements *)
Lemma AR1_split : sdrop 5 AR1 = Ssequence ZLOOP AR2.
Proof. vm_compute. reflexivity. Qed.
Lemma AR2_split : sdrop 16 AR2 = Ssequence MCALL AR3.
Proof. vm_compute. reflexivity. Qed.
Lemma AR3_ret : sdrop 9 AR3 = Sreturn (Some (Etempvar SO._obj (tptr OT))).
Proof. vm_compute. reflexivity. Qed.

Lemma ev_gaddr : forall (ge : genv) le m id ty ty' v b,
  eval_expr ge empty_env le m (Eaddrof (Evar id ty) ty') v -> Genv.find_symbol ge id = Some b ->
  v = Vptr b Ptrofs.zero.
Proof.
  intros ge le m id ty ty' v b H Hs. inv H; [ | match goal with Hl : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hl end ].
  match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end.
  - match goal with He : empty_env ! _ = Some _ |- _ => rewrite PTree.gempty in He; discriminate He end.
  - congruence.
Qed.

Lemma sc_arr : forall b o t n t' m, sem_cast (Vptr b o) (tarray t n) (tptr t') m = Some (Vptr b o).
Proof. reflexivity. Qed.

Lemma cmp_eq_null : forall (ge : genv) m T b o vc bc,
  sem_binary_operation ge Oeq (Vptr b o) (tptr T) (Vint (Int.repr 0)) (tptr tvoid) m = Some vc ->
  bool_val vc tint m = Some bc -> bc = false.
Proof.
  intros ge m T b o vc bc H Hb. cbn in H.
  unfold cmp_ptr in H. cbn in H. repeat match type of H with context [if ?c then _ else _] => destruct c end; cbn in H; try discriminate H.
  injection H as <-. cbn in Hb. injection Hb as <-. reflexivity.
Qed.

Section ALLOC.
  Variable ge : genv.
  Hypothesis Hce : forall id co, (prog_comp_env GN.prog) ! id = Some co -> (genv_cenv ge) ! id = Some co.
  Hypothesis Hcs : forall id co, (prog_comp_env SO.prog) ! id = Some co -> (genv_cenv ge) ! id = Some co.
  Variables pool la fl bpg gB : block.
  Hypothesis Hpl : pool <> la.
  Hypothesis Hpf : pool <> fl.
  Hypothesis Hlf : la <> fl.
  Hypothesis Hpb : pool <> bpg.
  Hypothesis Hlb : la <> bpg.
  Hypothesis Hfb : fl <> bpg.
  Hypothesis Hpool : Genv.find_symbol ge ObjSelf.POOL = Some pool.
  Hypothesis HgB : Genv.find_symbol ge ObjSelf.GCO = Some gB.
  Hypothesis Hfl : Genv.find_symbol ge SO._gFreeObjectList = Some fl.
  Hypothesis Hbpg : Genv.find_symbol ge SO._gObjParentGraphNode = Some bpg.
  Hypothesis Hgrc : forall b fd, Genv.find_symbol ge SO._geo_remove_child = Some b ->
    Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd -> fd = Internal GN.f_geo_remove_child.
  Hypothesis Hgac : forall b fd, Genv.find_symbol ge SO._geo_add_child = Some b ->
    Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd -> fd = Internal GN.f_geo_add_child.
  Hypothesis Htao : forall b fd, Genv.find_symbol ge SO._try_allocate_object = Some b ->
    Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd -> fd = Internal SO.f_try_allocate_object.
  Hypothesis Hmid : forall b fd, Genv.find_symbol ge SO._mtxf_identity = Some b ->
    Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd -> fd = Internal MU.f_mtxf_identity.

  Lemma KP_rcell : forall k, 0 <= k < NSLOT ->
    forall j i, 0 <= j < NSLOT -> j * OSZ + O_NEXT <= i < j * OSZ + O_PREV + 4 -> KP pool (k * OSZ) pool i.
  Proof.
    intros k Hk j i Hj Hi. unfold KP, O_NEXT, O_PREV, OSZ in *.
    destruct (Z.eq_dec j k) as [-> | Hne]; [ right; right; right; right; lia | ].
    right. destruct (Z_lt_le_dec j k); [ left; nia | right; left; nia ].
  Qed.

  Lemma KP_gcell : forall k, 0 <= k < NSLOT -> forall b z, GCELL pool bpg b z -> KP pool (k * OSZ) b z.
  Proof.
    intros k Hk b z [(-> & j & Hj & Hz) | (-> & Hz)].
    - unfold KP, G_PREV, G_CHILD, OSZ in *.
      destruct (Z.eq_dec j k) as [-> | Hne]; [ right; right; right; left; lia | ].
      right. destruct (Z_lt_le_dec j k); [ left; nia | right; left; nia ].
    - left. intros E. apply Hpb. symmetry. exact E.
  Qed.

  Theorem alloc_ok : forall m rs fs i t m' vr,
    rings m pool la = Some rs -> free_list m pool fl = Some fs -> NoDup (concat rs ++ fs) ->
    gfx_at pool bpg m -> (i < NLIST)%nat ->
    eval_funcall function_entry2 ge m (Internal SO.f_allocate_object)
      [Vptr la (Ptrofs.repr (hoff i))] t m' vr ->
    fs = []
    \/ (exists k fs', fs = k :: fs' /\ 0 <= k < NSLOT /\ vr = slot_v pool k
        /\ rings m' pool la = Some (upd rs i (nth i rs [] ++ [k])) /\ free_list m' pool fl = Some fs'
        /\ gfx_at pool bpg m'
        /\ Mem.unchanged_on (fun b z => AKEEP pool la fl bpg b z /\ KP pool (k * OSZ) b z) m m'
        /\ facts m' pool (k * OSZ) (slot_v pool k) alloc_facts).
  Proof.
    intros m rs fs i t m' vr Hr Hfs Hnd Hg Hi H.
    destruct (fcall_inv0 ge SO.f_allocate_object m _ t m' vr eq_refl H) as (le & le' & out & Hb & Hx & Hov).
    cbn in Hb. injection Hb as <-.
    cbn [fn_body SO.f_allocate_object] in Hx.
    apply RA.seq_inv in Hx as [(t1 & le1 & m1 & t2 & H1 & H2) | (H1 & Hne)].
    2:{ (* the call + set never leave abnormally *)
      apply RA.seq_inv in H1 as [(ta & lea & ma & tb & Ha & Hb) | (Ha & Hne')].
      - apply RA.set_inv in Hb as (_ & _ & _ & _ & E). contradiction.
      - apply RA.call_inv in Ha as (_ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & E). contradiction. }
    apply RA.seq_inv in H1 as [(ta & lea & ma & tb & Ha & Hb) | (Ha & Hne')].
    2:{ apply RA.call_inv in Ha as (_ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & E). contradiction. }
    (* obj = try_allocate_object(objList, &gFreeObjectList) *)
    apply RA.call_inv in Ha as (tyargs & tyres & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hc & -> & _).
    cbn in Hcf. injection Hcf as <- <- <-.
    match type of Evf with eval_expr _ _ _ _ (Evar _ ?ty) _ =>
      destruct (RA.ev_fun ge empty_env _ _ _ ty vf (PTree.gempty _ _) eq_refl Evf) as (bf & Hsf & ->) end.
    rewrite (Htao bf fd Hsf Hff) in Hc.
    destruct (ObjLoop.exl2 _ _ _ _ _ _ _ _ Eal) as (ta1 & tb1 & u1 & u2 & x1 & x2 & Ea2 & -> & Eva & Cca & Evb & Ccb).
    injection Ea2 as <- <-.
    apply RA.ev_temp in Eva. cbn in Eva. injection Eva as <-.
    cbn [typeof] in Cca. apply RA.cast_ptr_id in Cca. subst x1.
    rewrite (ev_gaddr _ _ _ _ _ _ _ _ Evb Hfl) in Ccb. cbn [typeof] in Ccb. apply RA.cast_ptr_id in Ccb. subst x2.
    destruct (try_alloc_ok ge Hce Hcs pool la fl bpg Hpl Hpf Hlf Hpb Hlb Hfb Hbpg Hgrc Hgac
                m rs fs i _ ma vres Hr Hfs Hnd Hg Hi Hc) as [(E & _) | (k & fs' & E & Ev & R1 & F1 & G1 & U1)].
    { left. exact E. }
    right. exists k, fs'.
    assert (Hk : 0 <= k < NSLOT).
    { apply (free_list_iff pool m fl fs) in Hfs as (_ & Hch & _). rewrite E in Hch. exact (proj1 Hch). }
    subst vres.
    apply RA.set_inv in Hb as (v & Hv & -> & -> & _).
    apply RA.ev_temp in Hv. cbn [set_opttemp] in Hv. rewrite PTree.gss in Hv. injection Hv as <-.
    (* if (obj == NULL): obj is a slot *)
    apply RA.seq_inv in H2 as [(tc & lec & mc & td & Hif & HR) | (Hif & Hne)].
    2:{ apply RA.if_inv in Hif as (vc & bc & Hcd & Hbc & Hif).
        inv Hcd; kill_lv.
        match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _, Hz : eval_expr _ _ _ _ (Ecast _ _) _,
                        Hs : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ =>
          apply RA.ev_temp in Ht; rewrite PTree.gss in Ht; injection Ht as <-;
          inv Hz; kill_lv;
          match goal with Hk0 : eval_expr _ _ _ _ (Econst_int _ _) _, Hc0 : sem_cast _ _ _ _ = Some _ |- _ =>
            apply RA.ev_const in Hk0; subst; cbn in Hc0; injection Hc0 as <- end;
          cbn [typeof] in Hs, Hbc; unfold slot_v in Hs; rewrite (cmp_eq_null _ _ _ _ _ _ _ Hs Hbc) in Hif end.
        apply RA.skip_inv in Hif as (_ & _ & E'). contradiction. }
    apply RA.if_inv in Hif as (vc & bc & Hcd & Hbc & Hif).
    inv Hcd; kill_lv.
    match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _, Hz : eval_expr _ _ _ _ (Ecast _ _) _,
                    Hs : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ =>
      apply RA.ev_temp in Ht; rewrite PTree.gss in Ht; injection Ht as <-;
      inv Hz; kill_lv;
      match goal with Hk0 : eval_expr _ _ _ _ (Econst_int _ _) _, Hc0 : sem_cast _ _ _ _ = Some _ |- _ =>
        apply RA.ev_const in Hk0; subst; cbn in Hc0; injection Hc0 as <- end;
      cbn [typeof] in Hs, Hbc; unfold slot_v in Hs; rewrite (cmp_eq_null _ _ _ _ _ _ _ Hs Hbc) in Hif end.
    apply RA.skip_inv in Hif as (-> & -> & _).
    (* the stores *)
    set (le0 := PTree.set SO._obj (slot_v pool k) _) in HR.
    match type of HR with exec_stmt ?fe ?g ?e ?l ?mm _ ?tt ?l' ?mm' ?oo =>
      change (exec_stmt fe g e l mm AR1 tt l' mm' oo) in HR end.
    assert (Hx0 : le0 ! SO._obj = Some (slot_v pool k)) by (unfold le0; apply PTree.gss).
    assert (Hce' : ObjSelf.cext ge CE) by exact Hcs.
    destruct (fxl_sound ge pool gB Hpool HgB CE Hce' SO._obj k Hk 5 AR1 [] _ _
                (fxl_ok CE SO._obj 5 AR1 [] ltac:(vm_compute; discriminate)) _ _ _ _ _ _ HR Hx0 (facts_nil _ _ _ _))
      as (le2 & m2 & t3 & H3 & Hx2 & HF2 & U2).
    rewrite AR1_split in H3.
    apply RA.seq_inv in H3 as [(t4 & le4 & m4 & t5 & HL & H5) | (HL & Hne)].
    2:{ destruct (zloop ge pool gB Hpool HgB CE Hce' SO._obj k Hk SO._i ltac:(RA.neq) RAW_ARR RAW_D
                    ltac:(vm_compute; reflexivity) eq_refl ltac:(vm_compute; reflexivity) _ _ _ _ _ _ _ HL Hx2 HF2)
          as (E' & _). contradiction. }
    destruct (zloop ge pool gB Hpool HgB CE Hce' SO._obj k Hk SO._i ltac:(RA.neq) RAW_ARR RAW_D
                ltac:(vm_compute; reflexivity) eq_refl ltac:(vm_compute; reflexivity) _ _ _ _ _ _ _ HL Hx2 HF2)
      as (_ & Hx4 & HF4 & U4).
    destruct (fxl_sound ge pool gB Hpool HgB CE Hce' SO._obj k Hk 16 AR2 (zeros RAW_D 80 ++ kill RAW_D 320 (ffacts CE SO._obj 5 AR1 [])) _ _
                (fxl_ok CE SO._obj 16 AR2 (zeros RAW_D 80 ++ kill RAW_D 320 (ffacts CE SO._obj 5 AR1 [])) ltac:(vm_compute; discriminate)) _ _ _ _ _ _ H5 Hx4 HF4)
      as (le6 & m6 & t6 & H6 & Hx6 & HF6 & U6).
    rewrite AR2_split in H6.
    (* mtxf_identity(obj->transform) *)
    apply RA.seq_inv in H6 as [(t7 & le7 & m7 & t8 & HC & H8) | (HC & Hne)];
      [ | apply RA.call_inv in HC as (_ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & E'); contradiction ].
    unfold MCALL in HC.
    apply RA.call_inv in HC as (tyargs2 & tyres2 & cc2 & vf2 & vargs2 & fd2 & vres2 & Hcf2 & Evf2 & Eal2 & Hff2 & _ & Hc7 & -> & _).
    cbn in Hcf2. injection Hcf2 as <- <- <-.
    match type of Evf2 with eval_expr _ _ _ _ (Evar _ ?ty) _ =>
      destruct (RA.ev_fun ge empty_env _ _ _ ty vf2 (PTree.gempty _ _) eq_refl Evf2) as (bf7 & Hsf7 & ->) end.
    rewrite (Hmid bf7 fd2 Hsf7 Hff2) in Hc7.
    destruct (ObjLoop.exl1 _ _ _ _ _ _ _ Eal2) as (ty1 & u & w & Ety & -> & Eu & Cu).
    injection Ety as <-.
    assert (Hu : u = Vptr pool (Ptrofs.add (Ptrofs.repr (k * OSZ)) (Ptrofs.repr TR_OFF))).
    { inv Eu.
      match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => rename Hl into Hl0 end.
      match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => rename Hd into Hd0 end.
      destruct (lad_at ge pool gB Hpool HgB CE Hce' SO._obj k _ _ _ _ _ _ TR_OFF Hx6 Hl0
                  ltac:(vm_compute; reflexivity)) as (-> & -> & ->).
      inv Hd0; cbn in *; try discriminate; reflexivity. }
    subst u. cbn [typeof] in Cu. rewrite sc_arr in Cu. injection Cu as <-.
    rewrite ObjSelf.ptrofs_add_repr in Hc7.
    pose proof (mtx_ok ge m6 pool (k * OSZ + TR_OFF) _ m7 _ ltac:(unfold TR_OFF, OSZ; lia)
                  ltac:(rewrite maxu32; unfold TR_OFF, OSZ, NSLOT in *; lia) Hc7) as U7.
    assert (HF7 : facts m7 pool (k * OSZ) (slot_v pool k) (kill TR_OFF 64 (ffacts CE SO._obj 16 AR2 (zeros RAW_D 80 ++ kill RAW_D 320 (ffacts CE SO._obj 5 AR1 []))))).
    { apply (facts_kill_unch m6 m7 pool (k * OSZ) _ _ TR_OFF 64); [ | exact HF6 ].
      apply (Mem.unchanged_on_implies _ _ _ _ U7). intros b z Hz _. exact Hz. }
    assert (U7' : Mem.unchanged_on (KP pool (k * OSZ)) m6 m7).
    { apply (Mem.unchanged_on_implies _ _ _ _ U7). intros b z Hz _. unfold KP, MF, TR_OFF, OSZ in *.
      destruct Hz as [Hz | [Hz | [Hz | [Hz | Hz]]]]; [ left; exact Hz | right; left; lia | right; right; lia
        | right; left; lia | right; left; lia ]. }
    destruct (fxl_sound ge pool gB Hpool HgB CE Hce' SO._obj k Hk 9 AR3 (kill TR_OFF 64 (ffacts CE SO._obj 16 AR2 (zeros RAW_D 80 ++ kill RAW_D 320 (ffacts CE SO._obj 5 AR1 [])))) _ _
                (fxl_ok CE SO._obj 9 AR3 (kill TR_OFF 64 (ffacts CE SO._obj 16 AR2 (zeros RAW_D 80 ++ kill RAW_D 320 (ffacts CE SO._obj 5 AR1 [])))) ltac:(vm_compute; discriminate)) _ _ _ _ _ _ H8 Hx6 HF7)
      as (le9 & m9 & t9 & H9 & Hx9 & HF9 & U9).
    rewrite AR3_ret in H9.
    apply RA.ret_inv in H9 as (-> & v9 & Ev9 & ->).
    apply RA.ev_temp in Ev9. rewrite Hx9 in Ev9. injection Ev9 as <-.
    cbn [outcome_result_value fn_return SO.f_allocate_object typeof] in Hov. destruct Hov as (_ & Hov).
    apply RA.cast_ptr_id in Hov. subst vr.
    assert (U : Mem.unchanged_on (KP pool (k * OSZ)) ma m9).
    { refine (Mem.unchanged_on_trans _ _ _ _ U2 (Mem.unchanged_on_trans _ _ _ _ U4
                (Mem.unchanged_on_trans _ _ _ _ U6 (Mem.unchanged_on_trans _ _ _ _ U7' U9)))). }
    refine (conj eq_refl (conj Hk (conj eq_refl (conj _ (conj _ (conj _ (conj _ _))))))).
    - exact (rings_keep pool la (KP pool (k * OSZ)) (KP_rcell k Hk) (fun i => or_introl (not_eq_sym Hpl))
               ma m9 _ Hpl U R1).
    - exact (free_keep pool fl (KP pool (k * OSZ)) (KP_rcell k Hk) (fun i => or_introl (not_eq_sym Hpf))
               ma m9 _ U F1).
    - exact (gfx_keep pool bpg (KP pool (k * OSZ)) ma m9 U (KP_gcell k Hk) G1).
    - exact (Mem.unchanged_on_trans _ _ _ _ (Mem.unchanged_on_implies _ _ _ _ U1 (fun b z Hz _ => proj1 Hz))
               (Mem.unchanged_on_implies _ _ _ _ U (fun b z Hz _ => proj2 Hz))).
    - exact HF9.
  Qed.
End ALLOC.

(* ---------------------------------------------------------------------- *)
(* 6. On the real linked program.                                           *)
(* ---------------------------------------------------------------------- *)
Lemma dm_gco : exists gd, (prog_defmap SO.prog) ! SO._gCurrentObject = Some gd.
Proof.
  destruct ((prog_defmap SO.prog) ! SO._gCurrentObject) as [gd|] eqn:E;
    [ exists gd; reflexivity | vm_compute in E; discriminate E ].
Qed.

Section LINKED.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Notation G := (lp_ge lp).

  (* THE ALLOCATOR ON THE REAL PROGRAM.  Premises: the four symbols and
     obj_w's ow_rings / ow_free / ow_part (NoDup) / ow_gfx; i is the list
     index create_object passes (&gObjectLists[i]). *)
  Theorem alloc_real : forall pool la fl bpg,
    Genv.find_symbol G object_list_processor._gObjectPool = Some pool ->
    Genv.find_symbol G object_list_processor._gObjectListArray = Some la ->
    Genv.find_symbol G object_list_processor._gFreeObjectList = Some fl ->
    Genv.find_symbol G area._gObjParentGraphNode = Some bpg ->
    forall m rs fs i t m' vr,
    rings m pool la = Some rs -> free_list m pool fl = Some fs -> NoDup (concat rs ++ fs) ->
    gfx_ok G pool m -> (i < NLIST)%nat ->
    eval_funcall function_entry2 G m (Internal SO.f_allocate_object)
      [Vptr la (Ptrofs.repr (hoff i))] t m' vr ->
    (* EMPTY FREE LIST: the find_unimportant_object / unload_object branch
       (or the endless loop) -- named, nothing claimed *)
    fs = []
    \/ (exists k fs', fs = k :: fs' /\ 0 <= k < NSLOT /\ vr = slot_v pool k
        /\ rings m' pool la = Some (upd rs i (nth i rs [] ++ [k])) /\ free_list m' pool fl = Some fs'
        /\ gfx_ok G pool m'
        /\ Mem.unchanged_on (fun b z => AKEEP pool la fl bpg b z /\ KP pool (k * OSZ) b z) m m'
        /\ facts m' pool (k * OSZ) (slot_v pool k) alloc_facts).
  Proof.
    intros pool la fl bpg Hp Hl Hf Hb m rs fs i t m' vr Hr Hfl Hnd Hg Hi H.
    assert (Hpl : pool <> la) by (apply (sym_ne lp _ _ _ _ Hp Hl); RA.neq).
    assert (Hpf : pool <> fl) by (apply (sym_ne lp _ _ _ _ Hp Hf); RA.neq).
    assert (Hlf : la <> fl) by (apply (sym_ne lp _ _ _ _ Hl Hf); RA.neq).
    assert (Hpb : pool <> bpg) by (apply (sym_ne lp _ _ _ _ Hp Hb); RA.neq).
    assert (Hlb : la <> bpg) by (apply (sym_ne lp _ _ _ _ Hl Hb); RA.neq).
    assert (Hfb : fl <> bpg) by (apply (sym_ne lp _ _ _ _ Hf Hb); RA.neq).
    destruct dm_gco as (gd & Hdm).
    destruct (linkorder_resolves_symbol lp SO.prog _ gd (linked12_LO_spawn_object lp H12) Hdm) as (gB & HgB).
    pose proof (gfx_at_iff pool bpg Hpb G m Hb) as Ig.
    destruct (alloc_ok G (cenv_of lp _ (linked12_LO_graph_node lp H12))
                (cenv_of lp _ (linked12_LO_spawn_object lp H12))
                pool la fl bpg gB Hpl Hpf Hlf Hpb Hlb Hfb Hp HgB Hf Hb
                (fun b fd => fun_res lp _ _ _ (linked12_LO_graph_node lp H12) dm_grc b fd)
                (fun b fd => fun_res lp _ _ _ (linked12_LO_graph_node lp H12) dm_gac b fd)
                (tao_fun lp H12)
                (fun b fd => fun_res lp _ _ _ (linked12_LO_math lp H12) dm_mid b fd)
                m rs fs i t m' vr Hr Hfl Hnd (proj1 Ig Hg) Hi H)
      as [E | (k & fs' & E & Hk & Ev & R & F & Gx & U & HF)].
    - left. exact E.
    - right. exists k, fs'.
      refine (conj E (conj Hk (conj Ev (conj R (conj F (conj _ (conj U HF))))))).
      exact (proj2 (gfx_at_iff pool bpg Hpb G m' Hb) Gx).
  Qed.
End LINKED.
