(** Rank 15: finite exhaustive search over the Eyerok scheduler skeleton.

    A literal search over controller frames is not exhaustive: analog samples,
    arbitrary waiting, timers, and Float32 positions make that tree unbounded.
    This file instead quotients a run at the source's boss/hand action
    boundaries.  Self edges represent arbitrary waiting, RNG and controller
    branches are all retained, and the two hands may take any pair of
    source-shaped edges in one abstract step.  This is deliberately an
    over-approximation: it can create impossible pairings, but cannot remove a
    pairing merely because the scheduler normally serializes it.

    The raw product contains 181,944 boss-edge / left-edge / right-edge /
    Mario-effect cases.  Since the seed transformer is independent of the
    three control-edge labels, the kernel check evaluates the six distinct
    effect representatives and proves that every raw tuple projects to one of
    them; this avoids constructing a huge redundant proof term.  More
    importantly, the induction below covers lists of those effects of
    arbitrary length.  It proves that, once Mario enters the boss schedule
    with vertical seed at most 31, no represented Eyerok interaction, platform
    carry, zero-damage knockback, hit-from-below, or checked no-new-A jump-kick
    can manufacture seed 32.  The only represented stock top bounce is 30.

    This does not decide dynamic support.  Seven of the sixteen hand action
    classes can raise a collision owner, and the quotient intentionally omits
    the continuous X/Y/Z, transformed triangles, update order, and Mario floor
    ownership needed to accept or reject those contacts.  Those seven classes
    are the now-finite geometry worklist.  The generated-source receipts are
    syntax facts rather than a linked Clight refinement theorem: a final
    clean-execution verdict must still prove that every reached live frame
    refines to one of the six effect representatives. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Integers.
From LessThanOneAPress.Proofs Require Import
  ClightFacts EyerokControllerManipulation EyerokRank15VSC.

Import ListNotations.
Local Open Scope Z_scope.

(** * Generated stock-data receipts *)

Definition rank15_expected_eyerok_hitbox : list init_data :=
  [Init_int32 (Int.repr 32768);
   Init_int8 (Int.repr 0);  (** down offset *)
   Init_int8 (Int.repr 0);  (** damage *)
   Init_int8 (Int.repr 4);  (** health *)
   Init_int8 (Int.repr 0);  (** loot coins *)
   Init_int16 (Int.repr 150);
   Init_int16 (Int.repr 100);
   Init_int16 (Int.repr 1);
   Init_int16 (Int.repr 1)].

Definition rank15_expected_us_eyerok_hand_script : list init_data :=
  [Init_int32 (Int.repr 589824);
   Init_int32 (Int.repr 285286465);
   Init_int32 (Int.repr 656801792);
   Init_addrof UBD._eyerok_seg5_anims_050116E4 (Ptrofs.repr 0);
   Init_int32 (Int.repr 671481856);
   Init_int32 (Int.repr 805306368);
   Init_int32 (Int.repr 9830400);
   Init_int32 (Int.repr 0);
   Init_int32 (Int.repr 65536200);
   Init_int32 (Int.repr 0);
   Init_int32 (Int.repr 754974720);
   Init_int32 (Int.repr 270139395);
   Init_int32 (Int.repr 134217728);
   Init_int32 (Int.repr 201326592);
   Init_addrof UBD._bhv_eyerok_hand_loop (Ptrofs.repr 0);
   Init_int32 (Int.repr 150994944)].

Definition rank15_expected_jp_eyerok_hand_script : list init_data :=
  [Init_int32 (Int.repr 589824);
   Init_int32 (Int.repr 285286465);
   Init_int32 (Int.repr 656801792);
   Init_addrof JBD._eyerok_seg5_anims_050116E4 (Ptrofs.repr 0);
   Init_int32 (Int.repr 671481856);
   Init_int32 (Int.repr 805306368);
   Init_int32 (Int.repr 9830400);
   Init_int32 (Int.repr 0);
   Init_int32 (Int.repr 65536200);
   Init_int32 (Int.repr 0);
   Init_int32 (Int.repr 754974720);
   Init_int32 (Int.repr 270139395);
   Init_int32 (Int.repr 134217728);
   Init_int32 (Int.repr 201326592);
   Init_addrof JBD._bhv_eyerok_hand_loop (Ptrofs.repr 0);
   Init_int32 (Int.repr 150994944)].

Definition EyerokRank15ScheduleSourceReceipt : Prop :=
  gvar_init UEye.v_sEyerokHitbox = rank15_expected_eyerok_hitbox /\
  gvar_init JEye.v_sEyerokHitbox = rank15_expected_eyerok_hitbox /\
  gvar_init UBD.v_bhvEyerokHand = rank15_expected_us_eyerok_hand_script /\
  gvar_init JBD.v_bhvEyerokHand = rank15_expected_jp_eyerok_hand_script /\
  EyerokControllerSourceShape /\
  eyerok_lifecycle_source_shape_us_claim /\
  eyerok_lifecycle_source_shape_jp_claim /\
  EyerokRank15VSCSourceShape.

Theorem eyerok_rank15_schedule_source_receipt_checked :
  EyerokRank15ScheduleSourceReceipt.
Proof.
  unfold EyerokRank15ScheduleSourceReceipt,
    rank15_expected_eyerok_hitbox,
    rank15_expected_us_eyerok_hand_script,
    rank15_expected_jp_eyerok_hand_script.
  refine (conj eq_refl _).
  refine (conj eq_refl _).
  refine (conj eq_refl _).
  refine (conj eq_refl _).
  refine (conj eyerok_controller_source_shape_checked _).
  refine (conj eyerok_lifecycle_source_shape_us _).
  refine (conj eyerok_lifecycle_source_shape_jp _).
  exact eyerok_rank15_vsc_source_shape_checked.
Qed.

(** Eyerok's script does not install the twirl-bounce subtype.  The executable
    effect census below therefore takes the clean allocated value zero as its
    boundary; alias/OOB/ACE changes are outside this stock schedule model. *)
Definition rank15_twirling_bounce_subtype_bit : Z := 128.

Definition rank15_has_twirling_bounce_subtype (subtype : Z) : bool :=
  negb (Z.eqb (Z.land subtype rank15_twirling_bounce_subtype_bit) 0).

Theorem rank15_clean_subtype_excludes_eighty_unit_bounce :
  rank15_has_twirling_bounce_subtype 0 = false.
Proof. vm_compute. reflexivity. Qed.

(** * Finite boss and hand action quotient *)

Inductive Rank15BossPhase : Type :=
| Rank15BossSleep
| Rank15BossWake
| Rank15BossIntro
| Rank15BossFightQuiescent
| Rank15BossNegativeDouble
| Rank15BossPositiveDouble
| Rank15BossLeftSingle
| Rank15BossRightSingle
| Rank15BossDie.

Scheme Equality for Rank15BossPhase.

Definition rank15_all_boss_phases : list Rank15BossPhase :=
  [Rank15BossSleep; Rank15BossWake; Rank15BossIntro;
   Rank15BossFightQuiescent; Rank15BossNegativeDouble;
   Rank15BossPositiveDouble; Rank15BossLeftSingle;
   Rank15BossRightSingle; Rank15BossDie].

Definition rank15_boss_successors
    (phase : Rank15BossPhase) : list Rank15BossPhase :=
  match phase with
  | Rank15BossSleep => [Rank15BossSleep; Rank15BossWake]
  | Rank15BossWake => [Rank15BossWake; Rank15BossIntro]
  | Rank15BossIntro => [Rank15BossIntro; Rank15BossFightQuiescent]
  | Rank15BossFightQuiescent =>
      [Rank15BossFightQuiescent; Rank15BossNegativeDouble;
       Rank15BossPositiveDouble; Rank15BossLeftSingle;
       Rank15BossRightSingle; Rank15BossDie]
  | Rank15BossNegativeDouble =>
      [Rank15BossNegativeDouble; Rank15BossFightQuiescent]
  | Rank15BossPositiveDouble =>
      [Rank15BossPositiveDouble; Rank15BossFightQuiescent]
  | Rank15BossLeftSingle =>
      [Rank15BossLeftSingle; Rank15BossFightQuiescent]
  | Rank15BossRightSingle =>
      [Rank15BossRightSingle; Rank15BossFightQuiescent]
  | Rank15BossDie => [Rank15BossDie]
  end.

Inductive Rank15HandPhase : Type :=
| Rank15HandSleep
| Rank15HandIdle
| Rank15HandOpen
| Rank15HandShowEye
| Rank15HandClose
| Rank15HandRetreat
| Rank15HandTargetMario
| Rank15HandSmash
| Rank15HandFistPush
| Rank15HandFistSweep
| Rank15HandBeginDouble
| Rank15HandDoublePound
| Rank15HandAttacked
| Rank15HandRecover
| Rank15HandBecomeActive
| Rank15HandDie.

Scheme Equality for Rank15HandPhase.

Definition rank15_all_hand_phases : list Rank15HandPhase :=
  [Rank15HandSleep; Rank15HandIdle; Rank15HandOpen; Rank15HandShowEye;
   Rank15HandClose; Rank15HandRetreat; Rank15HandTargetMario;
   Rank15HandSmash; Rank15HandFistPush; Rank15HandFistSweep;
   Rank15HandBeginDouble; Rank15HandDoublePound; Rank15HandAttacked;
   Rank15HandRecover; Rank15HandBecomeActive; Rank15HandDie].

(** Every assignment made by the stock handlers is retained.  Self edges
    absorb timer, animation, collision, RNG, and controller waiting. *)
Definition rank15_hand_successors
    (phase : Rank15HandPhase) : list Rank15HandPhase :=
  match phase with
  | Rank15HandSleep => [Rank15HandSleep; Rank15HandIdle]
  | Rank15HandIdle =>
      [Rank15HandIdle; Rank15HandOpen; Rank15HandTargetMario;
       Rank15HandFistPush; Rank15HandBeginDouble]
  | Rank15HandOpen => [Rank15HandOpen; Rank15HandShowEye]
  | Rank15HandShowEye =>
      [Rank15HandShowEye; Rank15HandClose; Rank15HandAttacked;
       Rank15HandDie]
  | Rank15HandClose =>
      [Rank15HandClose; Rank15HandRetreat; Rank15HandIdle]
  | Rank15HandRetreat => [Rank15HandRetreat; Rank15HandIdle]
  | Rank15HandTargetMario => [Rank15HandTargetMario; Rank15HandSmash]
  | Rank15HandSmash =>
      [Rank15HandSmash; Rank15HandFistSweep; Rank15HandRetreat]
  | Rank15HandFistPush => [Rank15HandFistPush; Rank15HandFistSweep]
  | Rank15HandFistSweep => [Rank15HandFistSweep; Rank15HandRetreat]
  | Rank15HandBeginDouble =>
      [Rank15HandBeginDouble; Rank15HandDoublePound]
  | Rank15HandDoublePound =>
      [Rank15HandDoublePound; Rank15HandRetreat]
  | Rank15HandAttacked => [Rank15HandAttacked; Rank15HandRecover]
  | Rank15HandRecover => [Rank15HandRecover; Rank15HandBecomeActive]
  | Rank15HandBecomeActive =>
      [Rank15HandBecomeActive; Rank15HandRetreat]
  | Rank15HandDie => [Rank15HandDie]
  end.

Definition rank15_edges {A : Type}
    (successors : A -> list A) (states : list A) : list (A * A) :=
  flat_map
    (fun before => map (fun after => (before, after)) (successors before))
    states.

Definition rank15_boss_edges : list (Rank15BossPhase * Rank15BossPhase) :=
  rank15_edges rank15_boss_successors rank15_all_boss_phases.

Definition rank15_hand_edges : list (Rank15HandPhase * Rank15HandPhase) :=
  rank15_edges rank15_hand_successors rank15_all_hand_phases.

Definition rank15_boss_successor_closed : bool :=
  forallb
    (fun phase =>
      forallb
        (fun successor =>
          existsb (Rank15BossPhase_beq successor) rank15_all_boss_phases)
        (rank15_boss_successors phase))
    rank15_all_boss_phases.

Definition rank15_hand_successor_closed : bool :=
  forallb
    (fun phase =>
      forallb
        (fun successor =>
          existsb (Rank15HandPhase_beq successor) rank15_all_hand_phases)
        (rank15_hand_successors phase))
    rank15_all_hand_phases.

Theorem rank15_finite_action_graph_receipt :
  length rank15_all_boss_phases = 9%nat /\
  length rank15_all_hand_phases = 16%nat /\
  length rank15_boss_edges = 21%nat /\
  length rank15_hand_edges = 38%nat /\
  rank15_boss_successor_closed = true /\
  rank15_hand_successor_closed = true.
Proof. vm_compute. repeat split. Qed.

(** * Candidate complete direct Mario-effect alphabet *)

Inductive Rank15MarioSeedEffect : Type :=
| Rank15FramePreservesSeed
| Rank15PlatformCarryPreservesSeed
| Rank15ZeroDamageKnockbackPreservesSeed
| Rank15HitFromBelowClearsSeed
| Rank15HeldAJumpKickInstallsTwenty
| Rank15EyerokTopBounceInstallsThirty.

Definition rank15_all_mario_seed_effects : list Rank15MarioSeedEffect :=
  [Rank15FramePreservesSeed; Rank15PlatformCarryPreservesSeed;
   Rank15ZeroDamageKnockbackPreservesSeed; Rank15HitFromBelowClearsSeed;
   Rank15HeldAJumpKickInstallsTwenty;
   Rank15EyerokTopBounceInstallsThirty].

Definition rank15_apply_seed_effect
    (effect : Rank15MarioSeedEffect) (seed : Z) : Z :=
  match effect with
  | Rank15FramePreservesSeed
  | Rank15PlatformCarryPreservesSeed
  | Rank15ZeroDamageKnockbackPreservesSeed => seed
  | Rank15HitFromBelowClearsSeed => 0
  | Rank15HeldAJumpKickInstallsTwenty => 20
  | Rank15EyerokTopBounceInstallsThirty => 30
  end.

(** [Rank15FramePreservesSeed] is the upper-envelope representative for a
    frame that leaves the seed unchanged or decreases it through gravity or a
    collision.  Mapping every reached live frame into this alphabet is a
    separate refinement obligation; it is not inferred from the action name. *)

Definition rank15_installed_seed
    (effect : Rank15MarioSeedEffect) : option Z :=
  match effect with
  | Rank15HitFromBelowClearsSeed => Some 0
  | Rank15HeldAJumpKickInstallsTwenty => Some 20
  | Rank15EyerokTopBounceInstallsThirty => Some 30
  | _ => None
  end.

Definition rank15_effect_safe_at_31 (effect : Rank15MarioSeedEffect) : bool :=
  rank15_apply_seed_effect effect 31 <=? 31.

(** Symmetry-reduced executable check.  Every raw schedule tuple carries one
    of exactly these six effects, and the control edges do not alter the seed
    transformer. *)
Definition rank15_bruteforce_all_schedule_cases_safe : bool :=
  forallb rank15_effect_safe_at_31 rank15_all_mario_seed_effects.

Definition rank15_bruteforce_case_count : Z :=
  Z.of_nat (length rank15_boss_edges) *
  Z.of_nat (length rank15_hand_edges) *
  Z.of_nat (length rank15_hand_edges) *
  Z.of_nat (length rank15_all_mario_seed_effects).

Theorem rank15_bruteforce_schedule_receipt :
  rank15_bruteforce_case_count = 181944 /\
  rank15_bruteforce_all_schedule_cases_safe = true.
Proof. vm_compute. split; reflexivity. Qed.

Theorem rank15_every_raw_schedule_tuple_projects_to_safe_representative :
  forall boss_edge left_edge right_edge effect,
    In boss_edge rank15_boss_edges ->
    In left_edge rank15_hand_edges ->
    In right_edge rank15_hand_edges ->
    In effect rank15_all_mario_seed_effects ->
    rank15_effect_safe_at_31 effect = true.
Proof.
  intros boss_edge left_edge right_edge effect _ _ _ Hin.
  repeat (destruct Hin as [Hin | Hin]; [subst effect |]);
    try contradiction; reflexivity.
Qed.

Theorem rank15_every_fresh_stock_installer_is_at_most_thirty :
  forall effect installed,
    In effect rank15_all_mario_seed_effects ->
    rank15_installed_seed effect = Some installed ->
    installed <= 30.
Proof.
  intros effect installed Hin Hinstalled.
  repeat (destruct Hin as [Hin | Hin]; [subst effect |]);
    try contradiction; cbn in Hinstalled; try discriminate;
    inversion Hinstalled; lia.
Qed.

Lemma rank15_one_effect_preserves_subthreshold_seed :
  forall effect seed,
    seed <= 31 ->
    rank15_apply_seed_effect effect seed <= 31.
Proof. intros effect seed Hseed; destruct effect; cbn; lia. Qed.

Fixpoint rank15_run_seed_effects
    (effects : list Rank15MarioSeedEffect) (seed : Z) : Z :=
  match effects with
  | [] => seed
  | effect :: rest =>
      rank15_run_seed_effects rest (rank15_apply_seed_effect effect seed)
  end.

(** Unlike a bounded controller search, this theorem covers arbitrarily many
    scheduler cycles.  Repetition cannot stack the direct assignments. *)
Theorem rank15_every_finite_clean_schedule_preserves_seed_below_32 :
  forall effects seed,
    seed <= 31 ->
    rank15_run_seed_effects effects seed <= 31.
Proof.
  induction effects as [|effect rest IH]; intros seed Hseed; cbn.
  - exact Hseed.
  - apply IH. apply rank15_one_effect_preserves_subthreshold_seed.
    exact Hseed.
Qed.

(** * Remaining dynamic-support worklist *)

Definition rank15_can_create_new_upward_hand_motion
    (phase : Rank15HandPhase) : bool :=
  match phase with
  | Rank15HandSleep       (** wake-up sine curve *)
  | Rank15HandIdle        (** boss wake offset *)
  | Rank15HandTargetMario (** approach home + 300 *)
  | Rank15HandBeginDouble (** double-pound formation *)
  | Rank15HandDoublePound (** 100 launch, then gravity *)
  | Rank15HandAttacked    (** 30 launch *)
  | Rank15HandDie => true (** 50 launch *)
  | _ => false
  end.

Definition rank15_upward_geometry_worklist : list Rank15HandPhase :=
  filter rank15_can_create_new_upward_hand_motion rank15_all_hand_phases.

Theorem rank15_dynamic_support_is_reduced_to_seven_action_classes :
  rank15_upward_geometry_worklist =
    [Rank15HandSleep; Rank15HandIdle; Rank15HandTargetMario;
     Rank15HandBeginDouble; Rank15HandDoublePound; Rank15HandAttacked;
     Rank15HandDie] /\
  length rank15_upward_geometry_worklist = 7%nat.
Proof. vm_compute. split; reflexivity. Qed.

Definition EyerokRank15ScheduleSearchBoundary : Prop :=
  EyerokRank15ScheduleSourceReceipt /\
  rank15_has_twirling_bounce_subtype 0 = false /\
  length rank15_boss_edges = 21%nat /\
  length rank15_hand_edges = 38%nat /\
  rank15_boss_successor_closed = true /\
  rank15_hand_successor_closed = true /\
  rank15_bruteforce_case_count = 181944 /\
  rank15_bruteforce_all_schedule_cases_safe = true /\
  (forall boss_edge left_edge right_edge effect,
    In boss_edge rank15_boss_edges ->
    In left_edge rank15_hand_edges ->
    In right_edge rank15_hand_edges ->
    In effect rank15_all_mario_seed_effects ->
    rank15_effect_safe_at_31 effect = true) /\
  (forall effects seed,
    seed <= 31 ->
    rank15_run_seed_effects effects seed <= 31) /\
  rank15_upward_geometry_worklist =
    [Rank15HandSleep; Rank15HandIdle; Rank15HandTargetMario;
     Rank15HandBeginDouble; Rank15HandDoublePound; Rank15HandAttacked;
     Rank15HandDie].

Theorem eyerok_rank15_schedule_search_boundary_holds :
  EyerokRank15ScheduleSearchBoundary.
Proof.
  unfold EyerokRank15ScheduleSearchBoundary.
  refine (conj eyerok_rank15_schedule_source_receipt_checked _).
  refine (conj rank15_clean_subtype_excludes_eighty_unit_bounce _).
  destruct rank15_finite_action_graph_receipt as
    [_ [_ [Hboss [Hhand [Hboss_closed Hhand_closed]]]]].
  refine (conj Hboss _).
  refine (conj Hhand _).
  refine (conj Hboss_closed _).
  refine (conj Hhand_closed _).
  destruct rank15_bruteforce_schedule_receipt as [Hcount Hsafe].
  refine (conj Hcount _).
  refine (conj Hsafe _).
  refine (conj
    rank15_every_raw_schedule_tuple_projects_to_safe_representative _).
  refine (conj rank15_every_finite_clean_schedule_preserves_seed_below_32 _).
  exact (proj1 rank15_dynamic_support_is_reduced_to_seven_action_classes).
Qed.
