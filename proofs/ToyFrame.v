(* ToyFrame.v -- Milestone 0.
 *
 * A *generic*, intra-procedural, syntactic analysis over a CompCert Clight function:
 * "does this function contain a direct assignment whose l-value is rooted at global g?"
 *
 * This is the toy-scale shape of the docs' `writesOf` idea: a fact computed by walking
 * the generated AST and machine-checked with `reflexivity`. It is deliberately NOT a
 * semantic theorem yet -- proving "syntactic non-write => semantic preservation" against
 * CompCert's Clight operational semantics is Milestone 2. Here we only validate the
 * generate -> load -> compute -> check spine.
 *
 * Conservativeness (intentional, documented):
 *   - Only Sassign l-values are considered. Writes a callee performs (Scall/Sbuiltin)
 *     are not chased -- that is interprocedural and out of scope for M0.
 *   - lvalue_global follows Evar/Ederef/Efield to a base Evar. A store through a global
 *     ARRAY (e.g. gObjects[i] = ...), whose l-value root is an Ebinop, returns None
 *     here. That under-approximates "writes a global" and is fine for the toy controls;
 *     M1/M2 will sharpen this.
 *)

From Coq Require Import Bool.
From Coq Require Import PArith.BinPos.
From compcert Require Import AST Ctypes Clight.
From SM64.Generated Require Import toy.

(* If an l-value is ultimately rooted at a global variable (Evar), return its ident. *)
Fixpoint lvalue_global (e : expr) : option ident :=
  match e with
  | Evar id _      => Some id
  | Ederef e' _    => lvalue_global e'
  | Efield e' _ _  => lvalue_global e'
  | _              => None
  end.

Fixpoint writes_global_s (s : statement) (g : ident) {struct s} : bool :=
  match s with
  | Sassign lhs _ =>
      match lvalue_global lhs with
      | Some id => Pos.eqb id g
      | None    => false
      end
  | Ssequence s1 s2   => writes_global_s s1 g || writes_global_s s2 g
  | Sifthenelse _ s1 s2 => writes_global_s s1 g || writes_global_s s2 g
  | Sloop s1 s2       => writes_global_s s1 g || writes_global_s s2 g
  | Slabel _ s1       => writes_global_s s1 g
  | Sswitch _ ls      => writes_global_ls ls g
  | _                 => false
  end
with writes_global_ls (ls : labeled_statements) (g : ident) {struct ls} : bool :=
  match ls with
  | LSnil           => false
  | LScons _ s rest => writes_global_s s g || writes_global_ls rest g
  end.

(* The function-level fact: does f directly assign to global g? *)
Definition writes_global (f : Clight.function) (g : ident) : bool :=
  writes_global_s (fn_body f) g.

(* --- The two machine-checked controls over the generated Clight of toy.c --- *)

(* Positive control: clobber() really does store into gUnrelated. *)
Example clobber_writes_gUnrelated :
  writes_global f_clobber _gUnrelated = true.
Proof. reflexivity. Qed.

(* Negative control: set_timer() never assigns to gUnrelated. *)
Example set_timer_does_not_write_gUnrelated :
  writes_global f_set_timer _gUnrelated = false.
Proof. reflexivity. Qed.
