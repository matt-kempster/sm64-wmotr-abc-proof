(* ====================================================================== *)
(* FpuValue.v -- the value clause of the FPU floor under sqrtf (TRUST 3.5) *)
(*                                                                        *)
(* FpuFloor.sqrtf_spec says a sqrtf call leaves memory alone; it makes no *)
(* claim about the result and does not say any behavior exists.  This     *)
(* file adds the value clause (user-approved hardware floor, 2026-10-22): *)
(*                                                                        *)
(*   sqrtf_value: on the decomp's own signature float(float), for an      *)
(*   argument x that is +-0 or a positive normal binary32 (sqrt_in), a    *)
(*   call returning Float32.sqrt x with memory unchanged IS a behavior.   *)
(*                                                                        *)
(* Tether.  The decomp's sqrtf is lib/asm/sqrtf.s:                        *)
(*     glabel sqrtf / jr $ra / sqrt.s $f0, $f12                            *)
(* (declared float sqrtf(float) in include/libc/math.h).  The VR4300's    *)
(* sqrt.s is the IEEE-754 single-precision square root, rounded per FCSR; *)
(* libultra's osInitialize (lib/src/osInitialize.c:80) sets FCSR to       *)
(* FPCSR_FS | FPCSR_EV: round-to-nearest-even, flush denormal RESULTS,    *)
(* trap on invalid operation.  Hence the domain sqrt_in: a negative       *)
(* nonzero x or a NaN is an invalid operation (a trap, not a return), a   *)
(* denormal input is an unimplemented operation on the R4300 FPU; on      *)
(* +-0 and positive normals no exception is raised, and the root of a     *)
(* normal is normal, so the flush never applies.  Infinity is left out    *)
(* (no claim needed).                                                      *)
(*                                                                        *)
(* Why the signature is in the clause: CompCert's own axiom               *)
(* external_functions_properties makes every behavior of                  *)
(* external_functions_sem "sqrtf" sg well typed for sg's return type, so  *)
(* a clause quantified over every sg is FALSE (sqrtf_any_sig_false below: *)
(* at an int-returning signature no Vsingle result exists).  The old      *)
(* antecedent TerrainRun.sqrtf_ieee was that refutable clause.            *)
(* ====================================================================== *)

From Coq Require Import String List ZArith.
From Flocq Require Import Binary.
From compcert Require Import Coqlib AST Integers Floats Values Memory Globalenvs Events.
Import ListNotations.

(* the signature every linked TU gives the sqrtf external (clightgen of
   math.h's float sqrtf(float)) *)
Definition sqrtf_sig : signature := mksignature (Xsingle :: nil) Xsingle cc_default.

(* +-0 or a positive normal binary32 (mantissa with all 24 digits) *)
Definition sqrt_in (x : float32) : bool :=
  match x with
  | B754_zero _ _ _ => true
  | B754_finite _ _ s m _ _ => negb s && Z.leb (2 ^ 23) (Zpos m)
  | _ => false
  end.

(* THE VALUE CLAUSE (TRUST 3.5, hardware floor). *)
Definition sqrtf_value : Prop :=
  forall (ge : Senv.t) x m, sqrt_in x = true ->
    external_functions_sem "sqrtf" sqrtf_sig ge [Vsingle x] m E0 (Vsingle (Float32.sqrt x)) m.

(* FOUND FALSE (2026-10-22): the any-signature form, which TerrainRun /
   StartSat carried as the antecedent sqrtf_ieee (and which BootRun's and
   TerrainRun's world_ok implied), contradicts CompCert's
   external_functions_properties: at an int-returning signature a Vsingle
   result is ill typed.  So every statement conditional on it was vacuous. *)
Lemma sqrtf_any_sig_false :
  ~ (forall sg (ge : Senv.t) x m, exists m',
        external_functions_sem "sqrtf" sg ge [Vsingle x] m E0 (Vsingle (Float32.sqrt x)) m').
Proof.
  intros H.
  destruct (H (mksignature (Xsingle :: nil) Xint cc_default)
              (Genv.to_senv (Genv.empty_genv unit unit nil)) Float32.zero Mem.empty) as (m' & E).
  pose proof (ec_well_typed (external_functions_properties "sqrtf"
                (mksignature (Xsingle :: nil) Xint cc_default)) _ _ _ _ _ _ E) as T.
  exact T.
Qed.
