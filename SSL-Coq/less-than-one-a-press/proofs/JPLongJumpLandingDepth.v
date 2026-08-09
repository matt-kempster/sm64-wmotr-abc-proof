(** The late long-jump-landing floor-sample split.

    The JP source has two distinct floor samples on a moving-action frame:
    [mario_update_quicksand] consumes the floor from before action dispatch,
    while [common_landing_action] calls [perform_ground_step] before its later
    quicksand-floor test and landing-depth write.  Thus a candidate frame may
    reset depth to zero on an ordinary pre-step floor and then apply the
    landing delta after the ground step has selected quicksand.

    This memory-light file proves only the new binary32 arithmetic at that
    split: timer four produces -0.5f and timer five produces -4.0f.  It does
    not claim that linked Clight realizes the split, that clean zero-A retail
    play reaches the late landing action, or that the value survives through
    repeated unreanchored sinks.  Those connections are named obligations
    below and are not assumptions of either theorem.

    Existing generated-AST receipts in [JPQuicksandDepth] establish the
    broader direct-writer inventory, A-edge long-jump constructor shape, and
    action-dispatch-before-final-sink syntax.  Importing that aggregate in
    this file is intentionally avoided: it exceeds the proof environment's
    memory ceiling. *)

From Coq Require Import Lia ZArith.
From compcert Require Import Floats Integers.

Local Open Scope Z_scope.
Local Transparent Float32.sub Float32.cmp Float32.compare.

Definition jplld_b32_zero : float32 :=
  Float32.of_bits (Int.repr 0).

Definition jplld_b32_half : float32 :=
  Float32.of_bits (Int.repr 1056964608). (* 0.5f *)

Definition jplld_b32_four : float32 :=
  Float32.of_bits (Int.repr 1082130432). (* 4.0f *)

Definition jplld_b32_nine_hundred_sixty : float32 :=
  Float32.of_bits (Int.repr 1148190720). (* 960.0f *)

Definition jplld_b32_warp_base : float32 :=
  Float32.of_bits (Int.repr 1145053184). (* 768.5f *)

Definition jplld_b32_warp_base_plus_960 : float32 :=
  Float32.of_bits (Int.repr 1155010560). (* 1728.5f *)

(** Hand-written mirrors of the final binary32 subtraction after an ordinary
    pre-step floor has supplied +0.0f and a post-step quicksand floor has
    selected the late landing formula.  The Clight-expression refinement is
    deliberately an obligation below. *)
Definition jp_timer_four_split_depth : float32 :=
  Float32.sub jplld_b32_zero jplld_b32_half.

Definition jp_timer_five_split_depth : float32 :=
  Float32.sub jplld_b32_zero jplld_b32_four.

Theorem jp_timer_four_split_depth_binary32_checked :
  Float32.to_bits jp_timer_four_split_depth = Int.repr 3204448256 /\
  Float32.cmp Clt jp_timer_four_split_depth jplld_b32_zero = true.
Proof. vm_compute. split; reflexivity. Qed.

Theorem jp_timer_five_split_depth_binary32_checked :
  Float32.to_bits jp_timer_five_split_depth = Int.repr 3229614080 /\
  Float32.cmp Clt jp_timer_five_split_depth jplld_b32_zero = true.
Proof. vm_compute. split; reflexivity. Qed.

(** The magnitude calculation is exact over integers.  It is not presented
    as a binary32 recurrence theorem. *)
Theorem jplld_240_times_four_is_960 :
  (240 * 4 = 960)%Z.
Proof. reflexivity. Qed.

(** * Explicit remaining connections *)

Inductive JPLandingFloorSample : Type :=
| JPLLOrdinaryFloor
| JPLLQuicksandFloor.

(** [linked_landing_step] must be instantiated with the actual linked-Clight
    one-frame relation.  The obligation says that the two relevant split
    cases refine the operation trees checked above. *)
Definition JPLandingSplitSampleClightRefinementObligation
    (linked_landing_step :
      JPLandingFloorSample -> JPLandingFloorSample -> Z ->
      float32 -> float32 -> Prop) : Prop :=
  (forall after,
    linked_landing_step JPLLOrdinaryFloor JPLLQuicksandFloor 4
      jplld_b32_zero after ->
    after = jp_timer_four_split_depth) /\
  (forall after,
    linked_landing_step JPLLOrdinaryFloor JPLLQuicksandFloor 5
      jplld_b32_zero after ->
    after = jp_timer_five_split_depth).

(** Geometry/action provenance must decide whether either split is reachable
    from a clean zero-A state.  This definition states the exclusion needed
    for an impossibility proof; it is not asserted. *)
Definition JPCleanZeroALateLandingSplitExcluded
    (clean_zero_a_reaches_split_timer : Z -> Prop) : Prop :=
  ~ clean_zero_a_reaches_split_timer 4 /\
  ~ clean_zero_a_reaches_split_timer 5.

(** A relational recurrence avoids claiming an evaluator-checked 240-step
    endpoint.  Closing either proposition below requires a scalable binary32
    induction or a proof environment with native reduction enabled. *)
Inductive JPLandingSinkRecurrence
    (depth : float32) : nat -> float32 -> float32 -> Prop :=
| JPLL_SinkZero :
    forall base,
      JPLandingSinkRecurrence depth O base base
| JPLL_SinkStep :
    forall ticks base middle,
      JPLandingSinkRecurrence depth ticks base middle ->
      JPLandingSinkRecurrence depth (S ticks) base
        (Float32.sub middle depth).

Definition JPSplitTimerFiveZeroBaseAmplifierBinary32Obligation : Prop :=
  JPLandingSinkRecurrence jp_timer_five_split_depth 240%nat
    jplld_b32_zero jplld_b32_nine_hundred_sixty.

Definition JPSplitTimerFiveWarpBaseAmplifierBinary32Obligation : Prop :=
  JPLandingSinkRecurrence jp_timer_five_split_depth 240%nat
    jplld_b32_warp_base jplld_b32_warp_base_plus_960.
