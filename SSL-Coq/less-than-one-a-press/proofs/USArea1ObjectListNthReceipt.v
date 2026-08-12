(** Fixed-position source receipts for the remaining selected-US object-list
    globals needed by the ordinary Area-1 entry address bundle. *)

From Coq Require Import List.
From compcert Require Import AST Clight Ctypes.
From LessThanOneAPress.Generated Require Import us_object_list_processor.

Theorem us_object_list_processor_gObjectLists_nth_error_checked :
  nth_error us_object_list_processor.global_definitions 151%nat =
    Some (us_object_list_processor._gObjectLists,
      Gvar us_object_list_processor.v_gObjectLists).
Proof. vm_compute. reflexivity. Qed.

Theorem us_object_list_processor_gFreeObjectList_nth_error_checked :
  nth_error us_object_list_processor.global_definitions 152%nat =
    Some (us_object_list_processor._gFreeObjectList,
      Gvar us_object_list_processor.v_gFreeObjectList).
Proof. vm_compute. reflexivity. Qed.

Theorem us_object_list_processor_gObjectListArray_nth_error_checked :
  nth_error us_object_list_processor.global_definitions 179%nat =
    Some (us_object_list_processor._gObjectListArray,
      Gvar us_object_list_processor.v_gObjectListArray).
Proof. vm_compute. reflexivity. Qed.

Corollary us_object_list_processor_gObjectLists_prog_defs_member :
  In (us_object_list_processor._gObjectLists,
      Gvar us_object_list_processor.v_gObjectLists)
    (prog_defs us_object_list_processor.prog).
Proof. eapply nth_error_In; exact us_object_list_processor_gObjectLists_nth_error_checked. Qed.

Corollary us_object_list_processor_gFreeObjectList_prog_defs_member :
  In (us_object_list_processor._gFreeObjectList,
      Gvar us_object_list_processor.v_gFreeObjectList)
    (prog_defs us_object_list_processor.prog).
Proof. eapply nth_error_In; exact us_object_list_processor_gFreeObjectList_nth_error_checked. Qed.

Corollary us_object_list_processor_gObjectListArray_prog_defs_member :
  In (us_object_list_processor._gObjectListArray,
      Gvar us_object_list_processor.v_gObjectListArray)
    (prog_defs us_object_list_processor.prog).
Proof. eapply nth_error_In; exact us_object_list_processor_gObjectListArray_nth_error_checked. Qed.
