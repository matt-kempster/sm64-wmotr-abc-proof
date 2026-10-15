From Coq Require Import List Lia.
From compcert Require Import Clight Events Smallstep.
Import ListNotations.

(** An indexed observation of the original CompCert execution. There is no
    alternative game transition relation here. Indices outside the finite
    prefix have no interpretation; every receipt must state its bounds. *)
Record demo_execution_history (prog : Clight.program) : Type := {
 history_length : nat;
 history_state : nat -> Clight.state;
 history_trace : nat -> Events.trace;
 history_step : forall index,
   (index < history_length)%nat ->
   Clight.step2 (Clight.globalenv prog)
     (history_state index) (history_trace index) (history_state (S index))
}.
Arguments history_length {prog} _.
Arguments history_state {prog} _ _.
Arguments history_trace {prog} _ _.
Arguments history_step {prog} _ _ _.

Fixpoint history_prefix_trace {prog} (history : demo_execution_history prog)
    (length : nat) : Events.trace :=
 match length with
 | O => E0
 | S previous => history_prefix_trace history previous ++ history_trace history previous
 end.

Definition history_index_valid {prog} (history : demo_execution_history prog)
    (index : nat) : Prop := (index <= history_length history)%nat.

Definition history_interval {prog} (history : demo_execution_history prog)
    (first past : nat) : Prop :=
 (first <= past <= history_length history)%nat.

(** Forgetting the indexing yields the ordinary real Clight execution. This
    does not assert any permitted initial state, hardware behavior, source
    completeness, or boot-to-gameplay witness. Those are separate obligations
    of the full specification, rather than implicit properties of this type. *)
Theorem history_prefix_is_actual_execution :
 forall prog (history : demo_execution_history prog) length,
 history_index_valid history length ->
 Smallstep.star Clight.step2 (Clight.globalenv prog)
   (history_state history O) (history_prefix_trace history length)
   (history_state history length).
Proof.
 intros prog history length. induction length as [|length IH]; intros Hbound.
 - apply star_refl.
 - cbn [history_prefix_trace].
   eapply star_trans.
   + apply IH. unfold history_index_valid in *. lia.
   + apply star_one. apply history_step.
     unfold history_index_valid in Hbound. lia.
   + reflexivity.
Qed.
