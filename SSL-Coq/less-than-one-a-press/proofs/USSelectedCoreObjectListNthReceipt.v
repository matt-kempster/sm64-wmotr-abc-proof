(** Fixed-position source receipts for the three selected US object-list
    globals.

    These checks traverse only the spine of [global_definitions].  In
    particular, they avoid constructing the translation unit's [prog_defmap]. *)

From Coq Require Import List.
From compcert Require Import AST Clight Ctypes.
From LessThanOneAPress.Generated Require Import us_object_list_processor.

Theorem us_object_list_processor_gMarioStates_nth_error_checked :
  nth_error us_object_list_processor.global_definitions 128%nat =
    Some (us_object_list_processor._gMarioStates,
      Gvar us_object_list_processor.v_gMarioStates).
Proof. vm_compute. reflexivity. Qed.

Theorem us_object_list_processor_gObjectPool_nth_error_checked :
  nth_error us_object_list_processor.global_definitions 149%nat =
    Some (us_object_list_processor._gObjectPool,
      Gvar us_object_list_processor.v_gObjectPool).
Proof. vm_compute. reflexivity. Qed.

Theorem us_object_list_processor_gMarioObject_nth_error_checked :
  nth_error us_object_list_processor.global_definitions 153%nat =
    Some (us_object_list_processor._gMarioObject,
      Gvar us_object_list_processor.v_gMarioObject).
Proof. vm_compute. reflexivity. Qed.

Corollary us_object_list_processor_gMarioStates_prog_defs_member :
  In (us_object_list_processor._gMarioStates,
      Gvar us_object_list_processor.v_gMarioStates)
    (prog_defs us_object_list_processor.prog).
Proof.
  eapply nth_error_In.
  exact us_object_list_processor_gMarioStates_nth_error_checked.
Qed.

Corollary us_object_list_processor_gObjectPool_prog_defs_member :
  In (us_object_list_processor._gObjectPool,
      Gvar us_object_list_processor.v_gObjectPool)
    (prog_defs us_object_list_processor.prog).
Proof.
  eapply nth_error_In.
  exact us_object_list_processor_gObjectPool_nth_error_checked.
Qed.

Corollary us_object_list_processor_gMarioObject_prog_defs_member :
  In (us_object_list_processor._gMarioObject,
      Gvar us_object_list_processor.v_gMarioObject)
    (prog_defs us_object_list_processor.prog).
Proof.
  eapply nth_error_In.
  exact us_object_list_processor_gMarioObject_nth_error_checked.
Qed.
