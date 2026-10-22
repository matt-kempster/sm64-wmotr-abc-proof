(* kept: general tool -- a COMPUTABLE Genv.init_mem.

   Genv.init_mem is not computable by vm_compute: store_zeros is defined by
   well-founded recursion and drop_perm / store decide permissions with
   range_perm_dec.  [alloc_globals_c] performs the same allocations, the same
   zero fill, the same initializer stores and the same permission drops with
   computable operations, and [init_mem_c] proves that whenever
   Genv.init_mem p = Some m, the computable version returns exactly that m
   (Leibniz-equal: same contents, same access closures, same nextblock).  So a
   run over the computed memory is a run over the program's real boot image,
   permissions included (read-only and function blocks too). *)

From Coq Require Import List Lia.
From compcert Require Import Coqlib Maps Integers Values AST Memtype Memory Memdata Globalenvs.
From SM64.Proofs Require Interp.CMem.
Module CM := SM64.Proofs.Interp.CMem.
Import ListNotations.

(* ---- store_zeros, without its permission checks ---- *)
Definition zeros_c (m : mem) (b : block) (p n : Z) : mem :=
  if Z.leb n 0 then m else CM.store_raw m b p (List.repeat (Byte Byte.zero) (Z.to_nat n)).

Lemma store_raw_cons : forall m b p x l,
    CM.store_raw (CM.store_raw m b p [x]) b (p + 1) l = CM.store_raw m b p (x :: l).
Proof.
  intros. unfold CM.store_raw. apply Mem.mkmem_ext; cbn [Mem.mem_contents]; try reflexivity.
  rewrite PMap.gss, PMap.set2. reflexivity.
Qed.

Lemma store_byte0 : forall m b p m',
    Mem.store Mint8unsigned m b p (Vint Int.zero) = Some m' ->
    m' = CM.store_raw m b p [Byte Byte.zero].
Proof.
  intros m b p m' H. rewrite <- CM.store_eq in H. unfold CM.store in H.
  destruct (CM.valid_access_b _ _ _ _ _); [ | discriminate ]. injection H as <-. reflexivity.
Qed.

Lemma store_zeros_c : forall k n m b p m', Z.to_nat n = k ->
    store_zeros m b p n = Some m' -> m' = zeros_c m b p n.
Proof.
  induction k as [| k IH]; intros n m b p m' Hk H;
    rewrite store_zeros_equation in H; unfold zeros_c.
  - destruct (zle n 0) as [Hn | Hn]; [ | lia ].
    injection H as <-. replace (Z.leb n 0) with true by (symmetry; apply Z.leb_le; lia). reflexivity.
  - destruct (zle n 0) as [Hn | Hn]; [ lia | ].
    replace (Z.leb n 0) with false by (symmetry; apply Z.leb_gt; lia).
    destruct (Mem.store Mint8unsigned m b p Vzero) as [m1|] eqn:S; [ | discriminate ].
    apply store_byte0 in S. subst m1.
    rewrite (IH (n - 1) _ _ _ _ ltac:(lia) H). unfold zeros_c.
    replace (Z.to_nat n) with (S (Z.to_nat (n - 1))) by lia. cbn [List.repeat].
    destruct (Z.leb (n - 1) 0) eqn:E.
    + apply Z.leb_le in E. replace (Z.to_nat (n - 1)) with 0%nat by lia. reflexivity.
    + apply store_raw_cons.
Qed.

(* ---- drop_perm, deciding permissions computably ---- *)
Definition drop_acc (m : mem) (b : block) (lo hi : Z) (p : permission) :=
  PMap.set b (fun ofs k => if zle lo ofs && zlt ofs hi then Some p else (Mem.mem_access m) !! b ofs k)
    (Mem.mem_access m).

Lemma drop_max : forall m b lo hi p b' ofs,
    Mem.perm_order'' ((drop_acc m b lo hi p) !! b' ofs Max) ((drop_acc m b lo hi p) !! b' ofs Cur).
Proof.
  intros. unfold drop_acc. repeat rewrite PMap.gsspec. destruct (peq b' b).
  - subst b'. destruct (zle lo ofs && zlt ofs hi); [ cbn; constructor | apply Mem.access_max ].
  - apply Mem.access_max.
Qed.

Lemma drop_noacc : forall m b lo hi p,
    CM.range_perm_b m b lo hi Cur Freeable = true ->
    forall b' ofs k, ~ Plt b' (Mem.nextblock m) -> (drop_acc m b lo hi p) !! b' ofs k = None.
Proof.
  intros m b lo hi p R b' ofs k Hb'. apply CM.range_perm_b_spec in R.
  pose proof (Mem.nextblock_noaccess m b' ofs k Hb') as NA.
  unfold drop_acc. rewrite PMap.gsspec. destruct (peq b' b); [ | exact NA ].
  subst b'. destruct (zle lo ofs); destruct (zlt ofs hi); cbn; try exact NA.
  exfalso. assert (P : Mem.perm m b ofs k Freeable)
    by (apply Mem.perm_cur; apply R; lia).
  unfold Mem.perm in P. rewrite NA in P. exact P.
Qed.

Definition drop_c_dep (m : mem) (b : block) (lo hi : Z) (p : permission) (x : bool)
    : CM.range_perm_b m b lo hi Cur Freeable = x -> option mem :=
  if x as y return (CM.range_perm_b m b lo hi Cur Freeable = y -> option mem)
  then fun E => Some (Mem.mkmem (Mem.mem_contents m) (drop_acc m b lo hi p) (Mem.nextblock m)
                        (drop_max m b lo hi p) (drop_noacc m b lo hi p E) (Mem.contents_default m))
  else fun _ => None.

Definition drop_c (m : mem) (b : block) (lo hi : Z) (p : permission) : option mem :=
  drop_c_dep m b lo hi p (CM.range_perm_b m b lo hi Cur Freeable) eq_refl.

Lemma drop_c_dep_eq : forall m b lo hi p x E, drop_c_dep m b lo hi p x E = Mem.drop_perm m b lo hi p.
Proof.
  intros m b lo hi p [|] E; cbn; unfold Mem.drop_perm.
  - pose proof E as R. apply CM.range_perm_b_spec in R.
    destruct (Mem.range_perm_dec m b lo hi Cur Freeable); [ | contradiction ].
    f_equal. apply Mem.mkmem_ext; reflexivity.
  - destruct (Mem.range_perm_dec m b lo hi Cur Freeable) as [V|]; [ | reflexivity ].
    pose proof (proj2 (CM.range_perm_b_spec _ _ _ _ _ _) V) as V2. congruence.
Qed.

Lemma drop_c_eq : forall m b lo hi p, drop_c m b lo hi p = Mem.drop_perm m b lo hi p.
Proof. intros. apply drop_c_dep_eq. Qed.

Section C.
Context {F V : Type}.
Variable ge : Genv.t F V.

Definition init_one_c (m : mem) (b : block) (p : Z) (i : init_data) : option mem :=
  match i with
  | Init_int8 n => CM.store Mint8unsigned m b p (Vint n)
  | Init_int16 n => CM.store Mint16unsigned m b p (Vint n)
  | Init_int32 n => CM.store Mint32 m b p (Vint n)
  | Init_int64 n => CM.store Mint64 m b p (Vlong n)
  | Init_float32 n => CM.store Mfloat32 m b p (Vsingle n)
  | Init_float64 n => CM.store Mfloat64 m b p (Vfloat n)
  | Init_addrof symb ofs =>
      match Genv.find_symbol ge symb with
      | Some b' => CM.store Mptr m b p (Vptr b' ofs)
      | None => None
      end
  | Init_space _ => Some m
  end.

Lemma init_one_c_eq : forall m b p i, init_one_c m b p i = Genv.store_init_data ge m b p i.
Proof.
  intros m b p i. destruct i; cbn; try apply CM.store_eq; try reflexivity.
  destruct (Genv.find_symbol ge i); [ apply CM.store_eq | reflexivity ].
Qed.

Fixpoint init_list_c (m : mem) (b : block) (p : Z) (l : list init_data) : option mem :=
  match l with
  | nil => Some m
  | i :: l' =>
      match init_one_c m b p i with
      | Some m' => init_list_c m' b (p + init_data_size i) l'
      | None => None
      end
  end.

Lemma init_list_c_eq : forall l m b p, init_list_c m b p l = Genv.store_init_data_list ge m b p l.
Proof.
  induction l as [| i l IH]; intros m b p; cbn; [ reflexivity | ].
  rewrite init_one_c_eq. destruct (Genv.store_init_data ge m b p i); [ apply IH | reflexivity ].
Qed.

Definition alloc_global_c (m : mem) (idg : ident * globdef F V) : option mem :=
  match idg with
  | (_, Gfun _) =>
      let (m1, b) := Mem.alloc m 0 1 in drop_c m1 b 0 1 Nonempty
  | (_, Gvar v) =>
      let sz := init_data_list_size (gvar_init v) in
      let (m1, b) := Mem.alloc m 0 sz in
      match init_list_c (zeros_c m1 b 0 sz) b 0 (gvar_init v) with
      | Some m3 => drop_c m3 b 0 sz (Genv.perm_globvar v)
      | None => None
      end
  end.

Fixpoint alloc_globals_c (m : mem) (gl : list (ident * globdef F V)) : option mem :=
  match gl with
  | nil => Some m
  | g :: gl' =>
      match alloc_global_c m g with
      | Some m' => alloc_globals_c m' gl'
      | None => None
      end
  end.

Lemma alloc_global_c_ok : forall m g m', Genv.alloc_global ge m g = Some m' ->
    alloc_global_c m g = Some m'.
Proof.
  intros m [id [f | v]] m' H; cbn in H |- *.
  - destruct (Mem.alloc m 0 1) as [m1 b]. rewrite drop_c_eq. exact H.
  - destruct (Mem.alloc m 0 (init_data_list_size (gvar_init v))) as [m1 b].
    destruct (store_zeros m1 b 0 (init_data_list_size (gvar_init v))) as [m2|] eqn:Z;
      [ | discriminate ].
    rewrite <- (store_zeros_c _ _ _ _ _ _ eq_refl Z).
    rewrite init_list_c_eq.
    destruct (Genv.store_init_data_list ge m2 b 0 (gvar_init v)); [ | discriminate ].
    rewrite drop_c_eq. exact H.
Qed.

Lemma alloc_globals_c_ok : forall gl m m', Genv.alloc_globals ge m gl = Some m' ->
    alloc_globals_c m gl = Some m'.
Proof.
  induction gl as [| g gl IH]; intros m m' H; cbn in H |- *; [ exact H | ].
  destruct (Genv.alloc_global ge m g) as [m1|] eqn:A; [ | discriminate ].
  rewrite (alloc_global_c_ok _ _ _ A). exact (IH _ _ H).
Qed.

End C.

Theorem init_mem_c : forall {F V} (p : AST.program F V) m, Genv.init_mem p = Some m ->
    alloc_globals_c (Genv.globalenv p) Mem.empty (prog_defs p) = Some m.
Proof. intros F V p m H. exact (alloc_globals_c_ok _ _ _ _ H). Qed.
