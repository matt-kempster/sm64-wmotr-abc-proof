(* ====================================================================== *)
(* AnimEnd (GOAL 2): reading AnimWorld.anim_st off a pole walk's outcome.  *)
(*                                                                        *)
(* anim_end_ok checks an outcome of a walk of a pole handler: its action  *)
(* is not one of the pole actions after the grab (AnimWorld.anim_acts), or *)
(* the outcome holds                                                       *)
(*   - a handstand animation k loaded (loaded_chk): currentAddr is k's    *)
(*     address in gMarioAnims, animID = k, curAnim = the buffer, no       *)
(*     acceleration, the frame in [-1, loopEnd_k] (a constant or a path   *)
(*     fact kF), and the buffer cells of k's relocated header, index      *)
(*     table and samples;                                                  *)
(*   - no handstand animation (nstate_chk): animID a constant not 9 / 11 /*)
(*     12 and currentAddr a non-handstand address of gMarioAnims or NULL; *)
(*   - or (when the walk starts in a pole action, so the start holds       *)
(*     anim_st) every cell anim_st reads untouched.                        *)
(* anim_end_sound turns it into anim_st of the memory after.              *)
(* ====================================================================== *)

From Coq Require Import ZArith List Bool Lia.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Events Globalenvs
  Ctypes Cop Clight ClightBigstep.
From SM64.Proofs Require Import Interp.SymExec2.
From SM64.Proofs.WMotRRequiresA Require Import AnimData AnimWorld RytXc.
Import ListNotations.
Local Transparent Archi.ptr64.

(* the types of load_patchable_table's and set_mario_animation's tests *)
Definition tI16 : type := Tint I16 Signed noattr.
Definition tI32 : type := Tint I32 Signed noattr.
Definition tpu8 : type := Tpointer (Tint I8 Unsigned noattr) noattr.
Definition tpv : type := Tpointer Tvoid noattr.
Definition teqb (a b : type) : bool := if type_eq a b then true else false.

Lemma teqb_eq : forall a b, teqb a b = true -> a = b.
Proof. intros a b H. unfold teqb in H. destruct (type_eq a b); [exact e | discriminate H]. Qed.

Section CHK.
Variables (nbase : positive) (R0 : list (positive * Z)) (kv : list (positive * Z * memory_chunk * sval)).
Variables (rM rO rLD rBUF rGA kF : positive).

Definition bsv (v : bcv) : sval :=
  match v with BI z => Sconst (Vint (Int.repr z)) | BP r => Sptr rBUF (Ptrofs.repr r) end.

Definition cint_is (s : sval) (z : Z) : bool :=
  match s with Sconst (Vint i) => Z.eqb (Int.signed i) z | _ => false end.

(* the frame: a constant or a kF fact within [-1, le] *)
Definition frame_chk (pc : list fact) (s : sval) (le : Z) : bool :=
  match s with
  | Sconst (Vint i) => (-1 <=? Int.signed i) && (Int.signed i <=? le)
  | _ => existsb (fun f => match kF_bounds kF s f with
                           | Some (lo, hi) => (-1 <=? Int.signed lo) && (Int.signed hi <=? le)
                           | None => false end) pc
  end.

Definition buf_chk (g : gst) (k : Z) : bool :=
  forallb (fun x => let '(rel, ch, v) := x in
             match sload nbase R0 kv g rBUF rel ch with Some s => sbeq s (bsv v) | None => false end)
          (buf_cells k).

Definition loaded_chk (g : gst) (k : Z) : bool :=
  let LD := sload nbase R0 kv g in
  match LD rLD 4 Mint32, LD rO 56 Mint16signed, LD rO 60 Mint32, LD rO 64 Mint16signed, LD rO 72 Mint32 with
  | Some (Sptr r1 o1), Some s56, Some (Sptr r2 o2), Some s64, Some s72 =>
      Pos.eqb r1 rGA && Z.eqb (Ptrofs.unsigned o1) (hs_off k) && cint_is s56 k
      && Pos.eqb r2 rBUF && Ptrofs.eq o2 Ptrofs.zero && cint_is s72 0
      && frame_chk (g_pc g) s64 (hs_le k) && buf_chk g k
  | _, _, _, _, _ => false
  end.

(* currentAddr names no handstand animation *)
Definition caddr_ok (s : sval) : bool :=
  match s with
  | Sptr r o => Pos.eqb r rGA && (Ptrofs.unsigned o <=? GA_SIZE)
                && negb (existsb (Z.eqb (Ptrofs.unsigned o)) hs_offs)
  | Sconst (Vint i) => Int.eq i Int.zero
  | _ => false
  end.
Definition nid_ok (s : sval) : bool :=
  match s with
  | Sconst (Vint i) => negb (existsb (Z.eqb (Int.signed i)) hs_ids)
  | _ => false
  end.

(* set_mario_animation's `animID != targetAnimID` taken false: animID is
   the target *)
Definition nid_fact (pc : list fact) (s : sval) : bool :=
  existsb (fun f => match f with
    | Fbool (Sbinop Cop.One s' t1 (Sconst (Vint x)) t2) t3 false =>
        sbeq s' s && teqb t1 tI16 && teqb t2 tI32 && teqb t3 tI32
        && negb (existsb (Z.eqb (Int.signed x)) hs_ids)
    | _ => false end) pc.

(* load_patchable_table's `currentAddr != addr` taken false: currentAddr
   is addr, a non-handstand address of gMarioAnims *)
Definition caddr_fact (pc : list fact) (s : sval) : bool :=
  existsb (fun f => match f with
    | Fbool (Sbinop Cop.One (Sptr r o) t1 s' t2) t3 false =>
        Pos.eqb r rGA && sbeq s' s && teqb t1 tpu8 && teqb t2 tpv && teqb t3 tI32
        && (Ptrofs.unsigned o <=? GA_SIZE)
        && negb (existsb (Z.eqb (Ptrofs.unsigned o)) hs_offs)
    | _ => false end) pc.

Definition nstate_chk (g : gst) : bool :=
  let LD := sload nbase R0 kv g in
  match LD rO 56 Mint16signed, LD rLD 4 Mint32 with
  | Some s56, Some s4 => (nid_ok s56 || nid_fact (g_pc g) s56) && (caddr_ok s4 || caddr_fact (g_pc g) s4)
  | _, _ => false
  end.

(* a path whose facts contradict each other (a test taken both ways): no
   execution follows it *)
Definition incons (pc : list fact) : bool :=
  existsb (fun f => match f with
    | Fbool c ty true => existsb (fbeq (Fbool c ty false)) pc
    | _ => false end) pc.

(* a test of two addresses in one region taken the wrong way (the walker
   does not fold pointer comparisons; it forks): no execution follows it *)
Definition pinc (pc : list fact) : bool :=
  existsb (fun f => match f with
    | Fbool (Sbinop Cop.One (Sptr r o) t1 (Sptr r' o') t2) t3 b =>
        Pos.eqb r r' && teqb t1 tpu8 && teqb t2 tpv && teqb t3 tI32 && Bool.eqb b (Ptrofs.eq o o')
    | _ => false end) pc.

(* the cells anim_st reads *)
Definition anim_keys : list (positive * Z * memory_chunk) :=
  [(rLD, 4, Mint32); (rO, 56, Mint16signed); (rO, 60, Mint32); (rO, 64, Mint16signed); (rO, 72, Mint32)]
  ++ flat_map (fun k => map (fun x => let '(rel, ch, _) := x in (rBUF, rel, ch)) (buf_cells k)) hs_ids.

Definition untouched_chk (g : gst) : bool :=
  forallb (fun x => let '(r, o, ch) := x in
             match sload nbase R0 kv g r o ch with Some s => sbeq s (init_cell kv r o ch) | None => false end)
          anim_keys.

Definition anim_end_ok (st : bool) (g : gst) : bool :=
  match sload nbase R0 kv g rM 12 Mint32 with
  | Some (Sconst (Vint a)) =>
      negb (existsb (Z.eqb (Int.unsigned a)) anim_acts)
      || nstate_chk g || existsb (loaded_chk g) hs_ids || (st && untouched_chk g)
      || incons (g_pc g) || pinc (g_pc g)
  | _ => false
  end.
End CHK.

(* the two tests, taken false *)
Lemma cmp_ne_int_false : forall ge v1 x v m, sem_binary_operation ge Cop.One v1 tI16 (Vint x) tI32 m = Some v ->
  bool_val v tI32 m = Some false -> v1 = Vint x.
Proof.
  intros ge v1 x v m H B.
  destruct v1; cbn in H; try discriminate H.
  injection H as <-. destruct (Int.eq i x) eqn:E; cbn in B.
  - pose proof (Int.eq_spec i x) as Q. rewrite E in Q. subst. reflexivity.
  - discriminate B.
Qed.

Lemma cmp_ne_ptr_false : forall ge b o v2 v m, sem_binary_operation ge Cop.One (Vptr b o) tpu8 v2 tpv m = Some v ->
  bool_val v tI32 m = Some false -> v2 = Vptr b o.
Proof.
  intros ge b o v2 v m H B.
  destruct v2; cbn in H; try discriminate H;
    unfold cmp_ptr, Val.cmpu_bool, option_map in H; cbn in H.
  all: repeat match type of H with
    | context [if ?c then _ else _] => let Ec := fresh "Ec" in destruct c eqn:Ec; cbn in H; try discriminate H
    end.
  all: injection H as <-; cbn in B; try discriminate B.
  subst b0. destruct (Ptrofs.eq o i) eqn:Q; cbn in B; [| discriminate B].
  pose proof (Ptrofs.eq_spec o i) as Q'. rewrite Q in Q'. subst. reflexivity.
Qed.

Lemma cmp_pp_same : forall ge b x y v m, sem_binary_operation ge Cop.One (Vptr b x) tpu8 (Vptr b y) tpv m = Some v ->
  bool_val v tI32 m = Some (negb (Ptrofs.eq x y)).
Proof.
  intros ge b x y v m H.
  cbn in H. unfold cmp_ptr, Val.cmpu_bool, option_map in H; cbn in H.
  repeat match type of H with
    | context [if ?c then _ else _] => let Ec := fresh "Ec" in destruct c eqn:Ec; cbn in H; try discriminate H;
        try (exfalso; congruence)
    end.
  all: injection H as <-.
  all: destruct (Ptrofs.eq x y); reflexivity.
Qed.

Section SND.
Variables (ge : genv) (nbase : positive) (R0 : list (positive * Z)) (gtab : list (ident * positive))
  (kv : list (positive * Z * memory_chunk * sval)).
Variables (m0 : mem) (uf : positive -> list (option val) -> Prop) (gp : meminj).
Hypothesis gp_old : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0).
Variables (rM rO rLD rBUF rGA kF : positive).
Hypothesis HF : forall v lo hi, uf kF [v; Some (Vint lo); Some (Vint hi)] ->
  exists i, v = Some (Vint i) /\ Int.signed lo <= Int.signed i <= Int.signed hi.

Local Notation MM := (MMg ge nbase R0 gtab kv m0 uf gp).
Local Notation den := (den ge m0).

Variables (E : senv) (m : mem) (g : gst).
Hypothesis MMh : MM E m g.
Variables (bm ab bga bt mb : block) (ot mo : ptrofs).
Hypothesis EbM : e_blk E rM = bm /\ e_base E rM = Ptrofs.zero.
Hypothesis EbO : e_blk E rO = mb /\ e_base E rO = mo.
Hypothesis EbL : e_blk E rLD = ab /\ e_base E rLD = Ptrofs.zero.
Hypothesis EbB : e_blk E rBUF = bt /\ e_base E rBUF = ot.
Hypothesis EbG : e_blk E rGA = bga /\ e_base E rGA = Ptrofs.zero.

(* the two tests taken false, through den *)
Lemma den_ne_int : forall s x v, den E (Sbinop Cop.One s tI16 (Sconst (Vint x)) tI32) = Some v ->
  bool_val v tI32 m0 = Some false -> den E s = Some (Vint x).
Proof.
  intros s x v H B. cbn [SymExec2.den] in H.
  destruct (den E s) as [v1 |] eqn:D; [| discriminate H]. cbv beta iota in H.
  rewrite (cmp_ne_int_false _ _ _ _ _ H B). reflexivity.
Qed.
Lemma den_ne_ptr : forall s r o v, den E (Sbinop Cop.One (Sptr r o) tpu8 s tpv) = Some v ->
  bool_val v tI32 m0 = Some false -> den E s = den E (Sptr r o).
Proof.
  intros s r o v H B. cbn [SymExec2.den] in H |- *.
  destruct (den E s) as [v1 |] eqn:D; [| discriminate H]. cbv beta iota in H.
  rewrite (cmp_ne_ptr_false _ _ _ _ _ _ H B). reflexivity.
Qed.

Lemma LDs : forall r o ch s, sload nbase R0 kv g r o ch = Some s ->
  Mem.load ch m (e_blk E r) (Ptrofs.unsigned (e_base E r) + o) = den E s.
Proof.
  intros r o ch s H.
  exact (proj1 (sload_sound ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp gp_old
                  E m g r o ch s MMh H)).
Qed.

Lemma cint_is_den : forall s z, cint_is s z = true -> den E s = Some (Vint (Int.repr z)).
Proof.
  intros s z H. destruct s as [v | | | | | | | | |]; try discriminate H.
  destruct v; try discriminate H. cbn in H. apply Z.eqb_eq in H. cbn. rewrite <- H, Int.repr_signed.
  reflexivity.
Qed.

Lemma frame_chk_sound : forall s le, frame_chk kF (g_pc g) s le = true ->
  exists f, -1 <= f <= le /\ den E s = Some (Vint (Int.repr f)).
Proof.
  intros s le H.
  assert (FF : existsb (fun f => match kF_bounds kF s f with
                           | Some (lo, hi) => (-1 <=? Int.signed lo) && (Int.signed hi <=? le)
                           | None => false end) (g_pc g) = true ->
               exists f, -1 <= f <= le /\ den E s = Some (Vint (Int.repr f))).
  { intros H'. apply existsb_exists in H'. destruct H' as (f0 & If & Hf).
    destruct (kF_bounds kF s f0) as [[lo hi] |] eqn:B; [| discriminate Hf].
    apply andb_true_iff in Hf as [H1 H2]. apply Z.leb_le in H1, H2.
    pose proof (kF_bounds_spec _ _ _ _ _ B) as ->.
    pose proof MMh as (_ & _ & _ & _ & _ & _ & PC & _).
    destruct (PC _ If) as (_ & Hh). cbn [fact_holds map SymExec2.den] in Hh.
    destruct (HF _ _ _ Hh) as (i & Di & Ri). exists (Int.signed i).
    split; [lia |]. rewrite Di, Int.repr_signed. reflexivity. }
  destruct s as [v | | | | | | | | |]; cbn [frame_chk] in H; try exact (FF H).
  destruct v; try exact (FF H).
  apply andb_true_iff in H as [H1 H2]. apply Z.leb_le in H1, H2.
  exists (Int.signed i). split; [lia |]. cbn. rewrite Int.repr_signed. reflexivity.
Qed.

Lemma loaded_chk_sound : forall k, In k hs_ids -> loaded_chk nbase R0 kv rO rLD rBUF rGA kF g k = true ->
  loaded m ab bga bt ot mb mo k.
Proof.
  intros k Hk H. unfold loaded_chk in H.
  destruct (sload nbase R0 kv g rLD 4 Mint32) as [s4 |] eqn:L4; [| discriminate H].
  destruct s4 as [| r1 o1 | | | | | | | |]; try discriminate H.
  destruct (sload nbase R0 kv g rO 56 Mint16signed) as [s56 |] eqn:L56; [| discriminate H].
  destruct (sload nbase R0 kv g rO 60 Mint32) as [s60 |] eqn:L60; [| discriminate H].
  destruct s60 as [| r2 o2 | | | | | | | |]; try discriminate H.
  destruct (sload nbase R0 kv g rO 64 Mint16signed) as [s64 |] eqn:L64; [| discriminate H].
  destruct (sload nbase R0 kv g rO 72 Mint32) as [s72 |] eqn:L72; [| discriminate H].
  repeat rewrite andb_true_iff in H.
  destruct H as [[[[[[[R1 O1] C56] R2] O2] C72] Fr] Bf].
  apply Pos.eqb_eq in R1, R2. subst r1 r2. apply Z.eqb_eq in O1.
  pose proof (Ptrofs.eq_spec o2 Ptrofs.zero) as E2. rewrite O2 in E2. subst o2.
  destruct EbM as (BM1 & BM2). destruct EbO as (BO1 & BO2). destruct EbL as (BL1 & BL2).
  destruct EbB as (BB1 & BB2). destruct EbG as (BG1 & BG2).
  pose proof (LDs _ _ _ _ L4) as D4. pose proof (LDs _ _ _ _ L56) as D56.
  pose proof (LDs _ _ _ _ L60) as D60. pose proof (LDs _ _ _ _ L64) as D64.
  pose proof (LDs _ _ _ _ L72) as D72.
  rewrite BL1, BL2, Ptrofs.unsigned_zero, Z.add_0_l in D4. rewrite BO1, BO2 in D56, D60, D64, D72.
  split; [rewrite D4; cbn; rewrite BG1, BG2, Ptrofs.add_zero_l, <- O1, Ptrofs.repr_unsigned; reflexivity |].
  split; [rewrite D56; exact (cint_is_den _ _ C56) |].
  split; [rewrite D60; cbn; rewrite BB1, BB2, Ptrofs.add_zero; reflexivity |].
  split; [rewrite D72; exact (cint_is_den _ _ C72) |].
  split; [destruct (frame_chk_sound _ _ Fr) as (f & Rf & Df); exists f; split; [exact Rf | rewrite D64; exact Df] |].
  intros rel ch v Hin. unfold buf_chk in Bf.
  pose proof (proj1 (forallb_forall _ _) Bf _ Hin) as Hc. cbn beta iota in Hc.
  destruct (sload nbase R0 kv g rBUF rel ch) as [s |] eqn:Ls; [| discriminate Hc].
  unfold sbeq in Hc. destruct (sval_eq s (bsv rBUF v)) as [-> |]; [| discriminate Hc].
  pose proof (LDs _ _ _ _ Ls) as Db. rewrite BB1, BB2 in Db. rewrite Db.
  destruct v as [z | r]; cbn; [reflexivity | rewrite BB1, BB2; reflexivity].
Qed.

Lemma nstate_chk_sound : nstate_chk nbase R0 kv rO rLD rGA g = true -> nstate m ab bga mb mo.
Proof.
  intros H. unfold nstate_chk in H.
  destruct (sload nbase R0 kv g rO 56 Mint16signed) as [s56 |] eqn:L56; [| discriminate H].
  destruct (sload nbase R0 kv g rLD 4 Mint32) as [s4 |] eqn:L4; [| discriminate H].
  apply andb_true_iff in H as [N C].
  destruct EbO as (BO1 & BO2). destruct EbL as (BL1 & BL2). destruct EbG as (BG1 & BG2).
  pose proof (LDs _ _ _ _ L4) as D4. pose proof (LDs _ _ _ _ L56) as D56.
  rewrite BL1, BL2, Ptrofs.unsigned_zero, Z.add_0_l in D4. rewrite BO1, BO2 in D56.
  pose proof MMh as (_ & _ & _ & _ & _ & _ & PC & _).
  split.
  - apply orb_true_iff in N as [N | N].
    + destruct s56 as [v | | | | | | | | |]; try discriminate N. destruct v; try discriminate N.
      exists i. split; [exact D56 |]. intros Hin. cbn [nid_ok] in N.
      apply negb_true_iff in N. rewrite (proj2 (existsb_exists _ _)) in N; [discriminate N |].
      exists (Int.signed i). split; [exact Hin | apply Z.eqb_refl].
    + unfold nid_fact in N. apply existsb_exists in N as (f & If & Hf).
      repeat match type of Hf with
      | context [match ?x with _ => _ end] => destruct x; try discriminate Hf
      end.
      repeat rewrite andb_true_iff in Hf. destruct Hf as [[[[S1 T1] T2] T3] Nh].
      unfold sbeq in S1.
      match type of S1 with (if sval_eq ?a ?b then _ else _) = _ =>
        destruct (sval_eq a b) as [-> |]; [| discriminate S1] end.
      apply teqb_eq in T1, T2, T3. subst.
      destruct (PC _ If) as (_ & v & Dv & Bv). pose proof (den_ne_int _ _ _ Dv Bv) as D1.
      match type of D1 with _ = Some (Vint ?x) =>
        exists x; split; [rewrite D56; exact D1 |]; intros Hin;
        apply negb_true_iff in Nh; rewrite (proj2 (existsb_exists _ _)) in Nh; [discriminate Nh |];
        exists (Int.signed x); split; [exact Hin | apply Z.eqb_refl] end.
  - apply orb_true_iff in C as [C | C].
    2:{ unfold caddr_fact in C. apply existsb_exists in C as (f & If & Hf).
        repeat match type of Hf with
        | context [match ?x with _ => _ end] => destruct x; try discriminate Hf
        end.
        repeat rewrite andb_true_iff in Hf. destruct Hf as [[[[[[R S1] T1] T2] T3] Ho] Nh].
        apply Pos.eqb_eq in R. subst.
        unfold sbeq in S1.
        match type of S1 with (if sval_eq ?a ?b then _ else _) = _ =>
          destruct (sval_eq a b) as [-> |]; [| discriminate S1] end.
        apply teqb_eq in T1, T2, T3. subst. apply Z.leb_le in Ho.
        destruct (PC _ If) as (_ & v & Dv & Bv). pose proof (den_ne_ptr _ _ _ _ Dv Bv) as D2.
        cbn [SymExec2.den] in D2. rewrite BG2, Ptrofs.add_zero_l in D2.
        match type of D2 with _ = Some (Vptr _ ?x) =>
          right; exists x; split; [rewrite D4; exact D2 |];
          split; [exact Ho |]; intros Hin; apply negb_true_iff in Nh;
          rewrite (proj2 (existsb_exists _ _)) in Nh; [discriminate Nh |];
          exists (Ptrofs.unsigned x); split; [exact Hin | apply Z.eqb_refl] end. }
    destruct s4 as [v | r o | | | | | | | |]; try discriminate C.
    + destruct v; try discriminate C. cbn [caddr_ok] in C.
      pose proof (Int.eq_spec i Int.zero) as Ei. rewrite C in Ei. subst i.
      left. exact D4.
    + cbn [caddr_ok] in C. repeat rewrite andb_true_iff in C. destruct C as [[R Ho] Nh].
      apply Pos.eqb_eq in R. subst r. apply Z.leb_le in Ho.
      right. exists o. split; [rewrite D4; cbn; rewrite BG1, BG2, Ptrofs.add_zero_l; reflexivity |].
      split; [exact Ho |]. intros Hin. apply negb_true_iff in Nh.
      rewrite (proj2 (existsb_exists _ _)) in Nh; [discriminate Nh |].
      exists (Ptrofs.unsigned o). split; [exact Hin | apply Z.eqb_refl].
Qed.

Lemma untouched_sound : untouched_chk nbase R0 kv rO rLD rBUF g = true ->
  anim_st m0 ab bga bt ot mb mo -> anim_st m ab bga bt ot mb mo.
Proof.
  intros H A.
  pose proof MMh as (EO & _).
  assert (K : forall r o ch, In (r, o, ch) (anim_keys rO rLD rBUF) ->
            Mem.load ch m (e_blk E r) (Ptrofs.unsigned (e_base E r) + o)
            = Mem.load ch m0 (e_blk E r) (Ptrofs.unsigned (e_base E r) + o)).
  { intros r o ch Hin. pose proof (proj1 (forallb_forall _ _) H _ Hin) as Hc. cbn beta iota in Hc.
    destruct (sload nbase R0 kv g r o ch) as [s |] eqn:Ls; [| discriminate Hc].
    unfold sbeq in Hc. destruct (sval_eq s (init_cell kv r o ch)) as [-> |]; [| discriminate Hc].
    rewrite (LDs _ _ _ _ Ls).
    exact (proj1 (init_cell_den ge nbase R0 gtab kv m0 gp E r o ch EO)). }
  destruct EbO as (BO1 & BO2). destruct EbL as (BL1 & BL2). destruct EbB as (BB1 & BB2).
  apply (anim_st_keep m0 m ab bga bt ot mb mo A).
  - pose proof (K rLD 4 Mint32 ltac:(left; reflexivity)) as K4.
    rewrite BL1, BL2, Ptrofs.unsigned_zero, Z.add_0_l in K4. exact K4.
  - intros o ch Hin. pose proof (K rO o ch) as Ko. rewrite BO1, BO2 in Ko. apply Ko.
    unfold anim_keys. apply in_or_app. left.
    destruct Hin as [E1 | [E1 | [E1 | [E1 | []]]]]; injection E1 as <- <-; cbn; auto 6.
  - intros k rel ch v Hk Hin. pose proof (K rBUF rel ch) as Kb. rewrite BB1, BB2 in Kb. apply Kb.
    unfold anim_keys. apply in_or_app. right. apply in_flat_map. exists k. split; [exact Hk |].
    apply in_map_iff. exists (rel, ch, v). split; [reflexivity | exact Hin].
Qed.

Theorem anim_end_sound : forall st, anim_end_ok nbase R0 kv rM rO rLD rBUF rGA kF st g = true ->
  (st = true -> anim_st m0 ab bga bt ot mb mo) ->
  forall a, Mem.load Mint32 m bm 12 = Some (Vint a) -> In (Int.unsigned a) anim_acts ->
  anim_st m ab bga bt ot mb mo.
Proof.
  intros st H S a La Ia. unfold anim_end_ok in H.
  destruct (sload nbase R0 kv g rM 12 Mint32) as [s |] eqn:Ls; [| discriminate H].
  destruct s as [v | | | | | | | | |]; try discriminate H. destruct v; try discriminate H.
  pose proof (LDs _ _ _ _ Ls) as D. destruct EbM as (BM1 & BM2).
  rewrite BM1, BM2, Ptrofs.unsigned_zero in D. cbn in D. rewrite La in D. injection D as ->.
  repeat rewrite orb_true_iff in H. destruct H as [[[[[N | Ns] | Lk] | U] | Ic] | Pi].
  6:{ exfalso. unfold pinc in Pi. apply existsb_exists in Pi as (f & If & Hf).
      repeat match type of Hf with
      | context [match ?x with _ => _ end] => destruct x; try discriminate Hf
      end.
      repeat rewrite andb_true_iff in Hf. destruct Hf as [[[[R T1] T2] T3] Bq].
      apply Pos.eqb_eq in R. subst. apply teqb_eq in T1, T2, T3. subst.
      apply Bool.eqb_prop in Bq. subst.
      pose proof MMh as (_ & _ & _ & _ & _ & _ & PC & _).
      destruct (PC _ If) as (_ & v & Dv & Bv). cbn [SymExec2.den] in Dv. cbv beta iota in Dv.
      rewrite (cmp_pp_same _ _ _ _ _ _ Dv) in Bv. injection Bv as Bv.
      match type of Bv with negb (Ptrofs.eq (Ptrofs.add ?b ?x) (Ptrofs.add ?b ?y)) = Ptrofs.eq ?x ?y =>
        rewrite (Ptrofs.add_commut b x), (Ptrofs.add_commut b y), Ptrofs.translate_eq in Bv;
        destruct (Ptrofs.eq x y); discriminate Bv end. }
  5:{ exfalso. unfold incons in Ic. apply existsb_exists in Ic as (f & If & Hf).
      destruct f as [c ty b | | |]; try discriminate Hf. destruct b; [| discriminate Hf].
      apply existsb_exists in Hf as (f' & If' & Hf'). unfold fbeq in Hf'.
      destruct (fact_eq (Fbool c ty false) f') as [<- |]; [| discriminate Hf'].
      pose proof MMh as (_ & _ & _ & _ & _ & _ & PC & _).
      destruct (PC _ If) as (_ & v1 & D1 & B1). destruct (PC _ If') as (_ & v2 & D2 & B2).
      rewrite D1 in D2. injection D2 as <-. rewrite B1 in B2. discriminate B2. }
  - apply negb_true_iff in N. rewrite (proj2 (existsb_exists _ _)) in N; [discriminate N |].
    exists (Int.unsigned i). split; [exact Ia | apply Z.eqb_refl].
  - left. exact (nstate_chk_sound Ns).
  - apply existsb_exists in Lk. destruct Lk as (k & Hk & Lk). right. exists k.
    split; [exact Hk | exact (loaded_chk_sound k Hk Lk)].
  - apply andb_true_iff in U as [St U]. subst st. exact (untouched_sound U (S eq_refl)).
Qed.
End SND.
