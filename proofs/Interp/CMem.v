(* kept: general tool -- vm_compute-able versions of CompCert's memory
   operations, each PROVED EQUAL to the original.  CompCert's
   Mem.range_perm_dec is defined by well-founded recursion over an opaque
   (Qed) accessibility proof, so vm_compute gets stuck on every Mem.load /
   store / loadbytes / storebytes / free -- and reading back the stuck term
   exhausts memory.  Here the same check is a structural recursion. *)

From Coq Require Import ZArith List.
From compcert Require Import Coqlib Maps Integers Values AST Memdata Memory.

Local Transparent Mem.load Mem.loadbytes Mem.store Mem.storebytes Mem.free.

Fixpoint perm_run (m : mem) (b : block) (lo : Z) (n : nat) (k : perm_kind)
    (p : permission) : bool :=
  match n with
  | O => true
  | S n' => (if Mem.perm_dec m b lo k p then true else false) && perm_run m b (lo + 1) n' k p
  end.

Definition range_perm_b (m : mem) (b : block) (lo hi : Z) (k : perm_kind)
    (p : permission) : bool :=
  perm_run m b lo (Z.to_nat (hi - lo)) k p.

Lemma perm_run_spec : forall m b k p n lo,
    perm_run m b lo n k p = true <-> Mem.range_perm m b lo (lo + Z.of_nat n) k p.
Proof.
  induction n as [|n IH]; intros lo; cbn [perm_run].
  - split; auto. intros _ ofs H. lia.
  - rewrite andb_true_iff, IH. split.
    + intros [H1 H2] ofs Hofs.
      destruct (Mem.perm_dec m b lo k p); [ | discriminate].
      destruct (zeq ofs lo); [subst; auto | apply H2; lia].
    + intros H. split.
      * destruct (Mem.perm_dec m b lo k p) as [|n0]; auto. elim n0. apply H. lia.
      * intros ofs Hofs. apply H. lia.
Qed.

Lemma range_perm_b_spec : forall m b lo hi k p,
    range_perm_b m b lo hi k p = true <-> Mem.range_perm m b lo hi k p.
Proof.
  intros. unfold range_perm_b. rewrite perm_run_spec.
  destruct (zle lo hi).
  - rewrite Z2Nat.id by lia. replace (lo + (hi - lo)) with hi by lia. tauto.
  - rewrite Z_to_nat_neg by lia. split; intros _ ofs H; lia.
Qed.

Definition valid_access_b (m : mem) (chunk : memory_chunk) (b : block) (ofs : Z)
    (p : permission) : bool :=
  range_perm_b m b ofs (ofs + size_chunk chunk) Cur p
  && (if Zdivide_dec (align_chunk chunk) ofs then true else false).

Lemma valid_access_b_spec : forall m chunk b ofs p,
    valid_access_b m chunk b ofs p = true <-> Mem.valid_access m chunk b ofs p.
Proof.
  intros. unfold valid_access_b, Mem.valid_access.
  rewrite andb_true_iff, range_perm_b_spec.
  destruct (Zdivide_dec _ _); intuition congruence.
Qed.


(* ---- loads ---- *)

Definition load (chunk : memory_chunk) (m : mem) (b : block) (ofs : Z) : option val :=
  if valid_access_b m chunk b ofs Readable
  then Some (decode_val chunk (Mem.getN (size_chunk_nat chunk) ofs (Mem.mem_contents m) !! b))
  else None.

Lemma load_eq : forall chunk m b ofs, load chunk m b ofs = Mem.load chunk m b ofs.
Proof.
  intros. unfold load, Mem.load.
  destruct (valid_access_b m chunk b ofs Readable) eqn:E.
  - apply valid_access_b_spec in E. destruct (Mem.valid_access_dec _ _ _ _ _); tauto.
  - destruct (Mem.valid_access_dec _ _ _ _ _) as [V|]; auto.
    apply valid_access_b_spec in V. congruence.
Qed.

Definition loadv (chunk : memory_chunk) (m : mem) (addr : val) : option val :=
  match addr with Vptr b ofs => load chunk m b (Ptrofs.unsigned ofs) | _ => None end.

Lemma loadv_eq : forall chunk m a, loadv chunk m a = Mem.loadv chunk m a.
Proof. intros; destruct a; auto; apply load_eq. Qed.

Definition loadbytes (m : mem) (b : block) (ofs n : Z) : option (list memval) :=
  if range_perm_b m b ofs (ofs + n) Cur Readable
  then Some (Mem.getN (Z.to_nat n) ofs (Mem.mem_contents m) !! b)
  else None.

Lemma loadbytes_eq : forall m b ofs n, loadbytes m b ofs n = Mem.loadbytes m b ofs n.
Proof.
  intros. unfold loadbytes, Mem.loadbytes.
  destruct (range_perm_b m b ofs (ofs + n) Cur Readable) eqn:E.
  - apply range_perm_b_spec in E. destruct (Mem.range_perm_dec _ _ _ _ _ _); tauto.
  - destruct (Mem.range_perm_dec _ _ _ _ _ _) as [V|]; auto.
    apply range_perm_b_spec in V. congruence.
Qed.

(* ---- stores: same contents/access/nextblock, own default-contents proof ---- *)

Lemma set_default : forall (m : mem) b ofs l b0,
    fst ((PMap.set b (Mem.setN l ofs (Mem.mem_contents m) !! b) (Mem.mem_contents m)) !! b0)
    = Undef.
Proof.
  intros. rewrite PMap.gsspec. destruct (peq b0 b).
  - rewrite Mem.setN_default. apply Mem.contents_default.
  - apply Mem.contents_default.
Qed.

Definition store_raw (m : mem) (b : block) (ofs : Z) (l : list memval) : mem :=
  Mem.mkmem (PMap.set b (Mem.setN l ofs (Mem.mem_contents m) !! b) (Mem.mem_contents m))
            (Mem.mem_access m) (Mem.nextblock m)
            (Mem.access_max m) (Mem.nextblock_noaccess m) (set_default m b ofs l).

Definition store (chunk : memory_chunk) (m : mem) (b : block) (ofs : Z) (v : val)
    : option mem :=
  if valid_access_b m chunk b ofs Writable
  then Some (store_raw m b ofs (encode_val chunk v))
  else None.

Lemma store_eq : forall chunk m b ofs v, store chunk m b ofs v = Mem.store chunk m b ofs v.
Proof.
  intros. unfold store, Mem.store.
  destruct (valid_access_b m chunk b ofs Writable) eqn:E.
  - apply valid_access_b_spec in E. destruct (Mem.valid_access_dec _ _ _ _ _); [ | tauto].
    f_equal. apply Mem.mkmem_ext; auto.
  - destruct (Mem.valid_access_dec _ _ _ _ _) as [V|]; auto.
    apply valid_access_b_spec in V. congruence.
Qed.

Definition storev (chunk : memory_chunk) (m : mem) (addr v : val) : option mem :=
  match addr with Vptr b ofs => store chunk m b (Ptrofs.unsigned ofs) v | _ => None end.

Lemma storev_eq : forall chunk m a v, storev chunk m a v = Mem.storev chunk m a v.
Proof. intros; destruct a; auto; apply store_eq. Qed.

Definition storebytes (m : mem) (b : block) (ofs : Z) (bytes : list memval) : option mem :=
  if range_perm_b m b ofs (ofs + Z.of_nat (length bytes)) Cur Writable
  then Some (store_raw m b ofs bytes)
  else None.

Lemma storebytes_eq : forall m b ofs l, storebytes m b ofs l = Mem.storebytes m b ofs l.
Proof.
  intros. unfold storebytes, Mem.storebytes.
  destruct (range_perm_b m b ofs (ofs + Z.of_nat (length l)) Cur Writable) eqn:E.
  - apply range_perm_b_spec in E. destruct (Mem.range_perm_dec _ _ _ _ _ _); [ | tauto].
    f_equal. apply Mem.mkmem_ext; auto.
  - destruct (Mem.range_perm_dec _ _ _ _ _ _) as [V|]; auto.
    apply range_perm_b_spec in V. congruence.
Qed.

(* ---- free ---- *)

Definition free (m : mem) (b : block) (lo hi : Z) : option mem :=
  if range_perm_b m b lo hi Cur Freeable then Some (Mem.unchecked_free m b lo hi) else None.

Lemma free_eq : forall m b lo hi, free m b lo hi = Mem.free m b lo hi.
Proof.
  intros. unfold free, Mem.free.
  destruct (range_perm_b m b lo hi Cur Freeable) eqn:E.
  - apply range_perm_b_spec in E. destruct (Mem.range_perm_dec _ _ _ _ _ _); tauto.
  - destruct (Mem.range_perm_dec _ _ _ _ _ _) as [V|]; auto.
    apply range_perm_b_spec in V. congruence.
Qed.

Fixpoint free_list (m : mem) (l : list (block * Z * Z)) : option mem :=
  match l with
  | nil => Some m
  | (b, lo, hi) :: l' =>
      match free m b lo hi with Some m' => free_list m' l' | None => None end
  end.

Lemma free_list_eq : forall l m, free_list m l = Mem.free_list m l.
Proof.
  induction l as [|[[b lo] hi] l IH]; intros m; cbn; auto.
  rewrite free_eq. destruct (Mem.free m b lo hi); auto.
Qed.
