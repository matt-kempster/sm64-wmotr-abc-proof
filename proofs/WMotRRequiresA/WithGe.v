(* ====================================================================== *)
(* WithGe (GOAL 2): branch on an optional genv without writing            *)
(* `match ge12 with ...` in a definition.                                 *)
(*                                                                        *)
(* Elaborating a definition whose body matches on the constant ge12 costs *)
(* about 50 s (measured 2026-10-20: the match over a variable g takes     *)
(* 0.03 s), apparently because elaboration reduces the scrutinee, the    *)
(* whole linked program.  with_ge takes the option as an argument, so the *)
(* walk definitions apply it to ge12 instead of matching on it; unfolding *)
(* with_ge gives back exactly the old term.                               *)
(* ====================================================================== *)

From compcert Require Import Clight.

Definition with_ge {A : Type} (o : option genv) (d : A) (k : genv -> A) : A :=
  match o with Some g => k g | None => d end.
