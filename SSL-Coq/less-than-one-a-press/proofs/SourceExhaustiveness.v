From Coq Require Import Bool List ZArith.
From compcert Require Import Integers.
From LessThanOneAPress.Proofs Require Import GameTypes.

Import ListNotations.
Local Open Scope Z_scope.

(**
  This file is a small, decidable source-inventory kernel.  It records the
  normal SSL star indices, the five Pyramid Puzzle trigger identities, and a
  target-save writer classification.

  Nothing in this file claims that every Clight or ROM execution is represented
  by [TargetBitWriterEvent].  Establishing that refinement, and excluding the
  explicit anomaly cases below for reachable executions, are separate proof
  obligations.
*)

Definition klepto_star_index : Z := 0.
Definition area1_static_star_index : Z := 1.
Definition eyerok_star_index : Z := 3.
Definition red_coin_star_index : Z := 4.

Inductive NormalSSLStarSource :=
| SourceKlepto
| SourceArea1Static
| SourceAct3Pyramid
| SourceEyerok
| SourceRedCoins
| SourcePyramidPuzzle
| SourceHundredCoins.

Definition normal_ssl_star_source_eq_dec :
  forall left right : NormalSSLStarSource, {left = right} + {left <> right}.
Proof. decide equality. Defined.

Definition all_normal_ssl_star_sources : list NormalSSLStarSource :=
  [ SourceKlepto;
    SourceArea1Static;
    SourceAct3Pyramid;
    SourceEyerok;
    SourceRedCoins;
    SourcePyramidPuzzle;
    SourceHundredCoins ].

Definition normal_ssl_star_index (source : NormalSSLStarSource) : Z :=
  match source with
  | SourceKlepto => klepto_star_index
  | SourceArea1Static => area1_static_star_index
  | SourceAct3Pyramid => act3_index
  | SourceEyerok => eyerok_star_index
  | SourceRedCoins => red_coin_star_index
  | SourcePyramidPuzzle => act6_index
  | SourceHundredCoins => hundred_coin_index
  end.

Definition normal_ssl_source_at_index
    (index : Z) : option NormalSSLStarSource :=
  if Z.eqb index klepto_star_index then Some SourceKlepto else
  if Z.eqb index area1_static_star_index then Some SourceArea1Static else
  if Z.eqb index act3_index then Some SourceAct3Pyramid else
  if Z.eqb index eyerok_star_index then Some SourceEyerok else
  if Z.eqb index red_coin_star_index then Some SourceRedCoins else
  if Z.eqb index act6_index then Some SourcePyramidPuzzle else
  if Z.eqb index hundred_coin_index then Some SourceHundredCoins else
  None.

Theorem all_normal_ssl_star_sources_complete :
  forall source, In source all_normal_ssl_star_sources.
Proof.
  intros []; unfold all_normal_ssl_star_sources; simpl; tauto.
Qed.

Theorem all_normal_ssl_star_sources_distinct :
  NoDup all_normal_ssl_star_sources.
Proof.
  unfold all_normal_ssl_star_sources.
  repeat constructor; simpl; intuition congruence.
Qed.

Theorem all_normal_ssl_star_sources_have_cardinality_seven :
  length all_normal_ssl_star_sources = 7%nat.
Proof. reflexivity. Qed.

Theorem normal_ssl_star_index_inventory :
  map normal_ssl_star_index all_normal_ssl_star_sources =
    [ klepto_star_index;
      area1_static_star_index;
      act3_index;
      eyerok_star_index;
      red_coin_star_index;
      act6_index;
      hundred_coin_index ].
Proof. reflexivity. Qed.

Theorem normal_ssl_star_index_injective :
  forall left right,
    normal_ssl_star_index left = normal_ssl_star_index right ->
    left = right.
Proof.
  intros [] []; cbn;
    unfold klepto_star_index, area1_static_star_index, act3_index,
      eyerok_star_index, red_coin_star_index, act6_index,
      hundred_coin_index;
    intros; try reflexivity; discriminate.
Qed.

Theorem normal_ssl_source_lookup_complete :
  forall source,
    normal_ssl_source_at_index (normal_ssl_star_index source) = Some source.
Proof.
  intros []; reflexivity.
Qed.

Theorem normal_ssl_source_lookup_sound :
  forall index source,
    normal_ssl_source_at_index index = Some source ->
    index = normal_ssl_star_index source.
Proof.
  intros index source.
  unfold normal_ssl_source_at_index.
  destruct (Z.eqb_spec index klepto_star_index) as [-> | Hnot_klepto].
  - intros Hlookup. inversion Hlookup. reflexivity.
  - destruct (Z.eqb_spec index area1_static_star_index)
      as [-> | Hnot_area1].
    + intros Hlookup. inversion Hlookup. reflexivity.
    + destruct (Z.eqb_spec index act3_index) as [-> | Hnot_act3].
      * intros Hlookup. inversion Hlookup. reflexivity.
      * destruct (Z.eqb_spec index eyerok_star_index)
          as [-> | Hnot_eyerok].
        -- intros Hlookup. inversion Hlookup. reflexivity.
        -- destruct (Z.eqb_spec index red_coin_star_index)
            as [-> | Hnot_red_coins].
          ++ intros Hlookup. inversion Hlookup. reflexivity.
          ++ destruct (Z.eqb_spec index act6_index) as [-> | Hnot_act6].
             ** intros Hlookup. inversion Hlookup. reflexivity.
             ** destruct (Z.eqb_spec index hundred_coin_index)
                  as [-> | Hnot_hundred_coins].
                --- intros Hlookup. inversion Hlookup. reflexivity.
                --- discriminate.
Qed.

Theorem normal_ssl_source_lookup_unique :
  forall index first second,
    normal_ssl_source_at_index index = Some first ->
    normal_ssl_source_at_index index = Some second ->
    first = second.
Proof.
  intros index first second Hfirst Hsecond.
  rewrite Hfirst in Hsecond. inversion Hsecond. reflexivity.
Qed.

Theorem normal_ssl_act3_source_unique :
  forall source,
    normal_ssl_star_index source = act3_index ->
    source = SourceAct3Pyramid.
Proof.
  intros []; cbn;
    unfold klepto_star_index, area1_static_star_index, act3_index,
      eyerok_star_index, red_coin_star_index, act6_index,
      hundred_coin_index;
    intros; try reflexivity; discriminate.
Qed.

Theorem normal_ssl_act6_source_unique :
  forall source,
    normal_ssl_star_index source = act6_index ->
    source = SourcePyramidPuzzle.
Proof.
  intros []; cbn;
    unfold klepto_star_index, area1_static_star_index, act3_index,
      eyerok_star_index, red_coin_star_index, act6_index,
      hundred_coin_index;
    intros; try reflexivity; discriminate.
Qed.

Definition normal_ssl_non_target_sources : list NormalSSLStarSource :=
  [ SourceKlepto;
    SourceArea1Static;
    SourceEyerok;
    SourceRedCoins;
    SourceHundredCoins ].

Theorem normal_ssl_non_target_sources_do_not_alias_targets :
  forall source,
    In source normal_ssl_non_target_sources ->
    normal_ssl_star_index source <> act3_index /\
    normal_ssl_star_index source <> act6_index.
Proof.
  intros source Hin.
  destruct source; cbn in *;
    unfold normal_ssl_non_target_sources, klepto_star_index,
      area1_static_star_index, act3_index, eyerok_star_index,
      red_coin_star_index, act6_index, hundred_coin_index in *;
    simpl in Hin; intuition discriminate.
Qed.

Theorem normal_ssl_non_target_indices_do_not_alias_targets :
  forall index,
    In index
      [ klepto_star_index;
        area1_static_star_index;
        eyerok_star_index;
        red_coin_star_index;
        hundred_coin_index ] ->
    index <> act3_index /\ index <> act6_index.
Proof.
  intros index Hin.
  unfold klepto_star_index, area1_static_star_index, act3_index,
    eyerok_star_index, red_coin_star_index, act6_index,
    hundred_coin_index in *.
  simpl in Hin. intuition congruence.
Qed.

Theorem all_hidden_triggers_have_cardinality_five :
  length all_hidden_triggers = 5%nat.
Proof. reflexivity. Qed.

Theorem all_hidden_triggers_are_distinct :
  NoDup all_hidden_triggers.
Proof.
  unfold all_hidden_triggers.
  repeat constructor; simpl; intuition congruence.
Qed.

Theorem all_hidden_triggers_complete :
  forall trigger, In trigger all_hidden_triggers.
Proof.
  intros []; unfold all_hidden_triggers; simpl; tauto.
Qed.

Theorem upper_hidden_trigger_is_one_of_five :
  In TriggerUpper all_hidden_triggers.
Proof. apply all_hidden_triggers_complete. Qed.

Theorem all_hidden_triggers_exact :
  forall trigger,
    In trigger all_hidden_triggers <->
      trigger = TriggerLowerWest \/
      trigger = TriggerLowerEast \/
      trigger = TriggerMiddleWest \/
      trigger = TriggerMiddleNorth \/
      trigger = TriggerUpper.
Proof.
  intros []; unfold all_hidden_triggers; simpl; tauto.
Qed.

(** This pair isolates the active/backup copy operation from the rest of
    [GameState].  [game_state_save_slots] below is its direct projection. *)
Record SaveSlotPair := {
  active_save_flags : Int.int;
  backup_save_flags : Int.int
}.

Definition ssl_target_index (index : Z) : Prop :=
  index = act3_index \/ index = act6_index.

Definition active_backup_targets_coherent (saves : SaveSlotPair) : Prop :=
  forall index,
    ssl_target_index index ->
    star_bit (active_save_flags saves) index =
      star_bit (backup_save_flags saves) index.

Definition game_over_save_reload (saves : SaveSlotPair) : SaveSlotPair :=
  {| active_save_flags := backup_save_flags saves;
     backup_save_flags := backup_save_flags saves |}.

Definition game_state_save_slots (state : GameState) : SaveSlotPair :=
  {| active_save_flags := state_save_flags state;
     backup_save_flags := state_backup_save_flags state |}.

Theorem game_state_target_save_coherence_projects :
  forall state,
    target_save_coherent state ->
    active_backup_targets_coherent (game_state_save_slots state).
Proof.
  intros state [Hact3 Hact6] index [-> | ->].
  - exact Hact3.
  - exact Hact6.
Qed.

Theorem coherent_game_over_reload_preserves_target_bits :
  forall saves index,
    active_backup_targets_coherent saves ->
    ssl_target_index index ->
    star_bit (active_save_flags (game_over_save_reload saves)) index =
      star_bit (active_save_flags saves) index.
Proof.
  intros saves index Hcoherent Htarget.
  unfold game_over_save_reload. simpl.
  symmetry. apply Hcoherent. exact Htarget.
Qed.

Theorem coherent_game_over_reload_cannot_newly_set_target :
  forall saves index,
    active_backup_targets_coherent saves ->
    ssl_target_index index ->
    ~ newly_collected
        (active_save_flags saves)
        (active_save_flags (game_over_save_reload saves))
        index.
Proof.
  intros saves index Hcoherent Htarget [Hclear Hset].
  rewrite (coherent_game_over_reload_preserves_target_bits
    saves index Hcoherent Htarget) in Hset.
  rewrite Hclear in Hset. discriminate.
Qed.

Theorem coherent_game_over_reload_cannot_newly_set_either_target :
  forall saves,
    active_backup_targets_coherent saves ->
    ~ newly_collected
        (active_save_flags saves)
        (active_save_flags (game_over_save_reload saves))
        act3_index /\
    ~ newly_collected
        (active_save_flags saves)
        (active_save_flags (game_over_save_reload saves))
        act6_index.
Proof.
  intros saves Hcoherent. split.
  - eapply coherent_game_over_reload_cannot_newly_set_target.
    + exact Hcoherent.
    + unfold ssl_target_index. auto.
  - eapply coherent_game_over_reload_cannot_newly_set_target.
    + exact Hcoherent.
    + unfold ssl_target_index. auto.
Qed.

Theorem coherent_game_state_reload_cannot_newly_set_either_target :
  forall state,
    target_save_coherent state ->
    ~ newly_collected
        (state_save_flags state)
        (active_save_flags
          (game_over_save_reload (game_state_save_slots state)))
        act3_index /\
    ~ newly_collected
        (state_save_flags state)
        (active_save_flags
          (game_over_save_reload (game_state_save_slots state)))
        act6_index.
Proof.
  intros state Hcoherent.
  apply (coherent_game_over_reload_cannot_newly_set_either_target
    (game_state_save_slots state)).
  apply game_state_target_save_coherence_projects.
  exact Hcoherent.
Qed.

Inductive SSLTarget :=
| TargetAct3
| TargetAct6.

Definition ssl_target_eq_dec :
  forall left right : SSLTarget, {left = right} + {left <> right}.
Proof. decide equality. Defined.

Definition ssl_target_star_index (target : SSLTarget) : Z :=
  match target with
  | TargetAct3 => act3_index
  | TargetAct6 => act6_index
  end.

Definition normal_ssl_target_of_source
    (source : NormalSSLStarSource) : option SSLTarget :=
  match source with
  | SourceAct3Pyramid => Some TargetAct3
  | SourcePyramidPuzzle => Some TargetAct6
  | _ => None
  end.

Theorem normal_ssl_target_source_matches_index :
  forall source target,
    normal_ssl_target_of_source source = Some target ->
    normal_ssl_star_index source = ssl_target_star_index target.
Proof.
  intros [] []; cbn; intros; try discriminate; reflexivity.
Qed.

Theorem normal_ssl_target_inventory :
  forall source target,
    normal_ssl_target_of_source source = Some target ->
    (source = SourceAct3Pyramid /\ target = TargetAct3) \/
    (source = SourcePyramidPuzzle /\ target = TargetAct6).
Proof.
  intros [] []; cbn; intros; try discriminate; auto.
Qed.

(** A four-bit projection of the active and backup save slots.  The writer
    semantics below is executable; its anomaly constructor deliberately carries
    an arbitrary replacement snapshot instead of silently excluding such a
    state change. *)
Record TargetBitSnapshot := {
  active_act3_bit : bool;
  active_act6_bit : bool;
  backup_act3_bit : bool;
  backup_act6_bit : bool
}.

Definition snapshot_active_target
    (snapshot : TargetBitSnapshot) (target : SSLTarget) : bool :=
  match target with
  | TargetAct3 => active_act3_bit snapshot
  | TargetAct6 => active_act6_bit snapshot
  end.

Definition snapshot_backup_target
    (snapshot : TargetBitSnapshot) (target : SSLTarget) : bool :=
  match target with
  | TargetAct3 => backup_act3_bit snapshot
  | TargetAct6 => backup_act6_bit snapshot
  end.

Definition target_snapshot_from_save_slots
    (saves : SaveSlotPair) : TargetBitSnapshot :=
  {| active_act3_bit := star_bit (active_save_flags saves) act3_index;
     active_act6_bit := star_bit (active_save_flags saves) act6_index;
     backup_act3_bit := star_bit (backup_save_flags saves) act3_index;
     backup_act6_bit := star_bit (backup_save_flags saves) act6_index |}.

Definition target_snapshot_coherent (snapshot : TargetBitSnapshot) : Prop :=
  forall target,
    snapshot_active_target snapshot target =
      snapshot_backup_target snapshot target.

Theorem coherent_save_slots_project_to_coherent_snapshot :
  forall saves,
    active_backup_targets_coherent saves ->
    target_snapshot_coherent (target_snapshot_from_save_slots saves).
Proof.
  intros saves Hcoherent [].
  - apply Hcoherent. unfold ssl_target_index. auto.
  - apply Hcoherent. unfold ssl_target_index. auto.
Qed.

Definition set_snapshot_active_target
    (snapshot : TargetBitSnapshot) (target : SSLTarget) : TargetBitSnapshot :=
  match target with
  | TargetAct3 =>
      {| active_act3_bit := true;
         active_act6_bit := active_act6_bit snapshot;
         backup_act3_bit := backup_act3_bit snapshot;
         backup_act6_bit := backup_act6_bit snapshot |}
  | TargetAct6 =>
      {| active_act3_bit := active_act3_bit snapshot;
         active_act6_bit := true;
         backup_act3_bit := backup_act3_bit snapshot;
         backup_act6_bit := backup_act6_bit snapshot |}
  end.

Definition apply_normal_ssl_star_interaction
    (snapshot : TargetBitSnapshot)
    (source : NormalSSLStarSource) : TargetBitSnapshot :=
  match normal_ssl_target_of_source source with
  | Some target => set_snapshot_active_target snapshot target
  | None => snapshot
  end.

Definition reload_snapshot_from_backup
    (snapshot : TargetBitSnapshot) : TargetBitSnapshot :=
  {| active_act3_bit := backup_act3_bit snapshot;
     active_act6_bit := backup_act6_bit snapshot;
     backup_act3_bit := backup_act3_bit snapshot;
     backup_act6_bit := backup_act6_bit snapshot |}.

Inductive TargetBitWriterEvent :=
| WriterNormalStarInteraction (source : NormalSSLStarSource)
| WriterGameOverSaveReload
| WriterCorruptionOrUnmodeled (replacement : TargetBitSnapshot).

Definition apply_target_bit_writer
    (snapshot : TargetBitSnapshot)
    (writer : TargetBitWriterEvent) : TargetBitSnapshot :=
  match writer with
  | WriterNormalStarInteraction source =>
      apply_normal_ssl_star_interaction snapshot source
  | WriterGameOverSaveReload =>
      reload_snapshot_from_backup snapshot
  | WriterCorruptionOrUnmodeled replacement =>
      replacement
  end.

(** [FirstTargetBitTransition target initial writers before writer after]
    states that every earlier writer leaves [target] clear, while [writer]
    changes it from clear to set. *)
Inductive FirstTargetBitTransition (target : SSLTarget) :
    TargetBitSnapshot ->
    list TargetBitWriterEvent ->
    TargetBitSnapshot ->
    TargetBitWriterEvent ->
    TargetBitSnapshot ->
    Prop :=
| FirstTargetTransitionHere :
    forall before writer remaining,
      snapshot_active_target before target = false ->
      snapshot_active_target
        (apply_target_bit_writer before writer) target = true ->
      FirstTargetBitTransition target before (writer :: remaining)
        before writer (apply_target_bit_writer before writer)
| FirstTargetTransitionLater :
    forall before writer remaining
      transition_before transition_writer transition_after,
      snapshot_active_target before target = false ->
      snapshot_active_target
        (apply_target_bit_writer before writer) target = false ->
      FirstTargetBitTransition target
        (apply_target_bit_writer before writer)
        remaining
        transition_before transition_writer transition_after ->
      FirstTargetBitTransition target before (writer :: remaining)
        transition_before transition_writer transition_after.

Inductive FirstTargetTransitionCause
    (target : SSLTarget)
    (before : TargetBitSnapshot)
    (writer : TargetBitWriterEvent) : Prop :=
| FirstTransitionByNormalTargetStar :
    forall source,
      writer = WriterNormalStarInteraction source ->
      normal_ssl_target_of_source source = Some target ->
      FirstTargetTransitionCause target before writer
| FirstTransitionByIncoherentReload :
    writer = WriterGameOverSaveReload ->
    snapshot_active_target before target = false ->
    snapshot_backup_target before target = true ->
    FirstTargetTransitionCause target before writer
| FirstTransitionByCorruptionOrUnmodeled :
    forall replacement,
      writer = WriterCorruptionOrUnmodeled replacement ->
      FirstTargetTransitionCause target before writer.

Lemma normal_star_writer_sets_only_its_target :
  forall before source target,
    snapshot_active_target before target = false ->
    snapshot_active_target
      (apply_target_bit_writer before
        (WriterNormalStarInteraction source)) target = true ->
    normal_ssl_target_of_source source = Some target.
Proof.
  intros before [] []; cbn; intros; try congruence; reflexivity.
Qed.

Lemma reload_writer_newly_sets_only_from_set_backup :
  forall before target,
    snapshot_active_target before target = false ->
    snapshot_active_target
      (apply_target_bit_writer before WriterGameOverSaveReload) target = true ->
    snapshot_backup_target before target = true.
Proof.
  intros before []; cbn; intros; assumption.
Qed.

Theorem first_target_bit_transition_classification :
  forall target initial writers before writer after,
    FirstTargetBitTransition
      target initial writers before writer after ->
    FirstTargetTransitionCause target before writer.
Proof.
  intros target initial writers before writer after Htransition.
  induction Htransition as
    [ transition_before transition_writer remaining Hclear Hset
    | prefix_before prefix_writer remaining transition_before
        transition_writer transition_after Hprefix_clear
        Hprefix_preserved Htail IH ].
  - destruct transition_writer as [source | | replacement].
    + econstructor 1 with (source := source).
      * reflexivity.
      * eapply normal_star_writer_sets_only_its_target; eauto.
    + econstructor 2.
      * reflexivity.
      * exact Hclear.
      * eapply reload_writer_newly_sets_only_from_set_backup; eauto.
    + econstructor 3 with (replacement := replacement). reflexivity.
  - exact IH.
Qed.

Definition modeled_target_bit_writer
    (writer : TargetBitWriterEvent) : Prop :=
  match writer with
  | WriterNormalStarInteraction _ => True
  | WriterGameOverSaveReload => True
  | WriterCorruptionOrUnmodeled _ => False
  end.

Lemma modeled_target_bit_writer_preserves_backup :
  forall before writer target,
    modeled_target_bit_writer writer ->
    snapshot_backup_target (apply_target_bit_writer before writer) target =
      snapshot_backup_target before target.
Proof.
  intros before [source | | replacement] target Hmodeled.
  - destruct source, target; reflexivity.
  - destruct target; reflexivity.
  - contradiction.
Qed.

Lemma first_target_bit_transition_initially_clear :
  forall target initial writers before writer after,
    FirstTargetBitTransition
      target initial writers before writer after ->
    snapshot_active_target initial target = false.
Proof.
  intros target initial writers before writer after Htransition.
  destruct Htransition; assumption.
Qed.

Lemma first_target_bit_transition_writer_in_trace :
  forall target initial writers before writer after,
    FirstTargetBitTransition
      target initial writers before writer after ->
    In writer writers.
Proof.
  intros target initial writers before writer after Htransition.
  induction Htransition; simpl; auto.
Qed.

Lemma first_target_bit_transition_preserves_backup_before_writer :
  forall target initial writers before writer after,
    FirstTargetBitTransition
      target initial writers before writer after ->
    Forall modeled_target_bit_writer writers ->
    snapshot_backup_target before target =
      snapshot_backup_target initial target.
Proof.
  intros target initial writers before writer after Htransition.
  induction Htransition as
    [ transition_before transition_writer remaining Hclear Hset
    | prefix_before prefix_writer remaining transition_before
        transition_writer transition_after Hprefix_clear
        Hprefix_preserved Htail IH ];
    intros Hall.
  - reflexivity.
  - inversion Hall as [|head tail Hhead Hremaining]; subst.
    etransitivity.
    + apply IH. exact Hremaining.
    + apply modeled_target_bit_writer_preserves_backup.
      exact Hhead.
Qed.

(** In the executable writer kernel, coherent initial target bits and an
    anomaly-free trace leave the matching normal star interaction as the only
    possible first setter.  A Clight-to-writer coverage theorem is still needed
    before this result applies to the game. *)
Theorem anomaly_free_coherent_first_transition_is_normal_target_star :
  forall target initial writers before writer after,
    target_snapshot_coherent initial ->
    FirstTargetBitTransition
      target initial writers before writer after ->
    Forall modeled_target_bit_writer writers ->
    exists source,
      writer = WriterNormalStarInteraction source /\
      normal_ssl_target_of_source source = Some target.
Proof.
  intros target initial writers before writer after
    Hcoherent Htransition Hall.
  pose proof (first_target_bit_transition_classification
    target initial writers before writer after Htransition)
    as Hcause.
  destruct Hcause as
    [source Hwriter Hsource
    | Hwriter Hclear Hbackup
    | replacement Hwriter].
  - exists source. auto.
  - assert (Hinitial_clear :
      snapshot_active_target initial target = false).
    { eapply first_target_bit_transition_initially_clear. exact Htransition. }
    assert (Hbackup_preserved :
      snapshot_backup_target before target =
        snapshot_backup_target initial target).
    { eapply first_target_bit_transition_preserves_backup_before_writer;
        eauto. }
    rewrite Hbackup_preserved in Hbackup.
    rewrite <- (Hcoherent target) in Hbackup.
    rewrite Hinitial_clear in Hbackup. discriminate.
  - assert (Hin : In writer writers).
    { eapply first_target_bit_transition_writer_in_trace. exact Htransition. }
    assert (Hmodeled : modeled_target_bit_writer writer).
    { eapply Forall_forall; eauto. }
    rewrite Hwriter in Hmodeled. simpl in Hmodeled. contradiction.
Qed.

Theorem coherent_snapshot_reload_cannot_be_first_transition :
  forall target before remaining transition_after,
    target_snapshot_coherent before ->
    ~ FirstTargetBitTransition target before
        (WriterGameOverSaveReload :: remaining)
        before WriterGameOverSaveReload transition_after.
Proof.
  intros target before remaining transition_after Hcoherent Htransition.
  pose proof (first_target_bit_transition_classification
    target before (WriterGameOverSaveReload :: remaining)
    before WriterGameOverSaveReload transition_after Htransition)
    as Hcause.
  destruct Hcause as
    [source Hwriter Hsource
    | Hwriter Hclear Hbackup
    | replacement Hwriter].
  - discriminate Hwriter.
  - rewrite (Hcoherent target) in Hclear.
    rewrite Hbackup in Hclear. discriminate.
  - discriminate Hwriter.
Qed.
