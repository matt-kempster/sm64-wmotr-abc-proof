From Coq Require Import Bool Lia List PArith.BinPos ZArith.
From compcert Require Import AST Clight Integers.
From Pedro.Generated Require Import
  us_object_list_processor us_behavior_data us_behavior_actions
  us_object_helpers us_behavior_script
  jp_object_list_processor jp_behavior_data jp_behavior_actions
  jp_object_helpers jp_behavior_script.
From Pedro.Proofs Require Import ASTFacts GameTypes.

Import ListNotations.
Open Scope Z_scope.

Module UOL := us_object_list_processor.
Module UBD := us_behavior_data.
Module UBA := us_behavior_actions.
Module UOH := us_object_helpers.
Module UBS := us_behavior_script.

Module JOL := jp_object_list_processor.
Module JBD := jp_behavior_data.
Module JBA := jp_behavior_actions.
Module JOH := jp_object_helpers.
Module JBS := jp_behavior_script.

(** Recognize the normalized Clight load used for [oTimer].  After the object
    field macros are preprocessed, [oTimer] is [asS32[51]]. *)
Definition array_field_index_loadb
    (array_field : ident) (index : Z) (value : expr) : bool :=
  match value with
  | Ederef
      (Ebinop Oadd (Efield _ found_field _)
        (Econst_int found_index _) _) _ =>
      Pos.eqb found_field array_field &&
      Int.eq found_index (Int.repr index)
  | _ => false
  end.

Definition temp_eq_zero_b (temporary : ident) (condition : expr) : bool :=
  match condition with
  | Ebinop Oeq (Etempvar tested _) (Econst_int zero _) _ =>
      Pos.eqb temporary tested && Int.eq zero Int.zero
  | Ebinop Oeq (Econst_int zero _) (Etempvar tested _) _ =>
      Int.eq zero Int.zero && Pos.eqb temporary tested
  | _ => false
  end.

(** Find a call whose only occurrence is later checked separately and whose
    enclosing branch is selected by [asS32[index] == 0]. *)
Fixpoint contains_array_index_zero_guarded_call_s
    (array_field : ident) (index : Z) (callee : ident)
    (statement : statement) : bool :=
  match statement with
  | Ssequence first second =>
      (match first, second with
       | Sset loaded value, Sifthenelse condition yes_branch _ =>
           array_field_index_loadb array_field index value &&
           temp_eq_zero_b loaded condition &&
           calls_ident_s callee yes_branch
       | _, _ => false
      end) ||
      contains_array_index_zero_guarded_call_s
        array_field index callee first ||
      contains_array_index_zero_guarded_call_s
        array_field index callee second
  | Sloop body increment =>
      contains_array_index_zero_guarded_call_s
        array_field index callee body ||
      contains_array_index_zero_guarded_call_s
        array_field index callee increment
  | Sifthenelse _ yes_branch no_branch =>
      contains_array_index_zero_guarded_call_s
        array_field index callee yes_branch ||
      contains_array_index_zero_guarded_call_s
        array_field index callee no_branch
  | Slabel _ body =>
      contains_array_index_zero_guarded_call_s
        array_field index callee body
  | _ => false
  end.

Fixpoint init_int8_values (values : list init_data) : list Z :=
  match values with
  | [] => []
  | Init_int8 value :: rest => Int.signed value :: init_int8_values rest
  | _ :: rest => init_int8_values rest
  end.

(** These checks are deliberately stronger than a call-graph reachability
    receipt: they pin the unique timer-zero call sites, the exact direct-call
    lists along the random path, the cross-translation-unit symbols, the object
    phases, and the constants and seed assignment in the retail recurrence. *)
Definition dust_prng_source_receipt (version : GameVersion) : Prop :=
  match version with
  | VersionUS =>
      init_int8_values (gvar_init UOL.v_sObjectListUpdateOrder) =
        [11; 9; 10; 0; 5; 4; 2; 6; 8; 12; -1] /\
      hd_error (gvar_init UBD.v_bhvTTCSpinner) =
        Some (Init_int32 (Int.repr 589824)) /\
      hd_error (gvar_init UBD.v_bhvMario) =
        Some (Init_int32 Int.zero) /\
      hd_error (gvar_init UBD.v_bhvWhitePuff1) =
        Some (Init_int32 (Int.repr 524288)) /\
      hd_error (gvar_init UBD.v_bhvWhitePuff2) =
        Some (Init_int32 (Int.repr 786432)) /\
      direct_callees_s (fn_body UBA.f_bhv_white_puff_1_loop) =
        [UBA._obj_translate_xz_random;
         UBA._cur_obj_scale;
         UBA._cur_obj_move_using_fvel_and_gravity;
         UBA._obj_mark_for_deletion] /\
      direct_callees_s (fn_body UBA.f_bhv_white_puff_2_loop) =
        [UBA._obj_translate_xz_random] /\
      contains_array_index_zero_guarded_call_s
        UBA._asS32 51 UBA._obj_translate_xz_random
        (fn_body UBA.f_bhv_white_puff_1_loop) = true /\
      contains_array_index_zero_guarded_call_s
        UBA._asS32 51 UBA._obj_translate_xz_random
        (fn_body UBA.f_bhv_white_puff_2_loop) = true /\
      UBA._obj_translate_xz_random = UOH._obj_translate_xz_random /\
      direct_callees_s (fn_body UOH.f_obj_translate_xz_random) =
        [UOH._random_float; UOH._random_float] /\
      UOH._random_float = UBS._random_float /\
      direct_callees_s (fn_body UBS.f_random_float) =
        [UBS._random_u16] /\
      direct_callees_s (fn_body UBS.f_random_u16) = [] /\
      statement_assigns_global_s UBS._gRandomSeed16
        (fn_body UBS.f_random_u16) = true /\
      statement_mentions_int_s 22026 (fn_body UBS.f_random_u16) = true /\
      statement_mentions_int_s 43605 (fn_body UBS.f_random_u16) = true /\
      statement_mentions_int_s 8180 (fn_body UBS.f_random_u16) = true /\
      statement_mentions_int_s 33152 (fn_body UBS.f_random_u16) = true /\
      statement_mentions_int_s 1073741823
        (fn_body UBS.f_cur_obj_update) = true /\
      assigns_array_field_index_s UBS._asS32 51
        (fn_body UBS.f_cur_obj_update) = true
  | VersionJP =>
      init_int8_values (gvar_init JOL.v_sObjectListUpdateOrder) =
        [11; 9; 10; 0; 5; 4; 2; 6; 8; 12; -1] /\
      hd_error (gvar_init JBD.v_bhvTTCSpinner) =
        Some (Init_int32 (Int.repr 589824)) /\
      hd_error (gvar_init JBD.v_bhvMario) =
        Some (Init_int32 Int.zero) /\
      hd_error (gvar_init JBD.v_bhvWhitePuff1) =
        Some (Init_int32 (Int.repr 524288)) /\
      hd_error (gvar_init JBD.v_bhvWhitePuff2) =
        Some (Init_int32 (Int.repr 786432)) /\
      direct_callees_s (fn_body JBA.f_bhv_white_puff_1_loop) =
        [JBA._obj_translate_xz_random;
         JBA._cur_obj_scale;
         JBA._cur_obj_move_using_fvel_and_gravity;
         JBA._obj_mark_for_deletion] /\
      direct_callees_s (fn_body JBA.f_bhv_white_puff_2_loop) =
        [JBA._obj_translate_xz_random] /\
      contains_array_index_zero_guarded_call_s
        JBA._asS32 51 JBA._obj_translate_xz_random
        (fn_body JBA.f_bhv_white_puff_1_loop) = true /\
      contains_array_index_zero_guarded_call_s
        JBA._asS32 51 JBA._obj_translate_xz_random
        (fn_body JBA.f_bhv_white_puff_2_loop) = true /\
      JBA._obj_translate_xz_random = JOH._obj_translate_xz_random /\
      direct_callees_s (fn_body JOH.f_obj_translate_xz_random) =
        [JOH._random_float; JOH._random_float] /\
      JOH._random_float = JBS._random_float /\
      direct_callees_s (fn_body JBS.f_random_float) =
        [JBS._random_u16] /\
      direct_callees_s (fn_body JBS.f_random_u16) = [] /\
      statement_assigns_global_s JBS._gRandomSeed16
        (fn_body JBS.f_random_u16) = true /\
      statement_mentions_int_s 22026 (fn_body JBS.f_random_u16) = true /\
      statement_mentions_int_s 43605 (fn_body JBS.f_random_u16) = true /\
      statement_mentions_int_s 8180 (fn_body JBS.f_random_u16) = true /\
      statement_mentions_int_s 33152 (fn_body JBS.f_random_u16) = true /\
      statement_mentions_int_s 1073741823
        (fn_body JBS.f_cur_obj_update) = true /\
      assigns_array_field_index_s JBS._asS32 51
        (fn_body JBS.f_cur_obj_update) = true
  end.

Theorem dust_prng_source_receipt_supported :
  forall version, dust_prng_source_receipt version.
Proof.
  intros []; vm_compute; repeat split.
Qed.

(** Faithful unsigned-16 mirror of [random_u16]. *)
Definition u16z (value : Z) : Z := Z.land value 65535.

Definition random_u16_step_z (seed : Z) : Z :=
  let seed0 := if Z.eqb seed 22026 then 0 else u16z seed in
  let temp1 :=
    u16z
      (Z.lxor
        (Z.shiftl (Z.land seed0 255) 8)
        seed0) in
  let seed1 :=
    u16z
      (Z.shiftl (Z.land temp1 255) 8 +
       Z.shiftr (Z.land temp1 65280) 8) in
  let temp1' :=
    u16z
      (Z.lxor
        (Z.shiftl (Z.land temp1 255) 1)
        seed1) in
  let temp2 :=
    u16z (Z.lxor (Z.shiftr temp1' 1) 65408) in
  if Z.even temp1'
  then
    if Z.eqb temp2 43605
    then 0
    else u16z (Z.lxor temp2 8180)
  else u16z (Z.lxor temp2 33152).

Definition rng_steps (count : nat) (seed : Z) : Z :=
  Nat.iter count random_u16_step_z seed.

Definition puff_rng_pair (seed : Z) : Z :=
  rng_steps 2 seed.

Theorem puff_rng_pair_is_exactly_two_consecutive_steps :
  forall seed, puff_rng_pair seed = rng_steps 2 seed.
Proof. reflexivity. Qed.

Lemma iter_two_after_two_is_four :
  forall (A : Type) (step : A -> A) (initial : A),
    Nat.iter 2 step (Nat.iter 2 step initial) =
    Nat.iter 4 step initial.
Proof. reflexivity. Qed.

(** The global seed at the start of Puff2 need not equal the seed at the end
    of Puff1: older unimportant objects can consume RNG between the DEFAULT and
    UNIMPORTANT phases. *)
Definition no_intervening_rng_consumer
    (seed_before_puff1 seed_before_puff2 : Z) : Prop :=
  seed_before_puff2 = rng_steps 2 seed_before_puff1.

Theorem dust_is_four_steps_under_no_intervening_consumer :
  forall seed_before_puff1 seed_before_puff2,
    no_intervening_rng_consumer seed_before_puff1 seed_before_puff2 ->
    rng_steps 2 seed_before_puff2 = rng_steps 4 seed_before_puff1.
Proof.
  intros seed_before_puff1 seed_before_puff2 Hnone.
  unfold no_intervening_rng_consumer in Hnone.
  subst seed_before_puff2.
  unfold rng_steps.
  apply iter_two_after_two_is_four.
Qed.

(** First-update timer projection for either freshly allocated puff.  The
    allocator receipt in [DustPool] checks that raw data are zeroed, while the
    source receipt above checks the timer-zero guard and the generic timer
    write/bound.  This small function makes the remaining model assumption
    explicit: no action change resets the puff's timer between updates. *)
Definition puff_rng_cost_at_timer (timer : Z) : nat :=
  if Z.eqb timer 0 then 2%nat else 0%nat.

Definition increment_puff_timer (timer : Z) : Z :=
  if timer <? 1073741823 then timer + 1 else timer.

Theorem fresh_puff_timer_has_exactly_two_rng_calls :
  puff_rng_cost_at_timer 0 = 2%nat.
Proof. reflexivity. Qed.

Theorem fresh_puff_timer_advances_to_one :
  increment_puff_timer 0 = 1.
Proof. reflexivity. Qed.

Theorem nonzero_puff_timer_has_no_rng_calls :
  forall timer,
    timer <> 0 ->
    puff_rng_cost_at_timer timer = 0%nat.
Proof.
  intros timer Hnonzero.
  unfold puff_rng_cost_at_timer.
  destruct (Z.eqb timer 0) eqn:Hequal.
  - apply Z.eqb_eq in Hequal. contradiction.
  - reflexivity.
Qed.

Inductive DustRNGSite : Type :=
| Puff1X
| Puff1Z
| Puff2X
| Puff2Z.

Inductive DustObjectPhase : Type :=
| DefaultPhase
| UnimportantPhase.

Record DustRNGEvent : Type := DustEvent {
  dust_site : DustRNGSite;
  dust_frame : nat;
  dust_phase : DustObjectPhase
}.

(** This list is a model-level event specification.  [DustRuntime] derives it
    from the successfully computed Mist/Puff1/Puff2 schedule; this definition
    alone is not a runtime execution theorem. *)
Definition dust_rng_trace (tap_frame : nat) : list DustRNGEvent :=
  [ DustEvent Puff1X tap_frame DefaultPhase;
    DustEvent Puff1Z tap_frame DefaultPhase;
    DustEvent Puff2X tap_frame UnimportantPhase;
    DustEvent Puff2Z tap_frame UnimportantPhase ].

Definition dust_owned_calls_at
    (tap_frame observed_frame : nat) : nat :=
  if Nat.eqb tap_frame observed_frame
  then length (dust_rng_trace tap_frame)
  else 0%nat.

Theorem dust_rng_provenance_order :
  forall tap_frame,
    map dust_site (dust_rng_trace tap_frame) =
      [Puff1X; Puff1Z; Puff2X; Puff2Z].
Proof. reflexivity. Qed.

Theorem dust_rng_phase_order :
  forall tap_frame,
    map dust_phase (dust_rng_trace tap_frame) =
      [DefaultPhase; DefaultPhase; UnimportantPhase; UnimportantPhase].
Proof. reflexivity. Qed.

Theorem dust_rng_all_calls_occur_on_tap_frame :
  forall tap_frame,
    map dust_frame (dust_rng_trace tap_frame) =
      repeat tap_frame 4.
Proof. reflexivity. Qed.

Theorem dust_rng_exactly_four_owned_calls :
  forall tap_frame, dust_owned_calls_at tap_frame tap_frame = 4%nat.
Proof.
  intro tap_frame.
  unfold dust_owned_calls_at, dust_rng_trace.
  rewrite Nat.eqb_refl.
  reflexivity.
Qed.

Theorem dust_rng_no_later_owned_calls :
  forall tap_frame later_frame,
    (tap_frame < later_frame)%nat ->
    dust_owned_calls_at tap_frame later_frame = 0%nat.
Proof.
  intros tap_frame later_frame Hlater.
  unfold dust_owned_calls_at, dust_rng_trace.
  assert (Nat.eqb tap_frame later_frame = false) as Hneq.
  { apply Nat.eqb_neq; lia. }
  now rewrite Hneq.
Qed.

(** In the source-derived normal-list model, SURFACE objects, including the TTC
    spinner, are updated before Mario's
    PLAYER list.  The four dust-owned calls occur later in DEFAULT and
    UNIMPORTANT, so their seed effect is first visible to a spinner update on
    the following frame. *)
Definition earliest_spinner_visible_frame (tap_frame : nat) : nat :=
  S tap_frame.

Theorem dust_rng_not_spinner_visible_on_tap_frame :
  forall tap_frame,
    earliest_spinner_visible_frame tap_frame <> tap_frame.
Proof. intros; unfold earliest_spinner_visible_frame; lia. Qed.

Theorem dust_rng_earliest_spinner_visible_next_frame :
  forall tap_frame,
    earliest_spinner_visible_frame tap_frame = (tap_frame + 1)%nat.
Proof. intros; unfold earliest_spinner_visible_frame; lia. Qed.

Definition dust_prng_timing_claim
    (version : GameVersion) (tap_frame : nat) : Prop :=
  dust_prng_source_receipt version /\
  puff_rng_cost_at_timer 0 = 2%nat /\
  increment_puff_timer 0 = 1 /\
  (forall timer, timer <> 0 -> puff_rng_cost_at_timer timer = 0%nat) /\
  dust_owned_calls_at tap_frame tap_frame = 4%nat /\
  (forall later_frame,
    (tap_frame < later_frame)%nat ->
    dust_owned_calls_at tap_frame later_frame = 0%nat) /\
  earliest_spinner_visible_frame tap_frame = (tap_frame + 1)%nat.

Theorem dust_prng_timing_checked_us_jp :
  forall version tap_frame, dust_prng_timing_claim version tap_frame.
Proof.
  intros version tap_frame.
  unfold dust_prng_timing_claim.
  refine (conj (dust_prng_source_receipt_supported version) _).
  refine (conj fresh_puff_timer_has_exactly_two_rng_calls _).
  refine (conj fresh_puff_timer_advances_to_one _).
  refine (conj nonzero_puff_timer_has_no_rng_calls _).
  refine (conj (dust_rng_exactly_four_owned_calls tap_frame) _).
  refine (conj (dust_rng_no_later_owned_calls tap_frame) _).
  exact (dust_rng_earliest_spinner_visible_next_frame tap_frame).
Qed.
