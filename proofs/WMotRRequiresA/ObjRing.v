(* spine (via BhvStep's allocate rows): OBJECTS -- the RING ACCESSORS.
   ObjWorld's object lists are computed walks (ring_from / free_from, with
   fuel); this file gives them a declarative face, so list surgery (the
   allocator's tail insert, the unloader's unlink + free push) is reasoned
   about cell by cell instead of by re-running the walk.
     - chain m E prev l : the nodes l are pool slots, each one's header.prev
       holds its predecessor (prev for the first) and header.next its
       successor (E after the last);
     - ring_i_iff     : ObjWorld.ring_i is exactly a chain closed at the
       list head (head.next = the first node, head.prev = the last);
     - free_list_iff  : ObjWorld.free_list is exactly a next-chain ending in
       NULL;
     - rings_iff      : ObjWorld.rings is the 13 ring_i's;
     - chain_app / chain_ext / fchain_ext: append a node; keep a chain
       when its cells are kept.
   Shared with the deallocate direction (Hseg).  Statements only mention
   ObjWorld's definitions, so ObjWorld can later absorb this file. *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib AST Integers Values Memory.
From SM64.Proofs.WMotRRequiresA Require Import ObjWorld.

Import ListNotations.
Local Open Scope Z_scope.

Lemma maxu32 : Ptrofs.max_unsigned = 4294967295.
Proof. reflexivity. Qed.

Section RING.
  Variable pool : block.

  Definition sv (k : Z) : val := slot_v pool k.

  Definition next_of (E : val) (l : list Z) : val :=
    match l with [] => E | k :: _ => sv k end.
  Fixpoint last_of (d : val) (l : list Z) : val :=
    match l with [] => d | k :: l' => last_of (sv k) l' end.

  Fixpoint chain (m : mem) (E prev : val) (l : list Z) : Prop :=
    match l with
    | [] => True
    | k :: l' => 0 <= k < NSLOT /\ ld32 m pool (k * OSZ + O_PREV) = Some prev
                 /\ ld32 m pool (k * OSZ + O_NEXT) = Some (next_of E l') /\ chain m E (sv k) l'
    end.

  Definition fnext (l : list Z) : val := match l with [] => Vnullptr | k :: _ => sv k end.

  Fixpoint fchain (m : mem) (l : list Z) : Prop :=
    match l with
    | [] => True
    | k :: l' => 0 <= k < NSLOT /\ ld32 m pool (k * OSZ + O_NEXT) = Some (fnext l') /\ fchain m l'
    end.

  (* ---- slot pointers ---- *)
  Lemma slot_off_range : forall k, 0 <= k < NSLOT -> 0 <= k * OSZ <= Ptrofs.max_unsigned.
  Proof. intros k Hk. rewrite maxu32. unfold NSLOT, OSZ in *. lia. Qed.

  Lemma slot_of_sv : forall k, 0 <= k < NSLOT -> slot_of (Ptrofs.unsigned (Ptrofs.repr (k * OSZ))) = Some k.
  Proof.
    intros k Hk. rewrite Ptrofs.unsigned_repr by (apply slot_off_range; exact Hk).
    unfold slot_of. unfold NSLOT, OSZ in *.
    rewrite Z.mod_mul by lia. rewrite Z.div_mul by lia.
    replace ((0 <=? k * 608) && (k * 608 <? 240 * 608) && (0 =? 0)) with true; [ reflexivity | ].
    symmetry. apply andb_true_iff. split; [ apply andb_true_iff; split | ];
      [ apply Z.leb_le; lia | apply Z.ltb_lt; lia | reflexivity ].
  Qed.

  Lemma slot_of_inv : forall o k, slot_of o = Some k -> o = k * OSZ /\ 0 <= k < NSLOT.
  Proof.
    intros o k H. unfold slot_of in H.
    destruct ((0 <=? o) && (o <? NSLOT * OSZ) && (o mod OSZ =? 0)) eqn:E; [ | discriminate H ].
    injection H as <-. apply andb_true_iff in E as [E E3]. apply andb_true_iff in E as [E1 E2].
    apply Z.leb_le in E1. apply Z.ltb_lt in E2. apply Z.eqb_eq in E3.
    unfold NSLOT, OSZ in *.
    pose proof (Z.div_mod o 608 ltac:(lia)) as Hd. rewrite E3 in Hd.
    split; [ lia | ].
    split; [ apply Z.div_pos; lia | apply Z.div_lt_upper_bound; lia ].
  Qed.

  Lemma ptr_slot : forall o k, Ptrofs.unsigned o = k * OSZ -> Vptr pool o = sv k.
  Proof. intros o k H. unfold sv, slot_v. rewrite <- H, Ptrofs.repr_unsigned. reflexivity. Qed.

  Lemma veqb_refl : forall v, veqb v v = true.
  Proof. intros v. unfold veqb. destruct (Val.eq v v); [ reflexivity | congruence ]. Qed.
  Lemma veqb_eq : forall v w, veqb v w = true -> v = w.
  Proof. intros v w H. unfold veqb in H. destruct (Val.eq v w); [ exact e | discriminate H ]. Qed.

  Lemma next_of_app : forall E l k, next_of E (l ++ [k]) = next_of (sv k) l.
  Proof. intros E [|a l] k; reflexivity. Qed.
  Lemma last_of_app : forall d l k, last_of d (l ++ [k]) = sv k.
  Proof. intros d l. revert d. induction l as [|a l IH]; intros d k; [ reflexivity | exact (IH (sv a) k) ]. Qed.

  (* ---- rings ---- *)
  Section HEAD.
    Variable la : block.
    Hypothesis Hpl : pool <> la.
    Variable ho : Z.
    Hypothesis Hho : 0 <= ho <= Ptrofs.max_unsigned.
    Let H := Vptr la (Ptrofs.repr ho).

    Lemma walk_sound : forall m n prev cur l, (exists b o, prev = Vptr b o) ->
      ring_from m pool la ho prev cur n = Some l ->
      cur = next_of H l /\ chain m H prev l /\ ld32 m la (ho + O_PREV) = Some (last_of prev l)
      /\ (List.length l < n)%nat.
    Proof.
      intros m n. induction n as [|n IH]; intros prev cur l Hpv Hw; [ discriminate Hw | ].
      cbn [ring_from] in Hw. destruct cur as [| | | | | b o]; try discriminate Hw.
      destruct (eq_block b la) as [-> | Hne]; cbn [proj_sumbool andb] in Hw.
      - destruct (Z.eqb (Ptrofs.unsigned o) ho) eqn:Eo.
        + apply Z.eqb_eq in Eo.
          destruct (veqb (match ld32 m la (ho + O_PREV) with Some v => v | None => Vundef end) prev) eqn:Ev;
            [ | discriminate Hw ].
          injection Hw as <-. apply veqb_eq in Ev.
          split; [ unfold H; rewrite <- Eo, Ptrofs.repr_unsigned; reflexivity | ].
          split; [ exact I | split; [ | cbn; lia ] ].
          destruct (ld32 m la (ho + O_PREV)) as [v|]; [ subst v; reflexivity | ].
          destruct Hpv as (b0 & o0 & ->). discriminate Ev.
        + exfalso. destruct (eq_block la pool) as [E | Ne0]; [ exact (Hpl (eq_sym E)) | ].
          (* a la pointer that is not the head: the walk fails *)
          cbn [proj_sumbool] in Hw. discriminate Hw.
      - destruct (eq_block b pool) as [-> | Hnp]; cbn [proj_sumbool] in Hw; [ | discriminate Hw ].
        destruct (slot_of (Ptrofs.unsigned o)) as [k|] eqn:Es; [ | discriminate Hw ].
        destruct (ld32 m pool (Ptrofs.unsigned o + O_PREV)) as [p|] eqn:Lp; [ | discriminate Hw ].
        destruct (ld32 m pool (Ptrofs.unsigned o + O_NEXT)) as [nx|] eqn:Ln; [ | discriminate Hw ].
        destruct (veqb p prev) eqn:Ev; [ | discriminate Hw ]. apply veqb_eq in Ev. subst p.
        destruct (ring_from m pool la ho (Vptr pool o) nx n) as [l'|] eqn:Er; [ | discriminate Hw ].
        injection Hw as <-.
        destruct (slot_of_inv _ _ Es) as (Eo & Hk).
        destruct (IH (Vptr pool o) nx l' ltac:(eauto) Er) as (-> & Hc & Hl & Hlen).
        rewrite (ptr_slot o k Eo) in Hc, Hl.
        rewrite Eo in Lp, Ln.
        split; [ exact (ptr_slot o k Eo) | ].
        split; [ exact (conj Hk (conj Lp (conj Ln Hc))) | ].
        split; [ exact Hl | cbn; lia ].
    Qed.

    Lemma walk_complete : forall m l n prev, chain m H prev l ->
      ld32 m la (ho + O_PREV) = Some (last_of prev l) -> (List.length l < n)%nat ->
      ring_from m pool la ho prev (next_of H l) n = Some l.
    Proof.
      intros m l. induction l as [|k l IH]; intros n prev Hc Hl Hn; (destruct n as [|n]; [ cbn in Hn; lia | ]).
      - cbn [ring_from next_of]. unfold H.
        destruct (eq_block la la) as [Eq0 | X]; [ | congruence ]. cbn [proj_sumbool andb].
        rewrite Ptrofs.unsigned_repr by exact Hho. rewrite Z.eqb_refl.
        cbn [last_of] in Hl. rewrite Hl, veqb_refl. reflexivity.
      - destruct Hc as (Hk & Lp & Ln & Hc).
        cbn [ring_from next_of]. unfold sv, slot_v.
        destruct (eq_block pool la) as [E | Ne0]; [ exact (False_ind _ (Hpl E)) | ]. cbn [proj_sumbool andb].
        destruct (eq_block pool pool) as [Eq0 | X]; [ | congruence ]. cbn [proj_sumbool].
        rewrite (slot_of_sv k Hk). rewrite Ptrofs.unsigned_repr by (apply slot_off_range; exact Hk).
        rewrite Lp, Ln, veqb_refl.
        cbn [last_of] in Hl. cbn [List.length] in Hn.
        pose proof (IH n (sv k) Hc Hl ltac:(lia)) as R. unfold sv, slot_v in R. rewrite R. reflexivity.
    Qed.
  End HEAD.

  Definition hoff (i : nat) : Z := Z.of_nat i * NODESZ.

  Lemma hoff_range : forall i, (i < NLIST)%nat -> 0 <= hoff i <= Ptrofs.max_unsigned.
  Proof. intros i Hi. rewrite maxu32. unfold hoff, NLIST, NODESZ in *. lia. Qed.

  (* THE RING ACCESSOR: list i of ObjWorld.rings is l iff the cells encode it *)
  Definition ring_enc (m : mem) (la : block) (i : nat) (l : list Z) : Prop :=
    let H := Vptr la (Ptrofs.repr (hoff i)) in
    ld32 m la (hoff i + O_NEXT) = Some (next_of H l) /\ chain m H H l
    /\ ld32 m la (hoff i + O_PREV) = Some (last_of H l) /\ (List.length l < WFUEL)%nat.

  Lemma ring_i_iff : forall m la i l, pool <> la -> (i < NLIST)%nat ->
    ring_i m pool la i = Some l <-> ring_enc m la i l.
  Proof.
    intros m la i l Hpl Hi. pose proof (hoff_range i Hi) as Hr. unfold ring_i, ring_enc. fold (hoff i).
    split.
    - intros Hw. destruct (ld32 m la (hoff i + O_NEXT)) as [nx|] eqn:Ln; [ | discriminate Hw ].
      destruct (walk_sound la Hpl (hoff i) m WFUEL _ nx l ltac:(eauto) Hw) as (-> & Hc & Hl & Hn).
      auto.
    - intros (Ln & Hc & Hl & Hn). rewrite Ln. exact (walk_complete la Hpl (hoff i) Hr m l WFUEL _ Hc Hl Hn).
  Qed.

  (* ---- the free list ---- *)
  Lemma free_sound : forall m n cur l, free_from m pool cur n = Some l ->
    cur = fnext l /\ fchain m l /\ (List.length l < n)%nat.
  Proof.
    intros m n. induction n as [|n IH]; intros cur l Hw; [ discriminate Hw | ].
    cbn [free_from] in Hw.
    destruct (veqb cur Vnullptr) eqn:En.
    - injection Hw as <-. apply veqb_eq in En. subst cur. split; [ reflexivity | split; [ exact I | cbn; lia ] ].
    - destruct cur as [| | | | | b o]; try discriminate Hw.
      destruct (eq_block b pool) as [-> | Ne0]; cbn [proj_sumbool] in Hw; [ | discriminate Hw ].
      destruct (slot_of (Ptrofs.unsigned o)) as [k|] eqn:Es; [ | discriminate Hw ].
      destruct (ld32 m pool (Ptrofs.unsigned o + O_NEXT)) as [nx|] eqn:Ln; [ | discriminate Hw ].
      destruct (free_from m pool nx n) as [l'|] eqn:Ef; [ | discriminate Hw ].
      injection Hw as <-. destruct (slot_of_inv _ _ Es) as (Eo & Hk).
      destruct (IH nx l' Ef) as (-> & Hc & Hn). rewrite Eo in Ln.
      split; [ exact (ptr_slot o k Eo) | split; [ exact (conj Hk (conj Ln Hc)) | cbn; lia ] ].
  Qed.

  Lemma free_complete : forall m l n, fchain m l -> (List.length l < n)%nat ->
    free_from m pool (fnext l) n = Some l.
  Proof.
    intros m l. induction l as [|k l IH]; intros n Hc Hn; (destruct n as [|n]; [ cbn in Hn; lia | ]).
    - cbn [free_from fnext]. rewrite veqb_refl. reflexivity.
    - destruct Hc as (Hk & Ln & Hc). cbn [free_from fnext]. unfold sv, slot_v.
      replace (veqb (Vptr pool (Ptrofs.repr (k * OSZ))) Vnullptr) with false by reflexivity.
      destruct (eq_block pool pool) as [Eq0 | X]; [ | congruence ]. cbn [proj_sumbool].
      rewrite (slot_of_sv k Hk). rewrite Ptrofs.unsigned_repr by (apply slot_off_range; exact Hk).
      rewrite Ln. cbn [List.length] in Hn. rewrite (IH n Hc ltac:(lia)). reflexivity.
  Qed.

  (* THE FREE-LIST ACCESSOR *)
  Lemma free_list_iff : forall m fl l,
    free_list m pool fl = Some l <->
    ld32 m fl O_NEXT = Some (fnext l) /\ fchain m l /\ (List.length l < WFUEL)%nat.
  Proof.
    intros m fl l. unfold free_list. split.
    - intros Hw. destruct (ld32 m fl O_NEXT) as [nx|] eqn:Ln; [ | discriminate Hw ].
      destruct (free_sound m WFUEL nx l Hw) as (-> & Hc & Hn). auto.
    - intros (Ln & Hc & Hn). rewrite Ln. exact (free_complete m l WFUEL Hc Hn).
  Qed.

  (* ---- the 13 rings ---- *)
  Lemma all_some_nth : forall {A} (l : list (option A)) r, all_some l = Some r ->
    List.length r = List.length l /\ forall i d, (i < List.length l)%nat -> nth i l None = Some (nth i r d).
  Proof.
    intros A l. induction l as [|x l IH]; intros r H; cbn in H.
    - injection H as <-. split; [ reflexivity | intros i d Hi; cbn in Hi; lia ].
    - destruct x as [a|]; [ | discriminate H ].
      destruct (all_some l) as [r'|] eqn:E; [ | discriminate H ]. injection H as <-.
      destruct (IH r' eq_refl) as (Hl & Hn). split; [ cbn; rewrite Hl; reflexivity | ].
      intros [|i] d Hi; [ reflexivity | cbn in Hi |- *; apply Hn; lia ].
  Qed.

  Lemma all_some_of_nth : forall {A} (l : list (option A)) r d, List.length r = List.length l ->
    (forall i, (i < List.length l)%nat -> nth i l None = Some (nth i r d)) -> all_some l = Some r.
  Proof.
    intros A l. induction l as [|x l IH]; intros r d Hl Hn.
    - destruct r; [ reflexivity | discriminate Hl ].
    - destruct r as [|a r]; [ discriminate Hl | ]. cbn in Hl. injection Hl as Hl.
      pose proof (Hn 0%nat ltac:(cbn; lia)) as H0. cbn in H0. subst x. cbn.
      rewrite (IH r d Hl (fun i Hi => Hn (S i) ltac:(cbn; lia))). reflexivity.
  Qed.

  (* THE RINGS ACCESSOR *)
  Lemma rings_iff : forall m la rs, pool <> la ->
    rings m pool la = Some rs <->
    List.length rs = NLIST /\ forall i, (i < NLIST)%nat -> ring_enc m la i (nth i rs []).
  Proof.
    intros m la rs Hpl. unfold rings.
    assert (Hlen : List.length (map (ring_i m pool la) (seq 0 NLIST)) = NLIST)
      by (rewrite map_length, seq_length; reflexivity).
    assert (Hnth : forall i, (i < NLIST)%nat -> nth i (map (ring_i m pool la) (seq 0 NLIST)) None = ring_i m pool la i).
    { intros i Hi. rewrite (nth_indep _ None (ring_i m pool la 0%nat)) by (rewrite Hlen; exact Hi).
      rewrite map_nth, seq_nth by exact Hi. reflexivity. }
    split.
    - intros H. destruct (all_some_nth _ _ H) as (Hl & Hn). rewrite Hlen in Hl.
      split; [ exact Hl | intros i Hi ]. apply (proj1 (ring_i_iff m la i _ Hpl Hi)).
      rewrite <- (Hnth i Hi). apply Hn. rewrite Hlen. exact Hi.
    - intros (Hl & Hn). apply (all_some_of_nth _ _ []); [ rewrite Hlen; exact Hl | ].
      intros i Hi. rewrite Hlen in Hi. rewrite (Hnth i Hi).
      exact (proj2 (ring_i_iff m la i _ Hpl Hi) (Hn i Hi)).
  Qed.

  (* ---- surgery ---- *)
  Lemma chain_app : forall m E prev l k,
    chain m E prev (l ++ [k]) <->
    chain m (sv k) prev l /\ 0 <= k < NSLOT /\ ld32 m pool (k * OSZ + O_PREV) = Some (last_of prev l)
    /\ ld32 m pool (k * OSZ + O_NEXT) = Some E.
  Proof.
    intros m E prev l. revert prev. induction l as [|a l IH]; intros prev k.
    - cbn. tauto.
    - cbn [app chain last_of]. rewrite next_of_app. rewrite IH. tauto.
  Qed.

  Lemma chain_ext : forall m m' E prev l, chain m E prev l ->
    (forall k, In k l -> ld32 m' pool (k * OSZ + O_PREV) = ld32 m pool (k * OSZ + O_PREV)
                         /\ ld32 m' pool (k * OSZ + O_NEXT) = ld32 m pool (k * OSZ + O_NEXT)) ->
    chain m' E prev l.
  Proof.
    intros m m' E prev l. revert prev. induction l as [|k l IH]; intros prev Hc Hx; [ exact I | ].
    destruct Hc as (Hk & Lp & Ln & Hc). destruct (Hx k (or_introl eq_refl)) as (E1 & E2).
    refine (conj Hk (conj _ (conj _ (IH _ Hc (fun j Hj => Hx j (or_intror Hj)))))); congruence.
  Qed.

  Lemma fchain_ext : forall m m' l, fchain m l ->
    (forall k, In k l -> ld32 m' pool (k * OSZ + O_NEXT) = ld32 m pool (k * OSZ + O_NEXT)) ->
    fchain m' l.
  Proof.
    intros m m' l. induction l as [|k l IH]; intros Hc Hx; [ exact I | ].
    destruct Hc as (Hk & Ln & Hc).
    refine (conj Hk (conj _ (IH Hc (fun j Hj => Hx j (or_intror Hj))))). rewrite Hx by (left; reflexivity). exact Ln.
  Qed.

  (* the nodes of a chain are its slots *)
  Lemma chain_range : forall m E prev l, chain m E prev l -> forall k, In k l -> 0 <= k < NSLOT.
  Proof.
    intros m E prev l. revert prev. induction l as [|a l IH]; intros prev Hc k Hk; [ destruct Hk | ].
    destruct Hc as (Ha & _ & _ & Hc). destruct Hk as [<- | Hk]; [ exact Ha | exact (IH _ Hc k Hk) ].
  Qed.
  Lemma fchain_range : forall m l, fchain m l -> forall k, In k l -> 0 <= k < NSLOT.
  Proof.
    intros m l. induction l as [|a l IH]; intros Hc k Hk; [ destruct Hk | ].
    destruct Hc as (Ha & _ & Hc). destruct Hk as [<- | Hk]; [ exact Ha | exact (IH Hc k Hk) ].
  Qed.
End RING.

(* ---------------------------------------------------------------------- *)
(* Lists of lists, and disjointness from the partition.                      *)
(* ---------------------------------------------------------------------- *)
Fixpoint upd {A} (l : list A) (i : nat) (x : A) : list A :=
  match l, i with
  | [], _ => []
  | _ :: l', O => x :: l'
  | a :: l', S i' => a :: upd l' i' x
  end.

Lemma upd_length : forall {A} (l : list A) i x, List.length (upd l i x) = List.length l.
Proof. intros A l. induction l as [|a l IH]; intros [|i] x; cbn; auto. Qed.
Lemma upd_nth_eq : forall {A} (l : list A) i x d, (i < List.length l)%nat -> nth i (upd l i x) d = x.
Proof. intros A l. induction l as [|a l IH]; intros [|i] x d Hi; cbn in *; try lia; auto. apply IH. lia. Qed.
Lemma upd_nth_ne : forall {A} (l : list A) i j x d, j <> i -> nth j (upd l i x) d = nth j l d.
Proof.
  intros A l. induction l as [|a l IH]; intros [|i] [|j] x d Hji; cbn; auto; try congruence.
Qed.

Lemma nodup_app_disj : forall (l1 l2 : list Z) x, NoDup (l1 ++ l2) -> In x l1 -> In x l2 -> False.
Proof.
  intros l1. induction l1 as [|a l1 IH]; intros l2 x Hn H1 H2; [ destruct H1 | ].
  inversion Hn as [| ? ? Hna Hn']; subst. destruct H1 as [<- | H1].
  - apply Hna. apply in_or_app. right. exact H2.
  - exact (IH l2 x Hn' H1 H2).
Qed.

Lemma nth_in_concat : forall (rs : list (list Z)) i x, In x (nth i rs []) -> In x (concat rs).
Proof.
  intros rs. induction rs as [|r rs IH]; intros [|i] x H; cbn in H |- *; try contradiction;
    apply in_or_app; [ left; exact H | right; exact (IH i x H) ].
Qed.

Lemma nodup_concat_disj : forall (rs : list (list Z)) i j x, NoDup (concat rs) -> i <> j ->
  In x (nth i rs []) -> In x (nth j rs []) -> False.
Proof.
  intros rs. induction rs as [|r rs IH]; intros i j x Hn Hij Hi Hj; [ destruct i, j; cbn in *; contradiction | ].
  cbn [concat] in Hn. destruct i as [|i], j as [|j]; cbn in Hi, Hj; [ congruence | | | ].
  - exact (nodup_app_disj _ _ _ Hn Hi (nth_in_concat rs j x Hj)).
  - exact (nodup_app_disj _ _ _ Hn Hj (nth_in_concat rs i x Hi)).
  - exact (IH i j x (NoDup_app_remove_l _ _ Hn) ltac:(congruence) Hi Hj).
Qed.

Lemma nodup_nth : forall (rs : list (list Z)) i, NoDup (concat rs) -> NoDup (nth i rs []).
Proof.
  intros rs. induction rs as [|r rs IH]; intros [|i] Hn; cbn [concat nth] in *; try constructor.
  - exact (NoDup_app_remove_r _ _ Hn).
  - exact (IH i (NoDup_app_remove_l _ _ Hn)).
Qed.

(* a duplicate-free list of slots has at most NSLOT elements *)
Lemma slots_len : forall l : list Z, NoDup l -> (forall k, In k l -> 0 <= k < NSLOT) ->
  (List.length l <= 240)%nat.
Proof.
  intros l Hn Hr.
  assert (Hi : incl l (map Z.of_nat (seq 0 240))).
  { intros x Hx. pose proof (Hr x Hx) as Hx'. unfold NSLOT in Hx'. apply in_map_iff.
    exists (Z.to_nat x). split; [ lia | apply in_seq; lia ]. }
  pose proof (NoDup_incl_length Hn Hi) as L. rewrite map_length, seq_length in L. exact L.
Qed.

(* ---------------------------------------------------------------------- *)
(* THE TAIL INSERT (try_allocate_object's list surgery): the free list's   *)
(* head slot k moves to the end of ring i.  m' stores, at the five link   *)
(* cells, exactly what try_allocate_object writes, and keeps every other  *)
(* aligned word.                                                          *)
(* ---------------------------------------------------------------------- *)
(* a link cell's offset is word-aligned *)
Ltac md4 := apply Z.mod_divide; [ lia | apply Z.divide_add_r;
  [ apply Z.divide_mul_r; first [ exists 152; reflexivity | exists 26; reflexivity ]
  | first [ exists 24; reflexivity | exists 25; reflexivity ] ] ].

Section ALLOC.
  Variables pool la fl : block.
  Hypothesis Hpl : pool <> la.
  Hypothesis Hpf : pool <> fl.
  Hypothesis Hlf : la <> fl.

  Definition tail_cell (i : nat) (l : list Z) : block * Z :=
    match rev l with [] => (la, hoff i + O_NEXT) | j :: _ => (pool, j * OSZ + O_NEXT) end.

  Definition alloc_cells (i : nat) (l : list Z) (k : Z) : list (block * Z) :=
    [(fl, O_NEXT); (pool, k * OSZ + O_PREV); (pool, k * OSZ + O_NEXT); (la, hoff i + O_PREV); tail_cell i l].

  Definition alloc_frame (m m' : mem) (i : nat) (l : list Z) (k : Z) : Prop :=
    forall b z, z mod 4 = 0 -> ~ In (b, z) (alloc_cells i l k) -> ld32 m' b z = ld32 m b z.

  Lemma alloc_rings : forall m m' rs fs k i,
    rings m pool la = Some rs -> free_list m pool fl = Some (k :: fs) ->
    NoDup (concat rs ++ k :: fs) -> (i < NLIST)%nat ->
    let l := nth i rs [] in
    let H := Vptr la (Ptrofs.repr (hoff i)) in
    ld32 m' fl O_NEXT = Some (fnext pool fs) ->
    ld32 m' pool (k * OSZ + O_PREV) = Some (last_of pool H l) ->
    ld32 m' pool (k * OSZ + O_NEXT) = Some H ->
    ld32 m' la (hoff i + O_PREV) = Some (sv pool k) ->
    ld32 m' (fst (tail_cell i l)) (snd (tail_cell i l)) = Some (sv pool k) ->
    alloc_frame m m' i l k ->
    rings m' pool la = Some (upd rs i (l ++ [k])) /\ free_list m' pool fl = Some fs.
  Proof.
    intros m m' rs fs k i Hr Hf Hnd Hi l H L1 L2 L3 L5 L4 HF.
    apply (rings_iff pool m la rs Hpl) in Hr as (Hlen & Henc).
    apply (free_list_iff pool m fl (k :: fs)) in Hf as (F0 & Fc & Flen).
    destruct Fc as (Hk & Fk & Fc).
    assert (Hkr : ~ In k (concat rs)) by (intros X; exact (nodup_app_disj _ _ k Hnd X (or_introl eq_refl))).
    assert (Hkf : ~ In k fs) by (apply NoDup_app_remove_l in Hnd; inversion Hnd; assumption).
    assert (Hnd_r : NoDup (concat rs)) by exact (NoDup_app_remove_r _ _ Hnd).
    assert (Hrf : forall x, In x (concat rs) -> ~ In x fs)
      by (intros x X1 X2; exact (nodup_app_disj _ _ x Hnd X1 (or_intror X2))).
    (* frame on a pool link cell of a slot outside the five cells *)
    assert (Fp : forall j off, (off = O_PREV \/ off = O_NEXT) -> j <> k ->
               (off = O_NEXT -> (pool, j * OSZ + O_NEXT) <> tail_cell i l) ->
               ld32 m' pool (j * OSZ + off) = ld32 m pool (j * OSZ + off)).
    { intros j off Ho Hjk Ht. apply HF; [ unfold OSZ, O_PREV, O_NEXT in *; destruct Ho as [-> | ->]; md4 | ].
      unfold alloc_cells. intros Hin. cbn [In] in Hin.
      destruct Hin as [E | [E | [E | [E | [E | []]]]]];
        try (injection E; intros; first [ congruence | unfold OSZ, O_PREV, O_NEXT in *; destruct Ho as [-> | ->]; lia ]).
      destruct Ho as [-> | ->].
      - unfold tail_cell in E. destruct (rev l) as [|j' r]; injection E; intros;
          [ congruence | unfold OSZ, O_PREV, O_NEXT in *; lia ].
      - exact (Ht eq_refl (eq_sym E)). }
    assert (FpP : forall j, j <> k -> ld32 m' pool (j * OSZ + O_PREV) = ld32 m pool (j * OSZ + O_PREV)).
    { intros j Hjk. apply Fp; [ left; reflexivity | exact Hjk | intros E0; unfold O_PREV, O_NEXT in E0; lia ]. }
    assert (FpN : forall j, j <> k -> (pool, j * OSZ + O_NEXT) <> tail_cell i l ->
               ld32 m' pool (j * OSZ + O_NEXT) = ld32 m pool (j * OSZ + O_NEXT)).
    { intros j Hjk Ht. apply Fp; [ right; reflexivity | exact Hjk | intros _; exact Ht ]. }
    (* frame on a head cell of another ring *)
    assert (Fh : forall j off, (j < NLIST)%nat -> (off = O_PREV \/ off = O_NEXT) -> j <> i ->
               ld32 m' la (hoff j + off) = ld32 m la (hoff j + off)).
    { intros j off Hj Ho Hji. apply HF; [ unfold hoff, NODESZ, O_PREV, O_NEXT in *; destruct Ho as [-> | ->]; md4 | ].
      unfold alloc_cells. intros Hin. cbn [In] in Hin.
      destruct Hin as [E | [E | [E | [E | [E | []]]]]];
        try (injection E; intros; first [ congruence | unfold hoff, NODESZ, O_PREV, O_NEXT in *; destruct Ho as [-> | ->]; nia ]).
      unfold tail_cell in E. destruct (rev l) as [|j' r]; injection E; intros;
        [ unfold hoff, NODESZ, O_PREV, O_NEXT in *; destruct Ho as [-> | ->]; nia | congruence ]. }
    split.
    - apply (rings_iff pool m' la _ Hpl). rewrite upd_length. split; [ exact Hlen | ].
      intros j Hj. destruct (Nat.eq_dec j i) as [-> | Hji].
      + rewrite upd_nth_eq by (rewrite Hlen; exact Hi). fold l.
        destruct (Henc i Hi) as (Hn0 & Hc0 & Hp0 & Hl0). fold l H in Hn0, Hc0, Hp0.
        assert (Hli : forall x, In x l -> In x (concat rs)) by (intros x Hx; exact (nth_in_concat rs i x Hx)).
        assert (Hndl : NoDup l) by exact (nodup_nth rs i Hnd_r).
        (* the new chain *)
        assert (Hc1 : chain pool m' H H (l ++ [k])).
        { apply chain_app. split; [ | split; [ exact Hk | split; [ exact L2 | exact L3 ] ] ].
          destruct (rev l) as [|j r] eqn:Erl.
          - apply (f_equal (@rev Z)) in Erl. rewrite rev_involutive in Erl. cbn in Erl. rewrite Erl. exact I.
          - apply (f_equal (@rev Z)) in Erl. rewrite rev_involutive in Erl. cbn in Erl.
            rewrite Erl in Hc0 |- *. apply chain_app in Hc0 as (Hc0 & Hj0 & Pj & Nj).
            apply chain_app. split; [ | split; [ exact Hj0 | split ] ].
            + apply (chain_ext pool m m' (sv pool j) H (rev r) Hc0). intros x Hx.
              assert (Hxk : x <> k) by (intros ->; apply Hkr; apply Hli; rewrite Erl; apply in_or_app; left; exact Hx).
              assert (Hxj : x <> j).
              { intros ->. rewrite Erl in Hndl. apply NoDup_remove_2 in Hndl. rewrite app_nil_r in Hndl. exact (Hndl Hx). }
              split; [ exact (FpP x Hxk) | apply (FpN x Hxk) ].
              intros E. unfold tail_cell in E. rewrite Erl, rev_app_distr in E. cbn in E.
              injection E; intros. unfold OSZ in *. apply Hxj. lia.
            + assert (Hjk : j <> k) by (intros ->; apply Hkr; apply Hli; rewrite Erl; apply in_or_app; right; left; reflexivity).
              rewrite (FpP j Hjk). exact Pj.
            + unfold tail_cell in L4. rewrite Erl, rev_app_distr in L4. cbn in L4. exact L4. }
        refine (conj _ (conj Hc1 (conj _ _))).
        * destruct l as [|j0 l0] eqn:El.
          -- unfold tail_cell in L4. cbn in L4. exact L4.
          -- rewrite next_of_app. cbn [next_of] in Hn0 |- *. rewrite <- Hn0. apply HF.
             ++ unfold hoff, NODESZ, O_NEXT. md4.
             ++ unfold alloc_cells. intros Hin. cbn [In] in Hin.
                destruct Hin as [E | [E | [E | [E | [E | []]]]]];
                  try (injection E; intros; first [ congruence | unfold hoff, NODESZ, O_PREV, O_NEXT in *; lia ]).
                unfold tail_cell in E. destruct (rev (j0 :: l0)) as [|j' r] eqn:Er.
                ** apply (f_equal (@rev Z)) in Er. rewrite rev_involutive in Er. discriminate Er.
                ** injection E; intros; congruence.
        * rewrite last_of_app. exact L5.
        * pose proof (slots_len (concat rs ++ k :: fs) Hnd) as Hb.
          rewrite app_length. cbn [List.length].
          assert (Hlc : (List.length l <= List.length (concat rs))%nat).
          { apply NoDup_incl_length; [ exact Hndl | intros x Hx; exact (Hli x Hx) ]. }
          assert (Hrng : forall x, In x (concat rs ++ k :: fs) -> 0 <= x < NSLOT).
          { intros x Hx. apply in_app_or in Hx as [Hx | Hx].
            - apply in_concat in Hx as (r & Hr & Hx). apply In_nth with (d := []) in Hr as (j1 & Hj1 & <-).
              rewrite Hlen in Hj1. destruct (Henc j1 Hj1) as (_ & Hcj & _). exact (chain_range pool m _ _ _ Hcj x Hx).
            - destruct Hx as [<- | Hx]; [ exact Hk | exact (fchain_range pool m fs Fc x Hx) ]. }
          specialize (Hb Hrng). rewrite app_length in Hb. cbn [List.length] in Hb. unfold WFUEL. lia.
      + rewrite upd_nth_ne by exact Hji.
        destruct (Henc j Hj) as (Hn0 & Hc0 & Hp0 & Hl0).
        assert (Hlj : forall x, In x (nth j rs []) -> In x (concat rs)) by (intros x Hx; exact (nth_in_concat rs j x Hx)).
        refine (conj _ (conj _ (conj _ Hl0))).
        * rewrite Fh by auto. exact Hn0.
        * apply (chain_ext pool m m' _ _ _ Hc0). intros x Hx.
          assert (Hxk : x <> k) by (intros ->; exact (Hkr (Hlj k Hx))).
          split; [ exact (FpP x Hxk) | apply (FpN x Hxk) ].
          intros E. unfold tail_cell in E. destruct (rev l) as [|j' r] eqn:Er; [ injection E; intros; congruence | ].
          injection E; intros. unfold OSZ in *. assert (x = j') by lia. subst j'.
          apply (nodup_concat_disj rs j i x Hnd_r ltac:(congruence) Hx).
          fold l. apply in_rev. rewrite Er. left. reflexivity.
        * rewrite Fh by auto. exact Hp0.
    - apply (free_list_iff pool m' fl fs). split; [ exact L1 | split; [ | cbn in Flen; lia ] ].
      apply (fchain_ext pool m m' fs Fc). intros x Hx.
      assert (Hxk : x <> k) by (intros ->; exact (Hkf Hx)).
      apply (FpN x Hxk).
      intros E. unfold tail_cell in E. destruct (rev l) as [|j' r] eqn:Er; [ injection E; intros; congruence | ].
      injection E; intros. unfold OSZ in *. assert (x = j') by lia. subst j'.
      apply (Hrf x); [ | exact Hx ]. apply (nth_in_concat rs i). fold l. apply in_rev. rewrite Er. left. reflexivity.
  Qed.
End ALLOC.
