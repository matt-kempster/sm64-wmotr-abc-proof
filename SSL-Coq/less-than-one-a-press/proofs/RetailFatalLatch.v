(** Retail delayed-warp latch closure for Ink's double-NULL branch.

    The explicit transition system below mirrors the source-audited scheduling
    events that can occur after [update_mario_geometry_inputs] successfully
    installs death/game-over in an empty [sDelayedWarpOp]:

    - a supported [ACT_DISAPPEARED] Mario tick;
    - the normal-play delayed-warp timer tail;
    - a frame/transition with no useful Mario tick;
    - an unrelated frame that does not write the latch; or
    - an atomic destination/level initialization barrier.

    A reset barrier deliberately destroys the *old* continuation.  This is the
    essential retail restriction missing from the earlier over-permissive
    model.  [ClightFacts] independently computes the direct-writer and explicit
    address-taking censuses for the generated US/JP [level_update.c] units,
    checks call-presence/callee-order and separate clear-presence anchors, and
    checks the packed SSL Area 1 fatal-destination record.  Those receipts do
    not prove assignment/call order, destination selection, or whole-program
    alias safety.

    This module does not claim an iterated, linked Clight small-step refinement
    of the event system.  In particular, arbitrary memory corruption is out of
    scope.  It proves the scheduler invariant and packages the generated syntax
    receipts without admitting the missing composition theorem. *)

From Coq Require Import Bool List Lia.
From compcert Require Import AST Clight.
From LessThanOneAPress.Proofs Require Import ASTFacts ClightFacts.

Import ListNotations.

Inductive RetailFatalKind : Type :=
| RetailDeath
| RetailGameOver.

Inductive RetailPendingWarp : Type :=
| RetailNoPendingWarp
| RetailFatalPending (kind : RetailFatalKind) (timer : nat)
| RetailUpperPending (timer : nat).

Inductive RetailOldContinuation : Type :=
| RetailDisappeared (ticks_remaining : nat)
| RetailContinuationDestroyed.

Record RetailLatchState : Type := {
  retail_pending : RetailPendingWarp;
  retail_old_continuation : RetailOldContinuation;
  retail_upper_request_accepted : bool;
  retail_old_mario_phase_available : bool
}.

(** This is [level_trigger_warp]'s first-writer rule projected to the two
    operations relevant to the race. *)
Definition retail_request_upper
    (state : RetailLatchState) : RetailLatchState :=
  match retail_pending state with
  | RetailNoPendingWarp => {|
      retail_pending := RetailUpperPending 20;
      retail_old_continuation := retail_old_continuation state;
      retail_upper_request_accepted := true;
      retail_old_mario_phase_available :=
        retail_old_mario_phase_available state
    |}
  | _ => state
  end.

(** One floor-supported dispatch of [ACT_DISAPPEARED].  Argument low word
    [2] becomes [1] on the first tick.  The second tick becomes [0] and calls
    [level_trigger_warp] for the upper object warp. *)
Definition retail_disappeared_tick
    (state : RetailLatchState) : RetailLatchState :=
  if retail_old_mario_phase_available state then
    match retail_old_continuation state with
    | RetailDisappeared 0 => state
    | RetailDisappeared 1 =>
        retail_request_upper {|
          retail_pending := retail_pending state;
          retail_old_continuation := RetailDisappeared 0;
          retail_upper_request_accepted :=
            retail_upper_request_accepted state;
          retail_old_mario_phase_available := true
        |}
    | RetailDisappeared (S (S remaining)) => {|
        retail_pending := retail_pending state;
        retail_old_continuation := RetailDisappeared (S remaining);
        retail_upper_request_accepted :=
          retail_upper_request_accepted state;
        retail_old_mario_phase_available := true
      |}
    | RetailContinuationDestroyed => state
    end
  else state.

(** The tail call to [initiate_delayed_warp].  Positive timers decrement.
    Reaching zero starts the fatal level transition, after which the old
    level has no further Mario behavior phase. *)
Definition retail_fatal_timer_tail
    (state : RetailLatchState) : RetailLatchState :=
  match retail_pending state with
  | RetailFatalPending kind 0 => {|
      retail_pending := RetailFatalPending kind 0;
      retail_old_continuation := RetailContinuationDestroyed;
      retail_upper_request_accepted :=
        retail_upper_request_accepted state;
      retail_old_mario_phase_available := false
    |}
  | RetailFatalPending kind 1 => {|
      retail_pending := RetailFatalPending kind 0;
      retail_old_continuation := RetailContinuationDestroyed;
      retail_upper_request_accepted :=
        retail_upper_request_accepted state;
      retail_old_mario_phase_available := false
    |}
  | RetailFatalPending kind (S (S remaining)) => {|
      retail_pending := RetailFatalPending kind (S remaining);
      retail_old_continuation := retail_old_continuation state;
      retail_upper_request_accepted :=
        retail_upper_request_accepted state;
      retail_old_mario_phase_available :=
        retail_old_mario_phase_available state
    |}
  | _ => state
  end.

(** At the observable boundary of a clear/reset function there is no useful
    continuation from the old SSL Mario object.  Treating the synchronous
    initialization call as one scheduler event prevents an impossible Mario
    behavior update from being inserted halfway through it. *)
Definition retail_clear_reset_barrier
    (state : RetailLatchState) : RetailLatchState := {|
  retail_pending := RetailNoPendingWarp;
  retail_old_continuation := RetailContinuationDestroyed;
  retail_upper_request_accepted := retail_upper_request_accepted state;
  retail_old_mario_phase_available := false
|}.

Inductive RetailLatchEvent : Type :=
| RetailSupportedMarioTick
| RetailNormalTimerTail
| RetailNoMarioTick
| RetailUnrelatedNonwriterTick
| RetailClearResetBarrier.

Definition retail_latch_step
    (event : RetailLatchEvent)
    (state : RetailLatchState) : RetailLatchState :=
  match event with
  | RetailSupportedMarioTick => retail_disappeared_tick state
  | RetailNormalTimerTail => retail_fatal_timer_tail state
  | RetailNoMarioTick | RetailUnrelatedNonwriterTick => state
  | RetailClearResetBarrier => retail_clear_reset_barrier state
  end.

Fixpoint retail_latch_run
    (events : list RetailLatchEvent)
    (state : RetailLatchState) : RetailLatchState :=
  match events with
  | [] => state
  | event :: rest =>
      retail_latch_run rest (retail_latch_step event state)
  end.

(** The double-NULL frame first installs timer 48, then cached interaction
    selects [ACT_DISAPPEARED(0x00040002)], then the normal-play tail decrements
    the fatal timer to 47.  The action itself was not dispatched because the
    floor remained NULL. *)
Definition retail_after_both_null_frame
    (kind : RetailFatalKind) : RetailLatchState := {|
  retail_pending := RetailFatalPending kind 47;
  retail_old_continuation := RetailDisappeared 2;
  retail_upper_request_accepted := false;
  retail_old_mario_phase_available := true
|}.

Definition retail_fatal_or_old_continuation_destroyed
    (state : RetailLatchState) : Prop :=
  (exists kind timer,
      retail_pending state = RetailFatalPending kind timer) \/
  retail_old_continuation state = RetailContinuationDestroyed.

Definition RetailFatalLatchInvariant (state : RetailLatchState) : Prop :=
  retail_fatal_or_old_continuation_destroyed state /\
  retail_upper_request_accepted state = false.

Theorem retail_both_null_frame_exact :
  forall kind,
    RetailFatalLatchInvariant (retail_after_both_null_frame kind).
Proof.
  intro kind. split.
  - left. exists kind, 47. reflexivity.
  - reflexivity.
Qed.

Theorem retail_fatal_latch_invariant_one_step :
  forall event state,
    RetailFatalLatchInvariant state ->
    RetailFatalLatchInvariant (retail_latch_step event state).
Proof.
  intros event
    [pending continuation upper_accepted mario_phase]
    [Hsafe Hupper].
  destruct event; cbn in *.
  - destruct mario_phase; cbn.
    + destruct continuation as [ticks |]; cbn.
      * destruct ticks as [| [| remaining]]; cbn.
        -- destruct Hsafe as
             [(pending_kind & pending_timer & Hpending) | Hdestroyed].
           ++ split.
              ** left.
                 exists pending_kind, pending_timer.
                 exact Hpending.
              ** exact Hupper.
           ++ discriminate.
        -- destruct pending as
             [| pending_kind pending_timer | pending_timer]; cbn in *.
           ++ destruct Hsafe as [(kind & timer & Hcontra) | Hcontra];
                discriminate.
           ++ split.
              ** left. exists pending_kind, pending_timer. reflexivity.
              ** exact Hupper.
           ++ destruct Hsafe as [(kind & timer & Hcontra) | Hcontra];
                discriminate.
        -- destruct Hsafe as
             [(pending_kind & pending_timer & Hpending) | Hdestroyed].
           ++ split.
              ** left.
                 exists pending_kind, pending_timer.
                 exact Hpending.
              ** exact Hupper.
           ++ discriminate.
      * exact (conj Hsafe Hupper).
    + exact (conj Hsafe Hupper).
  - destruct pending as [| kind timer | timer]; cbn.
    + exact (conj Hsafe Hupper).
    + destruct timer as [| [| remaining]]; cbn.
      * split; [right; reflexivity | exact Hupper].
      * split; [right; reflexivity | exact Hupper].
      * split.
        -- left. exists kind, (S remaining). reflexivity.
        -- exact Hupper.
    + exact (conj Hsafe Hupper).
  - exact (conj Hsafe Hupper).
  - exact (conj Hsafe Hupper).
  - split; [right; reflexivity | exact Hupper].
Qed.

Theorem retail_fatal_latch_invariant_trace :
  forall events state,
    RetailFatalLatchInvariant state ->
    RetailFatalLatchInvariant (retail_latch_run events state).
Proof.
  induction events as [| event rest IH]; intros state Hstate.
  - exact Hstate.
  - cbn. apply IH.
    now apply retail_fatal_latch_invariant_one_step.
Qed.

(** Main scheduler result: after the double-NULL event, the fatal operation
    either remains installed or a reset/terminal barrier has destroyed the old
    continuation.  No suffix can accept the upper object-warp request. *)
Theorem retail_fatal_persists_or_reset_destroys_disappeared :
  forall kind events,
    retail_fatal_or_old_continuation_destroyed
      (retail_latch_run events (retail_after_both_null_frame kind)) /\
    retail_upper_request_accepted
      (retail_latch_run events (retail_after_both_null_frame kind)) = false.
Proof.
  intros kind events.
  apply retail_fatal_latch_invariant_trace.
  apply retail_both_null_frame_exact.
Qed.

Theorem two_supported_disappeared_ticks_cannot_replace_fatal :
  forall kind,
    retail_latch_run
      [RetailSupportedMarioTick; RetailSupportedMarioTick]
      (retail_after_both_null_frame kind) =
    {|
      retail_pending := RetailFatalPending kind 47;
      retail_old_continuation := RetailDisappeared 0;
      retail_upper_request_accepted := false;
      retail_old_mario_phase_available := true
    |}.
Proof. intros []; reflexivity. Qed.

(** This intentionally unsafe transition demonstrates why a reset that merely
    clears the latch while retaining [ACT_DISAPPEARED(1)] would be fatal to the
    proof.  It is a counterexample to the old over-permissive abstraction, not
    a retail-game witness; none of the audited clear sites has this shape. *)
Definition unsafe_clear_but_keep_continuation
    (state : RetailLatchState) : RetailLatchState := {|
  retail_pending := RetailNoPendingWarp;
  retail_old_continuation := retail_old_continuation state;
  retail_upper_request_accepted := retail_upper_request_accepted state;
  retail_old_mario_phase_available := true
|}.

Theorem over_permissive_clear_accepts_upper_counterexample :
  retail_disappeared_tick
    (unsafe_clear_but_keep_continuation {|
      retail_pending := RetailFatalPending RetailDeath 47;
      retail_old_continuation := RetailDisappeared 1;
      retail_upper_request_accepted := false;
      retail_old_mario_phase_available := true
    |}) =
  {|
    retail_pending := RetailUpperPending 20;
    retail_old_continuation := RetailDisappeared 0;
    retail_upper_request_accepted := true;
    retail_old_mario_phase_available := true
  |}.
Proof. reflexivity. Qed.

Definition RetailFatalLatchSourceKernel : Prop :=
  retail_fatal_latch_source_shape_us_claim /\
  retail_fatal_latch_source_shape_jp_claim /\
  internal_function_assignment_sites ULU._sDelayedWarpOp
    ULU.global_definitions = delayed_warp_assignment_sites_us /\
  internal_function_assignment_sites JLU._sDelayedWarpOp
    JLU.global_definitions = delayed_warp_assignment_sites_jp /\
  internal_function_address_sites ULU._sDelayedWarpOp
    ULU.global_definitions = [] /\
  internal_function_address_sites JLU._sDelayedWarpOp
    JLU.global_definitions = [] /\
  delayed_warp_clear_site_anchor_source_shape_us_claim /\
  delayed_warp_clear_site_anchor_source_shape_jp_claim /\
  firstn 2 (skipn 92 (gvar_init USS.v_level_ssl_entry)) =
    ssl_area1_death_warp_record /\
  firstn 2 (skipn 92 (gvar_init JSS.v_level_ssl_entry)) =
    ssl_area1_death_warp_record.

Theorem retail_fatal_latch_source_kernel_checked :
  RetailFatalLatchSourceKernel.
Proof.
  unfold RetailFatalLatchSourceKernel.
  split; [exact retail_fatal_latch_source_shape_us |].
  split; [exact retail_fatal_latch_source_shape_jp |].
  split; [exact delayed_warp_assignment_census_exact_us |].
  split; [exact delayed_warp_assignment_census_exact_jp |].
  split; [exact delayed_warp_explicit_address_sites_empty_us |].
  split; [exact delayed_warp_explicit_address_sites_empty_jp |].
  split; [exact delayed_warp_clear_site_anchor_source_shape_us |].
  split; [exact delayed_warp_clear_site_anchor_source_shape_jp |].
  split; [exact ssl_area1_death_warp_record_exact_us |].
  exact ssl_area1_death_warp_record_exact_jp.
Qed.

Definition RetailFatalLatchCheckedBoundary : Prop :=
  RetailFatalLatchSourceKernel /\
  (forall kind events,
    retail_fatal_or_old_continuation_destroyed
      (retail_latch_run events (retail_after_both_null_frame kind)) /\
    retail_upper_request_accepted
      (retail_latch_run events (retail_after_both_null_frame kind)) = false).

Theorem retail_fatal_latch_checked_boundary :
  RetailFatalLatchCheckedBoundary.
Proof.
  split.
  - exact retail_fatal_latch_source_kernel_checked.
  - exact retail_fatal_persists_or_reset_destroys_disappeared.
Qed.
