(* kept: general tool -- a vm_compute-able Genv.init_mem, PROVED EQUAL to
   CompCert's.  Genv.init_mem uses store_zeros (well-founded recursion over
   an opaque accessibility proof), Mem.store and Mem.drop_perm (both decide
   range_perm by the same kind of recursion), so vm_compute gets stuck on it.
   Here every step is the same operation, with the permission check made
   structural (CMem.range_perm_b): init_mem_c p = Genv.init_mem p.  With it,
   an interpreter run can start from the REAL boot image of a link rather
   than from a memory built to look like one (MemBuild.alloc_globs). *)

From Coq Require Import ZArith List.
From compcert Require Import Coqlib Maps Integers Values AST Memdata Memory Globalenvs.
From SM64.Proofs Require Interp.CMem.
Module CM := SM64.Proofs.Interp.CMem.

Local Transparent Mem.drop_perm.

(* ---- drop_perm ---- *)

Definition range_perm_dec_c (m : mem) (b : block) (lo hi : Z) (k : perm_kind)
    (p : permission) : {Mem.range_perm m b lo hi k p} + {~ Mem.range_perm m b lo hi k p} :=
  match CM.range_perm_b m b lo hi k p as r
        return CM.range_perm_b m b lo hi k p = r ->
               {Mem.range_perm m b lo hi k p} + {~ Mem.range_perm m b lo hi k p} with
  | true => fun E => left (proj1 (CM.range_perm_b_spec m b lo hi k p) E)
  | false => fun E => right (fun H =>
      diff_false_true (eq_trans (eq_sym E) (proj2 (CM.range_perm_b_spec m b lo hi k p) H)))
  end eq_refl.

Definition drop_perm (m : mem) (b : block) (lo hi : Z) (p : permission) : option mem :=
  match range_perm_dec_c m b lo hi Cur Freeable with
  | left R =>
      Some (Mem.mkmem (Mem.mem_contents m)
              (PMap.set b (fun ofs k => if zle lo ofs && zlt ofs hi then Some p
                                        else (Mem.mem_access m) !! b ofs k)
                 (Mem.mem_access m))
              (Mem.nextblock m)
              (Memory.Mem.drop_perm_obligation_1 m b lo hi p)
              (Memory.Mem.drop_perm_obligation_2 m b lo hi p R)
              (Memory.Mem.drop_perm_obligation_3 m))
  | right _ => None
  end.

Lemma drop_perm_eq : forall m b lo hi p, drop_perm m b lo hi p = Mem.drop_perm m b lo hi p.
Proof.
  intros. unfold drop_perm, Mem.drop_perm.
  destruct (range_perm_dec_c m b lo hi Cur Freeable) as [R|R];
    destruct (Mem.range_perm_dec m b lo hi Cur Freeable) as [R'|R']; try tauto.
  f_equal. apply Mem.mkmem_ext; reflexivity.
Qed.

(* ---- store_zeros, by structural recursion on the byte count ---- *)

Fixpoint zeros_n (m : mem) (b : block) (p : Z) (n : nat) : option mem :=
  match n with
  | O => Some m
  | S n' =>
      match CM.store Mint8unsigned m b p Vzero with
      | Some m' => zeros_n m' b (p + 1) n'
      | None => None
      end
  end.

Definition store_zeros (m : mem) (b : block) (p n : Z) : option mem :=
  zeros_n m b p (Z.to_nat n).

Lemma zeros_n_eq : forall k m b p n, Z.to_nat n = k ->
    zeros_n m b p k = Globalenvs.store_zeros m b p n.
Proof.
  induction k as [|k IH]; intros m b p n Hk;
    rewrite Globalenvs.store_zeros_equation.
  - destruct (zle n 0) as [_|H]; [ reflexivity | lia ].
  - destruct (zle n 0) as [H|_]; [ lia | ]. cbn [zeros_n]. rewrite CM.store_eq.
    destruct (Mem.store Mint8unsigned m b p Vzero) as [m'|]; [ | reflexivity].
    apply IH. lia.
Qed.

Lemma store_zeros_eq : forall m b p n, store_zeros m b p n = Globalenvs.store_zeros m b p n.
Proof. intros. apply zeros_n_eq. reflexivity. Qed.

(* ---- the initial memory ---- *)

Section INIT.
Context {F V : Type}.
Variable ge : Genv.t F V.

Definition store_init_data (m : mem) (b : block) (p : Z) (i : init_data) : option mem :=
  match i with
  | Init_int8 n => CM.store Mint8unsigned m b p (Vint n)
  | Init_int16 n => CM.store Mint16unsigned m b p (Vint n)
  | Init_int32 n => CM.store Mint32 m b p (Vint n)
  | Init_int64 n => CM.store Mint64 m b p (Vlong n)
  | Init_float32 n => CM.store Mfloat32 m b p (Vsingle n)
  | Init_float64 n => CM.store Mfloat64 m b p (Vfloat n)
  | Init_addrof symb ofs =>
      match Genv.find_symbol ge symb with
      | None => None
      | Some b' => CM.store Mptr m b p (Vptr b' ofs)
      end
  | Init_space _ => Some m
  end.

Lemma store_init_data_eq : forall m b p i,
    store_init_data m b p i = Genv.store_init_data ge m b p i.
Proof.
  intros. destruct i; cbn; rewrite ?CM.store_eq; try reflexivity.
  destruct (Genv.find_symbol ge i); [ apply CM.store_eq | reflexivity ].
Qed.

Fixpoint store_init_data_list (m : mem) (b : block) (p : Z) (l : list init_data)
    : option mem :=
  match l with
  | nil => Some m
  | i :: l' =>
      match store_init_data m b p i with
      | None => None
      | Some m' => store_init_data_list m' b (p + init_data_size i) l'
      end
  end.

Lemma store_init_data_list_eq : forall l m b p,
    store_init_data_list m b p l = Genv.store_init_data_list ge m b p l.
Proof.
  induction l as [|i l IH]; intros; cbn; [ reflexivity | ].
  rewrite store_init_data_eq. destruct (Genv.store_init_data ge m b p i); auto.
Qed.

Definition alloc_global (m : mem) (idg : ident * globdef F V) : option mem :=
  match idg with
  | (_, Gfun _) =>
      let (m1, b) := Mem.alloc m 0 1 in
      drop_perm m1 b 0 1 Nonempty
  | (_, Gvar v) =>
      let init := gvar_init v in
      let sz := init_data_list_size init in
      let (m1, b) := Mem.alloc m 0 sz in
      match store_zeros m1 b 0 sz with
      | None => None
      | Some m2 =>
          match store_init_data_list m2 b 0 init with
          | None => None
          | Some m3 => drop_perm m3 b 0 sz (Genv.perm_globvar v)
          end
      end
  end.

Lemma alloc_global_eq : forall m g, alloc_global m g = Genv.alloc_global ge m g.
Proof.
  intros m [i [f|v]]; cbn.
  - destruct (Mem.alloc m 0 1). apply drop_perm_eq.
  - destruct (Mem.alloc m 0 (init_data_list_size (gvar_init v))) as [m1 b].
    rewrite store_zeros_eq.
    destruct (Globalenvs.store_zeros m1 b 0 _); [ | reflexivity].
    rewrite store_init_data_list_eq.
    destruct (Genv.store_init_data_list ge _ b 0 _); [ apply drop_perm_eq | reflexivity].
Qed.

Fixpoint alloc_globals (m : mem) (l : list (ident * globdef F V)) : option mem :=
  match l with
  | nil => Some m
  | g :: l' =>
      match alloc_global m g with
      | None => None
      | Some m' => alloc_globals m' l'
      end
  end.

Lemma alloc_globals_eq : forall l m, alloc_globals m l = Genv.alloc_globals ge m l.
Proof.
  induction l as [|g l IH]; intros; cbn; [ reflexivity | ].
  rewrite alloc_global_eq. destruct (Genv.alloc_global ge m g); auto.
Qed.

End INIT.

Definition init_mem_c {F V : Type} (p : AST.program F V) : option mem :=
  alloc_globals (Genv.globalenv p) Mem.empty (prog_defs p).

Theorem init_mem_c_eq : forall {F V : Type} (p : AST.program F V),
    init_mem_c p = Genv.init_mem p.
Proof. intros. apply alloc_globals_eq. Qed.
