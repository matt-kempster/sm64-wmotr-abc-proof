(* Escape.v -- the syntactic "address-taken" analysis.
 *
 * Companion to Frame.v. Frame.writes_global answers "who DIRECTLY assigns g?".
 * This answers the question that makes the pointer-write leak tractable (see
 * docs/pointer-writes-and-block-disjointness.md): "is the ADDRESS of global g
 * ever produced as a first-class value -- i.e. could it escape into a pointer?"
 *
 * Why this is the key query: CompCert memory is block-based, so a store through
 * a pointer can only hit g's block if some pointer actually holds an address in
 * g's block. If &g is never produced anywhere, NO indirect write can reach g,
 * regardless of how many pointer writes the program contains. The cost scales
 * with how aliased g is, not with the number of writes.
 *
 * An address of g is produced in exactly two syntactic ways:
 *   (a) Eaddrof of an l-value rooted at Evar g            -- explicit &g, &g.f
 *   (b) Evar g whose type is NOT by-value (array/struct/  -- aggregate/array
 *       union/function): naming it decays to its address     "decay"
 * A by-value (scalar/pointer) global named bare is a load, not an escape; an
 * Sassign into a scalar global uses its address only transiently to store. So
 * those do NOT count. This is deliberately a CONSERVATIVE OVER-approximation:
 * it may flag escapes that don't really persist (e.g. a struct-typed Evar in a
 * store l-value), never the reverse. addr_taken f g = false is the strong
 * (safe) answer; = true means "look closer".
 *
 * This is still SYNTACTIC. The semantic payoff -- "addr_taken = false in the
 * whole reachable program  =>  any pointer store preserves g" -- is the havoc
 * frame lemma, proved against the operational semantics (next step, generalizes
 * ToyReach's store_to_fresh_preserves_existing from "fresh" to "non-escaped").
 *
 * Generic: imports Frame (for lvalue_global) and no generated module.
 *)

From Coq Require Import Bool List ZArith PArith.BinPos.
From compcert Require Import AST Integers Ctypes Clight.
From SM64.Proofs Require Import Frame.

(* Scalar/pointer types are accessed by value; naming them yields a value, not
   an address. Everything else (array/struct/union/function/void) we treat as
   potentially address-producing when named bare. *)
Definition by_value (ty : type) : bool :=
  match ty with
  | Tint _ _ _ | Tlong _ _ | Tfloat _ _ | Tpointer _ _ => true
  | _ => false
  end.

Fixpoint addr_escapes_e (e : expr) (g : ident) : bool :=
  match e with
  | Evar id ty       => Pos.eqb id g && negb (by_value ty)        (* (b) decay *)
  | Eaddrof e1 _ =>                                                (* (a) &... *)
      match lvalue_global e1 with
      | Some id => if Pos.eqb id g then true else addr_escapes_e e1 g
      | None    => addr_escapes_e e1 g
      end
  | Ederef e1 _      => addr_escapes_e e1 g
  | Efield e1 _ _    => addr_escapes_e e1 g
  | Eunop _ e1 _     => addr_escapes_e e1 g
  | Ecast e1 _       => addr_escapes_e e1 g
  | Ebinop _ e1 e2 _ => addr_escapes_e e1 g || addr_escapes_e e2 g
  | _                => false   (* consts, tempvar, sizeof, alignof *)
  end.

Fixpoint addr_escapes_s (s : statement) (g : ident) {struct s} : bool :=
  match s with
  | Sassign e1 e2       => addr_escapes_e e1 g || addr_escapes_e e2 g
  | Sset _ e            => addr_escapes_e e g
  | Scall _ ef args     => addr_escapes_e ef g || existsb (fun a => addr_escapes_e a g) args
  | Sbuiltin _ _ _ args => existsb (fun a => addr_escapes_e a g) args
  | Ssequence s1 s2     => addr_escapes_s s1 g || addr_escapes_s s2 g
  | Sifthenelse c s1 s2 => addr_escapes_e c g || addr_escapes_s s1 g || addr_escapes_s s2 g
  | Sloop s1 s2         => addr_escapes_s s1 g || addr_escapes_s s2 g
  | Sreturn (Some e)    => addr_escapes_e e g
  | Sswitch c ls        => addr_escapes_e c g || addr_escapes_ls ls g
  | Slabel _ s1         => addr_escapes_s s1 g
  | _                   => false
  end
with addr_escapes_ls (ls : labeled_statements) (g : ident) {struct ls} : bool :=
  match ls with
  | LSnil           => false
  | LScons _ s rest => addr_escapes_s s g || addr_escapes_ls rest g
  end.

(* Does f take the address of global g (conservatively)? *)
Definition addr_taken (f : Clight.function) (g : ident) : bool :=
  addr_escapes_s (fn_body f) g.

(* Addresses also escape through static initializers: `T *p = &g;` compiles to
   an Init_addrof in p's gvar_init. A whole-program "&g never produced" claim
   must scan these too, not just function bodies. *)
Definition init_escapes (i : init_data) (g : ident) : bool :=
  match i with
  | Init_addrof id _ => Pos.eqb id g
  | _                => false
  end.

Definition globdef_takes_addr (gd : globdef fundef type) (g : ident) : bool :=
  match gd with
  | Gfun (Internal f) => addr_taken f g
  | Gfun (External _ _ _ _) => false
  | Gvar v => existsb (fun i => init_escapes i g) (gvar_init v)
  end.

(* --- Positive controls: the detector actually fires (synthetic ASTs) ------- *)
(* These guard against the vacuous bug where addr_taken always returns false:
   no file-scope global of shadow.c has its address taken, so the real-code
   facts are all `false`; these pin the `true` cases on hand-built expressions. *)

(* Explicit &g. *)
Example addrof_fires :
  addr_escapes_e (Eaddrof (Evar 1%positive (Tint I32 Signed noattr))
                   (Tpointer (Tint I32 Signed noattr) noattr)) 1%positive = true.
Proof. reflexivity. Qed.

(* Bare array-typed global decays to its address. *)
Example array_decay_fires :
  addr_escapes_e (Evar 1%positive (Tarray (Tint I32 Signed noattr) 4%Z noattr)) 1%positive = true.
Proof. reflexivity. Qed.

(* A bare scalar global is a load, NOT an escape. *)
Example scalar_load_is_not_escape :
  addr_escapes_e (Evar 1%positive (Tint I32 Signed noattr)) 1%positive = false.
Proof. reflexivity. Qed.

(* Init_addrof in a global initializer counts. *)
Example init_addrof_fires :
  init_escapes (Init_addrof 1%positive Ptrofs.zero) 1%positive = true.
Proof. reflexivity. Qed.
