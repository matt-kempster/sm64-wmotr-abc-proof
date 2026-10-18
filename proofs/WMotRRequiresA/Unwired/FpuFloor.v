(* ====================================================================== *)
(* FpuFloor.v -- the hardware floor under sqrtf                          *)
(*                                                                        *)
(* sqrtf has no C body in the decomp: on the N64 it is the VR4300 FPU's   *)
(* sqrt.s instruction (the compiler's builtin).  CompCert sees an         *)
(* external declaration whose semantics (external_functions_sem) has no  *)
(* content of its own, so "a call leaves memory alone" is where proving   *)
(* stops and a spec of the hardware starts (TRUST 3.5).                   *)
(*                                                                        *)
(* The spec says only that an instruction which reads and writes FPU     *)
(* registers does not touch memory.  It says nothing about the result     *)
(* value (no IEEE claim).                                                 *)
(* ====================================================================== *)

From Coq Require Import String.
From compcert Require Import Coqlib AST Values Memory Events.

Definition sqrtf_spec : Prop :=
  forall sg ge vargs m t vres m',
    external_functions_sem "sqrtf" sg ge vargs m t vres m' -> m' = m.
