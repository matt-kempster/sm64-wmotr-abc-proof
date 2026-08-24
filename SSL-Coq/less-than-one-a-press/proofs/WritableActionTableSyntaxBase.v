(** Shared definitions for the per-translation-unit writable-action-table
    syntax receipts.  Keeping these definitions separate lets Coq cache each
    expensive source traversal in its own [.vo] file. *)

From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Coqlib Ctypes Linking.
From LessThanOneAPress.Generated Require Import us_interaction jp_interaction.
From LessThanOneAPress.Proofs Require Import
  WritableActionTableAliasExternalClosure.

Import ListNotations.

Module WATSC_US := us_interaction.
Module WATSC_JP := jp_interaction.

Definition watsc_us_table_ids : list ident :=
  [WATSC_US._sInteractionHandlers;
   WATSC_US._sForwardKnockbackActions;
   WATSC_US._sBackwardKnockbackActions].

Definition watsc_jp_table_ids : list ident :=
  [WATSC_JP._sInteractionHandlers;
   WATSC_JP._sForwardKnockbackActions;
   WATSC_JP._sBackwardKnockbackActions].

Fixpoint watsc_nlist_all {A : Type}
    (predicate : A -> bool) (values : nlist A) : bool :=
  match values with
  | nbase value => predicate value
  | ncons value rest => predicate value && watsc_nlist_all predicate rest
  end.

Definition watsc_definition_access_safe
    (targets : list ident)
    (entry : ident * globdef Clight.fundef type) : bool :=
  match snd entry with
  | Gfun (Internal body) =>
      forallb
        (fun target =>
          wat_statement_access_safe_s target (fn_body body))
        targets
  | _ => true
  end.

Definition watsc_program_access_safe
    (targets : list ident) (program : Clight.program) : bool :=
  forallb (watsc_definition_access_safe targets) (prog_defs program).

Definition watsc_source_units_access_safe
    (targets : list ident) (units : nlist Clight.program) : bool :=
  watsc_nlist_all (watsc_program_access_safe targets) units.

Ltac watsc_compute_pair :=
  vm_compute; split; reflexivity.
