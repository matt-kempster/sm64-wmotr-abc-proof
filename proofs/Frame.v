(* Frame.v -- the generic, reusable syntactic frame analysis.
 *
 * Intra-procedural, syntactic: "does this Clight function contain a direct
 * assignment whose l-value is rooted at global g?" It walks the generated AST
 * and is meant to be discharged by `reflexivity` on any concrete function.
 *
 * This file imports NO generated module -- it is pure analysis over the CompCert
 * Clight AST, so it applies unchanged to toy.c, shadow.c, or any other TU. The
 * per-TU control examples live in ToyFrame.v / ShadowFrame.v.
 *
 * This is the toy-scale shape of the docs' `writesOf` idea. It is deliberately
 * NOT a semantic theorem -- "syntactic non-write => semantic preservation" is
 * Milestone 2 (see ToyReach.v).
 *
 * Conservativeness (intentional, documented):
 *   - Only Sassign l-values are considered. Writes a callee performs (Scall/
 *     Sbuiltin) are not chased -- that is interprocedural and out of scope here.
 *   - lvalue_global follows Evar/Ederef/Efield to a base Evar. A store through a
 *     global ARRAY (e.g. gObjects[i] = ...), whose l-value root is an Ebinop,
 *     returns None. That under-approximates "writes a global"; M2+ will sharpen.
 *)

From Coq Require Import Bool.
From Coq Require Import PArith.BinPos.
From compcert Require Import AST Ctypes Clight.

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
