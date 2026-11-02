(* ======================================================================= *)
(* ObjLoop.v -- B2: the object-list loops of update_objects, walked.       *)
(*                                                                         *)
(* update_terrain_objects / update_non_terrain_objects (object_list_       *)
(* processor.c:563/573) call update_objects_in_list on list heads of       *)
(* gObjectListArray; it reads head->next and runs                          *)
(* update_objects_starting_at (or, in time stop,                           *)
(* update_objects_during_time_stop), the loop                              *)
(*   while (objList != firstObj) { <one object>; firstObj = firstObj->next; *)
(*                                 count++; }                              *)
(* This file PROVES those five real bodies keep an invariant P from the    *)
(* object world (ObjWorld.obj_w: each list is a ring through pool slots)  *)
(* and narrow rows: the per-object step (<one object>, the real statements *)
(* up to and including cur_obj_update(), read off the generated loop      *)
(* body: loop_pre) keeps P and leaves the object in its ring; the         *)
(* gObjectCounter stores; the update-order table's cells; the frame block  *)
(* of update_non_terrain_objects' unused local filler[4].                  *)
(* ======================================================================= *)

From Coq Require Import List ZArith Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Values Memory Globalenvs
  Ctypes Ctypesdefs Cop Clight ClightBigstep Events Linking Errors.
From SM64.Generated Require object_list_processor debug.
From SM64.Proofs Require Import SymbolicLinking LinkedTwelve RealFrameLinked.
From SM64.Proofs.WMotRRequiresA Require Import RenderAnim.
From SM64.Proofs.WMotRRequiresA Require ObjPhase ObjWorld.
From SM64.Proofs Require Interp.CMem.
Import ListNotations.
Local Open Scope Z_scope.

Module OLP := SM64.Generated.object_list_processor.
Module OW := SM64.Proofs.WMotRRequiresA.ObjWorld.
Module CM := SM64.Proofs.Interp.CMem.

(* ---------------------------------------------------------------------- *)
(* 1. The rings of obj_w: the node after a ring node is in the ring.      *)
(* ---------------------------------------------------------------------- *)
Lemma slot_of_spec : forall o k, OW.slot_of o = Some k -> 0 <= k < OW.NSLOT /\ o = k * OW.OSZ.
Proof.
  intros o k H. unfold OW.slot_of in H.
  destruct ((0 <=? o) && (o <? OW.NSLOT * OW.OSZ) && (o mod OW.OSZ =? 0)) eqn:E; [ | discriminate H ].
  injection H as <-. apply andb_prop in E as [E E3]. apply andb_prop in E as [E1 E2].
  apply Z.leb_le in E1. apply Z.ltb_lt in E2. apply Z.eqb_eq in E3.
  unfold OW.NSLOT, OW.OSZ in *.
  pose proof (Z.div_mod o 608 ltac:(lia)) as D. rewrite E3 in D.
  split; [ split | lia ].
  - apply Z.div_pos; lia.
  - apply Z.div_lt_upper_bound; lia.
Qed.

Definition in_l (pool hb : block) (ho : Z) (l : list Z) (v : val) : Prop :=
  v = Vptr hb (Ptrofs.repr ho) \/ exists k, In k l /\ v = OW.slot_v pool k.

Lemma in_l_cons : forall pool hb ho k l v, in_l pool hb ho l v -> in_l pool hb ho (k :: l) v.
Proof.
  intros pool hb ho k l v [H | (k' & H1 & H2)];
    [ left; exact H | right; exists k'; split; [ right; exact H1 | exact H2 ] ].
Qed.

Lemma ld32_eq : forall m b z, OW.ld32 m b z = Mem.load Mint32 m b z.
Proof. intros. unfold OW.ld32. apply CM.load_eq. Qed.

Lemma ring_from_spec : forall m pool hb ho n prev cur l,
  OW.ring_from m pool hb ho prev cur n = Some l ->
  in_l pool hb ho l cur /\
  (forall k, In k l -> 0 <= k < OW.NSLOT /\
     exists nx, Mem.load Mint32 m pool (k * OW.OSZ + OW.O_NEXT) = Some nx /\ in_l pool hb ho l nx).
Proof.
  intros m pool hb ho n. induction n as [| n IH]; intros prev cur l H; [ discriminate H | ].
  cbn [OW.ring_from] in H.
  destruct cur as [| | | | | b o]; try discriminate H.
  destruct (eq_block b hb && Z.eqb (Ptrofs.unsigned o) ho) eqn:Eh.
  - destruct (OW.veqb _ prev); [ | discriminate H ]. injection H as <-.
    apply andb_prop in Eh as [Eb Eo]. apply proj_sumbool_true in Eb. subst b.
    apply Z.eqb_eq in Eo. split.
    + left. rewrite <- Eo, Ptrofs.repr_unsigned. reflexivity.
    + intros k [].
  - destruct (eq_block b pool) as [Eb | ]; [ subst b | discriminate H ].
    destruct (OW.slot_of (Ptrofs.unsigned o)) as [k|] eqn:Es; [ | discriminate H ].
    destruct (OW.ld32 m pool (Ptrofs.unsigned o + OW.O_PREV)) as [p|]; [ | cbn in H; discriminate H ].
    destruct (OW.ld32 m pool (Ptrofs.unsigned o + OW.O_NEXT)) as [nx|] eqn:En; [ | cbn in H; discriminate H ].
    destruct (OW.veqb p prev); [ | discriminate H ].
    destruct (OW.ring_from m pool hb ho (Vptr pool o) nx n) as [l'|] eqn:Er; [ | discriminate H ].
    injection H as <-.
    destruct (IH _ _ _ Er) as (Hnx & Hall).
    destruct (slot_of_spec _ _ Es) as (Hk & Ho).
    assert (Hcur : Vptr pool o = OW.slot_v pool k).
    { unfold OW.slot_v. rewrite <- Ho, Ptrofs.repr_unsigned. reflexivity. }
    split.
    + right. exists k. split; [ left; reflexivity | exact Hcur ].
    + intros k' [<- | Hin].
      * split; [ exact Hk | ]. exists nx. rewrite <- Ho, <- ld32_eq.
        split; [ exact En | exact (in_l_cons _ _ _ _ _ _ Hnx) ].
      * destruct (Hall k' Hin) as (Hk' & nx' & Hl & Hi). split; [ exact Hk' | ].
        exists nx'. split; [ exact Hl | exact (in_l_cons _ _ _ _ _ _ Hi) ].
Qed.

Lemma ring_i_spec : forall m pool la i l, OW.ring_i m pool la i = Some l ->
  (exists nx, Mem.load Mint32 m la (Z.of_nat i * OW.NODESZ + OW.O_NEXT) = Some nx
              /\ in_l pool la (Z.of_nat i * OW.NODESZ) l nx) /\
  (forall k, In k l -> 0 <= k < OW.NSLOT /\
     exists nx, Mem.load Mint32 m pool (k * OW.OSZ + OW.O_NEXT) = Some nx
                /\ in_l pool la (Z.of_nat i * OW.NODESZ) l nx).
Proof.
  intros m pool la i l H. unfold OW.ring_i in H. cbv zeta in H.
  destruct (OW.ld32 m la (Z.of_nat i * OW.NODESZ + OW.O_NEXT)) as [nx|] eqn:E; [ | discriminate H ].
  destruct (ring_from_spec _ _ _ _ _ _ _ _ H) as (H1 & H2).
  split; [ exists nx; rewrite <- ld32_eq; split; [ exact E | exact H1 ] | exact H2 ].
Qed.

(* the ring's ORDER (2026-11-02, for the indexed terrain walk): the head's
   next is the ring's first node, and each node's next is the node after it
   in the list (the head after the last) *)
Definition first_v (pool hb : block) (ho : Z) (l : list Z) : val :=
  match l with [] => Vptr hb (Ptrofs.repr ho) | k :: _ => OW.slot_v pool k end.

Lemma ring_from_order : forall m pool hb ho n prev cur l,
  OW.ring_from m pool hb ho prev cur n = Some l ->
  cur = first_v pool hb ho l /\
  (forall pre k post, l = pre ++ k :: post ->
     Mem.load Mint32 m pool (k * OW.OSZ + OW.O_NEXT) = Some (first_v pool hb ho post)).
Proof.
  intros m pool hb ho n. induction n as [| n IH]; intros prev cur l H; [ discriminate H | ].
  cbn [OW.ring_from] in H.
  destruct cur as [| | | | | b o]; try discriminate H.
  destruct (eq_block b hb && Z.eqb (Ptrofs.unsigned o) ho) eqn:Eh.
  - destruct (OW.veqb _ prev); [ | discriminate H ]. injection H as <-.
    apply andb_prop in Eh as [Eb Eo]. apply proj_sumbool_true in Eb. subst b.
    apply Z.eqb_eq in Eo. split.
    + cbn [first_v]. rewrite <- Eo, Ptrofs.repr_unsigned. reflexivity.
    + intros pre k post E. destruct pre; discriminate E.
  - destruct (eq_block b pool) as [Eb | ]; [ subst b | discriminate H ].
    destruct (OW.slot_of (Ptrofs.unsigned o)) as [k|] eqn:Es; [ | discriminate H ].
    destruct (OW.ld32 m pool (Ptrofs.unsigned o + OW.O_PREV)) as [p|]; [ | cbn in H; discriminate H ].
    destruct (OW.ld32 m pool (Ptrofs.unsigned o + OW.O_NEXT)) as [nx|] eqn:En; [ | cbn in H; discriminate H ].
    destruct (OW.veqb p prev); [ | discriminate H ].
    destruct (OW.ring_from m pool hb ho (Vptr pool o) nx n) as [l'|] eqn:Er; [ | discriminate H ].
    injection H as <-.
    destruct (IH _ _ _ Er) as (Hnx & Hsucc).
    destruct (slot_of_spec _ _ Es) as (Hk & Ho).
    split.
    + cbn [first_v]. unfold OW.slot_v. rewrite <- Ho, Ptrofs.repr_unsigned. reflexivity.
    + intros pre k' post E. destruct pre as [| x pre].
      * cbn in E. injection E as <- <-. rewrite <- Ho, <- ld32_eq, En, Hnx. reflexivity.
      * cbn in E. injection E as <- E. exact (Hsucc _ _ _ E).
Qed.

Lemma ring_i_order : forall m pool la i l, OW.ring_i m pool la i = Some l ->
  Mem.load Mint32 m la (Z.of_nat i * OW.NODESZ + OW.O_NEXT)
    = Some (first_v pool la (Z.of_nat i * OW.NODESZ) l) /\
  (forall pre k post, l = pre ++ k :: post ->
     Mem.load Mint32 m pool (k * OW.OSZ + OW.O_NEXT) = Some (first_v pool la (Z.of_nat i * OW.NODESZ) post)).
Proof.
  intros m pool la i l H. unfold OW.ring_i in H. cbv zeta in H.
  destruct (OW.ld32 m la (Z.of_nat i * OW.NODESZ + OW.O_NEXT)) as [nx|] eqn:E; [ | discriminate H ].
  destruct (ring_from_order _ _ _ _ _ _ _ _ H) as (H1 & H2).
  split; [ rewrite <- ld32_eq, E, H1; reflexivity | exact H2 ].
Qed.

Lemma all_some_nth : forall {A} (l : list (option A)) r, OW.all_some l = Some r ->
  forall i d, (i < length l)%nat -> nth i l None = Some (nth i r d).
Proof.
  intros A l. induction l as [| x l IH]; intros r H i d Hi; [ cbn in Hi; lia | ].
  cbn in H. destruct x as [x|]; [ | discriminate H ].
  destruct (OW.all_some l) as [r'|] eqn:E; [ | discriminate H ]. injection H as <-.
  destruct i as [| i]; [ reflexivity | ].
  cbn in Hi |- *. exact (IH r' eq_refl i d ltac:(lia)).
Qed.

Lemma rings_nth : forall m pool la rs, OW.rings m pool la = Some rs ->
  forall i, (i < OW.NLIST)%nat -> OW.ring_i m pool la i = Some (nth i rs []).
Proof.
  intros m pool la rs H i Hi. unfold OW.rings in H.
  assert (Hlen : (i < length (map (OW.ring_i m pool la) (seq 0 OW.NLIST)))%nat)
    by (rewrite map_length, seq_length; exact Hi).
  pose proof (all_some_nth _ _ H i [] Hlen) as E.
  rewrite (nth_indep _ None (OW.ring_i m pool la 0)) in E by exact Hlen.
  rewrite map_nth, seq_nth in E by exact Hi. exact E.
Qed.

Definition head_v (la : block) (i : nat) : val :=
  Vptr la (Ptrofs.repr (Z.of_nat i * OW.NODESZ)).

(* ---------------------------------------------------------------------- *)
(* 2. Ring membership in the object world.                                 *)
(* ---------------------------------------------------------------------- *)
Section W.
  Variable G : genv.
  Variable bm : block.

  Definition ow_at (m : mem) (pool la : block) (rs : list (list Z)) : Prop :=
    Genv.find_symbol G OLP._gObjectPool = Some pool
    /\ Genv.find_symbol G OLP._gObjectListArray = Some la
    /\ exists fl gol gmo sdp gdi fs,
         Genv.find_symbol G OLP._gFreeObjectList = Some fl
         /\ Genv.find_symbol G OLP._gObjectLists = Some gol
         /\ Genv.find_symbol G OLP._gMarioObject = Some gmo
         /\ Genv.find_symbol G debug._sDebugPage = Some sdp
         /\ Genv.find_symbol G debug._gDebugInfo = Some gdi
         /\ OW.ow_core G pool la fl gol gmo sdp gdi bm m rs fs.

  Lemma ow_at_of : forall m, OW.obj_w G bm m -> exists pool la rs, ow_at m pool la rs.
  Proof.
    intros m (pool & la & fl & gol & gmo & sdp & gdi & rs & fs & H1 & H2 & H3 & H4 & H5 & H6 & H7 & Hc).
    exists pool, la, rs. split; [ exact H1 | split; [ exact H2 | ] ].
    exists fl, gol, gmo, sdp, gdi, fs. tauto.
  Qed.

  (* v is a node of the list whose head is hd *)
  Definition in_ring (m : mem) (hd v : val) : Prop :=
    exists pool la rs i k, ow_at m pool la rs /\ (i < OW.NLIST)%nat /\ hd = head_v la i
      /\ In k (nth i rs []) /\ v = OW.slot_v pool k.

  (* hd is a list head *)
  Definition is_head (m : mem) (hd : val) : Prop :=
    exists pool la rs i, ow_at m pool la rs /\ (i < OW.NLIST)%nat /\ hd = head_v la i.

  Lemma add96 : forall z, 0 <= z -> z + 96 <= Ptrofs.max_unsigned ->
    Ptrofs.unsigned (Ptrofs.add (Ptrofs.repr z) (Ptrofs.repr 96)) = z + 96.
  Proof.
    intros z H0 H1. rewrite Ptrofs.add_unsigned.
    rewrite (Ptrofs.unsigned_repr z) by lia. rewrite (Ptrofs.unsigned_repr 96) by lia.
    apply Ptrofs.unsigned_repr. lia.
  Qed.

  Lemma maxu : Ptrofs.max_unsigned = 4294967295.
  Proof. reflexivity. Qed.

  Lemma in_l_ring : forall m pool la rs i l nx, ow_at m pool la rs -> (i < OW.NLIST)%nat ->
    nth i rs [] = l -> in_l pool la (Z.of_nat i * OW.NODESZ) l nx ->
    nx = head_v la i \/ in_ring m (head_v la i) nx.
  Proof.
    intros m pool la rs i l nx Ha Hi El [E | (k & Hk & E)].
    - left. exact E.
    - right. exists pool, la, rs, i, k. subst l. tauto.
  Qed.

  Lemma ring_next : forall m hd v, in_ring m hd v ->
    exists b o nx, v = Vptr b o
      /\ Mem.loadv Mint32 m (Vptr b (Ptrofs.add o (Ptrofs.repr 96))) = Some nx
      /\ (nx = hd \/ in_ring m hd nx).
  Proof.
    intros m hd v (pool & la & rs & i & k & Ha & Hi & -> & Hk & ->).
    pose proof Ha as (_ & _ & fl & gol & gmo & sdp & gdi & fs & _ & _ & _ & _ & _ & Hc).
    pose proof (rings_nth _ _ _ _ (OW.ow_rings _ _ _ _ _ _ _ _ _ _ _ _ Hc) i Hi) as Hr.
    destruct (ring_i_spec _ _ _ _ _ Hr) as (_ & Hall).
    destruct (Hall k Hk) as (Hkr & nx & Hl & Hin).
    exists pool, (Ptrofs.repr (k * OW.OSZ)), nx. split; [ reflexivity | ].
    split.
    - cbn [Mem.loadv]. rewrite add96 by (unfold OW.OSZ, OW.NSLOT in *; try rewrite maxu; lia).
      exact Hl.
    - exact (in_l_ring _ _ _ _ _ _ _ Ha Hi eq_refl Hin).
  Qed.

  Lemma head_next : forall m hd, is_head m hd ->
    exists b o nx, hd = Vptr b o
      /\ Mem.loadv Mint32 m (Vptr b (Ptrofs.add o (Ptrofs.repr 96))) = Some nx
      /\ (nx = hd \/ in_ring m hd nx).
  Proof.
    intros m hd (pool & la & rs & i & Ha & Hi & ->).
    pose proof Ha as (_ & _ & fl & gol & gmo & sdp & gdi & fs & _ & _ & _ & _ & _ & Hc).
    pose proof (rings_nth _ _ _ _ (OW.ow_rings _ _ _ _ _ _ _ _ _ _ _ _ Hc) i Hi) as Hr.
    destruct (ring_i_spec _ _ _ _ _ Hr) as ((nx & Hl & Hin) & _).
    exists la, (Ptrofs.repr (Z.of_nat i * OW.NODESZ)), nx. split; [ reflexivity | ].
    split.
    - cbn [Mem.loadv]. unfold OW.NLIST in Hi.
      rewrite add96 by (unfold OW.NODESZ; try rewrite maxu; lia).
      exact Hl.
    - exact (in_l_ring _ _ _ _ _ _ _ Ha Hi eq_refl Hin).
  Qed.
End W.

(* ---------------------------------------------------------------------- *)
(* 3. Statement facts.                                                     *)
(* ---------------------------------------------------------------------- *)
Fixpoint app_seq (l : list statement) (s : statement) : statement :=
  match l with [] => s | x :: l' => Ssequence x (app_seq l' s) end.

Fixpoint comps (s : statement) : list statement :=
  match s with Ssequence a b => a :: comps b | _ => [s] end.

(* the statements of a while loop's body before its last two (the cursor
   advance firstObj = firstObj->next and count++), read off a function
   body of the shape  count = 0; while (c) { ... }; return count; *)
Definition loop_pre (f : function) : list statement :=
  match fn_body f with
  | Ssequence _ (Ssequence (Sloop (Ssequence _ b) _) _) =>
      let l := comps b in firstn (length l - 2) l
  | _ => []
  end.

(* x is not assigned *)
Fixpoint nosets (x : ident) (s : statement) : bool :=
  match s with
  | Sskip | Sassign _ _ | Sbreak | Scontinue | Sreturn _ | Sgoto _ => true
  | Sset y _ => negb (Pos.eqb x y)
  | Scall o _ _ | Sbuiltin o _ _ _ => match o with Some y => negb (Pos.eqb x y) | None => true end
  | Ssequence s1 s2 | Sifthenelse _ s1 s2 | Sloop s1 s2 => nosets x s1 && nosets x s2
  | Sswitch _ _ => false
  | Slabel _ s1 => nosets x s1
  end.

(* no return statement *)
Fixpoint noret (s : statement) : bool :=
  match s with
  | Sreturn _ | Sswitch _ _ => false
  | Ssequence s1 s2 | Sifthenelse _ s1 s2 | Sloop s1 s2 => noret s1 && noret s2
  | Slabel _ s1 => noret s1
  | _ => true
  end.

Section ST.
  Variable G : genv.
  Variable e : env.
  Notation xs := (exec_stmt function_entry2 G e).

  Lemma nosets_keep : forall le m s t le' m' out, xs le m s t le' m' out ->
    forall x, nosets x s = true -> le' ! x = le ! x.
  Proof.
    intros le m s t le' m' out H. induction H; intros x0 Hn; pose proof Hn as Hn0; cbn [nosets] in Hn.
    all: repeat match goal with Ha : (_ && _) = true |- _ => apply andb_prop in Ha; destruct Ha end.
    all: try reflexivity.
    all: try discriminate Hn.
    all: try (match goal with |- (PTree.set ?id _ _) ! ?x = _ =>
                rewrite PTree.gso; [ reflexivity | intros ->; rewrite Pos.eqb_refl in Hn; discriminate Hn ] end).
    all: try (match goal with |- (set_opttemp ?o _ _) ! _ = _ =>
                destruct o as [y|]; cbn in Hn |- *; [ | reflexivity ];
                rewrite PTree.gso; [ reflexivity | intros ->; rewrite Pos.eqb_refl in Hn; discriminate Hn ] end).
    all: try (match goal with IH : forall x, nosets x (if ?b then _ else _) = true -> _ |- _ => destruct b end).
    all: repeat match goal with
           IH : forall x, nosets x ?s = true -> ?a ! x = ?b ! x, Hs : nosets ?x0 ?s = true |- context [?a ! ?x0] =>
             rewrite (IH x0 Hs) end.
    all: try reflexivity.
  Qed.

  Lemma noret_out : forall le m s t le' m' out, xs le m s t le' m' out ->
    noret s = true -> forall r, out <> Out_return r.
  Proof.
    intros le m s t le' m' out H.
    induction H; intros Hn r0 Er; pose proof Hn as Hn0; cbn [noret] in Hn; try discriminate Hn.
    all: repeat match goal with Ha : (_ && _) = true |- _ => apply andb_prop in Ha; destruct Ha end.
    all: try discriminate Er.
    all: try (match goal with IH : noret (if ?b then _ else _) = true -> _ |- _ => destruct b end).
    all: try (match goal with Hb : out_break_or_return _ _ |- _ => inv Hb end).
    all: try (match goal with Hx : Out_normal = Out_return _ |- _ => discriminate Hx end).
    all: try (match goal with IH : noret ?s = true -> forall r, Out_return ?q <> Out_return r, Hs : noret ?s = true |- _ =>
                exact (IH Hs q eq_refl) end).
    all: try (match goal with IH : noret ?s = true -> forall r, ?o <> Out_return r, Hs : noret ?s = true |- _ =>
                exact (IH Hs r0 Er) end).
  Qed.

  Lemma app_seq_inv : forall pre tail le m t le' m' out,
    xs le m (app_seq pre tail) t le' m' out ->
    (exists t1 le1 m1 t2, xs le m (app_seq pre Sskip) t1 le1 m1 Out_normal
                          /\ xs le1 m1 tail t2 le' m' out)
    \/ ((exists t', xs le m (app_seq pre Sskip) t' le' m' out) /\ out <> Out_normal).
  Proof.
    induction pre as [| x pre IH]; intros tail le m t le' m' out H; cbn [app_seq] in *.
    - left. exists E0, le, m, t. split; [ constructor | exact H ].
    - apply seq_inv in H. destruct H as [(t1 & le1 & m1 & t2 & H1 & H2) | (H1 & Hn)].
      + destruct (IH _ _ _ _ _ _ _ H2) as [(t3 & le3 & m3 & t4 & H3 & H4) | ((t3 & H3) & Hn)].
        * left. exists (t1 ** t3), le3, m3, t4. split; [ econstructor; eassumption | exact H4 ].
        * right. split; [ exists (t1 ** t3); econstructor; eassumption | exact Hn ].
      + right. split; [ exists t; apply exec_Sseq_2; assumption | exact Hn ].
  Qed.
End ST.

(* ---------------------------------------------------------------------- *)
(* 4. The loop, generic over its per-object prefix.                        *)
(* ---------------------------------------------------------------------- *)
Definition tnode : type := tptr (Tstruct OLP._ObjectNode noattr).
Definition COND : expr :=
  Ebinop One (Etempvar OLP._objList tnode) (Etempvar OLP._firstObj tnode) tint.
Definition NEXT : statement :=
  Sset OLP._firstObj
    (Efield (Ederef (Etempvar OLP._firstObj tnode) (Tstruct OLP._ObjectNode noattr)) OLP._next tnode).
Definition INC : statement :=
  Sset OLP._count (Ebinop Oadd (Etempvar OLP._count tint) (Econst_int (Int.repr 1) tint) tint).
Definition loop_body (pre : list statement) : statement := app_seq pre (Ssequence NEXT INC).
Definition loop_fn_body (pre : list statement) : statement :=
  Ssequence (Sset OLP._count (Econst_int (Int.repr 0) tint))
    (Ssequence (Swhile COND (loop_body pre)) (Sreturn (Some (Etempvar OLP._count tint)))).

Lemma cmp_self : forall (G : genv) m v r,
  sem_binary_operation G One v tnode v tnode m = Some r -> r = Vint Int.zero.
Proof.
  intros G m v r H. cbn in H. unfold cmp_ptr in H.
  destruct v; cbn [Archi.ptr64 Val.cmpu_bool] in H; try discriminate H.
  - unfold Int.cmpu in H. rewrite Int.eq_true in H. cbn in H. injection H as <-. reflexivity.
  - destruct (eq_block b b) as [_ | N]; [ | exfalso; exact (N eq_refl) ].
    match type of H with context [if ?c then _ else _] => destruct c end; [ | discriminate H ].
    cbn [option_map] in H. unfold Ptrofs.cmpu in H. rewrite Ptrofs.eq_true in H.
    cbn in H. injection H as <-. reflexivity.
Qed.

Lemma cast_tint : forall c vr m, sem_cast (Vint c) tint tint m = Some vr -> exists c', vr = Vint c'.
Proof. intros c vr m H. vm_compute in H. injection H as <-. eauto. Qed.

Lemma add_tint : forall (G : genv) c v m,
  sem_binary_operation G Oadd (Vint c) tint (Vint (Int.repr 1)) tint m = Some v -> exists c', v = Vint c'.
Proof. intros G c v m H. assert (E : sem_binary_operation G Oadd (Vint c) tint (Vint (Int.repr 1)) tint m = Some (Vint (Int.add c (Int.repr 1)))) by reflexivity. rewrite E in H. injection H as <-. eauto. Qed.

Lemma ofs_inj : forall b o b' o', Vptr b o = Vptr b' o' -> b = b' /\ o = o'.
Proof. intros b o b' o' H. injection H as -> ->. auto. Qed.

Section Loop.
  Variable G : genv.
  Variable P : mem -> Prop.
  Variable inr : mem -> val -> val -> Prop.
  Hypothesis Hnext : forall m hd v, inr m hd v ->
    exists b o nx, v = Vptr b o
      /\ Mem.loadv Mint32 m (Vptr b (Ptrofs.add o (Ptrofs.repr 96))) = Some nx
      /\ (nx = hd \/ inr m hd nx).
  Hypothesis Hfo : forall co, (genv_cenv G) ! OLP._ObjectNode = Some co ->
    field_offset G OLP._next (co_members co) = OK (96, Full).
  Variable pre : list statement.
  Hypothesis Hns : nosets OLP._firstObj (app_seq pre Sskip) && nosets OLP._objList (app_seq pre Sskip)
                   && nosets OLP._count (app_seq pre Sskip) && noret (app_seq pre Sskip) = true.
  (* THE ROW: the per-object prefix keeps P and leaves the object in its ring *)
  Hypothesis Hiter : forall hd v le m t le' m' out, P m -> inr m hd v ->
    le ! OLP._firstObj = Some v -> le ! OLP._objList = Some hd ->
    exec_stmt function_entry2 G empty_env le m (app_seq pre Sskip) t le' m' out -> P m' /\ inr m' hd v.

  Definition J (hd : val) (le : temp_env) (m : mem) : Prop :=
    P m /\ le ! OLP._objList = Some hd /\ (exists c, le ! OLP._count = Some (Vint c))
    /\ exists v, le ! OLP._firstObj = Some v /\ (v = hd \/ inr m hd v).

  Lemma s1_J : forall hd le m t le1 m1 out1,
    exec_stmt function_entry2 G empty_env le m
      (Ssequence (Sifthenelse COND Sskip Sbreak) (loop_body pre)) t le1 m1 out1 ->
    J hd le m ->
    P m1 /\ (forall r, out1 <> Out_return r) /\ (exists c, le1 ! OLP._count = Some (Vint c))
    /\ (out1 = Out_break \/ J hd le1 m1).
  Proof.
    intros hd le m t le1 m1 out1 H (HP & Ho & (c & Hc) & v & Hv & Hvr).
    apply andb_prop in Hns as [Hns' N4]. apply andb_prop in Hns' as [Hns'' N3].
    apply andb_prop in Hns'' as [N1 N2].
    apply seq_inv in H. destruct H as [(t1 & le2 & m2 & t2 & H1 & H2) | (H1 & Hn)].
    - apply if_inv in H1 as (r & b & Hr & Hb & H1).
      destruct b; [ | inv H1 ].
      apply skip_inv in H1 as (-> & -> & _).
      destruct Hvr as [-> | Hin].
      { exfalso. apply ev_binop in Hr as (v1 & v2 & E1 & E2 & E3).
        apply ev_temp in E1. apply ev_temp in E2. rewrite Ho in E1. rewrite Hv in E2.
        injection E1 as <-. injection E2 as <-. cbn [typeof COND] in E3.
        apply cmp_self in E3. subst r. cbn in Hb. discriminate Hb. }
      unfold loop_body in H2. apply app_seq_inv in H2.
      destruct H2 as [(t3 & le3 & m3 & t4 & H3 & H4) | ((t3 & H3) & Hn)].
      + destruct (Hiter hd v le m _ _ _ _ HP Hin Hv Ho H3) as (HP3 & Hin3).
        pose proof (nosets_keep _ _ _ _ _ _ _ _ _ H3 _ N1) as K1.
        pose proof (nosets_keep _ _ _ _ _ _ _ _ _ H3 _ N2) as K2.
        pose proof (nosets_keep _ _ _ _ _ _ _ _ _ H3 _ N3) as K3.
        apply seq_inv in H4. destruct H4 as [(t5 & le5 & m5 & t6 & H5 & H6) | (H5 & Hn)].
        * apply set_inv in H5 as (nv & Env & -> & -> & _).
          apply set_inv in H6 as (cv & Ecv & -> & -> & ->).
          destruct (ev_fld G empty_env m3 le3 OLP._firstObj OLP._ObjectNode OLP._next tnode nv Mint32 96 Hfo eq_refl Env) as (b & o & Hb1 & Hl).
          destruct (Hnext _ _ _ Hin3) as (b' & o' & nx & -> & Hl' & Hnx).
          rewrite K1, Hv in Hb1. injection Hb1 as <- <-.
          rewrite Hl' in Hl. injection Hl as <-.
          apply ev_binop in Ecv as (w1 & w2 & E1 & E2 & E3).
          apply ev_temp in E1. apply ev_const in E2. subst w2.
          rewrite PTree.gso in E1 by (vm_compute; discriminate). rewrite K3, Hc in E1.
          injection E1 as <-. cbn [typeof] in E3. destruct (add_tint _ _ _ _ E3) as (c' & ->).
          split; [ exact HP3 | split; [ intros r0 Er; discriminate Er | ] ].
          split; [ exists c'; apply PTree.gss | right ].
          split; [ exact HP3 | ].
          split; [ rewrite PTree.gso by (vm_compute; discriminate);
                   rewrite PTree.gso by (vm_compute; discriminate); rewrite K2; exact Ho | ].
          split; [ exists c'; apply PTree.gss | ].
          exists nx. split; [ rewrite PTree.gso by (vm_compute; discriminate); apply PTree.gss | exact Hnx ].
        * apply set_inv in H5 as (_ & _ & _ & _ & E). exfalso. exact (Hn E).
      + destruct (Hiter hd v le m _ _ _ _ HP Hin Hv Ho H3) as (HP3 & Hin3).
        pose proof (nosets_keep _ _ _ _ _ _ _ _ _ H3 _ N1) as K1.
        pose proof (nosets_keep _ _ _ _ _ _ _ _ _ H3 _ N2) as K2.
        pose proof (nosets_keep _ _ _ _ _ _ _ _ _ H3 _ N3) as K3.
        split; [ exact HP3 | split; [ exact (noret_out _ _ _ _ _ _ _ _ _ H3 N4) | ] ].
        split; [ exists c; rewrite K3; exact Hc | right ].
        split; [ exact HP3 | split; [ rewrite K2; exact Ho | ] ].
        split; [ exists c; rewrite K3; exact Hc | ].
        exists v. split; [ rewrite K1; exact Hv | right; exact Hin3 ].
    - apply if_inv in H1 as (r & b & Hr & Hb & H1).
      destruct b; inv H1; [ exfalso; exact (Hn eq_refl) | ].
      split; [ exact HP | split; [ intros r0 Er; discriminate Er | ] ].
      split; [ exists c; exact Hc | left; reflexivity ].
  Qed.

  Lemma loop_J : forall hd le m t le' m' out,
    exec_stmt function_entry2 G empty_env le m (Swhile COND (loop_body pre)) t le' m' out ->
    J hd le m ->
    P m' /\ (forall r, out <> Out_return r) /\ (exists c, le' ! OLP._count = Some (Vint c)).
  Proof.
    intros hd le m t le' m' out H. unfold Swhile in H. pose proof (s1_J hd) as S1.
    remember empty_env as e0 eqn:Ee.
    remember (Sloop (Ssequence (Sifthenelse COND Sskip Sbreak) (loop_body pre)) Sskip) as S eqn:ES.
    induction H; intros HJ; try discriminate ES; injection ES as E1 E2; subst.
    - destruct (S1 _ _ _ _ _ _ H HJ) as (HP & Hnr & Hc & _).
      inv H0; [ split; [ exact HP | split; [ intros r0 Er; discriminate Er | exact Hc ] ] | ].
      exfalso. exact (Hnr _ eq_refl).
    - inv H1. inv H2.
    - destruct (S1 _ _ _ _ _ _ H HJ) as (_ & _ & _ & [-> | HJ1]); [ inv H0 | ].
      inv H1. exact (IHexec_stmt3 eq_refl Hiter eq_refl S1 HJ1).
  Qed.

  Lemma fn_loop_keeps : forall f, fn_vars f = [] -> fn_return f = tint ->
    fn_params f = [(OLP._objList, tnode); (OLP._firstObj, tnode)] ->
    fn_body f = loop_fn_body pre ->
    forall m hd v0 t m' vr, P m -> (v0 = hd \/ inr m hd v0) ->
      eval_funcall function_entry2 G m (Internal f) [hd; v0] t m' vr -> P m' /\ exists c, vr = Vint c.
  Proof.
    intros f Hvars Hret Hpar Hbody m hd v0 t m' vr HP Hv0 Hev.
    remember (Internal f) as fd eqn:Efd. remember [hd; v0] as va eqn:Eva.
    destruct Hev as [mm ff vargs tt ee lea leb mm1 mm2 oo vv mm3 Hfe Hx Hor Hfr | ];
      [ injection Efd as Eff; subst ff | discriminate Efd ]. subst vargs.
    destruct Hfe as [_ _ _ Hav Hb].
    rewrite Hvars in Hav. inversion Hav; subst ee mm1; subst e m; rename mm into m.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rewrite Hpar in Hb; cbn in Hb; injection Hb as <- end.
    match goal with Hx : exec_stmt _ _ _ _ _ (fn_body f) _ _ _ _ |- _ =>
      rewrite Hbody in Hx; unfold loop_fn_body in Hx; rename Hx into Hx0 end.
    apply seq_inv in Hx0. destruct Hx0 as [(ta1 & lea1 & ma1 & ta2 & Y1 & Y2) | (Y1 & Yn)];
      [ | apply set_inv in Y1 as (_ & _ & _ & _ & E); exfalso; exact (Yn E) ].
    apply set_inv in Y1 as (cv & Ecv & -> & -> & _). apply ev_const in Ecv. subst cv.
    assert (HJ : J hd (PTree.set OLP._count (Vint (Int.repr 0))
                       (PTree.set OLP._firstObj v0
                          (PTree.set OLP._objList hd (create_undef_temps (fn_temps f))))) m).
    { split; [ exact HP | ].
      split; [ rewrite PTree.gso by (vm_compute; discriminate);
               rewrite PTree.gso by (vm_compute; discriminate); apply PTree.gss | ].
      split; [ eexists; apply PTree.gss | ].
      exists v0. split; [ rewrite PTree.gso by (vm_compute; discriminate); apply PTree.gss | exact Hv0 ]. }
    apply seq_inv in Y2. destruct Y2 as [(ta3 & lea3 & ma3 & ta4 & Y3 & Y4) | (Y3 & Yn)].
    - destruct (loop_J _ _ _ _ _ _ _ Y3 HJ) as (HP3 & _ & c & Hc).
      apply ret_inv in Y4 as (-> & rv & Erv & ->). apply ev_temp in Erv. rewrite Hc in Erv.
      injection Erv as <-.
      match goal with Ho : outcome_result_value _ _ _ _ |- _ => rewrite Hret in Ho; destruct Ho as (_ & Hcast) end.
      destruct (cast_tint _ _ _ Hcast) as (c' & ->).
      match goal with Hfr : Mem.free_list _ _ = Some _ |- _ => cbn in Hfr; injection Hfr as <- end.
      split; [ exact HP3 | eauto ].
    - destruct (loop_J _ _ _ _ _ _ _ Y3 HJ) as (HP3 & Hnr & _).
      exfalso.
      match goal with Ho : outcome_result_value _ _ _ _ |- _ => rewrite Hret in Ho; rename Ho into Hor end.
      destruct oo as [ | | | [[rv rt]|] ]; cbn in Hor; try contradiction.
      all: first [ exact (Yn eq_refl) | exact (Hnr _ eq_refl) ].
  Qed.
End Loop.

(* ---------------------------------------------------------------------- *)
(* 4b. The loop with a CURSOR-INDEXED invariant (2026-11-02): Pi v m is    *)
(*     what holds when the cursor firstObj is v (the terrain walk's       *)
(*     surface budget: the counter plus the budgets of the objects not    *)
(*     yet stepped).  The row moves it from v to the node after v.  The   *)
(*     loop ends on the head (the comparison objList != firstObj false),  *)
(*     so it ends with Pi hd.                                             *)
(* ---------------------------------------------------------------------- *)
(* no break / continue that reaches the enclosing loop *)
Fixpoint nobrk (s : statement) : bool :=
  match s with
  | Sbreak | Scontinue | Sswitch _ _ => false
  | Ssequence s1 s2 | Sifthenelse _ s1 s2 => nobrk s1 && nobrk s2
  | Slabel _ s1 => nobrk s1
  | _ => true
  end.

Lemma nobrk_out : forall G e le m s t le' m' out,
  exec_stmt function_entry2 G e le m s t le' m' out ->
  nobrk s = true -> out <> Out_break /\ out <> Out_continue.
Proof.
  intros G e le m s t le' m' out H.
  induction H; intros Hn; pose proof Hn as Hn0; cbn [nobrk] in Hn; try discriminate Hn.
  all: repeat match goal with Ha : (_ && _) = true |- _ => apply andb_prop in Ha; destruct Ha end.
  all: try (split; discriminate).
  all: try (match goal with IH : nobrk (if ?b then _ else _) = true -> _ |- _ => destruct b end).
  all: try (match goal with Hb : out_break_or_return _ _ |- _ => inv Hb; split; discriminate end).
  all: try (match goal with IH : nobrk ?s = true -> _, Hs : nobrk ?s = true |- _ => exact (IH Hs) end).
Qed.

Lemma cmp_ne_false : forall (G : genv) m b1 o1 b2 o2 r,
  sem_binary_operation G One (Vptr b1 o1) tnode (Vptr b2 o2) tnode m = Some r ->
  bool_val r tint m = Some false -> Vptr b1 o1 = Vptr b2 o2.
Proof.
  intros G m b1 o1 b2 o2 r H Hb. cbn in H. unfold cmp_ptr in H.
  cbn [Archi.ptr64 Val.cmpu_bool] in H.
  destruct (eq_block b1 b2) as [<- | N].
  - match type of H with context [if ?c then _ else _] => destruct c end; [ | discriminate H ].
    cbn [option_map] in H. injection H as <-. unfold Ptrofs.cmpu in Hb.
    destruct (Ptrofs.eq o1 o2) eqn:E; cbn in Hb; [ | discriminate Hb ].
    rewrite (Ptrofs.same_if_eq _ _ E). reflexivity.
  - match type of H with context [if ?c then _ else _] => destruct c end; [ | discriminate H ].
    cbn in H. injection H as <-. cbn in Hb. discriminate Hb.
Qed.

Section LoopIx.
  Variable G : genv.
  Variable Pi : val -> mem -> Prop.
  Variable inr : mem -> val -> val -> Prop.
  Hypothesis Hnext : forall m hd v, inr m hd v ->
    exists b o nx, v = Vptr b o
      /\ Mem.loadv Mint32 m (Vptr b (Ptrofs.add o (Ptrofs.repr 96))) = Some nx
      /\ (nx = hd \/ inr m hd nx).
  Hypothesis Hhd : forall m hd v, inr m hd v -> exists b o, hd = Vptr b o.
  Hypothesis Hfo : forall co, (genv_cenv G) ! OLP._ObjectNode = Some co ->
    field_offset G OLP._next (co_members co) = OK (96, Full).
  Variable pre : list statement.
  Hypothesis Hns : nosets OLP._firstObj (app_seq pre Sskip) && nosets OLP._objList (app_seq pre Sskip)
                   && nosets OLP._count (app_seq pre Sskip) && noret (app_seq pre Sskip) = true.
  Hypothesis Hnb : nobrk (app_seq pre Sskip) = true.
  (* THE ROW: the per-object prefix leaves the object in its ring and moves
     the invariant to the node after it *)
  Hypothesis Hiter : forall hd v le m t le' m' out, Pi v m -> inr m hd v ->
    le ! OLP._firstObj = Some v -> le ! OLP._objList = Some hd ->
    exec_stmt function_entry2 G empty_env le m (app_seq pre Sskip) t le' m' out ->
    inr m' hd v /\ forall b o nx, v = Vptr b o ->
      Mem.loadv Mint32 m' (Vptr b (Ptrofs.add o (Ptrofs.repr 96))) = Some nx -> Pi nx m'.

  Definition Jx (hd : val) (le : temp_env) (m : mem) : Prop :=
    le ! OLP._objList = Some hd /\ (exists c, le ! OLP._count = Some (Vint c))
    /\ exists v, le ! OLP._firstObj = Some v /\ (v = hd \/ inr m hd v) /\ Pi v m.

  Lemma s1_Jx : forall hd le m t le1 m1 out1,
    exec_stmt function_entry2 G empty_env le m
      (Ssequence (Sifthenelse COND Sskip Sbreak) (loop_body pre)) t le1 m1 out1 ->
    Jx hd le m ->
    (forall r, out1 <> Out_return r) /\ (exists c, le1 ! OLP._count = Some (Vint c))
    /\ ((out1 = Out_break /\ Pi hd m1) \/ (out1 = Out_normal /\ Jx hd le1 m1)).
  Proof.
    intros hd le m t le1 m1 out1 H (Ho & (c & Hc) & v & Hv & Hvr & HP).
    apply andb_prop in Hns as [Hns' N4]. apply andb_prop in Hns' as [Hns'' N3].
    apply andb_prop in Hns'' as [N1 N2].
    apply seq_inv in H. destruct H as [(t1 & le2 & m2 & t2 & H1 & H2) | (H1 & Hn)].
    - apply if_inv in H1 as (r & b & Hr & Hb & H1).
      destruct b; [ | inv H1 ].
      apply skip_inv in H1 as (-> & -> & _).
      destruct Hvr as [-> | Hin].
      { exfalso. apply ev_binop in Hr as (v1 & v2 & E1 & E2 & E3).
        apply ev_temp in E1. apply ev_temp in E2. rewrite Ho in E1. rewrite Hv in E2.
        injection E1 as <-. injection E2 as <-. cbn [typeof COND] in E3.
        apply cmp_self in E3. subst r. cbn in Hb. discriminate Hb. }
      unfold loop_body in H2. apply app_seq_inv in H2.
      destruct H2 as [(t3 & le3 & m3 & t4 & H3 & H4) | ((t3 & H3) & Hn)].
      + destruct (Hiter hd v le m _ _ _ _ HP Hin Hv Ho H3) as (Hin3 & HPn).
        pose proof (nosets_keep _ _ _ _ _ _ _ _ _ H3 _ N1) as K1.
        pose proof (nosets_keep _ _ _ _ _ _ _ _ _ H3 _ N2) as K2.
        pose proof (nosets_keep _ _ _ _ _ _ _ _ _ H3 _ N3) as K3.
        apply seq_inv in H4. destruct H4 as [(t5 & le5 & m5 & t6 & H5 & H6) | (H5 & Hn)].
        * apply set_inv in H5 as (nv & Env & -> & -> & _).
          apply set_inv in H6 as (cv & Ecv & -> & -> & ->).
          destruct (ev_fld G empty_env m3 le3 OLP._firstObj OLP._ObjectNode OLP._next tnode nv Mint32 96 Hfo eq_refl Env) as (b & o & Hb1 & Hl).
          destruct (Hnext _ _ _ Hin3) as (b' & o' & nx & -> & Hl' & Hnx).
          rewrite K1, Hv in Hb1. injection Hb1 as <- <-.
          rewrite Hl' in Hl. injection Hl as <-.
          apply ev_binop in Ecv as (w1 & w2 & E1 & E2 & E3).
          apply ev_temp in E1. apply ev_const in E2. subst w2.
          rewrite PTree.gso in E1 by (vm_compute; discriminate). rewrite K3, Hc in E1.
          injection E1 as <-. cbn [typeof] in E3. destruct (add_tint _ _ _ _ E3) as (c' & ->).
          split; [ intros r0 Er; discriminate Er | ].
          split; [ exists c'; apply PTree.gss | right ].
          split; [ reflexivity | ].
          split; [ rewrite PTree.gso by (vm_compute; discriminate);
                   rewrite PTree.gso by (vm_compute; discriminate); rewrite K2; exact Ho | ].
          split; [ exists c'; apply PTree.gss | ].
          exists nx. split; [ rewrite PTree.gso by (vm_compute; discriminate); apply PTree.gss | ].
          split; [ exact Hnx | exact (HPn _ _ _ eq_refl Hl') ].
        * apply set_inv in H5 as (_ & _ & _ & _ & E). exfalso. exact (Hn E).
      + exfalso. pose proof (noret_out _ _ _ _ _ _ _ _ _ H3 N4) as Nr.
        destruct (nobrk_out _ _ _ _ _ _ _ _ _ H3 Hnb) as (Nb & Nc).
        destruct out1 as [ | | | o ]; [ exact (Nb eq_refl) | exact (Nc eq_refl) | exact (Hn eq_refl) | exact (Nr o eq_refl) ].
    - apply if_inv in H1 as (r & b & Hr & Hb & H1).
      destruct b; inv H1; [ exfalso; exact (Hn eq_refl) | ].
      split; [ intros r0 Er; discriminate Er | ].
      split; [ exists c; exact Hc | left; split; [ reflexivity | ] ].
      apply ev_binop in Hr as (v1 & v2 & E1 & E2 & E3).
      apply ev_temp in E1. apply ev_temp in E2. rewrite Ho in E1. rewrite Hv in E2.
      injection E1 as <-. injection E2 as <-. cbn [typeof COND] in E3, Hb.
      destruct Hvr as [-> | Hin]; [ exact HP | ].
      destruct (Hnext _ _ _ Hin) as (bv & ov & _ & -> & _ & _).
      destruct (Hhd _ _ _ Hin) as (bh & oh & ->).
      rewrite (cmp_ne_false G _ _ _ _ _ _ E3 Hb). exact HP.
  Qed.

  Lemma loop_Jx : forall hd le m t le' m' out,
    exec_stmt function_entry2 G empty_env le m (Swhile COND (loop_body pre)) t le' m' out ->
    Jx hd le m ->
    Pi hd m' /\ (forall r, out <> Out_return r) /\ (exists c, le' ! OLP._count = Some (Vint c)).
  Proof.
    intros hd le m t le' m' out H. unfold Swhile in H. pose proof (s1_Jx hd) as S1.
    remember empty_env as e0 eqn:Ee.
    remember (Sloop (Ssequence (Sifthenelse COND Sskip Sbreak) (loop_body pre)) Sskip) as S eqn:ES.
    induction H; intros HJ; try discriminate ES; injection ES as E1 E2; subst.
    - destruct (S1 _ _ _ _ _ _ H HJ) as (Hnr & Hc & [(-> & HP) | (-> & _)]).
      + inv H0. split; [ exact HP | split; [ intros r0 Er; discriminate Er | exact Hc ] ].
      + inv H0.
    - inv H1. inv H2.
    - destruct (S1 _ _ _ _ _ _ H HJ) as (_ & _ & [(-> & _) | (_ & HJ1)]); [ inv H0 | ].
      inv H1. exact (IHexec_stmt3 eq_refl Hiter eq_refl S1 HJ1).
  Qed.

  Lemma fn_loop_keeps_ix : forall f, fn_vars f = [] -> fn_return f = tint ->
    fn_params f = [(OLP._objList, tnode); (OLP._firstObj, tnode)] ->
    fn_body f = loop_fn_body pre ->
    forall m hd v0 t m' vr, Pi v0 m -> (v0 = hd \/ inr m hd v0) ->
      eval_funcall function_entry2 G m (Internal f) [hd; v0] t m' vr -> Pi hd m' /\ exists c, vr = Vint c.
  Proof.
    intros f Hvars Hret Hpar Hbody m hd v0 t m' vr HP Hv0 Hev.
    remember (Internal f) as fd eqn:Efd. remember [hd; v0] as va eqn:Eva.
    destruct Hev as [mm ff vargs tt ee lea leb mm1 mm2 oo vv mm3 Hfe Hx Hor Hfr | ];
      [ injection Efd as Eff; subst ff | discriminate Efd ]. subst vargs.
    destruct Hfe as [_ _ _ Hav Hb].
    rewrite Hvars in Hav. inversion Hav; subst ee mm1; subst e m; rename mm into m.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rewrite Hpar in Hb; cbn in Hb; injection Hb as <- end.
    match goal with Hx : exec_stmt _ _ _ _ _ (fn_body f) _ _ _ _ |- _ =>
      rewrite Hbody in Hx; unfold loop_fn_body in Hx; rename Hx into Hx0 end.
    apply seq_inv in Hx0. destruct Hx0 as [(ta1 & lea1 & ma1 & ta2 & Y1 & Y2) | (Y1 & Yn)];
      [ | apply set_inv in Y1 as (_ & _ & _ & _ & E); exfalso; exact (Yn E) ].
    apply set_inv in Y1 as (cv & Ecv & -> & -> & _). apply ev_const in Ecv. subst cv.
    assert (HJ : Jx hd (PTree.set OLP._count (Vint (Int.repr 0))
                       (PTree.set OLP._firstObj v0
                          (PTree.set OLP._objList hd (create_undef_temps (fn_temps f))))) m).
    { split; [ rewrite PTree.gso by (vm_compute; discriminate);
               rewrite PTree.gso by (vm_compute; discriminate); apply PTree.gss | ].
      split; [ eexists; apply PTree.gss | ].
      exists v0. split; [ rewrite PTree.gso by (vm_compute; discriminate); apply PTree.gss | ].
      exact (conj Hv0 HP). }
    apply seq_inv in Y2. destruct Y2 as [(ta3 & lea3 & ma3 & ta4 & Y3 & Y4) | (Y3 & Yn)].
    - destruct (loop_Jx _ _ _ _ _ _ _ Y3 HJ) as (HP3 & _ & c & Hc).
      apply ret_inv in Y4 as (-> & rv & Erv & ->). apply ev_temp in Erv. rewrite Hc in Erv.
      injection Erv as <-.
      match goal with Ho : outcome_result_value _ _ _ _ |- _ => rewrite Hret in Ho; destruct Ho as (_ & Hcast) end.
      destruct (cast_tint _ _ _ Hcast) as (c' & ->).
      match goal with Hfr : Mem.free_list _ _ = Some _ |- _ => cbn in Hfr; injection Hfr as <- end.
      split; [ exact HP3 | eauto ].
    - destruct (loop_Jx _ _ _ _ _ _ _ Y3 HJ) as (HP3 & Hnr & _).
      exfalso.
      match goal with Ho : outcome_result_value _ _ _ _ |- _ => rewrite Hret in Ho; rename Ho into Hor end.
      destruct oo as [ | | | [[rv rt]|] ]; cbn in Hor; try contradiction.
      all: first [ exact (Yn eq_refl) | exact (Hnr _ eq_refl) ].
  Qed.
End LoopIx.

(* ---------------------------------------------------------------------- *)
(* 5. Generic statement and value facts.                                   *)
(* ---------------------------------------------------------------------- *)
(* straight-line statements end normally *)
Fixpoint plain (s : statement) : bool :=
  match s with
  | Sskip | Sset _ _ | Sassign _ _ | Scall _ _ _ | Sbuiltin _ _ _ _ => true
  | Ssequence s1 s2 | Sifthenelse _ s1 s2 => plain s1 && plain s2
  | _ => false
  end.

Lemma plain_out : forall G e le m s t le' m' out,
  exec_stmt function_entry2 G e le m s t le' m' out -> plain s = true -> out = Out_normal.
Proof.
  intros G e le m s t le' m' out H. induction H; intros Hp; cbn [plain] in Hp; try discriminate Hp; try reflexivity.
  all: repeat match goal with Ha : (_ && _) = true |- _ => apply andb_prop in Ha; destruct Ha end.
  - auto.
  - exfalso. match goal with Hn : ?o <> Out_normal, IH : _ -> ?o = Out_normal |- _ => exact (Hn (IH ltac:(assumption))) end.
  - destruct b; auto.
Qed.

Lemma cast_tnode : forall v v' m, sem_cast v tnode tnode m = Some v' -> v' = v.
Proof. intros v v' m H. destruct v; vm_compute in H; try discriminate H; injection H as <-; reflexivity. Qed.

Lemma cast_to_uint : forall c v m, sem_cast (Vint c) tint tuint m = Some v -> exists c', v = Vint c'.
Proof. intros c v m H. vm_compute in H. injection H as <-. eauto. Qed.
Lemma cast_uu : forall c v m, sem_cast (Vint c) tuint tuint m = Some v -> exists c', v = Vint c'.
Proof. intros c v m H. vm_compute in H. injection H as <-. eauto. Qed.

(* u + i on 32-bit: an int, whatever the left operand loaded *)
Lemma add_u_i : forall (G : genv) v1 c v m,
  sem_binary_operation G Oadd v1 tuint (Vint c) tint m = Some v -> exists c', v = Vint c'.
Proof.
  intros G v1 c v m H. destruct v1 as [| i | l | f | f | b o].
  - assert (E : sem_binary_operation G Oadd Vundef tuint (Vint c) tint m = None) by reflexivity.
    rewrite E in H. discriminate H.
  - assert (E : sem_binary_operation G Oadd (Vint i) tuint (Vint c) tint m = Some (Vint (Int.add i c))) by reflexivity.
    rewrite E in H. injection H as <-. eauto.
  - assert (E : sem_binary_operation G Oadd (Vlong l) tuint (Vint c) tint m = None) by reflexivity.
    rewrite E in H. discriminate H.
  - assert (E : sem_binary_operation G Oadd (Vfloat f) tuint (Vint c) tint m = None) by reflexivity.
    rewrite E in H. discriminate H.
  - assert (E : sem_binary_operation G Oadd (Vsingle f) tuint (Vint c) tint m = None) by reflexivity.
    rewrite E in H. discriminate H.
  - assert (E : sem_binary_operation G Oadd (Vptr b o) tuint (Vint c) tint m = None) by reflexivity.
    rewrite E in H. discriminate H.
Qed.

Lemma exl1 : forall (G : genv) e le m a tys vs, eval_exprlist G e le m [a] tys vs ->
  exists ty1 v1 w1, tys = [ty1] /\ vs = [w1] /\ eval_expr G e le m a v1 /\ sem_cast v1 (typeof a) ty1 m = Some w1.
Proof.
  intros G e le m a tys vs H. inv H.
  match goal with Hx : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hx end. eauto 10.
Qed.

Lemma exl2 : forall (G : genv) e le m a1 a2 tys vs, eval_exprlist G e le m [a1; a2] tys vs ->
  exists ty1 ty2 v1 v2 w1 w2, tys = [ty1; ty2] /\ vs = [w1; w2]
    /\ eval_expr G e le m a1 v1 /\ sem_cast v1 (typeof a1) ty1 m = Some w1
    /\ eval_expr G e le m a2 v2 /\ sem_cast v2 (typeof a2) ty2 m = Some w2.
Proof.
  intros G e le m a1 a2 tys vs H. inv H.
  match goal with Hx : eval_exprlist _ _ _ _ (_ :: nil) _ _ |- _ => inv Hx end.
  match goal with Hx : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hx end. eauto 20.
Qed.

(* a store of an int keeps every noref *)
Lemma store_int_noref : forall m b0 ofs c m' b,
  Mem.store Mint32 m b0 ofs (Vint c) = Some m' -> ObjPhase.noref b m -> ObjPhase.noref b m'.
Proof.
  intros m b0 ofs c m' b Hs Hn b' q Hne. specialize (Hn b' q Hne).
  rewrite (Mem.store_mem_contents _ _ _ _ _ _ Hs).
  destruct (peq b' b0) as [-> | N].
  - rewrite PMap.gss.
    destruct (zlt q ofs) as [Lq | Lq]; [ rewrite Mem.setN_outside by lia; exact Hn | ].
    destruct (zle (ofs + Z.of_nat (length (encode_val Mint32 (Vint c)))) q) as [Hq | Hq];
      [ rewrite Mem.setN_outside by lia; exact Hn | ].
    pose proof (Mem.setN_in (encode_val Mint32 (Vint c)) ofs q ((Mem.mem_contents m) !! b0) ltac:(lia)) as I.
    destruct (ZMap.get q (Mem.setN (encode_val Mint32 (Vint c)) ofs ((Mem.mem_contents m) !! b0))) as [ | x | v0 qq nn ]; [ exact Logic.I | exact Logic.I | ].
    cbn [encode_val inj_bytes] in I. apply in_map_iff in I as (x & Ex & _). discriminate Ex.
  - rewrite PMap.gso by exact N. exact Hn.
Qed.

(* ---------------------------------------------------------------------- *)
(* 6. The real functions on the twelve-TU link.                            *)
(* ---------------------------------------------------------------------- *)
Lemma sa_shape : fn_body OLP.f_update_objects_starting_at
                 = loop_fn_body (loop_pre OLP.f_update_objects_starting_at).
Proof. reflexivity. Qed.
Lemma ts_shape : fn_body OLP.f_update_objects_during_time_stop
                 = loop_fn_body (loop_pre OLP.f_update_objects_during_time_stop).
Proof. reflexivity. Qed.
Lemma sa_ns : nosets OLP._firstObj (app_seq (loop_pre OLP.f_update_objects_starting_at) Sskip)
  && nosets OLP._objList (app_seq (loop_pre OLP.f_update_objects_starting_at) Sskip)
  && nosets OLP._count (app_seq (loop_pre OLP.f_update_objects_starting_at) Sskip)
  && noret (app_seq (loop_pre OLP.f_update_objects_starting_at) Sskip) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma ts_ns : nosets OLP._firstObj (app_seq (loop_pre OLP.f_update_objects_during_time_stop) Sskip)
  && nosets OLP._objList (app_seq (loop_pre OLP.f_update_objects_during_time_stop) Sskip)
  && nosets OLP._count (app_seq (loop_pre OLP.f_update_objects_during_time_stop) Sskip)
  && noret (app_seq (loop_pre OLP.f_update_objects_during_time_stop) Sskip) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma dm_sa : (prog_defmap OLP.prog) ! OLP._update_objects_starting_at
              = Some (Gfun (Internal OLP.f_update_objects_starting_at)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_ts : (prog_defmap OLP.prog) ! OLP._update_objects_during_time_stop
              = Some (Gfun (Internal OLP.f_update_objects_during_time_stop)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_il : (prog_defmap OLP.prog) ! OLP._update_objects_in_list
              = Some (Gfun (Internal OLP.f_update_objects_in_list)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_ter : (prog_defmap OLP.prog) ! OLP._update_terrain_objects
               = Some (Gfun (Internal OLP.f_update_terrain_objects)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_nt : (prog_defmap OLP.prog) ! OLP._update_non_terrain_objects
              = Some (Gfun (Internal OLP.f_update_non_terrain_objects)).
Proof. vm_compute. reflexivity. Qed.

(* the lists of each walk: terrain (update_terrain_objects: 11, 9) and the
   rest (sObjectListUpdateOrder[2..9]) *)
Definition ter_ls : list nat := [11; 9]%nat.
Definition nt_ls : list nat := [10; 0; 5; 4; 2; 6; 8; 12]%nat.

Definition hd_in (G : genv) (ls : list nat) (hd : val) : Prop :=
  exists la i, Genv.find_symbol G OLP._gObjectListArray = Some la /\ In i ls /\ hd = head_v la i.
Definition in_ring_l (G : genv) (bm : block) (ls : list nat) (m : mem) (hd v : val) : Prop :=
  in_ring G bm m hd v /\ hd_in G ls hd.

(* THE ROW SHAPES (per object of a walked list) *)
Definition step_row (G : genv) (P : mem -> Prop) (inr : mem -> val -> val -> Prop) (f : function) : Prop :=
  forall hd v le m t le' m' out, P m -> inr m hd v ->
    le ! OLP._firstObj = Some v -> le ! OLP._objList = Some hd ->
    exec_stmt function_entry2 G empty_env le m (app_seq (loop_pre f) Sskip) t le' m' out ->
    P m' /\ inr m' hd v.
Definition step_nr_row (G : genv) (P : mem -> Prop) (inr : mem -> val -> val -> Prop) (f : function) : Prop :=
  forall b, Ple (Genv.genv_next G) b ->
  forall hd v le m t le' m' out, P m -> ObjPhase.noref b m -> inr m hd v ->
    le ! OLP._firstObj = Some v -> le ! OLP._objList = Some hd ->
    exec_stmt function_entry2 G empty_env le m (app_seq (loop_pre f) Sskip) t le' m' out ->
    ObjPhase.noref b m'.

(* THE TERRAIN ROW WITH THE SURFACE BUDGET (2026-11-02).  On top of the
   step row: the object v starts under its budget (vbud: the counter plus
   v's dynamic surfaces stays within NS + DS, or a time stop), and the step
   claims ter_post:
   (a) lists 11 and 9 only grow, at the tail, by objects with no budget;
   (b) the budget (the script it runs) of every node of lists 11 / 9 is
       unchanged;
   (c) the counter grows by at most v's budget (0 in a time stop);
   (d) the time-stop gate is unchanged.
   TRUTH / PHANTOM CHECKS (CollisionCensus, vm over the generated code):
   (a) list surgery is only try_allocate_object (tail insertion: its
       generated stores are freeList.next, nextObj.prev = destList->prev,
       nextObj.next = destList, destList->prev->next, destList->prev:
       list_value) and deallocate_object, reached only through
       allocate_object's pool-full path (unload_object of the FIRST node of
       list 12, find_unimportant_object; or the infinite loop when list 12
       is empty: no execution).  So a step never removes or reorders a node
       of list 11 or 9; the bubble / splash "move" is that list-12 unload
       plus a tail spawn.  Spawned objects run their BEGIN list's script;
       the only scripts that BEGIN in 9 / 11 are the box, the lid and
       bhvCoinFormation (terrain_value), and nothing spawns a box or a lid
       (spawn_value), so a spawned 9 / 11 node runs bhvCoinFormation:
       budget 0.  TRUE.
   (b) another object's curBhvCommand is written only by create_object (the
       new object) and obj_set_held_state (reachable from no terrain
       script: terrain_value); v's own stays in its script (no terrain
       script jumps: terrain_value).  The budget reads the RUNNING script,
       not the behavior field, so cur_obj_set_behavior (coin code) cannot
       change it mid-step.  TRUE.
   (c) only the box and lid scripts reach load_object_collision_model
       (loaders_value), the box once per step (bhv_exclamation_box_loop ->
       one action -> exclamation_box_act_2's one call: loader_calls), the
       lid once per loop pass (its script's CALL_NATIVE, sites []); the
       mesh is v's collisionData, pinned to NULL (no load: the NULL read
       has no execution) or v's own mesh (ObjWorld.ter_ok), whose
       initializer is pinned (12 / 2 triangles, mesh_tris_pinned), so a
       step adds at most 12 / 2 surfaces; the loader is gated on
       TIME_STOP_ACTIVE (gates_value).  Over phantom states: v's script
       read at m (the budget is m's), a box whose behavior field changes
       mid-step (irrelevant: the script is read), an object loading twice
       (no reached path calls the loader twice per step).  TRUE.
   (d) no terrain-list script reaches a gTimeStopState store
       (terrain_value; the writers are bhvMario and two star spawners,
       ts_writers_value).  TRUE.
   NOT CLAIMED (FOUND 2026-11-02): the node counter's 4-per-triangle bound,
   false over unpinned transforms (ObjWorld 3c). *)
Definition vbud (G : genv) (m : mem) (v : val) : Prop :=
  OW.tsa G m = true \/ exists pool k, Genv.find_symbol G OLP._gObjectPool = Some pool
    /\ v = OW.slot_v pool k /\ OW.ctrv G m + OW.sdyn G pool m k <= OW.NS + OW.DS.

Definition ter_post (G : genv) (m m' : mem) (v : val) : Prop :=
  forall pool la rs rs', Genv.find_symbol G OLP._gObjectPool = Some pool ->
    Genv.find_symbol G OLP._gObjectListArray = Some la ->
    OW.rings m pool la = Some rs -> OW.rings m' pool la = Some rs' ->
    (forall L, In L ter_ls -> exists ext, nth L rs' [] = nth L rs [] ++ ext
                                    /\ Forall (fun k => OW.sdyn G pool m' k = 0) ext)
    /\ (forall k, In k (nth 11 rs []) \/ In k (nth 9 rs []) -> OW.sdyn G pool m' k = OW.sdyn G pool m k)
    /\ (forall k, v = OW.slot_v pool k -> OW.ctrv G m' <= OW.ctrv G m + OW.dyn G pool m k)
    /\ OW.tsa G m' = OW.tsa G m.

Definition ter_row (G : genv) (bm : block) (P : mem -> Prop) (f : function) : Prop :=
  forall hd v le m t le' m' out, P m -> in_ring_l G bm ter_ls m hd v -> vbud G m v ->
    le ! OLP._firstObj = Some v -> le ! OLP._objList = Some hd ->
    exec_stmt function_entry2 G empty_env le m (app_seq (loop_pre f) Sskip) t le' m' out ->
    P m' /\ in_ring_l G bm ter_ls m' hd v /\ ter_post G m m' v.

Definition sz_ok (ce : composite_env) (S : ident) (n : Z) : bool :=
  match ce ! S with Some co => Z.eqb (co_sizeof co) n | None => false end.

Lemma sz_ok_lift : forall ce ce' S n, sz_ok ce S n = true ->
  (forall id co, ce ! id = Some co -> ce' ! id = Some co) -> sizeof ce' (Tstruct S noattr) = n.
Proof.
  intros ce ce' S n H Hext. unfold sz_ok in H.
  destruct (ce ! S) as [co|] eqn:E; [ | discriminate H ].
  cbn [sizeof]. rewrite (Hext _ _ E). apply Z.eqb_eq. exact H.
Qed.

Lemma sz_ok_node : sz_ok (prog_comp_env OLP.prog) OLP._ObjectNode OW.NODESZ = true.
Proof. vm_compute. reflexivity. Qed.

Ltac getnorm_tac := repeat first [ rewrite PTree.gss | rewrite PTree.gso by neq ]; reflexivity.

Section Real.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Notation G := (lp_ge lp).
  Variable bm : block.

  Lemma cenv_olp : forall id co, (prog_comp_env OLP.prog) ! id = Some co -> (genv_cenv G) ! id = Some co.
  Proof.
    intros id co H. pose proof (ObjPhase.LO_olp lp H12) as LO.
    Local Transparent Linker_program.
    unfold linkorder, Linker_program, linkorder_program in LO. destruct LO as [_ HCo].
    exact (HCo id co H).
  Qed.

  Lemma fo_next : forall co, (genv_cenv G) ! OLP._ObjectNode = Some co ->
    field_offset G OLP._next (co_members co) = OK (96, Full).
  Proof. apply (fo_ok_lift (prog_comp_env OLP.prog)); [ vm_compute; reflexivity | exact cenv_olp ]. Qed.

  Lemma sz_node : sizeof G (Tstruct OLP._ObjectNode noattr) = OW.NODESZ.
  Proof.
    exact (sz_ok_lift _ _ _ _ sz_ok_node cenv_olp).
  Qed.

  Lemma fun_olp : forall id f, (prog_defmap OLP.prog) ! id = Some (Gfun (Internal f)) ->
    forall b fd, Genv.find_symbol G id = Some b ->
      Genv.find_funct G (Vptr b Ptrofs.zero) = Some fd -> fd = Internal f.
  Proof. intros id f Hdm. exact (ObjPhase.fun_of lp _ _ _ (ObjPhase.LO_olp lp H12) Hdm). Qed.

  Section Ls.
    Variable ls : list nat.
    Variable P : mem -> Prop.
    Notation inr := (in_ring_l G bm ls).

    Lemma next_l : forall m hd v, inr m hd v ->
      exists b o nx, v = Vptr b o
        /\ Mem.loadv Mint32 m (Vptr b (Ptrofs.add o (Ptrofs.repr 96))) = Some nx
        /\ (nx = hd \/ inr m hd nx).
    Proof.
      intros m hd v (Hr & Hh). destruct (ring_next G bm m hd v Hr) as (b & o & nx & E & Hl & Hn).
      exists b, o, nx. split; [ exact E | split; [ exact Hl | ] ].
      destruct Hn as [-> | Hn]; [ left; reflexivity | right; exact (conj Hn Hh) ].
    Qed.

    Hypothesis Hsa : step_row G P inr OLP.f_update_objects_starting_at.
    Hypothesis Hts : step_row G P inr OLP.f_update_objects_during_time_stop.

    Lemma sa_keeps : forall m hd v0 t m' vr, P m -> (v0 = hd \/ inr m hd v0) ->
      eval_funcall function_entry2 G m (Internal OLP.f_update_objects_starting_at) [hd; v0] t m' vr ->
      P m' /\ exists c, vr = Vint c.
    Proof.
      exact (fn_loop_keeps G P inr next_l fo_next (loop_pre OLP.f_update_objects_starting_at) sa_ns Hsa
               OLP.f_update_objects_starting_at eq_refl eq_refl eq_refl sa_shape).
    Qed.
    Lemma ts_keeps : forall m hd v0 t m' vr, P m -> (v0 = hd \/ inr m hd v0) ->
      eval_funcall function_entry2 G m (Internal OLP.f_update_objects_during_time_stop) [hd; v0] t m' vr ->
      P m' /\ exists c, vr = Vint c.
    Proof.
      exact (fn_loop_keeps G P inr next_l fo_next (loop_pre OLP.f_update_objects_during_time_stop) ts_ns Hts
               OLP.f_update_objects_during_time_stop eq_refl eq_refl eq_refl ts_shape).
    Qed.

    (* one branch of update_objects_in_list: count = <walk>(objList, firstObj) *)
    Lemma il_branch : forall fid f tmp le m t le' m' out hd nx,
      (prog_defmap OLP.prog) ! fid = Some (Gfun (Internal f)) ->
      (forall t m' vr, eval_funcall function_entry2 G m (Internal f) [hd; nx] t m' vr ->
         P m' /\ exists c, vr = Vint c) ->
      exec_stmt function_entry2 G empty_env le m
        (Ssequence
           (Scall (Some tmp) (Evar fid (Tfunction [tnode; tnode] tint cc_default))
              [Etempvar OLP._objList tnode; Etempvar OLP._firstObj tnode])
           (Sset OLP._count (Etempvar tmp tint))) t le' m' out ->
      P m -> le ! OLP._objList = Some hd -> le ! OLP._firstObj = Some nx ->
      P m' /\ out = Out_normal /\ exists c, le' ! OLP._count = Some (Vint c).
    Proof.
      intros fid f tmp le m t le' m' out hd nx Hdm Hk H HP Ho Hf.
      apply seq_inv in H as [(t1 & le1 & m1 & t2 & H1 & H2) | (H1 & Hn)];
        [ | exfalso; exact (Hn (plain_out _ _ _ _ _ _ _ _ _ H1 eq_refl)) ].
      apply call_inv in H1 as (tya & tyr & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hc & -> & _).
      cbn in Hcf. injection Hcf as <- <- <-.
      destruct (ev_fun G empty_env m le fid (Tfunction [tnode; tnode] tint cc_default) vf (PTree.gempty _ _) eq_refl Evf) as (bf & Hs & ->).
      rewrite (fun_olp _ _ Hdm bf fd Hs Hff) in Hc.
      destruct (exl2 _ _ _ _ _ _ _ _ Eal) as (ty1 & ty2 & v1 & v2 & w1 & w2 & E1 & -> & Ev1 & C1 & Ev2 & C2).
      injection E1 as <- <-.
      apply ev_temp in Ev1. apply ev_temp in Ev2. rewrite Ho in Ev1. rewrite Hf in Ev2.
      injection Ev1 as <-. injection Ev2 as <-. cbn [typeof] in C1, C2.
      apply cast_tnode in C1. apply cast_tnode in C2. subst w1 w2.
      destruct (Hk _ _ _ Hc) as (HP1 & c & ->).
      apply set_inv in H2 as (cv & Ecv & -> & -> & ->). apply ev_temp in Ecv.
      cbn [set_opttemp] in Ecv. rewrite PTree.gss in Ecv. injection Ecv as <-.
      split; [ exact HP1 | split; [ reflexivity | exists c; apply PTree.gss ] ].
    Qed.

    (* update_objects_in_list(head): PROVED from the two walks *)
    Theorem in_list_keeps : forall m hd t m' vr, P m -> is_head G bm m hd -> hd_in G ls hd ->
      eval_funcall function_entry2 G m (Internal OLP.f_update_objects_in_list) [hd] t m' vr ->
      P m' /\ exists c, vr = Vint c.
    Proof.
      intros m hd t m' vr HP Hh Hin Hev.
      remember (Internal OLP.f_update_objects_in_list) as fd eqn:Efd. remember [hd] as va eqn:Eva.
      destruct Hev as [mm ff vargs tt ee lea leb mm1 mm2 oo vv mm3 Hfe Hx Hor Hfr | ];
        [ injection Efd as Eff; subst ff | discriminate Efd ]. subst vargs.
      destruct Hfe as [_ _ _ Hav Hb].
      cbn [fn_vars OLP.f_update_objects_in_list] in Hav. inversion Hav; subst ee mm1; subst e m; rename mm into m.
      cbn [fn_params OLP.f_update_objects_in_list bind_parameter_temps] in Hb. injection Hb as <-.
      unfold OLP.f_update_objects_in_list in Hx. cbn [fn_body] in Hx.
      destruct (head_next G bm m hd Hh) as (bh & oh & nx & Ehd & Hlh & Hnx).
      apply seq_inv in Hx as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)];
        [ | exfalso; exact (Xn (plain_out _ _ _ _ _ _ _ _ _ X1 eq_refl)) ].
      apply set_inv in X1 as (nv & Env & -> & -> & _).
      destruct (ev_fld G empty_env m _ OLP._objList OLP._ObjectNode OLP._next tnode nv Mint32 96 fo_next eq_refl Env)
        as (b & o & Hbo & Hl).
      rewrite PTree.gss in Hbo. injection Hbo as Ehd2. rewrite Ehd2 in Ehd. injection Ehd as <- <-.
      rewrite Hl in Hlh. injection Hlh as <-. subst hd.
      assert (Hnx' : nv = Vptr b o \/ inr m (Vptr b o) nv).
      { destruct Hnx as [E | E]; [ left; exact E | right; exact (conj E Hin) ]. }
      assert (Hnp : exists b' o', nv = Vptr b' o').
      { destruct Hnx as [-> | (pool & la & rs & i & k & _ & _ & _ & _ & ->)]; [ eauto | unfold OW.slot_v; eauto ]. }
      apply seq_inv in X2 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)];
        [ | exfalso; exact (Xn (plain_out _ _ _ _ _ _ _ _ _ X3 eq_refl)) ].
      apply seq_inv in X3 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)];
        [ | exfalso; exact (Xn (plain_out _ _ _ _ _ _ _ _ _ X5 eq_refl)) ].
      apply set_inv in X5 as (w & _ & -> & -> & _).
      apply if_inv in X6 as (cv & bb & _ & _ & X6).
      assert (K : P m3 /\ exists c, le3 ! OLP._count = Some (Vint c)).
      { destruct bb.
        - destruct (il_branch _ _ _ _ _ _ _ _ _ (Vptr b o) nv dm_sa (fun t0 m0' vr0 Hc => sa_keeps m _ _ t0 m0' vr0 HP Hnx' Hc)
                      X6 HP ltac:(getnorm_tac) ltac:(getnorm_tac)) as (HP3 & _ & Hc3).
          exact (conj HP3 Hc3).
        - destruct (il_branch _ _ _ _ _ _ _ _ _ (Vptr b o) nv dm_ts (fun t0 m0' vr0 Hc => ts_keeps m _ _ t0 m0' vr0 HP Hnx' Hc)
                      X6 HP ltac:(getnorm_tac) ltac:(getnorm_tac)) as (HP3 & _ & Hc3).
          exact (conj HP3 Hc3). }
      destruct K as (HP3 & c & Hc3).
      apply ret_inv in X4 as (-> & rv & Erv & ->). apply ev_temp in Erv. rewrite Hc3 in Erv. injection Erv as <-.
      cbn [fn_return OLP.f_update_objects_in_list outcome_result_value] in Hor. destruct Hor as (_ & Hcast).
      destruct (cast_tint _ _ _ Hcast) as (c' & ->).
      cbn in Hfr. injection Hfr as <-.
      split; [ exact HP3 | eauto ].
    Qed.
  End Ls.

  (* ---- 7. the list walks of update_terrain_objects / update_non_terrain_objects ---- *)
  Lemma ofs_idx : forall idx, (idx < 13)%nat ->
    Ptrofs.add Ptrofs.zero (Ptrofs.mul (Ptrofs.repr OW.NODESZ) (Ptrofs.of_ints (Int.repr (Z.of_nat idx))))
    = Ptrofs.repr (Z.of_nat idx * OW.NODESZ).
  Proof. intros idx H. do 13 (destruct idx as [|idx]; [ reflexivity | ]). lia. Qed.

  Ltac kill_abn :=
    match goal with
    | A : exec_stmt _ _ _ _ _ ?s _ _ _ ?o, Hn : ?o <> Out_normal |- _ =>
        exfalso; exact (Hn (plain_out _ _ _ _ _ _ _ _ _ A eq_refl))
    end.

  Lemma tmp_int : forall e le m x ty c v, le ! x = Some (Vint c) ->
    eval_expr G e le m (Etempvar x ty) v -> exists c', v = Vint c'.
  Proof. intros e le m x ty c v H Ev. apply ev_temp in Ev. rewrite H in Ev. injection Ev as <-. eauto. Qed.

  Section Walk.
    Variable ls : list nat.
    Variable P : mem -> Prop.
    Hypothesis HPow : forall m, P m -> OW.obj_w G bm m.
    Hypothesis Hsa : step_row G P (in_ring_l G bm ls) OLP.f_update_objects_starting_at.
    Hypothesis Hts : step_row G P (in_ring_l G bm ls) OLP.f_update_objects_during_time_stop.
    Hypothesis Hctr : forall m b c m', P m -> Genv.find_symbol G OLP._gObjectCounter = Some b ->
      Mem.store Mint32 m b 0 (Vint c) = Some m' -> P m'.

    (* tmp = update_objects_in_list(gObjectLists + idx) *)
    Lemma call_il : forall e le m t le' m' out tmpl tmp a idx,
      P m -> e ! OLP._gObjectLists = None -> e ! OLP._update_objects_in_list = None ->
      In idx ls -> (idx < 13)%nat -> typeof a = tint ->
      (forall gv v, eval_expr G e (PTree.set tmpl gv le) m a v -> v = Vint (Int.repr (Z.of_nat idx))) ->
      exec_stmt function_entry2 G e le m
        (Ssequence (Sset tmpl (Evar OLP._gObjectLists tnode))
           (Scall (Some tmp) (Evar OLP._update_objects_in_list (Tfunction [tnode] tint cc_default))
              [Ebinop Oadd (Etempvar tmpl tnode) a tnode])) t le' m' out ->
      P m' /\ out = Out_normal /\ exists c gv, le' = PTree.set tmp (Vint c) (PTree.set tmpl gv le).
    Proof.
      intros e le m t le' m' out tmpl tmp a idx HP He1 He2 Hin Hidx Hta Ha H.
      apply seq_inv in H as [(t1 & le1 & m1 & t2 & H1 & H2) | (H1 & Hn)]; [ | kill_abn ].
      apply set_inv in H1 as (gv & Egv & -> & -> & _).
      destruct (ev_gvar G e m le OLP._gObjectLists tnode gv Mint32 He1 eq_refl Egv) as (bg & Hbg & Hlg).
      destruct (HPow m HP) as (pool & la & fl & gol & gmo & sdp & gdi & rs & fs & S1 & S2 & S3 & S4 & S5 & S6 & S7 & Hc).
      rewrite Hbg in S4. injection S4 as <-.
      cbn [Mem.loadv] in Hlg. rewrite Ptrofs.unsigned_zero, (OW.ow_gol _ _ _ _ _ _ _ _ _ _ _ _ Hc) in Hlg.
      injection Hlg as <-.
      apply call_inv in H2 as (tya & tyr & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hcall & -> & ->).
      cbn in Hcf. injection Hcf as <- <- <-.
      destruct (ev_fun G e m _ OLP._update_objects_in_list (Tfunction [tnode] tint cc_default) vf He2 eq_refl Evf)
        as (bf & Hs & ->).
      rewrite (fun_olp _ _ dm_il bf fd Hs Hff) in Hcall.
      destruct (exl1 _ _ _ _ _ _ _ Eal) as (ty1 & v1 & w1 & E1 & -> & Ev1 & C1). injection E1 as <-.
      apply ev_binop in Ev1 as (x1 & x2 & X1 & X2 & X3).
      apply ev_temp in X1. rewrite PTree.gss in X1. injection X1 as <-.
      rewrite (Ha _ _ X2) in X3. cbn [typeof] in X3. rewrite Hta in X3.
      assert (E : sem_binary_operation G Oadd (Vptr la Ptrofs.zero) tnode (Vint (Int.repr (Z.of_nat idx))) tint m
                  = Some (Vptr la (Ptrofs.add Ptrofs.zero (Ptrofs.mul (Ptrofs.repr (sizeof G (Tstruct OLP._ObjectNode noattr)))
                                                                    (Ptrofs.of_ints (Int.repr (Z.of_nat idx))))))) by reflexivity.
      rewrite E, sz_node, (ofs_idx _ Hidx) in X3. injection X3 as <-.
      cbn [typeof] in C1. apply cast_tnode in C1. subst w1.
      assert (Hh : is_head G bm m (head_v la idx)).
      { exists pool, la, rs, idx. split; [ | split; [ unfold OW.NLIST; lia | reflexivity ] ].
        split; [ exact S1 | split; [ exact S2 | ] ]. exists fl, bg, gmo, sdp, gdi, fs. tauto. }
      assert (Hhd : hd_in G ls (head_v la idx)) by (exists la, idx; tauto).
      destruct (in_list_keeps ls P Hsa Hts m _ _ m' vres HP Hh Hhd Hcall) as (HP' & c & ->).
      split; [ exact HP' | split; [ reflexivity | exists c, (Vptr la Ptrofs.zero); reflexivity ] ].
    Qed.

    (* gObjectCounter = <an int> *)
    Lemma ctr_set : forall e le m a t le' m' out, P m -> e ! OLP._gObjectCounter = None ->
      (forall v, eval_expr G e le m a v -> exists c, v = Vint c) -> (typeof a = tint \/ typeof a = tuint) ->
      exec_stmt function_entry2 G e le m (Sassign (Evar OLP._gObjectCounter tuint) a) t le' m' out ->
      P m' /\ le' = le /\ out = Out_normal.
    Proof.
      intros e le m a t le' m' out HP He Ha Ht H.
      apply assign_inv in H as (b & o & bf & v2 & v & Hlv & Ev & Hcast & Has & -> & ->).
      destruct (lv_gvar G e m le _ _ _ _ _ He Hlv) as (Hs & -> & ->).
      destruct (Ha _ Ev) as (c & ->). cbn [typeof] in Hcast, Has.
      assert (Hv : exists c', v = Vint c').
      { destruct Ht as [Ht | Ht]; rewrite Ht in Hcast; [ exact (cast_to_uint _ _ _ Hcast) | exact (cast_uu _ _ _ Hcast) ]. }
      destruct Hv as (c' & ->).
      pose proof (store_by_value G tuint m b Ptrofs.zero Full (Vint c') m' Mint32 eq_refl eq_refl Has) as Hst.
      rewrite Ptrofs.unsigned_zero in Hst.
      exact (conj (Hctr _ _ _ _ HP Hs Hst) (conj eq_refl eq_refl)).
    Qed.
  End Walk.

  (* update_terrain_objects: lists 11 and 9 *)
  Section Terrain.
    Variable P : mem -> Prop.
    Hypothesis HPow : forall m, P m -> OW.obj_w G bm m.
    Hypothesis Hsa : step_row G P (in_ring_l G bm ter_ls) OLP.f_update_objects_starting_at.
    Hypothesis Hts : step_row G P (in_ring_l G bm ter_ls) OLP.f_update_objects_during_time_stop.
    Hypothesis Hctr : forall m b c m', P m -> Genv.find_symbol G OLP._gObjectCounter = Some b ->
      Mem.store Mint32 m b 0 (Vint c) = Some m' -> P m'.

    Theorem terrain_keeps : ObjPhase.call_keeps G P OLP._update_terrain_objects.
    Proof.
      intros bf fd m vargs t m' vr Hs Hf HP Hev.
      rewrite (fun_olp _ _ dm_ter bf fd Hs Hf) in Hev.
      remember (Internal OLP.f_update_terrain_objects) as fd' eqn:Efd.
      destruct Hev as [mm ff va tt ee lea leb mm1 mm2 oo vv mm3 Hfe Hx Hor Hfr | ];
        [ injection Efd as Eff; subst ff | discriminate Efd ].
      destruct Hfe as [_ _ _ Hav Hb].
      cbn [fn_vars OLP.f_update_terrain_objects] in Hav. inversion Hav; subst ee mm1; subst e m; rename mm into m.
      unfold OLP.f_update_terrain_objects in Hx. cbn [fn_body] in Hx.
      apply seq_inv in Hx as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_abn ].
      apply seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_abn ].
      destruct (call_il ter_ls P HPow Hsa Hts _ _ _ _ _ _ _ _ _ (Econst_int (Int.repr 11) tint) 11%nat HP (PTree.gempty _ _) (PTree.gempty _ _)
                  ltac:(left; reflexivity) ltac:(lia) eq_refl (fun gv v Ev => ev_const _ _ _ _ _ _ _ Ev) X3)
        as (HP3 & _ & c3 & gv3 & ->).
      destruct (ctr_set P Hctr _ _ _ _ _ _ _ _ HP3 (PTree.gempty _ _)
                  (fun v Ev => tmp_int _ _ _ _ _ _ _ (PTree.gss _ _ _) Ev)
                  (or_introl eq_refl) X4) as (HP1 & -> & _).
      apply seq_inv in X2 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)]; [ | kill_abn ].
      destruct (call_il ter_ls P HPow Hsa Hts _ _ _ _ _ _ _ _ _ (Econst_int (Int.repr 9) tint) 9%nat HP1 (PTree.gempty _ _) (PTree.gempty _ _)
                  ltac:(right; left; reflexivity) ltac:(lia) eq_refl (fun gv v Ev => ev_const _ _ _ _ _ _ _ Ev) X5)
        as (HP5 & _ & c5 & gv5 & ->).
      destruct (ctr_set P Hctr _ _ _ _ _ _ _ _ HP5 (PTree.gempty _ _)
                  (fun v Ev => tmp_int _ _ _ _ _ _ _ (PTree.gss _ _ _) Ev)
                  (or_introl eq_refl) X6) as (HP6 & -> & _).
      cbn in Hfr. injection Hfr as <-. exact HP6.
    Qed.
  End Terrain.

  (* ---- 7b. THE TERRAIN WALK WITH THE SURFACE BUDGET (2026-11-02).  The
     invariant at cursor v of list L (11 or 9) is P plus bud L v: the
     counter plus the budgets of the nodes from v to the end of L (and, in
     list 11, all of list 9) is at most NS + DS, or a time stop is on.  It
     starts from the post-clear fact (ObjPhase 3b: counter = NS) and the
     object world's budget clause (ter_ok: list 11 has none, list 9's sum
     to at most DS), and each step row (ter_row) moves it one node on. ---- *)
  Lemma sa_nb : nobrk (app_seq (loop_pre OLP.f_update_objects_starting_at) Sskip) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma ts_nb : nobrk (app_seq (loop_pre OLP.f_update_objects_during_time_stop) Sskip) = true.
  Proof. vm_compute. reflexivity. Qed.

  Lemma sym_inj : forall id1 id2 b, Genv.find_symbol G id1 = Some b -> Genv.find_symbol G id2 = Some b -> id1 = id2.
  Proof. intros id1 id2 b H1 H2. eapply Genv.genv_vars_inj; eassumption. Qed.

  Lemma sym_ne : forall id1 id2 b1 b2, Genv.find_symbol G id1 = Some b1 -> Genv.find_symbol G id2 = Some b2 ->
    id1 <> id2 -> b1 <> b2.
  Proof. intros id1 id2 b1 b2 H1 H2 N ->. exact (N (sym_inj _ _ _ H1 H2)). Qed.

  Definition suf_at (pool la : block) (L : nat) (l : list Z) (v : val) (suf : list Z) : Prop :=
    exists pre, l = pre ++ suf /\ v = first_v pool la (Z.of_nat L * OW.NODESZ) suf.

  Definition bud (L : nat) (v : val) (m : mem) : Prop :=
    exists pool la rs suf,
      Genv.find_symbol G OLP._gObjectPool = Some pool
      /\ Genv.find_symbol G OLP._gObjectListArray = Some la
      /\ OW.rings m pool la = Some rs /\ suf_at pool la L (nth L rs []) v suf
      /\ (OW.tsa G m = true
          \/ OW.ctrv G m + OW.sumz (map (OW.sdyn G pool m) suf)
             + (if Nat.eqb L 11 then OW.sumz (map (OW.sdyn G pool m) (nth 9 rs [])) else 0)
             <= OW.NS + OW.DS).

  Definition hd_is (L : nat) (hd : val) : Prop :=
    exists la, Genv.find_symbol G OLP._gObjectListArray = Some la /\ hd = head_v la L.

  Definition inr_L (L : nat) (m : mem) (hd v : val) : Prop := in_ring_l G bm ter_ls m hd v /\ hd_is L hd.

  Lemma next_L : forall L m hd v, inr_L L m hd v ->
    exists b o nx, v = Vptr b o
      /\ Mem.loadv Mint32 m (Vptr b (Ptrofs.add o (Ptrofs.repr 96))) = Some nx
      /\ (nx = hd \/ inr_L L m hd nx).
  Proof.
    intros L m hd v (Hin & Hh). destruct (next_l ter_ls m hd v Hin) as (b & o & nx & E & Hl & Hn).
    exists b, o, nx. split; [ exact E | split; [ exact Hl | ] ].
    destruct Hn as [-> | Hn]; [ left; reflexivity | right; exact (conj Hn Hh) ].
  Qed.

  Lemma hd_L : forall L m hd v, inr_L L m hd v -> exists b o, hd = Vptr b o.
  Proof. intros L m hd v (_ & la & _ & ->). exists la, (Ptrofs.repr (Z.of_nat L * OW.NODESZ)). reflexivity. Qed.

  Lemma ow_rs : forall m pool la, OW.obj_w G bm m -> Genv.find_symbol G OLP._gObjectPool = Some pool ->
    Genv.find_symbol G OLP._gObjectListArray = Some la ->
    exists rs fl gol gmo sdp gdi fs, OW.rings m pool la = Some rs /\ OW.ow_core G pool la fl gol gmo sdp gdi bm m rs fs.
  Proof.
    intros m pool la (pool' & la' & fl & gol & gmo & sdp & gdi & rs & fs & S1 & S2 & _ & _ & _ & _ & _ & C) Sp Sla.
    rewrite Sp in S1. injection S1 as <-. rewrite Sla in S2. injection S2 as <-.
    exists rs, fl, gol, gmo, sdp, gdi, fs. split; [ exact (OW.ow_rings _ _ _ _ _ _ _ _ _ _ _ _ C) | exact C ].
  Qed.

  Lemma pool_la : forall pool la, Genv.find_symbol G OLP._gObjectPool = Some pool ->
    Genv.find_symbol G OLP._gObjectListArray = Some la -> pool <> la.
  Proof. intros pool la H1 H2. apply (sym_ne _ _ _ _ H1 H2). vm_compute. discriminate. Qed.

  Lemma sumz_cons : forall x l, OW.sumz (x :: l) = x + OW.sumz l.
  Proof. reflexivity. Qed.
  Lemma sumz_app : forall l1 l2, OW.sumz (l1 ++ l2) = OW.sumz l1 + OW.sumz l2.
  Proof. induction l1 as [| x l IH]; intros l2; [ reflexivity | ]. cbn [app]. rewrite !sumz_cons, IH. lia. Qed.
  Lemma sumz_ext : forall (f g : Z -> Z) l, (forall k, In k l -> f k = g k) -> OW.sumz (map f l) = OW.sumz (map g l).
  Proof. intros f g l H. f_equal. apply map_ext_in. exact H. Qed.
  Lemma sumz_zero : forall (f : Z -> Z) l, (forall k, In k l -> f k = 0) -> OW.sumz (map f l) = 0.
  Proof.
    intros f l. induction l as [| x l IH]; intros H; [ reflexivity | ].
    cbn [map]. rewrite sumz_cons, (H x (or_introl eq_refl)), IH; [ reflexivity | ].
    intros k Hk. exact (H k (or_intror Hk)).
  Qed.
  Lemma sumz_nonneg : forall (f : Z -> Z) l, (forall k, 0 <= f k) -> 0 <= OW.sumz (map f l).
  Proof.
    intros f l H. induction l as [| x l IH]; [ cbn; lia | ]. cbn [map]. rewrite sumz_cons. specialize (H x). lia.
  Qed.
  Lemma sdyn_nonneg : forall pool m k, 0 <= OW.sdyn G pool m k.
  Proof.
    intros pool m k. unfold OW.sdyn, OW.D_BOX, OW.D_LID.
    destruct (OW.runs G pool m k OW.BOXS); [ lia | ]. destruct (OW.runs G pool m k OW.LIDS); lia.
  Qed.

  Lemma slot_not_head : forall pool la L k, Genv.find_symbol G OLP._gObjectPool = Some pool ->
    Genv.find_symbol G OLP._gObjectListArray = Some la -> OW.slot_v pool k <> head_v la L.
  Proof. intros pool la L k H1 H2 E. injection E as E _. exact (pool_la _ _ H1 H2 E). Qed.

  (* a ring node's slot index is in range *)
  Lemma ring_k : forall m pool la rs L k, OW.rings m pool la = Some rs -> (L < OW.NLIST)%nat ->
    In k (nth L rs []) -> 0 <= k < OW.NSLOT.
  Proof.
    intros m pool la rs L k Hr HL Hk.
    destruct (ring_i_spec _ _ _ _ _ (rings_nth _ _ _ _ Hr L HL)) as (_ & Hall).
    exact (proj1 (Hall k Hk)).
  Qed.

  (* nothing but gObjectCounter's block changes: the budget stays *)
  Lemma ring_from_ext : forall m m' pool hb ho,
    (forall z, OW.ld32 m' pool z = OW.ld32 m pool z) -> (forall z, OW.ld32 m' hb z = OW.ld32 m hb z) ->
    forall n prev cur, OW.ring_from m' pool hb ho prev cur n = OW.ring_from m pool hb ho prev cur n.
  Proof.
    intros m m' pool hb ho Kp Kh n. induction n as [| n IH]; intros prev cur; cbn [OW.ring_from]; [ reflexivity | ].
    destruct cur as [| | | | | b o]; try reflexivity.
    destruct (eq_block b hb && Z.eqb (Ptrofs.unsigned o) ho); [ rewrite Kh; reflexivity | ].
    destruct (eq_block b pool); [ | reflexivity ].
    destruct (OW.slot_of (Ptrofs.unsigned o)); [ | reflexivity ].
    rewrite !Kp.
    destruct (OW.ld32 m pool (Ptrofs.unsigned o + OW.O_PREV)) as [p|]; [ | reflexivity ].
    destruct (OW.ld32 m pool (Ptrofs.unsigned o + OW.O_NEXT)) as [nx|]; [ | reflexivity ].
    destruct (OW.veqb p prev); [ | reflexivity ].
    rewrite IH. reflexivity.
  Qed.

  Lemma rings_ext : forall m m' pool la,
    (forall z, OW.ld32 m' pool z = OW.ld32 m pool z) -> (forall z, OW.ld32 m' la z = OW.ld32 m la z) ->
    OW.rings m' pool la = OW.rings m pool la.
  Proof.
    intros m m' pool la Kp Kl. unfold OW.rings.
    assert (E : map (OW.ring_i m' pool la) (seq 0 OW.NLIST) = map (OW.ring_i m pool la) (seq 0 OW.NLIST)).
    { apply map_ext. intros i. unfold OW.ring_i. cbv zeta. rewrite Kl.
      destruct (OW.ld32 m la (Z.of_nat i * OW.NODESZ + OW.O_NEXT)); [ | reflexivity ].
      apply ring_from_ext; assumption. }
    rewrite E. reflexivity.
  Qed.

  Lemma bud_unch : forall L v m m',
    (forall id b, Genv.find_symbol G id = Some b -> id <> OLP._gObjectCounter ->
       forall ch z, Mem.load ch m' b z = Mem.load ch m b z) ->
    bud L v m -> bud L v m'.
  Proof.
    intros L v m m' K (pool & la & rs & suf & Sp & Sla & Hr & Hs & Hb).
    assert (Kp : forall ch z, Mem.load ch m' pool z = Mem.load ch m pool z)
      by (apply (K _ _ Sp); vm_compute; discriminate).
    assert (Kl : forall ch z, Mem.load ch m' la z = Mem.load ch m la z)
      by (apply (K _ _ Sla); vm_compute; discriminate).
    assert (Kp' : forall z, OW.ld32 m' pool z = OW.ld32 m pool z)
      by (intros z; rewrite !ld32_eq; apply Kp).
    assert (Kl' : forall z, OW.ld32 m' la z = OW.ld32 m la z)
      by (intros z; rewrite !ld32_eq; apply Kl).
    assert (Es : forall k, OW.sdyn G pool m' k = OW.sdyn G pool m k)
      by (intros k; unfold OW.sdyn, OW.runs; rewrite !Kp'; reflexivity).
    assert (Et : OW.tsa G m' = OW.tsa G m).
    { unfold OW.tsa. destruct (Genv.find_symbol G surface_load._gTimeStopState) as [bt|] eqn:Ht; [ | reflexivity ].
      rewrite (K _ _ Ht); [ reflexivity | vm_compute; discriminate ]. }
    assert (Ec : OW.ctrv G m' = OW.ctrv G m).
    { unfold OW.ctrv. destruct (Genv.find_symbol G surface_load._gSurfacesAllocated) as [ba|] eqn:Ha; [ | reflexivity ].
      rewrite (K _ _ Ha); [ reflexivity | vm_compute; discriminate ]. }
    exists pool, la, rs, suf. rewrite (rings_ext m m' pool la Kp' Kl'), Et, Ec.
    rewrite !(map_ext _ _ Es). exact (conj Sp (conj Sla (conj Hr (conj Hs Hb)))).
  Qed.

  Lemma ctr_K : forall m b c m', Genv.find_symbol G OLP._gObjectCounter = Some b ->
    Mem.store Mint32 m b 0 (Vint c) = Some m' ->
    forall id b', Genv.find_symbol G id = Some b' -> id <> OLP._gObjectCounter ->
      forall ch z, Mem.load ch m' b' z = Mem.load ch m b' z.
  Proof.
    intros m b c m' Hb Hs id b' Hb' N ch z. apply (Mem.load_store_other _ _ _ _ _ _ Hs). left.
    exact (sym_ne _ _ _ _ Hb' Hb N).
  Qed.

  Section TerrainIx.
    Variable P : mem -> Prop.
    Hypothesis HPow : forall m, P m -> OW.obj_w G bm m.
    Hypothesis Hsa : ter_row G bm P OLP.f_update_objects_starting_at.
    Hypothesis Hts : ter_row G bm P OLP.f_update_objects_during_time_stop.
    Hypothesis Hctr : forall m b c m', P m -> Genv.find_symbol G OLP._gObjectCounter = Some b ->
      Mem.store Mint32 m b 0 (Vint c) = Some m' -> P m'.

    Definition Pi (L : nat) (v : val) (m : mem) : Prop := P m /\ bud L v m.

    Lemma step_ix : forall f, ter_row G bm P f -> forall L, (L = 11 \/ L = 9)%nat ->
      forall hd v le m t le' m' out, Pi L v m -> inr_L L m hd v ->
      le ! OLP._firstObj = Some v -> le ! OLP._objList = Some hd ->
      exec_stmt function_entry2 G empty_env le m (app_seq (loop_pre f) Sskip) t le' m' out ->
      inr_L L m' hd v /\ forall b o nx, v = Vptr b o ->
        Mem.loadv Mint32 m' (Vptr b (Ptrofs.add o (Ptrofs.repr 96))) = Some nx -> Pi L nx m'.
    Proof.
      intros f Hrow L HL hd v le m t le' m' out (HP & pool & la & rs & suf & Sp & Sla & Hrs & (pre & Epre & Ev) & Hb)
        (Hin & Hhd) Hv Ho Hx.
      assert (HLt : (L < OW.NLIST)%nat) by (unfold OW.NLIST; destruct HL as [-> | ->]; lia).
      (* the cursor is a node: its suffix is k :: post *)
      destruct suf as [| k post].
      { exfalso. cbn [first_v] in Ev.
        destruct Hin as ((pool' & la' & rs' & i & k' & Ha & _ & _ & _ & Ev') & _).
        destruct Ha as (Sp' & _). rewrite Sp in Sp'. injection Sp' as <-.
        rewrite Ev in Ev'. unfold OW.slot_v in Ev'. injection Ev' as E _. exact (pool_la _ _ Sp Sla (eq_sym E)). }
      cbn [first_v] in Ev.
      assert (Hk : In k (nth L rs [])) by (rewrite Epre; apply in_or_app; right; left; reflexivity).
      pose proof (ring_k _ _ _ _ _ _ Hrs HLt Hk) as Hkr.
      assert (Hvb : vbud G m v).
      { destruct Hb as [Ht | Hb]; [ left; exact Ht | right ]. exists pool, k.
        split; [ exact Sp | split; [ exact Ev | ] ].
        cbn [map] in Hb. rewrite sumz_cons in Hb.
        pose proof (sumz_nonneg (OW.sdyn G pool m) post (sdyn_nonneg pool m)) as N1.
        pose proof (sumz_nonneg (OW.sdyn G pool m) (nth 9 rs []) (sdyn_nonneg pool m)) as N2.
        destruct (Nat.eqb L 11); lia. }
      destruct (Hrow hd v le m t le' m' out HP Hin Hvb Hv Ho Hx) as (HP' & Hin' & Hpost).
      split; [ exact (conj Hin' Hhd) | ].
      intros b o nx Evb Hl.
      destruct (ow_rs m' pool la (HPow m' HP') Sp Sla) as (rs' & _ & _ & _ & _ & _ & _ & Hrs' & _).
      destruct (Hpost pool la rs rs' Sp Sla Hrs Hrs') as (Ha & Hbb & Hc & Hd).
      destruct (Ha L ltac:(unfold ter_ls; destruct HL as [-> | ->]; cbn; tauto)) as (ext & Eext & Fext).
      pose proof (rings_nth _ _ _ _ Hrs' L HLt) as Hri'.
      destruct (ring_i_order _ _ _ _ _ Hri') as (_ & Hsucc).
      assert (E' : nth L rs' [] = pre ++ k :: (post ++ ext))
        by (rewrite Eext, Epre, <- app_assoc; reflexivity).
      pose proof (Hsucc pre k (post ++ ext) E') as Hlk.
      rewrite Ev in Evb. unfold OW.slot_v in Evb. injection Evb as <- <-.
      cbn [Mem.loadv] in Hl. rewrite add96 in Hl by (unfold OW.OSZ, OW.NSLOT in *; try rewrite maxu; lia).
      unfold OW.O_NEXT in Hlk. rewrite Hlk in Hl. injection Hl as <-.
      split; [ exact HP' | ].
      exists pool, la, rs', (post ++ ext).
      split; [ exact Sp | split; [ exact Sla | split; [ exact Hrs' | split ] ] ].
      - exists (pre ++ [k]). split; [ rewrite E', <- app_assoc; reflexivity | reflexivity ].
      - rewrite Hd. destruct (OW.tsa G m) eqn:Et; [ left; reflexivity | right ].
        destruct Hb as [Hb | Hb]; [ first [ discriminate Hb | rewrite Et in Hb; discriminate Hb ] | ].
        specialize (Hc k Ev). unfold OW.dyn in Hc. rewrite Et in Hc.
        assert (Hpost_in : forall k', In k' post -> In k' (nth 11 rs []) \/ In k' (nth 9 rs [])).
        { intros k' Hk'. assert (In k' (nth L rs [])) by (rewrite Epre; apply in_or_app; right; right; exact Hk').
          destruct HL as [-> | ->]; [ left | right ]; assumption. }
        rewrite map_app, sumz_app, (sumz_zero (OW.sdyn G pool m') ext (fun k' Hk' => proj1 (Forall_forall _ _) Fext k' Hk')).
        rewrite (sumz_ext (OW.sdyn G pool m') (OW.sdyn G pool m) post (fun k' Hk' => Hbb k' (Hpost_in k' Hk'))).
        cbn [map] in Hb. rewrite sumz_cons in Hb.
        destruct HL as [-> | ->]; cbn [Nat.eqb] in Hb |- *; [ | lia ].
        destruct (Ha 9%nat ltac:(unfold ter_ls; cbn; tauto)) as (ext9 & E9 & F9).
        rewrite E9, map_app, sumz_app, (sumz_zero (OW.sdyn G pool m') ext9 (fun k' Hk' => proj1 (Forall_forall _ _) F9 k' Hk')).
        rewrite (sumz_ext (OW.sdyn G pool m') (OW.sdyn G pool m) (nth 9 rs []) (fun k' Hk' => Hbb k' (or_intror Hk'))).
        lia.
    Qed.

    Lemma sa_keeps_ix : forall L, (L = 11 \/ L = 9)%nat -> forall m hd v0 t m' vr, Pi L v0 m ->
      (v0 = hd \/ inr_L L m hd v0) ->
      eval_funcall function_entry2 G m (Internal OLP.f_update_objects_starting_at) [hd; v0] t m' vr ->
      Pi L hd m' /\ exists c, vr = Vint c.
    Proof.
      intros L HL.
      exact (fn_loop_keeps_ix G (Pi L) (inr_L L) (next_L L) (hd_L L) fo_next
               (loop_pre OLP.f_update_objects_starting_at) sa_ns sa_nb (step_ix _ Hsa L HL)
               OLP.f_update_objects_starting_at eq_refl eq_refl eq_refl sa_shape).
    Qed.
    Lemma ts_keeps_ix : forall L, (L = 11 \/ L = 9)%nat -> forall m hd v0 t m' vr, Pi L v0 m ->
      (v0 = hd \/ inr_L L m hd v0) ->
      eval_funcall function_entry2 G m (Internal OLP.f_update_objects_during_time_stop) [hd; v0] t m' vr ->
      Pi L hd m' /\ exists c, vr = Vint c.
    Proof.
      intros L HL.
      exact (fn_loop_keeps_ix G (Pi L) (inr_L L) (next_L L) (hd_L L) fo_next
               (loop_pre OLP.f_update_objects_during_time_stop) ts_ns ts_nb (step_ix _ Hts L HL)
               OLP.f_update_objects_during_time_stop eq_refl eq_refl eq_refl ts_shape).
    Qed.

    (* one branch of update_objects_in_list, for any post-state predicate *)
    Lemma il_branch_q : forall (Q : mem -> Prop) fid f tmp le m t le' m' out hd nx,
      (prog_defmap OLP.prog) ! fid = Some (Gfun (Internal f)) ->
      (forall t m' vr, eval_funcall function_entry2 G m (Internal f) [hd; nx] t m' vr ->
         Q m' /\ exists c, vr = Vint c) ->
      exec_stmt function_entry2 G empty_env le m
        (Ssequence
           (Scall (Some tmp) (Evar fid (Tfunction [tnode; tnode] tint cc_default))
              [Etempvar OLP._objList tnode; Etempvar OLP._firstObj tnode])
           (Sset OLP._count (Etempvar tmp tint))) t le' m' out ->
      le ! OLP._objList = Some hd -> le ! OLP._firstObj = Some nx ->
      Q m' /\ out = Out_normal /\ exists c, le' ! OLP._count = Some (Vint c).
    Proof.
      intros Q fid f tmp le m t le' m' out hd nx Hdm Hk H Ho Hf.
      apply seq_inv in H as [(t1 & le1 & m1 & t2 & H1 & H2) | (H1 & Hn)];
        [ | exfalso; exact (Hn (plain_out _ _ _ _ _ _ _ _ _ H1 eq_refl)) ].
      apply call_inv in H1 as (tya & tyr & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hc & -> & _).
      cbn in Hcf. injection Hcf as <- <- <-.
      destruct (ev_fun G empty_env m le fid (Tfunction [tnode; tnode] tint cc_default) vf (PTree.gempty _ _) eq_refl Evf) as (bf & Hs & ->).
      rewrite (fun_olp _ _ Hdm bf fd Hs Hff) in Hc.
      destruct (exl2 _ _ _ _ _ _ _ _ Eal) as (ty1 & ty2 & v1 & v2 & w1 & w2 & E1 & -> & Ev1 & C1 & Ev2 & C2).
      injection E1 as <- <-.
      apply ev_temp in Ev1. apply ev_temp in Ev2. rewrite Ho in Ev1. rewrite Hf in Ev2.
      injection Ev1 as <-. injection Ev2 as <-. cbn [typeof] in C1, C2.
      apply cast_tnode in C1. apply cast_tnode in C2. subst w1 w2.
      destruct (Hk _ _ _ Hc) as (HQ1 & c & ->).
      apply set_inv in H2 as (cv & Ecv & -> & -> & ->). apply ev_temp in Ecv.
      cbn [set_opttemp] in Ecv. rewrite PTree.gss in Ecv. injection Ecv as <-.
      split; [ exact HQ1 | split; [ reflexivity | exists c; apply PTree.gss ] ].
    Qed.

    (* the list's entry budget: whatever the head's next is, bud holds there *)
    Definition ent (L : nat) (m : mem) : Prop :=
      forall la nx, Genv.find_symbol G OLP._gObjectListArray = Some la ->
        Mem.load Mint32 m la (Z.of_nat L * OW.NODESZ + OW.O_NEXT) = Some nx -> bud L nx m.

    (* update_objects_in_list(head of L), with the budget *)
    Theorem in_list_keeps_ix : forall L, (L = 11 \/ L = 9)%nat -> forall m la t m' vr, P m -> ent L m ->
      Genv.find_symbol G OLP._gObjectListArray = Some la -> is_head G bm m (head_v la L) ->
      eval_funcall function_entry2 G m (Internal OLP.f_update_objects_in_list) [head_v la L] t m' vr ->
      Pi L (head_v la L) m' /\ exists c, vr = Vint c.
    Proof.
      intros L HL m la t m' vr HP He Sla Hh Hev.
      assert (Hin : hd_in G ter_ls (head_v la L))
        by (exists la, L; split; [ exact Sla | split; [ unfold ter_ls; destruct HL as [-> | ->]; cbn; tauto | reflexivity ] ]).
      assert (HLt : (L < 13)%nat) by (destruct HL as [-> | ->]; lia).
      remember (Internal OLP.f_update_objects_in_list) as fd eqn:Efd. remember [head_v la L] as va eqn:Eva.
      destruct Hev as [mm ff vargs tt ee lea leb mm1 mm2 oo vv mm3 Hfe Hx Hor Hfr | ];
        [ injection Efd as Eff; subst ff | discriminate Efd ]. subst vargs.
      destruct Hfe as [_ _ _ Hav Hb].
      cbn [fn_vars OLP.f_update_objects_in_list] in Hav. inversion Hav; subst ee mm1; subst e m; rename mm into m.
      cbn [fn_params OLP.f_update_objects_in_list bind_parameter_temps] in Hb. injection Hb as <-.
      unfold OLP.f_update_objects_in_list in Hx. cbn [fn_body] in Hx.
      destruct (head_next G bm m (head_v la L) Hh) as (bh & oh & nx & Ehd & Hlh & Hnx).
      apply seq_inv in Hx as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)];
        [ | exfalso; exact (Xn (plain_out _ _ _ _ _ _ _ _ _ X1 eq_refl)) ].
      apply set_inv in X1 as (nv & Env & -> & -> & _).
      destruct (ev_fld G empty_env m _ OLP._objList OLP._ObjectNode OLP._next tnode nv Mint32 96 fo_next eq_refl Env)
        as (b & o & Hbo & Hl).
      rewrite PTree.gss in Hbo. assert (Ehd2 : head_v la L = Vptr b o) by congruence. clear Hbo. rewrite Ehd2 in Ehd. injection Ehd as <- <-.
      rewrite Hl in Hlh. injection Hlh as <-.
      (* the entry budget at the first node *)
      assert (HPn : Pi L nv m).
      { split; [ exact HP | apply (He la nv Sla) ].
        unfold head_v in Ehd2. injection Ehd2 as <- <-.
        cbn [Mem.loadv] in Hl. rewrite add96 in Hl by (unfold OW.NODESZ; try rewrite maxu; lia).
        exact Hl. }
      assert (Hnx' : nv = head_v la L \/ inr_L L m (head_v la L) nv).
      { destruct Hnx as [E | E]; [ left; exact E | right ].
        split; [ exact (conj E Hin) | exists la; split; [ exact Sla | reflexivity ] ]. }
      apply seq_inv in X2 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)];
        [ | exfalso; exact (Xn (plain_out _ _ _ _ _ _ _ _ _ X3 eq_refl)) ].
      apply seq_inv in X3 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)];
        [ | exfalso; exact (Xn (plain_out _ _ _ _ _ _ _ _ _ X5 eq_refl)) ].
      apply set_inv in X5 as (w & _ & -> & -> & _).
      apply if_inv in X6 as (cv & bb & _ & _ & X6).
      assert (K : Pi L (head_v la L) m3 /\ exists c, le3 ! OLP._count = Some (Vint c)).
      { destruct bb.
        - destruct (il_branch_q (Pi L (head_v la L)) _ _ _ _ _ _ _ _ _ (head_v la L) nv dm_sa
                      (fun t0 m0' vr0 Hc => sa_keeps_ix L HL m _ _ t0 m0' vr0 HPn Hnx' Hc)
                      X6 ltac:(getnorm_tac) ltac:(getnorm_tac)) as (HP3 & _ & Hc3).
          exact (conj HP3 Hc3).
        - destruct (il_branch_q (Pi L (head_v la L)) _ _ _ _ _ _ _ _ _ (head_v la L) nv dm_ts
                      (fun t0 m0' vr0 Hc => ts_keeps_ix L HL m _ _ t0 m0' vr0 HPn Hnx' Hc)
                      X6 ltac:(getnorm_tac) ltac:(getnorm_tac)) as (HP3 & _ & Hc3).
          exact (conj HP3 Hc3). }
      destruct K as (HP3 & c & Hc3).
      apply ret_inv in X4 as (-> & rv & Erv & ->). apply ev_temp in Erv. rewrite Hc3 in Erv. injection Erv as <-.
      cbn [fn_return OLP.f_update_objects_in_list outcome_result_value] in Hor. destruct Hor as (_ & Hcast).
      destruct (cast_tint _ _ _ Hcast) as (c' & ->).
      cbn in Hfr. injection Hfr as <-.
      split; [ exact HP3 | eauto ].
    Qed.

    (* entering list 11: the clear left the counter at NS (post_clear), list
       11 has no budget and list 9's is at most DS (ter_ok) *)
    Lemma ent11 : forall m, P m -> OW.post_clear G m -> ent 11 m.
    Proof.
      intros m HP Hpc la nx Sla Hl.
      destruct (HPow m HP) as (pool & la' & fl & gol & gmo & sdp & gdi & rs & fs & S1 & S2 & _ & _ & _ & _ & _ & C).
      rewrite Sla in S2. injection S2 as <-.
      pose proof (OW.ow_rings _ _ _ _ _ _ _ _ _ _ _ _ C) as Hrs.
      destruct (OW.ow_ter _ _ _ _ _ _ _ _ _ _ _ _ C) as (T1 & _ & T3 & _).
      destruct (ring_i_order _ _ _ _ _ (rings_nth _ _ _ _ Hrs 11 ltac:(unfold OW.NLIST; lia))) as (H0 & _).
      rewrite H0 in Hl. injection Hl as <-.
      exists pool, la, rs, (nth 11 rs []).
      split; [ exact S1 | split; [ exact Sla | split; [ exact Hrs | split ] ] ].
      - exists []. split; reflexivity.
      - destruct Hpc as [Ht | Hc]; [ left; exact Ht | right ].
        rewrite (sumz_zero (OW.sdyn G pool m) (nth 11 rs [])).
        + cbn [Nat.eqb]. rewrite Hc. lia.
        + intros k Hk. destruct (Z.eq_dec (OW.sdyn G pool m k) 0) as [E | N]; [ exact E | ].
          exfalso. pose proof (T1 11%nat k Hk N) as E. discriminate E.
    Qed.

    (* entering list 9: list 11's walk ended at its head with the budget of
       list 9 still covered *)
    Lemma ent9 : forall m la, Genv.find_symbol G OLP._gObjectListArray = Some la ->
      bud 11 (head_v la 11) m -> ent 9 m.
    Proof.
      intros m la Sla (pool & la' & rs & suf & Sp & Sla' & Hrs & (pre & Epre & Ev) & Hb) la2 nx Sla2 Hl.
      rewrite Sla in Sla'. injection Sla' as <-. rewrite Sla in Sla2. injection Sla2 as <-.
      destruct suf as [| k post];
        [ | exfalso; cbn [first_v] in Ev; unfold head_v, OW.slot_v in Ev; injection Ev as E _;
            exact (pool_la _ _ Sp Sla (eq_sym E)) ].
      destruct (ring_i_order _ _ _ _ _ (rings_nth _ _ _ _ Hrs 9 ltac:(unfold OW.NLIST; lia))) as (H0 & _).
      rewrite H0 in Hl. injection Hl as <-.
      exists pool, la, rs, (nth 9 rs []).
      split; [ exact Sp | split; [ exact Sla | split; [ exact Hrs | split ] ] ].
      - exists []. split; reflexivity.
      - destruct Hb as [Ht | Hb]; [ left; exact Ht | right ].
        cbn [Nat.eqb map] in Hb |- *. unfold OW.sumz in Hb |- *. cbn [fold_right] in Hb. lia.
    Qed.

    Lemma Hctr_ix : forall L hd m b c m', Pi L hd m -> Genv.find_symbol G OLP._gObjectCounter = Some b ->
      Mem.store Mint32 m b 0 (Vint c) = Some m' -> Pi L hd m'.
    Proof.
      intros L hd m b c m' (HP & Hb) Hs Hst.
      exact (conj (Hctr _ _ _ _ HP Hs Hst) (bud_unch _ _ _ _ (ctr_K _ _ _ _ Hs Hst) Hb)).
    Qed.

    (* tmp = update_objects_in_list(gObjectLists + idx), with the budget *)
    Lemma call_il_ix : forall e le m t le' m' out tmpl tmp a idx,
      (idx = 11 \/ idx = 9)%nat -> P m -> ent idx m ->
      e ! OLP._gObjectLists = None -> e ! OLP._update_objects_in_list = None -> typeof a = tint ->
      (forall gv v, eval_expr G e (PTree.set tmpl gv le) m a v -> v = Vint (Int.repr (Z.of_nat idx))) ->
      exec_stmt function_entry2 G e le m
        (Ssequence (Sset tmpl (Evar OLP._gObjectLists tnode))
           (Scall (Some tmp) (Evar OLP._update_objects_in_list (Tfunction [tnode] tint cc_default))
              [Ebinop Oadd (Etempvar tmpl tnode) a tnode])) t le' m' out ->
      (exists la, Genv.find_symbol G OLP._gObjectListArray = Some la /\ Pi idx (head_v la idx) m')
      /\ out = Out_normal /\ exists c gv, le' = PTree.set tmp (Vint c) (PTree.set tmpl gv le).
    Proof.
      intros e le m t le' m' out tmpl tmp a idx HL HP He He1 He2 Hta Ha H.
      assert (Hidx : (idx < 13)%nat) by (destruct HL as [-> | ->]; lia).
      apply seq_inv in H as [(t1 & le1 & m1 & t2 & H1 & H2) | (H1 & Hn)]; [ | kill_abn ].
      apply set_inv in H1 as (gv & Egv & -> & -> & _).
      destruct (ev_gvar G e m le OLP._gObjectLists tnode gv Mint32 He1 eq_refl Egv) as (bg & Hbg & Hlg).
      destruct (HPow m HP) as (pool & la & fl & gol & gmo & sdp & gdi & rs & fs & S1 & S2 & S3 & S4 & S5 & S6 & S7 & Hc).
      rewrite Hbg in S4. injection S4 as <-.
      cbn [Mem.loadv] in Hlg. rewrite Ptrofs.unsigned_zero, (OW.ow_gol _ _ _ _ _ _ _ _ _ _ _ _ Hc) in Hlg.
      injection Hlg as <-.
      apply call_inv in H2 as (tya & tyr & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hcall & -> & ->).
      cbn in Hcf. injection Hcf as <- <- <-.
      destruct (ev_fun G e m _ OLP._update_objects_in_list (Tfunction [tnode] tint cc_default) vf He2 eq_refl Evf)
        as (bf & Hs & ->).
      rewrite (fun_olp _ _ dm_il bf fd Hs Hff) in Hcall.
      destruct (exl1 _ _ _ _ _ _ _ Eal) as (ty1 & v1 & w1 & E1 & -> & Ev1 & C1). injection E1 as <-.
      apply ev_binop in Ev1 as (x1 & x2 & X1 & X2 & X3).
      apply ev_temp in X1. rewrite PTree.gss in X1. injection X1 as <-.
      rewrite (Ha _ _ X2) in X3. cbn [typeof] in X3. rewrite Hta in X3.
      assert (E : sem_binary_operation G Oadd (Vptr la Ptrofs.zero) tnode (Vint (Int.repr (Z.of_nat idx))) tint m
                  = Some (Vptr la (Ptrofs.add Ptrofs.zero (Ptrofs.mul (Ptrofs.repr (sizeof G (Tstruct OLP._ObjectNode noattr)))
                                                                    (Ptrofs.of_ints (Int.repr (Z.of_nat idx))))))) by reflexivity.
      rewrite E, sz_node, (ofs_idx _ Hidx) in X3. injection X3 as <-.
      cbn [typeof] in C1. apply cast_tnode in C1. subst w1.
      assert (Hh : is_head G bm m (head_v la idx)).
      { exists pool, la, rs, idx. split; [ | split; [ unfold OW.NLIST; lia | reflexivity ] ].
        split; [ exact S1 | split; [ exact S2 | ] ]. exists fl, bg, gmo, sdp, gdi, fs. tauto. }
      destruct (in_list_keeps_ix idx HL m la _ m' vres HP He S2 Hh Hcall) as (HP' & c & ->).
      split; [ exists la; exact (conj S2 HP') | split; [ reflexivity | exists c, (Vptr la Ptrofs.zero); reflexivity ] ].
    Qed.

    (* update_terrain_objects, from P and the post-clear fact, to P: the
       counter stays within NS + DS through both walks *)
    Theorem terrain_keeps_ix : ObjPhase.call_rel G (fun m => P m /\ OW.post_clear G m) P OLP._update_terrain_objects.
    Proof.
      intros bf fd m vargs t m' vr Hs Hf (HP & Hpc) Hev.
      rewrite (fun_olp _ _ dm_ter bf fd Hs Hf) in Hev.
      remember (Internal OLP.f_update_terrain_objects) as fd' eqn:Efd.
      destruct Hev as [mm ff va tt ee lea leb mm1 mm2 oo vv mm3 Hfe Hx Hor Hfr | ];
        [ injection Efd as Eff; subst ff | discriminate Efd ].
      destruct Hfe as [_ _ _ Hav Hb].
      cbn [fn_vars OLP.f_update_terrain_objects] in Hav. inversion Hav; subst ee mm1; subst e m; rename mm into m.
      unfold OLP.f_update_terrain_objects in Hx. cbn [fn_body] in Hx.
      apply seq_inv in Hx as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_abn ].
      apply seq_inv in X1 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)]; [ | kill_abn ].
      destruct (call_il_ix _ _ _ _ _ _ _ _ _ (Econst_int (Int.repr 11) tint) 11%nat (or_introl eq_refl) HP
                  (ent11 _ HP Hpc) (PTree.gempty _ _) (PTree.gempty _ _)
                  eq_refl (fun gv v Ev => ev_const _ _ _ _ _ _ _ Ev) X3)
        as ((la & Sla & HP3) & _ & c3 & gv3 & ->).
      destruct (ctr_set (Pi 11 (head_v la 11)) (Hctr_ix 11 (head_v la 11)) _ _ _ _ _ _ _ _ HP3 (PTree.gempty _ _)
                  (fun v Ev => tmp_int _ _ _ _ _ _ _ (PTree.gss _ _ _) Ev)
                  (or_introl eq_refl) X4) as (HP1 & -> & _).
      apply seq_inv in X2 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)]; [ | kill_abn ].
      destruct (call_il_ix _ _ _ _ _ _ _ _ _ (Econst_int (Int.repr 9) tint) 9%nat (or_intror eq_refl) (proj1 HP1)
                  (ent9 _ la Sla (proj2 HP1)) (PTree.gempty _ _) (PTree.gempty _ _)
                  eq_refl (fun gv v Ev => ev_const _ _ _ _ _ _ _ Ev) X5)
        as ((la5 & _ & HP5) & _ & c5 & gv5 & ->).
      destruct (ctr_set P Hctr _ _ _ _ _ _ _ _ (proj1 HP5) (PTree.gempty _ _)
                  (fun v Ev => tmp_int _ _ _ _ _ _ _ (PTree.gss _ _ _) Ev)
                  (or_introl eq_refl) X6) as (HP6 & -> & _).
      cbn in Hfr. injection Hfr as <-. exact HP6.
    Qed.
  End TerrainIx.

  (* ---- 8. update_non_terrain_objects: the walk over sObjectListUpdateOrder ---- *)
  Definition nt_loop_body : statement :=
    match fn_body OLP.f_update_non_terrain_objects with Ssequence _ (Sloop b _) => b | _ => Sskip end.
  Definition nt_head : statement := match nt_loop_body with Ssequence h _ => h | _ => Sskip end.
  Definition nt_rest : statement := match nt_loop_body with Ssequence _ r => r | _ => Sskip end.

  Lemma nt_shape : fn_body OLP.f_update_non_terrain_objects
    = Ssequence (Sset OLP._i (Econst_int (Int.repr 2) tint)) (Sloop (Ssequence nt_head nt_rest) Sskip).
  Proof. reflexivity. Qed.

  Lemma ev_unop : forall e le m op a ty v, eval_expr G e le m (Eunop op a ty) v ->
    exists v1, eval_expr G e le m a v1 /\ sem_unary_operation op v1 (typeof a) m = Some v.
  Proof. intros. inv H; [ eauto | inv H0 ]. Qed.

  Lemma cast_sc : forall x v m, sem_cast (Vint x) tschar tint m = Some v -> v = Vint x.
  Proof. intros x v m H. vm_compute in H. injection H as <-. reflexivity. Qed.

  Lemma ofs_n : forall n, (n < 11)%nat ->
    Ptrofs.unsigned (Ptrofs.add Ptrofs.zero (Ptrofs.mul (Ptrofs.repr 1) (Ptrofs.of_ints (Int.repr (Z.of_nat n)))))
    = Z.of_nat n.
  Proof. intros n H. do 11 (destruct n as [|n]; [ reflexivity | ]). lia. Qed.

  Lemma add1 : forall n, (n <= 10)%nat ->
    Int.add (Int.repr (Z.of_nat n)) (Int.repr 1) = Int.repr (Z.of_nat (S n)).
  Proof. intros n H. do 11 (destruct n as [|n]; [ reflexivity | ]). lia. Qed.

  Lemma nt_idx : forall n, (2 <= n < 10)%nat ->
    exists idx, nth n OW.upd_order 0 = Z.of_nat idx /\ In idx nt_ls /\ (idx < 13)%nat.
  Proof.
    intros n H. destruct n as [|[|[|[|[|[|[|[|[|[|n]]]]]]]]]]; try lia.
    1: exists 10%nat. 2: exists 0%nat. 3: exists 5%nat. 4: exists 4%nat.
    5: exists 2%nat. 6: exists 6%nat. 7: exists 8%nat. 8: exists 12%nat.
    all: split; [ reflexivity | split; [ cbn; repeat (first [ left; reflexivity | right ]) | lia ] ].
  Qed.

  Lemma ifsb : forall (e : env) (le : temp_env) (m : mem) (bb : bool) (t : trace) (le1 : temp_env) (m1 : mem) (out : outcome),
    exec_stmt function_entry2 G e le m (if bb then Sskip else Sbreak) t le1 m1 out ->
    m1 = m /\ le1 = le /\ out = (if bb then Out_normal else Out_break).
  Proof. intros e le m bb t le1 m1 out H. destruct bb; inv H; auto. Qed.

  (* *(sObjectListUpdateOrder + i) *)
  Lemma ev_order : forall e le m n v ob, e ! OLP._sObjectListUpdateOrder = None ->
    Genv.find_symbol G OLP._sObjectListUpdateOrder = Some ob ->
    le ! OLP._i = Some (Vint (Int.repr (Z.of_nat n))) -> (n < 11)%nat ->
    eval_expr G e le m (Ederef (Ebinop Oadd (Evar OLP._sObjectListUpdateOrder (tarray tschar 11))
                                  (Etempvar OLP._i tint) (tptr tschar)) tschar) v ->
    Mem.load Mint8signed m ob (Z.of_nat n) = Some v.
  Proof.
    intros e le m n v ob He Hs Hi Hn H.
    inv H. match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
    match goal with Hb : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ => apply ev_binop in Hb as (x1 & x2 & X1 & X2 & X3) end.
    destruct (ev_fun G e m le _ (tarray tschar 11) x1 He eq_refl X1) as (b1 & Hb1 & ->).
    rewrite Hs in Hb1. injection Hb1 as <-.
    apply ev_temp in X2. rewrite Hi in X2. injection X2 as <-.
    cbn [typeof] in X3.
    assert (E : sem_binary_operation G Oadd (Vptr ob Ptrofs.zero) (tarray tschar 11) (Vint (Int.repr (Z.of_nat n))) tint m
                = Some (Vptr ob (Ptrofs.add Ptrofs.zero (Ptrofs.mul (Ptrofs.repr 1) (Ptrofs.of_ints (Int.repr (Z.of_nat n)))))))
      by reflexivity.
    rewrite E in X3. injection X3 as <- <-.
    match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end.
    all: try (match goal with Ha : access_mode _ = _ |- _ => cbn in Ha; discriminate Ha end).
    match goal with Ha : access_mode _ = By_value ?ch, Hl : Mem.loadv ?ch _ _ = Some _ |- _ =>
      cbn in Ha; injection Ha as <-; cbn [Mem.loadv] in Hl; rewrite (ofs_n _ Hn) in Hl; exact Hl end.
  Qed.

  (* the loop head: listIndex = sObjectListUpdateOrder[i]; if (listIndex == -1) break *)
  Lemma head_nt : forall e le m t le1 m1 out n ob,
    e ! OLP._sObjectListUpdateOrder = None ->
    Genv.find_symbol G OLP._sObjectListUpdateOrder = Some ob ->
    (forall j, (j < 11)%nat -> Mem.load Mint8signed m ob (Z.of_nat j) = Some (Vint (Int.repr (nth j OW.upd_order 0)))) ->
    le ! OLP._i = Some (Vint (Int.repr (Z.of_nat n))) -> (2 <= n <= 10)%nat ->
    exec_stmt function_entry2 G e le m nt_head t le1 m1 out ->
    m1 = m /\ le1 ! OLP._i = le ! OLP._i /\
    ((n = 10%nat /\ out = Out_break) \/
     ((n < 10)%nat /\ out = Out_normal /\ le1 ! OLP._listIndex = Some (Vint (Int.repr (nth n OW.upd_order 0))))).
  Proof.
    intros e le m t le1 m1 out n ob He Hs Hord Hi Hn H.
    unfold nt_head, nt_loop_body, OLP.f_update_non_terrain_objects in H. cbn [fn_body] in H.
    apply seq_inv in H as [(t1 & le2 & m2 & t2 & H1 & H2) | (H1 & Hn')]; [ | kill_abn ].
    apply seq_inv in H1 as [(t3 & le3 & m3 & t4 & H3 & H4) | (H3 & Hn')]; [ | kill_abn ].
    apply seq_inv in H3 as [(t5 & le5 & m5 & t6 & H5 & H6) | (H5 & Hn')]; [ | kill_abn ].
    apply set_inv in H5 as (v5 & Ev5 & -> & -> & _).
    pose proof (ev_order e le m n v5 ob He Hs Hi ltac:(lia) Ev5) as Hl5.
    rewrite Hord in Hl5 by lia. injection Hl5 as <-.
    apply set_inv in H6 as (v1 & Ev1 & -> & -> & _).
    apply ev_cast in Ev1 as (u & Eu & Cu). apply ev_temp in Eu. rewrite PTree.gss in Eu. injection Eu as <-.
    cbn [typeof] in Cu. apply cast_sc in Cu. subst v1.
    apply set_inv in H4 as (v2 & Ev2 & -> & -> & _).
    apply ev_temp in Ev2. rewrite PTree.gss in Ev2. injection Ev2 as <-.
    apply if_inv in H2 as (cv & bb & Ecv & Hbv & H2).
    apply ev_binop in Ecv as (w1 & w2 & W1 & W2 & W3).
    apply ev_temp in W1. rewrite PTree.gso, PTree.gss in W1 by neq. injection W1 as <-.
    apply ev_unop in W2 as (u1 & U1 & U2). apply ev_const in U1. subst u1.
    cbn [typeof] in W3, U2, Hbv.
    destruct (ifsb _ _ _ _ _ _ _ _ H2) as (-> & -> & ->).
    split; [ reflexivity | ].
    split; [ rewrite !PTree.gso by neq; reflexivity | ].
    destruct n as [|[|[|[|[|[|[|[|[|[|[|n]]]]]]]]]]]; try lia.
    all: vm_compute in U2; injection U2 as <-; vm_compute in W3; injection W3 as <-;
         vm_compute in Hbv; injection Hbv as <-.
    all: first [ (left; split; reflexivity) | (right; split; [ lia | split; [ reflexivity | apply PTree.gss ] ]) ].
  Qed.

  Section NT.
    Variable P : mem -> Prop.
    Hypothesis HPow : forall m, P m -> OW.obj_w G bm m.
    Hypothesis Hsa : step_row G P (in_ring_l G bm nt_ls) OLP.f_update_objects_starting_at.
    Hypothesis Hts : step_row G P (in_ring_l G bm nt_ls) OLP.f_update_objects_during_time_stop.
    Hypothesis Hsa_nr : step_nr_row G P (in_ring_l G bm nt_ls) OLP.f_update_objects_starting_at.
    Hypothesis Hts_nr : step_nr_row G P (in_ring_l G bm nt_ls) OLP.f_update_objects_during_time_stop.
    Hypothesis Hctr : forall m b c m', P m -> Genv.find_symbol G OLP._gObjectCounter = Some b ->
      Mem.store Mint32 m b 0 (Vint c) = Some m' -> P m'.
    Hypothesis Hblind : forall b m m', Ple (Genv.genv_next G) b -> P m -> ObjPhase.noref b m ->
      Mem.unchanged_on (fun b' _ => b' <> b) m m' -> P m'.
    Hypothesis Hfresh : forall m m1 b, P m -> Mem.alloc m 0 4 = (m1, b) ->
      Ple (Genv.genv_next G) b /\ ObjPhase.noref b m1.

    Section Frame.
      Variable fb : block.
      Hypothesis Hfb : Ple (Genv.genv_next G) fb.
      Variable e : env.
      Hypothesis He1 : e ! OLP._gObjectLists = None.
      Hypothesis He2 : e ! OLP._update_objects_in_list = None.
      Hypothesis He3 : e ! OLP._gObjectCounter = None.
      Hypothesis He4 : e ! OLP._sObjectListUpdateOrder = None.

      Definition Pf (m : mem) : Prop := P m /\ ObjPhase.noref fb m.

      Lemma step_and : forall f, step_row G P (in_ring_l G bm nt_ls) f -> step_nr_row G P (in_ring_l G bm nt_ls) f ->
        step_row G Pf (in_ring_l G bm nt_ls) f.
      Proof.
        intros f H1 H2 hd v le m t le' m' out (HP & Hn) Hr Hv Ho Hx.
        destruct (H1 _ _ _ _ _ _ _ _ HP Hr Hv Ho Hx) as (HP' & Hr').
        exact (conj (conj HP' (H2 fb Hfb _ _ _ _ _ _ _ _ HP Hn Hr Hv Ho Hx)) Hr').
      Qed.

      Lemma ctr_and : forall m b c m', Pf m -> Genv.find_symbol G OLP._gObjectCounter = Some b ->
        Mem.store Mint32 m b 0 (Vint c) = Some m' -> Pf m'.
      Proof.
        intros m b c m' (HP & Hn) Hs Hst.
        exact (conj (Hctr _ _ _ _ HP Hs Hst) (store_int_noref _ _ _ _ _ _ Hst Hn)).
      Qed.

      Lemma pow_f : forall m, Pf m -> OW.obj_w G bm m.
      Proof. intros m H. exact (HPow m (proj1 H)). Qed.

      Definition Knt (le : temp_env) (m : mem) : Prop :=
        Pf m /\ exists n, le ! OLP._i = Some (Vint (Int.repr (Z.of_nat n))) /\ (2 <= n <= 10)%nat.

      Lemma it_nt : forall le m t le1 m1 out,
        exec_stmt function_entry2 G e le m (Ssequence nt_head nt_rest) t le1 m1 out -> Knt le m ->
        Pf m1 /\ (out = Out_break \/ (out = Out_normal /\ Knt le1 m1)).
      Proof.
        intros le m t le1 m1 out H (HP & n & Hi & Hn).
        destruct (HPow m (proj1 HP)) as (pool & la & fl & gol & gmo & sdp & gdi & rs & fs & _ & _ & _ & _ & _ & _ & _ & Hc).
        destruct (OW.ow_order _ _ _ _ _ _ _ _ _ _ _ _ Hc) as (ob & Hob & Hord).
        apply seq_inv in H as [(t1 & le2 & m2 & t2 & H1 & H2) | (H1 & Hn')].
        2: { destruct (head_nt _ _ _ _ _ _ _ n ob He4 Hob Hord Hi Hn H1) as (-> & _ & [(_ & ->) | (_ & E & _)]);
             [ split; [ exact HP | left; reflexivity ] | exfalso; exact (Hn' E) ]. }
        destruct (head_nt _ _ _ _ _ _ _ n ob He4 Hob Hord Hi Hn H1) as (-> & Hi2 & [(_ & E) | (Hlt & _ & Hli)]);
          [ discriminate E | ].
        unfold nt_rest, nt_loop_body, OLP.f_update_non_terrain_objects in H2. cbn [fn_body] in H2.
        apply seq_inv in H2 as [(t3 & le3 & m3 & t4 & H3 & H4) | (H3 & Hn')]; [ | kill_abn ].
        apply seq_inv in H3 as [(t5 & le5 & m5 & t6 & H5 & H6) | (H5 & Hn')]; [ | kill_abn ].
        destruct (nt_idx n ltac:(lia)) as (idx & Eidx & Hin & Hidx).
        assert (Ha : forall gv v, eval_expr G e (PTree.set OLP._t'4 gv le2) m (Etempvar OLP._listIndex tint) v ->
                       v = Vint (Int.repr (Z.of_nat idx))).
        { intros gv v Ev. apply ev_temp in Ev. rewrite PTree.gso in Ev by neq. rewrite Hli in Ev.
          injection Ev as <-. f_equal. f_equal. exact Eidx. }
        destruct (call_il nt_ls Pf pow_f (step_and _ Hsa Hsa_nr) (step_and _ Hts Hts_nr)
                    e le2 m _ _ _ _ OLP._t'4 OLP._t'2 (Etempvar OLP._listIndex tint) idx
                    HP He1 He2 Hin Hidx eq_refl Ha H5) as (HP5 & _ & c & gv & ->).
        apply seq_inv in H6 as [(t7 & le7 & m7 & t8 & H7 & H8) | (H7 & Hn')]; [ | kill_abn ].
        apply set_inv in H7 as (w & _ & -> & -> & _).
        assert (Ha2 : forall v, eval_expr G e (PTree.set OLP._t'3 w (PTree.set OLP._t'2 (Vint c) (PTree.set OLP._t'4 gv le2))) m5
                          (Ebinop Oadd (Etempvar OLP._t'3 tuint) (Etempvar OLP._t'2 tint) tuint) v -> exists c', v = Vint c').
        { intros v Ev. apply ev_binop in Ev as (y1 & y2 & Y1 & Y2 & Y3).
          apply ev_temp in Y2. rewrite PTree.gso, PTree.gss in Y2 by neq. injection Y2 as <-.
          cbn [typeof] in Y3. exact (add_u_i _ _ _ _ _ Y3). }
        destruct (ctr_set Pf ctr_and _ _ _ _ _ _ _ _ HP5 He3 Ha2 (or_intror eq_refl) H8) as (HP8 & -> & _).
        apply set_inv in H4 as (vi & Evi & -> & -> & ->).
        apply ev_binop in Evi as (z1 & z2 & Z1 & Z2 & Z3).
        apply ev_temp in Z1. rewrite !PTree.gso in Z1 by neq. rewrite Hi2, Hi in Z1. injection Z1 as <-.
        apply ev_const in Z2. subst z2. cbn [typeof] in Z3.
        assert (E : sem_binary_operation G Oadd (Vint (Int.repr (Z.of_nat n))) tint (Vint (Int.repr 1)) tint m3
                    = Some (Vint (Int.add (Int.repr (Z.of_nat n)) (Int.repr 1)))) by reflexivity.
        rewrite E in Z3. injection Z3 as <-.
        split; [ exact HP8 | right; split; [ reflexivity | ] ].
        split; [ exact HP8 | exists (S n); split; [ rewrite PTree.gss, (add1 n ltac:(lia)); reflexivity | lia ] ].
      Qed.

      Lemma loop_nt : forall le m t le' m' out,
        exec_stmt function_entry2 G e le m (Sloop (Ssequence nt_head nt_rest) Sskip) t le' m' out ->
        Knt le m -> Pf m' /\ out = Out_normal.
      Proof.
        intros le m t le' m' out H. pose proof it_nt as IT.
        remember (Sloop (Ssequence nt_head nt_rest) Sskip) as S eqn:ES.
        revert ES. induction H; intros ES HK; try discriminate ES; injection ES as E1 E2; subst.
        - destruct (IT _ _ _ _ _ _ H HK) as (HP1 & [-> | (-> & _)]); inv H0. split; [ exact HP1 | reflexivity ].
        - apply skip_inv in H1 as (_ & _ & ->). inv H2.
        - destruct (IT _ _ _ _ _ _ H HK) as (HP1 & [-> | (-> & HK1)]); [ inv H0 | ].
          apply skip_inv in H1 as (-> & -> & _).
          eapply IHexec_stmt3; eauto.
      Qed.
    End Frame.

    Ltac envtac := rewrite PTree.gso by neq; apply PTree.gempty.

    (* update_non_terrain_objects: PROVED from the per-object rows *)
    Theorem nonterrain_keeps : ObjPhase.call_keeps G P OLP._update_non_terrain_objects.
    Proof.
      intros bf fd m vargs t m' vr Hs Hf HP Hev.
      rewrite (fun_olp _ _ dm_nt bf fd Hs Hf) in Hev.
      remember (Internal OLP.f_update_non_terrain_objects) as fd' eqn:Efd.
      destruct Hev as [mm ff va tt ee lea leb mm1 mm2 oo vv mm3 Hfe Hx Hor Hfr | ];
        [ injection Efd as Eff; subst ff | discriminate Efd ].
      destruct Hfe as [_ _ _ Hav Hb].
      cbn [fn_vars OLP.f_update_non_terrain_objects] in Hav.
      inversion Hav as [ | e0 m0 id0 ty0 vs0 m1 b1 m2 e2 Hal Hrest ]; subst.
      inversion Hrest; subst.
      change (sizeof G (tarray tuchar 4)) with 4 in Hal.
      destruct (Hfresh _ _ _ HP Hal) as (Hple & Hn1).
      match type of Hal with Mem.alloc _ 0 4 = (?mx, _) => rename mx into ma end.
      assert (HP1 : P ma).
      { apply (Hblind b1 _ _ Hple HP (ObjPhase.noref_alloc _ _ _ _ _ Hal Hn1)).
        apply (Mem.unchanged_on_implies (fun _ _ => True)); [ | intros; exact I ].
        exact (Mem.alloc_unchanged_on _ _ _ _ _ _ Hal). }
      rewrite nt_shape in Hx.
      apply seq_inv in Hx as [(t1 & le1 & m3 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_abn ].
      apply set_inv in X1 as (iv & Eiv & -> & -> & _). apply ev_const in Eiv. subst iv.
      destruct (loop_nt b1 Hple (PTree.set OLP._filler (b1, tarray tuchar 4) empty_env)
                  ltac:(envtac) ltac:(envtac) ltac:(envtac) ltac:(envtac) _ _ _ _ _ _ X2)
        as ((HP2 & Hn2) & _).
      { split; [ exact (conj HP1 Hn1) | exists 2%nat; split; [ apply PTree.gss | lia ] ]. }
      change (blocks_of_env G (PTree.set OLP._filler (b1, tarray tuchar 4) empty_env)) with [(b1, 0, 4)] in Hfr.
      apply ObjPhase.free_list_one in Hfr.
      apply (Hblind b1 _ _ Hple HP2 Hn2).
      apply (Mem.free_unchanged_on _ _ _ _ _ _ Hfr). intros i _ N. exact (N eq_refl).
    Qed.
  End NT.
End Real.
