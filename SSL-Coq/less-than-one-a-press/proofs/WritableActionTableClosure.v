(** Writable action-table mutation audit.

    The initialized negative-depth closure left three writable source objects:
    [sInteractionHandlers], [sForwardKnockbackActions], and
    [sBackwardKnockbackActions].  This file combines already checked
    whole-corpus and dispatcher receipts to distinguish two questions:

    - can ordinary controller-driven source code mutate one of the tables?;
    - what would a hypothetical valid mutation buy?

    For US and JP, the handler table is mentioned only by
    [mario_process_interactions], and each knockback table only by
    [determine_knockback_action].  The whole-corpus censuses find no named
    assignment or explicit address escape.  The exact reader receipts show
    that the handler is loaded and called and that the knockback indices are
    restricted to 0, 1, or 2.  Thus controller state selects entries but no
    ordinary named source operation writes a table byte.

    This is deliberately not a universal pointer-provenance theorem.  A
    successful in-bounds mutation would now have to supply a concrete valid
    alias into one of the private global blocks or a reached outside effect
    with that footprint.  An OOB write, ACE, DMA, or a continuation after
    source undefined behavior is outside the Clight result.

    The payload calculation is nevertheless important.  Each knockback entry
    is one 32-bit action word, and replacing a selected word can encode any
    action, including [ACT_LONG_JUMP].  The stock Snufit/damage paths already
    pass the selected temporary to the action setter.  A handler record is two
    32-bit words; replacing the coin or pole handler word with a compatible
    stock handler can create an automatic action.  These are conditional
    capabilities, not table-write witnesses or Area-2 reachability proofs. *)

From Coq Require Import List Lia ZArith.
From compcert Require Import AST Clight Ctypes Integers.
From LessThanOneAPress.Generated Require Import us_interaction jp_interaction.
From LessThanOneAPress.Proofs Require Import
  NegativeDepthInteractionClosure.

Import ListNotations.
Local Open Scope Z_scope.

Module WAT_US := us_interaction.
Module WAT_JP := jp_interaction.

(** * The ordinary source mutation class is empty *)

Definition WritableActionTableSourceBoundary : Prop :=
  ndi_interaction_handler_initializer_claim /\
  ndi_knockback_table_named_source_claim /\
  ndi_knockback_helper_claim /\
  ndi_dynamic_action_source_claim /\
  gvar_readonly WAT_US.v_sInteractionHandlers = false /\
  gvar_readonly WAT_US.v_sForwardKnockbackActions = false /\
  gvar_readonly WAT_US.v_sBackwardKnockbackActions = false /\
  gvar_readonly WAT_JP.v_sInteractionHandlers = false /\
  gvar_readonly WAT_JP.v_sForwardKnockbackActions = false /\
  gvar_readonly WAT_JP.v_sBackwardKnockbackActions = false /\
  length (gvar_init WAT_US.v_sInteractionHandlers) = 62%nat /\
  length (gvar_init WAT_US.v_sForwardKnockbackActions) = 9%nat /\
  length (gvar_init WAT_US.v_sBackwardKnockbackActions) = 9%nat /\
  length (gvar_init WAT_JP.v_sInteractionHandlers) = 62%nat /\
  length (gvar_init WAT_JP.v_sForwardKnockbackActions) = 9%nat /\
  length (gvar_init WAT_JP.v_sBackwardKnockbackActions) = 9%nat /\
  (62 * 4 + 9 * 4 + 9 * 4 = 320)%nat.

Theorem writable_action_table_source_boundary_holds :
  WritableActionTableSourceBoundary.
Proof.
  unfold WritableActionTableSourceBoundary.
  split; [exact stock_interaction_handler_initializers_are_exact |].
  split; [exact knockback_action_tables_have_no_named_source_writer |].
  split; [exact stock_knockback_action_selection_is_exact |].
  split; [exact dynamic_action_arguments_have_one_internal_source |].
  vm_compute. repeat split; reflexivity.
Qed.

(** This is the strongest currently justified controller conclusion: the
    generated corpus has only the checked readers and no named writer or
    address handoff.  A separately established valid alias or outside call is
    intentionally not defined to be an ordinary controller source. *)
Definition OrdinaryControllerNamedTableMutationExcluded : Prop :=
  ndi_interaction_handler_initializer_claim /\
  ndi_knockback_table_named_source_claim.

Theorem ordinary_controller_has_no_named_table_mutation_producer :
  OrdinaryControllerNamedTableMutationExcluded.
Proof.
  unfold OrdinaryControllerNamedTableMutationExcluded.
  split; [exact stock_interaction_handler_initializers_are_exact |].
  exact knockback_action_tables_have_no_named_source_writer.
Qed.

(** * Conditional payload capacity *)

Fixpoint wat_replace_nth {A : Type}
    (index : nat) (replacement : A) (values : list A) : list A :=
  match index, values with
  | O, _ :: rest => replacement :: rest
  | S index', value :: rest =>
      value :: wat_replace_nth index' replacement rest
  | _, [] => []
  end.

Definition wat_act_long_jump : Z := 50333832. (* 0x03000888 *)

(** One aligned four-byte knockback cell can contain any 32-bit action word.
    The theorem uses entry zero only as a representative selected cell; the
    same list argument applies to every in-range index. *)
Theorem one_selected_knockback_word_can_hold_any_action :
  forall action,
    nth_error
      (wat_replace_nth 0
        (Init_int32 (Int.repr action))
        (gvar_init WAT_US.v_sForwardKnockbackActions)) 0 =
      Some (Init_int32 (Int.repr action)) /\
    nth_error
      (wat_replace_nth 0
        (Init_int32 (Int.repr action))
        (gvar_init WAT_JP.v_sForwardKnockbackActions)) 0 =
      Some (Init_int32 (Int.repr action)).
Proof. intros action. cbn [wat_replace_nth]. split; reflexivity. Qed.

Theorem one_knockback_word_can_hold_the_long_jump_action :
  nth_error
    (wat_replace_nth 0
      (Init_int32 (Int.repr wat_act_long_jump))
      (gvar_init WAT_US.v_sForwardKnockbackActions)) 0 =
    Some (Init_int32 (Int.repr 50333832)) /\
  nth_error
    (wat_replace_nth 0
      (Init_int32 (Int.repr wat_act_long_jump))
      (gvar_init WAT_JP.v_sForwardKnockbackActions)) 0 =
    Some (Init_int32 (Int.repr 50333832)).
Proof.
  unfold wat_act_long_jump.
  cbn [wat_replace_nth].
  split; reflexivity.
Qed.

(** The existing generated receipts connect the storage to live consumers:
    [determine_knockback_action] performs exactly two bounded table reads, and
    the Snufit handler's action temporary has exactly one source—the helper's
    return—before the checked action-setter call. *)
Definition KnockbackMutationConsumerBoundary : Prop :=
  ndi_knockback_helper_claim /\
  ndi_dynamic_action_source_claim /\
  forallb
    (ndi_handler_spec_checked
      WAT_US._set_mario_action WAT_US._drop_and_set_mario_action)
    ndi_us_handler_specs = true /\
  forallb
    (ndi_handler_spec_checked
      WAT_JP._set_mario_action WAT_JP._drop_and_set_mario_action)
    ndi_jp_handler_specs = true.

Theorem a_mutated_selected_knockback_word_reaches_an_action_setter :
  KnockbackMutationConsumerBoundary.
Proof.
  unfold KnockbackMutationConsumerBoundary.
  split; [exact stock_knockback_action_selection_is_exact |].
  split; [exact dynamic_action_arguments_have_one_internal_source |].
  exact all_stock_interaction_setter_arguments_are_recognized.
Qed.

(** Row zero is [INTERACT_COIN] and row 22 is [INTERACT_POLE].  Their handler
    pointers are initializer words 1 and 45.  On the selected 32-bit layout,
    the pole handler cell is byte offset 180.  The candidate replacement
    functions have exactly the same generated parameter and return types. *)
Definition HandlerMutationPayloadBoundary : Prop :=
  nth_error (gvar_init WAT_US.v_sInteractionHandlers) 1 =
    Some (Init_addrof WAT_US._interact_coin (Ptrofs.repr 0)) /\
  nth_error (gvar_init WAT_US.v_sInteractionHandlers) 45 =
    Some (Init_addrof WAT_US._interact_pole (Ptrofs.repr 0)) /\
  nth_error
    (wat_replace_nth 1
      (Init_addrof WAT_US._interact_snufit_bullet (Ptrofs.repr 0))
      (gvar_init WAT_US.v_sInteractionHandlers)) 1 =
    Some (Init_addrof WAT_US._interact_snufit_bullet (Ptrofs.repr 0)) /\
  nth_error
    (wat_replace_nth 45
      (Init_addrof WAT_US._interact_flame (Ptrofs.repr 0))
      (gvar_init WAT_US.v_sInteractionHandlers)) 45 =
    Some (Init_addrof WAT_US._interact_flame (Ptrofs.repr 0)) /\
  nth_error (gvar_init WAT_JP.v_sInteractionHandlers) 1 =
    Some (Init_addrof WAT_JP._interact_coin (Ptrofs.repr 0)) /\
  nth_error (gvar_init WAT_JP.v_sInteractionHandlers) 45 =
    Some (Init_addrof WAT_JP._interact_pole (Ptrofs.repr 0)) /\
  nth_error
    (wat_replace_nth 1
      (Init_addrof WAT_JP._interact_snufit_bullet (Ptrofs.repr 0))
      (gvar_init WAT_JP.v_sInteractionHandlers)) 1 =
    Some (Init_addrof WAT_JP._interact_snufit_bullet (Ptrofs.repr 0)) /\
  nth_error
    (wat_replace_nth 45
      (Init_addrof WAT_JP._interact_flame (Ptrofs.repr 0))
      (gvar_init WAT_JP.v_sInteractionHandlers)) 45 =
    Some (Init_addrof WAT_JP._interact_flame (Ptrofs.repr 0)) /\
  fn_params WAT_US.f_interact_pole =
    fn_params WAT_US.f_interact_snufit_bullet /\
  fn_return WAT_US.f_interact_pole =
    fn_return WAT_US.f_interact_snufit_bullet /\
  fn_params WAT_US.f_interact_pole = fn_params WAT_US.f_interact_flame /\
  fn_return WAT_US.f_interact_pole = fn_return WAT_US.f_interact_flame /\
  fn_params WAT_JP.f_interact_pole =
    fn_params WAT_JP.f_interact_snufit_bullet /\
  fn_return WAT_JP.f_interact_pole =
    fn_return WAT_JP.f_interact_snufit_bullet /\
  fn_params WAT_JP.f_interact_pole = fn_params WAT_JP.f_interact_flame /\
  fn_return WAT_JP.f_interact_pole = fn_return WAT_JP.f_interact_flame /\
  (22 * 8 + 4 = 180)%nat.

Theorem coin_and_pole_handler_words_accept_compatible_stock_handlers :
  HandlerMutationPayloadBoundary.
Proof.
  unfold HandlerMutationPayloadBoundary.
  vm_compute. repeat split; reflexivity.
Qed.

(** The complete result neither invents a mutation event nor hides the two
    remaining in-model origins. *)
Definition WritableActionTableCheckedBoundary : Prop :=
  WritableActionTableSourceBoundary /\
  KnockbackMutationConsumerBoundary /\
  HandlerMutationPayloadBoundary /\
  (forall action,
    nth_error
      (wat_replace_nth 0
        (Init_int32 (Int.repr action))
        (gvar_init WAT_US.v_sForwardKnockbackActions)) 0 =
      Some (Init_int32 (Int.repr action))).

Theorem writable_action_table_checked_boundary_holds :
  WritableActionTableCheckedBoundary.
Proof.
  unfold WritableActionTableCheckedBoundary.
  split; [exact writable_action_table_source_boundary_holds |].
  split; [exact a_mutated_selected_knockback_word_reaches_an_action_setter |].
  split; [exact coin_and_pole_handler_words_accept_compatible_stock_handlers |].
  intro action.
  exact (proj1 (one_selected_knockback_word_can_hold_any_action action)).
Qed.

(** A linked disproof now needs these two semantic facts.  They are kept as a
    named residual rather than smuggled into the source census. *)
Definition WritableActionTableLinkedResidual
    {State : Type}
    (clean_controller_reachable : State -> Prop)
    (valid_alias_targets_table : State -> Prop)
    (reached_outside_effect_targets_table : State -> Prop) : Prop :=
  forall state,
    clean_controller_reachable state ->
    ~ valid_alias_targets_table state /\
    ~ reached_outside_effect_targets_table state.
