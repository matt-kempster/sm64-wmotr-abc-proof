From Coq Require Import Bool Lia List PArith.BinPos ZArith.
From compcert Require Import AST Clight Integers.
From Pedro.Generated Require Import
  us_ttc_area1_macro us_obj_behaviors_2 us_behavior_actions
  us_behavior_script
  jp_ttc_area1_macro jp_obj_behaviors_2 jp_behavior_actions
  jp_behavior_script.
From Pedro.Proofs Require Import ASTFacts DustPRNG GameTypes.

Import ListNotations.
Open Scope Z_scope.

Module UMacroWindow := us_ttc_area1_macro.
Module UTTCWindow := us_obj_behaviors_2.
Module UActionWindow := us_behavior_actions.
Module UScriptWindow := us_behavior_script.

Module JMacroWindow := jp_ttc_area1_macro.
Module JTTCWindow := jp_obj_behaviors_2.
Module JActionWindow := jp_behavior_actions.
Module JScriptWindow := jp_behavior_script.

(** * Exact dust pairs with arbitrary intervening consumers

    An [RNGEffect] deliberately has no purity or fixed-cost restriction.  It
    can therefore stand for a source consumer whose number of [random_u16]
    calls depends on the incoming seed.  In particular, this model does not
    silently identify the seed before Puff2 with the seed after Puff1. *)
Definition RNGEffect : Type := Z -> Z.

Fixpoint run_rng_effects (effects : list RNGEffect) (seed : Z) : Z :=
  match effects with
  | [] => seed
  | effect :: rest => run_rng_effects rest (effect seed)
  end.

Definition dust_window_with_interference
    (before between after : list RNGEffect) (seed : Z) : Z :=
  run_rng_effects after
    (puff_rng_pair
      (run_rng_effects between
        (puff_rng_pair (run_rng_effects before seed)))).

Theorem two_exact_dust_pairs_preserved_under_arbitrary_interference :
  forall before between after seed,
    dust_window_with_interference before between after seed =
      run_rng_effects after
        (rng_steps 2
          (run_rng_effects between
            (rng_steps 2 (run_rng_effects before seed)))).
Proof. reflexivity. Qed.

(** A counted trace is the special case in which each effect is known to make
    a finite number of consecutive calls.  This theorem records the exact
    composition law without requiring any of the three traces to be empty. *)
Fixpoint run_rng_counts (counts : list nat) (seed : Z) : Z :=
  match counts with
  | [] => seed
  | count :: rest => run_rng_counts rest (rng_steps count seed)
  end.

Fixpoint total_rng_calls (counts : list nat) : nat :=
  match counts with
  | [] => 0%nat
  | count :: rest => (count + total_rng_calls rest)%nat
  end.

Lemma rng_steps_compose :
  forall first second seed,
    rng_steps second (rng_steps first seed) =
      rng_steps (first + second)%nat seed.
Proof.
  intros first second.
  induction second as [|second IH]; intro seed.
  - unfold rng_steps. simpl. now rewrite Nat.add_0_r.
  - unfold rng_steps in *. simpl.
    rewrite IH.
    now rewrite Nat.add_succ_r.
Qed.

Lemma run_rng_counts_exact :
  forall counts seed,
    run_rng_counts counts seed = rng_steps (total_rng_calls counts) seed.
Proof.
  induction counts as [|count rest IH]; intro seed.
  - reflexivity.
  - simpl. rewrite IH. apply rng_steps_compose.
Qed.

Definition counted_dust_window
    (before between after : list nat) (seed : Z) : Z :=
  run_rng_counts after
    (rng_steps 2
      (run_rng_counts between
        (rng_steps 2 (run_rng_counts before seed)))).

Theorem counted_dust_window_exact_total :
  forall before between after seed,
    counted_dust_window before between after seed =
      rng_steps
        (total_rng_calls before + 2 + total_rng_calls between + 2 +
         total_rng_calls after)%nat seed.
Proof.
  intros before between after seed.
  unfold counted_dust_window.
  repeat rewrite run_rng_counts_exact.
  repeat rewrite rng_steps_compose.
  f_equal. lia.
Qed.

(** * Generated TTC macro-object census *)

Definition ttc_macro_words (version : GameVersion) : list Z :=
  match version with
  | VersionUS =>
      init_int16_values (gvar_init UMacroWindow.v_ttc_seg7_macro_objs)
  | VersionJP =>
      init_int16_values (gvar_init JMacroWindow.v_ttc_seg7_macro_objs)
  end.

Definition ttc_macro_records (version : GameVersion) : list (list Z) :=
  chunks5 (ttc_macro_words version).

Definition macro_record_code (record : list Z) : Z :=
  match record with
  | encoded :: _ => Z.land encoded 511
  | [] => -1
  end.

Definition ttc_macro_codes (version : GameVersion) : list Z :=
  map macro_record_code (ttc_macro_records version).

Definition spinner0_macro_index : nat := 39.
Definition spinner7_macro_index : nat := 46.

Definition code_in (codes : list Z) (record : list Z) : bool :=
  existsb (Z.eqb (macro_record_code record)) codes.

Definition count_record_codes
    (codes : list Z) (records : list (list Z)) : nat :=
  length (filter (code_in codes) records).

Record TTCMacroPrefixCensus : Type := {
  census_length : nat;
  census_rotating_solids : nat;
  census_pendulums : nat;
  census_treadmills : nat;
  census_moving_bars : nat;
  census_cogs : nat;
  census_pit_blocks : nat;
  census_clock_hands : nat;
  census_earlier_spinners : nat;
  census_other_records : nat
}.

Definition ttc_prefix_census
    (version : GameVersion) (prefix_length : nat) : TTCMacroPrefixCensus :=
  let records := firstn prefix_length (ttc_macro_records version) in
  let rotating := count_record_codes [344; 345] records in
  let pendulums := count_record_codes [346] records in
  let treadmills := count_record_codes [347; 348] records in
  let bars := count_record_codes [349] records in
  let cogs := count_record_codes [350; 351] records in
  let pits := count_record_codes [352] records in
  let hands := count_record_codes [355] records in
  let spinners := count_record_codes [356] records in
  {| census_length := length records;
     census_rotating_solids := rotating;
     census_pendulums := pendulums;
     census_treadmills := treadmills;
     census_moving_bars := bars;
     census_cogs := cogs;
     census_pit_blocks := pits;
     census_clock_hands := hands;
     census_earlier_spinners := spinners;
     census_other_records :=
       (length records - rotating - pendulums - treadmills - bars - cogs -
        pits - hands - spinners)%nat |}.

Definition spinner0_expected_census : TTCMacroPrefixCensus :=
  {| census_length := 39;
     census_rotating_solids := 8;
     census_pendulums := 4;
     census_treadmills := 5;
     census_moving_bars := 12;
     census_cogs := 7;
     census_pit_blocks := 1;
     census_clock_hands := 2;
     census_earlier_spinners := 0;
     census_other_records := 0 |}.

Definition spinner7_expected_census : TTCMacroPrefixCensus :=
  {| census_length := 46;
     census_rotating_solids := 8;
     census_pendulums := 4;
     census_treadmills := 5;
     census_moving_bars := 12;
     census_cogs := 7;
     census_pit_blocks := 1;
     census_clock_hands := 2;
     census_earlier_spinners := 7;
     census_other_records := 0 |}.

Theorem generated_spinner0_prefix_census_us_jp :
  forall version,
    ttc_prefix_census version spinner0_macro_index =
      spinner0_expected_census.
Proof. intros []; vm_compute; reflexivity. Qed.

Theorem generated_spinner7_prefix_census_us_jp :
  forall version,
    ttc_prefix_census version spinner7_macro_index =
      spinner7_expected_census.
Proof. intros []; vm_compute; reflexivity. Qed.

Theorem generated_spinner_indices_us_jp :
  forall version,
    nth_error (ttc_macro_codes version) spinner0_macro_index = Some 356 /\
    nth_error (ttc_macro_codes version) spinner7_macro_index = Some 356.
Proof. intros []; vm_compute; split; reflexivity. Qed.

(** * Clight call-site receipts and conservative path budgets

    [direct_call_count_s] counts syntactic direct-call occurrences.  The
    receipt below ties the budget categories to the generated US and JP
    Clight.  Conditional branches are all present in this count; the smaller
    per-object path maxima used below therefore remain live-state premises,
    not consequences of the receipt alone. *)
Definition direct_call_count_s (callee : ident) (body : statement) : nat :=
  count_occ Pos.eq_dec (direct_callees_s body) callee.

Local Open Scope nat_scope.

Definition ttc_rng_callsite_receipt (version : GameVersion) : Prop :=
  match version with
  | VersionUS =>
      UTTCWindow._random_u16 = UScriptWindow._random_u16 /\
      UTTCWindow._random_float = UScriptWindow._random_float /\
      UTTCWindow._random_sign = UScriptWindow._random_sign /\
      UActionWindow._random_float = UScriptWindow._random_float /\
      direct_call_count_s UTTCWindow._random_u16
        (fn_body UTTCWindow.f_random_mod_offset) = 1 /\
      direct_call_count_s UTTCWindow._random_float
        (fn_body UTTCWindow.f_random_linear_offset) = 1 /\
      direct_call_count_s UScriptWindow._random_u16
        (fn_body UScriptWindow.f_random_float) = 1 /\
      direct_call_count_s UScriptWindow._random_u16
        (fn_body UScriptWindow.f_random_sign) = 1 /\
      direct_call_count_s UTTCWindow._random_mod_offset
        (fn_body UTTCWindow.f_bhv_ttc_rotating_solid_update) = 1 /\
      direct_call_count_s UTTCWindow._random_u16
        (fn_body UTTCWindow.f_bhv_ttc_pendulum_update) = 2 /\
      direct_call_count_s UTTCWindow._random_linear_offset
        (fn_body UTTCWindow.f_bhv_ttc_pendulum_update) = 1 /\
      direct_call_count_s UTTCWindow._random_mod_offset
        (fn_body UTTCWindow.f_bhv_ttc_treadmill_update) = 1 /\
      direct_call_count_s UTTCWindow._random_sign
        (fn_body UTTCWindow.f_bhv_ttc_treadmill_update) = 1 /\
      direct_call_count_s UTTCWindow._random_u16
        (fn_body UTTCWindow.f_ttc_moving_bar_act_wait) = 2 /\
      direct_call_count_s UTTCWindow._random_linear_offset
        (fn_body UTTCWindow.f_ttc_moving_bar_act_wait) = 1 /\
      direct_call_count_s UTTCWindow._random_u16
        (fn_body UTTCWindow.f_ttc_moving_bar_act_extend) = 1 /\
      direct_call_count_s UTTCWindow._random_u16
        (fn_body UTTCWindow.f_bhv_ttc_cog_update) = 1 /\
      direct_call_count_s UTTCWindow._random_sign
        (fn_body UTTCWindow.f_bhv_ttc_cog_update) = 1 /\
      direct_call_count_s UTTCWindow._random_mod_offset
        (fn_body UTTCWindow.f_bhv_ttc_pit_block_update) = 1 /\
      direct_call_count_s UTTCWindow._random_u16
        (fn_body UTTCWindow.f_bhv_ttc_2d_rotator_update) = 1 /\
      direct_call_count_s UTTCWindow._random_mod_offset
        (fn_body UTTCWindow.f_bhv_ttc_2d_rotator_update) = 3 /\
      direct_call_count_s UTTCWindow._random_sign
        (fn_body UTTCWindow.f_bhv_ttc_spinner_update) = 1 /\
      direct_call_count_s UTTCWindow._random_mod_offset
        (fn_body UTTCWindow.f_bhv_ttc_spinner_update) = 1 /\
      direct_call_count_s UActionWindow._random_float
        (fn_body UActionWindow.f_grindel_thwomp_act_idle_at_bottom) = 1 /\
      direct_call_count_s UActionWindow._random_float
        (fn_body UActionWindow.f_grindel_thwomp_act_idle_at_top) = 1
  | VersionJP =>
      JTTCWindow._random_u16 = JScriptWindow._random_u16 /\
      JTTCWindow._random_float = JScriptWindow._random_float /\
      JTTCWindow._random_sign = JScriptWindow._random_sign /\
      JActionWindow._random_float = JScriptWindow._random_float /\
      direct_call_count_s JTTCWindow._random_u16
        (fn_body JTTCWindow.f_random_mod_offset) = 1 /\
      direct_call_count_s JTTCWindow._random_float
        (fn_body JTTCWindow.f_random_linear_offset) = 1 /\
      direct_call_count_s JScriptWindow._random_u16
        (fn_body JScriptWindow.f_random_float) = 1 /\
      direct_call_count_s JScriptWindow._random_u16
        (fn_body JScriptWindow.f_random_sign) = 1 /\
      direct_call_count_s JTTCWindow._random_mod_offset
        (fn_body JTTCWindow.f_bhv_ttc_rotating_solid_update) = 1 /\
      direct_call_count_s JTTCWindow._random_u16
        (fn_body JTTCWindow.f_bhv_ttc_pendulum_update) = 2 /\
      direct_call_count_s JTTCWindow._random_linear_offset
        (fn_body JTTCWindow.f_bhv_ttc_pendulum_update) = 1 /\
      direct_call_count_s JTTCWindow._random_mod_offset
        (fn_body JTTCWindow.f_bhv_ttc_treadmill_update) = 1 /\
      direct_call_count_s JTTCWindow._random_sign
        (fn_body JTTCWindow.f_bhv_ttc_treadmill_update) = 1 /\
      direct_call_count_s JTTCWindow._random_u16
        (fn_body JTTCWindow.f_ttc_moving_bar_act_wait) = 2 /\
      direct_call_count_s JTTCWindow._random_linear_offset
        (fn_body JTTCWindow.f_ttc_moving_bar_act_wait) = 1 /\
      direct_call_count_s JTTCWindow._random_u16
        (fn_body JTTCWindow.f_ttc_moving_bar_act_extend) = 1 /\
      direct_call_count_s JTTCWindow._random_u16
        (fn_body JTTCWindow.f_bhv_ttc_cog_update) = 1 /\
      direct_call_count_s JTTCWindow._random_sign
        (fn_body JTTCWindow.f_bhv_ttc_cog_update) = 1 /\
      direct_call_count_s JTTCWindow._random_mod_offset
        (fn_body JTTCWindow.f_bhv_ttc_pit_block_update) = 1 /\
      direct_call_count_s JTTCWindow._random_u16
        (fn_body JTTCWindow.f_bhv_ttc_2d_rotator_update) = 1 /\
      direct_call_count_s JTTCWindow._random_mod_offset
        (fn_body JTTCWindow.f_bhv_ttc_2d_rotator_update) = 3 /\
      direct_call_count_s JTTCWindow._random_sign
        (fn_body JTTCWindow.f_bhv_ttc_spinner_update) = 1 /\
      direct_call_count_s JTTCWindow._random_mod_offset
        (fn_body JTTCWindow.f_bhv_ttc_spinner_update) = 1 /\
      direct_call_count_s JActionWindow._random_float
        (fn_body JActionWindow.f_grindel_thwomp_act_idle_at_bottom) = 1 /\
      direct_call_count_s JActionWindow._random_float
        (fn_body JActionWindow.f_grindel_thwomp_act_idle_at_top) = 1
  end.

Theorem ttc_rng_callsite_receipt_supported :
  forall version, ttc_rng_callsite_receipt version.
Proof. intros []; vm_compute; repeat split. Qed.

Local Open Scope Z_scope.

(** The following budgets are maxima for one compatible execution path of a
    generated macro record.  Code 347 is the first/master treadmill; the four
    code-348 followers do not draw while that master is live.  Choosing these
    path costs still requires the live object/action/timer snapshot below. *)
Definition macro_record_rng_budget (record : list Z) : nat :=
  match macro_record_code record with
  | 344 | 345 => 1%nat
  | 346 => 3%nat
  | 347 => 2%nat
  | 348 => 0%nat
  | 349 => 3%nat
  | 350 | 351 => 2%nat
  | 352 => 1%nat
  | 355 => 3%nat
  | 356 => 2%nat
  | _ => 0%nat
  end.

Fixpoint sum_nat (values : list nat) : nat :=
  match values with
  | [] => 0
  | value :: rest => value + sum_nat rest
  end%nat.

Definition macro_prefix_rng_budget
    (version : GameVersion) (prefix_length : nat) : nat :=
  sum_nat
    (map macro_record_rng_budget
      (firstn prefix_length (ttc_macro_records version))).

Theorem generated_spinner0_macro_prefix_budget_us_jp :
  forall version,
    macro_prefix_rng_budget version spinner0_macro_index = 79%nat.
Proof. intros []; vm_compute; reflexivity. Qed.

Theorem generated_spinner7_macro_prefix_budget_us_jp :
  forall version,
    macro_prefix_rng_budget version spinner7_macro_index = 93%nat.
Proof. intros []; vm_compute; reflexivity. Qed.

(** Actual call counts are intentionally supplied by a live-state snapshot.
    [snapshot_outside_rng_calls] covers every consumer not represented by the
    one Thwomp and aligned macro prefix: the rest of the tap frame, camera and
    frame-boundary work, other lists/objects, and any dynamic insertion. *)
Record TTCRNGWindowSnapshot : Type := {
  snapshot_thwomp_rng_calls : nat;
  snapshot_macro_rng_calls : list nat;
  snapshot_outside_rng_calls : nat
}.

Fixpoint pointwise_le_nat (actual budget : list nat) : Prop :=
  match actual, budget with
  | [], [] => True
  | actual_head :: actual_tail, budget_head :: budget_tail =>
      (actual_head <= budget_head)%nat /\
      pointwise_le_nat actual_tail budget_tail
  | _, _ => False
  end.

Definition live_snapshot_matches_prefix
    (version : GameVersion) (prefix_length : nat)
    (snapshot : TTCRNGWindowSnapshot) : Prop :=
  (snapshot_thwomp_rng_calls snapshot <= 1)%nat /\
  pointwise_le_nat
    (snapshot_macro_rng_calls snapshot)
    (map macro_record_rng_budget
      (firstn prefix_length (ttc_macro_records version))).

Definition no_outside_rng_call_in_window
    (snapshot : TTCRNGWindowSnapshot) : Prop :=
  snapshot_outside_rng_calls snapshot = 0%nat.

Definition snapshot_total_rng_calls
    (snapshot : TTCRNGWindowSnapshot) : nat :=
  (snapshot_thwomp_rng_calls snapshot +
   sum_nat (snapshot_macro_rng_calls snapshot) +
   snapshot_outside_rng_calls snapshot)%nat.

Lemma pointwise_sum_le :
  forall actual budget,
    pointwise_le_nat actual budget ->
    (sum_nat actual <= sum_nat budget)%nat.
Proof.
  induction actual as [|actual_head actual_tail IH];
    destruct budget as [|budget_head budget_tail]; simpl; intros H.
  - lia.
  - lia.
  - contradiction.
  - destruct H as [Hhead Htail]. specialize (IH _ Htail). lia.
Qed.

Lemma live_snapshot_total_bound :
  forall version prefix_length snapshot,
    live_snapshot_matches_prefix version prefix_length snapshot ->
    no_outside_rng_call_in_window snapshot ->
    (snapshot_total_rng_calls snapshot <=
       1 + macro_prefix_rng_budget version prefix_length)%nat.
Proof.
  intros version prefix_length snapshot [Hthwomp Hmacro] Houtside.
  unfold snapshot_total_rng_calls, no_outside_rng_call_in_window in *.
  unfold macro_prefix_rng_budget.
  pose proof (pointwise_sum_le _ _ Hmacro) as Hsum.
  lia.
Qed.

Theorem spinner0_source_tethered_window_bound_80 :
  forall version snapshot,
    live_snapshot_matches_prefix version spinner0_macro_index snapshot ->
    no_outside_rng_call_in_window snapshot ->
    ttc_rng_callsite_receipt version /\
    (snapshot_total_rng_calls snapshot <= 80)%nat.
Proof.
  intros version snapshot Hlive Houtside.
  split.
  - apply ttc_rng_callsite_receipt_supported.
  - pose proof
      (live_snapshot_total_bound version spinner0_macro_index snapshot
        Hlive Houtside) as Hbound.
    rewrite generated_spinner0_macro_prefix_budget_us_jp in Hbound.
    exact Hbound.
Qed.

Theorem spinner7_source_tethered_window_bound_94 :
  forall version snapshot,
    live_snapshot_matches_prefix version spinner7_macro_index snapshot ->
    no_outside_rng_call_in_window snapshot ->
    ttc_rng_callsite_receipt version /\
    (snapshot_total_rng_calls snapshot <= 94)%nat.
Proof.
  intros version snapshot Hlive Houtside.
  split.
  - apply ttc_rng_callsite_receipt_supported.
  - pose proof
      (live_snapshot_total_bound version spinner7_macro_index snapshot
        Hlive Houtside) as Hbound.
    rewrite generated_spinner7_macro_prefix_budget_us_jp in Hbound.
    exact Hbound.
Qed.

(** One capstone proposition for the finite RNG-window reduction.  The two
    snapshot implications deliberately retain their live-state and
    no-outside-call premises. *)
Definition ttc_rng_window_reduction_claim : Prop :=
  (forall before between after seed,
    dust_window_with_interference before between after seed =
      run_rng_effects after
        (rng_steps 2
          (run_rng_effects between
            (rng_steps 2 (run_rng_effects before seed))))) /\
  (forall before between after seed,
    counted_dust_window before between after seed =
      rng_steps
        (total_rng_calls before + 2 + total_rng_calls between + 2 +
         total_rng_calls after)%nat seed) /\
  (forall version,
    ttc_prefix_census version spinner0_macro_index =
      spinner0_expected_census) /\
  (forall version,
    ttc_prefix_census version spinner7_macro_index =
      spinner7_expected_census) /\
  (forall version, ttc_rng_callsite_receipt version) /\
  (forall version,
    macro_prefix_rng_budget version spinner0_macro_index = 79%nat) /\
  (forall version,
    macro_prefix_rng_budget version spinner7_macro_index = 93%nat) /\
  (forall version snapshot,
    live_snapshot_matches_prefix version spinner0_macro_index snapshot ->
    no_outside_rng_call_in_window snapshot ->
    ttc_rng_callsite_receipt version /\
    (snapshot_total_rng_calls snapshot <= 80)%nat) /\
  (forall version snapshot,
    live_snapshot_matches_prefix version spinner7_macro_index snapshot ->
    no_outside_rng_call_in_window snapshot ->
    ttc_rng_callsite_receipt version /\
    (snapshot_total_rng_calls snapshot <= 94)%nat).

Theorem checked_ttc_rng_window_reduction_us_jp :
  ttc_rng_window_reduction_claim.
Proof.
  unfold ttc_rng_window_reduction_claim.
  refine (conj two_exact_dust_pairs_preserved_under_arbitrary_interference _).
  refine (conj counted_dust_window_exact_total _).
  refine (conj generated_spinner0_prefix_census_us_jp _).
  refine (conj generated_spinner7_prefix_census_us_jp _).
  refine (conj ttc_rng_callsite_receipt_supported _).
  refine (conj generated_spinner0_macro_prefix_budget_us_jp _).
  refine (conj generated_spinner7_macro_prefix_budget_us_jp _).
  exact (conj spinner0_source_tethered_window_bound_80
              spinner7_source_tethered_window_bound_94).
Qed.
