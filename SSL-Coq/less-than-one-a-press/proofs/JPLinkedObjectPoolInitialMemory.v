(** Concrete initial-memory closure for the official cleaned JP object pool.

    This module resolves the exact retained [gObjectPool] variable in the
    official link and applies CompCert's initial-memory characterization to
    its 145920-byte writable initializer.  The resulting theorem supplies
    only the static initial permission range requested by
    [JPLinkedObjectPoolInitialMemoryObligation].  It does not establish a live
    allocation epoch, free-list chronology, payload contents, reachability, or
    any destination-area execution. *)

From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Globalenvs Memory.
From LessThanOneAPress.Generated Require Import jp_object_list_processor.
From LessThanOneAPress.Proofs Require Import
  JPDestinationChronologyCertificate JPOfficialInitialMemory
  JPObjectPoolCleanedUnitReceipt LinkedGlobalInitialMemory.

Import ListNotations.
Local Open Scope Z_scope.

Theorem jp_linked_object_pool_initial_memory_obligation_closed :
  JPLinkedObjectPoolInitialMemoryObligation.
Proof.
  unfold JPLinkedObjectPoolInitialMemoryObligation.
  destruct jp_official_cleaned_initial_memory_exists as
    [initial_memory Hinitial_memory].
  destruct jp_official_gObjectPool_exact_variable_lookup as
    [pool_block [Hpool_symbol Hpool_variable]].
  exists initial_memory, pool_block,
    jp_object_list_processor.v_gObjectPool.
  split; [exact Hinitial_memory |].
  split; [exact Hpool_symbol |].
  split; [exact Hpool_variable |].
  split; [reflexivity |].
  eapply initialized_writable_space_has_range_permission.
  - exact Hinitial_memory.
  - exact Hpool_variable.
  - reflexivity.
  - reflexivity.
  - reflexivity.
  - lia.
  - lia.
  - lia.
Qed.
