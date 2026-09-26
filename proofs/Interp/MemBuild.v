(* kept: general tool -- build CONCRETE memories for interpreter runs over a
   (possibly linked) Clight program: every global allocated in genv order and
   zero-filled then initialised, fresh heap objects, and name-addressed field
   writes.  Everything here is computable (vm_compute), and nothing here is
   trusted: a built memory is just a witness input, checked by the run. *)

From Coq Require Import String List ZArith.
From compcert Require Import Coqlib Errors Maps Integers Values AST Memory
  Globalenvs Ctypes Clight.
From compcert Require Ctypesdefs.
From SM64.Proofs Require Interp.CMem.
Module CM := SM64.Proofs.Interp.CMem.
Import ListNotations.

Definition id (s : string) : ident := Ctypesdefs.ident_of_string s.
Definition name (i : ident) : string := Ctypesdefs.string_of_ident i.

(* Zero-fill by one storebytes (Globalenvs.store_zeros is well-founded
   recursion, which vm_compute cannot unfold). *)
Definition zero_fill (m : mem) (b : block) (sz : Z) : option mem :=
  CM.storebytes m b 0 (List.repeat (Byte Byte.zero) (Z.to_nat sz)).

Section BUILD.

Variable ge : genv.

(* Size overrides for globals whose type is incomplete here (e.g. an
   `extern float gSineTable[];` defined in a TU outside the link). *)
Variable size_of_extern : ident -> option Z.

(* Genv.store_init_data over CMem (computable). *)
Definition init_one (m : mem) (b : block) (p : Z) (i : init_data) : option mem :=
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

Fixpoint init_list (m : mem) (b : block) (p : Z) (l : list init_data) : option mem :=
  match l with
  | nil => Some m
  | i :: l' =>
      match init_one m b p i with
      | Some m' => init_list m' b (p + init_data_size i) l'
      | None => None
      end
  end.

(* The global's footprint: its initializer, or its C type if larger (so an
   `extern` declaration with no initializer still gets a usable block). *)
Definition glob_size (i : ident) (g : globdef (Ctypes.fundef function) type) : Z :=
  match g with
  | Gfun _ => 1
  | Gvar v =>
      let sz := Z.max (init_data_list_size (gvar_init v)) (sizeof ge (gvar_info v)) in
      match size_of_extern i with Some z => Z.max sz z | None => sz end
  end.

(* Allocates block k for the k-th def, exactly as Genv.globalenv numbers
   symbols, so [Genv.find_symbol ge] addresses these blocks. *)
Fixpoint alloc_globs (m : mem) (defs : list (ident * globdef (Ctypes.fundef function) type))
    : option mem :=
  match defs with
  | nil => Some m
  | (i, g) :: defs' =>
      let sz := glob_size i g in
      let (m1, b) := Mem.alloc m 0 sz in
      match g with
      | Gfun _ => alloc_globs m1 defs'
      | Gvar v =>
          match zero_fill m1 b sz with
          | Some m2 =>
              match init_list m2 b 0 (gvar_init v) with
              | Some m3 => alloc_globs m3 defs'
              | None => None
              end
          | None => None
          end
      end
  end.

Definition sym (s : string) : option block := Genv.find_symbol ge (id s).

(* Byte offset of [fld] in struct [sname]. *)
Definition off (sname fld : string) : option Z :=
  match (genv_cenv ge) ! (id sname) with
  | Some co =>
      match field_offset ge (id fld) (co_members co) with
      | OK (d, Full) => Some d
      | _ => None
      end
  | None => None
  end.

Definition ssize (sname : string) : Z :=
  match (genv_cenv ge) ! (id sname) with Some co => co_sizeof co | None => 0 end.

(* A fresh zero-filled heap object of [sz] bytes. *)
Definition fresh (m : mem) (sz : Z) : option (mem * block) :=
  let (m1, b) := Mem.alloc m 0 sz in
  match zero_fill m1 b sz with
  | Some m2 => Some (m2, b)
  | None => None
  end.

(* A write: chunk, block, byte offset, value. *)
Record wr := W { w_chunk : memory_chunk; w_blk : block; w_ofs : Z; w_val : val }.

(* Applies the writes in order; on failure returns the index of the bad one. *)
Fixpoint apply_writes (m : mem) (ws : list wr) (k : nat) : mem + nat :=
  match ws with
  | nil => inl m
  | w :: ws' =>
      match CM.store (w_chunk w) m (w_blk w) (w_ofs w) (w_val w) with
      | Some m' => apply_writes m' ws' (S k)
      | None => inr k
      end
  end.

End BUILD.
